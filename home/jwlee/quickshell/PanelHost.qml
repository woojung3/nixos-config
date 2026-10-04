import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Panels supply implicit dimensions and reset(). Session state is separate from
// this Hyprland/layer-shell adapter so it can be regression-tested offscreen.
PanelWindow {
    id: host
    default property alias panels: frame.data
    property alias activePanel: session.activePanel
    property alias opened: session.opened

    function show(panel, reset = true) {
        session.show(panel, reset);
    }
    function toggle(panel) {
        session.toggle(panel);
    }
    function dismiss(restore = true) {
        session.dismiss(restore);
    }

    PanelSession {
        id: session
        compositor: Hyprland
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

    HyprlandFocusGrab {
        windows: [host]
        active: host.opened
        onCleared: session.dismissOutside()
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
