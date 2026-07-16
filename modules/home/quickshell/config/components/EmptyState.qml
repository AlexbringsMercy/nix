import QtQuick
import "../core" as Core

Item {
    id: root

    property string icon: "?"
    property string title: "Nothing here"
    property string detail: ""

    implicitHeight: 180

    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width, 280)
        spacing: Core.Tokens.spacingSm

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            color: Core.Tokens.primary
            font.family: Core.Tokens.iconFont
            font.pixelSize: 30
        }

        Text {
            width: parent.width
            text: root.title
            color: Core.Tokens.text
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.family: Core.Tokens.uiFont
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Text {
            visible: root.detail !== ""
            width: parent.width
            text: root.detail
            color: Core.Tokens.textMuted
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.family: Core.Tokens.uiFont
            font.pixelSize: 12
        }
    }
}
