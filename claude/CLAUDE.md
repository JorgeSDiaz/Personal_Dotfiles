# CLAUDE.md — claude/

Stows into `~/.claude/`. Configures the Claude Code CLI itself (this very tool).

## Layout

- `.claude/settings.json` — CLI settings (model, permission mode, status line, language).
- `.claude/statusline-command.sh` — status line renderer invoked by Claude Code on every prompt. Reads a JSON payload from stdin and emits an ANSI-colored single line.

## Key settings in `settings.json`

- `defaultMode: "plan"` — Claude Code starts in plan mode; changes require explicit approval.
- `model: "opusplan"` — uses Opus for planning, Sonnet for execution.
- `language: "Spanish"` — reply language.
- `skipDangerousModePermissionPrompt: true` — do not warn on `--dangerously-skip-permissions` (wired through the `csp` alias in `zsh/.zshrc`).

## Status line script — what to keep in mind

`statusline-command.sh` deliberately avoids `jq` (not everywhere installed) and parses JSON with inline `python3`. It is called on every prompt, so keep it fast and silent on error (every extractor already swallows exceptions and returns an empty string).

Segments rendered, left to right:

1. Git branch (yellow, from `git -C $cwd symbolic-ref --short HEAD`, fallback to short SHA).
2. Model name (magenta, from `model.id` or `model.display_name`).
3. Context window percentage (green <80%, red ≥80%).
4. Total input tokens including cache-read and cache-creation (gray).

`cwd` comes from `workspace.current_dir` → `cwd` → `pwd`. Nerd Font glyphs (`uf07b`, `uf292`, `ue725`, `uf080`, `uf0e7`) are produced via `python3` so the source stays ASCII-safe.

When editing the script: preserve the empty-string fallback pattern (Claude Code treats a missing segment as "skip"), and do not add dependencies beyond `python3`, `git`, and coreutils.
