// Aurora topbar — Bluetooth island. Compact presentation follows ilyamiro's TopBar.qml
// btPill (icon + connected-device name, active-state fill); data from Quickshell's
// Bluetooth service. Expands panels/BluetoothPanel.qml beneath this anchor (§5.2); the
// deeper radial device view ilyamiro ships is a later depth tier, see the progress report.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Pill {
    id: root

    required property var expansion

    readonly property bool enabled_: Bluetooth.defaultAdapter?.enabled ?? false // qmllint disable unresolved-type
    readonly property var connectedDevice: Bluetooth.devices.values.find(d => d.connected) ?? null // qmllint disable unresolved-type

    visible: root.enabled_ || root.connectedDevice !== null

    onClicked: root.expansion.toggle("bluetooth", root, null)

    MaterialIcon {
        text: root.connectedDevice ? Icons.getBluetoothIcon(root.connectedDevice.icon) : "bluetooth"
        color: root.connectedDevice ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        Layout.maximumWidth: 120
        text: root.connectedDevice ? root.connectedDevice.name : qsTr("On")
        elide: Text.ElideRight
        color: root.connectedDevice ? Colours.palette.m3primary : Colours.palette.m3onSurface
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }
}
