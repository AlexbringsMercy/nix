// Vendored from caelestia-dots/shell — modules/bar/Bar.qml. Aurora build; local changes tracked in git.
pragma ComponentBehavior: Bound

import "popouts" as BarPopouts
import "components"
import "components/workspaces"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

// Aurora: the left rail carries the Stage 2 application slice (`appRail` —
// pinned apps plus current-workspace running/minimized windows with grouped
// previews, see components/AppRail.qml) ALONGSIDE the stock status entries.
//
// The end-state architecture moves workspaces/tray/clock/statusIcons/power to
// the ilyamiro top bar (GRAND_PLAN.md §10.2 items 1-2), and the rail drops them
// then. They are RETAINED here until that top bar actually ships, because it
// lives dormant on `main` at aurora-shell `stage-3-in-progress/topbar/` and is
// deliberately not in the Stage 2 closure — removing them now would delete the
// only clock, tray, status and
// power menu on the machine rather than de-duplicating anything. They retire
// WITH the top bar, not before. Same rule that keeps special:min-* visible
// until its replacement exists.

ColumnLayout {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen
    readonly property int vPadding: Tokens.padding.large

    // Aurora: the only bar entries allowed to reach volume/brightness on scroll
    // (see handleWheel below). The app rail and every other region of the bar
    // are deliberately excluded.
    readonly property var scrollStatusEntries: ["activeWindow", "tray", "clock", "statusIcons", "power"]

    function closeTray(): void {
        if (!Config.bar.tray.compact)
            return;

        for (let i = 0; i < repeater.count; i++) {
            const tray = (repeater.itemAt(i) as EntryWrapper).item as Tray;
            if (tray)
                tray.expanded = false;
        }
    }

    function checkPopout(y: real): void {
        const ch = childAt(width / 2, y) as EntryWrapper;

        if (ch?.entryId !== "tray")
            closeTray();

        if (!ch) {
            popouts.hasCurrent = false;
            return;
        }

        const id = ch.entryId;
        const top = ch.y;

        if (id === "statusIcons" && Config.bar.popouts.statusIcons) {
            const items = (ch.item as StatusIcons).items;
            const icon = items.childAt(items.width / 2, mapToItem(items, 0, y).y);
            if (icon) {
                popouts.currentName = icon.name;
                popouts.currentCenter = Qt.binding(() => icon.mapToItem(root, 0, icon.implicitHeight / 2).y);
                popouts.hasCurrent = true;
            }
        } else if (id === "tray" && Config.bar.popouts.tray) {
            const tray = ch.item as Tray;
            if (!Config.bar.tray.compact || (tray.expanded && !tray.expandIcon.contains(mapToItem(tray.expandIcon, tray.implicitWidth / 2, y)))) {
                const index = Math.floor(((y - top - tray.padding * 2 + tray.spacing) / tray.layout.implicitHeight) * tray.items.count);
                const trayItem = tray.items.itemAt(index);
                if (trayItem) {
                    popouts.currentName = `traymenu${index}`;
                    popouts.currentCenter = Qt.binding(() => trayItem.mapToItem(root, 0, trayItem.implicitHeight / 2).y);
                    popouts.hasCurrent = true;
                } else {
                    popouts.hasCurrent = false;
                }
            } else {
                popouts.hasCurrent = false;
                tray.expanded = true;
            }
        } else if (id === "activeWindow" && Config.bar.popouts.activeWindow && Config.bar.activeWindow.showOnHover) {
            popouts.currentName = id.toLowerCase();
            popouts.currentCenter = (ch.item as Item).mapToItem(root, 0, (ch.item as Item).implicitHeight / 2).y ?? 0;
            popouts.hasCurrent = true;
        } else if (id === "appRail") {
            // Aurora: the rail owns its own popout lifecycle. AppRail.qml opens
            // "railgroup" from the hovered tile itself (it needs to know *which*
            // tile, which this coarse childAt() hit-test cannot tell it) and
            // closes it on its own debounce. Deliberately a no-op so the two
            // don't fight over the same popout.
        } else if (popouts.currentName === "railgroup") {
            // Aurora: the chain above had no final dismissal branch, so a rail
            // preview left open by AppRail could survive while the pointer sat
            // on an unrelated entry (logo/clock/power) that sets no popout of
            // its own. Scoped to "railgroup" only — the upstream branches
            // deliberately leave e.g. an open tray submenu alone.
            popouts.hasCurrent = false;
        }
    }

    // Aurora: rewritten from upstream's positional fall-through.
    //
    // The old shape was `if (workspaces) … else if (y < height/2) volume else
    // brightness`, i.e. *every* wheel event on the bar that wasn't over the
    // workspaces entry drove volume or brightness. The app rail is a scrollable
    // application column, so scrolling it fell straight through to
    // `monitor.setBrightness(…)` and walked the display to zero — the operator
    // reproduced exactly that around a minimized rail entry.
    //
    // Wheel handling is now scoped to the entry actually under the pointer:
    //   • appRail     — scrolls its own list and CONSUMES the event. Nothing
    //                   below can run for a rail scroll.
    //   • workspaces  — unchanged behaviour, still gated on its config flag,
    //                   and now consumes even when the flag is off rather than
    //                   falling through to brightness.
    //   • the status stack (activeWindow/tray/clock/statusIcons/power) — keeps
    //     upstream's top-half-volume / bottom-half-brightness split verbatim,
    //     so the capability is preserved on the entries where it was actually
    //     meant to live, and both config flags stay honoured rather than being
    //     switched off.
    //   • everything else (logo, spacer, dead space between entries) is inert.
    //
    // Volume and brightness remain fully available from their dedicated
    // surfaces — modules/osd/Content.qml's sliders and wheel handlers are
    // untouched — so no capability is lost by removing the blanket fall-through.
    function handleWheel(y: real, angleDelta: point): void {
        const ch = childAt(width / 2, y) as EntryWrapper;
        const id = ch?.entryId ?? "";

        if (id === "appRail") {
            (ch.item as AppRail)?.scrollByWheel(angleDelta.y);
            return;
        }

        if (id === "workspaces") {
            if (!Config.bar.scrollActions.workspaces)
                return;

            const mon = (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor);
            const specialWs = mon?.lastIpcObject.specialWorkspace.name;
            if (specialWs?.length > 0)
                Hypr.dispatch(Hypr.usingLua ? `hl.dsp.workspace.toggle_special("${specialWs.slice(8)}")` : `togglespecialworkspace ${specialWs.slice(8)}`);
            else if (angleDelta.y < 0 || (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? mon.activeWorkspace?.id : Hypr.activeWsId) > 1)
                Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "r${angleDelta.y > 0 ? "-" : "+"}1" })` : `workspace r${angleDelta.y > 0 ? "-" : "+"}1`);
            return;
        }

        if (!root.scrollStatusEntries.includes(id))
            return;

        if (y < screen.height / 2) {
            // Volume scroll on top half of the status stack
            if (!Config.bar.scrollActions.volume)
                return;
            if (angleDelta.y > 0)
                Audio.incrementVolume();
            else if (angleDelta.y < 0)
                Audio.decrementVolume();
            return;
        }

        // Brightness scroll on bottom half of the status stack
        if (!Config.bar.scrollActions.brightness)
            return;
        const monitor = Brightness.getMonitorForScreen(screen);
        if (angleDelta.y > 0)
            monitor.setBrightness(monitor.brightness + GlobalConfig.services.brightnessIncrement);
        else if (angleDelta.y < 0)
            monitor.setBrightness(monitor.brightness - GlobalConfig.services.brightnessIncrement);
    }

    spacing: Tokens.spacing.medium

    Repeater {
        id: repeater

        model: ScriptModel {
            values: root.Config.bar.entries.filter(e => e.enabled ?? true)
        }

        DelegateChooser {
            role: "id"

            DelegateChoice {
                roleValue: "spacer"
                delegate: EntryWrapper {
                    Layout.fillHeight: true
                }
            }
            DelegateChoice {
                roleValue: "logo"
                delegate: EntryWrapper {
                    OsIcon {
                        objectName: "taskbarLogo"
                    }
                }
            }
            DelegateChoice {
                roleValue: "appRail"
                delegate: EntryWrapper {
                    AppRail {
                        objectName: "taskbarAppRail"
                        screen: root.screen
                        bar: root
                    }
                }
            }

            DelegateChoice {
                roleValue: "workspaces"
                delegate: EntryWrapper {
                    Workspaces {
                        objectName: "taskbarWorkspaces"
                        screen: root.screen
                        fullscreen: root.fullscreen
                    }
                }
            }
            DelegateChoice {
                roleValue: "activeWindow"
                delegate: EntryWrapper {
                    ActiveWindow {
                        objectName: "taskbarActiveWindow"
                        bar: root
                        monitor: Brightness.getMonitorForScreen(root.screen)
                    }
                }
            }
            DelegateChoice {
                roleValue: "tray"
                delegate: EntryWrapper {
                    Tray {
                        objectName: "taskbarTray"
                    }
                }
            }
            DelegateChoice {
                roleValue: "clock"
                delegate: EntryWrapper {
                    Clock {
                        objectName: "taskbarClock"
                    }
                }
            }
            DelegateChoice {
                roleValue: "statusIcons"
                delegate: EntryWrapper {
                    StatusIcons {
                        objectName: "taskbarStatusIcons"
                    }
                }
            }
            DelegateChoice {
                roleValue: "power"
                delegate: EntryWrapper {
                    Power {
                        objectName: "taskbarPowerButton"
                        screenState: root.screenState
                    }
                }
            }
        }
    }

    component EntryWrapper: Item {
        required property var modelData
        required property int index
        default property Item item
        readonly property string entryId: modelData.id

        Layout.topMargin: index === 0 ? root.vPadding : 0
        Layout.bottomMargin: index === repeater.count - 1 ? root.vPadding : 0
        Layout.alignment: Qt.AlignHCenter

        implicitWidth: item?.implicitWidth ?? 0
        implicitHeight: item?.implicitHeight ?? 0

        children: item
    }
}
