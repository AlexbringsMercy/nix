// Aurora-authored — Stage 2 minimum final left-rail application slice
// (GRAND_PLAN.md §5.3, STAGE2_CLOSEOUT_WORK_ORDER.md deliverable H).
//
// Structural donor: caelestia-dots/shell modules/bar/ — this file reuses the
// Bar/EntryWrapper hosting convention, the bar's own PopoutState/anchored-popout
// pipeline (see modules/bar/popouts/Content.qml's "railgroup" case and
// RailGroupPreview.qml), and the `Hypr.toplevels.values.filter(t => t.workspace?.id
// === wsId)` idiom already used by modules/bar/components/workspaces/Workspace.qml
// and modules/areapicker/Picker.qml.
//
// Grouping-model donor: AvengeMedia/DankMaterialShell
// quickshell/Modules/Dock/DockApps.qml — the "pinned app that is currently running
// fuses into one tile; unpinned running apps become their own grouped tile" model
// is adapted from its buildUngroupedItems()/buildGroupedItems() logic, drastically
// narrowed to Stage 2's scope (no drag/reorder, no overflow, no trash, no core-app
// plugin icons).
//
// Preview-guard donor: snowarch/iNiR modules/dock/DockPreview.qml — the
// hover/close debounce (root.hoveredGroupTile / currentToplevelsHovered +
// a running-bound Timer) mirrors its dual dock-hover/popup-hover Timer guard so a
// live preview can actually be reached and clicked instead of vanishing the
// instant the pointer leaves the 40px-wide tile.
//
// Binding contract (GRAND_PLAN.md §6.2, EXECUTION_LOG finding 20a): minimized
// windows report `"hidden": true` in `hyprctl clients -j` and keep their original
// workspace; no new IPC is required to read that state. Verified live on this
// machine against `hyprctl clients -j` with the auroraminimize plugin loaded.
//
// Restore invocation (PM correction, verified independently against the pinned
// Hyprland source's src/debug/HyprCtl.cpp): `aurora:restore` is a plugin-
// registered top-level hyprctl COMMAND, not a dispatcher — under Lua config
// (this project's config type) `hyprctl dispatch aurora:restore <addr>` gets
// rewritten to `hl.dispatch(aurora:restore <addr>)`, which is not valid Lua and
// never reaches the plugin. The correct call is the bare command
// `hyprctl aurora:restore <addr>` (no "dispatch", no "address:" prefix — see
// runAuroraCtl() below). `hyprctl plugin list` on this machine now reports
// "aurora-minimize by Aurora" as loaded, so the failure toast below should no
// longer be the expected outcome.
//
// PREVIEW FIX (this session): openGroupPreview() used to abort halfway. It writes
// to `root.bar.popouts`, which is a modules/bar/popouts/Wrapper — not the
// PopoutState that declares `currentToplevels`. The Wrapper aliased only
// currentName/hasCurrent, so the `currentToplevels` write raised
// "Cannot assign to non-existent property" (visible in the shell journal at
// AppRail.qml:181) and the following `hasCurrent = true` never executed, so no
// preview ever opened for any tile. The Wrapper now aliases both rail properties.
// Hover previews are additionally no longer restricted to multi-window groups.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.utils
import qs.modules.launcher.services

Item {
    id: root

    required property ShellScreen screen
    required property var bar

    // --- Pinned block (GRAND_PLAN §5.3): always visible regardless of running state. ---
    readonly property var pinnedSpecs: [
        {
            key: "chrome",
            idHints: ["google-chrome", "google-chrome.desktop", "com.google.Chrome", "com.google.Chrome.desktop"],
            classRegex: /^google-chrome$/i
        },
        {
            key: "kitty",
            idHints: ["kitty", "kitty.desktop"],
            classRegex: /^kitty$/i
        },
        {
            key: "dolphin",
            idHints: ["org.kde.dolphin", "dolphin.desktop"],
            classRegex: /dolphin/i
        },
        {
            key: "spotify",
            idHints: ["spotify", "spotify.desktop", "com.spotify.Client"],
            classRegex: /spotify/i
        },
        {
            key: "mediacenter",
            idHints: ["mediacenter", "mediacenter.desktop"],
            classRegex: /^MediaCenter$/i
        }
    ]

    // Aurora: ephemeral one-shot helper surfaces that must never become rail
    // entries. Layer-shell surfaces (the area picker, the bar itself, the
    // drawers) never appear in `hyprctl clients` at all and so cannot reach this
    // list — but the shell also creates real xdg toplevels via Quickshell
    // FloatingWindow (components/filedialog/FileDialog.qml's file picker,
    // modules/nexus/WindowFactory.qml's detached window), and those DO show up
    // as clients. They are caught by the pid test in isEphemeral() rather than
    // by this list, because pid equality is exact and needs no app-id guessing.
    // This list covers external screenshot/colour-pick/portal helpers instead.
    readonly property var ephemeralClassRegex: /^(quickshell|caelestia(-shell)?|aurora(-shell)?|org\.quickshell.*|grim|slurp|swappy|satty|flameshot|hyprshot|hyprpicker|wl-clipboard|xdg-desktop-portal.*|.*\.portal\.desktop.*|hyprland-share-picker)$/i

    // Current-workspace-only source of truth, scoped to *this* rail's own
    // screen/monitor (not just the globally-focused one) — matches the
    // per-monitor awareness modules/bar/components/workspaces/Workspaces.qml
    // already has, for whenever an external display is attached.
    readonly property var monitor: Hypr.monitorFor(root.screen)
    readonly property int wsId: monitor?.activeWorkspace?.id ?? Hypr.activeWsId

    // Deliberately filters the flat `clients`-backed toplevel list rather than
    // a workspace's own `.toplevels` aggregate — the minimize backend detaches
    // a layout target from the workspace's target list, which under-counts
    // that aggregate (binding contract above / EXECUTION_LOG finding 20a).
    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.wsId && !root.isEphemeral(t))

    // Pinned apps that are neither installed nor running are dropped rather
    // than rendered as an inert placeholder: with no desktop entry there is no
    // icon and no launch command, so the tile resolved to the icon theme's
    // `image-missing` glyph (a torn-photo pictogram in Papirus) that did
    // nothing when clicked — the "screenshot/image utility dead icon" the
    // operator reported. A pin reappears the moment its app is installed.
    readonly property var pinnedItems: pinnedSpecs.map(spec => {
        const windows = root.wsToplevels.filter(t => spec.classRegex.test(t.lastIpcObject.class ?? ""));
        return {
            key: `pinned:${spec.key}`,
            kind: "pinned",
            spec: spec,
            entry: root.findDesktopEntry(spec.idHints),
            windows: windows,
            windowCount: windows.length
        };
    }).filter(i => i.entry || i.windowCount > 0)

    readonly property var taskItems: {
        const groups = new Map();
        for (const t of root.wsToplevels) {
            const cls = t.lastIpcObject.class ?? "";
            if (root.pinnedSpecs.some(s => s.classRegex.test(cls)))
                continue;
            if (!groups.has(cls))
                groups.set(cls, []);
            groups.get(cls).push(t);
        }
        const items = Array.from(groups.entries()).map(([cls, windows]) => ({
                    key: `task:${cls}`,
                    kind: "task",
                    cls: cls,
                    windows: windows,
                    windowCount: windows.length
                }));
        // Running groups cluster above fully-minimized ones (GRAND_PLAN §5.3
        // layout: running, then minimized-dimmed); stable within each partition.
        const running = items.filter(i => !i.windows.every(w => root.isMinimized(w)));
        const minimized = items.filter(i => i.windows.every(w => root.isMinimized(w)));
        return running.concat(minimized);
    }

    readonly property var railItems: pinnedItems.concat(taskItems)

    // --- Exact live-preview popout (requirement 6) — reuses the bar's own
    // anchored PopoutState/Content pipeline; see popouts/RailGroupPreview.qml.
    // Opens for ANY tile with at least one window, not just multi-window groups:
    // a single-window app must show that exact window's preview too. ---
    property Item hoveredGroupTile: null
    property string openGroupKey: ""

    function findDesktopEntry(idHints: var): var {
        const apps = DesktopEntries.applications.values;
        for (const hint of idHints) {
            const found = apps.find(a => a.id === hint);
            if (found)
                return found;
        }
        return null;
    }

    function isMinimized(t: var): bool {
        return !!t?.lastIpcObject.hidden;
    }

    // Shell-owned and ephemeral surfaces never belong in an application rail.
    function isEphemeral(t: var): bool {
        const o = t?.lastIpcObject;
        if (!o)
            return true;
        // Anything this very shell process mapped: Nexus's detached window, the
        // file/image picker dialog, and any future FloatingWindow surface.
        if (o.pid === Quickshell.processId)
            return true;
        const cls = (o.class ?? "").trim();
        if (!cls)
            return true;
        return root.ephemeralClassRegex.test(cls);
    }

    // Never resolves to `image-missing`: an empty string here makes RailTile
    // fall back to a themed Material glyph instead of a broken-image pictogram.
    function iconPathFor(item: var): string {
        if (item.kind === "pinned" && item.entry)
            return Quickshell.iconPath(item.entry.icon, true);
        if (item.windowCount > 0) {
            const icon = DesktopEntries.heuristicLookup(item.windows[0].lastIpcObject.class ?? "")?.icon;
            if (icon)
                return Quickshell.iconPath(icon, true);
        }
        return "";
    }

    function glyphFor(item: var): string {
        if (item.windowCount > 0)
            return Icons.getAppCategoryIcon(item.windows[0].lastIpcObject.class ?? "", "web_asset");
        return "web_asset";
    }

    function windowsForKey(key: string): var {
        return root.railItems.find(i => i.key === key)?.windows ?? [];
    }

    // Bare top-level hyprctl command invocation for the auroraminimize plugin
    // (see the file-header note above) — never a `dispatch`. Surfaces failure
    // via a toast rather than a silent dead click (PM correction).
    function runAuroraCtl(action: string, addr: string): void {
        auroraCtl.lastAction = action;
        auroraCtl.lastAddr = addr;
        auroraCtl.command = ["hyprctl", `aurora:${action}`, addr];
        auroraCtl.running = true;
    }

    // One-click focus/restore (GRAND_PLAN §5.3, §6.2 decision #6 — mandatory path;
    // a hotkey is optional redundancy only, owned elsewhere).
    function focusOrRestore(t: var): void {
        if (!t)
            return;
        if (isMinimized(t))
            runAuroraCtl("restore", `0x${t.address}`);
        else
            Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:0x${t.address}" })` : `focuswindow address:0x${t.address}`);
    }

    function openGroupPreview(item: var, tile: Item): void {
        if (item.windowCount < 1)
            return;

        const popouts = root.bar.popouts;
        root.openGroupKey = item.key;
        popouts.currentName = "railgroup";
        popouts.currentToplevels = item.windows;
        popouts.currentCenter = Qt.binding(() => tile.mapToItem(root.bar, 0, tile.implicitHeight / 2).y);
        popouts.hasCurrent = true;
    }

    // Hover entry point. Deliberately NOT a direct openGroupPreview() call:
    // sweeping the pointer down the rail would otherwise spin up and tear down a
    // live ScreencopyView stream for every tile it crosses, which this 8 GB
    // dual-core cannot absorb while the operator is working. A short rest opens
    // the preview; a sweep opens nothing. Swapping between tiles while a rail
    // preview is already up stays instant, since that cost is already paid.
    function requestGroupPreview(item: var, tile: Item): void {
        if (item.windowCount < 1)
            return;

        const popouts = root.bar.popouts;
        if (popouts.hasCurrent && popouts.currentName === "railgroup") {
            root.openGroupPreview(item, tile);
            return;
        }

        openDelay.pendingItem = item;
        openDelay.pendingTile = tile;
        openDelay.restart();
    }

    function isGroupPreviewOpen(key: string): bool {
        const popouts = root.bar.popouts;
        return popouts.hasCurrent && popouts.currentName === "railgroup" && root.openGroupKey === key;
    }

    function closeGroupPreviewIfMine(): void {
        const popouts = root.bar.popouts;
        root.openGroupKey = "";
        if (popouts.currentName === "railgroup")
            popouts.hasCurrent = false;
    }

    // Called by Bar.qml's handleWheel, which hands the rail its own wheel events
    // and returns immediately afterwards. Nothing here may fall through to the
    // bar's volume/brightness scroll actions.
    function scrollByWheel(deltaY: real): void {
        if (deltaY === 0)
            return;

        const step = Tokens.sizes.bar.innerWidth + Tokens.spacing.small;
        flick.contentY -= deltaY > 0 ? step : -step;
        flick.returnToBounds();
    }

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: flick.contentHeight

    // `currentToplevels` is imperative state on the shared popout Wrapper, not a
    // binding, so an open preview would otherwise keep rendering the snapshot it
    // was opened with — including entries for windows that have since closed
    // (dangling QObject references) and stale minimized/restored state. Re-feed
    // it whenever the rail's own model changes, and close the preview outright
    // once its group is empty.
    onRailItemsChanged: {
        if (!root.openGroupKey)
            return;

        const popouts = root.bar.popouts;
        if (!popouts.hasCurrent || popouts.currentName !== "railgroup")
            return;

        const windows = root.windowsForKey(root.openGroupKey);
        if (windows.length === 0)
            root.closeGroupPreviewIfMine();
        else
            popouts.currentToplevels = windows;
    }

    Process {
        id: auroraCtl

        property string lastAction: ""
        property string lastAddr: ""

        stdout: StdioCollector {
            onStreamFinished: {
                // Aurora: "unknown request" is Hyprland's verbatim reply for an
                // unregistered top-level hyprctl command (verified at
                // HyprCtl.cpp). With aurora-minimize loaded this should no
                // longer fire; if it does, the plugin is missing again and the
                // click must not fail silently.
                if (/^unknown request$/i.test(text.trim()))
                    Toaster.toast(qsTr("Window restore unavailable"), qsTr("hyprctl aurora:%1 %2 → \"unknown request\" (the minimize/restore plugin isn't loaded).").arg(auroraCtl.lastAction).arg(auroraCtl.lastAddr), "release_alert");

                // The rail's whole model hangs off each toplevel's
                // `lastIpcObject.hidden`. services/Hypr.qml only refreshes
                // toplevels when Hyprland emits an event it recognises, and the
                // plugin's own minimize/restore is not guaranteed to emit one —
                // so pull the truth back explicitly rather than leaving a
                // restored window drawn as still-minimized.
                Hyprland.refreshToplevels();
            }
        }
    }

    Timer {
        id: openDelay

        property var pendingItem: null
        property Item pendingTile: null

        interval: 140
        onTriggered: {
            // The tile must still be the hovered one — a sweep will have moved
            // hoveredGroupTile on (or to null) before this fires.
            if (openDelay.pendingItem && root.hoveredGroupTile === openDelay.pendingTile)
                root.openGroupPreview(openDelay.pendingItem, openDelay.pendingTile);
        }
    }

    Timer {
        // iNiR DockPreview.qml pattern: debounce the close so the pointer can
        // actually travel from the 40px tile into the popout panel and click a
        // specific window without the preview vanishing first.
        interval: 220
        running: root.bar.popouts.currentName === "railgroup" && root.bar.popouts.hasCurrent && !root.hoveredGroupTile && !root.bar.popouts.currentToplevelsHovered
        onTriggered: root.closeGroupPreviewIfMine()
    }

    VerticalFadeFlickable {
        id: flick

        anchors.fill: parent
        contentHeight: content.implicitHeight
        topMargin: Tokens.padding.small
        bottomMargin: Tokens.padding.small

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Tokens.spacing.small

            Repeater {
                model: ScriptModel {
                    values: root.pinnedItems
                    objectProp: "key"
                }

                delegate: RailTileDelegate {}
            }

            StyledRect {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Tokens.spacing.extraSmall
                Layout.bottomMargin: Tokens.spacing.extraSmall
                visible: root.taskItems.length > 0
                implicitWidth: Tokens.sizes.bar.innerWidth * 0.6
                implicitHeight: 1
                color: Colours.palette.m3outlineVariant
            }

            Repeater {
                model: ScriptModel {
                    values: root.taskItems
                    objectProp: "key"
                }

                delegate: RailTileDelegate {}
            }
        }
    }

    component RailTileDelegate: Item {
        id: delegate

        required property var modelData

        readonly property bool anyRunning: modelData.windowCount > 0
        readonly property bool allMinimized: anyRunning && modelData.windows.every(w => root.isMinimized(w))
        readonly property bool isFocused: modelData.windows.some(w => w.address === Hypr.activeToplevel?.address)

        Layout.alignment: Qt.AlignHCenter
        implicitWidth: tile.implicitWidth
        implicitHeight: tile.implicitHeight

        RailTile {
            id: tile

            iconSource: root.iconPathFor(delegate.modelData)
            fallbackGlyph: root.glyphFor(delegate.modelData)
            focused: delegate.isFocused
            dimmed: delegate.allMinimized
            windowCount: delegate.modelData.windowCount

            onClicked: {
                const md = delegate.modelData;
                if (md.windowCount === 0) {
                    if (md.kind === "pinned" && md.entry)
                        Apps.launch(md.entry);
                    return;
                }
                if (md.windowCount === 1) {
                    root.closeGroupPreviewIfMine();
                    root.focusOrRestore(md.windows[0]);
                    return;
                }
                // Multi-window: the tile itself cannot pick a window, so it only
                // toggles the preview — the preview's thumbnails are what focus
                // or restore a specific address.
                if (root.isGroupPreviewOpen(md.key))
                    root.closeGroupPreviewIfMine();
                else
                    root.openGroupPreview(md, tile);
            }

            onHoveredChanged: {
                // Every tile with at least one window previews on hover, so a
                // single-window app shows that exact window and a grouped app
                // shows every member (minimized ones dimmed).
                if (delegate.modelData.windowCount < 1)
                    return;
                if (tile.hovered) {
                    root.hoveredGroupTile = tile;
                    root.requestGroupPreview(delegate.modelData, tile);
                } else if (root.hoveredGroupTile === tile) {
                    root.hoveredGroupTile = null;
                }
            }
        }
    }
}
