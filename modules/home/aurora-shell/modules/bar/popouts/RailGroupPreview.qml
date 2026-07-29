// Aurora-authored — Stage 2 minimum final left-rail application slice
// (GRAND_PLAN.md §5.3, requirement 6: grouped exact live previews).
//
// Live-preview machinery ported directly from caelestia-dots/shell
// modules/windowinfo/Preview.qml's ScreencopyView usage (same captureSource/
// constraintSize idiom), repeated once per window in the hovered group so the
// user picks the *exact* window rather than just the app.
//
// This component only exists while modules/bar/popouts/Content.qml's Popout
// Loader is active (the same lifecycle every other bar popout already uses),
// so the ScreencopyView captures are created and destroyed with it — no
// separate teardown code is needed for the memory guard. The
// hover-debounce contract with AppRail.qml (currentToplevelsHovered) follows
// snowarch/iNiR modules/dock/DockPreview.qml's dual dock/popup hover guard so
// the pointer can reach this popout and click a thumbnail before it closes.
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
import Caelestia
import Caelestia.Config
import qs.components
import qs.services

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

    implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2

    Process {
        id: auroraCtl

        property string lastAction: ""
        property string lastAddr: ""

        stdout: StdioCollector {
            onStreamFinished: {
                if (/^unknown request$/i.test(text.trim()))
                    Toaster.toast(qsTr("Window restore unavailable"), qsTr("hyprctl aurora:%1 %2 → \"unknown request\" (the minimize/restore plugin isn't loaded yet).").arg(auroraCtl.lastAction).arg(auroraCtl.lastAddr), "release_alert");
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.popouts.currentToplevelsHovered = hovered
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.medium

        Repeater {
            model: ScriptModel {
                values: root.toplevels
                objectProp: "address"
            }

            delegate: ColumnLayout {
                id: item

                required property HyprlandToplevel modelData

                readonly property bool minimized: !!modelData?.lastIpcObject.hidden

                spacing: Tokens.spacing.small

                StyledClippingRect {
                    id: previewRect

                    Layout.preferredWidth: Tokens.sizes.bar.windowPreviewSize * 0.4
                    Layout.preferredHeight: Tokens.sizes.bar.windowPreviewSize * 0.28

                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer
                    opacity: item.minimized ? 0.5 : 1

                    StateLayer {
                        radius: previewRect.radius
                        onClicked: {
                            const addr = item.modelData?.address;
                            if (!addr)
                                return;
                            if (item.minimized)
                                root.runAuroraCtl("restore", `0x${addr}`);
                            else
                                Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:0x${addr}" })` : `focuswindow address:0x${addr}`);
                            root.popouts.hasCurrent = false;
                        }
                    }

                    ScreencopyView {
                        anchors.centerIn: parent

                        captureSource: item.modelData?.wayland ?? null // qmllint disable unresolved-type
                        live: true

                        constraintSize.width: previewRect.width - Tokens.padding.small
                        constraintSize.height: previewRect.height - Tokens.padding.small
                    }
                }

                StyledText {
                    Layout.maximumWidth: Tokens.sizes.bar.windowPreviewSize * 0.4
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: item.modelData?.title ?? ""
                    font: Tokens.font.body.small
                    color: item.minimized ? Colours.palette.m3outline : Colours.palette.m3onSurface
                }
            }
        }
    }
}
