// Vendored from caelestia-dots/shell — modules/areapicker/Picker.qml. Aurora build; local changes tracked in git.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia
import qs.components
import qs.components.effects
import qs.services

MouseArea {
    id: root

    required property LazyLoader loader
    required property ShellScreen screen

    property bool onClient
    property bool saving // Aurora: exactly one capture per picker instance.

    property real realBorderWidth: onClient ? (Hypr.options["general:border_size"] ?? 1) : 2
    property real realRounding: onClient ? (Hypr.options["decoration:rounding"] ?? 0) : 0

    // Aurora: dpr/pixelGrid belong to the FROZEN path only -- it is the one mode
    // still captured with CUtils.saveItem (see save() below). saveItem
    // multiplies the crop rect by the window's devicePixelRatio before cropping
    // the grab, and only skips that when the ratio is exactly 1. This panel is
    // at a fractional 1.5 scale, so an odd logical coordinate lands on half a
    // device pixel and has to be rounded. pixelGrid is the smallest logical step
    // that maps to a whole number of device pixels (2 at scale 1.5, 4 at 1.25, 1
    // at 1.0); snapping the crop to it keeps the scaled rect exact instead of
    // leaving it to rounding. Live region/window capture does NOT use either of
    // these -- see grimScale/grimRect below, and do not confuse the two.
    readonly property real dpr: (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1
    readonly property int pixelGrid: {
        for (let step = 1; step <= 8; step++)
            if (Math.abs(step * root.dpr - Math.round(step * root.dpr)) < 1e-4)
                return step;
        return 1;
    }

    // Aurora: the factor grim scales a -g box by, which is NOT root.dpr. grim
    // derives its own logical_scale from the xdg-output ratio raw_width /
    // logical_width and applies that single scalar to both axes; on this panel
    // that is 2560 / 1707 = 1.4997071, while Qt's fractional-scale DPR is 1.5
    // exactly. Using the wrong one of those two produces a crop that is subtly
    // the wrong size and subtly resampled -- the failure a gate is least likely
    // to catch -- so it is taken from the same HyprlandMonitor pixel geometry
    // Screenshotter.captureFullScreen uses, divided by the logical size grim
    // itself sees. Verified against grim 1.5.0 on this output: -g "0,0
    // 1707x1067" is byte-identical to -o eDP-1, and -g "0,0 400x300" produced
    // exactly 599x449 = floor(400 * 2560/1707) x floor(300 * 2560/1707).
    readonly property real grimScale: {
        const mon = Hypr.monitorFor(screen);
        return mon && screen.width > 0 ? mon.width / screen.width : 1;
    }

    property real ssx
    property real ssy

    property real sx: 0
    property real sy: 0
    property real ex: screen.width
    property real ey: screen.height

    property real rsx: Math.min(sx, ex)
    property real rsy: Math.min(sy, ey)
    property real sw: Math.abs(sx - ex)
    property real sh: Math.abs(sy - ey)

    // Aurora: two fixes for "automatic window bounds appear inconsistent for
    // floating windows" (root cause, both confirmed from hyprctl clients -j
    // read-only, not live-tested against an actual overlap):
    // 1. hidden (minimized) clients were not excluded. Hyprland keeps a
    //    minimized window's last on-screen at/size in its client record, so a
    //    hidden window can still win the hit-test below and get silently
    //    captured/highlighted in place of the visible window that now
    //    occupies that space.
    // 2. floating windows can overlap each other, unlike tiled ones, and the
    //    old sort had no tiebreaker among same-category clients -- ties fell
    //    back to Hyprland.toplevels' own order, which is not stacking order.
    //    focusHistoryID (0 = most recently focused) is the best read-only
    //    proxy for "on top" available, since Hyprland raises a floating
    //    window when it is focused.
    property list<var> clients: {
        const mon = Hypr.monitorFor(screen);
        if (!mon)
            return [];

        const special = mon.lastIpcObject.specialWorkspace;
        const wsId = special.name ? special.id : mon.activeWorkspace.id;

        return Hypr.toplevels.values.filter(c => c.workspace?.id === wsId && !c.lastIpcObject.hidden).sort((a, b) => {
            // Pinned first, then fullscreen, then floating, then any other;
            // most-recently-focused first within a tier.
            const ac = a.lastIpcObject;
            const bc = b.lastIpcObject;
            return (bc.pinned - ac.pinned) || ((bc.fullscreen !== 0) - (ac.fullscreen !== 0)) || (bc.floating - ac.floating) || ((ac.focusHistoryID ?? Infinity) - (bc.focusHistoryID ?? Infinity));
        });
    }

    function checkClientRects(x: real, y: real): void {
        for (const client of clients) {
            if (!client)
                continue;

            let {
                at: [cx, cy],
                size: [cw, ch]
            } = client.lastIpcObject;
            cx -= screen.x;
            cy -= screen.y;
            if (cx <= x && cy <= y && cx + cw >= x && cy + ch >= y) {
                onClient = true;
                sx = cx;
                sy = cy;
                ex = cx + cw;
                ey = cy + ch;
                break;
            }
        }
    }

    // Aurora: the FROZEN path's crop. Snaps the selection outwards onto the
    // device-pixel grid, then clamps it inside the grab. Clamping is
    // load-bearing: QImage::copy() pads a rect that overhangs its source with
    // transparent pixels instead of failing, so an unclamped rect would silently
    // produce a transparent edge on the output.
    function captureRect(): rect {
        const step = root.pixelGrid;
        const limitX = Math.floor(root.width / step) * step;
        const limitY = Math.floor(root.height / step) * step;

        const x = Math.min(Math.max(0, Math.floor(root.rsx / step) * step), Math.max(0, limitX - step));
        const y = Math.min(Math.max(0, Math.floor(root.rsy / step) * step), Math.max(0, limitY - step));
        const w = Math.max(step, Math.min(Math.ceil((root.rsx + root.sw) / step) * step, limitX) - x);
        const h = Math.max(step, Math.min(Math.ceil((root.rsy + root.sh) / step) * step, limitY) - y);

        return Qt.rect(x, y, w, h);
    }

    // Aurora: the LIVE region/window crop, in this output's logical pixels.
    //
    // Coordinate spaces -- a silent mix-up here is exactly the class of bug a
    // gate does not catch:
    //  * rsx/rsy/sw/sh are logical px inside this picker window, and the window
    //    fills the output, so they are logical px from the output's top-left.
    //  * grim -g takes LAYOUT coordinates, so the output's own logical position
    //    (screen.x/screen.y) is added on at the call site, not here.
    //  * the scale is grimScale, never root.dpr. See grimScale above.
    //
    // Why the origin is snapped: grim's mapping from output pixels to
    // destination pixels is a pure translation -- destination = output pixel -
    // origin * scale -- and the destination is floor(size * scale) px. So the
    // crop is bit-exact when the fractional part of origin * scale is zero, and
    // is bilinearly blended by that fraction otherwise; the SIZE only decides
    // how many destination pixels come out, it cannot blur anything. frac(x *
    // scale) advances by ~0.4997 per logical px here, so of any two adjacent
    // logical origins one always lands far closer to a whole output pixel, and
    // taking that one caps the blend at a quarter pixel instead of a half.
    // Measured on this panel against a grim -o reference: origin 100 (phase
    // 0.03) gives a mean channel error of 0.3/255, origin 1 (phase 0.50) gives
    // 5.2/255.
    //
    // The snap only ever moves an edge OUTWARDS and by at most one logical px,
    // which is tighter than the two-logical-px pixelGrid snap captureRect()
    // above still applies on the frozen path, so no selection -- including a
    // window's exact bounds in Window mode -- is ever cropped into.
    function grimRect(): rect {
        const s = root.grimScale;
        const phase = v => Math.abs(v * s - Math.round(v * s));

        let x = Math.max(0, Math.floor(root.rsx));
        if (x > 0 && phase(x - 1) < phase(x))
            x--;

        let y = Math.max(0, Math.floor(root.rsy));
        if (y > 0 && phase(y - 1) < phase(y))
            y--;

        // Clamped to the output: a box that overhangs it makes grim pad the
        // result instead of failing, the same trap captureRect() guards against.
        // root.width/root.height are the window's logical size, i.e. the
        // output's, which is the size grim compares the box against.
        const w = Math.min(Math.ceil(root.rsx + root.sw), root.width) - x;
        const h = Math.min(Math.ceil(root.rsy + root.sh), root.height) - y;

        return Qt.rect(x, y, Math.max(1, w), Math.max(1, h));
    }

    // Aurora: the FROZEN path's save. This is the only mode left that captures
    // through CUtils.saveItem, and it is safe to: `screencopy` already holds a
    // compositor frame taken when this picker was created, before any of its own
    // content had been drawn, so nothing about this call depends on hiding
    // anything first. Live region/window capture no longer comes through here --
    // see onReleased.
    function save(): void {
        if (root.saving)
            return;
        root.saving = true;

        const crop = root.captureRect();

        // Straight-to-clipboard keeps its scratch file; every other mode writes
        // the timestamped PNG the work order asks for and copies that.
        const target = root.loader.clipboardOnly ? Screenshotter.scratchPath() : Screenshotter.targetPath();

        verifier.path = target;
        verifier.expectedWidth = Math.round(crop.width * root.dpr);
        verifier.expectedHeight = Math.round(crop.height * root.dpr);

        // Only the screencopy subtree is grabbed. The tinted overlay, the
        // selection border and the toolbar are siblings, so no pixel of theirs
        // reaches this grab. Note precisely what that does and does not prove:
        // it makes the QtQuick scenegraph half of the exclusion structural, and
        // says nothing about what the compositor put INSIDE screencopy -- which
        // on this path is a frame from before this picker drew anything.
        CUtils.saveItem(screencopy, Qt.resolvedUrl(target), crop, () => verifier.start(), () => {
            Screenshotter.reportFailed(target);
            root.finish();
        });
    }

    function finish(): void {
        if (!closeAnim.running)
            closeAnim.start();
    }

    onClientsChanged: checkClientRects(mouseX, mouseY)

    anchors.fill: parent
    opacity: 0
    hoverEnabled: true
    cursorShape: Qt.CrossCursor

    Component.onCompleted: {
        Hypr.extras.refreshOptions();

        // Break binding if frozen
        if (loader.freeze)
            clients = clients;

        opacity = 1;

        const c = clients[0];
        if (c) {
            const cx = c.lastIpcObject.at[0] - screen.x;
            const cy = c.lastIpcObject.at[1] - screen.y;
            onClient = true;
            sx = cx;
            sy = cy;
            ex = cx + c.lastIpcObject.size[0];
            ey = cy + c.lastIpcObject.size[1];
        } else {
            sx = screen.width / 2 - 100;
            sy = screen.height / 2 - 100;
            ex = screen.width / 2 + 100;
            ey = screen.height / 2 + 100;
        }
    }

    onPressed: event => {
        ssx = event.x;
        ssy = event.y;
    }

    onReleased: {
        if (closeAnim.running || root.saving)
            return;

        if (root.loader.freeze) {
            save();
            return;
        }

        // Aurora: live region and window capture, per GRAND_PLAN §5.12 and
        // operator decision 27 -- geometry first, then the picker surface is
        // destroyed, then grim crops the compositor's own output. What this
        // replaced was a hide-then-capture: overlay/border/toolbar were switched
        // invisible and a whole-output compositor screencopy was started in the
        // same tick, which left it to chance whether Qt had committed the hide
        // before the compositor grabbed the frame. Nothing here depends on that
        // ordering any more, because by the time grim runs there is no picker
        // surface for the compositor to include (see
        // AreaPicker.captureRegionFromPicker and Screenshotter.pickerGoneGuard).
        root.saving = true;

        const r = root.grimRect();
        const s = root.grimScale;

        root.loader.captureRegionFromPicker(`${root.screen.x + r.x},${root.screen.y + r.y} ${r.width}x${r.height}`, Math.floor(r.width * s), Math.floor(r.height * s));
    }

    onPositionChanged: event => {
        const x = event.x;
        const y = event.y;

        // Aurora: in Window mode (the toolbar's toggle) a press-drag never
        // becomes a free rectangle -- it keeps re-snapping to whatever client
        // is under the cursor, so releasing anywhere always captures exactly
        // one window's bounds, never an arbitrary region.
        if (pressed && root.loader.selectMode !== "window") {
            onClient = false;
            sx = ssx;
            sy = ssy;
            ex = x;
            ey = y;
        } else {
            checkClientRects(x, y);
        }
    }

    focus: true
    Keys.onEscapePressed: closeAnim.start()

    SequentialAnimation {
        id: closeAnim

        PropertyAction {
            target: root.loader
            property: "closing"
            value: true
        }
        ParallelAnimation {
            Anim {
                target: root
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
            Anim {
                target: root
                properties: "rsx,rsy"
                to: 0
            }
            Anim {
                target: root
                property: "sw"
                to: root.screen.width
            }
            Anim {
                target: root
                property: "sh"
                to: root.screen.height
            }
        }
        PropertyAction {
            target: root.loader
            property: "activeAsync"
            value: false
        }
    }

    Process {
        running: true
        command: ["hyprctl", "cursorpos", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const pos = JSON.parse(text);
                root.checkClientRects(pos.x - root.screen.x, pos.y - root.screen.y);
            }
        }
    }

    // Aurora: risk R1 instrumentation, and now frozen-mode-only, because the
    // frozen path is the only one still going through grabToImage. A
    // fractional-scale grabToImage has never been exercised on this display, so
    // the saved file is measured before the picker closes and its real pixel
    // size is reported in the toast. A wrong size is then visible to the user
    // instead of silently shipping. The grim paths do not need this and could
    // not use it anyway -- their picker is already destroyed when the file
    // lands, and grim's output size is deterministic rather than at the mercy of
    // Qt's rounding; Screenshotter reports it and still fails loudly if the file
    // did not get written (`test -s` in the capture command).
    Item {
        id: verifier

        property string path
        property int expectedWidth
        property int expectedHeight
        property bool done

        function start(): void {
            timeout.restart();
            probe.source = Qt.resolvedUrl(verifier.path);
        }

        function report(width: int, height: int): void {
            if (verifier.done)
                return;
            verifier.done = true;

            timeout.stop();
            probe.source = "";

            Screenshotter.reportSaved(verifier.path, width, height, verifier.expectedWidth, verifier.expectedHeight, root.loader.clipboardOnly);
            root.finish();
        }

        Image {
            id: probe

            asynchronous: true
            cache: false
            visible: false

            // sourceSize on a loaded Image with no explicit sourceSize reports the
            // file's true pixel dimensions, unscaled by devicePixelRatio.
            onStatusChanged: {
                if (status === Image.Ready)
                    verifier.report(sourceSize.width, sourceSize.height);
                else if (status === Image.Error)
                    verifier.report(0, 0);
            }
        }

        Timer {
            id: timeout

            // The picker holds keyboard focus, so it must never wait on the probe
            // indefinitely.
            interval: 2000
            onTriggered: verifier.report(0, 0)
        }
    }

    // Aurora: frozen mode only, and now permanently so -- `active` is a plain
    // binding on loader.freeze with nothing left that flips it imperatively. In
    // frozen mode this is the picture the user is selecting on: one compositor
    // frame taken when the picker was created, which is also what gets cropped
    // and saved (save() above). Live region/window mode used to reuse this as a
    // capture mechanism, taking a fresh whole-output screencopy after hiding the
    // overlay; that is gone, and with it the hide it depended on.
    Loader {
        id: screencopy

        asynchronous: true
        anchors.fill: parent

        active: root.loader.freeze

        sourceComponent: ScreencopyView {
            captureSource: root.screen

            // Aurora: grabToImage sizes its target as int(logicalSize) * dpr.
            // This output is 1707x1067 logical at dpr 1.5, and 1707 is odd, so a
            // 2560x1600 capture is stretched onto 2561x1601 — a sub-pixel blur
            // that costs up to half the contrast of a one-pixel feature in the
            // middle of the frame, where windows are. Nearest-neighbour sampling
            // makes every pixel but one duplicated column and row bit-exact
            // instead. Displayed size is already ~1:1 in device pixels, so this
            // does not change how the live selection preview looks. If the type
            // ignores smooth the result is simply today's behaviour, never worse
            // — the proper fix (padding the grab to an even logical width) needs
            // a source read this session could not do and is recorded as owed.
            smooth: false
        }
    }

    StyledRect {
        id: overlay

        anchors.fill: parent
        color: Colours.palette.m3secondaryContainer
        opacity: 0.3

        layer.enabled: true
        layer.effect: Mask {
            maskSource: selectionWrapper
            maskInverted: true
        }
    }

    Item {
        id: selectionWrapper

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            id: selectionRect

            radius: root.realRounding
            x: root.rsx
            y: root.rsy
            implicitWidth: root.sw
            implicitHeight: root.sh
        }
    }

    Rectangle {
        id: border

        color: "transparent"
        radius: root.realRounding > 0 ? root.realRounding + root.realBorderWidth : 0
        border.width: root.realBorderWidth
        border.color: Colours.palette.m3primary

        x: selectionRect.x - root.realBorderWidth
        y: selectionRect.y - root.realBorderWidth
        implicitWidth: selectionRect.implicitWidth + root.realBorderWidth * 2
        implicitHeight: selectionRect.implicitHeight + root.realBorderWidth * 2

        Behavior on border.color {
            CAnim {}
        }
    }

    // Aurora: the visible Region/Window/Full screen mode toolbar (PM directive
    // 2026-07-29 -- a hover-to-discover affordance is not enough, MASTER §2).
    // A sibling of screencopy, exactly like overlay/border above, so on the
    // frozen path CUtils.saveItem grabs the `screencopy` item and never a
    // toolbar pixel. On the live region/window and full-screen paths the toolbar
    // is excluded by something stronger and completely separate: by the time
    // grim runs, this entire window has been destroyed and the compositor has
    // confirmed it (AreaPicker.tearDownForGrim, Screenshotter.pickerGoneGuard).
    // Neither statement rests on hiding the toolbar first -- the hide that used
    // to be load-bearing here is gone, along with the property that drove it.
    // root.opacity's fade (closeAnim below) cascades to it like every other
    // sibling, so Escape and frozen completion need no extra code; the two grim
    // paths skip that fade deliberately and tear the surface down instead.
    Toolbar {
        id: toolbar

        loader: root.loader
        screen: root.screen
    }

    Behavior on opacity {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Behavior on rsx {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on rsy {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on sw {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on sh {
        enabled: !root.pressed

        Anim {}
    }
}
