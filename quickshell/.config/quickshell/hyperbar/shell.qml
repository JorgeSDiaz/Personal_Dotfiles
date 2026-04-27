import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "modules"
import "services"
import "theme"

ShellRoot {
    Component.onCompleted: {
        Quickshell.reloadCompleted.connect(() => Quickshell.inhibitReloadPopup())
        Quickshell.reloadFailed.connect(() => Quickshell.inhibitReloadPopup())
    }

    NetworkService { id: networkService }
    PowerService   { id: powerService }

    // ─── Sidebars (uno por monitor) ────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        NetworkSidebar {
            service: networkService
        }
    }

    Variants {
        model: Quickshell.screens
        PowerMenu { service: powerService }
    }

    // ─── Barras (una por monitor) ──────────────────────────────────────────
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

                        Item {
                            id: powerBox
                            implicitWidth: powerIsland.implicitWidth
                            implicitHeight: powerIsland.implicitHeight

                            Island {
                                id: powerIsland
                                width: parent.width
                                height: parent.height
                                Power { id: pwr; service: powerService }
                            }

                            HoverHandler { onHoveredChanged: pwr.hovered = hovered }
                            TapHandler   { onTapped: powerService.menuOpen = !powerService.menuOpen }
                        }

                        Island {
                            paddingH: 10
                            paddingV: 4
                            Workspaces {}
                        }

                        Island {
                            paddingH: 12
                            paddingV: 4
                            visible: (Hyprland.activeToplevel?.title ?? "").length > 0

                            Item {
                                id: marqueeBox
                                readonly property int maxW: 130
                                readonly property int overflow: Math.max(0, titleText.implicitWidth - maxW)
                                implicitWidth: Math.min(titleText.implicitWidth, maxW)
                                implicitHeight: titleText.implicitHeight
                                clip: true

                                Text {
                                    id: titleText
                                    text: Hyprland.activeToplevel?.title ?? ""
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    color: leftPal.secondary
                                    onTextChanged: x = 0
                                }

                                SequentialAnimation {
                                    running: marqueeBox.overflow > 0
                                    loops: Animation.Infinite
                                    PauseAnimation  { duration: 2000 }
                                    NumberAnimation {
                                        target: titleText; property: "x"
                                        to: -marqueeBox.overflow
                                        duration: marqueeBox.overflow * 30
                                        easing.type: Easing.Linear
                                    }
                                    PauseAnimation  { duration: 1200 }
                                    NumberAnimation { target: titleText; property: "x"; to: 0; duration: 0 }
                                }
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

                // Derecha: network + volumen + tray
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        spacing: 8

                        Item {
                            id: netBox
                            implicitWidth: netIsland.implicitWidth
                            implicitHeight: netIsland.implicitHeight

                            Island {
                                id: netIsland
                                width: parent.width
                                height: parent.height
                                Network {
                                    id: net
                                    service: networkService
                                }
                            }

                            HoverHandler {
                                onHoveredChanged: net.hovered = hovered
                            }

                            TapHandler {
                                onTapped: networkService.sidebarOpen = !networkService.sidebarOpen
                            }
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

                        Island {
                            paddingH: 10
                            paddingV: 4
                            visible: trayItem.implicitWidth > 0
                            Tray { id: trayItem }
                        }
                    }
                }
            }
        }
    }
}
