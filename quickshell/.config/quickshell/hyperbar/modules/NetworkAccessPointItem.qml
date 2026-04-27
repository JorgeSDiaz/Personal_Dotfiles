import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    required property var modelData
    property QtObject service: null

    property string ssid:     modelData.ssid     ?? ""
    property int    signal_:  modelData.signal    ?? 0   // signal es keyword QML, usar signal_
    property string security: modelData.security  ?? ""
    property bool   active:   modelData.active    ?? false

    property bool askingPassword: false
    property bool connectFailed:  false

    implicitWidth:  row.implicitWidth
    implicitHeight: col.implicitHeight

    Palette { id: pal }

    // Escuchar señales del service para este AP
    Connections {
        target: root.service
        function onPasswordRequired(ssid) {
            if (ssid === root.ssid) {
                root.askingPassword = true
                root.connectFailed  = false
                passField.text = ""
                passField.forceActiveFocus()
            }
        }
        function onConnectionFailed(ssid, reason) {
            if (ssid === root.ssid && root.askingPassword) {
                root.connectFailed = true
                passField.text     = ""
                passField.forceActiveFocus()
            }
        }
    }

    // Cuando cambia la lista de APs, resetear estado si el AP ya no está activo
    onActiveChanged: {
        if (active && askingPassword) {
            askingPassword = false
            connectFailed  = false
        }
    }

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 0

        // Fila principal
        Item {
            id: row
            Layout.fillWidth: true
            implicitHeight: 42

            RowLayout {
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                spacing: 8

                // Ícono señal wifi
                Text {
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: root.active ? pal.primary : pal.on_surface
                    text: {
                        if (root.signal_ >= 76) return "󰤨"
                        if (root.signal_ >= 51) return "󰤥"
                        if (root.signal_ >= 26) return "󰤢"
                        return "󰤟"
                    }
                }

                // Ícono candado si tiene seguridad
                Text {
                    visible: root.security !== ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    color: pal.outline
                    text: "󰌾"
                }

                // SSID
                Text {
                    Layout.fillWidth: true
                    text: root.ssid
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    color: root.active ? pal.primary : pal.on_surface
                    font.bold: root.active
                    elide: Text.ElideRight
                }

                // Chip "conectada" o botón desconectar
                Rectangle {
                    visible: root.active
                    implicitWidth: chipTxt.implicitWidth + 16
                    implicitHeight: 22
                    radius: 11
                    color: pal.primary_container

                    Text {
                        id: chipTxt
                        anchors.centerIn: parent
                        text: "conectada"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: pal.on_primary
                    }

                    TapHandler {
                        onTapped: root.service.disconnect(root.ssid)
                    }
                }
            }

            // Click en la fila = intentar conectar (solo si no activa)
            TapHandler {
                enabled: !root.active && !root.askingPassword
                onTapped: root.service.connect(root.ssid, "")
            }
        }

        // Zona de password (expandible)
        Item {
            Layout.fillWidth: true
            implicitHeight: root.askingPassword ? passRow.implicitHeight + 16 : 0
            clip: true
            Behavior on implicitHeight {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: passRow
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 6

                // Error de contraseña
                Text {
                    visible: root.connectFailed
                    Layout.fillWidth: true
                    text: "Contraseña incorrecta"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    color: pal.error
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: 8
                        color: pal.surface_container_high
                        border.color: root.connectFailed ? pal.error : pal.outline_variant
                        border.width: 1

                        TextInput {
                            id: passField
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: pal.on_surface
                            selectByMouse: true
                            Keys.onReturnPressed: {
                                if (text.length > 0) {
                                    root.connectFailed = false
                                    root.service.connect(root.ssid, text)
                                }
                            }
                            Keys.onEscapePressed: {
                                root.askingPassword = false
                                root.connectFailed  = false
                                text = ""
                            }
                        }
                    }

                    // Botón conectar
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 8
                        color: pal.primary_container

                        Text {
                            anchors.centerIn: parent
                            text: "󰌓"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: pal.on_primary
                        }

                        TapHandler {
                            onTapped: {
                                if (passField.text.length > 0) {
                                    root.connectFailed = false
                                    root.service.connect(root.ssid, passField.text)
                                }
                            }
                        }
                    }

                    // Botón cancelar
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 8
                        color: pal.surface_container_high

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: pal.outline
                        }

                        TapHandler {
                            onTapped: {
                                root.askingPassword = false
                                root.connectFailed  = false
                                passField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
