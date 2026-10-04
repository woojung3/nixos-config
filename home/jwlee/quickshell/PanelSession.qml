import QtQuick

// Popup state machine, independent of layer-shell. The compositor supplies
// activeToplevel, focusedWorkspace and activeToplevelChanged. A toplevel exposes
// workspace and wayland.activate(). Tests supply a deterministic compositor.
QtObject {
    id: session
    required property var compositor
    property Item activePanel: null
    property bool opened: false
    property var lastApplication: null
    Component.onCompleted: lastApplication = compositor.activeToplevel
    property var returnApplication: null
    property bool restoreOnClose: true

    function show(panel, reset = true) {
        activePanel = panel;
        opened = true;
        if (reset)
            panel.reset();
    }
    function toggle(panel) {
        // A Waybar click can arrive after the same click dismisses the grab.
        if (dismissGuard.running)
            return;
        if (opened && activePanel === panel)
            dismiss();
        else
            show(panel);
    }
    function dismiss(restore = true) {
        restoreOnClose = restore;
        opened = false;
    }
    function dismissOutside() {
        if (opened) {
            dismiss();
            dismissGuard.restart();
        }
    }

    property Connections focusObserver: Connections {
        target: session.compositor
        function onActiveToplevelChanged() {
            if (!session.opened && session.compositor.activeToplevel)
                session.lastApplication = session.compositor.activeToplevel;
        }
    }
    onOpenedChanged: {
        if (opened) {
            restoreFocus.stop();
            returnApplication = compositor.activeToplevel || lastApplication;
            restoreOnClose = true;
        } else if (restoreOnClose) {
            restoreFocus.restart();
        }
    }
    property Timer restoreFocus: Timer {
        // Wait for unmapping and pointer release before restoring app input.
        interval: 80
        onTriggered: {
            const previous = session.returnApplication;
            const current = session.compositor.activeToplevel;
            if (session.opened || !previous || !previous.wayland)
                return;
            // Never override an outside-click app selection or workspace switch.
            if (current && current !== previous)
                return;
            if (previous.workspace !== session.compositor.focusedWorkspace)
                return;
            previous.wayland.activate();
        }
    }
    property Timer dismissGuard: Timer {
        interval: 200
    }
}
