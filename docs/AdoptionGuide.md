# Adoption Guide for a New Apple Project

This guide turns the playbook into a project-specific operating contract. It does not
replace product discovery, Apple account setup, signing ownership, or an executable
Xcode bootstrap.

## 1. Choose the adoption unit

For a greenfield project, adopt the Architecture Standard and Delivery Loop together.
Record:

- playbook Git tag or commit;
- Architecture and Delivery Loop document versions;
- project owner for future upgrades;
- approved deviations and their ADRs.

For an existing project, adopt at a clean feature, service, flow, or target boundary.
Do not create half-migrated screens to claim compliance.

## 2. Establish project facts

Before feature implementation, decide and record:

- product name, bundle identifiers, platforms, and minimum OS;
- Apple Developer team, App Store Connect ownership, signing, certificates, profiles,
  entitlements, and protected credentials;
- schemes, configurations, environments, API endpoints, and feature-flag ownership;
- repository owners, review policy, protected branch, CI runner, and release authority;
- privacy/data classification, security review triggers, third-party policy, and legal
  constraints;
- analytics, operational logging, crash reporting, performance monitoring, incident
  path, and support ownership;
- TestFlight/App Store channels, target cohorts, production verification, and rollback
  strategy.

The Architecture Standard cannot guess these product and organization decisions.

## 3. Bootstrap the repository contract

Run the non-overwriting bootstrap helper:

~~~bash
./scripts/bootstrap_project.sh /path/to/new-app-repository
~~~

Alternatively, copy the starter files from `templates/project/` and delivery artifacts
manually. Replace all placeholders:

~~~text
AGENTS.md
CLAUDE.md
.claude/rules/git-workflow.md
.claude/settings.json
.mcp.json
scripts/check_playbook_access.sh
tooling/skills.yml
tooling/tools.yml
tooling/examples/tapia/
docs/adr/0000-template.md
~~~

`CLAUDE.md` exists because Claude Code loads only `CLAUDE.md` and ignores `AGENTS.md`;
its first line, `@AGENTS.md`, imports the contract at session start so `AGENTS.md`
stays the single source of truth. Keep only Claude-runtime notes in it — agent behaviour
that would not be true of a different agent or a human reader. Project facts, commands,
paths, and owners stay in `AGENTS.md`; `CLAUDE.md` may name a section but must not
restate it, because a fact held in two files goes stale in one of them.

`.claude/rules/git-workflow.md` is checked in because agent git behaviour is a project
contract, not a personal preference: which reviewers a pull request needs, whether the
PR template must be filled, and that nothing is committed or pushed unless a human asks.
Claude Code loads every `.claude/rules/*.md` file automatically alongside `CLAUDE.md`, so
the rule reaches any contributor's session without setup. Keep repository-specific
routing — the reviewer source of truth, the ticket prefix — in `CODEOWNERS` and the PR
template the rule already reads, not restated in the rule.

`.claude/settings.json` and `.mcp.json` are checked in for the same reason as the git rule:
agent capability is a project contract, not a personal setup. The settings file approves the MCP
server that `.mcp.json` configures, naming it rather than blanket-approving whatever the file
happens to contain. Without these, a project's capability is whatever each developer happened to
install — which is indistinguishable from a project that works on one machine and nowhere else.

The skills go further: they are **checked in, not installed**. `.agents/skills/<name>/` holds the
files and `.claude/settings.json` declares no marketplace at all. The starter kit previously
declared three plugin marketplaces there, which reads as provisioning but is really an instruction
to install — it needs the network and a trust prompt on first open, resolves to whatever the
upstream default branch says that day, and lands in per-machine state under the user's home
directory. The consequence is a skill that is absent in a fresh clone until somebody accepts a
prompt, absent in every headless and CI run, and a different version per developer: the same
failure the `company://apple-skills` placeholder produced, one layer further along. Vendored
skills are present on clone, identical everywhere, and change only in a reviewed commit.
`.claude/skills/<name>` is a committed symlink into `.agents/skills/`, so Claude Code loads each as
a project-scope skill while an agent reading `AGENTS.md` finds the same files — one payload, not a
per-tool copy. Bump a pin with the playbook's `scripts/vendor_skills.sh`, never by editing the
vendored files in place.

`.mcp.json` ships with the server version pinned exactly — `xcodebuildmcp@2.7.0`, the version this
package evaluated — rather than a placeholder for the adopter to fill in. A placeholder there is
not a decision deferred, it is a broken file: `.claude/settings.json` approves the server, so a
fresh clone starts a server whose `npx` specifier cannot resolve, and the failure surfaces as an
absent tool rather than as an unreplaced placeholder. Bump the pin deliberately, in a commit that
says what was re-evaluated; never replace it with `latest` or a range, which make the resolved
version a property of the registry rather than of the project.

`scripts/check_playbook_access.sh` exists because a browser `blob/` URL is not a readable
reference even now that this repository is public: it returns an HTML page rather than the
document, so an agent given only such a link has the project's own summary and nothing else — and
then diverges from a standard it names as its authority. The script confirms the architecture
standard is readable at the pinned commit — through the GitHub CLI when one is installed and
authenticated, which is also the only route that works for a private fork of the playbook, and
over plain HTTPS when it is not — and prints the matching command for reading any playbook
document. Run it as the first step after bootstrap. If it fails, the correct response is to report
the gap, not to proceed as though the standard had been read.

The bootstrap also records `playbook_commit` in `.apple-playbook-version` alongside the package
version, because a document is read at a ref, and "whatever the default branch says today" is not
a pinned adoption unit.

Then create the project structure required by ARCH v2.1:

~~~text
App/
Features/
Core/
DesignSystem/
Resources/
Config/            # xcconfig, Info.plist, *.entitlements
PreviewSupport/
Tests/
UITests/
docs/adr/
delivery/items/
delivery/schema/
delivery/templates/
scripts/
tooling/
AGENTS.md
Makefile
~~~

The helper creates only the playbook contract files. It refuses to overwrite existing
files and does not edit an Xcode project.

The starter is a contract skeleton. It deliberately does not generate
`project.pbxproj`, signing configuration, or a fake universal app.

## 4. Establish deterministic commands

Before agent-driven implementation, `AGENTS.md` and the project Makefile must expose:

- format;
- lint;
- clean build;
- unit/integration tests;
- critical UI tests;
- simulator/device runtime launch;
- delivery packet validation.

Commands identify the supported Xcode/Swift version, scheme, configuration, and
destination. They must work from a clean checkout with documented prerequisites.

## 5. Adopt skills as capabilities

Start from `templates/project/tooling/skills.yml`. Resolve canonical IDs to the actual
developer/agent tooling in `AGENTS.md`. Pin resolved versions in `skills.lock` when the
distribution system supports locking.

A missing skill is a tooling gap, not permission to ignore the corresponding ARCH or
DLV rule. Use the documented standard/checklist as the manual fallback.

## 5.1 Adopt executable tool capabilities

Start from `templates/project/tooling/tools.yml`. Keep this manifest separate from
skills: it records executable interfaces, reviewed revisions, scope, guardrails, and
fallbacks.

- Adopt Xcode automation as the recommended baseline where the selected Xcode/runtime
  exposes it. Select one implementation and keep the evaluated alternatives in
  `alternatives`: the first-party Xcode MCP needs the project open in Xcode, so headless
  or parallel agent work selects a pinned headless build server such as XcodeBuildMCP, or
  runs the repository commands with filtered output. See
  `docs/tooling/XcodeAutomationGuide.md`.
- Make `make build`/`make test` readable before adding any build server: filter through
  `xcbeautify` or an equivalent, keep the raw log, write a result bundle, set `pipefail`.
  This is the only option that also works in CI.
- Adopt Tapia MCP conditionally for agent-heavy local Simulator flows, semantic UI
  interaction, accessibility inspection, and evidence capture.
- Do not activate Tapia merely because its example is present. Review the pinned
  revision, install prerequisites, run `./scripts/tapia-doctor` from its source
  checkout, and copy
  `tooling/examples/tapia/mcp.example.json` into the agent runtime configuration only
  after project approval.
- Keep XCUITest for stable regression coverage and CI; use real-device and distributed
  verification for the gates that require them.

The bootstrap copies inactive Tapia examples, not an active `.mcp.json`. See
`docs/tooling/TapiaMCPGuide.md` for the adoption conditions and safety model.

## 6. Adopt delivery artifacts

Place the schema and selected templates in the new repository:

~~~text
delivery/
  schema/delivery.schema.json
  templates/
  items/
~~~

For each item:

1. create `delivery/items/<ID>/delivery.yml`;
2. link approved requirements and exact Figma node/version context;
3. pass Definition of Ready;
4. plan and implement vertical slices;
5. attach evidence per acceptance ID and gate;
6. release only with explicit authority;
7. declare Delivered only after distributed-build verification.

## 7. Decide what is vendored versus linked

Recommended baseline:

- link this repository as the canonical policy source;
- vendor the schemas, templates, and project-specific AGENTS/skill/tool configuration;
- record the upstream tag/commit in the project;
- upgrade through a deliberate pull request with validation and migration notes.

Avoid copying the handbooks into every app repo unless offline availability or client
constraints require it. Untracked copies drift silently.

## 8. New-project readiness review

A project is ready for its first feature when all are true:

- project facts and owners are recorded;
- the app builds and launches from a clean checkout;
- test, lint, format, runtime, and delivery validation commands exist;
- required and conditional skills/tools are declared, with Tapia enabled only when its adoption conditions apply;
- environments and signing responsibilities are explicit;
- privacy, security, analytics, observability, release, and rollback owners exist;
- the project has adopted a specific playbook revision;
- deviations have ADRs;
- the first delivery item can pass Definition of Ready.

If these conditions are not met, report the exact missing bootstrap capability. Do not
hide it inside the first feature ticket.
