# Global OpenCode Instructions

## Language
Always respond in Spanish, unless the technical context (code, variable names,
compiler errors, logs) requires English.

## General Behavior
- Always prefer editing existing files over creating new ones
- NEVER create documentation files (README, .md, CHANGELOG) unless explicitly requested
- Before operations that affect many files at once, briefly describe the plan
- Keep responses concise: avoid restating what is already known from context

## Hard Limits — Do Not Cross Without Explicit User Confirmation
These rules are enforced at the system level, but are listed here so you
understand the intent:
- `rm` / `rm -rf` — deleting files or directories
- `sudo` — any command requiring elevated privileges
- `git push` — pushing changes to remote repositories
- Dependency installers: `npm install`, `bun add`, `pip install`,
  `brew install`, `apt`, `apt-get`

## CLI Tools You Can Use Freely
gh, git (read operations and local commits), obsidian, jq, curl, wget,
grep, rg, fd, ls, cat, bat, fzf, sed, awk, xargs

## Documentation via Context7 (Lazy Loading)
You have access to the `context7` MCP server to look up official documentation
for libraries and frameworks.

Use it lazily: only when the current task concretely requires it.

**When to use it:**
- You need the exact signature of a function or API
- The library has recent API changes that may not be in your training data
- The user references a specific version of a library

**How to use it:**
1. Call `context7_resolve-library-id` to get the library ID
2. Call `context7_get-library-docs` with the specific topic needed

Do not load documentation preemptively if it is not required for the current task.

## Agent Skills
When creating a skill (`SKILL.md`):
- Always set `compatibility` as a YAML list: `- opencode` and `- claudecode`
- The `description` field is what the agent sees first in `<available_skills>` —
  start it with `Load when...` followed by explicit trigger keywords
  (e.g. `git commit`, `/commit`, `staged changes`)
- Add a `## When to use me` section inside the skill body listing the same
  keywords and literal phrases that should trigger loading
- Fields recognized by OpenCode: `name`, `description`, `license`,
  `compatibility`, `metadata`. Unknown fields are silently ignored.
- `name` must match the directory name exactly and follow `^[a-z0-9]+(-[a-z0-9]+)*$`
- Skills have no explicit trigger mechanism — loading is driven entirely by
  the agent reading `description` and `## When to use me`

## Commits
- Use Conventional Commits: `type: subject` (no scope)
- Types: feat, fix, refactor, docs, style, perf, test, build, ci, chore, revert
- Breaking changes: append `!` after type (e.g. `feat!: drop Node 16 support`)
- Subject: English, imperative mood, max 72 characters, no trailing period
- Body (if needed): English, explain the *why*, not the *what*
- Always include a relevant emoji at the start of the subject (Gitmoji convention)
- When making commits, load the `commit-conventions` skill for full reference
