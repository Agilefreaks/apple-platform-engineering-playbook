# Git & PR Workflow

## General
- Do NOT commit, push, or create PRs unless the user explicitly asks.

## Prerequisites
- PRs are handled via the `gh` CLI. Before any PR step, verify it's installed: `gh --version`
- If `gh` is not installed, install it, then confirm auth with `gh auth status`:
  - macOS: `brew install gh`
  - Debian/Ubuntu: `sudo apt install gh`
  - Fedora: `sudo dnf install gh`
  - Otherwise: see https://github.com/cli/cli#installation
- If `gh auth status` shows you are not logged in, tell the user to run `gh auth login`
  themselves (it's interactive — a subprocess can't complete it).

## Commits
- Keep commit subjects to a single line.
- Never add `Co-Authored-By: Claude` or "Generated with Claude Code" trailers.
- Check whether a pre-commit hook rewrites the message (e.g. adds a branch/ticket
  prefix). If it does, do NOT add that prefix yourself. Detect by inspecting
  `.git/hooks/` and any hook config (`.pre-commit-config.yaml`, Husky, etc.).

## Pull Requests
- Start from the repo's PR template if one exists — check, in order:
  `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
  `PULL_REQUEST_TEMPLATE.md`, or `docs/`. **Fill in every section** — never submit
  with raw template placeholders intact. At minimum complete: what & why, the
  related ticket/issue link, and steps to test or reproduce.
- Create non-interactively: pass the filled body via `--body-file <path>` or
  `--body "…"`. Never submit with `--body ""` or the untouched template.
- Match the repo's title convention. If commits/PRs use a branch or ticket prefix
  (e.g. `[ABC-123] title`), follow it; infer the pattern from recent history:
  `gh pr list --state all --limit 20` or `git log --oneline -20`.

## Reviewers
Add required reviewers (excluding the PR author). Resolve them from the project,
in this priority order — use the first source that yields names:
1. **CODEOWNERS** — `.github/CODEOWNERS`, `CODEOWNERS`, or `docs/CODEOWNERS`.
   Match the changed paths to their owning teams/users.
2. **README / CONTRIBUTING** — a documented maintainers or reviewers list.
3. **Git history** — the most frequent recent committers to the changed files:
   `git log --format='%an <%ae>' -- <changed-paths> | sort | uniq -c | sort -rn`

- Resolve a display name to a GitHub username with
  `git log --all --format='%an <%ae>' | sort -u` and/or `gh api users/<login>`.
- Add reviewers with `gh pr create --reviewer <login1> --reviewer <login2>`.
- If you can't confidently resolve a reviewer, ask the user rather than guessing.
