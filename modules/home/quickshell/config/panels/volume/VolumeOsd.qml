pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../core" as Core
import "../../services" as Services

PanelWindow {
    id: root

    property bool revealed: false
    property bool initialized: false

    anchors {
        bottom: true
    }
    margins.bottom: 72

    implicitWidth: 310
    implicitHeight: 70
    visible: revealed
    color: "transparent"
    surfaceFormat.opaque: false
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aurora-volume-osd"

    Component.onCompleted: {
        if (Services.AudioService.ready)
            settleTimer.restart();
    }

    function reveal(): void {
        if (!root.initialized || !Services.AudioService.ready)
            return;
        root.revealed = true;
        hideTimer.restart();
    }

    Connections {
        target: Services.AudioService
        function onReadyChanged(): void {
            root.initialized = false;
            root.revealed = false;
            if (Services.AudioService.ready)
                settleTimer.restart();
        }
        function onVolumeChanged(): void { root.reveal(); }
        function onMutedChanged(): void { root.reveal(); }
    }

    // PipeWire publishes its initial sink state as property changes. Arm the
    // OSD only after that burst so graphical login stays visually quiet.
    Timer {
        id: settleTimer
        interval: 500
        repeat: false
        onTriggered: root.initialized = Services.AudioService.ready
    }

    Timer {
        id: hideTimer
        interval: 1450
        repeat: false
        onTriggered: root.revealed = false
    }

    Rectangle {
        anchors.fill: parent
        radius: Core.Tokens.radiusLarge
        color: Core.Tokens.panel
        border.width: 1
        border.color: Core.Tokens.outlineStrong

        Row {
            anchors.fill: parent
            anchors.margins: Core.Tokens.spacingLg
            spacing: Core.Tokens.spacing

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.AudioService.muted ? "󰝟" : "󰝞"
                color: Services.AudioService.muted ? Core.Tokens.error : Core.Tokens.primary
                font.family: Core.Tokens.iconFont
                font.pixelSize: 21
            }

            Item {
                width: 220
                height: parent.height

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 7
                    radius: height / 2
                    color: Core.Tokens.surfaceHover

                    Rectangle {
                        width: Math.min(1, Services.AudioService.volume) * parent.width
                        height: parent.height
                        radius: parent.radius
                        color: Core.Tokens.secondary

                        Behavior on width {
                            NumberAnimation { duration: Core.Motion.fast; easing.type: Core.Motion.easeOut }
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.AudioService.muted ? "--" : Math.round(Services.AudioService.volume * 100)
                color: Core.Tokens.text
                font.family: Core.Tokens.monoFont
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }
    }
}
