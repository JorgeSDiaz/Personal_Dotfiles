import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: sidebarRoot

    required property ShellScreen modelData
    property QtObject service: null

    screen: modelData
    anchors { top: true; right: true; bottom: true; left: true }
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay

    visible: (service?.sidebarOpen ?? false) || slideAnim.running

    Palette { id: pal }

    // Dismiss al clic fuera del sidebar
    MouseArea {
        anchors.fill: parent
        onClicked: if (service) service.sidebarOpen = false
    }

    // Contenedor principal con slide animation
    Rectangle {
        id: content
        anchors {
            top: parent.top;    topMargin: 4
            right: parent.right; rightMargin: 4
            bottom: parent.bottom; bottomMargin: 4
        }
        width: 360
        radius: 16
        color: pal.surface_container
        border.color: pal.outline_variant
        border.width: 1
        clip: true

        // Absorbe clics sobre el sidebar para que no lleguen al MouseArea de dismiss
        MouseArea { anchors.fill: parent }

        transform: [Translate {
            x: (service?.sidebarOpen ?? false) ? 0 : content.width + 8
            Behavior on x {
                NumberAnimation {
                    id: slideAnim
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }]

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ─── Header ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8

                Text {
                    text: "Red"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    color: pal.on_surface
                }

                Item { Layout.fillWidth: true }

                // Botón cerrar
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: closeHover.hovered ? pal.surface_container_high : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: pal.outline
                    }

                    HoverHandler { id: closeHover }
                    TapHandler { onTapped: if (service) service.sidebarOpen = false }
                }
            }

            // ─── Sección Wi-Fi toggle + rescan ─────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8
                spacing: 8

                Text {
                    text: "Wi-Fi"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    color: pal.on_surface
                    opacity: 0.7
                }

                Item { Layout.fillWidth: true }

                // Rescan button
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: rescanHover.hovered ? pal.surface_container_high : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        id: rescanIcon
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: pal.outline
                        transformOrigin: Item.Center
                        rotation: 0
                    }

                    RotationAnimation {
                        target: rescanIcon
                        running: service?.scanning ?? false
                        from: 0; to: 360
                        duration: 800
                        loops: Animation.Infinite
                    }

                    HoverHandler { id: rescanHover }
                    TapHandler { onTapped: if (service) service.rescan() }
                }

                // Switch Wi-Fi
                Rectangle {
                    id: wifiSwitch
                    property bool on_: service?.wifiEnabled ?? false

                    implicitWidth: 44
                    implicitHeight: 24
                    radius: 12
                    color: on_ ? pal.primary : pal.outline_variant
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        id: thumb
                        width: 18; height: 18
                        radius: 9
                        color: wifiSwitch.on_ ? pal.on_primary : pal.surface_container
                        anchors.verticalCenter: parent.verticalCenter
                        x: wifiSwitch.on_ ? parent.width - width - 3 : 3
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    TapHandler { onTapped: if (service) service.toggleWifi() }
                }
            }

            // ─── Tarjeta de conexión activa ────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8
                visible: (service?.connectionType ?? "none") !== "none"
                implicitHeight: visible ? connCard.implicitHeight : 0

                Rectangle {
                    id: connCard
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: connCol.implicitHeight + 20
                    radius: 10
                    color: pal.surface_container_high
                    border.color: pal.outline_variant
                    border.width: 1

                    ColumnLayout {
                        id: connCol
                        anchors { left: parent.left; right: parent.right; top: parent.top }
                        anchors.margins: 10
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: (service?.connectionType ?? "") === "ethernet" ? "󰈀" : "󰤨"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 15
                                color: pal.primary
                            }
                            Text {
                                Layout.fillWidth: true
                                text: service?.activeConnectionName ?? ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                                color: pal.on_surface
                                elide: Text.ElideRight
                            }
                            Text {
                                visible: (service?.connectionType ?? "") === "wifi"
                                text: (service?.activeSignal ?? 0) + "%"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                color: pal.outline
                            }
                        }

                        Repeater {
                            model: [
                                { label: "Dispositivo",  value: service?.activeDevice   ?? "" },
                                { label: "IP",           value: service?.activeIPv4     ?? "" },
                                { label: "Puerta enlace", value: service?.activeGateway ?? "" },
                                { label: "DNS",          value: service?.activeDns      ?? "" }
                            ]
                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                visible: modelData.value.length > 0
                                spacing: 8

                                Text {
                                    Layout.preferredWidth: 92
                                    text: modelData.label
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    color: pal.outline
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.value
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    color: pal.on_surface
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                implicitHeight: 1
                color: pal.outline_variant
                opacity: 0.5
            }

            // ─── Lista de APs ───────────────────────────────────────────────
            ListView {
                id: apList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                clip: true
                model: service?.accessPoints ?? []
                spacing: 0

                ScrollBar.vertical: ScrollBar {
                    policy: apList.contentHeight > apList.height
                        ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: NetworkAccessPointItem {
                    width: apList.width
                    service: sidebarRoot.service
                }

                // Reset estado al cerrar el sidebar
                Connections {
                    target: sidebarRoot.service
                    function onSidebarOpenChanged() {
                        if (!(sidebarRoot.service?.sidebarOpen ?? false))
                            apList.positionViewAtBeginning()
                    }
                }
            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                implicitHeight: 1
                color: pal.outline_variant
                opacity: 0.5
            }

            // ─── Footer ─────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                Layout.bottomMargin: 16
                implicitHeight: advBtn.implicitHeight

                Rectangle {
                    id: advBtn
                    implicitWidth: advRow.implicitWidth + 24
                    implicitHeight: 32
                    anchors.right: parent.right
                    radius: 8
                    color: advHover.hovered ? pal.surface_container_high : "transparent"
                    border.color: pal.outline_variant
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        id: advRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󱛅"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: pal.outline
                        }
                        Text {
                            text: "Configuración avanzada"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: pal.on_surface
                            opacity: 0.7
                        }
                    }

                    HoverHandler { id: advHover }
                    TapHandler {
                        onTapped: Quickshell.execDetached(["nm-connection-editor"])
                    }
                }
            }
        }
    }
}
