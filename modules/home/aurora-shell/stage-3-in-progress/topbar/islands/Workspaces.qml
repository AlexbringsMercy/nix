// Aurora topbar — workspace island: three visible pills plus "+", active extras expand
// responsively (GRAND_PLAN.md §5.1/§10.2 decision 10), and the mandatory mouse entry
// point into Hyprexpo Overview placed next to the workspace controls (§10.2 decision 14).
// Pill row + the leading/trailing "stretchy catch-up" active indicator are ilyamiro's
// TopBar.qml workspacesBox/activeHighlight nearly 1:1; workspace data/dispatch come from
// caelestia's Hypr service instead of his bash/JSON polling.
//
// Hyprexpo sourcing note (see the Stage 3 progress report for the full finding): the
// hyprexpo plugin is NOT present in the pinned hyprwm/hyprland-plugins checkout (it only
// ships hyprbars/hyprfocus/borders-plus-plus/csgo-vulkan-fix at the pinned commit) and is
// not in nixpkgs' hyprlandPlugins. The button below dispatches the plugin's real IPC
// verb regardless, so it lights up the moment the plugin is added — it is not wired to a
// substitute.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property ShellScreen screen

    readonly property int activeWsId: Hypr.activeWsId
    readonly property int minVisible: 3

    // Base 1..3 always shown; any other occupied/active workspace is an "active extra"
    // that stays visible while in use, per §10.2 decision 10.
    readonly property var visibleIds: {
        const ids = new Set([1, 2, 3]);
        for (const ws of Hypr.workspaces.values) {
            const id = ws.id;
            if (id < 1 || ws.name.startsWith("special:"))
                continue;
            const occupied = (ws.lastIpcObject?.windows ?? 0) > 0;
            if (occupied || id === root.activeWsId)
                ids.add(id);
        }
        return [...ids].sort((a, b) => a - b);
    }

    function dispatchWorkspace(id: int): void {
        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${id}" })` : `workspace ${id}`);
    }

    function dispatchNewWorkspace(): void {
        const used = new Set(Hypr.workspaces.values.map(w => w.id));
        let next = 1;
        while (used.has(next))
            next++;
        dispatchWorkspace(next);
    }

    function dispatchHyprexpo(): void {
        // hyprexpo:expo is the plugin's own dispatcher (hyprwm/hyprland-plugins), not a
        // core Hyprland verb — inert until the plugin is loaded, see the header note.
        Hypr.dispatch("hyprexpo:expo toggle");
    }

    onWheel: angleDelta => {
        if (angleDelta.y === 0)
            return;
        const ids = root.visibleIds;
        const idx = ids.indexOf(root.activeWsId);
        if (idx === -1)
            return;
        const nextIdx = angleDelta.y > 0 ? Math.max(0, idx - 1) : Math.min(ids.length - 1, idx + 1);
        if (ids[nextIdx] !== root.activeWsId)
            root.dispatchWorkspace(ids[nextIdx]);
    }

    Item {
        id: wsStrip

        implicitWidth: wsRow.implicitWidth
        implicitHeight: wsRow.implicitHeight

        readonly property int stepSize: 32 + Tokens.spacing.small

        StyledRect {
            id: indicator

            readonly property int activeIndex: root.visibleIds.indexOf(root.activeWsId)
            property int prevIndex: activeIndex

            y: 0
            height: 32
            radius: Tokens.rounding.medium
            color: Colours.palette.m3primary

            x: activeIndex >= 0 ? activeIndex * wsStrip.stepSize : 0
            width: activeIndex >= 0 ? 32 : 0
            visible: activeIndex >= 0

            onActiveIndexChanged: {
                leadingAnim.type = activeIndex > prevIndex ? Anim.FastSpatial : Anim.SlowSpatial;
                trailingAnim.type = activeIndex > prevIndex ? Anim.SlowSpatial : Anim.FastSpatial;
                prevIndex = activeIndex;
            }

            Behavior on x {
                Anim {
                    id: leadingAnim
                }
            }
            Behavior on width {
                Anim {
                    id: trailingAnim
                }
            }
        }

        Row {
            id: wsRow

            spacing: Tokens.spacing.small

            Repeater {
                model: root.visibleIds

                Item {
                    id: wsChip

                    required property int modelData

                    readonly property bool isActive: wsChip.modelData === root.activeWsId

                    width: 32
                    height: 32

                    StyledText {
                        anchors.centerIn: parent
                        text: wsChip.modelData
                        font: Tokens.font.body.builders.medium.weight(wsChip.isActive ? Font.Bold : Font.Medium).build()
                        color: wsChip.isActive ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                    }

                    StateLayer {
                        radius: Tokens.rounding.medium
                        onClicked: root.dispatchWorkspace(wsChip.modelData)
                    }
                }
            }
        }
    }

    IconButton {
        icon: "add"
        type: IconButton.Text
        onClicked: root.dispatchNewWorkspace()
    }

    StyledRect {
        implicitWidth: 1
        implicitHeight: 20
        color: Qt.alpha(Colours.palette.m3onSurface, 0.12)
    }

    IconButton {
        id: expoButton

        icon: "grid_view"
        type: IconButton.Text
        onClicked: root.dispatchHyprexpo()

        // Discoverability for a mouse-only entry point that has no visual precedent yet.
        StyledText {
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Tokens.spacing.extraSmall
            visible: expoHover.containsMouse
            text: qsTr("Overview")
            font: Tokens.font.body.small
            color: Colours.palette.m3onSurfaceVariant
        }

        HoverHandler {
            id: expoHover
        }
    }
}
