# CLAUDE.md — tmux/

Stows into `~/.config/tmux/`. Tmux config + git-branch override.

## Files

- `tmux.conf` — single source of truth (all settings, keybindings, plugin list).
- `git_branch.conf` — standalone include for a compact git-branch status segment (referenced by tmux.conf).
- `matugen.conf` — **generated** by matugen on wallpaper change, sourced at the end of `tmux.conf` via `source-file -q`. Overwrites pane/message colors with the current theme palette. The `-q` flag keeps tmux booting on machines where the file has not been generated yet.

## Non-obvious settings

- **Prefix**: `C-Space` (not `C-b` or `C-a`). Rebinding this breaks resurrect/yank/continuum muscle memory — don't change without a very good reason.
- **Terminal chain**: `default-terminal = "tmux-256color"` plus `terminal-overrides ",xterm-ghostty:RGB"`. The override is what tells tmux the *outer* terminal supports truecolor; dropping it makes colors banded inside nvim.
- **`extended-keys on`** is required for Ctrl+Shift+<key> bindings to reach apps inside tmux.
- **`set-clipboard on`** (OSC 52): apps inside tmux can write to system clipboard. Works with Ghostty + Wayland without additional setup.
- **`detach-on-destroy off`**: closing the last pane of a session jumps to another session instead of kicking you out of tmux entirely.

## Copy mode

Vi keys (`v` selects, `C-v` rectangle, `y` copy + cancel). `tmux-yank` sends to the system clipboard on Wayland via `wl-copy`.

## Plugins (TPM)

Load order matters because `matugen.conf` must be sourced *after* plugins, so plugin color themes can be overridden:

```
tpm.tpm → plugins load → source matugen.conf
```

Listed plugins: `tmux-sensible`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`. Continuum has `@continuum-restore 'on'` — sessions auto-save every 15 min and auto-restore at startup. If you add a plugin, put its `set -g @plugin` line **before** the `run '~/.tmux/plugins/tpm/tpm'` call.

## Catppuccin theme

Installed manually (per Catppuccin's recommendation), **not** via TPM. Expected path: `~/.config/tmux/plugins/catppuccin/tmux`. `@catppuccin_status_background "none"` is deliberate — rounded separators would need a real bg color, and transparency wins. That's why `@catppuccin_window_status_style` is `"basic"`, not `"rounded"`.

## Reload

`prefix + r` → `source-file ~/.config/tmux/tmux.conf`. Preferred over killing the server when testing changes.
