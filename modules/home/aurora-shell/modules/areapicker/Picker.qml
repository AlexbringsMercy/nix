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

    // Aurora: CUtils.saveItem multiplies the crop rect by the window's
    // devicePixelRatio before cropping the grab, and only skips that when the
    // ratio is exactly 1. This panel is at a fractional 1.5 scale, so an odd
    // logical coordinate lands on half a device pixel and has to be rounded.
    // pixelGrid is the smallest logical step that maps to a whole number of
    // device pixels (2 at scale 1.5, 4 at 1.25, 1 at 1.0); snapping the crop to
    // it keeps the scaled rect exact instead of leaving it to rounding.
    readonly property real dpr: (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1
    readonly property int pixelGrid: {
        for (let step = 1; step <= 8; step++)
            if (Math.abs(step * root.dpr - Math.round(step * root.dpr)) < 1e-4)
                return step;
        return 1;
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

    property list<var> clients: {
        const mon = Hypr.monitorFor(screen);
        if (!mon)
            return [];

        const special = mon.lastIpcObject.specialWorkspace;
        const wsId = special.name ? special.id : mon.activeWorkspace.id;

        return Hypr.toplevels.values.filter(c => c.workspace?.id === wsId).sort((a, b) => {
            // Pinned first, then fullscreen, then floating, then any other
            const ac = a.lastIpcObject;
            const bc = b.lastIpcObject;
            return (bc.pinned - ac.pinned) || ((bc.fullscreen !== 0) - (ac.fullscreen !== 0)) || (bc.floating - ac.floating);
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

    // Aurora: snap the selection outwards onto the device-pixel grid, then clamp
    // it inside the grab. Clamping is load-bearing: QImage::copy() pads a rect
    // that overhangs its source with transparent pixels instead of failing, so an
    // unclamped rect would silently produce a transparent edge on the output.
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

    function save(): void {
        if (root.saving)
            return;
        root.saving = true;

        const crop = root.captureRect();

        // Straight-to-clipboard keeps its scratch file; every other mode writes
        // the timestamped PNG the work order asks for and copies that.
        const target = root.loader.clipboardOnly ? `/tmp/caelestia-picker-${Quickshell.processId}-${Date.now()}.png` : Screenshotter.targetPath();

        verifier.path = target;
        verifier.expectedWidth = Math.round(crop.width * root.dpr);
        verifier.expectedHeight = Math.round(crop.height * root.dpr);

        // Only the screencopy subtree is grabbed. The tinted overlay and the
        // selection border are siblings, so they are not in the grab at all —
        // which is what makes overlay contamination structurally impossible here.
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
        if (closeAnim.running)
            return;

        if (root.loader.freeze) {
            save();
        } else {
            overlay.visible = border.visible = false;
            screencopy.visible = false;
            screencopy.active = true;
        }
    }

    onPositionChanged: event => {
        const x = event.x;
        const y = event.y;

        if (pressed) {
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

    // Aurora: risk R1 instrumentation. A fractional-scale grabToImage has never
    // been exercised on this display, so the saved file is measured before the
    // picker closes and its real pixel size is reported in the toast. A wrong
    // size is then visible to the user instead of silently shipping.
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

            onHasContentChanged: {
                if (!hasContent || root.loader.freeze)
                    return;

                // Restore the selection UI for the close animation only. It is not
                // in the grab, and the frame that reached hasContent was captured
                // with it hidden.
                overlay.visible = border.visible = true;
                root.save();
            }
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
