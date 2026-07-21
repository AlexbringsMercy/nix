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
        const result = adapter.devices.values.filter(device => root.shouldShow(device));
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

    function _looksLikeAddress(value): bool {
        const candidate = String(value || "").trim();
        return candidate === ""
            || /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(candidate)
            || /^([0-9a-f]{2}-){5}[0-9a-f]{2}$/i.test(candidate);
    }

    function hasRealName(device): bool {
        if (!device)
            return false;
        return !root._looksLikeAddress(device.name)
            || !root._looksLikeAddress(device.deviceName);
    }

    function shouldShow(device): bool {
        return device && (device.connected || device.paired || root.hasRealName(device));
    }

    function displayName(device): string {
        if (!device)
            return "Unknown device";
        if (!root._looksLikeAddress(device.name))
            return device.name;
        if (!root._looksLikeAddress(device.deviceName))
            return device.deviceName;
        return device.address;
    }

    function deviceCategory(device): string {
        if (!device)
            return "Bluetooth device";

        const icon = String(device.icon || "").toLowerCase();
        const name = root.displayName(device).toLowerCase();
        if (icon.indexOf("gaming") >= 0 || /xbox|controller|gamepad|joystick/.test(name))
            return "Game controller";
        if (icon.indexOf("keyboard") >= 0)
            return "Keyboard";
        if (icon.indexOf("mouse") >= 0 || icon.indexOf("touchpad") >= 0)
            return "Mouse / pointing device";
        if (icon.indexOf("headset") >= 0 || icon.indexOf("headphone") >= 0)
            return "Headphones / headset";
        if (icon.indexOf("audio") >= 0 || icon.indexOf("speaker") >= 0)
            return "Audio device";
        if (icon.indexOf("phone") >= 0)
            return "Phone";
        if (icon.indexOf("computer") >= 0)
            return "Computer";
        if (icon.indexOf("display") >= 0 || icon.indexOf("video") >= 0)
            return "Display / TV";
        if (icon.indexOf("camera") >= 0)
            return "Camera";
        if (icon.indexOf("printer") >= 0)
            return "Printer";
        return "Bluetooth device";
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
    }

    function stopScan(): void {
        root._scanWhenEnabled = false;
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
