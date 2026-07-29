// Aurora build; no upstream counterpart. Service shape modelled on
// caelestia-dots/shell — services/Recorder.qml, and it drives the vendored
// caelestia-dots/shell — modules/areapicker/ surface.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import qs.services
import qs.utils

Singleton {
    id: root

    // Region/window capture goes through the picker, which owns the selection
    // surface but no longer performs the capture: it hands its geometry back and
    // this service runs grim (captureRegion below). Full-screen never opens the
    // picker at all — see captureFullScreen.
    signal requested(bool freeze, bool clipboardOnly)

    property string pendingMode
    // Aurora: the in-flight grim capture — full screen, region or window alike.
    // grimProc below is deliberately shared by all three so there is exactly one
    // place that reports the result and restores focus.
    property string grimTarget
    property int grimWidth
    property int grimHeight
    property bool grimClipboardOnly
    // Aurora: the window that owned keyboard focus just before grim ran,
    // captured fresh in captureFullScreen and restored once grim exits --
    // covers the Print keybind, the utilities-card Full screen action, and both
    // area-picker paths that hand off to grim (the toolbar's Full screen button
    // and a region/window selection), which tear their own picker down first and
    // defer to this capture-and-restore rather than doing their own, so the
    // restore dispatch can never race grim's actual screen grab.
    property string priorFocusAddress: ""

    // Aurora: every grim capture in this file waits on this before it grabs a
    // frame. It exists because "the picker window has been destroyed" is NOT the
    // same statement as "the picker is out of the frame": Hyprland keeps
    // *rendering* an unmapped layer surface for the whole layersOut /
    // fadeLayersOut animation (hyprland/animations.lua:35,37 — speed 3.0 and
    // 2.8, i.e. ~300ms and ~280ms). Measured on this machine at generation 31
    // against Hyprland 0.55.4, with a throwaway opaque layer torn down exactly
    // the way AreaPicker tears the picker down: a grim frame taken 5ms after the
    // surface was destroyed is still ~100% that surface, and one taken 153ms
    // after is still ~76% of it. A fixed settle delay is therefore a guess, and
    // the 50ms one this file's full-screen path used to rely on was far too
    // short to be a correct guess.
    //
    // `hyprctl layers` keeps listing a layer for as long as it is still being
    // composited, fade included, so the namespace being absent from it is the
    // compositor's own statement that the surface contributes nothing to the
    // frame it composites next. Measured over three separate runs, the first
    // poll where the namespace was absent already captured clean while the poll
    // immediately before it was still contaminated. The wait lives inside the
    // same `sh -c` as grim, so nothing can reorder the two, and it is bounded
    // (40 polls, ~2.3s) so a future namespace rename degrades to today's
    // behaviour instead of hanging the capture forever.
    //
    // The namespace is StyledWindow.qml's `caelestia-${name}` applied to
    // AreaPicker.qml's `name: "area-picker"`. Every path that has no picker on
    // screen (the Print keybind, the utilities card, IPC) simply finds it absent
    // on the first poll and pays ~40ms.
    readonly property string pickerGoneGuard: '{ n=0; while [ "$n" -lt 40 ] && hyprctl layers | grep -q "namespace: caelestia-area-picker"; do n=$((n+1)); sleep 0.02; done; } && '

    // mode is one of "region", "frozen", "clipboard", "full".
    function capture(mode: string): void {
        root.pendingMode = mode;
        root.emitPending();
    }

    // Same, but issued from a shell surface. The drawer that owns the button is
    // still on screen and would otherwise be photographed, so both surfaces that
    // can render the card are closed first and the capture waits out the close
    // animation. This matters most for "full", which captures instantly.
    function captureFromUi(mode: string): void {
        root.pendingMode = mode;

        const state = ShellState.forActive();
        if (state) {
            state.utilities = false;
            state.sidebar = false;
        }

        uiDelay.restart();
    }

    function emitPending(): void {
        const mode = root.pendingMode;
        root.pendingMode = "";

        if (mode === "full")
            root.captureFullScreen();
        else
            root.requested(mode === "frozen", mode === "clipboard");
    }

    // Aurora: grimProc is shared by every grim path, so a second capture must
    // not be allowed to overwrite the first one's target mid-flight.
    function grimBusy(): bool {
        if (!grimProc.running)
            return false;
        Toaster.toast(qsTr("Screenshot busy"), qsTr("A capture is already running"), "hourglass_top", Toast.Warning);
        return true;
    }

    // Print captures straight through grim, deliberately, and never opens the
    // picker.
    //
    // Full-screen has no selection UI of its own, so there is nothing to bake in
    // except a picker the *toolbar's* Full screen button may have left behind —
    // which pickerGoneGuard above, not a delay, is what excludes. What grim buys
    // on top of that is exactness: it writes the output's native framebuffer
    // byte for byte, where a QQuickItem grab would have to go through the
    // fractional 1.5 scale. Qt renders an item grab at QSize(int(w), int(h)) *
    // devicePixelRatio, which for this 1707x1067 logical panel is 2561x1601 — so
    // the 2560x1600 screencopy texture would be bilinearly stretched by one
    // pixel across the frame. GRAND_PLAN §5.12 names grim as the capture
    // backend; what was retired was the standalone shell scripts bound to keys,
    // not grim.
    // Aurora: restoreAddress is optional. Passed explicitly by the area-picker
    // toolbar's Full screen button (AreaPicker.qml's captureFullFromToolbar),
    // which already captured the right address when ITS picker opened -- that
    // is the address this call restores, not whatever is focused (or not) at
    // this later moment. Left undefined by every path with no picker in the
    // way (the Print keybind, the utilities-card action, the IPC handler), in
    // which case a fresh capture is taken below instead.
    function captureFullScreen(restoreAddress: string): void {
        if (root.grimBusy())
            return;

        const mon = Hypr.focusedMonitor;
        if (!mon || !mon.name) {
            Toaster.toast(qsTr("Screenshot failed"), qsTr("No focused output to capture"), "broken_image", Toast.Error);
            return;
        }

        // Aurora: restore only after grim exits (see grimProc.onExited) -- an
        // explicit focuswindow dispatch is what actually hands typing back,
        // and firing it any earlier would race grim's own screen grab with a
        // focus-change repaint.
        root.priorFocusAddress = restoreAddress !== undefined ? restoreAddress : (Hypr.activeToplevel?.address ?? "");

        root.grimClipboardOnly = false;
        root.grimTarget = root.targetPath();

        // grim writes the output's framebuffer at its native size, so the
        // compositor's own pixel geometry is the size that lands on disk.
        // HyprlandMonitor.width/height mirror hyprctl monitors, i.e. 2560x1600
        // here, not the 1707x1067 logical size.
        root.grimWidth = mon.width;
        root.grimHeight = mon.height;

        grimProc.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && ' + root.pickerGoneGuard + 'grim -o "$2" "$1" && test -s "$1"', "aurora-screenshot-full", root.grimTarget, mon.name];
        grimProc.running = true;
    }

    // Aurora: region and window capture. GRAND_PLAN §5.12 puts the picker's job
    // at "overlay-tinted only ... capture happens via grim after geometry, so
    // the §5 purple-film bug is structurally gone", and operator decision 27
    // requires the toolbar and picker to sit outside the captured frame by
    // construction rather than by timing. That is what this function completes:
    // Picker.qml computes the crop while its selection is still on screen,
    // AreaPicker.captureRegionFromPicker destroys every picker layer-shell
    // surface, pickerGoneGuard holds grim until the compositor confirms they are
    // gone, and grim then crops the compositor's own output. A surface that no
    // longer exists cannot be in that frame — there is no hide to race.
    //
    // geometry is grim's -g string in LOGICAL LAYOUT coordinates; pixelWidth /
    // pixelHeight are grim's deterministic output size for it. Both come from
    // Picker.grimRect(), which owns and documents the coordinate-space and scale
    // arithmetic.
    function captureRegion(geometry: string, pixelWidth: int, pixelHeight: int, clipboardOnly: bool, restoreAddress: string): void {
        if (root.grimBusy())
            return;

        // Unlike captureFullScreen, this is only ever reached from a picker, so
        // the address captured when that picker opened always exists and is
        // always the right one to restore.
        root.priorFocusAddress = restoreAddress;

        root.grimClipboardOnly = clipboardOnly;
        // Straight-to-clipboard keeps its scratch file; every other mode writes
        // the timestamped PNG the work order asks for and copies that.
        root.grimTarget = clipboardOnly ? root.scratchPath() : root.targetPath();
        root.grimWidth = pixelWidth;
        root.grimHeight = pixelHeight;

        grimProc.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && ' + root.pickerGoneGuard + 'grim -g "$2" "$1" && test -s "$1"', "aurora-screenshot-region", root.grimTarget, geometry];
        grimProc.running = true;
    }

    // ~/Pictures/Screenshots/Screenshot_<YYYY-MM-DD_HH-MM-SS>.png — the same
    // name the retired scripts/screenshot-area and scripts/screenshot-full wrote,
    // so the folder stays sorted and nothing downstream has to learn a new one.
    function targetPath(): string {
        return `${Paths.pictures}/Screenshots/Screenshot_${Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss")}.png`;
    }

    // Aurora: the straight-to-clipboard scratch file. Defined once here rather
    // than at each call site so the frozen path (Picker.save) and the grim path
    // (captureRegion) cannot drift apart.
    function scratchPath(): string {
        return `/tmp/caelestia-picker-${Quickshell.processId}-${Date.now()}.png`;
    }

    // Passed as an argument rather than interpolated so a path containing spaces
    // cannot break the redirect.
    function copyToClipboard(path: string): void {
        Quickshell.execDetached(["sh", "-c", 'exec wl-copy --type image/png < "$1"', "wl-copy", path]);
    }

    // Called once a capture has landed on disk. width/height are the pixel
    // dimensions of the saved file — read back off the file on the frozen path,
    // which still goes through CUtils.saveItem, and computed on the grim paths,
    // where the size is deterministic (the whole output for -o, floor(logical *
    // scale) for -g) rather than subject to risk R1's fractional-scale grab.
    // expectedWidth/expectedHeight are what the maths predicted; they disagree
    // only if that grab misbehaves, so the mismatch is surfaced rather than
    // logged.
    function reportSaved(path: string, width: int, height: int, expectedWidth: int, expectedHeight: int, clipboardOnly: bool): void {
        root.copyToClipboard(path);

        const where = clipboardOnly ? qsTr("Copied to clipboard") : qsTr("Clipboard + %1").arg(Paths.shortenHome(path));

        if (width <= 0 || height <= 0) {
            Toaster.toast(qsTr("Screenshot saved"), qsTr("%1 — size could not be verified").arg(where), "screenshot_region", Toast.Warning);
            return;
        }

        if (Math.abs(width - expectedWidth) > 1 || Math.abs(height - expectedHeight) > 1) {
            Toaster.toast(qsTr("Screenshot saved at an unexpected size"), qsTr("%1×%2 px, expected %3×%4 — fractional display scaling").arg(width).arg(height).arg(expectedWidth).arg(expectedHeight), "aspect_ratio", Toast.Warning);
            return;
        }

        Toaster.toast(qsTr("Screenshot saved"), qsTr("%1×%2 px — %3").arg(width).arg(height).arg(where), "screenshot_region", Toast.Success);
    }

    function reportFailed(path: string): void {
        Toaster.toast(qsTr("Screenshot failed"), qsTr("Could not write %1").arg(path ? Paths.shortenHome(path) : qsTr("the screenshot")), "broken_image", Toast.Error);
    }

    // Aurora: same dispatch shape as AppRail.qml/RailGroupPreview.qml/
    // windowinfo/Buttons.qml. A no-op if the address is empty (nothing was
    // focused before, or this call already consumed it).
    function restoreFocus(): void {
        if (!root.priorFocusAddress)
            return;
        const addr = root.priorFocusAddress;
        root.priorFocusAddress = "";
        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:0x${addr}" })` : `focuswindow address:0x${addr}`);
    }

    Process {
        id: grimProc

        onExited: code => {
            // qmllint disable signal-handler-parameters
            if (code === 0)
                root.reportSaved(root.grimTarget, root.grimWidth, root.grimHeight, root.grimWidth, root.grimHeight, root.grimClipboardOnly);
            else
                root.reportFailed(root.grimTarget);
            // Aurora: restore regardless of outcome -- a failed capture must
            // not also leave the operator unable to type.
            root.restoreFocus();
        }
    }

    Timer {
        id: uiDelay

        // Long enough for the utilities drawer to finish animating out.
        interval: 500
        onTriggered: root.emitPending()
    }
}
