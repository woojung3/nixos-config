import QtQuick
import QtQuick.Controls

Slider {
    id: slider
    property bool muted: false
    readonly property color ink: muted ? Theme.muted : Theme.accent
    implicitHeight: 36
    from: 0
    to: 100
    stepSize: 1
    wheelEnabled: false

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 5
        radius: 3
        color: Theme.surface
        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: slider.ink
        }
    }
    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: 8
        color: slider.ink
        scale: slider.pressed ? 1.15 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 100
            }
        }
    }
}
