import QtQuick
import "../theme"

Item {
    id: root

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Palette { id: pal }

    property QtObject service: null
    property bool hovered: false

    readonly property bool active: service?.menuOpen ?? false

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        text: "󰐥"
        color: (root.hovered || root.active) ? pal.error : pal.on_surface
        Behavior on color { ColorAnimation { duration: 150 } }
        transformOrigin: Item.Center
        scale: root.hovered ? 1.15 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
}
