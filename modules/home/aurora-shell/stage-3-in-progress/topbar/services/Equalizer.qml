// Aurora topbar — state bridge for the "aurora-shell/scripts/equalizer-state" CLI (see
// GRAND_PLAN.md §5.9). Structure/behaviour of the surface it feeds is ilyamiro's
// music/MusicPopup.qml (repos/ilyamiro-nixos-configuration); EasyEffects stays invisible.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var bandFrequencies: [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    readonly property var presets: ["Flat", "Bass", "Treble", "Vocal", "Pop", "Rock", "Jazz", "Classic"]

    property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property string preset: "Flat"
    property bool ready: false

    function refresh(): void {
        getProc.running = false;
        getProc.running = true;
    }

    function setBand(index: int, gainDb: real): void {
        // Optimistic local update so the fader doesn't snap back while the
        // script round-trips; refresh() below reconciles with the real state.
        const next = bands.slice();
        next[index] = Math.max(-12, Math.min(12, gainDb));
        bands = next;
        preset = "Custom";
        writeProc.exec(["equalizer-state", "set-band", index.toString(), gainDb.toString()]);
    }

    function setPreset(name: string): void {
        preset = name;
        writeProc.exec(["equalizer-state", "preset", name]);
    }

    function applyState(text: string): void {
        try {
            const state = JSON.parse(text);
            if (Array.isArray(state.bands) && state.bands.length === 10)
                bands = state.bands;
            if (typeof state.preset === "string")
                preset = state.preset;
            ready = true;
        } catch (e) {
            console.warn("Equalizer: failed to parse equalizer-state output:", e);
        }
    }

    Component.onCompleted: refresh()

    Process {
        id: getProc

        command: ["equalizer-state", "get"]
        stdout: StdioCollector {
            onStreamFinished: root.applyState(text)
        }
    }

    Process {
        id: writeProc

        stdout: StdioCollector {
            onStreamFinished: root.applyState(text)
        }
    }
}
