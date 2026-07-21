// Vendored from caelestia-dots/shell — components/controls/MenuItem.qml. Aurora build; local changes tracked in git.
import QtQuick

QtObject {
    required property string text
    property string icon
    property string trailingIcon
    property string activeIcon: icon
    property string activeText: text

    signal clicked
}
