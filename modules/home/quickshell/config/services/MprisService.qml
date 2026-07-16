pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var availablePlayers: Mpris.players.values.filter(function(player) {
        if (!player || !player.canControl)
            return false;

        // Firefox briefly publishes a second MPRIS endpoint for YouTube hover
        // previews. It has no useful track and should never steal the panel.
        const identity = String(player.identity || "").toLowerCase();
        const url = String(player.metadata?.["xesam:url"] || "");
        return !(identity.includes("firefox")
                 && /^https?:\/\/(www\.)?youtube\.com\/?($|\?|#)/i.test(url));
    })

    property MprisPlayer activePlayer: null
    property bool positionTracking: false
    property string stableTitle: ""
    property string stableArtist: ""
    property string stableAlbum: ""
    property real stableLength: 0

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string title: stableTitle || "Nothing playing"
    readonly property string artist: stableArtist || (hasPlayer ? "Unknown artist" : "Start some music")
    readonly property string album: stableAlbum
    readonly property string identity: activePlayer?.identity || "Media"
    readonly property string artUrl: activePlayer?.trackArtUrl || ""
    readonly property real position: activePlayer?.positionSupported ? activePlayer.position : 0
    readonly property real length: stableLength > 0 ? stableLength : 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0

    function isIdle(player) {
        return player
            && player.playbackState === MprisPlaybackState.Stopped
            && !player.trackTitle
            && !player.trackArtist;
    }

    function score(player) {
        if (!player)
            return -1;
        let value = player.isPlaying ? 100 : 0;
        value += player.trackTitle ? 25 : 0;
        value += player.trackArtist ? 10 : 0;
        value += player.trackArtUrl ? 4 : 0;
        value += player.canTogglePlaying ? 2 : 0;
        value -= isIdle(player) ? 80 : 0;
        return value;
    }

    function resolveActivePlayer() {
        const players = availablePlayers;
        const playing = players.find(function(player) { return player.isPlaying; });
        if (playing) {
            activePlayer = playing;
            syncMetadata();
            return;
        }

        if (activePlayer && players.indexOf(activePlayer) >= 0 && !isIdle(activePlayer)) {
            syncMetadata();
            return;
        }

        let best = null;
        let bestScore = -1;
        for (const player of players) {
            const playerScore = score(player);
            if (playerScore > bestScore) {
                best = player;
                bestScore = playerScore;
            }
        }
        activePlayer = best;
        syncMetadata();
    }

    function syncMetadata() {
        const player = activePlayer;
        if (!player) {
            stableTitle = "";
            stableArtist = "";
            stableAlbum = "";
            stableLength = 0;
            return;
        }

        // Chromium can publish a blank metadata frame between tracks. Preserve
        // the last complete frame until the endpoint is genuinely idle.
        if (player.trackTitle)
            stableTitle = player.trackTitle;
        if (player.trackArtist)
            stableArtist = player.trackArtist;
        if (player.trackAlbum)
            stableAlbum = player.trackAlbum;
        if (player.lengthSupported && player.length > 1)
            stableLength = player.length;

        idleGrace.restart();
    }

    function setActivePlayer(player) {
        if (availablePlayers.indexOf(player) < 0)
            return;
        activePlayer = player;
        syncMetadata();
    }

    function togglePlaying() {
        if (activePlayer?.canTogglePlaying)
            activePlayer.togglePlaying();
    }

    function previous() {
        if (!activePlayer)
            return;
        if (activePlayer.positionSupported && activePlayer.canSeek && activePlayer.position > 8)
            activePlayer.position = 0.1;
        else if (activePlayer.canGoPrevious)
            activePlayer.previous();
    }

    function next() {
        if (activePlayer?.canGoNext)
            activePlayer.next();
    }

    function seekToFraction(fraction) {
        if (!activePlayer?.canSeek || !activePlayer.positionSupported || length <= 0)
            return;
        activePlayer.position = Math.max(0, Math.min(length, Number(fraction) * length));
        activePlayer.positionChanged();
    }

    function formatDuration(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const whole = Math.floor(seconds);
        const minutes = Math.floor(whole / 60);
        const remaining = whole % 60;
        return minutes + ":" + (remaining < 10 ? "0" : "") + remaining;
    }

    onAvailablePlayersChanged: resolveActivePlayer()
    Component.onCompleted: resolveActivePlayer()

    Instantiator {
        model: root.availablePlayers
        delegate: Connections {
            required property MprisPlayer modelData
            target: modelData
            function onIsPlayingChanged() { root.resolveActivePlayer(); }
            function onPlaybackStateChanged() { root.resolveActivePlayer(); }
            function onTrackChanged() { root.syncMetadata(); }
            function onTrackTitleChanged() { root.syncMetadata(); }
            function onTrackArtistChanged() { root.syncMetadata(); }
            function onTrackAlbumChanged() { root.syncMetadata(); }
            function onLengthChanged() { root.syncMetadata(); }
        }
    }

    Connections {
        target: root.activePlayer
        ignoreUnknownSignals: true
        function onPostTrackChanged() { root.syncMetadata(); }
    }

    Timer {
        id: idleGrace
        interval: 1250
        onTriggered: {
            if (!root.isIdle(root.activePlayer))
                return;
            root.stableTitle = "";
            root.stableArtist = "";
            root.stableAlbum = "";
            root.stableLength = 0;
            root.resolveActivePlayer();
        }
    }

    // MPRIS intentionally does not emit a position signal continuously. Tick
    // only while the visible music panel needs a progressing seek bar.
    Timer {
        interval: 1000
        repeat: true
        running: root.positionTracking && root.isPlaying
        onTriggered: root.activePlayer?.positionChanged()
    }
}
