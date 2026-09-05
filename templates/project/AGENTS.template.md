# AGENTS.md — <PROJECT_NAME>

Short operational contract for developers and coding agents. Project-specific facts
belong here; durable rationale belongs in `docs/adr/`.

## Authority

1. Current approved requirements and task constraints.
2. Project ADRs.
3. This file.
4. Apple Platform Engineering Playbook `<TAG_OR_COMMIT>`.
5. Nearby legacy conventions.

The playbook repository is public, but a browser `blob/` URL is still not a readable reference —
it returns an HTML page rather than the document, which leaves an agent with this file's summary
and nothing else. Read a playbook document at the pinned commit in `.apple-playbook-version`,
with the GitHub CLI when one is installed and authenticated, and over plain HTTPS when it is not:

~~~bash
scripts/check_playbook_access.sh   # confirms the standard is readable, and prints which command to use

gh api 'repos/<PLAYBOOK_SLUG>/contents/<path>?ref=<PLAYBOOK_COMMIT>' --jq .content | base64 -d

curl -fsSL 'https://raw.githubusercontent.com/<PLAYBOOK_SLUG>/<PLAYBOOK_COMMIT>/<path>'
~~~

Architecture standard: `docs/architecture/AppleTeamArchitectureStandard.md`

Delivery standard: `docs/delivery/AppleTeamDeliveryLoopStandard.md`

Handbook (rationale): `docs/architecture/AppleTeamHandbook.md`

If the access check fails, say so in the handoff and fall back to this file plus current primary
Apple documentation. Do not proceed as though the standard had been read.

## Project facts

| Fact | Value |
|---|---|
| Platforms | `<iOS / iPadOS / tvOS>` |
| Minimum OS | `<VERSION>` |
| Xcode / Swift | `<VERSIONS>` |
| Bundle IDs | `<IDS>` |
| Default scheme/configuration | `<SCHEME> / <CONFIG>` |
| Simulator destination | `<DESTINATION>` |
| Signing owner | `<ROLE_OR_TEAM>` |
| Release owner | `<ROLE_OR_TEAM>` |
| Privacy/security owner | `<ROLE_OR_TEAM>` |
| Telemetry owner | `<ROLE_OR_TEAM>` |

## Deterministic commands

| Intent | Command | Expected result |
|---|---|---|
| Setup | `<COMMAND>` | Clean checkout becomes buildable |
| Format | `<COMMAND>` | No diff after formatting |
| Lint | `<COMMAND>` | Zero blocking findings |
| Build | `<COMMAND>` | Supported scheme/destination builds |
| Unit/integration tests | `<COMMAND>` | Test suite passes |
| Critical UI tests | `<COMMAND>` | Declared critical flows pass |
| Runtime launch | `<COMMAND>` | App launches on declared destination |
| Delivery validation | `<COMMAND>` | Delivery Packet validates |
| Playbook access | `scripts/check_playbook_access.sh` | the architecture standard is readable at the pinned commit, through `gh` when it is installed and authenticated and over plain HTTPS otherwise |

## Architecture and folders

- Default: feature-first modular MVVM/R under ARCH v2.1.
- TCA status: `<NOT_ADOPTED / ADOPTED_BY_ADR>`.
- Composition root: `<PATH>`.
- Feature root: `<PATH>`.
- Core root: `<PATH>`.
- DesignSystem root: `<PATH>`.
- Tests and fixtures: `<PATHS>`.
- Delivery items: `delivery/items/`.

## Environments and configuration

- Environments: `<LIST>`.
- Configuration sources: `<XCCONFIG_PATHS>`.
- Feature flags and owner: `<SYSTEM_AND_OWNER>`.
- Test accounts/data: `<SAFE_ACCESS_INSTRUCTIONS>`.
- Never place secrets, tokens, or production credentials in this file or the repo.

## Skills

Canonical requirements are in `tooling/skills.yml`. Map them to the installed runtime:

| Canonical skill | Runtime skill/tool | Version |
|---|---|---|
| `apple/swift-concurrency` | `swift-concurrency-pro@swift-concurrency-agent-skill` | `<VERSION>` |
| `apple/swift-testing` | `swift-testing-pro@swift-testing-agent-skill` | `<VERSION>` |
| `apple/ios-runtime-debugging` | none installed — tooling gap | — |
| `apple/swiftui-patterns` (conditional) | `swiftui-pro@swiftui-agent-skill` | `<VERSION>` |

`.claude/settings.json` declares the marketplaces and enables the plugins, so a fresh clone
installs them with no manual step. That file is the repository's statement of which skills it
expects; a skill that lives only in one developer's user settings is invisible to everyone else
and to CI.

Add conditional mappings only when that work is in scope. A missing skill uses the
standard/checklist as manual fallback and is reported as a tooling gap.

## Tool capabilities

Canonical declarations are in `tooling/tools.yml`. Record the runtime mapping and
enable only capabilities whose adoption conditions apply:

| Capability | Runtime implementation | Adoption | Health/setup command |
|---|---|---|---|
| `apple/xcode-automation` | `<SELECTED_IMPLEMENTATION_AND_PINNED_VERSION>` | Recommended | `<COMMAND>` |
| `apple/ios-simulator-automation` | Tapia MCP | Recommended/conditional | `<TAPIA_SOURCE_CLONE>/scripts/tapia-doctor` |

Name the selected Xcode-automation implementation and its pinned version, not just
"an MCP". The make targets stay authoritative: reproduce any gate result through them
before reporting it, because no MCP implementation runs in CI.

`.mcp.json` carries the server configuration and `.claude/settings.json` approves it, both
committed. Replace `<EVALUATED_VERSION>` with the version actually evaluated on this project —
never a floating tag. The shipped configuration disables the server's own telemetry and names
every enabled workflow explicitly, because that variable replaces the server's defaults rather
than extending them. A project that keeps Xcode open and prefers the first-party bridge should
swap the file's contents and say so here.

When Tapia is enabled, pin the reviewed revision, use stable
`accessibilityIdentifier` values, isolate the Simulator from production accounts/data,
and keep command approval narrow. A Tapia flow is local Simulator evidence only; it
does not replace XCUITest, CI, real-device/distributed-build checks, or human approval.
If unavailable, use a declared fallback and report the reduced evidence level.

## Continue within authorized scope

When implementation is requested, continue through implementation, relevant validation,
and evidence capture within the authorized scope and applicable approval gates. Do not
stop at a plan or merely suggest checks you can run. Preserve review-only and
proposal-only limits.

Reuse authorization already given for the same action and scope. Resolve routine,
reversible implementation choices using project evidence. Ask only when missing
information materially affects correctness, scope, or a protected action, or when an
explicit approval requirement remains unmet.

If one step is blocked, continue independent authorized work and report the blocker
precisely. Distinguish task completion from formal Product/Design/Engineering/QA/Release
approval. This rule does not authorize additional Git actions, release, scope expansion,
or bypassing any approval gate.

## Protected actions

Agents require explicit human authority before:

- signing/certificate/entitlement changes;
- App Store/TestFlight submission or production release;
- production feature-flag/cohort changes;
- privacy/security/legal waiver;
- external communication or destructive production operations;
- declaring final Product/Design/Release approval.

## Local deviations

| Area | Summary | ADR | Owner | Review date |
|---|---|---|---|---|
| None | | | | |
