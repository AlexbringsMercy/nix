pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../core" as Core
import "../../services" as Services

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }
    margins {
        top: 54
        right: 12
    }

    implicitWidth: 390
    implicitHeight: Math.max(1, Math.min(620, toastList.contentHeight))
    visible: Services.NotificationService.toasts.length > 0 && !Services.NotificationService.dndEnabled
    color: "transparent"
    surfaceFormat.opaque: false
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:notification.toasts"

    ListView {
        id: toastList
        anchors.fill: parent
        spacing: Core.Tokens.spacingSm
        interactive: contentHeight > height
        model: Services.NotificationService.toasts
        verticalLayoutDirection: ListView.TopToBottom

        delegate: NotificationCard {
            required property var modelData
            width: ListView.view.width
            entry: modelData
            toast: true
            onDismissed: Services.NotificationService.dismiss(entry.id, false)
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Core.Motion.standard; easing.type: Core.Motion.easeOut }
                NumberAnimation { property: "x"; from: 42; to: 0; duration: Core.Motion.deliberate; easing.type: Core.Motion.easeExpressive }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: Core.Motion.fast }
                NumberAnimation { property: "x"; to: 34; duration: Core.Motion.standard; easing.type: Core.Motion.easeIn }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Core.Motion.standard; easing.type: Core.Motion.easeExpressive }
        }
    }
}
