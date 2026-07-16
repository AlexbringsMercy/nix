pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME")
        || (Quickshell.env("HOME") + "/.cache")
    readonly property string palettePath: cacheHome + "/aurora-theme/quickshell.json"
    property var palette: ({})

    // Near-black glass remains stable while wallpaper-derived accents flow to
    // every panel, toast, OSD, and control through this shared singleton.
    readonly property color background: palette.background || "#05060b"
    readonly property color panel: palette.panel || Qt.rgba(0.043, 0.055, 0.086, 0.94)
    readonly property color panelRaised: palette.panelRaised || Qt.rgba(0.063, 0.082, 0.133, 0.96)
    readonly property color surface: palette.surface || Qt.rgba(0.082, 0.106, 0.165, 0.90)
    readonly property color surfaceHover: palette.surfaceHover || Qt.rgba(0.11, 0.145, 0.22, 0.96)
    readonly property color outline: palette.outline || Qt.rgba(0.30, 0.42, 0.52, 0.28)
    readonly property color outlineStrong: palette.outlineStrong || Qt.rgba(0.33, 0.84, 0.76, 0.60)

    readonly property color primary: palette.primary || "#54d7ff"
    readonly property color secondary: palette.secondary || "#39e6c5"
    readonly property color tertiary: palette.tertiary || "#9b6dff"
    readonly property color success: palette.success || "#50d6a4"
    readonly property color warning: palette.warning || "#e9c46a"
    readonly property color error: palette.error || "#ff7d9c"

    readonly property color text: palette.text || "#eef6ff"
    readonly property color textMuted: palette.textMuted || "#a1adc2"
    readonly property color textDim: palette.textDim || "#6f7d94"
    readonly property color onAccent: palette.onAccent || "#05060b"

    readonly property string uiFont: "Inter"
    readonly property string iconFont: "FiraCode Nerd Font"
    readonly property string monoFont: "FiraCode Nerd Font"

    readonly property int radiusSmall: 8
    readonly property int radius: 12
    readonly property int radiusLarge: 16
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacing: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 22

    function loadPalette(): void {
        try {
            const raw = paletteFile.text();
            if (!raw)
                return;
            const next = JSON.parse(raw);
            if (next.primary && next.secondary && next.tertiary && next.text)
                root.palette = next;
        } catch (exception) {
            console.warn("Aurora theme: retaining fallback palette:", exception);
        }
    }

    property FileView paletteFile: FileView {
        path: root.palettePath
        preload: true
        blockLoading: false
        printErrors: false
        watchChanges: true
        onLoaded: root.loadPalette()
        onFileChanged: reload()
    }
}
