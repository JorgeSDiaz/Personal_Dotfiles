import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: popoverRoot

    required property ShellScreen modelData
    property QtObject service: null

    screen: modelData
    anchors { top: true; right: true; bottom: true; left: true }
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay

    visible: (service?.menuOpen ?? false) || openAnim.running

    Palette { id: pal }

    MouseArea {
        anchors.fill: parent
        onClicked: if (service) service.menuOpen = false
    }

    Rectangle {
        id: content
        anchors { top: parent.top; topMargin: 4; left: parent.left; leftMargin: 4 }
        width: 260
        height: col.implicitHeight + 16
        radius: 14
        color: pal.surface_container
        border.color: pal.outline_variant
        border.width: 1
        clip: true
        opacity: (service?.menuOpen ?? false) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        transform: [
            Scale {
                origin.x: 0
                origin.y: 0
                xScale: (service?.menuOpen ?? false) ? 1.0 : 0.92
                yScale: xScale
                Behavior on xScale {
                    NumberAnimation { id: openAnim; duration: 180; easing.type: Easing.OutCubic }
                }
            },
            Translate {
                y: (service?.menuOpen ?? false) ? 0 : -8
                Behavior on y {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }
        ]

        // Absorbe clics para que no burbujeen al MouseArea de dismiss
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 8
            spacing: 2

            readonly property var _actions: [
                { glyph: "󰌾", label: "Bloquear",      key: "lock",     destructive: false },
                { glyph: "󰍃", label: "Cerrar sesión", key: "logout",   destructive: false },
                { glyph: "󰜉", label: "Reiniciar",     key: "reboot",   destructive: true  },
                { glyph: "󰐥", label: "Apagar",        key: "shutdown", destructive: true  }
            ]

            Repeater {
                model: col._actions

                delegate: Rectangle {
                    required property var modelData

                    readonly property bool isPending: modelData.destructive &&
                        (popoverRoot.service?.pending ?? "") === modelData.key
                    readonly property bool otherPending: (popoverRoot.service?.pending ?? "") !== "" && !isPending

                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 10
                    clip: true

                    color: isPending
                        ? Qt.rgba(1.0, 0.71, 0.67, 0.18)
                        : (rowHover.hovered && !otherPending ? pal.surface_container_high : "transparent")
                    border.color: isPending ? pal.error : "transparent"
                    border.width: isPending ? 1 : 0
                    opacity: otherPending ? 0.35 : 1.0

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on opacity { NumberAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.glyph
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: modelData.destructive ? pal.error : pal.on_surface
                        }

                        Text {
                            Layout.fillWidth: true
                            text: isPending ? ("Confirmar: " + modelData.label) : modelData.label
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: modelData.destructive ? pal.error : pal.on_surface
                        }
                    }

                    HoverHandler { id: rowHover; enabled: !otherPending }

                    TapHandler {
                        enabled: !otherPending
                        onTapped: {
                            var svc = popoverRoot.service
                            if (!svc) return
                            if (modelData.key === "lock")          svc.lock()
                            else if (modelData.key === "logout")   svc.logout()
                            else if (modelData.key === "reboot")   svc.requestReboot()
                            else if (modelData.key === "shutdown") svc.requestShutdown()
                        }
                    }
                }
            }
        }
    }
}
