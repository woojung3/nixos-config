import QtQuick
import Quickshell
import Quickshell.Io

FocusScope {
    id: brightness
    implicitWidth: 280
    implicitHeight: 100

    function reset() {
        readBrightness.running = true;
        slider.forceActiveFocus();
    }
    Process {
        id: readBrightness
        command: [Commands.brightness, "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = Number(text.trim());
                if (text.trim() !== "" && Number.isFinite(value))
                    slider.value = value;
            }
        }
    }
    Text {
        x: 18
        y: 18
        text: "Brightness"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 18
        y: 18
        text: Math.round(slider.value) + "%"
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }
    BloomSlider {
        id: slider
        x: 18
        y: 47
        width: parent.width - 36
        height: 32
        from: 5
        value: 50
        Accessible.name: "Brightness"
        // Pointer drags commit on release; keyboard steps commit immediately.
        onMoved: {
            if (!pressed)
                apply();
        }
        onPressedChanged: {
            if (!pressed)
                apply();
        }
        function apply() {
            Quickshell.execDetached([Commands.brightness, "set", String(Math.round(value))]);
        }
    }
}
