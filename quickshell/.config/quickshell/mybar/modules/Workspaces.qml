import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Palette { id: pal }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Repeater {
            model: 10

            delegate: Item {
                required property int index
                property int wsId: index + 1
                property bool isActive: wsId === (Hyprland.focusedWorkspace?.id ?? -1)
                property bool isOccupied: {
                    const ws = Hyprland.workspaces.values.find(w => w.id === wsId)
                    return ws !== null && ws !== undefined && !isActive
                }

                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 14
                implicitHeight: 14

                Rectangle {
                    anchors.centerIn: parent

                    property real dotSize: isActive ? 10 : 7
                    width: dotSize
                    height: dotSize
                    radius: dotSize / 2

                    color: isActive    ? pal.primary
                         : isOccupied ? Qt.rgba(pal.on_surface.r, pal.on_surface.g, pal.on_surface.b, 0.55)
                         : "transparent"

                    border.color: (isActive || isOccupied) ? "transparent" : pal.outline
                    border.width: (isActive || isOccupied) ? 0 : 1.5

                    Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color  { ColorAnimation  { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
}
