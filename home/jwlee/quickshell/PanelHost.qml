import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Panels supply implicit dimensions and reset(). This host owns all session
// focus, dismissal and layer-shell behavior; individual panels never grab input.
PanelWindow {
    id: host
    default property alias panels: frame.data
    property Item activePanel: null
    property bool opened: false
    property var lastApplication: Hyprland.activeToplevel
    property var returnApplication: null
    property bool restoreOnClose: true

    function show(panel, reset = true) {
        activePanel = panel;
        opened = true;
        if (reset)
            panel.reset();
    }
    function toggle(panel) {
        // An outside click can also reach Waybar. Ignore the second delivery
        // of the same click rather than reopening a just-dismissed panel.
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

    visible: opened
    implicitWidth: activePanel ? activePanel.implicitWidth : 280
    implicitHeight: activePanel ? activePanel.implicitHeight : 100
    anchors {
        top: true
        right: true
    }
    // Layer margins are relative to Waybar's reserved area, not the screen edge.
    margins {
        top: 10
        right: 14
    }
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    // Exclusive layer focus prevents Hyprland's outside-click grab dismissal.
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            if (!host.opened && Hyprland.activeToplevel)
                host.lastApplication = Hyprland.activeToplevel;
        }
    }
    onOpenedChanged: {
        if (opened) {
            restoreFocus.stop();
            returnApplication = Hyprland.activeToplevel || lastApplication;
            restoreOnClose = true;
        } else if (restoreOnClose) {
            restoreFocus.restart();
        }
    }
    Timer {
        id: restoreFocus
        // Wait for unmapping and pointer release before restoring app input.
        interval: 80
        onTriggered: {
            const previous = host.returnApplication;
            const current = Hyprland.activeToplevel;
            if (host.opened || !previous || !previous.wayland)
                return;
            // Never override an outside-click app selection or workspace switch.
            if (current && current !== previous)
                return;
            if (previous.workspace !== Hyprland.focusedWorkspace)
                return;
            previous.wayland.activate();
        }
    }
    Timer {
        id: dismissGuard
        interval: 200
    }
    HyprlandFocusGrab {
        windows: [host]
        active: host.opened
        onCleared: {
            if (host.opened) {
                host.dismiss();
                dismissGuard.restart();
            }
        }
    }
    Rectangle {
        id: frame
        anchors.fill: parent
        radius: 10
        color: Theme.background
        border.color: Theme.surface
        Keys.onEscapePressed: host.dismiss()
    }
}
