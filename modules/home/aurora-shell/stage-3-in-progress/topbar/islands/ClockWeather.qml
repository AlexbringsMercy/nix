// Aurora topbar — centred clock/date/weather island. Composition (time left, weather
// icon+temp right, centred in the bar) is ilyamiro's TopBar.qml centerBox nearly 1:1;
// data from caelestia's Time/Weather services rather than his date +typewriter/weather.sh
// scripts. Click expands the calendar/forecast surface (panels/ClockWeatherPanel.qml).
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Pill {
    id: root

    required property var expansion

    onClicked: root.expansion.toggle("clockweather", root, null)

    ColumnLayout {
        spacing: -2

        StyledText {
            text: Time.timeStr
            font: Tokens.font.body.builders.medium.weight(Font.Black).build()
        }

        StyledText {
            text: Time.format("dddd, MMM d")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    StyledRect {
        implicitWidth: 1
        implicitHeight: 22
        color: Qt.alpha(Colours.palette.m3onSurface, 0.12)
    }

    RowLayout {
        spacing: Tokens.spacing.extraSmall

        MaterialIcon {
            text: Weather.icon
            color: Colours.palette.m3tertiary
        }

        StyledText {
            text: Weather.temp
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
        }
    }
}
