import QtQuick
import Quickshell

// Instanciar en ShellRoot como: PowerService { id: powerService }
// NO usar pragma Singleton (bug de init en Quickshell vía import 'dir')
QtObject {
    id: root

    property bool menuOpen: false
    // pending: "" | "shutdown" | "reboot"
    property string pending: ""

    property var _confirmTimer: Timer {
        interval: 3000
        repeat: false
        onTriggered: root.pending = ""
    }

    function lock() {
        menuOpen = false
        Quickshell.execDetached(["loginctl", "lock-session"])
    }

    function logout() {
        menuOpen = false
        Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
    }

    function requestShutdown() {
        if (pending === "shutdown") {
            menuOpen = false
            pending = ""
            Quickshell.execDetached(["systemctl", "poweroff"])
            return
        }
        pending = "shutdown"
        _confirmTimer.restart()
    }

    function requestReboot() {
        if (pending === "reboot") {
            menuOpen = false
            pending = ""
            Quickshell.execDetached(["systemctl", "reboot"])
            return
        }
        pending = "reboot"
        _confirmTimer.restart()
    }

    function cancelPending() {
        pending = ""
        _confirmTimer.stop()
    }

    onMenuOpenChanged: if (!menuOpen) cancelPending()
}
