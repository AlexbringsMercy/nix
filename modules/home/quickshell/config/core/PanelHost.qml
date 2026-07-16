pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: host

    required property string panelName
    property int panelWidth: 390
    property int panelHeight: 560
    property int topMargin: 54
    property int rightMargin: 12
    property string layerNamespace: "aurora-panel-" + panelName
    default property Component panelContent

    readonly property bool requestedOpen: PanelCoordinator.activePanel === PanelCoordinator.canonicalName(panelName)
    readonly property bool panelLoaded: windowLoader.item !== null
    readonly property var panelWindow: windowLoader.item

    property bool _keepLoaded: false
    property bool _revealed: false

    signal opened()
    signal closed()

    onRequestedOpenChanged: {
        if (requestedOpen) {
            unloadTimer.stop();
            _keepLoaded = true;
            revealTimer.restart();
            opened();
        } else if (_keepLoaded) {
            _revealed = false;
            unloadTimer.restart();
            closed();
        }
    }

    Timer {
        id: revealTimer
        interval: 16
        repeat: false
        onTriggered: {
            if (host.requestedOpen)
                host._revealed = true;
        }
    }

    Timer {
        id: unloadTimer
        interval: Motion.standard + 30
        repeat: false
        onTriggered: host._keepLoaded = false
    }

    LazyLoader {
        id: windowLoader
        active: host._keepLoaded

        PanelWindow {
            id: panelWindow

            anchors {
                top: true
                right: true
            }
            margins {
                top: host.topMargin
                right: host.rightMargin
            }

            implicitWidth: host.panelWidth
            implicitHeight: host.panelHeight
            color: "transparent"
            surfaceFormat.opaque: false
            exclusionMode: ExclusionMode.Ignore
            focusable: true

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: host.layerNamespace

            Item {
                id: animatedContent
                anchors.fill: parent
                opacity: host._revealed ? 1 : 0
                scale: host._revealed ? 1 : 0.97
                transform: Translate {
                    y: host._revealed ? 0 : -12
                    Behavior on y {
                        NumberAnimation {
                            duration: Motion.standard
                            easing.type: Motion.easeExpressive
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.standard
                        easing.type: Motion.easeOut
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Motion.standard
                        easing.type: Motion.easeExpressive
                    }
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: host.panelContent
                }
            }

            Shortcut {
                sequence: "Escape"
                onActivated: PanelCoordinator.close()
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: host.panelWindow ? [host.panelWindow] : []
        active: host.requestedOpen && host.panelLoaded && host._revealed
        onCleared: {
            if (host.requestedOpen)
                PanelCoordinator.close();
        }
    }
}
