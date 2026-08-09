// Aurora topbar — the Music/EQ surface. Composition is ilyamiro's music/MusicPopup.qml
// nearly 1:1 (repos/ilyamiro-nixos-configuration config/sessions/hyprland/scripts/
// quickshell/music/MusicPopup.qml + previews/screenshot4.png, guide/previews/
// preview_music.png): art / track / seek / transport, divider, 10-band EQ with genre
// presets. Backed by caelestia's Players (MPRIS) service for playback and the project's
// validated equalizer-state/EasyEffects backend (../services/Equalizer.qml) for the EQ —
// GRAND_PLAN.md §5.9. EasyEffects itself stays invisible; only its state is read/written.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.topbar.services as TopBarServices

ColumnLayout {
    id: root

    readonly property var player: Players.active
    readonly property bool hasPlayer: !!player
    readonly property real positionRatio: hasPlayer && player.length > 0 ? player.position / player.length : 0

    function lengthStr(length: real): string {
        if (!(length >= 0))
            return "0:00";

        const hours = Math.floor(length / 3600);
        const mins = Math.floor((length % 3600) / 60);
        const secs = Math.floor(length % 60).toString().padStart(2, "0");

        return hours > 0 ? `${hours}:${mins.toString().padStart(2, "0")}:${secs}` : `${mins}:${secs}`;
    }

    width: 340
    spacing: Tokens.spacing.medium

    // MPRIS position isn't pushed reactively; poll while playing so the seek bar
    // actually advances (same pattern as modules/dashboard/media/Details.qml).
    Timer {
        running: root.hasPlayer && root.player.isPlaying
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    // --- Now playing -----------------------------------------------------
    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.medium

        StyledClippingRect {
            implicitWidth: 76
            implicitHeight: 76
            radius: Tokens.rounding.full
            color: Colours.tPalette.m3surfaceContainerHigh
            border.width: root.hasPlayer && root.player.isPlaying ? 2 : 0
            border.color: Colours.palette.m3primary

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: root.hasPlayer ? (Players.getArtUrl(root.player) || root.player.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: !root.hasPlayer
                text: "music_note"
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.large
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            StyledText {
                Layout.fillWidth: true
                text: root.hasPlayer ? (root.player.trackTitle || qsTr("Unknown track")) : qsTr("Nothing playing")
                elide: Text.ElideRight
                font: Tokens.font.title.small
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.hasPlayer && !!root.player.trackArtist
                text: qsTr("by %1").arg(root.hasPlayer ? root.player.trackArtist : "")
                elide: Text.ElideRight
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.hasPlayer
                text: Players.getIdentity(root.player)
                elide: Text.ElideRight
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall
        visible: root.hasPlayer

        StyledSlider {
            Layout.fillWidth: true
            value: root.positionRatio
            enabled: root.hasPlayer && root.player.canSeek && root.player.positionSupported
            onInteraction: v => {
                if (root.hasPlayer && root.player.canSeek && root.player.positionSupported)
                    root.player.position = v * root.player.length;
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: root.hasPlayer ? root.lengthStr(root.player.position) : "0:00"
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: root.hasPlayer ? root.lengthStr(root.player.length) : "0:00"
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Tokens.spacing.large

        IconButton {
            icon: "skip_previous"
            type: IconButton.Text
            disabled: !root.hasPlayer || !root.player.canGoPrevious
            onClicked: root.player.previous()
        }

        IconButton {
            icon: root.hasPlayer && root.player.isPlaying ? "pause" : "play_arrow"
            type: IconButton.Filled
            disabled: !root.hasPlayer
            onClicked: root.player.togglePlaying()
        }

        IconButton {
            icon: "skip_next"
            type: IconButton.Text
            disabled: !root.hasPlayer || !root.player.canGoNext
            onClicked: root.player.next()
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.extraSmall
        implicitHeight: 1
        color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
    }

    // --- Equalizer ---------------------------------------------------------
    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Equalizer")
            font: Tokens.font.title.small
        }

        StyledText {
            text: TopBarServices.Equalizer.preset
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: Tokens.spacing.small

        Repeater {
            model: 10

            ColumnLayout {
                id: bandCol

                required property int index

                spacing: Tokens.spacing.extraSmall

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 22
                    implicitHeight: 110

                    StyledSlider {
                        anchors.centerIn: parent
                        implicitWidth: 110
                        implicitHeight: 22
                        rotation: -90

                        value: (TopBarServices.Equalizer.bands[bandCol.index] + 12) / 24
                        onInteraction: v => TopBarServices.Equalizer.setBand(bandCol.index, v * 24 - 12)
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: TopBarServices.Equalizer.bandFrequencies[bandCol.index] >= 1000 ? `${TopBarServices.Equalizer.bandFrequencies[bandCol.index] / 1000}k` : TopBarServices.Equalizer.bandFrequencies[bandCol.index]
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.small
        columns: 4
        columnSpacing: Tokens.spacing.small
        rowSpacing: Tokens.spacing.small

        Repeater {
            model: TopBarServices.Equalizer.presets

            StyledRect {
                id: presetBtn

                required property string modelData

                readonly property bool active: TopBarServices.Equalizer.preset === presetBtn.modelData

                Layout.fillWidth: true
                implicitHeight: presetLabel.implicitHeight + Tokens.padding.small
                radius: Tokens.rounding.medium
                color: presetBtn.active ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainer

                StateLayer {
                    color: presetBtn.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    onClicked: TopBarServices.Equalizer.setPreset(presetBtn.modelData)
                }

                StyledText {
                    id: presetLabel

                    anchors.centerIn: parent
                    text: presetBtn.modelData
                    color: presetBtn.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }
        }
    }
}
