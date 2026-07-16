# AGENTS.md — <PROJECT_NAME>

Short operational contract for developers and coding agents. Project-specific facts
belong here; durable rationale belongs in `docs/adr/`.

## Authority

1. Current approved requirements and task constraints.
2. Project ADRs.
3. This file.
4. Apple Platform Engineering Playbook `<TAG_OR_COMMIT>`.
5. Nearby legacy conventions.

Architecture standard: `<PLAYBOOK_URL>/docs/architecture/AppleTeamArchitectureStandard.md`

Delivery standard: `<PLAYBOOK_URL>/docs/delivery/AppleTeamDeliveryLoopStandard.md`

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
| `apple/swift-concurrency` | `<MAPPING>` | `<VERSION>` |
| `apple/swift-testing` | `<MAPPING>` | `<VERSION>` |
| `apple/ios-runtime-debugging` | `<MAPPING>` | `<VERSION>` |

Add conditional mappings only when that work is in scope. A missing skill uses the
standard/checklist as manual fallback and is reported as a tooling gap.

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
