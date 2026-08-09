// Aurora topbar — shared glass pill base for every bar island. Geometry/independent-
// island idea is ilyamiro's TopBar.qml (each of his leftContent/workspacesBox/mediaBox/
// centerBox/rightContent pills); the glass fill itself is Aurora's own semantic surface
// (GRAND_PLAN.md §3.2 — generated surfaceLowest, not ilyamiro's hardcoded mocha rgba).
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    property bool clickable: true
    property bool hovered: stateLayer.containsMouse

    signal clicked
    signal wheel(angleDelta: point)

    implicitWidth: row.implicitWidth + Tokens.padding.large * 2
    implicitHeight: Math.max(36, row.implicitHeight + Tokens.padding.small * 2)

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3onSurface, 0.06)

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    StateLayer {
        id: stateLayer

        disabled: !root.clickable
        radius: root.radius
        onClicked: root.clicked()

        WheelHandler {
            onWheel: event => root.wheel(Qt.point(event.angleDelta.x, event.angleDelta.y))
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Tokens.spacing.small
    }
}
