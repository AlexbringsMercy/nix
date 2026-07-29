// Vendored from caelestia-dots/shell — modules/areapicker/AreaPicker.qml. Aurora build; local changes tracked in git.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.containers
import qs.components.misc
import qs.services

Scope {
    LazyLoader {
        id: root

        property bool freeze
        property bool closing
        property bool clipboardOnly
        // Aurora: the "Region / Window" toggle the toolbar drives; reset to
        // "region" on every fresh open (see start()).
        property string selectMode: "region"
        // Aurora: the window that owned keyboard focus just before this picker
        // mapped, captured here -- the single choke point every open path
        // (direct CustomShortcut, IPC, or Screenshotter.requested from the
        // utilities card) funnels through -- so it can be explicitly restored
        // on close instead of trusting Hyprland's own post-layer-shell refocus
        // handoff, which the operator found unreliable (typing stuck on the
        // previously-focused window until clicked again).
        property string priorFocusAddress: ""
        // Aurora: set for the instant, unanimated toolbar-full-screen teardown
        // (captureFullFromToolbar below) so onClosingChanged's normal restore
        // does not fire before grim has actually captured the frame --
        // Screenshotter restores focus itself once grim exits instead, using
        // its own independently-captured address. Region/window/frozen
        // completions and Escape are unaffected and still restore here.
        property bool suppressAutoRestore: false

        function start(shouldFreeze: bool, clipOnly: bool): void {
            root.priorFocusAddress = Hypr.activeToplevel?.address ?? "";
            root.suppressAutoRestore = false;
            root.freeze = shouldFreeze;
            root.closing = false;
            root.clipboardOnly = clipOnly;
            root.selectMode = "region";
            root.activeAsync = true;
        }

        // Aurora: an explicit focuswindow dispatch -- not merely the layer
        // surface releasing WlrKeyboardFocus.Exclusive -- is what reliably
        // hands typing back to the seat. Same dispatch shape already used by
        // AppRail.qml, RailGroupPreview.qml and windowinfo/Buttons.qml to force
        // focus onto an explicit address.
        function restoreFocus(): void {
            if (!root.priorFocusAddress)
                return;
            const addr = root.priorFocusAddress;
            root.priorFocusAddress = "";
            Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:0x${addr}" })` : `focuswindow address:0x${addr}`);
        }

        // Aurora: the toolbar's Full screen button. The picker overlay (this
        // whole window, including the toolbar itself) must be gone from the
        // compositor's output before grim runs, so this skips the animated
        // close entirely -- closing flips keyboardFocus/mask off immediately
        // and activeAsync=false unloads the surface in the same tick, both
        // synchronous, before any frame is captured. Screenshotter gets a short
        // settle delay to let the compositor actually repaint without it, then
        // captures and restores focus itself once grim exits.
        function captureFullFromToolbar(): void {
            root.suppressAutoRestore = true;
            root.closing = true;
            root.activeAsync = false;
            toolbarFullSettle.restart();
        }

        onClosingChanged: {
            if (root.closing && !root.suppressAutoRestore)
                root.restoreFocus();
        }

        Variants {
            model: Screens.screens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "area-picker"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: root.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
                mask: root.closing ? empty : null

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Region {
                    id: empty
                }

                Picker {
                    loader: root
                    screen: win.modelData
                }
            }
        }
    }

    // Aurora: settle delay between the toolbar's hard teardown and the actual
    // grim invocation (captureFullFromToolbar above) -- long enough for the
    // compositor to repaint without the now-unloaded picker/toolbar surface, and
    // deliberately short because there is no fade to wait out here (unlike
    // Screenshotter's own 500ms drawer-close delay for the utilities card path).
    // Unverified live -- see report. Calls captureFullScreen directly (not
    // capture("full")) so the address captured in start() above -- not a fresh
    // re-query made after this picker has already torn itself down -- is what
    // gets restored.
    Timer {
        id: toolbarFullSettle

        interval: 50
        onTriggered: Screenshotter.captureFullScreen(root.priorFocusAddress)
    }

    // Aurora: region requests from a shell surface (the utilities Screenshot
    // card) arrive here, so the mouse path and the keyboard path share one owner.
    // Full-screen never reaches the picker — it has no selection step, so
    // Screenshotter captures it directly with grim and byte-exactly.
    Connections {
        function onRequested(freeze, clipboardOnly): void {
            root.start(freeze, clipboardOnly);
        }

        target: Screenshotter
    }

    IpcHandler {
        function open(): void {
            root.start(false, false);
        }

        function openFreeze(): void {
            root.start(true, false);
        }

        function openClip(): void {
            root.start(false, true);
        }

        function openFreezeClip(): void {
            root.start(true, true);
        }

        target: "picker"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshot"
        description: "Open screenshot tool"
        onPressed: root.start(false, false)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreeze"
        description: "Open screenshot tool (freeze mode)"
        onPressed: root.start(true, false)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotClip"
        description: "Open screenshot tool (clipboard)"
        onPressed: root.start(false, true)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreezeClip"
        description: "Open screenshot tool (freeze mode, clipboard)"
        onPressed: root.start(true, true)
    }
}
