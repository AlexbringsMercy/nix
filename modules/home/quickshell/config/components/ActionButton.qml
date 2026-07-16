import QtQuick
import "../core" as Core

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property string accessibleName: text
    property color accent: Core.Tokens.primary
    property bool emphasized: false
    property bool compact: false

    signal clicked()

    implicitWidth: Math.max(compact ? 36 : 76, row.implicitWidth + Core.Tokens.spacingLg * 2)
    implicitHeight: compact ? 36 : 40
    radius: Core.Tokens.radiusSmall
    color: emphasized ? accent : (pointer.containsMouse ? Core.Tokens.surfaceHover : Core.Tokens.surface)
    border.width: emphasized ? 0 : 1
    border.color: pointer.containsMouse ? Core.Tokens.outlineStrong : Core.Tokens.outline
    opacity: enabled ? 1 : 0.45
    scale: pointer.pressed ? 0.97 : 1
    focus: false
    activeFocusOnTab: enabled

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName

    Behavior on color {
        ColorAnimation { duration: Core.Motion.fast }
    }
    Behavior on scale {
        NumberAnimation { duration: Core.Motion.fast; easing.type: Core.Motion.easeOut }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.text !== "" && root.icon !== "" ? Core.Tokens.spacingSm : 0

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.emphasized ? Core.Tokens.onAccent : Core.Tokens.text
            font.family: Core.Tokens.iconFont
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: root.text !== ""
            text: root.text
            color: root.emphasized ? Core.Tokens.onAccent : Core.Tokens.text
            font.family: Core.Tokens.uiFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        visible: root.activeFocus
        anchors.fill: parent
        anchors.margins: -2
        color: "transparent"
        radius: root.radius + 2
        border.width: 2
        border.color: root.accent
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Keys.onSpacePressed: {
        if (enabled)
            clicked();
    }
    Keys.onReturnPressed: {
        if (enabled)
            clicked();
    }
}
