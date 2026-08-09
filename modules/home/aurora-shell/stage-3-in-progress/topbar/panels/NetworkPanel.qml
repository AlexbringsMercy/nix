// Aurora topbar — Network island's expanded panel. Data/behaviour carried from
// caelestia-dots/shell modules/bar/popouts/Network.qml (Nmcli service, NetworkConnection
// util); re-anchored beneath the top network island per GRAND_PLAN.md §5.2 instead of the
// rail. Presentation kept in Aurora's card language rather than ilyamiro's own network
// script UI — ilyamiro's network surface is shell-script driven and has no QML to carry.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

ColumnLayout {
    id: root

    property var passwordNetwork: null
    property bool showPasswordField: false
    property string passwordText: ""
    property string connectingToSsid: ""

    width: 320
    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true

        MaterialIcon {
            text: "wifi"
            color: Colours.palette.m3primary
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Wi-Fi")
            font: Tokens.font.title.medium
        }

        StyledSwitch {
            checked: Nmcli.wifiEnabled
            onToggled: Nmcli.enableWifi(checked)
        }
    }

    StyledText {
        text: qsTr("%1 networks available").arg(Nmcli.networks.length)
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
        visible: !root.showPasswordField
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall
        visible: !root.showPasswordField

        Repeater {
            model: ScriptModel {
                values: [...Nmcli.networks].sort((a, b) => (b.active - a.active) || (b.strength - a.strength)).slice(0, 7)
            }

            RowLayout {
                id: netRow

                required property Nmcli.AccessPoint modelData

                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: Icons.getNetworkIcon(netRow.modelData.strength, netRow.modelData.isSecure)
                    color: netRow.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: netRow.modelData.ssid
                    elide: Text.ElideRight
                    color: netRow.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    font: Tokens.font.body.builders.medium.weight(netRow.modelData.active ? Font.Medium : Font.Normal).build()
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: connIcon.implicitHeight + Tokens.padding.extraSmall
                    radius: Tokens.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, netRow.modelData.active ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: root.connectingToSsid === netRow.modelData.ssid
                    }

                    StateLayer {
                        color: netRow.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: !Nmcli.wifiEnabled || root.connectingToSsid === netRow.modelData.ssid
                        onClicked: {
                            if (netRow.modelData.active) {
                                Nmcli.disconnectFromNetwork();
                                return;
                            }
                            root.connectingToSsid = netRow.modelData.ssid;
                            NetworkConnection.handleConnect(netRow.modelData, null, network => {
                                root.passwordNetwork = network;
                                root.showPasswordField = true;
                            });
                        }
                    }

                    MaterialIcon {
                        id: connIcon

                        anchors.centerIn: parent
                        text: netRow.modelData.active ? "link_off" : "link"
                        color: netRow.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        opacity: root.connectingToSsid === netRow.modelData.ssid ? 0 : 1
                    }
                }
            }
        }
    }

    // Inline password entry — a lighter substitute for the rail's detached
    // WirelessPassword drawer (kept self-contained rather than importing the rail).
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small
        visible: root.showPasswordField

        StyledText {
            text: qsTr("Password for %1").arg(root.passwordNetwork?.ssid ?? "")
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
        }

        StyledTextField {
            Layout.fillWidth: true
            echoMode: TextInput.Password
            text: root.passwordText
            onTextChanged: root.passwordText = text
            Keys.onReturnPressed: connectBtn.clicked()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            TextButton {
                text: qsTr("Cancel")
                onClicked: {
                    root.showPasswordField = false;
                    root.passwordText = "";
                    root.connectingToSsid = "";
                }
            }

            Item {
                Layout.fillWidth: true
            }

            IconTextButton {
                id: connectBtn

                text: qsTr("Connect")
                icon: "wifi"
                onClicked: {
                    NetworkConnection.connectWithPassword(root.passwordNetwork, root.passwordText, () => {
                        root.showPasswordField = false;
                        root.passwordText = "";
                        root.connectingToSsid = "";
                    });
                }
            }
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.small
        visible: !root.showPasswordField
        implicitHeight: rescanRow.implicitHeight + Tokens.padding.small

        radius: Tokens.rounding.full
        color: Colours.palette.m3primaryContainer

        StateLayer {
            color: Colours.palette.m3onPrimaryContainer
            disabled: Nmcli.scanning || !Nmcli.wifiEnabled
            onClicked: Nmcli.rescanWifi()
        }

        RowLayout {
            id: rescanRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "wifi_find"
                color: Colours.palette.m3onPrimaryContainer
                animate: true
            }

            StyledText {
                text: Nmcli.scanning ? qsTr("Scanning…") : qsTr("Rescan networks")
                color: Colours.palette.m3onPrimaryContainer
            }
        }
    }

    Connections {
        function onActiveChanged(): void {
            if (Nmcli.active && root.connectingToSsid === Nmcli.active.ssid)
                root.connectingToSsid = "";
        }

        target: Nmcli
    }
}
