pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool scanning: adapter ? adapter.discovering : false
    readonly property var devices: {
        if (!adapter)
            return [];
        const result = adapter.devices.values.slice();
        result.sort((left, right) => {
            if (left.connected !== right.connected)
                return left.connected ? -1 : 1;
            if (left.paired !== right.paired)
                return left.paired ? -1 : 1;
            return root.displayName(left).localeCompare(root.displayName(right));
        });
        return result;
    }
    property bool _scanWhenEnabled: false

    Connections {
        target: root.adapter
        enabled: root.adapter !== null

        function onEnabledChanged(): void {
            if (root.adapter && root.adapter.enabled && root._scanWhenEnabled) {
                root._scanWhenEnabled = false;
                root.startScan();
            }
        }
    }

    Timer {
        id: scanTimeout
        interval: 15000
        repeat: false
        onTriggered: root.stopScan()
    }

    function displayName(device): string {
        if (!device)
            return "Unknown device";
        return device.name || device.deviceName || device.address;
    }

    function setEnabled(value: bool): void {
        if (!root.adapter)
            return;
        if (!value)
            root.stopScan();
        else
            root._scanWhenEnabled = true;
        root.adapter.enabled = value;
    }

    function startScan(): void {
        if (!root.adapter || !root.adapter.enabled)
            return;
        root.adapter.discovering = true;
        scanTimeout.restart();
    }

    function stopScan(): void {
        root._scanWhenEnabled = false;
        scanTimeout.stop();
        if (root.adapter)
            root.adapter.discovering = false;
    }

    function toggleScan(): void {
        if (root.scanning)
            root.stopScan();
        else
            root.startScan();
    }

    function toggleConnection(device): void {
        if (!device)
            return;
        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    function cancelPair(device): void {
        if (device && device.pairing)
            device.cancelPair();
    }

    function forget(device): void {
        if (device)
            device.forget();
    }

    function openAdvanced(): void {
        // blueman supplies the interactive pairing agent for PIN/passkey and
        // uncommon device flows that BlueZ cannot safely complete headlessly.
        Quickshell.execDetached(["blueman-manager"]);
    }
}
