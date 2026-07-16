pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import "../../core" as Core
import "../../services" as Services
import "../music" as Music

Core.PanelHost {
    id: panel

    panelName: "calendar"
    panelWidth: 720
    panelHeight: 790
    topMargin: 54
    rightMargin: 82
    layerNamespace: "aurora-panel-calendar"

    onOpened: Services.WeatherService.refresh(false)

    Item {
        id: content
        anchors.fill: parent

        property date now: new Date()
        property int displayYear: now.getFullYear()
        property int displayMonth: now.getMonth()
        property date selectedDate: new Date(now.getFullYear(), now.getMonth(), now.getDate())
        property real introClock: 0
        property real introCalendar: 0
        property real introWeather: 0
        property real introTimeline: 0
        property real introForecast: 0

        readonly property var monthNames: [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        readonly property var weekdayNames: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        readonly property var dayCells: buildMonth(displayYear, displayMonth)

        function sameDay(left, right) {
            return left.getFullYear() === right.getFullYear()
                && left.getMonth() === right.getMonth()
                && left.getDate() === right.getDate();
        }

        function buildMonth(year, month) {
            const first = new Date(year, month, 1);
            const mondayOffset = (first.getDay() + 6) % 7;
            const cells = [];
            for (let index = 0; index < 42; index++) {
                const date = new Date(year, month, 1 - mondayOffset + index);
                cells.push({
                    date: date,
                    day: date.getDate(),
                    inMonth: date.getMonth() === month,
                    today: sameDay(date, now),
                    selected: sameDay(date, selectedDate)
                });
            }
            return cells;
        }

        function moveMonth(delta) {
            const date = new Date(displayYear, displayMonth + delta, 1);
            displayYear = date.getFullYear();
            displayMonth = date.getMonth();
        }

        function returnToday() {
            now = new Date();
            displayYear = now.getFullYear();
            displayMonth = now.getMonth();
            selectedDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        }

        function conditionLabel(code) {
            if (code === 0) return "Clear";
            if (code <= 2) return "Partly cloudy";
            if (code === 3) return "Overcast";
            if (code === 45 || code === 48) return "Fog";
            if (code >= 51 && code <= 57) return "Drizzle";
            if (code >= 61 && code <= 67) return "Rain";
            if (code >= 71 && code <= 77) return "Snow";
            if (code >= 80 && code <= 82) return "Showers";
            if (code >= 85 && code <= 86) return "Snow showers";
            if (code >= 95) return "Thunderstorm";
            return "Conditions";
        }

        function conditionIcon(code, daylight) {
            if (code === 0) return daylight === false ? "󰖔" : "󰖙";
            if (code <= 2) return daylight === false ? "󰼱" : "󰖕";
            if (code === 3) return "󰖐";
            if (code === 45 || code === 48) return "󰖑";
            if (code >= 51 && code <= 67) return "󰖗";
            if (code >= 71 && code <= 77) return "󰖘";
            if (code >= 80 && code <= 86) return "󰖖";
            if (code >= 95) return "󰙾";
            return "󰖐";
        }

        function hourLabel(isoTime) {
            const hour = Number(String(isoTime || "").split("T")[1]?.slice(0, 2));
            if (!isFinite(hour)) return "--";
            const suffix = hour >= 12 ? "PM" : "AM";
            const display = hour % 12 || 12;
            return display + suffix;
        }

        function shortDate(date) {
            return Qt.formatDate(date, "ddd, MMM d");
        }

        Component.onCompleted: stagedIntro.restart()

        Music.ThemeBridge { id: theme }

        Timer {
            interval: 1000
            repeat: true
            running: panel.requestedOpen
            triggeredOnStart: true
            onTriggered: content.now = new Date()
        }

        ParallelAnimation {
            id: stagedIntro
            NumberAnimation {
                target: content; property: "introClock"
                from: 0; to: 1; duration: Core.Motion.staged
                easing.type: Easing.OutBack; easing.overshoot: 0.65
            }
            SequentialAnimation {
                PauseAnimation { duration: 100 }
                NumberAnimation {
                    target: content; property: "introCalendar"
                    from: 0; to: 1; duration: Core.Motion.staged
                    easing.type: Core.Motion.easeExpressive
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 180 }
                NumberAnimation {
                    target: content; property: "introWeather"
                    from: 0; to: 1; duration: Core.Motion.staged
                    easing.type: Easing.OutBack; easing.overshoot: 0.55
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 300 }
                NumberAnimation {
                    target: content; property: "introTimeline"
                    from: 0; to: 1; duration: Core.Motion.staged
                    easing.type: Core.Motion.easeExpressive
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 440 }
                NumberAnimation {
                    target: content; property: "introForecast"
                    from: 0; to: 1; duration: Core.Motion.deliberate
                    easing.type: Easing.OutBack; easing.overshoot: 0.5
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Core.Tokens.radiusLarge
            color: Qt.rgba(theme.panel.r, theme.panel.g, theme.panel.b, 0.91)
            border.width: 1
            border.color: theme.outlineStrong
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.2; color: theme.tertiary }
                    GradientStop { position: 0.5; color: theme.primary }
                    GradientStop { position: 0.82; color: theme.secondary }
                    GradientStop { position: 1; color: "transparent" }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    spacing: 18
                    opacity: content.introClock
                    transform: Translate { y: -18 * (1 - content.introClock) }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -3
                        Text {
                            text: Qt.formatTime(content.now, "hh:mm:ss")
                            color: theme.text
                            font.family: Core.Tokens.monoFont
                            font.pixelSize: 52
                            font.weight: Font.Light
                        }
                        Text {
                            text: Qt.formatDate(content.now, "dddd, MMMM d")
                            color: theme.textMuted
                            font.family: Core.Tokens.uiFont
                            font.pixelSize: 15
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 238
                        Layout.fillHeight: true
                        radius: Core.Tokens.radius
                        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.54)
                        border.width: 1
                        border.color: theme.outline

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12
                            Text {
                                text: content.conditionIcon(Number(Services.WeatherService.current.weather_code || -1), Services.WeatherService.current.is_day)
                                color: theme.primary
                                font.family: Core.Tokens.iconFont
                                font.pixelSize: 42
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    text: isFinite(Number(Services.WeatherService.current.temperature))
                                        ? Math.round(Number(Services.WeatherService.current.temperature)) + "°"
                                        : "--°"
                                    color: theme.text
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 29
                                    font.weight: Font.Bold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: content.conditionLabel(Number(Services.WeatherService.current.weather_code || -1))
                                    color: theme.textMuted
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: Services.WeatherService.location
                                    color: theme.textDim
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 414
                        Layout.fillHeight: true
                        radius: Core.Tokens.radius
                        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.45)
                        border.width: 1
                        border.color: theme.outline
                        opacity: content.introCalendar
                        transform: Translate { x: -26 * (1 - content.introCalendar) }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Button {
                                    implicitWidth: 34; implicitHeight: 34
                                    hoverEnabled: true
                                    onClicked: content.moveMonth(-1)
                                    background: Rectangle {
                                        radius: Core.Tokens.radiusSmall
                                        color: parent.hovered ? theme.surfaceHover : "transparent"
                                    }
                                    contentItem: Text {
                                        text: "󰅁"; color: theme.textMuted
                                        font.family: Core.Tokens.iconFont; font.pixelSize: 18
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: -2
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: content.monthNames[content.displayMonth]
                                        color: theme.text
                                        font.family: Core.Tokens.uiFont
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: content.displayYear
                                        color: theme.textDim
                                        font.family: Core.Tokens.monoFont
                                        font.pixelSize: 11
                                    }
                                }
                                Button {
                                    implicitWidth: 34; implicitHeight: 34
                                    hoverEnabled: true
                                    onClicked: content.moveMonth(1)
                                    background: Rectangle {
                                        radius: Core.Tokens.radiusSmall
                                        color: parent.hovered ? theme.surfaceHover : "transparent"
                                    }
                                    contentItem: Text {
                                        text: "󰅂"; color: theme.textMuted
                                        font.family: Core.Tokens.iconFont; font.pixelSize: 18
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 7
                                columnSpacing: 4
                                Repeater {
                                    model: content.weekdayNames
                                    Text {
                                        required property string modelData
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData
                                        color: theme.textDim
                                        font.family: Core.Tokens.monoFont
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 7
                                rows: 6
                                columnSpacing: 4
                                rowSpacing: 4

                                Repeater {
                                    model: content.dayCells
                                    Button {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        hoverEnabled: true
                                        onClicked: {
                                            content.selectedDate = modelData.date;
                                            if (!modelData.inMonth) {
                                                content.displayYear = modelData.date.getFullYear();
                                                content.displayMonth = modelData.date.getMonth();
                                            }
                                        }
                                        background: Rectangle {
                                            radius: 9
                                            color: modelData.selected
                                                ? theme.tertiary
                                                : (parent.hovered ? theme.surfaceHover : "transparent")
                                            border.width: modelData.today && !modelData.selected ? 1 : 0
                                            border.color: theme.secondary
                                            scale: parent.down ? 0.91 : 1
                                            Behavior on scale { NumberAnimation { duration: Core.Motion.fast; easing.type: Core.Motion.easeOut } }
                                            Behavior on color { ColorAnimation { duration: Core.Motion.fast } }
                                        }
                                        contentItem: Text {
                                            text: parent.modelData.day
                                            color: parent.modelData.selected
                                                ? theme.onAccent
                                                : (parent.modelData.inMonth ? theme.text : theme.textDim)
                                            opacity: parent.modelData.inMonth ? 1 : 0.52
                                            font.family: Core.Tokens.uiFont
                                            font.pixelSize: 12
                                            font.weight: parent.modelData.today || parent.modelData.selected ? Font.Bold : Font.Normal
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "Selected · " + content.shortDate(content.selectedDate)
                                    color: theme.textDim
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 11
                                }
                                Button {
                                    implicitWidth: 58; implicitHeight: 27
                                    hoverEnabled: true
                                    onClicked: content.returnToday()
                                    background: Rectangle {
                                        radius: 7
                                        color: parent.hovered ? theme.surfaceHover : theme.surface
                                        border.width: 1; border.color: theme.outline
                                    }
                                    contentItem: Text {
                                        text: "Today"; color: theme.textMuted
                                        font.family: Core.Tokens.uiFont; font.pixelSize: 10; font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10
                        opacity: content.introWeather
                        transform: Translate { x: 28 * (1 - content.introWeather) }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 148
                            radius: Core.Tokens.radius
                            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.45)
                            border.width: 1
                            border.color: theme.outline

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "CURRENT CONDITIONS"
                                        color: theme.text
                                        font.family: Core.Tokens.monoFont
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                    Item { Layout.fillWidth: true }
                                    Button {
                                        implicitWidth: 28; implicitHeight: 28
                                        hoverEnabled: true
                                        enabled: !Services.WeatherService.loading
                                        onClicked: Services.WeatherService.refresh(true)
                                        background: Rectangle {
                                            radius: 7
                                            color: parent.hovered ? theme.surfaceHover : "transparent"
                                        }
                                        contentItem: Text {
                                            text: Services.WeatherService.loading ? "󰑓" : "󰑐"
                                            color: theme.primary
                                            font.family: Core.Tokens.iconFont
                                            font.pixelSize: 15
                                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                        }
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Refresh weather"
                                    }
                                }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 16
                                    rowSpacing: 7
                                    Repeater {
                                        model: [
                                            { icon: "󰔏", label: "Feels", value: Math.round(Number(Services.WeatherService.current.apparent_temperature || 0)) + "°" },
                                            { icon: "󰖌", label: "Humidity", value: Math.round(Number(Services.WeatherService.current.humidity || 0)) + "%" },
                                            { icon: "󰖝", label: "Wind", value: Math.round(Number(Services.WeatherService.current.wind_speed || 0)) + " mph" },
                                            { icon: "󰖗", label: "Rain", value: Number(Services.WeatherService.current.precipitation || 0).toFixed(2) + " in" }
                                        ]
                                        RowLayout {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            spacing: 6
                                            Text {
                                                text: modelData.icon; color: theme.secondary
                                                font.family: Core.Tokens.iconFont; font.pixelSize: 14
                                            }
                                            ColumnLayout {
                                                spacing: -2
                                                Text {
                                                    text: modelData.label; color: theme.textDim
                                                    font.family: Core.Tokens.uiFont; font.pixelSize: 9
                                                }
                                                Text {
                                                    text: modelData.value; color: theme.textMuted
                                                    font.family: Core.Tokens.monoFont; font.pixelSize: 11; font.weight: Font.DemiBold
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Core.Tokens.radius
                            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.45)
                            border.width: 1
                            border.color: theme.outline

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 13
                                spacing: 6
                                Text {
                                    text: "5-DAY OUTLOOK"
                                    color: theme.text
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                                Repeater {
                                    model: Services.WeatherService.daily.slice(0, 5)
                                    RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        opacity: content.introForecast
                                        transform: Translate { x: 16 * (1 - content.introForecast) }
                                        Text {
                                            Layout.preferredWidth: 42
                                            text: Qt.formatDate(new Date(modelData.date + "T12:00:00"), "ddd")
                                            color: theme.textMuted
                                            font.family: Core.Tokens.uiFont
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                        }
                                        Text {
                                            text: content.conditionIcon(Number(modelData.weather_code || -1), true)
                                            color: theme.primary
                                            font.family: Core.Tokens.iconFont
                                            font.pixelSize: 17
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: Math.round(Number(modelData.low || 0)) + "°"
                                            color: theme.textDim
                                            font.family: Core.Tokens.monoFont
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: Math.round(Number(modelData.high || 0)) + "°"
                                            color: theme.text
                                            font.family: Core.Tokens.monoFont
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: Services.WeatherService.error !== ""
                                    text: Services.WeatherService.error
                                    color: theme.warning
                                    font.family: Core.Tokens.uiFont
                                    font.pixelSize: 9
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    radius: Core.Tokens.radius
                    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.45)
                    border.width: 1
                    border.color: theme.outline
                    opacity: content.introTimeline
                    transform: Translate { y: 20 * (1 - content.introTimeline) }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        Repeater {
                            model: Services.WeatherService.hourly.slice(0, 8)
                            ColumnLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: content.hourLabel(modelData.time)
                                    color: theme.textDim
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 9
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: content.conditionIcon(Number(modelData.weather_code || -1), Boolean(modelData.is_day))
                                    color: theme.primary
                                    font.family: Core.Tokens.iconFont
                                    font.pixelSize: 18
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: Math.round(Number(modelData.temperature || 0)) + "°"
                                    color: theme.text
                                    font.family: Core.Tokens.monoFont
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 4
                                    height: Math.max(3, Number(modelData.precipitation_probability || 0) * 0.22)
                                    radius: 2
                                    color: theme.secondary
                                    opacity: 0.8
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
