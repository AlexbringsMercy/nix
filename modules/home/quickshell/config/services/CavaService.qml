pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int barCount: 28
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || (Quickshell.env("HOME") + "/.config")
    readonly property string configPath: configHome + "/cava/aurora-raw.conf"

    property bool active: false
    property var bars: Array(barCount).fill(0)
    property string error: ""
    readonly property bool running: cavaProcess.running

    function consume(line) {
        const values = String(line).trim().split(";")
            .filter(function(value) { return value !== ""; })
            .map(function(value) { return Math.max(0, Math.min(1, Number(value) / 1000)); });
        if (values.length < barCount || values.some(function(value) { return !isFinite(value); }))
            return;

        // A light low-pass avoids nervous one-frame spikes without adding a
        // second timer or sacrificing the real 30 fps Cava stream.
        const next = [];
        for (let index = 0; index < barCount; index++)
            next.push((bars[index] || 0) * 0.34 + values[index] * 0.66);
        bars = next;
        error = "";
    }

    function clear() {
        bars = Array(barCount).fill(0);
    }

    Process {
        id: cavaProcess
        command: ["cava", "-p", root.configPath]
        running: root.active && MprisService.isPlaying
        stdout: SplitParser {
            onRead: function(line) { root.consume(line); }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const message = String(text || "").trim();
                if (message)
                    root.error = message;
            }
        }
        onRunningChanged: {
            if (!running)
                root.clear();
        }
    }
}
