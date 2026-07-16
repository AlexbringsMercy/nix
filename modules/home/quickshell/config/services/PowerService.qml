pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryReady: battery && battery.ready && battery.isPresent
    readonly property real batteryLevel: batteryReady ? Math.max(0, Math.min(1, battery.percentage)) : 0
    readonly property int batteryPercent: Math.round(batteryLevel * 100)
    readonly property bool charging: batteryReady && (battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge)
    readonly property bool onBattery: UPower.onBattery
    readonly property int activeProfile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile

    property real brightness: 0.5
    property bool brightnessReady: false
    property string brightnessError: ""
    property real _requestedBrightness: 0.5

    Component.onCompleted: refreshBrightness()

    Process {
        id: brightnessRead
        command: ["brightnessctl", "--device=intel_backlight", "-m"]
        stdout: SplitParser {
            onRead: data => root.parseBrightness(data)
        }
        onExited: (code, status) => {
            if (code !== 0)
                root.brightnessError = "Brightness control is unavailable.";
        }
    }

    Timer {
        id: brightnessWriteDelay
        interval: 60
        repeat: false
        onTriggered: {
            const percent = Math.round(root._requestedBrightness * 100);
            brightnessWrite.exec(["brightnessctl", "--device=intel_backlight", "set", percent + "%"]);
        }
    }

    Process {
        id: brightnessWrite
        onExited: (code, status) => {
            if (code !== 0)
                root.brightnessError = "Could not change display brightness.";
        }
    }

    Timer {
        id: regionCaptureDelay
        interval: 300
        repeat: false
        onTriggered: Quickshell.execDetached(["screenshot-area"])
    }

    Timer {
        id: screenCaptureDelay
        interval: 300
        repeat: false
        onTriggered: Quickshell.execDetached(["screenshot-full"])
    }

    function refreshBrightness(): void {
        if (!brightnessRead.running)
            brightnessRead.running = true;
    }

    function parseBrightness(line: string): void {
        const fields = line.trim().split(",");
        if (fields.length < 5)
            return;
        const parsed = Number(fields[3].replace("%", ""));
        if (isNaN(parsed))
            return;
        root.brightness = Math.max(0.02, Math.min(1, parsed / 100));
        root._requestedBrightness = root.brightness;
        root.brightnessReady = true;
        root.brightnessError = "";
    }

    function setBrightness(value: real): void {
        const clamped = Math.max(0.02, Math.min(1, value));
        root._requestedBrightness = clamped;
        root.brightness = clamped;
        brightnessWriteDelay.restart();
    }

    function profileName(profile: int): string {
        if (profile === PowerProfile.PowerSaver)
            return "Power saver";
        if (profile === PowerProfile.Performance)
            return "Performance";
        return "Balanced";
    }

    function setProfile(profile: int): void {
        if (profile === PowerProfile.Performance && !root.hasPerformanceProfile)
            return;
        PowerProfiles.profile = profile;
    }

    function setPowerSaver(): void {
        root.setProfile(PowerProfile.PowerSaver);
    }

    function setBalanced(): void {
        root.setProfile(PowerProfile.Balanced);
    }

    function setPerformance(): void {
        root.setProfile(PowerProfile.Performance);
    }

    function lock(): void {
        Quickshell.execDetached(["hyprlock"]);
    }

    function openWallpaperPicker(): void {
        Quickshell.execDetached(["waypaper"]);
    }

    function captureRegion(): void {
        regionCaptureDelay.restart();
    }

    function captureScreen(): void {
        screenCaptureDelay.restart();
    }

    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function powerOff(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
}
