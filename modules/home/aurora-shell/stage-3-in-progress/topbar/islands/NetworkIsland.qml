// Aurora topbar — network island. Compact presentation follows ilyamiro's TopBar.qml
// wifiPill (icon + SSID/status, active-state fill); data/actions are caelestia's Nmcli
// service. Expands panels/NetworkPanel.qml beneath this anchor per GRAND_PLAN.md §5.2.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Pill {
    id: root

    required property var expansion

    readonly property bool showEthernet: Nmcli.activeEthernet !== null && !Nmcli.wifiEnabled
    readonly property string label: root.showEthernet ? qsTr("Ethernet") : (Nmcli.wifiEnabled ? (Nmcli.active?.ssid ?? qsTr("On")) : qsTr("Off"))
    readonly property bool isOn: root.showEthernet ? true : Nmcli.wifiEnabled && !!Nmcli.active

    onClicked: root.expansion.toggle("network", root, null)

    MaterialIcon {
        text: root.showEthernet ? "settings_ethernet" : Icons.getNetworkIcon(Nmcli.active?.strength ?? 0, Nmcli.active?.isSecure ?? false)
        color: root.isOn ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        text: root.label
        color: root.isOn ? Colours.palette.m3primary : Colours.palette.m3onSurface
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
        elide: Text.ElideRight
        Layout.maximumWidth: 120
    }
}
