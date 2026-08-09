// Aurora topbar — Resources/System island's expanded panel. This island itself is one of
// the "explicit Aurora system additions" GRAND_PLAN.md §5.1 allows alongside ilyamiro's
// islands (CPU/RAM/System were not in the reference bar). The vertical fill-tile
// treatment still follows ilyamiro's own resources composition (repos/ilyamiro-nixos-
// configuration previews/screenshot9.png, quickactions/SystemUsage.qml) for visual
// cohesion with the rest of the bar. Data comes from caelestia's compiled services
// (Cpu/Memory/Storage/NetworkUsage under Caelestia.Services) — see modules/dashboard/
// performance/*.qml for the donor bindings this panel reuses.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.misc
import qs.services

RowLayout {
    id: root

    spacing: Tokens.spacing.small

    ServiceRef {
        service: Cpu
    }

    ServiceRef {
        service: Memory
    }

    ServiceRef {
        service: Storage
    }

    Ref {
        service: NetworkUsage
    }

    Tile {
        icon: "memory"
        label: qsTr("CPU")
        value: `${Math.round(Cpu.percentage * 100)}%`
        fraction: Cpu.percentage
        accent: Colours.palette.m3primary
    }

    Tile {
        icon: "memory_alt"
        label: qsTr("RAM")
        value: {
            const fmt = UsageFmt.formatKib(Memory.used, Memory.total);
            return `${(+fmt.value.toFixed(1))}${fmt.unit}`;
        }
        fraction: Memory.percentage
        accent: Colours.palette.m3tertiary
    }

    Tile {
        icon: "thermometer"
        label: qsTr("TEMP")
        value: `${Math.round(Cpu.temperature)}°`
        fraction: Math.min(1, Cpu.temperature / 100)
        accent: Cpu.temperature > 85 ? Colours.palette.m3error : Colours.palette.m3secondary
    }

    Tile {
        icon: "hard_drive"
        label: qsTr("DISK")
        value: Storage.primaryDisk ? `${Math.round(Storage.primaryDisk.perc * 100)}%` : qsTr("N/A")
        fraction: Storage.primaryDisk?.perc ?? 0
        accent: Colours.palette.m3secondary
    }

    Tile {
        icon: "wifi"
        label: qsTr("NET")
        value: {
            const down = NetworkUsage.formatBytes(NetworkUsage.downloadSpeed ?? 0);
            return down ? `${down.value.toFixed(0)}${down.unit}/s` : "0 B/s";
        }
        fraction: 0
        showFraction: false
        accent: Colours.palette.m3primary
    }

    component Tile: StyledRect {
        id: tile

        required property string icon
        required property string label
        required property string value
        property real fraction: 0
        property bool showFraction: true
        required property color accent

        Layout.preferredWidth: 76
        Layout.preferredHeight: 96
        radius: Tokens.rounding.large
        color: Colours.tPalette.m3surfaceContainer
        clip: true

        StyledRect {
            visible: tile.showFraction
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * Math.max(0, Math.min(1, tile.fraction))
            color: Qt.alpha(tile.accent, 0.28)

            Behavior on height {
                Anim {}
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.extraSmall

            RowLayout {
                Layout.fillWidth: true

                MaterialIcon {
                    text: tile.icon
                    color: tile.accent
                    fontStyle: Tokens.font.icon.small
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillHeight: true
            }

            StyledText {
                Layout.alignment: Qt.AlignRight
                text: tile.value
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }

            StyledText {
                Layout.alignment: Qt.AlignRight
                text: tile.label
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.body.small.pointSize - 1
            }
        }
    }
}
