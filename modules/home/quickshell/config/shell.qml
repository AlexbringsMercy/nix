//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import Quickshell.Io
import "core" as Core
import "services" as Services
import "panels/bluetooth" as Bluetooth
import "panels/calendar" as Calendar
import "panels/music" as Music
import "panels/network" as Network
import "panels/notifications" as Notifications
import "panels/power" as Power
import "panels/volume" as Volume

ShellRoot {
    id: root

    // Explicit references eagerly establish each singleton backend. Visual
    // panels themselves remain lazy and unload after their exit animation.
    readonly property var notificationBackend: Services.NotificationService
    readonly property var networkBackend: Services.NetworkService
    readonly property var bluetoothBackend: Services.BluetoothService
    readonly property var audioBackend: Services.AudioService
    readonly property var powerBackend: Services.PowerService
    readonly property var mediaBackend: Services.MprisService
    readonly property var weatherBackend: Services.WeatherService

    IpcHandler {
        target: "panels"

        function toggle(name: string): string {
            Core.PanelCoordinator.toggle(name);
            return Core.PanelCoordinator.activePanel;
        }

        function open(name: string): string {
            Core.PanelCoordinator.show(name);
            return Core.PanelCoordinator.activePanel;
        }

        function hide(name: string): string {
            Core.PanelCoordinator.hide(name);
            return Core.PanelCoordinator.activePanel;
        }

        function close(): void {
            Core.PanelCoordinator.close();
        }

        function status(): string {
            return Core.PanelCoordinator.activePanel;
        }
    }

    IpcHandler {
        target: "notifications"

        function toggleDnd(): bool {
            return Services.NotificationService.toggleDnd();
        }

        function status(): string {
            return Services.NotificationService.dndEnabled
                ? "dnd:on unread:" + Services.NotificationService.unreadCount
                : "dnd:off unread:" + Services.NotificationService.unreadCount;
        }

        function unreadCount(): int {
            return Services.NotificationService.unreadCount;
        }

        function clear(): void {
            Services.NotificationService.clearAll();
        }
    }

    Notifications.NotificationPanel {}
    Network.NetworkPanel {}
    Bluetooth.BluetoothPanel {}
    Volume.VolumePanel {}
    Power.PowerPanel {}
    Music.MusicPanel {}
    Calendar.CalendarPanel {}

    Notifications.ToastLayer {}
    Volume.VolumeOsd {}
}
