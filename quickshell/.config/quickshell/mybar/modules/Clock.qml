import QtQuick
import Quickshell
import "../theme"

Item {
    implicitWidth: label.implicitWidth + 24
    implicitHeight: label.implicitHeight

    property bool showDate: false

    Palette { id: pal }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.weight: Font.Bold
        color: pal.tertiary

        text: {
            if (!clock.date) return "󱑎 --:--"
            return showDate
                ? "󰃭 " + Qt.formatDateTime(clock.date, "dddd dd MMM yyyy")
                : "󱑎 " + Qt.formatDateTime(clock.date, "HH:mm")
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: showDate = !showDate
    }
}
