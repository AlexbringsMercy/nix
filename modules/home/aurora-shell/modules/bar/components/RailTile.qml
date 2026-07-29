// Aurora-authored — Stage 2 left-rail application slice (GRAND_PLAN.md §5.3).
// Reusable "glass tile" app button shared by AppRail's pinned and task entries.
// Container/hover treatment follows the existing caelestia-dots/shell
// modules/bar/components/Tray.qml glass-container idiom (StyledRect + StateLayer);
// the running/focused indicator dots follow the visual role of
// AvengeMedia/DankMaterialShell quickshell/Modules/Dock/DockAppButton.qml's
// column indicator (adapted, not ported — no drag/reorder/overflow carried over).
// Visual direction (restrained glass container, negative space, no chrome beyond
// a soft rounded surface) follows agridyne-dotfiles-dt/rice-contents.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property string iconSource: ""
    // Aurora: shown when iconSource is empty. AppRail resolves icons with
    // Quickshell.iconPath(name, true), which returns "" for an unknown icon
    // instead of the theme's `image-missing` placeholder — that placeholder is a
    // torn-photo pictogram in Papirus and was being read as a dead
    // "screenshot/image utility" tile in the rail. A themed Material glyph is
    // always legible and always matches the palette.
    property string fallbackGlyph: "web_asset"
    property bool focused: false
    property bool dimmed: false
    property int windowCount: 0

    readonly property alias hovered: stateLayer.containsMouse

    signal clicked

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    opacity: dimmed ? 0.45 : 1

    Behavior on opacity {
        Anim {}
    }

    StyledRect {
        id: tile

        anchors.fill: parent
        radius: Tokens.rounding.large
        color: root.focused ? Colours.tPalette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainerHigh, stateLayer.containsMouse ? 2 : 1)

        StateLayer {
            id: stateLayer

            radius: parent.radius
            onClicked: root.clicked()
        }

        IconImage {
            id: icon

            anchors.centerIn: parent
            asynchronous: true
            visible: root.iconSource.length > 0
            implicitSize: root.implicitWidth * 0.55
            source: root.iconSource
        }

        MaterialIcon {
            anchors.centerIn: parent
            visible: !icon.visible
            text: root.fallbackGlyph
            color: root.focused ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
        }

        Row {
            id: indicators

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Tokens.padding.extraSmall
            spacing: Tokens.spacing.extraSmall / 2
            visible: root.windowCount > 0

            Repeater {
                model: Math.min(root.windowCount, 4)

                Rectangle {
                    width: Tokens.spacing.extraSmall
                    height: Tokens.spacing.extraSmall
                    radius: width / 2
                    color: root.focused ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3primary
                }
            }
        }
    }
}
