import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import "BatteryInfo.js" as BatteryInfo

FocusScope {
    id: battery
    implicitWidth: 280
    implicitHeight: content.implicitHeight + 36
    readonly property var device: UPower.displayDevice
    readonly property bool available: device && device.ready && device.isPresent
    readonly property var modes: PowerProfiles.hasPerformanceProfile ? [
        {
            label: "Power saver",
            value: PowerProfile.PowerSaver,
            name: "power-saver"
        },
        {
            label: "Balanced",
            value: PowerProfile.Balanced,
            name: "balanced"
        },
        {
            label: "Performance",
            value: PowerProfile.Performance,
            name: "performance"
        }
    ] : [
        {
            label: "Power saver",
            value: PowerProfile.PowerSaver,
            name: "power-saver"
        },
        {
            label: "Balanced",
            value: PowerProfile.Balanced,
            name: "balanced"
        }
    ]
    property string errorMessage: ""
    readonly property string profileNotice: {
        if (errorMessage)
            return errorMessage;
        if (PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature)
            return "Performance limited by temperature.";
        if (PowerProfiles.degradationReason === PerformanceDegradationReason.LapDetected)
            return "Performance limited while on your lap.";
        if (PowerProfiles.holds.length > 0)
            return "An application is requesting a power mode.";
        return "";
    }

    function reset() {
        errorMessage = "";
        for (let i = 0; i < modes.length; ++i) {
            if (modes[i].value === PowerProfiles.profile) {
                choices.itemAt(i).forceActiveFocus();
                return;
            }
        }
        forceActiveFocus();
    }
    function selectMode(index) {
        if (setProfile.running || modes[index].value === PowerProfiles.profile)
            return;
        errorMessage = "";
        setProfile.command = [Commands.powerProfiles, "set", modes[index].name];
        setProfile.running = true;
    }
    Process {
        id: setProfile
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                battery.errorMessage = "Could not change power mode. Try again.";
        }
    }

    Column {
        id: content
        x: 18
        y: 18
        width: parent.width - 36
        spacing: 12
        Item {
            width: parent.width
            height: 16
            Text {
                text: "Battery"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
            Text {
                anchors.right: parent.right
                text: battery.available ? BatteryInfo.percentage(battery.device.percentage) : "—"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }
        Text {
            width: parent.width
            text: battery.available ? BatteryInfo.stateLabel(battery.device.state) : battery.device && battery.device.ready ? "No battery detected" : "Battery information unavailable"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
        Rectangle {
            width: parent.width
            height: 5
            radius: 3
            color: Theme.surface
            visible: battery.available
            Rectangle {
                width: parent.width * (battery.available ? Math.max(0, Math.min(1, battery.device.percentage)) : 0)
                height: parent.height
                radius: 3
                color: Theme.accent
                Behavior on width {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
        Text {
            width: parent.width
            visible: battery.available
            text: battery.available ? BatteryInfo.detail(battery.device.state, UPower.onBattery, battery.device.timeToEmpty, battery.device.timeToFull) : ""
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.surface
        }
        Text {
            text: "Power mode"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
        Column {
            width: parent.width
            spacing: 4
            Repeater {
                id: choices
                model: battery.modes
                BloomButton {
                    required property var modelData
                    required property int index
                    width: parent.width
                    text: modelData.label
                    leftAligned: true
                    emphasized: PowerProfiles.profile === modelData.value
                    // Keep keyboard focus while the asynchronous request runs.
                    onClicked: battery.selectMode(index)
                    Keys.onUpPressed: choices.itemAt((index + battery.modes.length - 1) % battery.modes.length).focusFor(Qt.TabFocusReason)
                    Keys.onDownPressed: choices.itemAt((index + 1) % battery.modes.length).focusFor(Qt.TabFocusReason)
                }
            }
        }
        Text {
            width: parent.width
            visible: battery.profileNotice !== ""
            text: battery.profileNotice
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
    }
}
