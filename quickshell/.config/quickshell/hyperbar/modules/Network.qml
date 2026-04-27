import QtQuick
import "../theme"

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Palette { id: pal }

    property QtObject service: null
    property bool hovered: false

    // Derivados del service
    property string connectionType: service?.connectionType ?? "none"
    property string ssid:           service?.activeSsid    ?? ""
    property int    signalStrength: service?.activeSignal  ?? 0

    function netIcon(): string {
        if (connectionType === "ethernet") return "󰈀"
        if (connectionType === "wifi") {
            if (signalStrength >= 76) return "󰤨"
            if (signalStrength >= 51) return "󰤥"
            if (signalStrength >= 26) return "󰤢"
            return "󰤟"
        }
        return "󰤮"
    }

    Row {
        id: row
        spacing: root.hovered ? 6 : 0
        Behavior on spacing { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: root.connectionType === "none" ? pal.outline : pal.on_surface
            text: root.netIcon()
            transformOrigin: Item.Center
            scale: root.hovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            height: ssidTxt.implicitHeight
            width: (root.hovered && root.connectionType === "wifi" && root.ssid.length > 0)
                   ? ssidTxt.implicitWidth : 0
            opacity: (root.hovered && root.connectionType === "wifi") ? 1 : 0
            clip: true
            Behavior on width   { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                id: ssidTxt
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                color: pal.on_surface
                text: root.ssid
            }
        }
    }
}
