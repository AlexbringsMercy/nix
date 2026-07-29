// Aurora build; no upstream counterpart. Card shape modelled directly on
// caelestia-dots/shell — modules/utilities/cards/Record.qml.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property var props
    readonly property real nonAnimHeight: layout.implicitHeight + layout.anchors.margins * 2

    implicitHeight: nonAnimHeight

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer

    RowLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        StyledRect {
            implicitWidth: implicitHeight
            implicitHeight: {
                const h = icon.implicitHeight + Tokens.padding.small * 2;
                return h - (h % 2);
            }

            radius: Tokens.rounding.full
            color: Colours.palette.m3secondaryContainer

            MaterialIcon {
                id: icon

                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: "screenshot_region"
                color: Colours.palette.m3onSecondaryContainer
                fontStyle: Tokens.font.icon.large
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Screenshot")
                font: Tokens.font.body.medium
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Clipboard + ~/Pictures/Screenshots")
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }
        }

        SplitButton {
            active: menuItems.find(m => root.props.screenshotMode === m.icon + m.text) ?? menuItems[0]
            menu.onItemSelected: item => root.props.screenshotMode = item.icon + item.text

            // captureFromUi, not capture: this drawer is on screen and must be
            // gone before the frame is taken.
            menuItems: [
                MenuItem {
                    icon: "screenshot_region"
                    text: qsTr("Capture region")
                    activeText: qsTr("Region")
                    onClicked: Screenshotter.captureFromUi("region")
                },
                MenuItem {
                    icon: "fullscreen"
                    text: qsTr("Capture full screen")
                    activeText: qsTr("Full screen")
                    onClicked: Screenshotter.captureFromUi("full")
                },
                MenuItem {
                    icon: "ac_unit"
                    text: qsTr("Capture frozen region")
                    activeText: qsTr("Frozen")
                    onClicked: Screenshotter.captureFromUi("frozen")
                },
                MenuItem {
                    icon: "content_copy"
                    text: qsTr("Capture region to clipboard only")
                    activeText: qsTr("Clipboard")
                    onClicked: Screenshotter.captureFromUi("clipboard")
                }
            ]
        }
    }
}
