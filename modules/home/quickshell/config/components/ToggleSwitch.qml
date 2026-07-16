import QtQuick
import "../core" as Core

Item {
    id: root

    property bool checked: false
    property string accessibleName: "Toggle"
    signal toggled(bool checked)

    implicitWidth: 44
    implicitHeight: 24
    activeFocusOnTab: enabled

    Accessible.role: Accessible.CheckBox
    Accessible.name: accessibleName
    Accessible.checked: checked

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Core.Tokens.secondary : Core.Tokens.surfaceHover
        border.width: root.checked ? 0 : 1
        border.color: Core.Tokens.outlineStrong
        opacity: root.enabled ? 1 : 0.45

        Behavior on color { ColorAnimation { duration: Core.Motion.fast } }

        Rectangle {
            width: 18
            height: 18
            radius: 9
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Core.Tokens.onAccent : Core.Tokens.textMuted

            Behavior on x {
                NumberAnimation { duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
            }
        }
    }

    Rectangle {
        visible: root.activeFocus
        anchors.fill: parent
        anchors.margins: -3
        radius: height / 2
        color: "transparent"
        border.width: 2
        border.color: Core.Tokens.primary
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }

    Keys.onSpacePressed: {
        if (enabled)
            toggled(!checked);
    }
}
