# Evidence Index — <DELIVERY-ID> <Title>

This index does not copy logs or sensitive data. It links durable evidence and explains
exactly what each item demonstrates.

## Build identity

| Field | Value |
|---|---|
| Delivery revision | |
| Bundle ID | |
| Version/build | |
| Commit | |
| CI/archive run | |
| Environment/channel/cohort | |
| Effective flags | |

## Evidence register

| ID | Kind | Acceptance/gate | Build/environment | Observed at | Observer | Link | What it demonstrates | Limitations |
|---|---|---|---|---|---|---|---|---|
| EV-001 | Test / Screenshot / Video / Runtime / Telemetry / Analytics / Approval / Release | | | | | | | |

## Acceptance summary

| Acceptance ID | Status | Automated evidence | Runtime evidence | Distributed evidence | Approver |
|---|---|---|---|---|---|
| AC-01 | Pending / Passed / Failed / N/A | | | | |

## Gate summary

| Gate | Status | Evidence IDs | Approval IDs | Missing/waiver |
|---|---|---|---|---|
| READY | | | | |
| PLANNED | | | | |
| CODE_COMPLETE | | | | |
| MERGED | | | | |
| QA_ACCEPTED | | | | |
| RELEASE_CANDIDATE | | | | |
| RELEASED | | | | |
| PRODUCTION_VERIFIED | | | | |
| DELIVERED | | | | |

## Production verification window

| Signal | Query/window | Traffic/exercise | Result | Interpretation | Evidence ID |
|---|---|---|---|---|---|
| Critical path | | | | Exercised healthy / unhealthy / not exercised / inconclusive | |
| Crashes/errors | | | | | |
| Backend/dependency | | | | | |
| Performance | | | | | |
| Product analytics | | | | | |

## Missing observability

| Gap | Impact on the claim | Minimum safe change | Owner | Follow-up |
|---|---|---|---|---|
| | | | | |

## Integrity and privacy

- [ ] Every piece of evidence identifies build/environment/timestamp where relevant.
- [ ] The evidence is fresh for the gate it supports.
- [ ] There are no secrets, tokens, credentials, or unauthorized PII.
- [ ] Screenshots and videos use safe account/test data.
- [ ] Absence of traffic is `not exercised`, not `healthy`.
- [ ] Links are accessible to authorized reviewers.
