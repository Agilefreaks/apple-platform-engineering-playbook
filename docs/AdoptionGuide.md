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
  exposes it.
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
