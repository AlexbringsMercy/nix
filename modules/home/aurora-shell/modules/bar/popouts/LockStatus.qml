// Vendored from caelestia-dots/shell — modules/bar/popouts/LockStatus.qml. Aurora build; local changes tracked in git.
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    spacing: Tokens.spacing.small

    StyledText {
        text: qsTr("Capslock: %1").arg(Hypr.capsLock ? "Enabled" : "Disabled")
    }

    StyledText {
        text: qsTr("Numlock: %1").arg(Hypr.numLock ? "Enabled" : "Disabled")
    }
}
