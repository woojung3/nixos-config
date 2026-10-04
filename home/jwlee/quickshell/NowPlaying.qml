import QtQuick
import Quickshell.Services.Mpris
import "SoundLogic.js" as SoundLogic

// MPRIS ownership and presentation stay separate from system audio controls.
FocusScope {
    id: media
    readonly property var players: SoundLogic.mediaPlayers(Mpris.players.values)
    property string chosenPlayer: ""
    readonly property var player: SoundLogic.choosePlayer(players, chosenPlayer)
    readonly property bool hasMedia: player !== null
    implicitHeight: content.implicitHeight

    function reset() {
        playerPicker.reset();
    }
    onPlayerChanged: {
        if (!player)
            reset();
    }

    Column {
        id: content
        width: parent.width
        spacing: 12
        Item {
            width: parent.width
            height: 76
            Rectangle {
                width: 76
                height: 76
                radius: 7
                color: Theme.surface
                // The artwork fallback is drawn, so it needs no icon font.
                Rectangle {
                    anchors.centerIn: parent
                    width: 44
                    height: 44
                    radius: 22
                    color: "transparent"
                    border.color: Theme.muted
                    Rectangle {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        radius: 6
                        color: Theme.accent
                    }
                }
                Image {
                    anchors.fill: parent
                    source: media.player ? media.player.trackArtUrl : ""
                    sourceSize.width: 152
                    sourceSize.height: 152
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }
            }
            Column {
                x: 88
                width: parent.width - 88
                spacing: 5
                Text {
                    width: parent.width
                    text: media.player ? media.player.trackTitle || "Unknown title" : ""
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: media.player ? media.player.trackArtist || media.player.trackAlbum : ""
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }
        ChoicePicker {
            id: playerPicker
            width: parent.width
            options: media.players.map(p => ({
                        key: p.dbusName,
                        label: p.identity
                    }))
            selectedKey: media.player ? media.player.dbusName : ""
            label: media.player ? media.player.identity : ""
            expandable: media.players.length > 1
            onChosen: key => media.chosenPlayer = key
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            MediaIconButton {
                width: 40
                symbol: "previous"
                label: "Previous track"
                enabled: media.player && media.player.canControl && media.player.canGoPrevious
                onClicked: media.player.previous()
            }
            MediaIconButton {
                width: 48
                symbol: media.player && media.player.isPlaying ? "pause" : "play"
                label: media.player && media.player.isPlaying ? "Pause" : "Play"
                emphasized: true
                enabled: media.player && media.player.canControl && media.player.canTogglePlaying
                onClicked: media.player.togglePlaying()
            }
            MediaIconButton {
                width: 40
                symbol: "next"
                label: "Next track"
                enabled: media.player && media.player.canControl && media.player.canGoNext
                onClicked: media.player.next()
            }
        }
    }
}
