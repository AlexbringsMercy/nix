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

    required property var entry
    property bool toast: false
    readonly property string resolvedIcon: entry.image !== ""
        ? entry.image
        : (entry.appIcon !== "" ? Quickshell.iconPath(entry.appIcon, true) : "")

    signal dismissed()

    implicitHeight: content.implicitHeight + Core.Tokens.spacingLg * 2
    radius: Core.Tokens.radius
    color: pointer.containsMouse ? Core.Tokens.surfaceHover : Core.Tokens.surface
    border.width: 1
    border.color: entry.critical ? Core.Tokens.error : (entry.unread ? Core.Tokens.outlineStrong : Core.Tokens.outline)
    antialiasing: true

    Behavior on color { ColorAnimation { duration: Core.Motion.fast } }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Core.Tokens.spacingLg
        }
        spacing: Core.Tokens.spacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Core.Tokens.spacing

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: Core.Tokens.radiusSmall
                color: root.entry.critical
                    ? Qt.rgba(Core.Tokens.error.r, Core.Tokens.error.g, Core.Tokens.error.b, 0.14)
                    : Qt.rgba(Core.Tokens.primary.r, Core.Tokens.primary.g, Core.Tokens.primary.b, 0.14)

                Text {
                    visible: root.resolvedIcon === ""
                    anchors.centerIn: parent
                    text: root.entry.appName.charAt(0).toUpperCase()
                    color: root.entry.critical ? Core.Tokens.error : Core.Tokens.primary
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                IconImage {
                    visible: root.resolvedIcon !== ""
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    source: root.resolvedIcon
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.entry.appName
                    color: Core.Tokens.textMuted
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                Text {
                    Layout.fillWidth: true
                    text: root.entry.summary
                    color: Core.Tokens.text
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    font.family: Core.Tokens.uiFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
            }

            Text {
                // Touch the clock binding so relative time refreshes each minute.
                text: {
                    clock.date;
                    return Services.NotificationService.relativeTime(root.entry.timestamp);
                }
                color: Core.Tokens.textDim
                font.family: Core.Tokens.monoFont
                font.pixelSize: 10
            }

            Components.ActionButton {
                compact: true
                icon: "×"
                accessibleName: "Dismiss " + root.entry.summary
                onClicked: root.dismissed()
            }
        }

        Text {
            visible: root.entry.body !== ""
            Layout.fillWidth: true
            text: root.entry.body
            color: Core.Tokens.textMuted
            wrapMode: Text.Wrap
            maximumLineCount: root.toast ? 3 : 5
            elide: Text.ElideRight
            textFormat: Text.PlainText
            font.family: Core.Tokens.uiFont
            font.pixelSize: 12
            lineHeight: 1.12
        }

        Flow {
            visible: root.entry.live && root.entry.actions.length > 0
            Layout.fillWidth: true
            spacing: Core.Tokens.spacingSm

            Repeater {
                model: root.entry.actions

                Components.ActionButton {
                    required property var modelData
                    required property int index
                    text: modelData.text || "Open"
                    emphasized: index === 0
                    onClicked: Services.NotificationService.invokeAction(root.entry.id, modelData.identifier)
                }
            }
        }

        Rectangle {
            visible: root.entry.live && root.entry.hasInlineReply && !root.toast
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            radius: Core.Tokens.radiusSmall
            color: Core.Tokens.panelRaised
            border.width: replyInput.activeFocus ? 1 : 0
            border.color: Core.Tokens.primary

            TextInput {
                id: replyInput
                anchors {
                    left: parent.left
                    right: sendReply.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: Core.Tokens.spacing
                    rightMargin: Core.Tokens.spacingSm
                }
                color: Core.Tokens.text
                selectionColor: Core.Tokens.primary
                selectedTextColor: Core.Tokens.onAccent
                clip: true
                font.family: Core.Tokens.uiFont
                font.pixelSize: 12

                Text {
                    visible: replyInput.text === "" && !replyInput.activeFocus
                    text: root.entry.inlineReplyPlaceholder || "Reply…"
                    color: Core.Tokens.textDim
                    font: replyInput.font
                }

                Keys.onReturnPressed: {
                    Services.NotificationService.sendInlineReply(root.entry.id, replyInput.text);
                    replyInput.text = "";
                }
            }

            Components.ActionButton {
                id: sendReply
                anchors.right: parent.right
                anchors.rightMargin: 3
                anchors.verticalCenter: parent.verticalCenter
                compact: true
                icon: "↵"
                emphasized: true
                enabled: replyInput.text.trim() !== ""
                accessibleName: "Send reply"
                onClicked: {
                    Services.NotificationService.sendInlineReply(root.entry.id, replyInput.text);
                    replyInput.text = "";
                }
            }
        }
    }
}
