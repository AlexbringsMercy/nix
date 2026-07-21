// Vendored from caelestia-dots/shell — components/effects/Colouriser.qml. Aurora build; local changes tracked in git.
import QtQuick
import QtQuick.Effects
import qs.components

MultiEffect {
    property color sourceColor: "black"

    colorization: 1
    brightness: 1 - sourceColor.hslLightness

    Behavior on colorizationColor {
        CAnim {}
    }
}
