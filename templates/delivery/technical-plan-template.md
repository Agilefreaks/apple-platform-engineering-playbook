# Technical Plan — <DELIVERY-ID> <Title>

## Context and outcome

- Delivery revision:
- Acceptance IDs:
- Architecture standard/version:
- Current architecture seam:
- Engineering owner/reviewers:

## Solution summary

Describe the vertical slice, its boundaries, and why the solution produces the required
outcome.

## Acceptance traceability

| Acceptance ID | Feature/modules | UI/state/navigation | Data/dependency | Tests | Runtime evidence |
|---|---|---|---|---|---|
| AC-01 | | | | | |

## Architecture and ownership

- Feature owner and folder/module:
- View / optional ViewModel / Router / Client boundaries:
- Shared state and source of truth:
- Dependency injection and composition root changes:
- Navigation/deep link/push impact:
- DesignSystem/Core promotion, if there is a second consumer:
- Required ADRs:
- TCA impact, only if the project is approved for TCA:

## Data and integration

| Area | Contract/decision | Failure behavior | Compatibility |
|---|---|---|---|
| API/SDK | | | |
| DTO/mapping | | | |
| Storage/cache | | | |
| Migration | | | |
| Offline/stale data | | | |
| Auth/session | | | |

## State and concurrency

- State machine and valid concurrent states:
- MainActor/nonisolated boundaries:
- Structured tasks and ownership:
- Cancellation:
- Retry/idempotency/duplicate action:
- Background/resume:
- Sendable/actor risks:

## UI quality

- Figma reviewed version and mapped nodes:
- Adaptive layout/device matrix:
- Accessibility plan:
- Localization plan:
- Motion/Reduce Motion:
- Performance/memory/energy budgets:

## Analytics and observability

| Signal | Type | Trigger/schema | Consent/privacy | Verification query/evidence |
|---|---|---|---|---|
| | Product event | | | |
| | Operational log/metric | | | |
| | Crash/error context | | | |

## Test strategy

| Level | Scope | Acceptance/risk | Command/environment | Expected evidence |
|---|---|---|---|---|
| Unit | | | | |
| Integration | | | | |
| UI | | | | |
| Runtime | | | | |
| Distributed build | | | | |

## Delivery slices

| Slice | Demonstrable outcome | Files/modules | Gate/evidence | Dependency |
|---|---|---|---|---|
| 1 | | | | |

Every slice keeps the app buildable and avoids unverified states/configurations.

## Rollout, abort, and rollback

- Channel/environment/cohort:
- Feature flags/defaults/prerequisites:
- Backend compatibility window:
- Abort thresholds and owner:
- Flag-off/server fallback/data safety:
- Hotfix path:
- Production verification plan:

## Risks, spikes, and decisions

| ID | Risk/unknown | Impact | Mitigation/spike | Owner | Due | Status |
|---|---|---|---|---|---|---|
| R-01 | | | | | | |

## Engineering approval

| Actor | Role | Decision | Date | Conditions/evidence |
|---|---|---|---|---|
| | Engineering owner | Pending / Approved / Rejected / Conditional | | |
