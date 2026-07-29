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

    // Region capture goes through the picker, which owns the selection surface.
    // Full-screen does not — see captureFullScreen below.
    signal requested(bool freeze, bool clipboardOnly)

    property string pendingMode
    property string fullTarget
    property int fullWidth
    property int fullHeight

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

    // Print captures straight through grim, deliberately, and never opens the
    // picker.
    //
    // Full-screen has no selection UI, so the overlay-contamination race that
    // forced the picker's hide -> hasContent handshake cannot exist here — there
    // is nothing on screen to bake in. What grim buys instead is exactness: it
    // writes the output's native framebuffer byte for byte, where a QQuickItem
    // grab would have to go through the fractional 1.5 scale. Qt renders an item
    // grab at QSize(int(w), int(h)) * devicePixelRatio, which for this 1707x1067
    // logical panel is 2561x1601 — so the 2560x1600 screencopy texture would be
    // bilinearly stretched by one pixel across the frame. That is a detail loss
    // on a path that was never defective. GRAND_PLAN §5.12 names grim as the
    // capture backend; what was retired was the standalone shell scripts bound
    // to keys, not grim.
    function captureFullScreen(): void {
        if (grimProc.running) {
            Toaster.toast(qsTr("Screenshot busy"), qsTr("A full screen capture is already running"), "hourglass_top", Toast.Warning);
            return;
        }

        const mon = Hypr.focusedMonitor;
        if (!mon || !mon.name) {
            Toaster.toast(qsTr("Screenshot failed"), qsTr("No focused output to capture"), "broken_image", Toast.Error);
            return;
        }

        root.fullTarget = root.targetPath();

        // grim writes the output's framebuffer at its native size, so the
        // compositor's own pixel geometry is the size that lands on disk.
        // HyprlandMonitor.width/height mirror hyprctl monitors, i.e. 2560x1600
        // here, not the 1707x1067 logical size.
        root.fullWidth = mon.width;
        root.fullHeight = mon.height;

        grimProc.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && grim -o "$2" "$1" && test -s "$1"', "aurora-screenshot-full", root.fullTarget, mon.name];
        grimProc.running = true;
    }

    // ~/Pictures/Screenshots/Screenshot_<YYYY-MM-DD_HH-MM-SS>.png — the same
    // name the retired scripts/screenshot-area and scripts/screenshot-full wrote,
    // so the folder stays sorted and nothing downstream has to learn a new one.
    function targetPath(): string {
        return `${Paths.pictures}/Screenshots/Screenshot_${Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss")}.png`;
    }

    // Passed as an argument rather than interpolated so a path containing spaces
    // cannot break the redirect.
    function copyToClipboard(path: string): void {
        Quickshell.execDetached(["sh", "-c", 'exec wl-copy --type image/png < "$1"', "wl-copy", path]);
    }

    // Called once a capture has landed on disk. width/height are the pixel
    // dimensions of the saved file — read back off the file on the region path,
    // taken from the compositor's output geometry on the grim path, where grim
    // guarantees them. expectedWidth/expectedHeight are what the maths predicted;
    // they disagree only if the fractional-scale grab misbehaves (risk R1), so
    // the mismatch is surfaced rather than logged.
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

    Process {
        id: grimProc

        onExited: code => {
            // qmllint disable signal-handler-parameters
            if (code === 0)
                root.reportSaved(root.fullTarget, root.fullWidth, root.fullHeight, root.fullWidth, root.fullHeight, false);
            else
                root.reportFailed(root.fullTarget);
        }
    }

    Timer {
        id: uiDelay

        // Long enough for the utilities drawer to finish animating out.
        interval: 500
        onTriggered: root.emitPending()
    }
}
