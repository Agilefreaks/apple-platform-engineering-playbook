# Changelog

All notable changes to the complete playbook package are recorded here.

## Unreleased

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
