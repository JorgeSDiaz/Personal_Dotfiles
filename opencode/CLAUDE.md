# CLAUDE.md — opencode/

Stows into `~/.config/opencode/`. Configures the OpenCode CLI, a sibling AI tool to Claude Code.

## What's in here and why Claude Code should care

This directory is not for Claude Code *itself*, but Claude Code frequently needs to edit it:

- `AGENTS.md` — global instructions for OpenCode (analogous to `~/.claude/CLAUDE.md`). When changing behavior for both agents, mirror the relevant parts here.
- `skills/` — **shared skills** (`compatibility: [opencode, claudecode]`). Editing a skill here affects both agents.
- `commands/` — OpenCode slash commands (e.g. `/commit`).
- `plugin/` — local OpenCode plugins (TypeScript): `background-agents.ts`, `rtk.ts`.
- `opencode.json` — OpenCode config: models, permissions, MCP servers.
- `tui.json` — OpenCode TUI theme (Catppuccin).

`node_modules/`, `package.json`, `package-lock.json`, `bun.lock` are gitignored (dev artifacts for plugin development).

## Model and permissions (`opencode.json`)

- Default model: `anthropic/claude-sonnet-4-6`. Small model: `claude-haiku-4-5`. Plan agent: `claude-opus-4-6`.
- `permission.bash` is **allow-by-default** with `ask` overrides for `rm *`, `sudo *`, `git push *`, and dependency installers (`npm install/i`, `bun add/install`, `pip install`, `brew install`, `apt`, `apt-get`). Mirror any new hard-limit additions into `AGENTS.md`.
- `compaction.auto = false`, `compaction.prune = false` — transcripts are not auto-trimmed.

## MCP servers configured

| Server | Type | Notes |
|--------|------|-------|
| `context7` | remote | `https://mcp.context7.com/mcp` — library docs lookup |
| `basic-memory` | local | `uvx basic-memory mcp` — requires `uv` on PATH |
| `aws-docs` | local | `uvx awslabs.aws-documentation-mcp-server@latest` |

If you add a local MCP server using `uvx`, confirm `uv` is listed in the README's install steps.

## Skills — authoring rules

Full rules live in `AGENTS.md` under "Agent Skills" — read that section before authoring a new skill. Reference implementation: `skills/commit-conventions/SKILL.md`, which is shared with Claude Code (loaded by the `/commit` flow in both agents).

## Commands

`commands/commit.md` — implements the shared commit workflow: assess state, analyze, propose a plan, confirm with user, execute each commit in order. Never runs `git push`. The command loads the `commit-conventions` skill at step 1.

If you change commit behavior for the repo, update the skill (source of truth) rather than the command.
