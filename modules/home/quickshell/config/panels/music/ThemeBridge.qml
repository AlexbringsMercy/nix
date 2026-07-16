import QtQuick
import Quickshell
import Quickshell.Io
import "../../core" as Core

QtObject {
    id: root

    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME")
        || (Quickshell.env("HOME") + "/.cache")
    readonly property string palettePath: cacheHome + "/aurora-theme/quickshell.json"

    property var palette: ({})

    readonly property color background: palette.background || Core.Tokens.background
    readonly property color panel: palette.panel || Core.Tokens.panel
    readonly property color panelRaised: palette.panelRaised || Core.Tokens.panelRaised
    readonly property color surface: palette.surface || Core.Tokens.surface
    readonly property color surfaceHover: palette.surfaceHover || Core.Tokens.surfaceHover
    readonly property color outline: palette.outline || Core.Tokens.outline
    readonly property color outlineStrong: palette.outlineStrong || Core.Tokens.outlineStrong
    readonly property color primary: palette.primary || Core.Tokens.primary
    readonly property color secondary: palette.secondary || Core.Tokens.secondary
    readonly property color tertiary: palette.tertiary || Core.Tokens.tertiary
    readonly property color success: palette.success || Core.Tokens.success
    readonly property color warning: palette.warning || Core.Tokens.warning
    readonly property color error: palette.error || Core.Tokens.error
    readonly property color text: palette.text || Core.Tokens.text
    readonly property color textMuted: palette.textMuted || Core.Tokens.textMuted
    readonly property color textDim: palette.textDim || Core.Tokens.textDim
    readonly property color onAccent: palette.onAccent || Core.Tokens.onAccent

    function loadPalette() {
        try {
            const raw = paletteFile.text();
            if (!raw)
                return;
            const next = JSON.parse(raw);
            if (next.primary && next.secondary && next.tertiary && next.text)
                palette = next;
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
