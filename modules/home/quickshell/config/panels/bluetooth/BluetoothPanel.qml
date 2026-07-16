pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    id: host

    panelName: "bluetooth"
    panelWidth: 410
    panelHeight: 600
    rightMargin: 270
    onOpened: {
        if (Services.BluetoothService.enabled)
            Services.BluetoothService.startScan();
    }
    onClosed: Services.BluetoothService.stopScan()

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
                    icon: "󰂯"
                    title: "Bluetooth"
                    subtitle: {
                        const connected = Services.BluetoothService.devices.filter(device => device.connected).length;
                        if (!Services.BluetoothService.available)
                            return "Adapter unavailable";
                        if (!Services.BluetoothService.enabled)
                            return "Off";
                        return connected > 0 ? connected + " connected" : "Ready to connect";
                    }
                    onCloseClicked: Core.PanelCoordinator.close()
                }

                Components.GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    padding: Core.Tokens.spacing

                    RowLayout {
                        anchors.fill: parent
                        spacing: Core.Tokens.spacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: Services.BluetoothService.adapter
                                    ? (Services.BluetoothService.adapter.name || "Bluetooth adapter")
                                    : "Bluetooth adapter"
                                color: Core.Tokens.text
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: Services.BluetoothService.scanning
                                    ? "Looking for nearby devices…"
                                    : (Services.BluetoothService.enabled ? "Discoverable devices appear below" : "Turn on to connect accessories")
                                color: Core.Tokens.textMuted
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 10
                            }
                        }

                        Components.ToggleSwitch {
                            checked: Services.BluetoothService.enabled
                            enabled: Services.BluetoothService.available
                            accessibleName: "Bluetooth"
                            onToggled: value => {
                                Services.BluetoothService.setEnabled(value);
                                if (value)
                                    Services.BluetoothService.startScan();
                            }
                        }
                    }
                }

                RowLayout {
                    visible: Services.BluetoothService.enabled
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: Services.BluetoothService.scanning ? "Scanning…" : "Devices"
                        color: Core.Tokens.textMuted
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Components.ActionButton {
                        text: Services.BluetoothService.scanning ? "Stop" : "Scan"
                        icon: "⟳"
                        onClicked: Services.BluetoothService.toggleScan()
                    }
                }

                ListView {
                    id: deviceList
                    visible: Services.BluetoothService.enabled && Services.BluetoothService.devices.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Core.Tokens.spacingSm
                    model: Services.BluetoothService.devices
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: BluetoothDeviceRow {
                        required property var modelData
                        width: ListView.view.width
                        device: modelData
                    }

                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
                    }
                }

                Components.EmptyState {
                    visible: !Services.BluetoothService.available
                        || !Services.BluetoothService.enabled
                        || Services.BluetoothService.devices.length === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰂯"
                    title: !Services.BluetoothService.available
                        ? "Bluetooth unavailable"
                        : (!Services.BluetoothService.enabled ? "Bluetooth is off" : "No devices found")
                    detail: !Services.BluetoothService.enabled
                        ? "Use the switch above to turn it on."
                        : "Put your accessory in pairing mode, then scan again."
                }

                Components.ActionButton {
                    Layout.fillWidth: true
                    text: "Advanced Bluetooth settings"
                    onClicked: Services.BluetoothService.openAdvanced()
                }
            }
        }
    }
}
