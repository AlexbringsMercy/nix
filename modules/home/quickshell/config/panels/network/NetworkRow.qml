pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Rectangle {
    id: root

    required property var network
    property bool expanded: false

    implicitHeight: body.implicitHeight + Core.Tokens.spacing * 2
    radius: Core.Tokens.radius
    color: pointer.containsMouse || expanded ? Core.Tokens.surfaceHover : Core.Tokens.surface
    border.width: 1
    border.color: network.connected ? Core.Tokens.outlineStrong : Core.Tokens.outline

    Behavior on implicitHeight {
        NumberAnimation { duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
    }
    Behavior on color { ColorAnimation { duration: Core.Motion.fast } }

    Connections {
        target: root.network

        function onConnectedChanged(): void {
            if (root.network.connected) {
                passwordInput.text = "";
                root.expanded = false;
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.network.connected)
                return;
            if (Services.NetworkService.isEnterprise(root.network)) {
                Services.NetworkService.openAdvanced();
            } else if (Services.NetworkService.requiresPassword(root.network)) {
                root.expanded = !root.expanded;
                if (root.expanded)
                    passwordInput.forceActiveFocus();
            } else {
                Services.NetworkService.connectNetwork(root.network, "");
            }
        }
    }

    ColumnLayout {
        id: body
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Core.Tokens.spacing
        }
        spacing: Core.Tokens.spacingSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Core.Tokens.spacing

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: Core.Tokens.radiusSmall
                color: root.network.connected
                    ? Qt.rgba(Core.Tokens.secondary.r, Core.Tokens.secondary.g, Core.Tokens.secondary.b, 0.17)
                    : Core.Tokens.panelRaised

                Text {
                    anchors.centerIn: parent
                    text: {
                        const strength = Services.NetworkService.signalPercent(root.network);
                        if (strength >= 75)
                            return "▁▃▅▇";
                        if (strength >= 45)
                            return "▁▃▅";
                        if (strength >= 20)
                            return "▁▃";
                        return "▁";
                    }
                    color: root.network.connected ? Core.Tokens.secondary : Core.Tokens.textMuted
                    font.family: Core.Tokens.monoFont
                    font.pixelSize: 13
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Core.Tokens.spacingSm

                    Text {
                        Layout.fillWidth: true
                        text: root.network.name
                        color: Core.Tokens.text
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        visible: Services.NetworkService.requiresPassword(root.network)
                        text: "󰌪"
                        color: Core.Tokens.textDim
                        font.family: Core.Tokens.iconFont
                        font.pixelSize: 12
                    }
                }

                Text {
                    text: {
                        if (root.network.connected)
                            return "Connected · " + Services.NetworkService.signalPercent(root.network) + "%";
                        if (root.network.stateChanging)
                            return "Connecting…";
                        if (Services.NetworkService.isEnterprise(root.network))
                            return "Enterprise · open advanced settings";
                        if (root.network.known)
                            return "Saved · " + Services.NetworkService.signalPercent(root.network) + "%";
                        return Services.NetworkService.signalPercent(root.network) + "% signal";
                    }
                    color: root.network.connected ? Core.Tokens.secondary : Core.Tokens.textMuted
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 10
                }
            }

            Components.ActionButton {
                visible: root.network.connected
                text: "Disconnect"
                onClicked: Services.NetworkService.disconnect(root.network)
            }

            Components.ActionButton {
                visible: !root.network.connected && root.network.known && !root.network.stateChanging
                text: "Connect"
                emphasized: true
                onClicked: Services.NetworkService.connectNetwork(root.network, "")
            }

            Text {
                visible: root.network.stateChanging
                text: "◌"
                color: Core.Tokens.primary
                font.pixelSize: 20

                RotationAnimation on rotation {
                    running: root.network.stateChanging
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 900
                }
            }
        }

        RowLayout {
            visible: root.expanded
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 42 : 0
            spacing: Core.Tokens.spacingSm

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Core.Tokens.radiusSmall
                color: Core.Tokens.panelRaised
                border.width: passwordInput.activeFocus ? 1 : 0
                border.color: Core.Tokens.primary

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: Core.Tokens.spacing
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    color: Core.Tokens.text
                    selectionColor: Core.Tokens.primary
                    selectedTextColor: Core.Tokens.onAccent
                    clip: true
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 12

                    Text {
                        visible: passwordInput.text === "" && !passwordInput.activeFocus
                        text: "Network password"
                        color: Core.Tokens.textDim
                        font: passwordInput.font
                    }

                    Keys.onReturnPressed: connectButton.clicked()
                }
            }

            Components.ActionButton {
                id: connectButton
                text: "Connect"
                emphasized: true
                enabled: passwordInput.text.length >= 8
                onClicked: {
                    if (Services.NetworkService.connectNetwork(root.network, passwordInput.text))
                        passwordInput.text = "";
                }
            }
        }
    }
}
