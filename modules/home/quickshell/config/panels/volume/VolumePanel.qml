pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    panelName: "volume"
    panelWidth: 390
    panelHeight: 280
    rightMargin: 382

    panelContent: Component {
        Rectangle {
            radius: Core.Tokens.radiusLarge
            color: Core.Tokens.panel
            border.width: 1
            border.color: Core.Tokens.outline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Core.Tokens.spacingLg
                spacing: Core.Tokens.spacing

                Components.PanelHeader {
                    Layout.fillWidth: true
                    icon: Services.AudioService.muted ? "󰝟" : "󰝞"
                    title: "Sound"
                    subtitle: Services.AudioService.description
                    onCloseClicked: Core.PanelCoordinator.close()
                }

                Components.GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 92
                    padding: Core.Tokens.spacing

                    Components.SliderRow {
                        anchors.fill: parent
                        icon: Services.AudioService.muted ? "󰝟" : "󰝞"
                        title: Services.AudioService.muted ? "Muted" : "Output volume"
                        enabled: Services.AudioService.ready
                        from: 0
                        to: 1
                        stepSize: 0.01
                        value: Services.AudioService.volume
                        valueText: Math.round(Services.AudioService.volume * 100) + "%"
                        onMoved: value => Services.AudioService.setVolume(value)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Core.Tokens.spacingSm

                    Components.ActionButton {
                        Layout.fillWidth: true
                        icon: Services.AudioService.muted ? "󰝟" : "󰝞"
                        text: Services.AudioService.muted ? "Unmute" : "Mute"
                        emphasized: Services.AudioService.muted
                        enabled: Services.AudioService.ready
                        onClicked: Services.AudioService.toggleMute()
                    }

                    Components.ActionButton {
                        Layout.fillWidth: true
                        text: "Open mixer"
                        onClicked: Services.AudioService.openMixer()
                    }
                }
            }
        }
    }
}
