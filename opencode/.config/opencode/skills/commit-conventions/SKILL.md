---
name: commit-conventions
description: Load when creating a git commit, writing a commit message, running git commit, staging changes, or using /commit. Full reference for Conventional Commits with Gitmoji.
license: MIT
compatibility:
  - opencode
  - claudecode
---

## Format

```
<emoji> <type>: <subject>

[optional body]
```

## Rules

- **No scope** — never use `type(scope): subject`
- **Subject**: English, imperative mood, max 72 characters, no trailing period
- **Body**: English, explain the *why* not the *what*, wrap at 72 characters
- **Breaking changes**: append `!` after type → `feat!: remove legacy API`

## Types and their Gitmoji

| Type     | Emoji | When to use                                      |
|----------|-------|--------------------------------------------------|
| feat     | ✨    | New feature for the user                         |
| fix      | 🐛    | Bug fix for the user                             |
| refactor | ♻️    | Code change that is not a fix or feature         |
| perf     | ⚡️    | Performance improvement                          |
| docs     | 📝    | Documentation only changes                      |
| style    | 🎨    | Formatting, missing semicolons, etc. (no logic)  |
| test     | ✅    | Adding or correcting tests                       |
| build    | 🏗️    | Changes to build system or external dependencies |
| ci       | 👷    | CI/CD configuration changes                     |
| chore    | 🔧    | Maintenance tasks, configs, tooling             |
| revert   | ⏪️    | Reverts a previous commit                        |

For breaking changes, prefer: 💥

## Good examples

```
✨ feat: add OAuth2 login with Google
🐛 fix: prevent crash when config file is missing
♻️ refactor: extract validation logic into separate module
📝 docs: document environment variables required for setup
✅ test: add unit tests for user authentication flow
💥 feat!: drop support for Node 16
⚡️ perf: cache database queries to reduce response time
🔧 chore: update ESLint config to v9 flat format
```

## Bad examples

```
feat(auth): Add login               ← has scope, not imperative, uppercase
fix: fixed the bug                  ← past tense, vague
update stuff                        ← no type, no emoji, vague
✨ feat: Added new feature.          ← past tense, trailing period
```

## Breaking changes

Append `!` after type. Optionally explain in body:

```
💥 feat!: remove /v1 API endpoints

The v1 endpoints have been deprecated since 2024-01. All clients
must migrate to /v2 before upgrading.
```

## When to use me

Load this skill whenever any of these keywords or actions appear:
- `git commit`, `commit`, `/commit`
- "stage", "staged changes", `git add`, `git add -A`
- "write a commit message", "commit message"
- "conventional commits", "gitmoji"
- "stage and commit", "prepare commits", "split commits"

Do not load this skill for unrelated tasks.

## Workflow

### Step 1 — Assess the state
Run `git status` to understand what is staged, unstaged, and untracked.

- **Staged changes exist**: use them as-is for analysis.
- **Nothing staged**: use the interactive question tool to ask:
  > "There are no staged changes. What do you want to do?"
  > - "Stage all changes and continue" → run `git add -A` then proceed
  > - "Cancel — I'll stage manually"
- **Nothing at all**: tell the user and stop.

### Step 2 — Analyze and group into logical commits
Read all changes and determine if they represent one or multiple independent intents.

Each logical commit should:
- Have a single clear purpose (one `type`, one subject)
- Be able to stand alone without breaking the codebase

### Step 3 — Propose the commit plan
Present each proposed commit with:
- Which files belong to it
- The exact `git add <files>` command to stage them
- The full commit message: `<emoji> <type>: <subject>` + optional body

Use the interactive question tool to ask the user:
> "How do you want to proceed with this commit plan?"
> - "Proceed — execute all commits as proposed"
> - "Modify — I want to adjust the plan" (ask what to change, loop back)
> - "Cancel — abort without making any changes"

### Step 4 — Execute in order
For each confirmed commit:
1. `git add <files>` — stage only the files for that commit
2. `git commit -m "<message>"` — create the commit
3. Confirm success before moving to the next

After all commits, summarize and remind the user the branch is ready to push.
**Never run `git push` automatically.**
