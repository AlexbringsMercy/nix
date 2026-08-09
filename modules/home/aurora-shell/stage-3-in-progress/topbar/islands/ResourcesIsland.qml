// Aurora topbar — Resources/System island. One of the explicit Aurora system additions
// GRAND_PLAN.md §5.1 allows alongside the ilyamiro islands ("explicit project-required
// system entries such as CPU/RAM and the System action; they remain independent islands").
// Compact chip shows CPU/RAM at a glance; expands panels/ResourcesPanel.qml (§5.2).
pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

Pill {
    id: root

    required property var expansion

    onClicked: root.expansion.toggle("resources", root, null)

    ServiceRef {
        service: Cpu
    }

    ServiceRef {
        service: Memory
    }

    MaterialIcon {
        text: "memory"
        color: Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        text: `${Math.round(Cpu.percentage * 100)}%`
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }

    StyledRect {
        implicitWidth: 1
        implicitHeight: 16
        color: Qt.alpha(Colours.palette.m3onSurface, 0.12)
    }

    MaterialIcon {
        text: "memory_alt"
        color: Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        text: `${Math.round(Memory.percentage * 100)}%`
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }
}
