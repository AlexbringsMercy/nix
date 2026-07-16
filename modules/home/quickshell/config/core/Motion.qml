pragma Singleton

import QtQuick

QtObject {
    property bool reducedMotion: false

    readonly property int instant: reducedMotion ? 0 : 80
    readonly property int fast: reducedMotion ? 0 : 130
    readonly property int standard: reducedMotion ? 0 : 210
    readonly property int deliberate: reducedMotion ? 0 : 360
    readonly property int staged: reducedMotion ? 0 : 760

    readonly property int easeOut: Easing.OutCubic
    readonly property int easeExpressive: Easing.OutQuint
    readonly property int easeIn: Easing.InCubic
}
