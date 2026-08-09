// Aurora topbar — Battery island's expanded panel: percentage/time/profile fast controls,
// per GRAND_PLAN.md §5.2. Service bindings carried from caelestia-dots/shell modules/bar/
// popouts/Battery.qml (Quickshell.Services.UPower). ilyamiro's full battery ring +
// brightness/volume + lock/sleep/restart/power composition (repos/ilyamiro-nixos-
// configuration previews/screenshot7.png, .../battery/BatteryPopup.qml) is the "expanded
// ilyamiro battery presentation" depth tier the plan names as a later layer — this ships
// the fast-control tier this pass; see the Stage 3 progress report.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    readonly property bool hasBattery: UPower.displayDevice.isLaptopBattery

    width: 280
    spacing: Tokens.spacing.medium

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.large

        CircularProgress {
            visible: root.hasBattery
            implicitSize: 84
            strokeWidth: Tokens.padding.small
            startAngle: -225
            sweepAngle: 270
            value: UPower.displayDevice.percentage
            fgColour: UPower.onBattery && UPower.displayDevice.percentage < 0.2 ? Colours.palette.m3error : Colours.palette.m3primary

            Behavior on clampedVal {
                Anim {}
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                    font: Tokens.font.title.builders.large.width(90).build()
                    color: Colours.palette.m3primary
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            StyledText {
                text: root.hasBattery ? qsTr("Remaining: %1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("No battery detected")
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }

            StyledText {
                text: {
                    if (!root.hasBattery)
                        return qsTr("Power profile: %1").arg(PowerProfile.toString(PowerProfiles.profile));

                    const seconds = UPower.onBattery ? UPower.displayDevice.timeToEmpty : UPower.displayDevice.timeToFull;
                    const hr = Math.floor(seconds / 3600);
                    const min = Math.floor(seconds / 60) % 60;
                    const label = UPower.onBattery ? qsTr("remaining") : qsTr("until charged");
                    if (seconds <= 0)
                        return UPower.onBattery ? qsTr("Calculating…") : qsTr("Fully charged");
                    return qsTr("%1h %2m %3").arg(hr).arg(min).arg(label);
                }
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                wrapMode: Text.WordWrap
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        active: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        visible: active

        sourceComponent: StyledRect {
            implicitWidth: parent?.width ?? 0
            implicitHeight: warnRow.implicitHeight + Tokens.padding.medium
            color: Colours.palette.m3error
            radius: Tokens.rounding.large

            RowLayout {
                id: warnRow

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "warning"
                    color: Colours.palette.m3onError
                }

                StyledText {
                    text: qsTr("Performance degraded: %1").arg(PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
                    color: Colours.palette.m3onError
                    font: Tokens.font.body.small
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    StyledText {
        text: qsTr("Power profile")
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        ProfileButton {
            Layout.fillWidth: true
            profile: PowerProfile.PowerSaver
            icon: "energy_savings_leaf"
            label: qsTr("Saver")
        }

        ProfileButton {
            Layout.fillWidth: true
            profile: PowerProfile.Balanced
            icon: "balance"
            label: qsTr("Balance")
        }

        ProfileButton {
            Layout.fillWidth: true
            profile: PowerProfile.Performance
            icon: "rocket_launch"
            label: qsTr("Perform")
        }
    }

    component ProfileButton: StyledRect {
        id: btn

        required property int profile
        required property string icon
        required property string label

        readonly property bool active: PowerProfiles.profile === btn.profile

        implicitHeight: btnLayout.implicitHeight + Tokens.padding.medium
        radius: Tokens.rounding.large
        color: btn.active ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainer

        StateLayer {
            color: btn.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            onClicked: PowerProfiles.profile = btn.profile
        }

        ColumnLayout {
            id: btnLayout

            anchors.centerIn: parent
            spacing: Tokens.spacing.extraSmall

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: btn.icon
                fill: btn.active ? 1 : 0
                color: btn.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: btn.label
                font: Tokens.font.body.small
                color: btn.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            }
        }
    }
}
