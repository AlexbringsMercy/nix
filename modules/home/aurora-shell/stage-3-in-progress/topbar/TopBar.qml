// Aurora topbar — entry point. Wires one shared Expansion (the morph engine, see
// Expansion.qml) to a persistent IslandBar on every enabled screen. Instantiated once
// from shell.qml, alongside Background/Drawers/etc — a new, independent surface per
// GRAND_PLAN.md §5.1; it does not touch modules/bar/ (the caelestia left rail) at all.
pragma ComponentBehavior: Bound

import Quickshell
import qs.services

Scope {
    id: root

    Expansion {
        id: expansion
    }

    Variants {
        model: Screens.screens

        IslandBar {
            expansion: expansion
        }
    }
}
