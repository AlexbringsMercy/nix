// Aurora topbar — media/now-playing island. Structure and behaviour (art thumbnail,
// title/elapsed, prev/play/next, click-to-expand) are ilyamiro's TopBar.qml mediaBox
// nearly 1:1; data comes from caelestia's Players (MPRIS) service instead of his
// music_info.sh polling. Clicking the info side expands the Music/EQ surface
// (panels/MediaEqPanel.qml) beneath this same anchor, per GRAND_PLAN.md §5.9. The whole
// island hides itself when nothing is playing, exactly like the ilyamiro donor.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property var expansion

    readonly property var player: Players.active
    readonly property bool hasPlayer: !!player

    visible: hasPlayer
    clickable: false

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Item {
        id: infoWrapper

        implicitWidth: infoLayout.implicitWidth
        implicitHeight: infoLayout.implicitHeight

        RowLayout {
            id: infoLayout

            anchors.fill: parent
            spacing: Tokens.spacing.small

            StyledClippingRect {
                implicitWidth: 28
                implicitHeight: 28
                radius: Tokens.rounding.medium
                color: Colours.tPalette.m3surfaceContainerHigh
                border.width: root.hasPlayer && root.player.isPlaying ? 1 : 0
                border.color: Colours.palette.m3primary

                Image {
                    anchors.fill: parent
                    source: root.hasPlayer ? (Players.getArtUrl(root.player) || root.player.trackArtUrl || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                spacing: -2

                StyledText {
                    Layout.maximumWidth: 140
                    text: root.hasPlayer ? root.player.trackTitle : ""
                    elide: Text.ElideRight
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                }

                StyledText {
                    Layout.maximumWidth: 140
                    text: root.hasPlayer ? root.player.trackArtist : ""
                    elide: Text.ElideRight
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }
        }

        StateLayer {
            radius: Tokens.rounding.medium
            onClicked: root.expansion.toggle("media", root, null)
        }
    }

    RowLayout {
        spacing: 0

        IconButton {
            icon: "skip_previous"
            type: IconButton.Text
            disabled: !root.hasPlayer || !root.player.canGoPrevious
            onClicked: root.player.previous()
        }

        IconButton {
            icon: root.hasPlayer && root.player.isPlaying ? "pause" : "play_arrow"
            type: IconButton.Text
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
}
