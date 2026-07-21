# New iOS Project — Information Gathering Checklist

Fill this in **before** running `scripts/bootstrap_project.sh`. It maps 1:1 to the
placeholders you must replace afterward: the "Establish project facts" section of
[docs/AdoptionGuide.md](../../docs/AdoptionGuide.md), the `<PLACEHOLDER>` fields in
[AGENTS.template.md](AGENTS.template.md), and the
[Definition of Ready](../delivery/DefinitionOfReady.md).

When every row has a value and section 12 passes, the project is ready for its first
delivery item.

| Meta | Value |
|---|---|
| Project name | |
| Filled in by | |
| Date | |
| Playbook tag/commit adopted | |

---

## 1. Playbook adoption unit

| Item | Value |
|---|---|
| Playbook Git tag or commit | |
| Architecture Standard version (current `2.1`) | |
| Delivery Loop version (current `0.1`) | |
| Playbook upgrade owner | |
| Vendored vs. linked decision | |

## 2. Product & platform identity

| Item | Value |
|---|---|
| Product name | |
| Bundle identifier(s) | |
| Platforms (iOS / iPadOS / tvOS) | |
| Minimum OS version(s) | |
| Device classes & orientations | |
| Locales & localization behavior | |

## 3. Apple account, signing & release

| Item | Value |
|---|---|
| Apple Developer team | |
| App Store Connect ownership | |
| Signing owner (role/team) | |
| Certificates & provisioning profiles | |
| Entitlements & protected-credentials owner | |
| Release authority | |
| TestFlight / App Store channels & cohorts | |
| Production verification approach | |
| Rollback strategy | |

## 4. Build & toolchain facts

| Item | Value |
|---|---|
| Xcode version | |
| Swift version | |
| Default scheme | |
| Build configurations | |
| Simulator/device destination (CI + local) | |
| Formatter tooling | |
| Linter tooling | |

Deterministic commands (populate the AGENTS.md command table):

| Intent | Command |
|---|---|
| Setup | |
| Format | |
| Lint | |
| Build | |
| Unit/integration tests | |
| Critical UI tests | |
| Runtime launch | |
| Delivery validation | |

## 5. Environments & configuration

| Item | Value |
|---|---|
| Environment list (dev/staging/prod/…) | |
| Configuration sources (`.xcconfig` paths) | |
| API endpoints per environment | |
| Feature-flag system & owner | |
| Test accounts / test data access | |

## 6. Repository & process ownership

| Item | Value |
|---|---|
| Repository owners | |
| Code review policy | |
| Protected branch rules | |
| CI runner / platform | |
| Product owner | |
| Design owner | |
| Engineering owner | |

## 7. Privacy, security & compliance

| Item | Value |
|---|---|
| Data classification / privacy impact | |
| Privacy/security review triggers & owner | |
| Third-party SDK policy | |
| Privacy manifest impact | |
| Legal / content / licensing constraints | |
| Mandatory reviewers for risk-gated work | |

## 8. Observability & operations

| Item | Value |
|---|---|
| Analytics events & consent behavior | |
| Telemetry owner | |
| Logging / crash reporting / performance monitoring | |
| Incident path | |
| Support ownership | |
| Success metrics & guardrails approach | |

## 9. Architecture decisions

| Item | Value |
|---|---|
| TCA status (not adopted / adopted-by-ADR) | |
| Composition root path | |
| Feature root path | |
| Core root path | |
| DesignSystem root path | |
| Tests & fixtures paths | |
| Planned deviations (each needs an ADR) | |

## 10. Tooling / skills / MCP

| Canonical skill | Runtime mapping | Version |
|---|---|---|
| `apple/swift-concurrency` | | |
| `apple/swift-testing` | | |
| `apple/ios-runtime-debugging` | | |

| Capability | Runtime implementation | Adopt? | Health/setup command |
|---|---|---|---|
| `apple/xcode-automation` | | Recommended | |
| `apple/ios-simulator-automation` (Tapia) | | Conditional — only for agent-heavy local Simulator flows | |

> Tapia: enable only after reviewing the pinned revision, running `tapia-doctor`, and
> isolating the Simulator from production accounts/data. See
> [docs/tooling/TapiaMCPGuide.md](../../docs/tooling/TapiaMCPGuide.md).

## 11. First delivery item readiness

| Item | Value / status |
|---|---|
| Delivery ID | |
| User-framed problem & observable outcome | |
| Acceptance criteria with stable `AC-*` IDs | |
| Figma node IDs + reviewed version/timestamp (or `N/A` approved) | |
| API/backend contract available or approved stub | |
| Every unknown has owner, due date, blocking flag | |

## 12. New-project readiness review

Project is ready for its first feature when all are true (AdoptionGuide §8):

- [ ] Project facts and owners are recorded.
- [ ] The app builds and launches from a clean checkout.
- [ ] Test, lint, format, runtime, and delivery validation commands exist.
- [ ] Required and conditional skills/tools are declared (Tapia only if conditions apply).
- [ ] Environments and signing responsibilities are explicit.
- [ ] Privacy, security, analytics, observability, release, and rollback owners exist.
- [ ] The project has adopted a specific playbook revision.
- [ ] Deviations have ADRs.
- [ ] The first delivery item can pass Definition of Ready.
