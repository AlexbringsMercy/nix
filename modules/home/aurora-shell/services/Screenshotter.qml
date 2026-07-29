// Aurora build; no upstream counterpart. Service shape modelled on
// caelestia-dots/shell — services/Recorder.qml, and it drives the vendored
// caelestia-dots/shell — modules/areapicker/ surface.
pragma Singleton

import QtQuick
import Quickshell
import Caelestia
import qs.services
import qs.utils

Singleton {
    id: root

    // The single door into the capture chain. modules/areapicker/AreaPicker.qml
    // listens for this and owns the picker window; nothing else may capture.
    signal requested(bool freeze, bool clipboardOnly, bool fullScreen)

    property string pendingMode

    // mode is one of "region", "frozen", "clipboard", "full".
    function capture(mode: string): void {
        root.pendingMode = mode;
        root.emitPending();
    }

    // Same, but issued from a shell surface. The drawer that owns the button is
    // still on screen and would otherwise be photographed, so both surfaces that
    // can render the card are closed first and the capture waits out the close
    // animation.
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
        root.requested(mode === "frozen", mode === "clipboard", mode === "full");
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

    // Called once a capture has landed on disk. width/height are the real pixel
    // dimensions read back off the saved file; expectedWidth/expectedHeight are
    // what the devicePixelRatio maths predicted. They disagree only if the
    // fractional-scale grab misbehaves (risk R1), so the mismatch is surfaced
    // rather than logged.
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

    Timer {
        id: uiDelay

        // Long enough for the utilities drawer to finish animating out.
        interval: 500
        onTriggered: root.emitPending()
    }
}
