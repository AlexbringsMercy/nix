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
// workspace; no new IPC is required to read that state.
//
// Restore invocation (PM correction, verified independently against the pinned
// Hyprland source's src/debug/HyprCtl.cpp): `aurora:restore` is a plugin-
// registered top-level hyprctl COMMAND, not a dispatcher — under Lua config
// (this project's config type) `hyprctl dispatch aurora:restore <addr>` gets
// rewritten to `hl.dispatch(aurora:restore <addr>)`, which is not valid Lua and
// never reaches the plugin. The correct call is the bare command
// `hyprctl aurora:restore <addr>` (no "dispatch", no "address:" prefix — see
// runAuroraCtl() below). The auroraminimize plugin has never been compiled, so
// its actual reply on success is unknown; Hyprland's own generic reply for an
// unregistered top-level command is the literal string "unknown request"
// (confirmed at HyprCtl.cpp's request-dispatch loop), which is what
// runAuroraCtl()'s failure toast keys off — a real success reply from the
// eventual plugin will not match that string and will not toast.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
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
    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.wsId)

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
    })

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

    // --- Grouped live-preview popout (requirement 6) — reuses the bar's own
    // anchored PopoutState/Content pipeline; see popouts/RailGroupPreview.qml. ---
    property Item hoveredGroupTile: null

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
        const popouts = root.bar.popouts;
        popouts.currentName = "railgroup";
        popouts.currentToplevels = item.windows;
        popouts.currentCenter = Qt.binding(() => tile.mapToItem(root.bar, 0, tile.implicitHeight / 2).y);
        popouts.hasCurrent = true;
    }

    function closeGroupPreviewIfMine(): void {
        const popouts = root.bar.popouts;
        if (popouts.currentName === "railgroup")
            popouts.hasCurrent = false;
    }

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: flick.contentHeight

    Process {
        id: auroraCtl

        property string lastAction: ""
        property string lastAddr: ""

        stdout: StdioCollector {
            onStreamFinished: {
                // Aurora: "unknown request" is Hyprland's verbatim reply for an
                // unregistered top-level hyprctl command (verified at
                // HyprCtl.cpp) — the auroraminimize plugin has never been
                // compiled, so this is the expected failure signature today.
                // A real plugin reply will not match this string.
                if (/^unknown request$/i.test(text.trim()))
                    Toaster.toast(qsTr("Window restore unavailable"), qsTr("hyprctl aurora:%1 %2 → \"unknown request\" (the minimize/restore plugin isn't loaded yet).").arg(auroraCtl.lastAction).arg(auroraCtl.lastAddr), "release_alert");
            }
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
        readonly property bool notInstalled: modelData.kind === "pinned" && modelData.windowCount === 0 && !modelData.entry
        readonly property bool isFocused: modelData.windows.some(w => w.address === Hypr.activeToplevel?.address)

        Layout.alignment: Qt.AlignHCenter
        implicitWidth: tile.implicitWidth
        implicitHeight: tile.implicitHeight

        RailTile {
            id: tile

            iconSource: {
                if (delegate.modelData.kind === "pinned" && delegate.modelData.entry)
                    return Quickshell.iconPath(delegate.modelData.entry.icon, "image-missing");
                if (delegate.modelData.windowCount > 0)
                    return Icons.getAppIcon(delegate.modelData.windows[0].lastIpcObject.class ?? "", "image-missing");
                return Quickshell.iconPath("", "image-missing");
            }
            focused: delegate.isFocused
            dimmed: delegate.allMinimized || delegate.notInstalled
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
                const popouts = root.bar.popouts;
                if (popouts.hasCurrent && popouts.currentName === "railgroup" && popouts.currentToplevels === md.windows)
                    popouts.hasCurrent = false;
                else
                    root.openGroupPreview(md, tile);
            }

            onHoveredChanged: {
                if (delegate.modelData.windowCount <= 1)
                    return;
                if (tile.hovered) {
                    root.hoveredGroupTile = tile;
                    root.openGroupPreview(delegate.modelData, tile);
                } else if (root.hoveredGroupTile === tile) {
                    root.hoveredGroupTile = null;
                }
            }
        }
    }
}
