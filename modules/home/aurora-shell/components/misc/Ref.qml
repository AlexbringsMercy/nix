// Vendored from caelestia-dots/shell — components/misc/Ref.qml. Aurora build; local changes tracked in git.
import QtQuick

QtObject {
    required property var service

    Component.onCompleted: service.refCount++
    Component.onDestruction: service.refCount--
}
