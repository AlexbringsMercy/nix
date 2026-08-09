// Aurora topbar — audio island. Compact presentation follows ilyamiro's TopBar.qml
// volume pill (icon + percentage, active-state fill, scroll-to-adjust); data from
// caelestia's Audio service (Pipewire). Expands panels/AudioPanel.qml (§5.2). The deeper
// "liquid audio orb" listening surface lives on the Media island's expansion instead
// (§5.9), so the EQ is not duplicated here.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property var expansion

    readonly property bool isSoundActive: !Audio.muted && Audio.volume > 0

    onClicked: root.expansion.toggle("audio", root, null)
    onWheel: angleDelta => {
        if (angleDelta.y > 0)
            Audio.incrementVolume();
        else if (angleDelta.y < 0)
            Audio.decrementVolume();
    }

    MaterialIcon {
        text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
        color: root.isSoundActive ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        text: Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`
        color: root.isSoundActive ? Colours.palette.m3primary : Colours.palette.m3onSurface
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }
}
