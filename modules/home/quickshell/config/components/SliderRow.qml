import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../core" as Core

Item {
    id: root

    property string icon: ""
    property string title: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0.01
    property string valueText: Math.round(value * 100) + "%"
    signal moved(real value)

    implicitHeight: 62

    RowLayout {
        anchors.fill: parent
        spacing: Core.Tokens.spacing

        Text {
            Layout.preferredWidth: 22
            text: root.icon
            color: Core.Tokens.primary
            font.family: Core.Tokens.iconFont
            font.pixelSize: 17
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: Core.Tokens.text
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    text: root.valueText
                    color: Core.Tokens.textMuted
                    font.family: Core.Tokens.monoFont
                    font.pixelSize: 11
                }
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                enabled: root.enabled
                from: root.from
                to: root.to
                stepSize: root.stepSize
                value: root.value
                onMoved: root.moved(value)

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 5
                    width: slider.availableWidth
                    height: implicitHeight
                    radius: height / 2
                    color: Core.Tokens.surfaceHover

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        color: Core.Tokens.secondary
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: slider.pressed ? Core.Tokens.primary : Core.Tokens.text
                    border.width: 2
                    border.color: Core.Tokens.secondary
                }
            }
        }
    }
}
