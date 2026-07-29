// Aurora build; no upstream counterpart. Compact "Region / Window / Full
// screen" mode toolbar for modules/areapicker, added per PM directive
// 2026-07-29: a Windows-Snipping-Tool-style visible, clickable mode surface
// centred at the top of the screen whenever screenshot mode is open -- a
// hover-to-discover affordance (clicking a window inside Region mode to
// select it) is not sufficient on its own (MASTER §2, a hotkey/gesture is
// never the only path in).
//
// HOW THIS TOOLBAR STAYS OUT OF CAPTURES (2026-07-29 architecture correction).
// Every capture mode now excludes it structurally, and by two different
// mechanisms, neither of which is a hide:
//
//  * Frozen mode is captured with CUtils.saveItem on Picker.qml's `screencopy`
//    item. This toolbar is declared as a SIBLING of that item, exactly like the
//    pre-existing overlay/border, so a grab of that subtree cannot contain a
//    toolbar pixel. And the frame inside `screencopy` is one the compositor took
//    when the picker was created, before this toolbar had drawn anything.
//
//  * Live region/window mode and the Full screen button are captured by grim,
//    after AreaPicker.qml's tearDownForGrim has DESTROYED this whole layer-shell
//    window and Screenshotter.qml's pickerGoneGuard has waited for Hyprland to
//    confirm the surface is gone from what it composites. A surface that does
//    not exist cannot be in the frame.
//
// What this replaced, and why the replacement was necessary: region/window mode
// used to switch overlay/border/toolbar invisible and start a compositor-level
// screencopy of the WHOLE output in the same tick. This window sits on
// WlrLayer.Overlay, the topmost compositing layer, so whether the toolbar landed
// in that capture depended on whether Qt had committed the hide before the
// compositor grabbed the frame -- a race, and one biased towards losing, since
// no repaint had been requested yet. That is the hide-then-capture pattern
// operator decision 27 rules out ("outside the captured subtree BY
// CONSTRUCTION, NOT BY TIMING"), and the `hiddenForCapture` property that drove
// it has been removed rather than left dormant.
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
    visible: Hypr.monitorFor(root.screen)?.name === Hypr.focusedMonitor?.name

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
        // path; see AreaPicker.qml's tearDownForGrim for why that teardown is
        // instant rather than the animated close Escape and frozen completion
        // still use.
        IconTextButton {
            type: IconTextButton.Tonal
            isRound: true
            icon: "fullscreen"
            text: qsTr("Full screen")
            onClicked: root.loader.captureFullFromToolbar()
        }
    }
}
