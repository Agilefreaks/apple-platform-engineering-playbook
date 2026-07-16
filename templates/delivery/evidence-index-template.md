# Evidence Index — <DELIVERY-ID> <Title>

Acest index nu copiază logs sau date sensibile. Leagă dovezi durabile și explică exact
ce demonstrează fiecare.

## Build identity

| Câmp | Valoare |
|---|---|
| Delivery revision | |
| Bundle ID | |
| Version/build | |
| Commit | |
| CI/archive run | |
| Environment/channel/cohort | |
| Effective flags | |

## Evidence register

| ID | Kind | Acceptance/gate | Build/environment | Observed at | Observer | Link | Ce demonstrează | Limitări |
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

| Gap | Impact asupra afirmației | Minimum safe change | Owner | Follow-up |
|---|---|---|---|---|
| | | | | |

## Integritate și privacy

- [ ] Fiecare dovadă identifică build/environment/timestamp unde este relevant.
- [ ] Dovada este proaspătă pentru gate-ul pe care îl susține.
- [ ] Nu există secrete, tokens, credentials sau PII neautorizat.
- [ ] Screenshot-urile și video-urile folosesc cont/test data sigură.
- [ ] Lipsa traficului este `not exercised`, nu `healthy`.
- [ ] Linkurile sunt accesibile reviewerilor autorizați.
