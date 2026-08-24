import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int batteryLevel: 0
    property bool isCharging: false
    property bool available: false
    property bool showPopup: false

    readonly property color accentColor: "#c78bf5"

    implicitWidth: barButton.implicitWidth
    implicitHeight: barButton.implicitHeight

    Process {
        id: batteryProcess

        command: [
            "/usr/bin/python3",
            "/home/naoko/.config/omarchy/plugins/naoko.razer-battery/battery.py"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                const value = data.trim()

                if (value === "") {
                    root.available = false
                    return
                }

                const parts = value.split("|")

                if (parts.length < 2)
                    return

                const level = parseInt(parts[0])

                if (isNaN(level))
                    return

                root.batteryLevel = Math.min(
                    Math.max(level, 0),
                    100
                )

                root.isCharging = parts[1] === "1"
                root.available = true
            }
        }
    }

    // ----------------------------------------------------
    // CHECK EVERY 7 SECONDS
    // ----------------------------------------------------

    Timer {
        interval: 7000
        running: true
        repeat: true

        onTriggered: {
            if (!batteryProcess.running)
                batteryProcess.running = true
        }
    }

    // ----------------------------------------------------
    // BAR BUTTON
    // ----------------------------------------------------

    Rectangle {
        id: barButton

        implicitWidth: 34
        implicitHeight: 30

        radius: 6

        // No hover background
        color: "transparent"

        Text {
            anchors.centerIn: parent

            text: root.isCharging
                ? "󰚥"
                : "󰍽"

            font.family: "JetBrainsMono Nerd Font"

            font.pixelSize: root.isCharging
                ? 17
                : 14

            color: root.accentColor
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true

            onClicked: {
                root.showPopup = !root.showPopup
            }
        }
    }

    // ----------------------------------------------------
    // BATTERY POPUP
    // ----------------------------------------------------

    Rectangle {
        id: popup

        visible: root.showPopup

        z: 9999

        width: 250
        height: 145

        radius: 12

        color: "#0b0918"

        border.width: 1
        border.color: "#313244"

        anchors.top: barButton.bottom
        anchors.topMargin: 8
        anchors.right: barButton.right

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15

            spacing: 9

            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.isCharging
                        ? "󰚥"
                        : "󰍽"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: root.isCharging
                        ? 19
                        : 16

                    color: root.accentColor
                }

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: "Razer DeathAdder V2 Pro"

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true

                        color: root.accentColor
                    }

                    Text {
                        text: root.isCharging
                            ? "Charging"
                            : root.available
                                ? "Connected"
                                : "Unavailable"

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10

                        color: root.accentColor
                        opacity: 0.7
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.available
                        ? root.batteryLevel + "%"
                        : "--%"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true

                    color: root.accentColor
                }
            }

            // ------------------------------------------------
            // BATTERY BAR
            // ------------------------------------------------

            Rectangle {
                Layout.fillWidth: true

                height: 10

                radius: 5

                color: Qt.rgba(
                    199 / 255,
                    139 / 255,
                    245 / 255,
                    0.15
                )

                clip: true

                Rectangle {
                    width: parent.width * (
                        Math.min(
                            Math.max(
                                root.batteryLevel,
                                0
                            ),
                            100
                        ) / 100
                    )

                    height: parent.height

                    radius: parent.radius

                    color: root.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 250
                        }
                    }
                }
            }

            // ------------------------------------------------
            // DETAILS
            // ------------------------------------------------

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Battery"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11

                    color: root.accentColor
                    opacity: 0.7
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.available
                        ? root.batteryLevel + "%"
                        : "Unavailable"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11

                    color: root.accentColor
                }
            }

            // ------------------------------------------------
            // STATUS
            // ------------------------------------------------

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.isCharging
                        ? "⚡ Charging"
                        : "● Battery"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10

                    color: root.accentColor
                    opacity: 0.8
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "DeathAdder V2 Pro"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10

                    color: root.accentColor
                    opacity: 0.5
                }
            }
        }
    }
}
