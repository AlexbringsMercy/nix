pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var history: []
    property var toasts: []
    property int unreadCount: 0
    readonly property bool dndEnabled: state.dndEnabled
    readonly property int historyLimit: 80

    property var _liveNotifications: ({})
    property var _expirationTimers: ({})
    property var _removeOnClose: ({})
    property var _refreshQueued: ({})

    signal notificationReceived(int id)
    signal notificationClosed(int id)
    signal dndChanged(bool enabled)

    PersistentProperties {
        id: state
        reloadableId: "aurora-notification-state"
        property bool dndEnabled: false
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: true

        onNotification: notification => root.receive(notification)
    }

    Component {
        id: expirationTimerFactory

        Timer {
            required property int notificationId
            repeat: false
            onTriggered: root.expireNotification(notificationId)
        }
    }

    function plainText(value): string {
        if (!value)
            return "";

        return String(value)
            .replace(/<br\s*\/?>/gi, "\n")
            .replace(/<[^>]*>/g, "")
            .replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .replace(/&#39;/g, "'");
    }

    function snapshot(notification): var {
        const actionList = [];
        for (const action of notification.actions) {
            actionList.push({
                identifier: action.identifier,
                text: root.plainText(action.text),
                object: action
            });
        }

        return {
            id: notification.id,
            appName: root.plainText(notification.appName) || "Application",
            appIcon: notification.appIcon || "",
            summary: root.plainText(notification.summary) || "Notification",
            body: root.plainText(notification.body),
            image: notification.image || "",
            urgency: notification.urgency,
            critical: notification.urgency === NotificationUrgency.Critical,
            transient: notification.transient,
            resident: notification.resident,
            hasInlineReply: notification.hasInlineReply,
            inlineReplyPlaceholder: root.plainText(notification.inlineReplyPlaceholder),
            actions: actionList,
            timestamp: Date.now(),
            live: true,
            unread: !notification.lastGeneration
        };
    }

    function receive(notification): void {
        notification.tracked = true;
        const id = notification.id;
        root._liveNotifications[id] = notification;

        notification.closed.connect(reason => root.handleClosed(id, reason));
        const queueRefresh = () => root.queueRefresh(id);
        notification.expireTimeoutChanged.connect(queueRefresh);
        notification.appNameChanged.connect(queueRefresh);
        notification.appIconChanged.connect(queueRefresh);
        notification.summaryChanged.connect(queueRefresh);
        notification.bodyChanged.connect(queueRefresh);
        notification.urgencyChanged.connect(queueRefresh);
        notification.actionsChanged.connect(queueRefresh);
        notification.residentChanged.connect(queueRefresh);
        notification.transientChanged.connect(queueRefresh);
        notification.imageChanged.connect(queueRefresh);
        notification.hasInlineReplyChanged.connect(queueRefresh);
        notification.inlineReplyPlaceholderChanged.connect(queueRefresh);

        const entry = root.snapshot(notification);
        const oldHistoryIndex = root.history.findIndex(item => item.id === id);

        if (!entry.transient) {
            const nextHistory = root.history.slice();
            if (oldHistoryIndex >= 0)
                nextHistory[oldHistoryIndex] = entry;
            else
                nextHistory.unshift(entry);
            root.history = nextHistory.slice(0, root.historyLimit);
        }

        root.recountUnread();

        // Notifications retained by keepOnReload already had their visual
        // presentation in the previous generation. Re-track them without a
        // duplicate toast or unread increment.
        if (!notification.lastGeneration && !root.dndEnabled) {
            const nextToasts = root.toasts.filter(item => item.id !== id);
            nextToasts.unshift(entry);
            root.toasts = nextToasts.slice(0, 4);
            root.armExpiration(notification);
        }

        root.notificationReceived(id);
    }

    function queueRefresh(id: int): void {
        if (root._refreshQueued[id])
            return;
        root._refreshQueued[id] = true;
        Qt.callLater(() => {
            delete root._refreshQueued[id];
            root.refreshNotification(id);
        });
    }

    function refreshNotification(id: int): void {
        const notification = root._liveNotifications[id];
        if (!notification)
            return;

        const entry = root.snapshot(notification);
        if (entry.transient) {
            root.history = root.history.filter(item => item.id !== id);
        } else {
            const nextHistory = root.history.slice();
            const index = nextHistory.findIndex(item => item.id === id);
            if (index >= 0)
                nextHistory[index] = entry;
            else
                nextHistory.unshift(entry);
            root.history = nextHistory.slice(0, root.historyLimit);
        }

        if (root.dndEnabled) {
            root.removeToast(id);
        } else {
            const nextToasts = root.toasts.filter(item => item.id !== id);
            nextToasts.unshift(entry);
            root.toasts = nextToasts.slice(0, 4);
            root.armExpiration(notification);
        }

        root.recountUnread();
        root.notificationReceived(id);
    }

    function armExpiration(notification): void {
        root.cancelExpiration(notification.id);

        // QuickShell forwards the freedesktop expire timeout in milliseconds.
        // Zero is explicitly persistent; a negative value asks the server for
        // its own default.
        let timeoutMs = 0;
        if (notification.expireTimeout > 0)
            timeoutMs = Math.round(notification.expireTimeout);
        else if (notification.expireTimeout < 0 && notification.urgency !== NotificationUrgency.Critical)
            timeoutMs = 7000;

        if (timeoutMs <= 0)
            return;

        const timer = expirationTimerFactory.createObject(root, {
            notificationId: notification.id,
            interval: timeoutMs
        });
        root._expirationTimers[notification.id] = timer;
        timer.start();
    }

    function cancelExpiration(id: int): void {
        const timer = root._expirationTimers[id];
        if (!timer)
            return;
        timer.stop();
        timer.destroy();
        delete root._expirationTimers[id];
    }

    function removeToast(id: int): void {
        root.cancelExpiration(id);
        root.toasts = root.toasts.filter(item => item.id !== id);
    }

    function expireNotification(id: int): void {
        root.removeToast(id);
        const notification = root._liveNotifications[id];
        if (notification)
            notification.expire();
    }

    function dismiss(id: int, removeFromHistory: bool): void {
        root._removeOnClose[id] = removeFromHistory;
        root.removeToast(id);

        const notification = root._liveNotifications[id];
        if (notification)
            notification.dismiss();
        else
            root.finishClose(id, removeFromHistory);
    }

    function handleClosed(id: int, reason): void {
        const remove = root._removeOnClose[id] === true;
        delete root._removeOnClose[id];
        root.finishClose(id, remove);
    }

    function finishClose(id: int, removeFromHistory: bool): void {
        root.removeToast(id);
        delete root._refreshQueued[id];
        delete root._liveNotifications[id];

        if (removeFromHistory) {
            root.history = root.history.filter(item => item.id !== id);
        } else {
            root.history = root.history.map(item => {
                if (item.id !== id)
                    return item;
                const updated = Object.assign({}, item);
                updated.live = false;
                updated.actions = [];
                updated.hasInlineReply = false;
                return updated;
            });
        }

        root.recountUnread();
        root.notificationClosed(id);
    }

    function invokeAction(id: int, identifier: string): void {
        const entry = root.history.find(item => item.id === id)
            || root.toasts.find(item => item.id === id);
        if (!entry || !entry.live)
            return;

        const action = entry.actions.find(item => item.identifier === identifier);
        if (action && action.object)
            action.object.invoke();
    }

    function sendInlineReply(id: int, text: string): void {
        const notification = root._liveNotifications[id];
        if (notification && text.trim() !== "")
            notification.sendInlineReply(text.trim());
    }

    function markAllRead(): void {
        root.history = root.history.map(item => {
            if (!item.unread)
                return item;
            const updated = Object.assign({}, item);
            updated.unread = false;
            return updated;
        });
        root.unreadCount = 0;
    }

    function recountUnread(): void {
        root.unreadCount = root.history.reduce((count, item) => count + (item.unread ? 1 : 0), 0);
    }

    function clearAll(): void {
        const ids = Object.keys(root._liveNotifications);
        root.history = [];
        root.toasts = [];
        root.unreadCount = 0;
        for (const idText of ids) {
            const id = Number(idText);
            root._removeOnClose[id] = true;
            root.cancelExpiration(id);
            const notification = root._liveNotifications[id];
            if (notification)
                notification.dismiss();
        }
    }

    function clearToasts(): void {
        for (const entry of root.toasts)
            root.cancelExpiration(entry.id);
        root.toasts = [];
    }

    function setDnd(enabled: bool): void {
        if (state.dndEnabled === enabled)
            return;
        state.dndEnabled = enabled;
        if (enabled)
            root.clearToasts();
        root.dndChanged(enabled);
    }

    function toggleDnd(): bool {
        root.setDnd(!root.dndEnabled);
        return root.dndEnabled;
    }

    function relativeTime(timestamp: real): string {
        const seconds = Math.max(0, Math.floor((Date.now() - timestamp) / 1000));
        if (seconds < 60)
            return "now";
        if (seconds < 3600)
            return Math.floor(seconds / 60) + "m";
        if (seconds < 86400)
            return Math.floor(seconds / 3600) + "h";
        return Math.floor(seconds / 86400) + "d";
    }
}
