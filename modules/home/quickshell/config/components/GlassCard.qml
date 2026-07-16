import QtQuick
import "../core" as Core

Rectangle {
    id: root

    default property alias content: contentItem.data
    property alias contentItem: contentItem
    property int padding: Core.Tokens.spacingLg
    property color fillColor: Core.Tokens.surface
    property color strokeColor: Core.Tokens.outline

    implicitWidth: Math.max(1, contentItem.childrenRect.width + padding * 2)
    implicitHeight: Math.max(1, contentItem.childrenRect.height + padding * 2)
    color: fillColor
    radius: Core.Tokens.radius
    border.width: 1
    border.color: strokeColor
    antialiasing: true

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
