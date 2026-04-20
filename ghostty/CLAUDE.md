# CLAUDE.md — ghostty/

Stows into `~/.config/ghostty/`. Single-file Ghostty terminal config.

## Things that matter when editing `config.ghostty`

- **Auto-tmux**: `command = tmux new-session -A -s main` — Ghostty always lands inside a tmux session called `main`. Changing or removing this changes the whole startup flow (zsh only loads once, inside tmux).
- **Theme is matugen-driven**: `theme = matugen` references a theme file written by matugen at wallpaper change. There is no static color block in this file on purpose.
- **Transparency stack**: `background-opacity = 0.82`, `background-opacity-cells = true`, `background-blur = 20`. `background-opacity-cells` is what makes the transparency propagate into apps like nvim/tmux; disabling it leaves their backgrounds opaque.
- **Shell integration features** (`cursor,sudo,title,ssh-env,ssh-terminfo`): `ssh-env` + `ssh-terminfo` auto-install Ghostty's terminfo on remote hosts; don't drop them unless you know you won't SSH anywhere.
- **Notifications**: `notify-on-command-finish = unfocused` + `notify-on-command-finish-after = 10s` require Ghostty ≥ 1.3.0.
- **Local overrides**: the last line `config-file = ?~/.config/ghostty/local.ghostty` loads a machine-specific override if present. The file is gitignored — put per-host tweaks (font size, monitor-specific padding) there rather than forking this config.

## Why `adjust-cell-height = 2`

Tweaks vertical padding inside the cell so JetBrainsMono Nerd Font icons don't visually collide between lines. Do not change without testing in nvim + btop.
