# Tapia MCP Integration Guide

Tapia MCP is the recommended conditional implementation of the
`apple/ios-simulator-automation` capability for AI-agent-heavy Apple projects.

It complements the Xcode MCP, XCUITest, and repository commands. It does not replace
them.

## Adoption decision

Adopt Tapia when at least one is true:

- coding agents implement or review material application UI;
- critical simulator flows are exercised repeatedly during vertical-slice work;
- local runtime evidence is required for `CODE_COMPLETE` or `QA_ACCEPTED`;
- accessibility identifiers and semantic simulator flows can be maintained by the
  project.

It remains optional for non-UI targets, small experiments, or projects where agents do
not control the Simulator.

## Supported scope

Tapia evidence may support:

- local runtime behavior;
- design-state review;
- accessibility-tree inspection;
- repeatable simulator smoke flows;
- evidence for `CODE_COMPLETE` and, with the designated reviewer, `QA_ACCEPTED`.

Tapia evidence alone never proves:

- real-device behavior;
- TestFlight or App Store distribution;
- `PRODUCTION_VERIFIED`;
- `DELIVERED`.

## Install and pin

The evaluated internal source is:

- repository: `Agilefreaks/tapia-mcp`;
- package version: `0.2.0`;
- pinned revision: `e1defb92367a5f55ef28e3d8b414dc8b7b64b04f`.

Follow the installer and doctor instructions in the Tapia repository. Until Tapia has
a consumable release tag, record the evaluated commit in `tooling/tools.yml` and the
resolved local revision in the project handoff.

Run the health check from the Tapia source checkout before an agent session (or use
`tapia-doctor` when that helper has deliberately been exposed on `PATH`):

~~~bash
./scripts/tapia-doctor
~~~

## Project configuration

Copy `templates/project/tools/tapia/mcp.example.json` to `.mcp.json` only when the
project adopts Tapia. Merge it with existing MCP servers instead of overwriting the
project configuration.

Keep the server project-scoped so its working directory is the application root and it
can discover `tapia.flows.yaml`.

Copy `tapia.flows.example.yaml` to the application root, rename it to
`tapia.flows.yaml`, replace the sample bundle identifier, and define only stable,
valuable flows.

## Selector policy

Selector preference:

1. `accessibilityIdentifier` / AXIdentifier;
2. stable accessible label;
3. element type plus an explicit occurrence;
4. coordinates only as a documented last resort.

Identifiers are a testing contract, not a replacement for useful VoiceOver labels.
Keep identifiers semantic and stable across copy and localization changes.

## Agent operating rules

Before using Tapia, the agent reads `AGENTS.md`, the Delivery Packet, acceptance IDs,
and mapped Figma nodes. It records:

- simulator model and OS;
- app bundle ID, build, and commit;
- flow name and relevant parameters;
- observed timestamp and result;
- screenshot/video/log links;
- limitations or unexercised states.

The agent may record or update a flow in the same pull request as the behavior it
verifies. Review flow changes like test changes.

## Guardrails

- Use non-production environments, test accounts, and synthetic data.
- Do not enter production credentials through simulator automation.
- Auto-accept is limited to a bounded Tapia session on a Simulator; it does not grant
  signing, release, flag, external-message, or destructive-data authority.
- Treat system overlays and permissions as separate verification cases when the
  accessibility tree cannot observe them.
- Keep XCUITest for durable CI regression coverage.
- Fall back to `xcrun simctl`, `idb`, or manual verification when Tapia is unhealthy.

## Evidence semantics

A screenshot proves only the rendered state it shows. A successful Tapia flow proves
the declared flow on the identified Simulator build. Neither proves distribution or
production health.

If a flow had no valid exercise, record `not exercised`; do not infer health from the
absence of an error.
