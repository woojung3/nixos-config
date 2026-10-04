import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool emphasized: false
    property bool leftAligned: false
    property bool selected: false
    implicitHeight: 36
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 10

    function activateFromKeyboard() {
        if (!enabled)
            return;
        forceActiveFocus(Qt.TabFocusReason);
        clicked();
    }
    Keys.onReturnPressed: activateFromKeyboard()
    Keys.onEnterPressed: activateFromKeyboard()

    contentItem: Text {
        text: control.text
        elide: Text.ElideRight
        color: control.emphasized ? Theme.background : Theme.foreground
        rightPadding: control.selected ? 22 : 0
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
        horizontalAlignment: control.leftAligned ? Text.AlignLeft : Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1 : 0.5
        Canvas {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            visible: control.selected
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = Theme.accent;
                ctx.lineWidth = 1.5;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.beginPath();
                ctx.moveTo(2, 7);
                ctx.lineTo(5, 10);
                ctx.lineTo(12, 3);
                ctx.stroke();
            }
        }
    }
    background: Rectangle {
        radius: 7
        color: control.emphasized ? Theme.accent : control.hovered || control.down ? Theme.surface : "transparent"
        // visualFocus distinguishes keyboard navigation from mouse/programmatic
        // focus. Keeping actual focus must not look like a persistent selection.
        border.width: control.visualFocus ? 1 : 0
        border.color: control.emphasized ? Theme.foreground : Theme.accent
        opacity: control.down ? 0.8 : 1
        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }
}
