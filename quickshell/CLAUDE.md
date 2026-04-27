# CLAUDE.md — quickshell/

Stows into `~/.config/quickshell/`. Custom Hyprland status bar (`hyperbar`) written in QML for Quickshell.

Launched by Hyprland via `exec-once = qs -p ~/.config/quickshell/hyperbar` in `hypr/.config/hypr/conf.d/autostart.conf`.

## Architecture

`shell.qml` is the `ShellRoot` entrypoint (bar + network sidebar, one of each per monitor). Code is split into:

- `modules/` — visible widgets instantiated from `shell.qml`.
- `services/NetworkService.qml` — nmcli-backed state + actions (see notes below).
- `theme/` — `Palette.qml` (Material You colors, matugen-derived) and `Island.qml` (rounded container used by every widget). `qmldir` exposes both as types.
- `notificator.js` / `.jsonc` — notification helper module.

## Important QML patterns used here

- **Per-monitor instantiation**: both the bar and the network sidebar wrap a `PanelWindow` inside `Variants { model: Quickshell.screens }`. Adding a new sidebar-style panel means following this same `Variants` pattern, not a singleton.
- **Services are instantiated, not singletons**: `NetworkService` is a `QtObject` with `id: networkService` declared once inside `ShellRoot`. It is *not* `pragma Singleton` — the comment in `NetworkService.qml` explains why (init bug when imported from a directory). Do not convert it.
- **Sidebar visibility shared across monitors**: `networkService.sidebarOpen` is a single bool. Opening the sidebar on one monitor opens it on all; that is intentional.
- **Tap vs hover handlers**: bar widgets wrap `Island` inside an `Item` that holds `HoverHandler` (sets widget's `hovered` prop) and `TapHandler` (toggles sidebar or launches pavucontrol). Keep this split when adding new widgets — hover mutates the widget, tap does an action.

## `NetworkService.qml` — how nmcli integration works

- `nmcli monitor` runs forever as `_monitorProc`; every line fires a 200ms debounce timer that re-reads `radio wifi` + `device status`. This replaces the old 5s polling loop — do not add polling Timers.
- The APs list is parsed from `nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list`. The parser escapes `\:` to `\x00` before splitting by `:`, because SSIDs can contain colons.
- `connect()` passes passwords on argv (`nmcli ... password ...`). There is a `TODO v2` to move this to `ProcessEnvironment` — honor it if someone assigns you the security hardening task.
- `connectionType` priority: ethernet > wifi > none.
- `_connInfoProc` parses `nmcli -t device show <dev>` for `IP4.ADDRESS[1]`, `IP4.GATEWAY`, `IP4.DNS[...]`.

## Theme — `Palette.qml`

Static Material You values (matugen-derived, but this file is hand-written QML, not a matugen template target). Use the semantic names (`surface`, `on_surface`, `primary`, etc.) in new code; the short aliases at the bottom (`bg`, `fg`, `accent`, `teal`, `overlay`) are kept only for existing widgets.
