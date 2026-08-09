// Aurora topbar — battery island. Compact presentation follows ilyamiro's TopBar.qml
// batteryPill (icon + percentage, charge-state colour); data from Quickshell's UPower
// service. Expands panels/BatteryPanel.qml (§5.2); the ilyamiro battery-ring presentation
// is the later depth tier (see the progress report). Hidden entirely on desktops (no
// battery), matching the ilyamiro donor's isDesktop branch.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Pill {
    id: root

    required property var expansion

    readonly property bool hasBattery: UPower.displayDevice.isLaptopBattery
    readonly property real percentage: UPower.displayDevice.percentage
    // UPower.onBattery is the proven signal (see modules/bar/popouts/Battery.qml) — avoids
    // depending on the exact UPowerDeviceState enum names, which vary by Quickshell version.
    readonly property bool charging: root.hasBattery && !UPower.onBattery

    visible: root.hasBattery

    onClicked: root.expansion.toggle("battery", root, null)

    MaterialIcon {
        text: Icons.getBatteryIcon(root.percentage, root.charging)
        color: root.charging ? Colours.palette.m3tertiary : (root.percentage <= 0.2 ? Colours.palette.m3error : Colours.palette.m3onSurface)
        fill: 1
    }

    StyledText {
        text: `${Math.round(root.percentage * 100)}%`
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }
}
