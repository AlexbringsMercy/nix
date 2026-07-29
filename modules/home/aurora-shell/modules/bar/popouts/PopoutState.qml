// Vendored from caelestia-dots/shell — modules/bar/popouts/PopoutState.qml. Aurora build; local changes tracked in git.
import QtQuick

QtObject {
    property string currentName
    property bool hasCurrent

    // Aurora: carries the hovered/clicked app-group's windows for the left
    // rail's grouped live-preview popout ("railgroup", see
    // modules/bar/components/AppRail.qml and popouts/RailGroupPreview.qml).
    // currentToplevelsHovered lets that popout report its own hover state back
    // so AppRail's close-debounce timer knows the pointer reached it.
    property var currentToplevels: []
    property bool currentToplevelsHovered: false

    signal detachRequested(mode: string)
}
