# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed with **GNU Stow**. Each top-level directory is an independent stow package that mirrors the destination path structure under `$HOME` (e.g. `hypr/.config/hypr/...` stows into `~/.config/hypr/...`). There is no build system, tests, or CI — the "build" is `stow <package>`.

## Applying / reverting configs

```bash
cd ~/Workspace/DotFiles                  # stow always runs from the repo root

stow <package>                           # link into $HOME
stow -D <package>                        # unlink (remove symlinks)
stow -R <package>                        # relink (after adding new files)
stow -n -v <package>                     # dry-run (see what would change)
```

The full default install is: `stow zsh tmux starship nvim claude opencode hypr quickshell` (plus `ghostty` if used as terminal).

## Per-package guidance

Each stow package has its own `CLAUDE.md` with tool-specific details — read the relevant one before editing that package.

- [claude/CLAUDE.md](claude/CLAUDE.md) — Claude Code settings and status line script
- [ghostty/CLAUDE.md](ghostty/CLAUDE.md) — Ghostty terminal config
- [hypr/CLAUDE.md](hypr/CLAUDE.md) — Hyprland compositor (modular `conf.d/`, hyprlock, hypridle, hyprpaper)
- [nvim/CLAUDE.md](nvim/CLAUDE.md) — Neovim on LazyVim
- [opencode/CLAUDE.md](opencode/CLAUDE.md) — OpenCode config, skills, commands, MCP servers
- [quickshell/CLAUDE.md](quickshell/CLAUDE.md) — Hyprland status bar (QML)
- [starship/CLAUDE.md](starship/CLAUDE.md) — Shell prompt
- [tmux/CLAUDE.md](tmux/CLAUDE.md) — Terminal multiplexer
- [zsh/CLAUDE.md](zsh/CLAUDE.md) — Interactive shell

## Cross-cutting conventions

### Commit style (enforced across the repo)

Conventional Commits **with a Gitmoji prefix**, no scope:

```
<emoji> <type>: <subject>
```

- Types: `feat ✨`, `fix 🐛`, `refactor ♻️`, `perf ⚡️`, `docs 📝`, `style 🎨`, `test ✅`, `build 🏗️`, `ci 👷`, `chore 🔧`, `revert ⏪️`. Breaking: append `!` and prefer `💥`.
- Subject: **English**, imperative mood, ≤72 chars, no trailing period.
- Body (optional): English, explain **why**, not what.

Full reference and the `/commit` workflow live in [opencode/.config/opencode/skills/commit-conventions/SKILL.md](opencode/.config/opencode/skills/commit-conventions/SKILL.md). The skill is shared by OpenCode and Claude Code.

### Before committing dotfile changes

Verify whether the change needs a matching update to `README.md` (install steps, tool list, post-install notes, "not yet versioned" section). The README is the onboarding path for a fresh machine, so drift there silently breaks new installs.

### Matugen-generated files — do not hand-edit

These files are rewritten whenever the user changes wallpaper (`Super+Shift+W`). Editing them by hand gets overwritten on the next theme regeneration. They are checked in only as **Catppuccin Mocha fallbacks** so a fresh install can boot before the user runs the wallpaper picker:

- `hypr/.config/hypr/conf.d/matugen-colors.conf`
- `hypr/.config/hypr/hyprlock-colors.conf`
- `hypr/.config/hypr/hyprpaper.conf`
- `tmux/.config/tmux/matugen.conf` (sourced at the end of `tmux.conf`, may not exist on fresh installs — sourced with `-q`)
- `quickshell/.config/quickshell/mybar/theme/Palette.qml` (values are matugen-derived but the file is edited as QML)

If you need to change theme behavior, edit the *consumers* of these variables, not the generated files themselves.

### External dependencies not versioned here

Referenced by configs in this repo but living outside it: `~/.config/matugen/` (templates), `~/.local/bin/wallpaper-picker.sh`, `~/.local/bin/start-hyprpaper.sh`. On a fresh machine these are missing; some features degrade gracefully (the bar launches; the wallpaper picker keybinding is dead until the scripts exist). The README's "Hyprland notes" lists the same set — keep both in sync when adding or removing an external helper.
