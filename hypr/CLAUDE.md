# CLAUDE.md — hypr/

Stows into `~/.config/hypr/`. Hyprland compositor config.

## Architecture

`hyprland.conf` is a **dispatcher only** — it `source =`s files in `conf.d/`, one per concern. Keep it that way when adding new settings: create or extend a file in `conf.d/`, do not add rules to `hyprland.conf` itself.

Layered companion daemons:

- `hypridle.conf` — idle timeouts (lock at 5 min, DPMS off at 5:30, suspend at 10 min).
- `hyprlock.conf` — lockscreen UI. Sources `hyprlock-colors.conf` (matugen-generated).
- `hyprpaper.conf` — wallpaper (matugen-generated, overwritten on `Super+Shift+W`).

## `conf.d/` files and their responsibility

| File | What goes in it |
|------|-----------------|
| `monitors.conf` | `monitor =` lines — hand-calibrated for DP-2 + HDMI-A-1 @ 1080p. Adjust per machine with `hyprctl monitors`. |
| `env.conf` | `env =` exports (Wayland/Qt/GDK backends, cursor theme). |
| `variables.conf` | `$terminal`, `$fileManager`, `$scriptMenu` — referenced from `keybindings.conf`. |
| `autostart.conf` | `exec-once =` — polkit, vicinae, quickshell bar, hyprpaper launcher, swaync, nm-applet, hypridle, cursor. |
| `matugen-colors.conf` | **Generated** — `$primary`, `$secondary`, `$tertiary`, `$surface`, `$outline`, `$outline_variant`. Consumed by `look-and-feel.conf`. |
| `look-and-feel.conf` | `general`, `decoration`, `animations`, `dwindle`, `master`, `misc` — consumes matugen vars. |
| `input.conf` | Keyboard (`us intl`), mouse, touchpad. |
| `keybindings.conf` | All binds. Super is `$mainMod`. |
| `windowrules.conf` | Floating rules, XDG portal, PiP, screen-sharing indicator. |

## Matugen-generated files

Three files here are overwritten on wallpaper change: `conf.d/matugen-colors.conf`, `hyprlock-colors.conf`, `hyprpaper.conf` (see root `CLAUDE.md`). If you rename any variable they export, update the matugen templates under `~/.config/matugen/` to match — that repo lives outside this one.

## Key patterns in `windowrules.conf`

Browser popup floats use the **negative-title** idiom: match the browser class, negate the main-window title, float everything else. This is how OAuth/SSO/extension popups (Zen, Brave, Chrome, Chromium) get floated without floating the main browser window.

File picker rule uses `initial_title` (not `title`), because pickers rename themselves once open — match at spawn time.

## Binds worth knowing

- `Super+Shift+W` → wallpaper picker (external script at `~/.local/bin/wallpaper-picker.sh`, not in this repo — re-triggers matugen).
- `Super+Space` → vicinae launcher.
- `Super+Shift+Space` → rofi drun.
- `Super+Shift+S` / `Print` → `grimblast --freeze copy area` (freezes the screen during selection).

## Fresh-machine gotchas

Hyprland boots with Catppuccin fallback colors even if matugen is not configured. If the bar or wallpaper don't appear, the external helpers listed in the root `CLAUDE.md` ("External dependencies not versioned here") are missing — quickshell itself is in this repo, so `stow quickshell` is enough for the bar.
