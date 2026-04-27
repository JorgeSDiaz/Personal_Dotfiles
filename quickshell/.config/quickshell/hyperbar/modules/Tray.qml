import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                implicitWidth: 20
                implicitHeight: 20
                Layout.alignment: Qt.AlignVCenter

                Image {
                    anchors.centerIn: parent
                    source: modelData.icon
                    width: 16
                    height: 16
                    sourceSize: Qt.size(16, 16)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            modelData.activate()
                        else if (modelData.menu)
                            modelData.menu.open()
                    }
                }
            }
        }
    }
}
