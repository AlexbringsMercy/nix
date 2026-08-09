// Aurora topbar — the persistent per-screen bar surface. Independent-island composition
// (left: launcher+bell, workspaces, media; centre: clock/date/weather; right: tray/lang,
// network, bluetooth, audio, battery, resources) is ilyamiro's TopBar.qml nearly 1:1
// (repos/ilyamiro-nixos-configuration config/sessions/hyprland/scripts/quickshell/
// TopBar.qml + previews/screenshot1.png), rebuilt on Aurora's StyledWindow/Tokens/glass
// rather than his raw PanelWindow + hardcoded mocha rectangles. See GRAND_PLAN.md §5.1.
//
// Hard exclusion carried from the plan: no pinned/running/minimized apps and no active-
// window title live here — that is the caelestia left rail's job (modules/bar/), a
// completely separate surface this file never touches or imports.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import "islands" as Islands

StyledWindow {
    id: root

    required property ShellScreen modelData
    required property var expansion

    name: "topbar"
    screen: modelData

    WlrLayershell.namespace: "aurora-topbar"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    anchors.right: true

    readonly property int barHeight: 48
    readonly property int barMargin: Tokens.padding.small

    // A floating bar with a gap from the screen edge (ilyamiro's `margins { top: s(8) }`
    // treatment), not a flush-mounted strip.
    margins {
        top: barMargin
        left: barMargin
        right: barMargin
    }

    implicitHeight: barHeight
    exclusiveZone: barHeight + barMargin

    Item {
        id: content

        anchors.fill: parent

        Row {
            id: leftGroup

            anchors.left: parent.left
            anchors.leftMargin: Tokens.padding.medium
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacing.small

            Islands.LaunchCluster {
                anchors.verticalCenter: parent.verticalCenter
                screen: root.modelData
            }

            Islands.Workspaces {
                anchors.verticalCenter: parent.verticalCenter
                screen: root.modelData
            }

            Islands.MediaChip {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }
        }

        Islands.ClockWeather {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            expansion: root.expansion
        }

        Row {
            id: rightGroup

            anchors.right: parent.right
            anchors.rightMargin: Tokens.padding.medium
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacing.small

            Islands.TrayLang {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }

            Islands.NetworkIsland {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }

            Islands.BluetoothIsland {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }

            Islands.AudioIsland {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }

            Islands.BatteryIsland {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }

            Islands.ResourcesIsland {
                anchors.verticalCenter: parent.verticalCenter
                expansion: root.expansion
            }
        }
    }
}
