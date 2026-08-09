// Aurora topbar — tray + keyboard-layout island. Tray icon row/menu behaviour is
// caelestia's own SystemTray + TrayMenu drill-in (carried per GRAND_PLAN.md §5.2),
// re-anchored here instead of the rail; the compact icon-row presentation and the
// language chip follow ilyamiro's TopBar.qml rightContent/sysLayout composition.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property var expansion

    visible: trayRepeater.count > 0 || Hypr.kbLayout !== "??"
    clickable: false

    Row {
        spacing: Tokens.spacing.small
        visible: trayRepeater.count > 0

        Repeater {
            id: trayRepeater

            model: SystemTray.items

            Item {
                id: trayItem

                required property var modelData

                width: 18
                height: 18

                Image {
                    anchors.fill: parent
                    source: trayItem.modelData.icon ?? ""
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(18, 18)
                }

                StateLayer {
                    radius: Tokens.rounding.small
                    onClicked: root.expansion.toggle("tray", trayItem, trayItem.modelData.menu)
                }
            }
        }
    }

    StyledRect {
        visible: trayRepeater.count > 0 && Hypr.kbLayout !== "??"
        implicitWidth: 1
        implicitHeight: 18
        color: Qt.alpha(Colours.palette.m3onSurface, 0.12)
    }

    Item {
        visible: Hypr.kbLayout !== "??"
        implicitWidth: kbRow.implicitWidth
        implicitHeight: kbRow.implicitHeight

        Row {
            id: kbRow

            spacing: Tokens.spacing.extraSmall

            MaterialIcon {
                text: "keyboard"
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                text: Hypr.kbLayout
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }
        }

        StateLayer {
            radius: Tokens.rounding.small
            onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "main", "next"])
        }
    }
}
