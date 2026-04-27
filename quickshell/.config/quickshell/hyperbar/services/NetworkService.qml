import QtQuick
import Quickshell
import Quickshell.Io

// Instanciar en ShellRoot como: NetworkService { id: networkService }
// NO usar pragma Singleton (bug de init en Quickshell vía import "dir")
QtObject {
    id: root

    // Controla visibilidad del sidebar (global — una pantalla abre todas)
    property bool sidebarOpen: false

    // Estado público
    property bool wifiEnabled: false
    property string connectionType: "none"   // "wifi" | "ethernet" | "none"
    property string activeSsid: ""
    property int activeSignal: 0
    property var accessPoints: []
    property bool scanning: false

    // Detalles de la conexión activa (para la tarjeta de info)
    property string activeDevice: ""           // e.g. "wlp3s0", "enp4s0"
    property string activeConnectionName: ""   // nombre del profile NM
    property string activeIPv4: ""             // sin prefijo
    property string activeGateway: ""
    property string activeDns: ""              // comma-joined

    // Señales para el delegate
    signal passwordRequired(string ssid)
    signal connectionFailed(string ssid, string reason)

    // ─── API pública ────────────────────────────────────────────────────────

    function rescan() {
        if (scanning) return
        if (!wifiEnabled) return
        scanning = true
        _rescanProc.command = ["nmcli", "dev", "wifi", "rescan"]
        _rescanProc.running = true
    }

    function connect(ssid, password) {
        if (_connectPending) return
        _connectSsid = ssid
        _connectStderr = ""
        _connectPending = true
        // TODO v2: pasar password por ProcessEnvironment para evitar exposición en /proc/cmdline
        if (password === "") {
            _connectProc.command = ["nmcli", "-w", "10", "device", "wifi", "connect", ssid]
        } else {
            _connectProc.command = ["nmcli", "-w", "10", "device", "wifi", "connect", ssid, "password", password]
        }
        _connectProc.running = true
    }

    function disconnect(ssid) {
        _disconnectProc.command = ["nmcli", "connection", "down", ssid]
        _disconnectProc.running = true
    }

    function toggleWifi() {
        _toggleProc.command = wifiEnabled
            ? ["nmcli", "radio", "wifi", "off"]
            : ["nmcli", "radio", "wifi", "on"]
        _toggleProc.running = true
    }

    // Refresh instantáneo al abrir el sidebar
    onSidebarOpenChanged: {
        if (sidebarOpen) {
            _devLines = []
            _deviceProc.running = true
            rescan()
        }
    }

    // ─── Internos ────────────────────────────────────────────────────────────

    property string _connectSsid: ""
    property string _connectStderr: ""
    property bool _connectPending: false
    property var _devLines: []
    property var _apLines: []
    property var _connInfoLines: []

    // Monitor event-driven (reemplaza polling de 5s)
    property var _monitorProc: Process {
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: data => { if (!_debounce.running) _debounce.restart() }
        }
    }

    property var _debounce: Timer {
        interval: 200
        repeat: false
        onTriggered: {
            root._devLines = []
            root._radioProc.running = true
            root._deviceProc.running = true
        }
    }

    property var _radioProc: Process {
        command: ["nmcli", "-t", "radio", "wifi"]
        running: false
        stdout: SplitParser {
            onRead: data => root.wifiEnabled = data.trim() === "enabled"
        }
        onExited: {
            running = false
            // Mantener la lista de APs en sincronía con el estado del radio
            if (root.wifiEnabled) {
                root._apLines = []
                root._apProc.running = true
            } else {
                root.accessPoints = []
                root.activeSsid = ""
                root.activeSignal = 0
            }
        }
    }

    property var _deviceProc: Process {
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        running: false
        stdout: SplitParser {
            onRead: data => root._devLines.push(data)
        }
        onExited: {
            running = false
            let activeType = "none"
            let activeDev = ""
            let activeConn = ""
            for (const line of root._devLines) {
                if (!line) continue
                const esc = line.replace(/\\:/g, "\x00")
                const parts = esc.split(":")
                if (parts.length < 4) continue
                const dev   = parts[0].replace(/\x00/g, ":")
                const type  = parts[1]
                const state = parts[2]
                const conn  = parts.slice(3).join(":").replace(/\x00/g, ":")
                if (state !== "connected") continue
                // Ethernet prioritaria sobre wifi para la tarjeta de conexión
                if (type === "ethernet") {
                    activeType = "ethernet"; activeDev = dev; activeConn = conn
                    break
                }
                if (type === "wifi" && activeType === "none") {
                    activeType = "wifi"; activeDev = dev; activeConn = conn
                }
            }
            root._devLines = []
            root.connectionType = activeType
            root.activeDevice = activeDev
            root.activeConnectionName = activeConn

            if (activeDev) {
                root._connInfoLines = []
                root._connInfoProc.command = ["nmcli", "-t", "device", "show", activeDev]
                root._connInfoProc.running = true
            } else {
                root.activeIPv4 = ""
                root.activeGateway = ""
                root.activeDns = ""
            }
        }
    }

    property var _connInfoProc: Process {
        command: []
        running: false
        stdout: SplitParser {
            onRead: data => root._connInfoLines.push(data)
        }
        onExited: {
            running = false
            let ip = "", gw = "", dns = []
            for (const line of root._connInfoLines) {
                if (!line) continue
                const esc = line.replace(/\\:/g, "\x00")
                const idx = esc.indexOf(":")
                if (idx < 0) continue
                const key = esc.substring(0, idx)
                const val = esc.substring(idx + 1).replace(/\x00/g, ":")
                if (key === "IP4.ADDRESS[1]") ip = val.split("/")[0]
                else if (key === "IP4.GATEWAY") gw = val
                else if (key.startsWith("IP4.DNS[")) dns.push(val)
            }
            root._connInfoLines = []
            root.activeIPv4 = ip
            root.activeGateway = gw
            root.activeDns = dns.join(", ")
        }
    }

    property var _apProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list", "--rescan", "no"]
        running: false
        stdout: SplitParser {
            onRead: data => root._apLines.push(data)
        }
        onExited: {
            running = false
            root._parseAPs()
            root.scanning = false
        }
    }

    property var _rescanProc: Process {
        command: []
        running: false
        onExited: {
            running = false
            root._apLines = []
            root._apProc.running = true
        }
    }

    property var _connectProc: Process {
        command: []
        running: false
        stderr: SplitParser {
            onRead: data => root._connectStderr += data + "\n"
        }
        onExited: (code, status) => {
            running = false
            root._connectPending = false
            if (code === 0) {
                root._apLines = []
                root._apProc.running = true
            } else {
                const err = root._connectStderr.toLowerCase()
                if (err.includes("secrets") || err.includes("password") || err.includes("no network with ssid")) {
                    root.passwordRequired(root._connectSsid)
                } else {
                    root.connectionFailed(root._connectSsid, root._connectStderr.trim())
                }
                root._connectStderr = ""
            }
        }
    }

    property var _disconnectProc: Process {
        command: []
        running: false
        onExited: {
            running = false
            root._devLines = []
            root._deviceProc.running = true
        }
    }

    property var _toggleProc: Process {
        command: []
        running: false
        onExited: {
            running = false
            root._radioProc.running = true
        }
    }

    // Parsea output de nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID
    // Formato: *:82:WPA2:MiCasa  (colones en SSID escapados como \:)
    function _parseAPs() {
        const seen = {}   // ssid → index in result
        const result = []
        for (const line of root._apLines) {
            if (!line) continue
            const esc = line.replace(/\\:/g, "\x00")
            const parts = esc.split(":")
            if (parts.length < 4) continue
            const active = parts[0] === "*"
            const sig    = parseInt(parts[1]) || 0
            const sec    = parts[2].replace(/\x00/g, ":").trim()
            const ssid   = parts.slice(3).join(":").replace(/\x00/g, ":")
            if (!ssid) continue
            if (seen[ssid] === undefined) {
                seen[ssid] = result.length
                result.push({ ssid, signal: sig, security: sec, active })
            } else if (result[seen[ssid]].signal < sig) {
                result[seen[ssid]] = { ssid, signal: sig, security: sec, active }
            }
        }
        root._apLines = []
        result.sort((a, b) => a.active !== b.active ? (a.active ? -1 : 1) : b.signal - a.signal)
        root.accessPoints = result
        const activeAP = result.find(x => x.active)
        root.activeSsid  = activeAP ? activeAP.ssid   : ""
        root.activeSignal = activeAP ? activeAP.signal : 0
    }

    Component.onCompleted: {
        _radioProc.running = true
        _deviceProc.running = true
    }

    Component.onDestruction: {
        _monitorProc.running = false
    }
}
