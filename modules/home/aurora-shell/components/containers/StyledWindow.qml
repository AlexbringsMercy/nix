// Vendored from caelestia-dots/shell — components/containers/StyledWindow.qml. Aurora build; local changes tracked in git.
import Quickshell
import Quickshell.Wayland
import Caelestia.Config

// qmllint disable uncreatable-type
PanelWindow {
    // qmllint enable uncreatable-type
    required property string name

    WlrLayershell.namespace: `caelestia-${name}`
    color: "transparent"

    contentItem.Config.screen: screen.name
    contentItem.Tokens.screen: screen.name
}
