// Aurora topbar — the shared expanding panel. Structurally this is ilyamiro's
// Main.qml "masterWindow" idea (repos/ilyamiro-nixos-configuration config/sessions/
// hyprland/scripts/quickshell/Main.qml): ONE geometry-morphing surface shared by every
// bar island, repositioning itself under whichever island opened it and content-swapping
// rather than each island owning a separate popup window. GRAND_PLAN.md §3.3 calls this
// "the morph engine ... ilyamiro's — everywhere" and §5.1 "top-bar islands expand
// beneath themselves". Backing data for each panel is caelestia's services
// (Audio/Bluetooth/UPower/Nmcli/Players/Cpu/Memory/Storage/NetworkUsage), per §5.2.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import "panels" as Panels

StyledWindow {
    id: root

    name: "topbar-expansion"

    property string current: ""
    property var openData: null
    property Item anchorItem: null

    readonly property bool isOpen: current !== ""

    // Screen-local coordinates of the anchor island's bottom-left corner, refreshed
    // every time a panel opens (islands live in per-screen windows; this window is
    // single-instance, so it must be told where the trigger was).
    property real anchorX: 0
    property real anchorY: 0
    property real anchorCenterX: 0

    screen: anchorItem?.QsWindow.window?.screen ?? Screens.screens[0]

    WlrLayershell.namespace: "aurora-topbar-expansion"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    focusable: root.isOpen

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true

    implicitWidth: screen?.width ?? 1
    implicitHeight: screen?.height ?? 1

    // Outside-click and Escape close the panel; the island row itself is outside this
    // window's content area (it's the bar window, not this one), so nothing else has to
    // special-case "clicked the trigger again" — the island toggles via close()/open().
    visible: isOpen
    mask: isOpen ? null : emptyRegion

    Region {
        id: emptyRegion
    }

    function open(name: string, item: Item, data: var): void {
        if (root.current === name && root.anchorItem === item) {
            close();
            return;
        }
        if (item) {
            // mapToGlobal (not mapToItem(null, ...)) because the anchor island lives in
            // the per-screen IslandBar window while this is a separate, single-instance
            // window — only screen-global coordinates are comparable across the two.
            // This window is anchored fullscreen with no margins, so global == local here.
            const pos = item.mapToGlobal(0, item.height);
            root.anchorX = pos.x;
            root.anchorY = pos.y;
            root.anchorCenterX = pos.x + item.width / 2;
        }
        root.anchorItem = item;
        root.openData = data ?? null;
        root.current = name;
    }

    function toggle(name: string, item: Item, data: var): void {
        if (root.current === name && root.isOpen)
            close();
        else
            open(name, item, data);
    }

    function close(): void {
        root.current = "";
        root.openData = null;
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.isOpen
        onClicked: root.close()
    }

    Item {
        id: focusScope

        focus: root.isOpen
        Keys.onEscapePressed: root.close()
    }

    // The animated bounding box: position + size morph together (ilyamiro's animX/animY/
    // animW/animH), content fades+scales on swap (his replaceEnter/replaceExit).
    StyledClippingRect {
        id: card

        radius: Tokens.rounding.extraLarge
        color: Colours.tPalette.m3surfaceContainer
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3onSurface, 0.08)

        readonly property real margin: Tokens.spacing.small
        readonly property Loader activeLoader: {
            switch (root.current) {
            case "network":
                return networkLoader;
            case "bluetooth":
                return bluetoothLoader;
            case "audio":
                return audioLoader;
            case "battery":
                return batteryLoader;
            case "media":
                return mediaLoader;
            case "clockweather":
                return clockWeatherLoader;
            case "resources":
                return resourcesLoader;
            case "tray":
                return trayLoader;
            default:
                return null;
            }
        }
        readonly property real targetWidth: activeLoader?.item?.implicitWidth ?? 1
        readonly property real targetHeight: activeLoader?.item?.implicitHeight ?? 1

        x: Math.max(margin, Math.min(root.anchorCenterX - width / 2, root.width - width - margin))
        y: root.anchorY + margin
        width: Math.max(1, targetWidth) + Tokens.padding.large * 2
        height: Math.max(1, targetHeight) + Tokens.padding.large * 2

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.97

        visible: opacity > 0.001

        Behavior on x {
            Anim {
                type: Anim.DefaultSpatial
            }
        }
        Behavior on width {
            Anim {
                type: Anim.DefaultSpatial
            }
        }
        Behavior on height {
            Anim {
                type: Anim.DefaultSpatial
            }
        }
        Behavior on opacity {
            Anim {
                type: root.isOpen ? Anim.DefaultEffects : Anim.FastEffects
            }
        }
        Behavior on scale {
            Anim {
                type: Anim.DefaultSpatial
            }
        }

        Item {
            id: contentArea

            anchors.fill: parent
            anchors.margins: Tokens.padding.large

            PanelLoader {
                id: networkLoader

                panelName: "network"
                sourceComponent: networkComp
            }

            PanelLoader {
                id: bluetoothLoader

                panelName: "bluetooth"
                sourceComponent: bluetoothComp
            }

            PanelLoader {
                id: audioLoader

                panelName: "audio"
                sourceComponent: audioComp
            }

            PanelLoader {
                id: batteryLoader

                panelName: "battery"
                sourceComponent: batteryComp
            }

            PanelLoader {
                id: mediaLoader

                panelName: "media"
                sourceComponent: mediaComp
            }

            PanelLoader {
                id: clockWeatherLoader

                panelName: "clockweather"
                sourceComponent: clockWeatherComp
            }

            PanelLoader {
                id: resourcesLoader

                panelName: "resources"
                sourceComponent: resourcesComp
            }

            PanelLoader {
                id: trayLoader

                panelName: "tray"
                sourceComponent: trayComp
            }
        }
    }

    component PanelLoader: Loader {
        id: loader

        required property string panelName

        anchors.centerIn: parent
        active: root.current === panelName
        asynchronous: false

        opacity: active ? 1 : 0
        scale: active ? 1 : 0.98

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
        Behavior on scale {
            Anim {
                type: Anim.DefaultSpatial
            }
        }
    }

    Component {
        id: networkComp

        Panels.NetworkPanel {}
    }

    Component {
        id: bluetoothComp

        Panels.BluetoothPanel {}
    }

    Component {
        id: audioComp

        Panels.AudioPanel {}
    }

    Component {
        id: batteryComp

        Panels.BatteryPanel {}
    }

    Component {
        id: mediaComp

        Panels.MediaEqPanel {}
    }

    Component {
        id: clockWeatherComp

        Panels.ClockWeatherPanel {}
    }

    Component {
        id: resourcesComp

        Panels.ResourcesPanel {}
    }

    Component {
        id: trayComp

        Panels.TrayPanel {
            handle: root.openData
        }
    }
}
