// Aurora topbar — Audio island's expanded panel: fast device/volume controls, per
// GRAND_PLAN.md §5.2 ("volume/mute/device/per-app fast controls"). Service bindings
// carried from caelestia-dots/shell modules/bar/popouts/Audio.qml (Quickshell.Services.
// Pipewire via the Audio singleton). The deeper listening surface — large art, EQ,
// presets — is the Media island's expansion (MediaEqPanel.qml), not this one.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    width: 300
    spacing: Tokens.spacing.medium

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            color: Colours.palette.m3primary
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Volume (%1)").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
            font: Tokens.font.title.medium
        }

        IconButton {
            icon: Audio.muted ? "volume_off" : "volume_up"
            type: IconButton.Text
            isToggle: true
            checked: Audio.muted
            onClicked: {
                if (Audio.sink?.ready && Audio.sink?.audio)
                    Audio.sink.audio.muted = !Audio.sink.audio.muted;
            }
        }
    }

    CustomMouseArea {
        Layout.fillWidth: true
        implicitHeight: Tokens.padding.medium * 3

        onWheel: event => {
            if (event.angleDelta.y > 0)
                Audio.incrementVolume();
            else if (event.angleDelta.y < 0)
                Audio.decrementVolume();
        }

        StyledSlider {
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: parent.implicitHeight

            value: Audio.volume
            onInteraction: v => Audio.setVolume(v)
        }
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        text: qsTr("Output device")
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall

        Repeater {
            model: Audio.sinks

            RowLayout {
                id: sinkRow

                required property var modelData

                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                readonly property bool active: Audio.sink?.id === sinkRow.modelData.id

                StateLayer {
                    anchors.fill: parent
                    z: -1
                    disabled: sinkRow.active
                    onClicked: Audio.setAudioSink(sinkRow.modelData)
                }

                MaterialIcon {
                    text: "speaker"
                    color: sinkRow.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    fill: sinkRow.active ? 1 : 0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: sinkRow.modelData.description
                    elide: Text.ElideRight
                    color: sinkRow.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    font: Tokens.font.body.builders.medium.weight(sinkRow.active ? Font.Medium : Font.Normal).build()
                }

                MaterialIcon {
                    visible: sinkRow.active
                    text: "check_circle"
                    color: Colours.palette.m3primary
                }
            }
        }
    }

    RowLayout {
        Layout.topMargin: Tokens.spacing.small
        Layout.fillWidth: true

        MaterialIcon {
            text: "mic"
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Input (%1)").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`)
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }
}
