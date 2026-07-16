pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: Pipewire.ready && sink !== null && sink.ready
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property string description: ready
        ? (sink.description || sink.nickname || sink.name)
        : "No audio output"

    signal volumeAdjusted(real value)

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    function setVolume(value: real): void {
        if (!root.ready)
            return;
        const clamped = Math.max(0, Math.min(1, value));
        root.sink.audio.volume = clamped;
        if (clamped > 0 && root.sink.audio.muted)
            root.sink.audio.muted = false;
        root.volumeAdjusted(clamped);
    }

    function adjustVolume(delta: real): void {
        root.setVolume(root.volume + delta);
    }

    function setMuted(value: bool): void {
        if (root.ready)
            root.sink.audio.muted = value;
    }

    function toggleMute(): void {
        root.setMuted(!root.muted);
    }

    function openMixer(): void {
        Quickshell.execDetached(["pwvucontrol"]);
    }
}
