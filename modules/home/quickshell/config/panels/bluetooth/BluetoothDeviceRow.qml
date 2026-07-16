pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Rectangle {
    id: root

    required property var device
    readonly property string resolvedIcon: Quickshell.iconPath(device.icon || "bluetooth", true)

    implicitHeight: 64
    radius: Core.Tokens.radius
    color: pointer.containsMouse ? Core.Tokens.surfaceHover : Core.Tokens.surface
    border.width: 1
    border.color: device.connected ? Core.Tokens.outlineStrong : Core.Tokens.outline

    Behavior on color { ColorAnimation { duration: Core.Motion.fast } }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.BluetoothService.toggleConnection(root.device)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Core.Tokens.spacing
        spacing: Core.Tokens.spacing

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: Core.Tokens.radiusSmall
            color: root.device.connected
                ? Qt.rgba(Core.Tokens.secondary.r, Core.Tokens.secondary.g, Core.Tokens.secondary.b, 0.17)
                : Core.Tokens.panelRaised

            Text {
                visible: root.resolvedIcon === ""
                anchors.centerIn: parent
                text: "B"
                color: root.device.connected ? Core.Tokens.secondary : Core.Tokens.primary
                font.family: Core.Tokens.uiFont
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            IconImage {
                visible: root.resolvedIcon !== ""
                anchors.centerIn: parent
                width: 23
                height: 23
                source: root.resolvedIcon
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: Services.BluetoothService.displayName(root.device)
                color: Core.Tokens.text
                elide: Text.ElideRight
                textFormat: Text.PlainText
                font.family: Core.Tokens.uiFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Text {
                text: {
                    let state = "Available";
                    if (root.device.pairing)
                        state = "Pairing…";
                    else if (root.device.connected)
                        state = "Connected";
                    else if (root.device.paired)
                        state = "Paired";
                    if (root.device.batteryAvailable) {
                        const level = root.device.battery <= 1 ? root.device.battery * 100 : root.device.battery;
                        state += " · " + Math.round(level) + "% battery";
                    }
                    return state;
                }
                color: root.device.connected ? Core.Tokens.secondary : Core.Tokens.textMuted
                font.family: Core.Tokens.uiFont
                font.pixelSize: 10
            }
        }

        Components.ActionButton {
            visible: !root.device.pairing
            text: root.device.connected ? "Disconnect" : (root.device.paired ? "Connect" : "Pair")
            emphasized: !root.device.connected
            onClicked: Services.BluetoothService.toggleConnection(root.device)
        }

        Components.ActionButton {
            visible: root.device.pairing
            text: "Cancel"
            onClicked: Services.BluetoothService.cancelPair(root.device)
        }

        Components.ActionButton {
            visible: root.device.paired && !root.device.connected && !root.device.pairing
            compact: true
            icon: "×"
            accessibleName: "Forget " + Services.BluetoothService.displayName(root.device)
            onClicked: Services.BluetoothService.forget(root.device)
        }
    }
}
