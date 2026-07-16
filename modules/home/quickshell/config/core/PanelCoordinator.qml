pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property var knownPanels: [
        "notifications",
        "wifi",
        "bluetooth",
        "volume",
        "power",
        "music",
        "calendar"
    ]

    property string activePanel: ""

    signal panelOpened(string name)
    signal panelClosed(string name)

    function canonicalName(name: string): string {
        return name === "network" ? "wifi" : name;
    }

    function isKnown(name: string): bool {
        return root.knownPanels.indexOf(root.canonicalName(name)) !== -1;
    }

    function isOpen(name: string): bool {
        return root.activePanel === root.canonicalName(name);
    }

    function show(name: string): void {
        if (!root.isKnown(name)) {
            console.warn("Aurora panels: refusing unknown panel", name);
            return;
        }

        const canonical = root.canonicalName(name);
        if (root.activePanel === canonical)
            return;

        const previous = root.activePanel;
        root.activePanel = canonical;
        if (previous !== "")
            root.panelClosed(previous);
        root.panelOpened(canonical);
    }

    function hide(name: string): void {
        const canonical = root.canonicalName(name);
        if (canonical === "" || root.activePanel !== canonical)
            return;
        root.activePanel = "";
        root.panelClosed(canonical);
    }

    function toggle(name: string): void {
        const canonical = root.canonicalName(name);
        if (root.activePanel === canonical)
            root.hide(canonical);
        else
            root.show(canonical);
    }

    function close(): void {
        if (root.activePanel !== "")
            root.hide(root.activePanel);
    }
}
