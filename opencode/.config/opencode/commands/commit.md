---
description: Analyze changes, propose one or multiple conventional commits with Gitmoji, confirm with user, then stage and commit
---

Load the `commit-conventions` skill, then follow these steps:

## Current repository state
!`git status`

## Staged changes
!`git diff --staged`

## Unstaged changes
!`git diff`

## Untracked files
!`git ls-files --others --exclude-standard`

## Recent commits (for style and cadence reference)
!`git log --oneline -5`

## Instructions

### Step 1 — Assess what is available

- If there are **staged changes**: use them as the basis for analysis. Ignore unstaged/untracked for now.
- If there are **no staged changes**: use the interactive question tool to ask the user:
  > "There are no staged changes. What do you want to do?"
  > - "Stage all changes and continue" (runs `git add -A` then proceeds)
  > - "Cancel — I'll stage manually"
- If there is **nothing at all** (no staged, no unstaged, no untracked): tell the user there is nothing to commit and stop.

### Step 2 — Analyze and propose a commit plan

Carefully read all the changes and determine whether they represent **one single logical intent** or **multiple independent intents**.

Group changes into logical commits where each group:
- Has a single clear purpose (one type, one subject)
- Could stand alone without breaking the codebase

For each proposed commit, specify:
- Which files belong to it
- The `git add` command needed to stage exactly those files
- The full commit message (emoji + type + subject, optional body)

Present the plan to the user like this:

```
Proposed commit plan (N commits):

── Commit 1/N ──────────────────────────
Files:  src/auth/login.ts, src/auth/types.ts
Stage:  git add src/auth/login.ts src/auth/types.ts
Commit: ✨ feat: add OAuth2 login with Google

── Commit 2/N ──────────────────────────
Files:  README.md
Stage:  git add README.md
Commit: 📝 docs: document OAuth2 setup steps
```

Then use the interactive question tool to ask the user:

> "How do you want to proceed with this commit plan?"
> - "Proceed — execute all commits as proposed"
> - "Modify — I want to adjust the plan" (if selected, ask what to change and loop back to Step 2)
> - "Cancel — abort without making any changes"

### Step 3 — Execute after confirmation

Once the user confirms:

For each commit in order:
1. Run `git add <files>` to stage exactly the files for that commit
2. Run `git commit -m "<message>"` to create the commit
3. Report success before moving to the next

After all commits are done, show a summary and remind the user the branch is ready to push (but do NOT run `git push`).
