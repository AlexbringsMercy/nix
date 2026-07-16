import QtQuick
import "../core" as Core

Rectangle {
    id: root

    property string text: "Power off"
    property string icon: ""
    property color accent: Core.Tokens.error
    property int holdDuration: 1100
    property real holdProgress: 0
    signal triggered()

    implicitWidth: 96
    implicitHeight: 44
    radius: Core.Tokens.radiusSmall
    color: pointer.containsMouse ? Core.Tokens.surfaceHover : Core.Tokens.surface
    border.width: 1
    border.color: pointer.containsMouse ? accent : Core.Tokens.outline
    clip: true
    opacity: enabled ? 1 : 0.45

    Accessible.role: Accessible.Button
    Accessible.name: text + ", hold to confirm"

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * root.holdProgress
        color: Qt.alpha(root.accent, 0.28)
    }

    Row {
        anchors.centerIn: parent
        spacing: Core.Tokens.spacingSm

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.accent
            font.family: Core.Tokens.iconFont
            font.pixelSize: 15
        }

        Text {
            text: root.text
            color: Core.Tokens.text
            font.family: Core.Tokens.uiFont
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
    }

    NumberAnimation {
        id: holdAnimation
        target: root
        property: "holdProgress"
        from: 0
        to: 1
        duration: root.holdDuration
        easing.type: Easing.Linear
        onFinished: {
            root.triggered();
            resetAnimation.restart();
        }
    }

    NumberAnimation {
        id: resetAnimation
        target: root
        property: "holdProgress"
        to: 0
        duration: Core.Motion.fast
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: holdAnimation.restart()
        onReleased: {
            if (holdAnimation.running) {
                holdAnimation.stop();
                resetAnimation.restart();
            }
        }
        onCanceled: {
            holdAnimation.stop();
            resetAnimation.restart();
        }
    }
}
