# CLAUDE.md — zsh/

Stows into `~/`. Two files only: `.zshenv` and `.zshrc`.

## Split of concerns

- `.zshenv` — read by *every* zsh (interactive or not). Contains env only: `GOPATH`, `GOTOOLCHAIN`, XDG base dirs, `PATH` (deduped via `typeset -U PATH`). Don't put aliases or interactive setup here.
- `.zshrc` — interactive-only (guarded with `[[ $- != *i* ]] && return` at line 1). Everything else lives here.

## Structure of `.zshrc` (in order)

1. Interactive guard.
2. History — XDG-aware (`$XDG_STATE_HOME/zsh/history`), 50k entries, dedup, shared across terminals.
3. Shell options (`AUTO_CD`, `CORRECT`, `GLOB_DOTS`, `EXTENDED_GLOB`, `INTERACTIVE_COMMENTS`, etc.).
4. Completion — XDG-cached, case-insensitive + fuzzy matcher, `menu select`, dump freshness skip if <24h.
5. Plugins (Arch paths under `/usr/share/zsh/plugins/...`): `zsh-autosuggestions`, `zsh-syntax-highlighting`. **Non-Arch systems need these paths updated** — the README's "Note" after the Ubuntu/Debian install block has the alternatives (`~/.zsh/`, `/opt/homebrew/share/`).
6. fzf — `source <(fzf --zsh)` gives `Ctrl+R` history, `Ctrl+T` files, `Alt+C` dirs.
7. Keybindings — arrows search by prefix, `Ctrl+Backspace`, word-jump on `Ctrl+←/→` and `Alt+f/b`, `Ctrl+A`/`Ctrl+E`.
8. `WORDCHARS` — deliberately narrowed so `Ctrl+W` / `Ctrl+Backspace` treat `/` and `-` as word boundaries.
9. Aliases (grouped: navigation → utilities → tools).
10. Functions: `mkcd`, `extract`.
11. External tool inits: `mise`, `starship`, `zoxide`. Each guarded with `(( $+commands[<tool>] ))`, so missing tools degrade silently.
12. Final `. "$HOME/.local/share/../bin/env"` sources `uv`'s env file (also loaded on non-Arch installs).

## Alias conventions

- `cp`, `mv`, `rm` are **always** `-iv` (interactive + verbose) — never strip the flags "for scripts"; scripts should call the binaries directly.
- `cat='bat --style=plain'` — remember `bat` is not `cat`; for raw content piping use `/bin/cat` or `command cat`.
- `c='claude'`, `csp='claude --dangerously-skip-permissions'`, `o='opencode'` — three AI-agent shortcuts.

## `extract` function

Dispatches by extension: `.tar.{bz2,gz,xz,zst}`, `.bz2`, `.gz`, `.zip`, `.7z`, `.rar`, `.xz`, `.zst`. Relies on `unzip`, `p7zip`, `unrar`, `zstd` — optional deps listed in the README. Add new formats by extending the `case` statement; keep the error-on-unknown-format behavior.

## Gotchas

- `XDG_STATE_HOME` / `XDG_CACHE_HOME` are used before they are exported by `.zshenv` only if zsh loaded `.zshenv` first (it does — that's the point of the split).
- Changing the completion cache location also requires clearing the old dump file; `compinit` caches aggressively.
