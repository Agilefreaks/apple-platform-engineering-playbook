# Project Starter Contract

These files bootstrap the human/agent operating contract of a new Apple project. They
do not generate an Xcode project, signing identities, environments, or production
credentials.

Preferred installation from the playbook root:

~~~bash
./scripts/bootstrap_project.sh /path/to/new-app-repository
~~~

The helper refuses to overwrite existing files. After installation:

1. run `scripts/check_playbook_access.sh` — a browser URL is not a readable reference even for a
   public repository; this confirms the architecture standard is readable at the pinned commit,
   through the GitHub CLI when one is installed and authenticated and over plain HTTPS when it is
   not, and prints the matching command for reading any playbook document;
2. replace every `<PLACEHOLDER>` in `AGENTS.md` — the machine-read files (`.mcp.json`,
   `.claude/settings.json`) ship with no placeholders and are runnable as checked out;
3. define deterministic project commands in `AGENTS.md` and the project Makefile;
4. keep the `@AGENTS.md` import as the first line of `CLAUDE.md` — Claude Code loads
   only `CLAUDE.md`, so this import is what puts the contract in its context; add only
   Claude-specific notes there;
5. keep `.claude/rules/git-workflow.md` checked in — Claude Code loads every
   `.claude/rules/*.md` file automatically, which is how the git and pull-request
   contract reaches a contributor's session without local setup; it needs no
   placeholder replacement, because it resolves reviewers from `CODEOWNERS`, the PR
   template, and repository history at the time it is used;
6. keep `.claude/settings.json` checked in for the same reason — it approves the MCP server that
   `.mcp.json` configures, by name; capability held only in a developer's user settings is
   invisible to everyone else;
7. commit `.agents/skills/` and the `.claude/skills/*` symlinks — the agent skills are checked in
   rather than installed from a marketplace, so they are present on clone, in CI, and in headless
   runs, with no trust prompt and no per-machine state; `.agents/skills/VENDORED.md` records each
   upstream repository, pinned commit and licence, and `tooling/skills.yml` maps them to the
   canonical skill IDs. Name anything unresolved as a tooling gap rather than leaving it blank;
8. review capabilities in `tooling/tools.yml`; activate the Tapia example only when
   agent-heavy Simulator automation is in scope;
9. create project ADRs instead of editing the company standard locally;
10. commit `.apple-playbook-version` so upgrades are deliberate — it records the playbook commit
    as well as the package version, which is what pins the documents a project reads to one ref;
11. create the first Delivery Packet only after project ownership and environments are ready.

`.mcp.json` is installed active, configured for the headless Xcode-automation implementation
with its telemetry disabled and its enabled workflows named explicitly. A project that keeps
Xcode open and prefers the first-party bridge replaces the file's contents and records that
choice in `AGENTS.md`.

`tooling/examples/tapia/` remains inactive reference configuration. The bootstrap does not
install Tapia or grant command approval.
