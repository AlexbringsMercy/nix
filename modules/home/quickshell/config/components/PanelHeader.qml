import QtQuick
import QtQuick.Layouts
import "../core" as Core

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool showClose: true
    signal closeClicked()

    implicitHeight: 48

    RowLayout {
        anchors.fill: parent
        spacing: Core.Tokens.spacing

        Rectangle {
            visible: root.icon !== ""
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Core.Tokens.radiusSmall
            color: Qt.alpha(Core.Tokens.primary, 0.14)

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: Core.Tokens.primary
                font.family: Core.Tokens.iconFont
                font.pixelSize: 17
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Core.Tokens.text
                elide: Text.ElideRight
                font.family: Core.Tokens.uiFont
                font.pixelSize: 17
                font.weight: Font.DemiBold
            }

            Text {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                color: Core.Tokens.textMuted
                elide: Text.ElideRight
                font.family: Core.Tokens.uiFont
                font.pixelSize: 11
            }
        }

        ActionButton {
            visible: root.showClose
            compact: true
            icon: "×"
            accessibleName: "Close panel"
            onClicked: root.closeClicked()
        }
    }
}
