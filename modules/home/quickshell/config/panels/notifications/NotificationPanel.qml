pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components" as Components
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    id: host

    panelName: "notifications"
    panelWidth: 420
    panelHeight: 650
    rightMargin: 38
    onOpened: Services.NotificationService.markAllRead()

    panelContent: Component {
        Rectangle {
            radius: Core.Tokens.radiusLarge
            color: Core.Tokens.panel
            border.width: 1
            border.color: Core.Tokens.outline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Core.Tokens.spacingLg
                spacing: Core.Tokens.spacing

                Components.PanelHeader {
                    Layout.fillWidth: true
                    icon: "󰁳"
                    title: "Notifications"
                    subtitle: Services.NotificationService.history.length === 0
                        ? "You're all caught up"
                        : Services.NotificationService.history.length + " recent"
                    onCloseClicked: Core.PanelCoordinator.close()
                }

                Components.GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    padding: Core.Tokens.spacing

                    RowLayout {
                        anchors.fill: parent
                        spacing: Core.Tokens.spacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Do not disturb"
                                color: Core.Tokens.text
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: Services.NotificationService.dndEnabled
                                    ? "Popups are paused; history is still recorded"
                                    : "Notification popups are enabled"
                                color: Core.Tokens.textMuted
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 10
                            }
                        }

                        Components.ToggleSwitch {
                            checked: Services.NotificationService.dndEnabled
                            accessibleName: "Do not disturb"
                            onToggled: value => Services.NotificationService.setDnd(value)
                        }
                    }
                }

                RowLayout {
                    visible: Services.NotificationService.history.length > 0
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Recent"
                        color: Core.Tokens.textMuted
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Components.ActionButton {
                        text: "Clear all"
                        onClicked: Services.NotificationService.clearAll()
                    }
                }

                ListView {
                    id: notificationList
                    visible: Services.NotificationService.history.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Core.Tokens.spacingSm
                    clip: true
                    model: Services.NotificationService.history
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: NotificationCard {
                        required property var modelData
                        width: ListView.view.width
                        entry: modelData
                        onDismissed: Services.NotificationService.dismiss(entry.id, true)
                    }

                    add: Transition {
                        NumberAnimation { properties: "opacity,scale"; from: 0; to: 1; duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
                    }
                }

                Components.EmptyState {
                    visible: Services.NotificationService.history.length === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "✓"
                    title: "No notifications"
                    detail: "New alerts will appear here without getting in your way."
                }
            }
        }
    }
}
