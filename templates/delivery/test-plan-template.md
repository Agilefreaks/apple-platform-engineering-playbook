# Test Plan — <DELIVERY-ID> <Title>

## Test identity

| Câmp | Valoare |
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

## State și failure matrix

| Categorie | Scenariu | Injection/setup | Expected recovery | Acceptance/risk | Status |
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

## UI și design verification

| Screen/state | Device/layout | Appearance | Dynamic Type | Figma node/version | Evidence/status |
|---|---|---|---|---|---|
| | | | | | |

## Accessibility

- [ ] VoiceOver semantics/order/actions.
- [ ] Dynamic Type și text expansion.
- [ ] Contrast și non-color cues.
- [ ] Focus/keyboard/tvOS behavior.
- [ ] Reduce Motion.
- [ ] Touch targets și alternative pentru gestures.

## Localization

- [ ] String Catalog și translator context.
- [ ] Locale-sensitive values.
- [ ] Long text/truncation/wrapping.
- [ ] RTL, dacă este suportat.
- [ ] VoiceOver pronunciation relevantă.

## Non-functional

| Zonă | Budget/guardrail | Metodă | Baseline | Result/evidence |
|---|---|---|---|---|
| Launch/responsiveness | | | | |
| Memory/scrolling | | | | |
| Network/media/energy | | | | |
| Reliability | | | | |
| Privacy/security | | | | |
| Analytics ingestion | | | | |

## Commands și reproducibility

| Check | Command/workflow | Toolchain/destination | Result link |
|---|---|---|---|
| Format/lint | | | |
| Build | | | |
| Unit/integration | | | |
| UI | | | |
| Runtime | | | |

## Defects și disposition

| Defect | Severity | Acceptance/risk | Owner | Disposition | Release blocker |
|---|---|---|---|---|---:|
| | | | | | |

## Exit criteria

- [ ] Toate must acceptance criteria sunt passed.
- [ ] Nu există P0/P1 sau release blocker.
- [ ] Quality areas sunt passed ori au `not applicable`/waiver valid.
- [ ] Dovezile identifică build-ul, environment-ul, actorul și timpul.
- [ ] Known limitations și follow-up sunt explicite.
- [ ] QA/acceptance owner a înregistrat decizia.
