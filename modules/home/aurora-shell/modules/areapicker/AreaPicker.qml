// Vendored from caelestia-dots/shell — modules/areapicker/AreaPicker.qml. Aurora build; local changes tracked in git.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.containers
import qs.components.misc
import qs.services

Scope {
    LazyLoader {
        id: root

        property bool freeze
        property bool closing
        property bool clipboardOnly

        function start(shouldFreeze: bool, clipOnly: bool): void {
            root.freeze = shouldFreeze;
            root.closing = false;
            root.clipboardOnly = clipOnly;
            root.activeAsync = true;
        }

        Variants {
            model: Screens.screens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "area-picker"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: root.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
                mask: root.closing ? empty : null

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Region {
                    id: empty
                }

                Picker {
                    loader: root
                    screen: win.modelData
                }
            }
        }
    }

    // Aurora: region requests from a shell surface (the utilities Screenshot
    // card) arrive here, so the mouse path and the keyboard path share one owner.
    // Full-screen never reaches the picker — it has no selection step, so
    // Screenshotter captures it directly with grim and byte-exactly.
    Connections {
        function onRequested(freeze, clipboardOnly): void {
            root.start(freeze, clipboardOnly);
        }

        target: Screenshotter
    }

    IpcHandler {
        function open(): void {
            root.start(false, false);
        }

        function openFreeze(): void {
            root.start(true, false);
        }

        function openClip(): void {
            root.start(false, true);
        }

        function openFreezeClip(): void {
            root.start(true, true);
        }

        target: "picker"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshot"
        description: "Open screenshot tool"
        onPressed: root.start(false, false)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreeze"
        description: "Open screenshot tool (freeze mode)"
        onPressed: root.start(true, false)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotClip"
        description: "Open screenshot tool (clipboard)"
        onPressed: root.start(false, true)
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreezeClip"
        description: "Open screenshot tool (freeze mode, clipboard)"
        onPressed: root.start(true, true)
    }
}
