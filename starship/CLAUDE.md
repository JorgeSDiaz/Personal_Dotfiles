# CLAUDE.md — starship/

Stows into `~/.config/starship.toml`. Cross-shell prompt config.

## Layout

Single file: `.config/starship.toml`. Two halves:

1. `format` — the visible prompt, structured as colored "powerline-style" segments using Catppuccin palette vars as `bg`/`fg`.
2. `[palettes.catppuccin_*]` — all four Catppuccin flavors defined. Active palette picked by `palette = 'catppuccin_mocha'`.

## What's actually shown

OS icon → username → directory → git branch/status → language version (C, Rust, Go, Node, PHP, Java, Kotlin, Haskell, Python) → conda env → time → (newline) → character.

Language segments use one shared `bg:green` block; only the *active* language at a given directory renders, so the block is dynamic in width.

## `cmd_duration`

Shows after long commands, with OS notification when over 45s (`min_time_to_notify = 45000`). Relies on the shell's notification backend; on Linux/Wayland this uses `notify-send`.

## Editing tips

- Changing flavor: flip `palette = 'catppuccin_mocha'` — all four flavors are already defined below.
- To add a language: append a new `[<lang>]` block with `style = "bg:green"` matching the existing format string; keep the order consistent with the `format` string above or the segment won't appear where you expect.
- `directory.truncation_length = 3` + substitutions (`Documents`, `Downloads`, `Music`, `Pictures`, `Developer`) are cosmetic; expand the substitution map before changing truncation.
