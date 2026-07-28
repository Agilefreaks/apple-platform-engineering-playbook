# Project Starter Contract

These files bootstrap the human/agent operating contract of a new Apple project. They
do not generate an Xcode project, signing identities, environments, or production
credentials.

Preferred installation from the playbook root:

~~~bash
./scripts/bootstrap_project.sh /path/to/new-app-repository
~~~

The helper refuses to overwrite existing files. After installation:

1. replace every `<PLACEHOLDER>`;
2. define deterministic project commands in `AGENTS.md` and the project Makefile;
3. keep the `@AGENTS.md` import as the first line of `CLAUDE.md` — Claude Code loads
   only `CLAUDE.md`, so this import is what puts the contract in its context; add only
   Claude-specific notes there;
4. keep `.claude/rules/git-workflow.md` checked in — Claude Code loads every
   `.claude/rules/*.md` file automatically, which is how the git and pull-request
   contract reaches a contributor's session without local setup; it needs no
   placeholder replacement, because it resolves reviewers from `CODEOWNERS`, the PR
   template, and repository history at the time it is used;
5. select and resolve skills in `tooling/skills.yml`;
6. review capabilities in `tooling/tools.yml`; activate the Tapia example only when
   agent-heavy Simulator automation is in scope;
7. create project ADRs instead of editing the company standard locally;
8. commit `.apple-playbook-version` so upgrades are deliberate;
9. create the first Delivery Packet only after project ownership and environments are
   ready.

`tooling/examples/tapia/` is inactive reference configuration. The bootstrap does not
create an active `.mcp.json`, install Tapia, or grant command approval.
