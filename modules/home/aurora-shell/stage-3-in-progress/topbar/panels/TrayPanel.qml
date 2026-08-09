// Aurora topbar — tray icon's expanded menu. Per GRAND_PLAN.md §5.2 ("Tray menus: carried
// StackView drill-in, opened from the top tray island"), this reuses caelestia's own
// TrayMenu.qml drill-in component (modules/bar/popouts/TrayMenu.qml) verbatim rather than
// rebuilding menu/submenu plumbing — only the anchor point moves, to the top tray island.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property var handle

    implicitWidth: menu.implicitWidth
    implicitHeight: menu.implicitHeight

    BarPopouts.TrayMenu {
        id: menu

        popouts: state
        trayItem: root.handle
    }

    BarPopouts.PopoutState {
        id: state
    }
}
