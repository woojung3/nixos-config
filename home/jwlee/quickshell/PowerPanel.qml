import QtQuick
import Quickshell.Io

FocusScope {
    id: menu
    signal closeRequested
    signal failed
    property string pendingAction: ""
    property string pendingLabel: ""
    property string errorMessage: ""
    readonly property var actions: [
        {
            label: "Lock",
            action: "lock",
            confirm: false
        },
        {
            label: "Suspend",
            action: "suspend",
            confirm: false
        },
        {
            label: "Log out",
            action: "logout",
            confirm: true
        },
        {
            label: "Restart",
            action: "reboot",
            confirm: true
        },
        {
            label: "Shut down",
            action: "poweroff",
            confirm: true
        }
    ]
    implicitWidth: 280
    implicitHeight: pendingAction ? 176 : errorMessage ? 294 : 262

    function reset(reason = Qt.OtherFocusReason) {
        pendingAction = "";
        errorMessage = "";
        choices.itemAt(0).forceActiveFocus(reason);
    }
    function choose(index, reason = Qt.OtherFocusReason) {
        if (actionProcess.running)
            return;
        const item = actions[index];
        if (item.confirm) {
            pendingLabel = item.label;
            pendingAction = item.action;
            cancelButton.forceActiveFocus(reason);
        } else {
            execute(item.action);
        }
    }
    function execute(action) {
        if (actionProcess.running)
            return;
        menu.closeRequested();
        actionProcess.command = [Commands.power, action];
        actionProcess.running = true;
    }

    Process {
        id: actionProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                menu.reset();
                errorMessage = "Could not complete the action. Try again.";
                menu.failed();
            }
        }
    }

    Text {
        x: 18
        y: 18
        text: menu.pendingAction ? menu.pendingLabel + "?" : "Power"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    Column {
        x: 10
        y: 46
        width: parent.width - 20
        spacing: 4
        visible: !menu.pendingAction
        Repeater {
            id: choices
            model: menu.actions
            BloomButton {
                required property var modelData
                required property int index
                width: parent.width
                text: modelData.label
                leftAligned: true
                enabled: !actionProcess.running
                onClicked: menu.choose(index, focusReason)
                Keys.onUpPressed: choices.itemAt((index + 4) % 5).forceActiveFocus(Qt.TabFocusReason)
                Keys.onDownPressed: choices.itemAt((index + 1) % 5).forceActiveFocus(Qt.TabFocusReason)
            }
        }
        Text {
            visible: menu.errorMessage !== ""
            width: parent.width
            leftPadding: 8
            text: menu.errorMessage
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
    }

    Item {
        anchors.fill: parent
        visible: menu.pendingAction !== ""
        Text {
            x: 18
            y: 48
            width: parent.width - 36
            text: "Unsaved work may be lost."
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
        Row {
            x: 18
            y: 118
            spacing: 8
            BloomButton {
                id: cancelButton
                width: (menu.width - 44) / 2
                text: "Cancel"
                onClicked: menu.reset(focusReason)
                Keys.onRightPressed: confirmButton.forceActiveFocus(Qt.TabFocusReason)
            }
            BloomButton {
                id: confirmButton
                width: (menu.width - 44) / 2
                text: menu.pendingLabel
                emphasized: true
                enabled: !actionProcess.running
                onClicked: menu.execute(menu.pendingAction)
                Keys.onLeftPressed: cancelButton.forceActiveFocus(Qt.TabFocusReason)
            }
        }
    }
}
