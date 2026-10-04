import QtQuick
import Quickshell.Services.Pipewire
import "SoundLogic.js" as SoundLogic

FocusScope {
    id: sound
    implicitWidth: 320
    implicitHeight: content.implicitHeight + 36
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool audioReady: sink && sink.ready && sink.audio
    readonly property var outputs: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    property string outputError: ""
    property var requestedSink: null

    // Audio properties are only valid while nodes are bound by a tracker.
    PwObjectTracker {
        objects: sound.outputs
    }
    onAudioReadyChanged: {
        if (visible && !audioReady)
            forceActiveFocus();
    }
    function focusVolume() {
        if (audioReady)
            volume.forceActiveFocus();
        else
            forceActiveFocus();
    }
    function reset() {
        outputPicker.reset();
        media.reset();
        outputError = "";
        focusVolume();
    }
    function setVolume(value) {
        if (audioReady)
            sink.audio.volume = SoundLogic.boundedVolume(value);
    }
    function stepVolume(delta) {
        if (audioReady)
            setVolume(Math.round(sink.audio.volume * 100) + delta);
    }
    function toggleMute() {
        if (audioReady)
            sink.audio.muted = !sink.audio.muted;
    }
    function selectOutput(id) {
        requestedSink = outputs.find(n => n.id === id) || null;
        outputError = "";
        if (requestedSink)
            Pipewire.preferredDefaultAudioSink = requestedSink;
        outputCheck.restart();
    }
    Timer {
        id: outputCheck
        interval: 1200
        onTriggered: {
            if (!sound.requestedSink || sound.sink !== sound.requestedSink)
                sound.outputError = "Could not switch output. Try again.";
        }
    }
    Keys.onLeftPressed: stepVolume(-1)
    Keys.onRightPressed: stepVolume(1)

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
                text: "Sound"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
            Text {
                anchors.right: parent.right
                text: sound.audioReady ? Math.round(sound.sink.audio.volume * 100) + "%" : "—"
                color: sound.audioReady && sound.sink.audio.muted ? Theme.muted : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }
        Row {
            width: parent.width
            spacing: 8
            BloomSlider {
                id: volume
                width: parent.width - 44
                height: 36
                value: sound.audioReady ? Math.max(0, Math.min(100, sound.sink.audio.volume * 100)) : 0
                enabled: sound.audioReady
                muted: sound.audioReady && sound.sink.audio.muted
                Accessible.name: "System volume"
                onMoved: sound.setVolume(value)
            }
            MediaIconButton {
                width: 36
                enabled: sound.audioReady
                symbol: sound.audioReady && sound.sink.audio.muted ? "muted" : "volume"
                label: sound.audioReady && sound.sink.audio.muted ? "Unmute" : "Mute"
                emphasized: sound.audioReady && sound.sink.audio.muted
                onClicked: sound.toggleMute()
            }
        }
        ChoicePicker {
            id: outputPicker
            width: parent.width
            options: sound.outputs.map(n => ({
                        key: n.id,
                        label: n.description || n.nickname || n.name
                    }))
            selectedKey: sound.sink ? sound.sink.id : null
            label: sound.sink ? sound.sink.description || sound.sink.nickname || sound.sink.name : "No audio output"
            onChosen: key => sound.selectOutput(key)
        }
        Text {
            width: parent.width
            visible: sound.outputError !== ""
            text: sound.outputError
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.surface
            visible: media.hasMedia
        }
        NowPlaying {
            id: media
            width: parent.width
            visible: hasMedia
            onHasMediaChanged: {
                if (sound.visible && !hasMedia)
                    sound.focusVolume();
            }
        }
    }
}
