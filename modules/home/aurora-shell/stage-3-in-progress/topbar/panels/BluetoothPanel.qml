// Aurora topbar — Bluetooth island's expanded panel. Service bindings carried from
// caelestia-dots/shell modules/bar/popouts/Bluetooth.qml (Quickshell.Bluetooth), re-anchored
// under the top Bluetooth island per GRAND_PLAN.md §5.2. This is the stable list-form
// tier; ilyamiro's radial device-constellation composition (repos/ilyamiro-nixos-
// configuration previews/screenshot5.png, .../network/NetworkPopup.qml) is the "deeper
// panel may open from it" tier the plan calls optional — not built this pass, see the
// Stage 3 progress report.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

ColumnLayout {
    id: root

    width: 300
    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true

        MaterialIcon {
            text: "bluetooth"
            color: Colours.palette.m3primary
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Bluetooth")
            font: Tokens.font.title.medium
        }

        StyledSwitch {
            checked: Bluetooth.defaultAdapter?.enabled ?? false // qmllint disable unresolved-type
            onToggled: {
                const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
                if (adapter)
                    adapter.enabled = checked;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Discoverable / scanning")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }

        StyledSwitch {
            checked: Bluetooth.defaultAdapter?.discovering ?? false // qmllint disable unresolved-type
            onToggled: {
                const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
                if (adapter)
                    adapter.discovering = checked;
            }
        }
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        text: {
            const devices = Bluetooth.devices.values; // qmllint disable unresolved-type
            const connected = devices.filter(d => d.connected).length;
            const base = qsTr("%1 device%2").arg(devices.length).arg(devices.length === 1 ? "" : "s");
            return connected > 0 ? qsTr("%1 (%2 connected)").arg(base).arg(connected) : base;
        }
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall

        Repeater {
            model: ScriptModel {
                values: [...Bluetooth.devices.values] // qmllint disable unresolved-type
                .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)).slice(0, 6)
            }

            RowLayout {
                id: device

                required property BluetoothDevice modelData
                readonly property bool loading: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting // qmllint disable unresolved-type

                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: Icons.getBluetoothIcon(device.modelData.icon)
                    color: device.modelData.connected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: device.modelData.name
                    elide: Text.ElideRight
                    color: device.modelData.connected ? Colours.palette.m3primary : Colours.palette.m3onSurface
                }

                MaterialIcon {
                    visible: device.modelData.connected && device.modelData.batteryAvailable
                    text: Icons.getBatteryIcon(device.modelData.battery)
                    color: device.modelData.battery < 0.2 ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: connIcon.implicitHeight + Tokens.padding.extraSmall
                    radius: Tokens.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, device.modelData.connected ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: device.loading
                    }

                    StateLayer {
                        color: device.modelData.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: device.loading
                        onClicked: device.modelData.connected = !device.modelData.connected
                    }

                    MaterialIcon {
                        id: connIcon

                        anchors.centerIn: parent
                        text: device.modelData.connected ? "link_off" : "link"
                        color: device.modelData.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        opacity: device.loading ? 0 : 1
                    }
                }
            }
        }

        StyledText {
            visible: Bluetooth.devices.values.length === 0 // qmllint disable unresolved-type
            text: qsTr("No devices found yet")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }
}
