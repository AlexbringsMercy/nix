pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    id: host

    panelName: "wifi"
    panelWidth: 410
    panelHeight: 620
    rightMargin: 318
    onOpened: {
        Services.NetworkService.beginScan();
        Services.NetworkService.refreshAddress();
    }
    onClosed: Services.NetworkService.endScan()

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
                    icon: "󰤪"
                    title: "Wi-Fi"
                    subtitle: Services.NetworkService.connectedNetwork
                        ? Services.NetworkService.connectedNetwork.name
                        : (Services.NetworkService.enabled ? "Not connected" : "Off")
                    onCloseClicked: Core.PanelCoordinator.close()
                }

                Components.GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Services.NetworkService.connectedNetwork ? 76 : 58
                    padding: Core.Tokens.spacing

                    RowLayout {
                        anchors.fill: parent
                        spacing: Core.Tokens.spacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: Services.NetworkService.connectedNetwork
                                    ? Services.NetworkService.connectedNetwork.name
                                    : "Wireless network"
                                color: Core.Tokens.text
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: {
                                    if (!Services.NetworkService.available)
                                        return "No Wi-Fi adapter found";
                                    if (!Services.NetworkService.hardwareEnabled)
                                        return "Disabled by hardware";
                                    if (Services.NetworkService.connectedNetwork) {
                                        const details = Services.NetworkService.signalPercent(Services.NetworkService.connectedNetwork) + "% signal";
                                        return Services.NetworkService.ipv4Address !== ""
                                            ? details + " · " + Services.NetworkService.ipv4Address
                                            : details;
                                    }
                                    return Services.NetworkService.enabled ? "Choose a network below" : "Turn Wi-Fi on to connect";
                                }
                                color: Core.Tokens.textMuted
                                elide: Text.ElideRight
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 10
                            }
                        }

                        Components.ToggleSwitch {
                            checked: Services.NetworkService.enabled
                            enabled: Services.NetworkService.available && Services.NetworkService.hardwareEnabled
                            accessibleName: "Wi-Fi"
                            onToggled: value => Services.NetworkService.setEnabled(value)
                        }
                    }
                }

                Rectangle {
                    visible: Services.NetworkService.errorMessage !== ""
                    Layout.fillWidth: true
                    Layout.preferredHeight: errorText.implicitHeight + Core.Tokens.spacing * 2
                    radius: Core.Tokens.radiusSmall
                    color: Qt.rgba(Core.Tokens.error.r, Core.Tokens.error.g, Core.Tokens.error.b, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(Core.Tokens.error.r, Core.Tokens.error.g, Core.Tokens.error.b, 0.45)

                    Text {
                        id: errorText
                        anchors.fill: parent
                        anchors.margins: Core.Tokens.spacing
                        text: Services.NetworkService.errorMessage
                        color: Core.Tokens.error
                        wrapMode: Text.Wrap
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 11
                    }
                }

                RowLayout {
                    visible: Services.NetworkService.enabled && Services.NetworkService.available
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: Services.NetworkService.scanning ? "Scanning…" : "Available networks"
                        color: Core.Tokens.textMuted
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Components.ActionButton {
                        text: Services.NetworkService.scanning ? "Stop" : "Scan"
                        icon: "⟳"
                        onClicked: Services.NetworkService.scanning
                            ? Services.NetworkService.endScan()
                            : Services.NetworkService.beginScan()
                    }
                }

                ListView {
                    id: networkList
                    visible: Services.NetworkService.enabled && Services.NetworkService.networks.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Core.Tokens.spacingSm
                    model: Services.NetworkService.networks
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: NetworkRow {
                        required property var modelData
                        width: ListView.view.width
                        network: modelData
                    }

                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
                    }
                }

                Components.EmptyState {
                    visible: !Services.NetworkService.available
                        || !Services.NetworkService.enabled
                        || Services.NetworkService.networks.length === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰤪"
                    title: !Services.NetworkService.available
                        ? "Wi-Fi unavailable"
                        : (!Services.NetworkService.enabled ? "Wi-Fi is off" : "No networks found")
                    detail: !Services.NetworkService.enabled
                        ? "Use the switch above to turn it on."
                        : "Move closer to an access point or scan again."
                }

                Components.ActionButton {
                    Layout.fillWidth: true
                    text: "Advanced network settings"
                    onClicked: Services.NetworkService.openAdvanced()
                }
            }
        }
    }
}
