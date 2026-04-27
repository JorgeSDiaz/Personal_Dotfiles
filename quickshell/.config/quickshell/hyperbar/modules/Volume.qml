import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../theme"

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Palette { id: pal }

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property bool muted: sink?.audio?.muted ?? false
    property real volume: sink?.audio?.volume ?? 0
    property bool hovered: false

    function volumeIcon(): string {
        if (muted || volume === 0) return "󰖁"
        if (volume < 0.33)        return "󰕿"
        if (volume < 0.66)        return "󰖀"
        return "󰕾"
    }

    Row {
        id: row
        spacing: root.hovered ? 6 : 0
        Behavior on spacing { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Text {
            id: iconTxt
            anchors.verticalCenter: parent.verticalCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: root.muted ? pal.outline : pal.on_surface
            text: root.volumeIcon()
            transformOrigin: Item.Center
            scale: root.hovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        Item {
            id: pctWrap
            anchors.verticalCenter: parent.verticalCenter
            height: pctTxt.implicitHeight
            width: root.hovered ? pctTxt.implicitWidth : 0
            opacity: root.hovered ? 1 : 0
            clip: true
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                id: pctTxt
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                color: root.muted ? pal.outline : pal.on_surface
                text: root.muted ? "Silencio" : (Math.round(Math.cbrt(root.volume) * 100) + "%")
            }
        }
    }
}
