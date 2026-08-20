# Changelog

All notable changes to the complete playbook package are recorded here.

## Unreleased

- Made a generated project's agent capability part of the repository instead of an assumption
  about the machine it is checked out on. Three things were left to whoever happened to set a
  project up, and all three failed the same way — silently, and differently per developer.
  **The standard was unreadable.** `AGENTS.template.md` named the architecture standard as
  authority via a `<PLAYBOOK_URL>/...` link, which resolves to a browser `blob/` URL. This
  repository is private, so that URL returns 404 to anything without a session: an agent had the
  project's own summary and nothing else, and diverged from a standard it correctly named as
  authority. Added `templates/project/scripts/check_playbook_access.sh`, which verifies `gh` is
  installed and authenticated and that the standard is readable at the pinned commit, and prints
  the API command for reading any playbook document; the Authority section now carries that
  command instead of an unfetchable link, and the command table gains a Playbook access row.
  `bootstrap_project.sh` also records `playbook_commit` in `.apple-playbook-version`, because
  reading a private document through the API needs a ref and "whatever the default branch says
  today" is not a pinned adoption unit.
  **The required skills resolved to nothing.** `tooling/skills.yml` declared three `required`
  entries against `source: company://apple-skills`, a placeholder for a library that was never
  published — so every project copied a file that read as satisfied and resolved to nothing. The
  two that have good public equivalents now map to MIT-licensed skills (Swift concurrency, Swift
  Testing, plus SwiftUI as a conditional), declared in a new checked-in
  `templates/project/.claude/settings.json` so a clone installs them with no manual step and
  without requiring any extra CLI. `apple/ios-runtime-debugging` stays explicitly unresolved and
  named as a tooling gap rather than left blank.
  **The MCP server was documented but never installed.** The starter kit shipped no active
  `.mcp.json`, so each project reinvented it. Added one, pinned, for the headless Xcode-automation
  implementation — with its `mcp` subcommand (absent, the process prints CLI help and exits), its
  enabled-workflow list naming every workflow in use (the variable replaces the server's defaults
  rather than extending them, so naming one silently removes the rest), and its telemetry disabled
  (`XCODEBUILDMCP_SENTRY_DISABLED=true`), because a client project should emit nothing outward it
  has not agreed to. `tooling/tools.yml` gains those as limitations and guardrails, including that
  the server's screenshot and snapshot tools ignore an explicitly passed simulator id and act on
  the session default — which attributes one device's evidence to another with no error.
  `docs/tooling/XcodeAutomationGuide.md`, the Adoption Guide (section 3) and the starter-kit
  README explain each, and the README no longer claims the bootstrap creates no active
  `.mcp.json`.

- Made the git and pull-request contract part of the starter kit instead of each
  contributor's private setup. Agent git behaviour was left to whatever personal
  configuration a machine happened to carry, so the same repository got PRs with an
  untouched template body, no reviewers, and commits nobody asked for. Added
  `templates/project/.claude/rules/git-workflow.md` — loaded automatically by Claude Code
  from any checked-in `.claude/rules/*.md` file — stating that nothing is committed,
  pushed, or opened as a PR unless a human asks, that `gh` availability and auth are
  verified before any PR step, that the repository's PR template is filled in full, and
  that reviewers are resolved from `CODEOWNERS`, then a documented maintainers list, then
  recent history of the changed paths. The bootstrap helper installs it, and the Adoption
  Guide (section 3) and starter-kit README explain why it is checked in rather than
  local. It carries no placeholders: every repository-specific answer is read from
  `CODEOWNERS`, the PR template, and history when the rule is used.
- Made `apple/xcode-automation` usable in the headless, parallel agent workflow the
  playbook promotes. The capability was `recommended` but named a single implementation —
  the first-party Xcode MCP — whose own recorded limitation is that it needs the project
  open in Xcode, so every agent run without an open Xcode silently degraded to the
  `xcodebuild` fallback and adopters read the playbook as CLI-only. The tools schema now
  accepts an optional `alternatives` list of evaluated-but-unselected implementations, plus
  an optional `selected_when` per implementation; `templates/project/tooling/tools.yml`
  carries XcodeBuildMCP as the headless alternative with pinning placeholders, sharper
  limitations, and guardrails (pin an evaluated version, never a floating tag; reproduce
  gate results through `make`; pin parallel builds to the worker's destination UDID). Added
  `docs/tooling/XcodeAutomationGuide.md` with the selection table, install/pin rules,
  parallel-execution rules, and evidence semantics, and referenced it from the Handbook
  (14.4), the Architecture Standard (`ARCH-015`), the Adoption Guide (5.1), and the README
  index.
- Required readable build output as the baseline before any build server is added: `make
  build`/`make test` filter through `xcbeautify` or an equivalent, keep the raw log, write
  a result bundle, and set `pipefail` so filtering cannot mask a failure. The command
  interface sections said nothing about log noise, which is the actual reason agents
  misread `xcodebuild` failures — and the only fix that also works in CI. Stated in the
  Architecture Standard command-interface section, Handbook 12.5, and Adoption Guide 5.1.

## 0.2.5 — 2026-07-28

- Stated that `Info.plist` and `*.entitlements` belong in `Config/`, beside the xcconfig
  files whose values they substitute. The Handbook's section 5.4 tree already showed this,
  but the agent-facing Standard never said it and the Adoption Guide listed a bare
  `Config/`, so an adoption reasonably put `Info.plist` in `App/` following its
  generator's default. Now normative in the Architecture Standard (ARCH-009 section) and
  Handbook 5.4, and annotated in the Adoption Guide structure block, including the case
  where a generator writes `Info.plist` and the file is gitignored.

## 0.2.4 — 2026-07-28

- Stopped `templates/project/CLAUDE.template.md` inviting the duplication it forbids. It
  told adopters to keep project facts in `AGENTS.md` and never restate them here, then
  offered generated-project rules and the preferred verification simulator as examples of
  what to put in `CLAUDE.md` — both project facts `AGENTS.md` already carries. The
  template now states the test for which file a note belongs in (would it still be true
  with a different agent, or for a human reading the repository?), gives genuinely
  runtime-scoped examples, and lists what must not be restated. `AdoptionGuide` §3 says
  the same. Found in a real adoption whose `CLAUDE.md` restated six `AGENTS.md` facts.

## 0.2.3 — 2026-07-27

- Added decision DLV-018 (Design fidelity): a Figma frame states visual intent, not
  fixed geometry. `Pixel perfect` means the design's hierarchy, proportion, spacing
  rhythm, type ramp, and tokens reproduced with native SwiftUI layout so the screen
  looks right on every supported device, appearance, and Dynamic Type size — never a
  pixel copy of one frame rebuilt from reference-width scale factors, fixed text
  frames, hardcoded point sizes, or screen-bounds math. Stated normatively in the
  Delivery Loop Standard (new section 3.3) and ARCH-014, explained with a
  before/after SwiftUI example in both Handbooks, and made checkable in the Figma
  Definition of Ready checklist, the design-map template (new Layout fidelity
  section), and the test-plan parity matrix. Added an optional `design.fidelity_policy`
  field to the delivery schema and template, extended the Definition of Ready and
  Definition of Delivered design checks, and bumped the decision-ID validator range.
- Added decision DLV-017 (Parallel execution and shared-resource isolation): when work
  fans out across concurrent workers, each owns a dedicated Simulator with a unique UDID,
  pins every operation to it, and never runs destructive lifecycle actions (restart,
  shutdown, erase, re-boot) on a device it does not own — preventing the shared-Simulator
  restart thrash loop. Documented the mechanics in the Tapia MCP Guide, mirrored the
  guardrails in `tooling/tools.yml`, and updated the decision-ID validator. Updated the
  Delivery Loop Standard (DLV-017) and Handbook together.
- Required compiler-generated asset symbols for catalog colors and images
  (`Color(.brandPurple)`, `Image(.logo)`) and banned the stringly-typed
  initializers (`Color("BrandPurple")`, `Image("Logo")`) as a review-blocking
  violation, with `Generate Swift Asset Symbol Extensions` kept enabled. Updated
  the Architecture Standard (ARCH-014) and the Handbook DesignSystem section.
- Recorded the explicit Figma→Xcode asset export rule across the delivery and
  architecture documents: export SVG whenever Figma renders the artwork faithfully
  as vector, otherwise PNG at 3x only; every Asset Catalog image set holds one
  universal Single Scale variant (no 1x/2x/3x triplets) and views size images
  explicitly. Updated the Delivery Loop Standard/Handbook, Architecture
  Standard/Handbook, the Figma Definition of Ready checklist, and the design-map
  template.

## 0.2.2 — 2026-07-21

- Added `templates/project/CLAUDE.template.md` and taught the bootstrap to install it
  as `CLAUDE.md`: Claude Code loads only `CLAUDE.md`, so the template's `@AGENTS.md`
  first line imports the contract while `AGENTS.md` stays the single source of truth.
- Bootstrap now stamps `.apple-playbook-version` with the released package version
  (was stale at `0.2.0`).

## 0.2.1 — 2026-07-21

- Translated all delivery templates, the Architecture Handbook, and the Delivery Loop
  Handbook to English; ARCH/DLV decision IDs, tables, and fences unchanged.
- Recorded the English-only repository policy in CONTRIBUTING (Language section).
- Added the New Project Intake Checklist template mapping 1:1 to the Adoption Guide
  project facts, AGENTS.md, and the Definition of Ready.

## 0.2.0 — 2026-07-16

- Added `tooling/tools.yml` and its JSON Schema for executable capability declarations.
- Added Tapia MCP as `recommended_conditional` for agent-heavy iOS Simulator UI and
  runtime automation, pinned to a reviewed revision.
- Added inactive Tapia MCP/flow examples, an operational guide, safety guardrails,
  evidence semantics, and explicit fallbacks.
- Updated architecture, delivery, adoption, agent contract, validation, and bootstrap
  guidance while keeping XCUITest, real-device, distributed-build, and production
  verification responsibilities distinct.

## 0.1.1 — 2026-07-16

- Fixed GitHub Actions dependency-cache discovery for `requirements-dev.txt`.

## 0.1.0 — 2026-07-16

- Added Apple Team Architecture Handbook and agent-facing Standard v2.1.
- Added Delivery Loop Handbook and agent-facing Standard v0.1.
- Added Delivery Packet JSON Schema and validated YAML template.
- Added Figma Ready, Definition of Ready, Definition of Delivered, RACI, release, and
  production-verification artifacts.
- Added requirements, design map, technical plan, test plan, and evidence templates.
- Added new-project Adoption Guide and project starter contract.
- Added local and pull-request validation for decision IDs, schema/template, links,
  and Markdown fenced blocks.
