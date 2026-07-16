pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var data: ({
        location: "Chicago",
        timezone: "America/Chicago",
        fetched_at: 0,
        stale: true,
        current: {},
        hourly: [],
        daily: []
    })
    property bool loading: false
    property string error: ""
    property bool queuedRefresh: false
    property bool forceNext: false

    readonly property string location: data.location || "Chicago"
    readonly property string timezone: data.timezone || "America/Chicago"
    readonly property var current: data.current || ({})
    readonly property var hourly: data.hourly || []
    readonly property var daily: data.daily || []
    readonly property bool stale: Boolean(data.stale)
    readonly property double fetchedAt: Number(data.fetched_at || 0)

    function refresh(force) {
        if (weatherProcess.running) {
            queuedRefresh = true;
            forceNext = forceNext || Boolean(force);
            return;
        }
        forceNext = Boolean(force);
        weatherProcess.command = forceNext
            ? ["weather-fetch", "--force"]
            : ["weather-fetch"];
        loading = true;
        error = "";
        weatherProcess.running = true;
    }

    Process {
        id: weatherProcess
        running: false
        command: ["weather-fetch"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = String(text || "").trim();
                if (!output)
                    return;
                try {
                    const parsed = JSON.parse(output);
                    if (!parsed.current || !Array.isArray(parsed.hourly) || !Array.isArray(parsed.daily))
                        throw new Error("weather response is incomplete");
                    root.data = parsed;
                    root.error = "";
                } catch (exception) {
                    root.error = "Weather data could not be read";
                    console.warn("Aurora weather:", exception);
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const message = String(text || "").trim();
                if (message)
                    root.error = message.split("\n").slice(-1)[0];
            }
        }
        onExited: function(exitCode) {
            root.loading = false;
            if (exitCode !== 0 && !root.error)
                root.error = "Weather is unavailable; calendar remains offline-ready";
            if (root.queuedRefresh) {
                const nextForce = root.forceNext;
                root.queuedRefresh = false;
                root.forceNext = false;
                root.refresh(nextForce);
            }
        }
    }
}
