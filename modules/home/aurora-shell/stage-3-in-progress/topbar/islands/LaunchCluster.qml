// Aurora topbar — left-most island: launcher trigger + notification bell. Structure is
// ilyamiro's leftContent pill row (search icon first) minus his help/settings/update
// icons, which have no Aurora equivalent on this surface. This is one of the three
// documented launcher triggers (GRAND_PLAN.md §5.5: "Apps button, left-rail Apps entry,
// Cmd+Space") and the bell click path into the carried notification history drawer
// (§5.6: "modules/sidebar/ ... bell click, Super+N, right-edge swipe").
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property ShellScreen screen

    readonly property ScreenState screenState: ShellState.forScreen(root.screen)
    readonly property int unreadCount: Notifs.notClosed.length

    IconButton {
        icon: "search"
        type: IconButton.Text
        onClicked: {
            if (root.screenState)
                root.screenState.launcher = !root.screenState.launcher;
        }
    }

    Item {
        implicitWidth: bellIcon.implicitWidth
        implicitHeight: bellIcon.implicitHeight

        IconButton {
            id: bellIcon

            icon: "notifications"
            type: IconButton.Text
            onClicked: {
                if (root.screenState)
                    root.screenState.sidebar = !root.screenState.sidebar;
            }
        }

        StyledRect {
            visible: root.unreadCount > 0
            anchors.top: bellIcon.top
            anchors.right: bellIcon.right
            implicitWidth: 8
            implicitHeight: 8
            radius: Tokens.rounding.full
            color: Colours.palette.m3primary
        }
    }
}
