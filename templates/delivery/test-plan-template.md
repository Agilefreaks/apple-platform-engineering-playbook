# Test Plan — <DELIVERY-ID> <Title>

## Test identity

| Field | Value |
|---|---|
| Delivery revision | |
| Build/commit under test | |
| QA / acceptance owner | |
| Environments | |
| Device/OS matrix | |
| Account/permission states | |

## Acceptance coverage

| Acceptance ID | Priority | Automated tests | Manual/runtime scenario | Distributed proof | Status |
|---|---|---|---|---|---|
| AC-01 | Must | | | | Pending |

## Functional scenarios

| ID | Preconditions | Steps/intent | Expected result | Level | Evidence |
|---|---|---|---|---|---|
| T-01 | | | | Unit / Integration / UI / Runtime | |

## State and failure matrix

| Category | Scenario | Injection/setup | Expected recovery | Acceptance/risk | Status |
|---|---|---|---|---|---|
| Loading | | | | | |
| Empty/partial | | | | | |
| Offline/timeout | | | | | |
| API/SDK failure | | | | | |
| Permission/auth | | | | | |
| Retry/duplicate | | | | | |
| Cancellation | | | | | |
| Background/resume | | | | | |
| Migration/upgrade | | | | | |

## UI and design verification

| Screen/state | Device/layout | Appearance | Dynamic Type | Figma node/version | Evidence/status |
|---|---|---|---|---|---|
| | | | | | |

## Accessibility

- [ ] VoiceOver semantics/order/actions.
- [ ] Dynamic Type and text expansion.
- [ ] Contrast and non-color cues.
- [ ] Focus/keyboard/tvOS behavior.
- [ ] Reduce Motion.
- [ ] Touch targets and alternatives for gestures.

## Localization

- [ ] String Catalog and translator context.
- [ ] Locale-sensitive values.
- [ ] Long text/truncation/wrapping.
- [ ] RTL, if supported.
- [ ] Relevant VoiceOver pronunciation.

## Non-functional

| Area | Budget/guardrail | Method | Baseline | Result/evidence |
|---|---|---|---|---|
| Launch/responsiveness | | | | |
| Memory/scrolling | | | | |
| Network/media/energy | | | | |
| Reliability | | | | |
| Privacy/security | | | | |
| Analytics ingestion | | | | |

## Commands and reproducibility

| Check | Command/workflow | Toolchain/destination | Result link |
|---|---|---|---|
| Format/lint | | | |
| Build | | | |
| Unit/integration | | | |
| UI | | | |
| Runtime | | | |

## Defects and disposition

| Defect | Severity | Acceptance/risk | Owner | Disposition | Release blocker |
|---|---|---|---|---|---:|
| | | | | | |

## Exit criteria

- [ ] All must acceptance criteria are passed.
- [ ] There is no P0/P1 or release blocker.
- [ ] Quality areas are passed or have a valid `not applicable`/waiver.
- [ ] Evidence identifies the build, environment, actor, and time.
- [ ] Known limitations and follow-up are explicit.
- [ ] The QA/acceptance owner has recorded the decision.
