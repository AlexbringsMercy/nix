pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    id: host

    panelName: "power"
    panelWidth: 410
    panelHeight: 700
    rightMargin: 205
    onOpened: Services.PowerService.refreshBrightness()

    function durationText(seconds: real): string {
        if (seconds <= 0)
            return "Calculating…";
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        return hours > 0 ? hours + "h " + minutes + "m" : minutes + "m";
    }

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
                    icon: Services.PowerService.charging ? "󰂄" : "󰁹"
                    title: "System & power"
                    subtitle: Services.PowerService.batteryReady
                        ? Services.PowerService.batteryPercent + "% battery"
                        : "Battery status unavailable"
                    onCloseClicked: Core.PanelCoordinator.close()
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 116
                    radius: Core.Tokens.radius
                    border.width: 1
                    border.color: Core.Tokens.outlineStrong
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.rgba(Core.Tokens.secondary.r, Core.Tokens.secondary.g, Core.Tokens.secondary.b, 0.17) }
                        GradientStop { position: 1; color: Core.Tokens.surface }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Core.Tokens.spacingLg
                        spacing: Core.Tokens.spacingSm

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: Services.PowerService.batteryReady
                                        ? Services.PowerService.batteryPercent + "%"
                                        : "--"
                                    color: Core.Tokens.text
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 25
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: {
                                        if (!Services.PowerService.batteryReady)
                                            return "No battery data";
                                        if (Services.PowerService.charging)
                                            return host.durationText(Services.PowerService.battery.timeToFull) + " until full";
                                        if (Services.PowerService.onBattery)
                                            return host.durationText(Services.PowerService.battery.timeToEmpty) + " remaining";
                                        return "Fully powered";
                                    }
                                    color: Core.Tokens.textMuted
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 11
                                }
                            }

                            ColumnLayout {
                                spacing: 1

                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: Services.PowerService.profileName(Services.PowerService.activeProfile)
                                    color: Core.Tokens.secondary
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    visible: Services.PowerService.batteryReady && Services.PowerService.battery.healthSupported
                                    Layout.alignment: Qt.AlignRight
                                    text: {
                                        const health = Services.PowerService.battery.healthPercentage;
                                        return Math.round(health <= 1 ? health * 100 : health) + "% health";
                                    }
                                    color: Core.Tokens.textMuted
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 10
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 7
                            radius: height / 2
                            color: Core.Tokens.surfaceHover

                            Rectangle {
                                width: parent.width * Services.PowerService.batteryLevel
                                height: parent.height
                                radius: parent.radius
                                color: Services.PowerService.batteryPercent <= 15
                                    ? Core.Tokens.error
                                    : (Services.PowerService.charging ? Core.Tokens.primary : Core.Tokens.secondary)

                                Behavior on width {
                                    NumberAnimation { duration: Core.Motion.standard; easing.type: Core.Motion.easeOut }
                                }
                            }
                        }
                    }
                }

                Components.GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 84
                    padding: Core.Tokens.spacing

                    Components.SliderRow {
                        anchors.fill: parent
                        icon: "☀"
                        title: "Display brightness"
                        enabled: Services.PowerService.brightnessReady
                        from: 0.02
                        to: 1
                        stepSize: 0.01
                        value: Services.PowerService.brightness
                        valueText: Services.PowerService.brightnessReady
                            ? Math.round(Services.PowerService.brightness * 100) + "%"
                            : "--"
                        onMoved: value => Services.PowerService.setBrightness(value)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Core.Tokens.spacingSm

                    Text {
                        text: "Power mode"
                        color: Core.Tokens.textMuted
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Core.Tokens.spacingSm

                        Components.ActionButton {
                            Layout.fillWidth: true
                            text: "Saver"
                            emphasized: Services.PowerService.activeProfile === PowerProfile.PowerSaver
                            accent: Core.Tokens.secondary
                            onClicked: Services.PowerService.setPowerSaver()
                        }

                        Components.ActionButton {
                            Layout.fillWidth: true
                            text: "Balanced"
                            emphasized: Services.PowerService.activeProfile === PowerProfile.Balanced
                            onClicked: Services.PowerService.setBalanced()
                        }

                        Components.ActionButton {
                            Layout.fillWidth: true
                            text: "Performance"
                            emphasized: Services.PowerService.activeProfile === PowerProfile.Performance
                            enabled: Services.PowerService.hasPerformanceProfile
                            accent: Core.Tokens.tertiary
                            onClicked: Services.PowerService.setPerformance()
                        }
                    }
                }

                Text {
                    visible: Services.PowerService.brightnessError !== ""
                    Layout.fillWidth: true
                    text: Services.PowerService.brightnessError
                    color: Core.Tokens.error
                    wrapMode: Text.Wrap
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 10
                }

                Components.ActionButton {
                    Layout.fillWidth: true
                    icon: "󰸉"
                    text: "Wallpapers & colors"
                    accessibleName: "Open wallpaper and color picker"
                    onClicked: {
                        Core.PanelCoordinator.close();
                        Services.PowerService.openWallpaperPicker();
                    }
                }

                Text {
                    text: "Capture"
                    color: Core.Tokens.textMuted
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Core.Tokens.spacingSm

                    Components.ActionButton {
                        Layout.fillWidth: true
                        icon: "󰩭"
                        text: "Select area"
                        accessibleName: "Select an area to save and copy as a screenshot"
                        onClicked: {
                            Core.PanelCoordinator.close();
                            Services.PowerService.captureRegion();
                        }
                    }

                    Components.ActionButton {
                        Layout.fillWidth: true
                        icon: "󰍹"
                        text: "Full screen"
                        accessibleName: "Save and copy a full screen screenshot"
                        onClicked: {
                            Core.PanelCoordinator.close();
                            Services.PowerService.captureScreen();
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "Session"
                    color: Core.Tokens.textMuted
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Core.Tokens.spacingSm

                    Components.ActionButton {
                        Layout.fillWidth: true
                        icon: "󰌾"
                        text: "Lock"
                        onClicked: {
                            Core.PanelCoordinator.close();
                            Services.PowerService.lock();
                        }
                    }

                    Components.ActionButton {
                        Layout.fillWidth: true
                        icon: "☾"
                        text: "Sleep"
                        onClicked: {
                            Core.PanelCoordinator.close();
                            Services.PowerService.suspend();
                        }
                    }

                    Components.HoldActionButton {
                        Layout.fillWidth: true
                        icon: "⟳"
                        text: "Restart"
                        accent: Core.Tokens.warning
                        onTriggered: Services.PowerService.reboot()
                    }

                    Components.HoldActionButton {
                        Layout.fillWidth: true
                        icon: "⏻"
                        text: "Power off"
                        accent: Core.Tokens.error
                        onTriggered: Services.PowerService.powerOff()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Hold Restart or Power off to confirm."
                    color: Core.Tokens.textDim
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 9
                }
            }
        }
    }
}
