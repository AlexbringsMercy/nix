// Aurora-authored — Stage 2 left-rail application slice
// (GRAND_PLAN.md §5.3, requirement 6: exact live window previews).
//
// Live-preview machinery ported directly from caelestia-dots/shell
// modules/windowinfo/Preview.qml's ScreencopyView usage (same captureSource/
// constraintSize idiom), repeated once per window in the hovered tile's group so
// the user picks the *exact* window rather than just the app. A tile with a
// single window gets a single-thumbnail popout through the same path — there is
// no separate code path for the ungrouped case.
//
// This component only exists while modules/bar/popouts/Content.qml's Popout
// Loader is active (the same lifecycle every other bar popout already uses),
// so the ScreencopyView captures are created and destroyed with it — no
// separate teardown code is needed for the memory guard. The
// hover-debounce contract with AppRail.qml (currentToplevelsHovered) follows
// snowarch/iNiR modules/dock/DockPreview.qml's dual dock/popup hover guard so
// the pointer can reach this popout and click a thumbnail before it closes.
//
// Minimized members: a window hidden by the aurora-minimize plugin is still
// mapped, but it is detached from rendering, so a live screencopy stream of it
// is both wasteful and unreliable. Minimized thumbnails therefore take a single
// non-live capture and fall back to the app icon plus an explicit
// "visibility_off" badge if no frame ever arrives — they must stay visibly
// distinguishable from running members, never a blank rectangle.
//
// Restore invocation: `aurora:restore` is a plugin-registered top-level
// hyprctl COMMAND, not a dispatcher — see AppRail.qml's file-header note for
// the full explanation (PM correction, verified against HyprCtl.cpp). The
// bare `hyprctl aurora:restore <addr>` form is invoked the same way here via
// a local Process, with the same "unknown request" failure toast.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Caelestia
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Item {
    id: root

    required property PopoutState popouts

    readonly property var toplevels: popouts.currentToplevels ?? []

    function runAuroraCtl(action: string, addr: string): void {
        auroraCtl.lastAction = action;
        auroraCtl.lastAddr = addr;
        auroraCtl.command = ["hyprctl", `aurora:${action}`, addr];
        auroraCtl.running = true;
    }

    function activate(t: var): void {
        const addr = t?.address;
        if (!addr)
            return;

        if (t.lastIpcObject.hidden)
            root.runAuroraCtl("restore", `0x${addr}`);
        else
            Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:0x${addr}" })` : `focuswindow address:0x${addr}`);
        root.popouts.hasCurrent = false;
    }

    implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2

    // A stale `true` here would keep AppRail's close-debounce Timer disarmed
    // forever, pinning the next preview open. Always hand the flag back.
    Component.onDestruction: root.popouts.currentToplevelsHovered = false

    Process {
        id: auroraCtl

        property string lastAction: ""
        property string lastAddr: ""

        stdout: StdioCollector {
            onStreamFinished: {
                if (/^unknown request$/i.test(text.trim()))
                    Toaster.toast(qsTr("Window restore unavailable"), qsTr("hyprctl aurora:%1 %2 → \"unknown request\" (the minimize/restore plugin isn't loaded).").arg(auroraCtl.lastAction).arg(auroraCtl.lastAddr), "release_alert");

                // Same reason as AppRail.qml's copy: `hidden` is only ever as
                // fresh as the last toplevel refresh, and the plugin is not
                // guaranteed to emit an event services/Hypr.qml reacts to.
                Hyprland.refreshToplevels();
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.popouts.currentToplevelsHovered = hovered
    }

    GridLayout {
        id: layout

        anchors.centerIn: parent
        // Wraps rather than growing a single row off the right edge of a
        // 1707px display once an app has more than a handful of windows open.
        columns: Math.max(1, Math.min(4, root.toplevels.length))
        rowSpacing: Tokens.spacing.medium
        columnSpacing: Tokens.spacing.medium

        Repeater {
            model: ScriptModel {
                values: root.toplevels
                objectProp: "address"
            }

            delegate: ColumnLayout {
                id: item

                required property HyprlandToplevel modelData

                readonly property bool minimized: !!modelData?.lastIpcObject.hidden
                readonly property string appClass: modelData?.lastIpcObject.class ?? ""
                readonly property string appIcon: {
                    const icon = DesktopEntries.heuristicLookup(item.appClass)?.icon;
                    return icon ? Quickshell.iconPath(icon, true) : "";
                }

                spacing: Tokens.spacing.small

                StyledClippingRect {
                    id: previewRect

                    Layout.preferredWidth: Tokens.sizes.bar.windowPreviewSize * 0.4
                    Layout.preferredHeight: Tokens.sizes.bar.windowPreviewSize * 0.28

                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer
                    opacity: item.minimized ? 0.55 : 1

                    ScreencopyView {
                        id: view

                        anchors.centerIn: parent

                        captureSource: item.modelData?.wayland ?? null // qmllint disable unresolved-type
                        // Only running windows stream. A hidden window is not
                        // being rendered, so a live stream would burn CPU on an
                        // 8 GB dual-core for nothing; one attempt is enough.
                        live: !item.minimized

                        constraintSize.width: previewRect.width - Tokens.padding.small
                        constraintSize.height: previewRect.height - Tokens.padding.small
                    }

                    // Fallback identity for a window that yields no frame —
                    // in practice the minimized ones. Never a blank tile.
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Tokens.spacing.extraSmall
                        visible: !view.hasContent

                        IconImage {
                            id: fallbackIcon

                            Layout.alignment: Qt.AlignHCenter
                            asynchronous: true
                            visible: item.appIcon.length > 0
                            implicitSize: Tokens.sizes.bar.innerWidth
                            source: item.appIcon
                        }

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !fallbackIcon.visible
                            text: Icons.getAppCategoryIcon(item.appClass, "web_asset")
                            color: Colours.palette.m3outline
                        }

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: item.minimized
                            text: "visibility_off"
                            color: Colours.palette.m3outline
                        }
                    }

                    StateLayer {
                        radius: previewRect.radius
                        onClicked: root.activate(item.modelData)
                    }
                }

                StyledText {
                    Layout.maximumWidth: Tokens.sizes.bar.windowPreviewSize * 0.4
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: item.minimized ? qsTr("%1 — minimized").arg(item.modelData?.title ?? "") : (item.modelData?.title ?? "")
                    font: Tokens.font.body.small
                    color: item.minimized ? Colours.palette.m3outline : Colours.palette.m3onSurface
                }
            }
        }
    }
}
