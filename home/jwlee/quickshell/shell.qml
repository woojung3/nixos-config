import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    IpcHandler {
        target: "brightness"
        function toggle(): void {
            popup.toggle(brightness);
        }
    }
    IpcHandler {
        target: "power"
        function toggle(): void {
            popup.toggle(power);
        }
    }
    IpcHandler {
        target: "calendar"
        function toggle(): void {
            popup.toggle(calendar);
        }
    }
    IpcHandler {
        target: "battery"
        function toggle(): void {
            popup.toggle(battery);
        }
    }
    IpcHandler {
        target: "sound"
        function toggle(): void {
            popup.toggle(sound);
        }
    }

    PanelHost {
        id: popup
        BrightnessPanel {
            id: brightness
            anchors.fill: parent
            visible: popup.activePanel === brightness
        }
        PowerPanel {
            id: power
            anchors.fill: parent
            visible: popup.activePanel === power
            // Session actions manage focus themselves. Preserve error state on
            // failure rather than calling reset() when reopening the panel.
            onCloseRequested: popup.dismiss(false)
            onFailed: popup.show(power, false)
        }
        CalendarPanel {
            id: calendar
            anchors.fill: parent
            visible: popup.activePanel === calendar
        }
        BatteryPanel {
            id: battery
            anchors.fill: parent
            visible: popup.activePanel === battery
        }
        SoundPanel {
            id: sound
            anchors.fill: parent
            visible: popup.activePanel === sound
        }
    }
}
