pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../../core" as Core
import "../../services" as Services

Core.PanelHost {
    id: panel

    panelName: "music"
    panelWidth: 720
    panelHeight: 790
    topMargin: 54
    rightMargin: 500
    layerNamespace: "aurora-panel-music"

    onOpened: {
        Services.MprisService.positionTracking = true;
        Services.CavaService.active = true;
    }
    onClosed: {
        Services.MprisService.positionTracking = false;
        Services.CavaService.active = false;
    }

    Item {
        id: content
        anchors.fill: parent

        property var eqState: ({
            bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            preset: "Flat"
        })
        property var queuedEqCommand: null
        property real introCover: 0
        property real introDetails: 0
        property real introControls: 0
        property real introVisualizer: 0
        property real introEqualizer: 0
        property real introPresets: 0

        readonly property var bandLabels: ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]
        readonly property var presets: ["Flat", "Bass", "Treble", "Vocal", "Pop", "Rock", "Jazz", "Classic"]

        function runEq(commandArguments) {
            if (eqProcess.running) {
                queuedEqCommand = commandArguments;
                return;
            }
            eqProcess.command = ["equalizer-state"].concat(commandArguments);
            eqProcess.running = true;
        }

        function setBand(index, value) {
            const next = eqState.bands.slice();
            next[index] = Math.round(value * 10) / 10;
            eqState = { bands: next, preset: "Custom" };
            runEq(["set-band", String(index), String(next[index])]);
        }

        function applyPreset(name) {
            runEq(["preset", name]);
            presetPulse.restart();
        }

        Component.onCompleted: {
            runEq(["get"]);
            stagedIntro.restart();
        }
        Component.onDestruction: {
            Services.MprisService.positionTracking = false;
            Services.CavaService.active = false;
        }

        ThemeBridge { id: theme }

        Process {
            id: eqProcess
            running: false
            command: ["equalizer-state", "get"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const output = String(text || "").trim();
                    if (!output)
                        return;
                    try {
                        const parsed = JSON.parse(output);
                        if (Array.isArray(parsed.bands) && parsed.bands.length === 10)
                            content.eqState = parsed;
                    } catch (exception) {
                        console.warn("Aurora equalizer:", exception);
                    }
                }
            }
            onExited: {
                if (content.queuedEqCommand) {
                    const next = content.queuedEqCommand;
                    content.queuedEqCommand = null;
                    content.runEq(next);
                }
            }
        }

        ParallelAnimation {
            id: stagedIntro
            NumberAnimation {
                target: content; property: "introCover"
                from: 0; to: 1; duration: Core.Motion.staged
                easing.type: Easing.OutBack; easing.overshoot: 0.72
            }
            SequentialAnimation {
                PauseAnimation { duration: 90 }
                NumberAnimation {
                    target: content; property: "introDetails"
                    from: 0; to: 1; duration: Core.Motion.deliberate
                    easing.type: Core.Motion.easeExpressive
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 180 }
                NumberAnimation {
                    target: content; property: "introControls"
                    from: 0; to: 1; duration: Core.Motion.deliberate
                    easing.type: Easing.OutBack; easing.overshoot: 0.55
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 270 }
                NumberAnimation {
                    target: content; property: "introVisualizer"
                    from: 0; to: 1; duration: Core.Motion.deliberate
                    easing.type: Core.Motion.easeExpressive
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 350 }
                NumberAnimation {
                    target: content; property: "introEqualizer"
                    from: 0; to: 1; duration: Core.Motion.staged
                    easing.type: Easing.OutExpo
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 490 }
                NumberAnimation {
                    target: content; property: "introPresets"
                    from: 0; to: 1; duration: Core.Motion.deliberate
                    easing.type: Easing.OutBack; easing.overshoot: 0.6
                }
            }
        }

        SequentialAnimation {
            id: presetPulse
            NumberAnimation { target: eqGlow; property: "opacity"; to: 0.30; duration: Core.Motion.fast }
            NumberAnimation { target: eqGlow; property: "opacity"; to: 0; duration: Core.Motion.deliberate }
        }

        Rectangle {
            id: shell
            anchors.fill: parent
            anchors.margins: 1
            radius: Core.Tokens.radiusLarge
            color: Qt.rgba(theme.panel.r, theme.panel.g, theme.panel.b, 0.91)
            border.width: 1
            border.color: theme.outlineStrong
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.20; color: theme.tertiary }
                    GradientStop { position: 0.52; color: theme.primary }
                    GradientStop { position: 0.82; color: theme.secondary }
                    GradientStop { position: 1; color: "transparent" }
                }
            }

            Rectangle {
                id: eqGlow
                width: 440; height: 440; radius: 220
                x: parent.width - 250; y: parent.height - 260
                color: theme.tertiary
                opacity: 0
                z: -1
                layer.enabled: opacity > 0
                layer.effect: MultiEffect { blurEnabled: true; blur: 1; blurMax: 64 }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 222
                    spacing: 24

                    Item {
                        Layout.preferredWidth: 206
                        Layout.preferredHeight: 206
                        opacity: content.introCover
                        scale: 0.76 + 0.24 * content.introCover
                        transform: Translate {
                            x: -34 * (1 - content.introCover)
                            y: 10 * (1 - content.introCover)
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 202; height: 202; radius: 101
                            color: "#030409"
                            border.width: 3
                            border.color: Services.MprisService.isPlaying ? theme.tertiary : theme.outline

                            Rectangle {
                                anchors.centerIn: parent
                                width: 216; height: 216; radius: 108
                                color: theme.tertiary
                                opacity: Services.MprisService.isPlaying ? 0.13 : 0
                                z: -1
                                Behavior on opacity { NumberAnimation { duration: Core.Motion.standard } }
                            }

                            Item {
                                id: vinyl
                                anchors.fill: parent
                                anchors.margins: 5

                                Image {
                                    id: albumImage
                                    anchors.fill: parent
                                    source: Services.MprisService.artUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize: Qt.size(384, 384)
                                    visible: false
                                }
                                Rectangle {
                                    id: albumMask
                                    anchors.fill: parent
                                    radius: width / 2
                                    visible: false
                                    layer.enabled: true
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: albumImage
                                    maskEnabled: true
                                    maskSource: albumMask
                                    opacity: albumImage.status === Image.Ready ? 0.90 : 0
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.12)
                                    Repeater {
                                        model: 5
                                        Rectangle {
                                            required property int index
                                            anchors.centerIn: parent
                                            width: 178 - index * 27
                                            height: width
                                            radius: width / 2
                                            color: "transparent"
                                            border.width: 1
                                            border.color: Qt.rgba(1, 1, 1, 0.09)
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34; height: 34; radius: 17
                                    color: "#05060b"
                                    border.width: 5
                                    border.color: theme.primary
                                }

                                NumberAnimation on rotation {
                                    from: 0; to: 360; duration: 12000
                                    loops: Animation.Infinite
                                    running: panel.requestedOpen
                                    paused: !Services.MprisService.isPlaying
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 8
                        spacing: 8
                        opacity: content.introDetails
                        transform: Translate { x: 30 * (1 - content.introDetails) }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: Services.MprisService.identity.toUpperCase()
                                color: theme.secondary
                                font.family: Core.Tokens.monoFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: statusText.implicitWidth + 18; height: 25; radius: 7
                                color: Qt.rgba(theme.secondary.r, theme.secondary.g, theme.secondary.b, 0.12)
                                border.width: 1
                                border.color: Qt.rgba(theme.secondary.r, theme.secondary.g, theme.secondary.b, 0.32)
                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: Services.MprisService.isPlaying ? "PLAYING" : (Services.MprisService.hasPlayer ? "PAUSED" : "IDLE")
                                    color: Services.MprisService.isPlaying ? theme.secondary : theme.textDim
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Services.MprisService.title
                            color: theme.text
                            font.family: Core.Tokens.uiFont
                            font.pixelSize: 28
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Services.MprisService.artist
                            color: theme.textMuted
                            font.family: Core.Tokens.uiFont
                            font.pixelSize: 16
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Services.MprisService.album
                            visible: text !== ""
                            color: theme.textDim
                            font.family: Core.Tokens.uiFont
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }

                        Slider {
                            id: progressSlider
                            Layout.fillWidth: true
                            from: 0; to: 1
                            enabled: Boolean(Services.MprisService.activePlayer?.canSeek)
                            onPressedChanged: {
                                if (!pressed)
                                    Services.MprisService.seekToFraction(value);
                            }

                            Binding {
                                target: progressSlider
                                property: "value"
                                value: Services.MprisService.progress
                                when: !progressSlider.pressed
                                restoreMode: Binding.RestoreBindingOrValue
                            }

                            background: Rectangle {
                                x: progressSlider.leftPadding
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - 3
                                width: progressSlider.availableWidth
                                height: 6; radius: 3
                                color: theme.surface
                                Rectangle {
                                    width: progressSlider.visualPosition * parent.width
                                    height: parent.height; radius: parent.radius
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0; color: theme.tertiary }
                                        GradientStop { position: 0.5; color: theme.primary }
                                        GradientStop { position: 1; color: theme.secondary }
                                    }
                                }
                            }
                            handle: Rectangle {
                                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                width: 16; height: 16; radius: 8
                                color: theme.text
                                scale: progressSlider.pressed ? 1.25 : 1
                                Behavior on scale { NumberAnimation { duration: Core.Motion.fast; easing.type: Easing.OutBack } }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: Services.MprisService.formatDuration(Services.MprisService.position)
                                color: theme.textDim; font.family: Core.Tokens.monoFont; font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Services.MprisService.formatDuration(Services.MprisService.length)
                                color: theme.textDim; font.family: Core.Tokens.monoFont; font.pixelSize: 11
                            }
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 20
                            opacity: content.introControls
                            transform: Translate { y: 18 * (1 - content.introControls) }

                            component TransportButton: Button {
                                required property string glyph
                                property bool primaryAction: false
                                implicitWidth: primaryAction ? 52 : 40
                                implicitHeight: primaryAction ? 52 : 40
                                hoverEnabled: true
                                background: Rectangle {
                                    radius: width / 2
                                    color: parent.primaryAction
                                        ? (parent.down ? Qt.darker(theme.primary, 1.18) : theme.primary)
                                        : (parent.hovered ? theme.surfaceHover : theme.surface)
                                    border.width: parent.primaryAction ? 0 : 1
                                    border.color: theme.outline
                                    scale: parent.down ? 0.92 : 1
                                    Behavior on scale { NumberAnimation { duration: Core.Motion.fast; easing.type: Core.Motion.easeOut } }
                                    Behavior on color { ColorAnimation { duration: Core.Motion.fast } }
                                }
                                contentItem: Text {
                                    text: parent.glyph
                                    color: parent.primaryAction ? theme.onAccent : theme.text
                                    font.family: Core.Tokens.iconFont
                                    font.pixelSize: parent.primaryAction ? 22 : 17
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            TransportButton {
                                glyph: "󰒮"
                                enabled: Boolean(Services.MprisService.activePlayer?.canGoPrevious || Services.MprisService.activePlayer?.canSeek)
                                onClicked: Services.MprisService.previous()
                                ToolTip.visible: hovered; ToolTip.text: "Previous / restart"
                            }
                            TransportButton {
                                glyph: Services.MprisService.isPlaying ? "󰏤" : "󰐊"
                                primaryAction: true
                                enabled: Boolean(Services.MprisService.activePlayer?.canTogglePlaying)
                                onClicked: Services.MprisService.togglePlaying()
                                ToolTip.visible: hovered; ToolTip.text: Services.MprisService.isPlaying ? "Pause" : "Play"
                            }
                            TransportButton {
                                glyph: "󰒭"
                                enabled: Boolean(Services.MprisService.activePlayer?.canGoNext)
                                onClicked: Services.MprisService.next()
                                ToolTip.visible: hovered; ToolTip.text: "Next"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    radius: Core.Tokens.radius
                    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.48)
                    border.width: 1
                    border.color: theme.outline
                    opacity: content.introVisualizer
                    transform: Translate { y: 16 * (1 - content.introVisualizer) }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 5
                        Repeater {
                            model: Services.CavaService.barCount
                            Rectangle {
                                required property int index
                                width: (parent.width - (Services.CavaService.barCount - 1) * parent.spacing) / Services.CavaService.barCount
                                height: Math.max(3, (Services.CavaService.bars[index] || 0) * parent.height)
                                anchors.bottom: parent.bottom
                                radius: width / 2
                                color: index < 9 ? theme.tertiary : (index < 19 ? theme.primary : theme.secondary)
                                opacity: 0.52 + (Services.CavaService.bars[index] || 0) * 0.48
                                Behavior on height { NumberAnimation { duration: 44; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !Services.MprisService.isPlaying
                        text: Services.MprisService.hasPlayer ? "Visualizer wakes with playback" : "No active MPRIS player"
                        color: theme.textDim
                        font.family: Core.Tokens.uiFont
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    opacity: content.introEqualizer
                    transform: Translate { y: 22 * (1 - content.introEqualizer) }
                    Text {
                        text: "10-BAND PARAMETRIC EQ"
                        color: theme.text
                        font.family: Core.Tokens.monoFont
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: theme.outline }
                    Text {
                        text: content.eqState.preset.toUpperCase()
                        color: theme.tertiary
                        font.family: Core.Tokens.monoFont
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 256
                    spacing: 5
                    opacity: content.introEqualizer

                    Repeater {
                        model: 10
                        ColumnLayout {
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            opacity: content.introEqualizer
                            transform: Translate {
                                y: (30 + index * 5) * (1 - content.introEqualizer)
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    const value = Number(content.eqState.bands[index] || 0);
                                    return (value > 0 ? "+" : "") + value.toFixed(value % 1 === 0 ? 0 : 1);
                                }
                                color: theme.textMuted
                                font.family: Core.Tokens.monoFont
                                font.pixelSize: 10
                            }

                            Slider {
                                id: bandSlider
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillHeight: true
                                orientation: Qt.Vertical
                                from: -12; to: 12; stepSize: 0.5
                                onPressedChanged: {
                                    if (!pressed)
                                        content.setBand(index, value);
                                }
                                Binding {
                                    target: bandSlider
                                    property: "value"
                                    value: Number(content.eqState.bands[index] || 0)
                                    when: !bandSlider.pressed
                                    restoreMode: Binding.RestoreBindingOrValue
                                }
                                background: Rectangle {
                                    x: bandSlider.leftPadding + bandSlider.availableWidth / 2 - 3
                                    y: bandSlider.topPadding
                                    width: 6; height: bandSlider.availableHeight; radius: 3
                                    color: theme.surface
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: (1 - bandSlider.visualPosition) * parent.height
                                        radius: 3
                                        gradient: Gradient {
                                            orientation: Gradient.Vertical
                                            GradientStop { position: 0; color: theme.tertiary }
                                            GradientStop { position: 0.55; color: theme.primary }
                                            GradientStop { position: 1; color: theme.secondary }
                                        }
                                    }
                                }
                                handle: Rectangle {
                                    x: bandSlider.leftPadding + bandSlider.availableWidth / 2 - width / 2
                                    y: bandSlider.topPadding + bandSlider.visualPosition * (bandSlider.availableHeight - height)
                                    width: 16; height: 16; radius: 8
                                    color: bandSlider.pressed ? theme.secondary : theme.text
                                    border.width: 2
                                    border.color: theme.panel
                                    scale: bandSlider.pressed ? 1.18 : 1
                                    Behavior on scale { NumberAnimation { duration: Core.Motion.fast; easing.type: Easing.OutBack } }
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: content.bandLabels[index]
                                color: theme.textDim
                                font.family: Core.Tokens.monoFont
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8
                    opacity: content.introPresets
                    transform: Translate { y: 18 * (1 - content.introPresets) }

                    Repeater {
                        model: content.presets
                        Button {
                            required property string modelData
                            Layout.fillWidth: true
                            implicitHeight: 34
                            hoverEnabled: true
                            onClicked: content.applyPreset(modelData)
                            background: Rectangle {
                                radius: Core.Tokens.radiusSmall
                                color: content.eqState.preset === parent.modelData
                                    ? theme.tertiary
                                    : (parent.hovered ? theme.surfaceHover : theme.surface)
                                border.width: content.eqState.preset === parent.modelData ? 0 : 1
                                border.color: theme.outline
                                scale: parent.down ? 0.96 : 1
                                Behavior on color { ColorAnimation { duration: Core.Motion.fast } }
                                Behavior on scale { NumberAnimation { duration: Core.Motion.fast; easing.type: Core.Motion.easeOut } }
                            }
                            contentItem: Text {
                                text: parent.modelData
                                color: content.eqState.preset === parent.modelData ? theme.onAccent : theme.textMuted
                                font.family: Core.Tokens.uiFont
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
