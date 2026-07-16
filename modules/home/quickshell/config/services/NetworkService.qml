pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var wifiDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wifi)
    readonly property var wifiDevice: wifiDevices.length > 0 ? wifiDevices[0] : null
    readonly property bool available: wifiDevice !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false
    readonly property string hardwareAddress: wifiDevice ? wifiDevice.address : ""
    readonly property var networks: {
        if (!wifiDevice)
            return [];
        const visible = wifiDevice.networks.values.filter(network => network.name !== "");
        visible.sort((left, right) => {
            if (left.connected !== right.connected)
                return left.connected ? -1 : 1;
            if (left.known !== right.known)
                return left.known ? -1 : 1;
            return right.signalStrength - left.signalStrength;
        });
        return visible;
    }
    readonly property var connectedNetwork: networks.find(network => network.connected) || null

    property var pendingNetwork: null
    property string errorMessage: ""
    property string ipv4Address: ""
    property bool _scanWhenEnabled: false

    Process {
        id: addressQuery
        stdout: StdioCollector {
            onStreamFinished: root.parseAddresses(text)
        }
    }

    Connections {
        target: root.wifiDevice
        enabled: root.wifiDevice !== null

        function onConnectedChanged(): void {
            if (root.wifiDevice && root.wifiDevice.connected)
                Qt.callLater(root.refreshAddress);
            else
                root.ipv4Address = "";
        }
    }

    Connections {
        target: Networking

        function onWifiEnabledChanged(): void {
            if (Networking.wifiEnabled && root._scanWhenEnabled) {
                root._scanWhenEnabled = false;
                root.beginScan();
            }
        }
    }

    Connections {
        target: root.pendingNetwork
        enabled: root.pendingNetwork !== null

        function onConnectionFailed(reason): void {
            root.errorMessage = root.failureText(reason);
        }

        function onStateChanged(): void {
            if (!root.pendingNetwork)
                return;
            if (root.pendingNetwork.connected) {
                root.errorMessage = "";
                root.pendingNetwork = null;
            }
        }
    }

    function setEnabled(value: bool): void {
        if (root.hardwareEnabled) {
            root._scanWhenEnabled = value;
            Networking.wifiEnabled = value;
        }
    }

    function beginScan(): void {
        if (root.wifiDevice && root.enabled)
            root.wifiDevice.scannerEnabled = true;
    }

    function endScan(): void {
        root._scanWhenEnabled = false;
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = false;
    }

    function refreshAddress(): void {
        if (!root.wifiDevice || !root.wifiDevice.connected) {
            root.ipv4Address = "";
            return;
        }
        addressQuery.exec(["ip", "-j", "address", "show", "dev", root.wifiDevice.name]);
    }

    function parseAddresses(output: string): void {
        try {
            const devices = JSON.parse(String(output || "[]"));
            if (devices.length === 0) {
                root.ipv4Address = "";
                return;
            }
            const addresses = devices[0].addr_info || [];
            const address = addresses.find(item => item.family === "inet" && item.scope === "global");
            root.ipv4Address = address ? address.local : "";
        } catch (error) {
            root.ipv4Address = "";
        }
    }

    function signalPercent(network): int {
        if (!network)
            return 0;
        const raw = network.signalStrength;
        return Math.round(Math.max(0, Math.min(100, raw <= 1 ? raw * 100 : raw)));
    }

    function isEnterprise(network): bool {
        if (!network)
            return false;
        return network.security === WifiSecurityType.Wpa2Eap
            || network.security === WifiSecurityType.WpaEap
            || network.security === WifiSecurityType.Leap;
    }

    function requiresPassword(network): bool {
        if (!network || network.known)
            return false;
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Owe;
    }

    function connectNetwork(network, password: string): bool {
        if (!network || network.stateChanging)
            return false;

        root.errorMessage = "";
        root.pendingNetwork = network;

        if (network.known || !root.requiresPassword(network)) {
            network.connect();
            return true;
        }

        if (root.isEnterprise(network)) {
            root.errorMessage = "Enterprise Wi-Fi requires the advanced connection editor.";
            root.pendingNetwork = null;
            return false;
        }

        if (password.length < 8) {
            root.errorMessage = "Enter the network password (at least 8 characters).";
            root.pendingNetwork = null;
            return false;
        }

        // The secret stays in QML memory and is passed directly over the
        // NetworkManager API. It is never included in a process argument.
        network.connectWithPsk(password);
        return true;
    }

    function disconnect(network): void {
        if (network)
            network.disconnect();
    }

    function forget(network): void {
        if (network)
            network.forget();
    }

    function openAdvanced(): void {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    function failureText(reason): string {
        if (reason === ConnectionFailReason.NoSecrets)
            return "NetworkManager needs a password for this network.";
        if (reason === ConnectionFailReason.WifiAuthTimeout)
            return "Authentication timed out. Check the password and try again.";
        if (reason === ConnectionFailReason.WifiNetworkLost)
            return "The network disappeared during connection.";
        return "Could not connect to the network.";
    }
}
