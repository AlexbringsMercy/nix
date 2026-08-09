// Aurora topbar — Clock/date/weather island's expanded panel. Composition follows
// ilyamiro's calendar/CalendarPopup.qml (repos/ilyamiro-nixos-configuration
// previews/screenshot2.png, guide/previews/preview_calendar.png): month grid, current
// time, short forecast strip. Backed by caelestia's Time and Weather services rather than
// ilyamiro's weather.sh polling. Weather detail lives here per GRAND_PLAN.md §5.4 — not a
// duplicate dashboard tab.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    readonly property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    readonly property var monthDays: {
        const first = new Date(viewYear, viewMonth, 1);
        // Monday-first weekday index (0 = Monday .. 6 = Sunday).
        const leading = (first.getDay() + 6) % 7;
        const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();

        const cells = [];
        for (let i = 0; i < leading; i++)
            cells.push(null);
        for (let d = 1; d <= daysInMonth; d++)
            cells.push(d);
        while (cells.length % 7 !== 0)
            cells.push(null);
        return cells;
    }

    spacing: Tokens.spacing.large

    // --- Month calendar ------------------------------------------------
    ColumnLayout {
        Layout.preferredWidth: 220
        spacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true

            IconButton {
                icon: "chevron_left"
                type: IconButton.Text
                onClicked: {
                    if (root.viewMonth === 0) {
                        root.viewMonth = 11;
                        root.viewYear -= 1;
                    } else {
                        root.viewMonth -= 1;
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }

            IconButton {
                icon: "chevron_right"
                type: IconButton.Text
                onClicked: {
                    if (root.viewMonth === 11) {
                        root.viewMonth = 0;
                        root.viewYear += 1;
                    } else {
                        root.viewMonth += 1;
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: Tokens.spacing.extraSmall
            columnSpacing: Tokens.spacing.extraSmall

            Repeater {
                model: [qsTr("Mo"), qsTr("Tu"), qsTr("We"), qsTr("Th"), qsTr("Fr"), qsTr("Sa"), qsTr("Su")]

                StyledText {
                    required property string modelData

                    Layout.preferredWidth: 26
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }

            Repeater {
                model: root.monthDays

                Item {
                    id: cell

                    required property var modelData

                    readonly property bool isToday: cell.modelData === root.today.getDate() && root.viewMonth === root.today.getMonth() && root.viewYear === root.today.getFullYear()

                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26

                    StyledRect {
                        anchors.fill: parent
                        visible: cell.isToday
                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: cell.modelData !== null
                        text: cell.modelData ?? ""
                        color: cell.isToday ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        font: Tokens.font.body.small
                    }
                }
            }
        }
    }

    StyledRect {
        Layout.fillHeight: true
        implicitWidth: 1
        color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
    }

    // --- Time + weather --------------------------------------------------
    ColumnLayout {
        Layout.preferredWidth: 240
        spacing: Tokens.spacing.small

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.timeStr
            font: Tokens.font.title.builders.large.width(90).build()
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.format("dddd, MMMM d")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.medium
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: Weather.icon
                fontStyle: Tokens.font.icon.large
                color: Colours.palette.m3tertiary
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: Weather.temp
                    font: Tokens.font.title.medium
                }

                StyledText {
                    text: Weather.description
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.small
            spacing: Tokens.spacing.large

            Stat {
                icon: "thermostat"
                label: qsTr("Feels")
                value: Weather.feelsLike
            }

            Stat {
                icon: "humidity_percentage"
                label: qsTr("Humid")
                value: `${Weather.humidity}%`
            }

            Stat {
                icon: "air"
                label: qsTr("Wind")
                value: `${Math.round(Weather.windSpeed)} km/h`
            }
        }

        RowLayout {
            Layout.topMargin: Tokens.spacing.medium
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: Weather.forecast.slice(0, 5)

                ColumnLayout {
                    id: dayCol

                    required property var modelData

                    Layout.fillWidth: true
                    spacing: Tokens.spacing.extraSmall

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(dayCol.modelData.date), "ddd")
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.small
                    }

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: dayCol.modelData.icon
                        color: Colours.palette.m3tertiary
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: `${Math.round(dayCol.modelData.maxTempC)}°`
                        font: Tokens.font.body.small
                    }
                }
            }
        }
    }

    component Stat: ColumnLayout {
        id: stat

        required property string icon
        required property string label
        required property string value

        spacing: 0

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: stat.icon
            fontStyle: Tokens.font.icon.small
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: stat.value
            font: Tokens.font.body.small
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: stat.label
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Tokens.font.body.small.pointSize - 1
        }
    }
}
