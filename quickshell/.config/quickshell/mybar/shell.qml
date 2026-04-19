import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "modules"
import "theme"
import "config"

ShellRoot {
    Component.onCompleted: {
        Quickshell.reloadCompleted.connect(() => Quickshell.inhibitReloadPopup())
        Quickshell.reloadFailed.connect(() => Quickshell.inhibitReloadPopup())
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: 42
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                // Izquierda: workspaces + título de ventana
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Palette { id: leftPal }

                    RowLayout {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        spacing: 8

                        Island {
                            paddingH: 10
                            paddingV: 4
                            Workspaces {}
                        }

                        Island {
                            paddingH: 12
                            paddingV: 4
                            visible: (Hyprland.focusedClient?.title ?? "").length > 0

                            Text {
                                Layout.maximumWidth: 276
                                text: Hyprland.focusedClient?.title ?? ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: leftPal.on_surface
                                opacity: 0.7
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Centro: reloj
                Item {
                    Layout.preferredWidth: clockIsland.implicitWidth
                    Layout.fillHeight: true

                    Island {
                        id: clockIsland
                        anchors.centerIn: parent
                        Clock {}
                    }
                }

                // Derecha: tray + volumen
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        spacing: 8

                        Island {
                            paddingH: 10
                            paddingV: 4
                            visible: trayItem.implicitWidth > 0
                            Tray { id: trayItem }
                        }

                        Item {
                            id: volBox
                            implicitWidth: volIsland.implicitWidth
                            implicitHeight: volIsland.implicitHeight

                            Island {
                                id: volIsland
                                width: parent.width
                                height: parent.height
                                Volume { id: vol }
                            }

                            HoverHandler {
                                onHoveredChanged: vol.hovered = hovered
                            }

                            TapHandler {
                                onTapped: Quickshell.execDetached(["pavucontrol"])
                            }
                        }
                    }
                }
            }
        }
    }
}
