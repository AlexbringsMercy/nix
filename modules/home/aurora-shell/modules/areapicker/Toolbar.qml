// Aurora build; no upstream counterpart. Compact "Region / Window / Full
// screen" mode toolbar for modules/areapicker, added per PM directive
// 2026-07-29: a Windows-Snipping-Tool-style visible, clickable mode surface
// centred at the top of the screen whenever screenshot mode is open -- a
// hover-to-discover affordance (clicking a window inside Region mode to
// select it) is not sufficient on its own (MASTER §2, a hotkey/gesture is
// never the only path in).
//
// Declared as a sibling of the screencopy Loader in Picker.qml, exactly like
// the pre-existing overlay/border, so CUtils.saveItem's grab of the
// screencopy subtree structurally excludes it -- the same "excluded by
// construction, not by timing" property that made the original pink-film
// overlay-tint defect (slurp's selection compositing into the frame)
// impossible to reintroduce here. See Picker.qml's onReleased/
// onHasContentChanged for the one place it IS deliberately hidden (the live
// completion flash, cosmetic only) and AreaPicker.qml's captureFullFromToolbar
// for the one path that tears it down instantly rather than fading it (the
// toolbar's own Full screen button, which hands off to grim).
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services

StyledRect {
    id: root

    required property LazyLoader loader
    required property ShellScreen screen

    // Aurora: true only for the instant, unanimated teardown that precedes a
    // toolbar-triggered full-screen grab. Kept as its own property (rather
    // than assigning `visible` directly from Picker.qml) so imperatively
    // toggling it never overwrites -- and thereby destroys -- the binding
    // below.
    property bool hiddenForCapture: false

    // Aurora: rail-filtering identifier, per PM request -- this toolbar is not
    // a separate surface (it lives inside the same caelestia-area-picker
    // layer-shell window as the picker), but it is named for introspection.
    objectName: "areaPickerToolbar"

    // Aurora: one toolbar for the whole multi-monitor picker session (the
    // LazyLoader in AreaPicker.qml maps one Picker per screen), shown only on
    // the currently-focused monitor's instance. Compared by name rather than
    // object identity -- this codebase already does the same for toplevels
    // (AppRail.qml compares .address, not the object) rather than assume two
    // separately-fetched Quickshell wrappers for the same monitor are ===.
    visible: !hiddenForCapture && Hypr.monitorFor(root.screen)?.name === Hypr.focusedMonitor?.name

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: Tokens.padding.large * 2

    radius: Tokens.rounding.full
    color: Colours.palette.m3surfaceContainerHigh
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.5)

    implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    Elevation {
        anchors.fill: parent
        radius: parent.radius
        level: 3
        z: -1
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        // Aurora: Region and Window are a mutually-exclusive toggle over
        // loader.selectMode -- Picker.qml's onPositionChanged reads it to
        // decide whether a press-drag follows the cursor freely (Region) or
        // keeps re-snapping to whatever client is under it (Window). checked
        // is driven entirely from selectMode so exactly one is ever lit,
        // which is the "current mode is visually obvious" requirement.
        IconTextButton {
            type: IconTextButton.Tonal
            isRound: true
            isToggle: true
            checked: root.loader.selectMode === "region"
            icon: "screenshot_region"
            text: qsTr("Region")
            onClicked: root.loader.selectMode = "region"
        }

        IconTextButton {
            type: IconTextButton.Tonal
            isRound: true
            isToggle: true
            checked: root.loader.selectMode === "window"
            icon: "select_window"
            text: qsTr("Window")
            onClicked: root.loader.selectMode = "window"
        }

        // Aurora: not a mode -- a one-click action. Tears the whole picker
        // session down (all monitors) and hands off to Screenshotter's grim
        // path; see AreaPicker.qml's captureFullFromToolbar for why that
        // teardown is instant rather than the animated close every other exit
        // uses.
        IconTextButton {
            type: IconTextButton.Tonal
            isRound: true
            icon: "fullscreen"
            text: qsTr("Full screen")
            onClicked: root.loader.captureFullFromToolbar()
        }
    }
}
