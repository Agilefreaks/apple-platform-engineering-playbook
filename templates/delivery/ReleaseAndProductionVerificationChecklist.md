# Release and Production Verification Checklist

Acest artefact acoperă tranzițiile `QA_ACCEPTED → RELEASE_CANDIDATE → RELEASED →
PRODUCTION_VERIFIED`. Se completează pentru build-ul și cohorta efectivă.

## Release identity

| Câmp | Valoare |
|---|---|
| Delivery ID / revision | |
| Environment | |
| Channel | |
| Target audience / cohort / percentage | |
| Bundle ID | |
| Marketing version | |
| Build number | |
| Commit | |
| CI/archive run | |
| Release operator | |
| Planned window | |

## 1. Pre-release candidate

- [ ] Requirements, Figma reviewed version și acceptance IDs nu s-au schimbat material.
- [ ] QA_ACCEPTED se referă la acest build sau la un build demonstrabil echivalent.
- [ ] Toate must acceptance criteria au passed evidence.
- [ ] Design și accessibility reviews sunt închise pentru UI material.
- [ ] Open defects au severity, owner și disposition aprobată.
- [ ] Nu există P0/P1 sau release blocker.
- [ ] Waivers sunt valide, neexpirate și vizibile ownerilor riscului.
- [ ] Release notes și known limitations sunt pregătite.

## 2. Build, signing și configuration

- [ ] Clean archive a fost produs de toolchain/CI suportat.
- [ ] Bundle ID, version, build și commit corespund Delivery Packet-ului.
- [ ] Signing certificate și provisioning profile sunt cele așteptate.
- [ ] Entitlements și capabilities sunt corecte.
- [ ] Environment URLs și public client configuration sunt corecte.
- [ ] Nu există debug flags, test endpoints, mock data sau secrete în build.
- [ ] dSYM/symbols și crash reporting upload sunt confirmate.
- [ ] Privacy manifest și required-reason APIs sunt verificate.
- [ ] App Store/TestFlight compliance și metadata sunt complete.

## 3. Compatibilitate și date

- [ ] API/backend suportă versiunile instalate pe fereastra declarată.
- [ ] Schema/migrations sunt forward-safe și au fost testate.
- [ ] Upgrade de la versiunile relevante a fost verificat.
- [ ] Downgrade assumptions nu sunt folosite ca rollback implicit.
- [ ] Cache, stale data și offline behavior au fost evaluate.
- [ ] Repetarea acțiunilor și idempotency sunt sigure unde se aplică.
- [ ] Feature flags au defaults sigure pentru clienții vechi și noi.

## 4. Observability readiness

- [ ] Crash/error/performance dashboards sau queries sunt legate.
- [ ] Backend/dependency health queries sunt legate.
- [ ] Typed product analytics events și schema sunt documentate.
- [ ] Consent behavior și test account/cohort sunt cunoscute.
- [ ] Critical-path correlation include build/environment fără PII.
- [ ] Verificatorul poate identifica lipsa traficului versus trafic sănătos.
- [ ] Incident owner, canal și escalation path sunt active în fereastra release-ului.

## 5. Rollout și rollback

- [ ] Canalul și cohorta au aprobarea Product + Release.
- [ ] Flag names, prerequisites, defaults și release values sunt înregistrate.
- [ ] Abort conditions au prag, fereastră și owner.
- [ ] Kill switch/flag-off a fost revizuit sau testat proporțional cu riscul.
- [ ] Server fallback și backward compatibility sunt confirmate.
- [ ] Data migration nu lasă date corupte după dezactivarea behavior-ului.
- [ ] Hotfix path și timpul estimat sunt cunoscute.
- [ ] Communication path pentru support/stakeholders este pregătit.

## 6. Aprobări RELEASE_CANDIDATE

| Rol | Decizie | Actor | Dată | Evidence/link |
|---|---|---|---|---|
| Engineering | Pending / Approved / Rejected / Conditional | | | |
| QA | Pending / Approved / Rejected / Conditional | | | |
| Product — cohortă | Pending / Approved / Rejected / Conditional | | | |
| Release | Pending / Approved / Rejected / Conditional | | | |
| Security/Privacy/Legal — după risc | Pending / Approved / Rejected / Conditional / N/A | | | |

**Decizie:** `RELEASE_CANDIDATE / NOT READY`

## 7. Execuția release-ului

- [ ] Operatorul a confirmat build-ul și target audience înainte de acțiune.
- [ ] Build-ul a fost distribuit în canalul aprobat.
- [ ] Flag/cohort values efective au fost citite după schimbare.
- [ ] Release time și operatorul sunt înregistrate.
- [ ] App Store/TestFlight status și link sunt înregistrate.
- [ ] Nicio acțiune neaprobată nu a extins cohorta sau scope-ul.
- [ ] `current_status` a fost setat `RELEASED`, nu `DELIVERED`.

## 8. Production verification

### Setup

- [ ] Verificatorul folosește build-ul distribuit, nu un debug/local build.
- [ ] Device, OS, account state, locale și network conditions sunt înregistrate.
- [ ] Build/version și effective flags sunt confirmate în aplicație/sistem.
- [ ] Fereastra de telemetry începe după release/config change.

### Smoke și acceptance

- [ ] Install sau upgrade.
- [ ] Launch și authentication/session state.
- [ ] Critical path complet.
- [ ] Cel puțin un failure/recovery path critic, dacă este sigur.
- [ ] Persistență/background/resume când sunt în acceptance.
- [ ] Rezultat vizibil corespunde Figma/acceptance pentru stările verificate.
- [ ] Evidence este legată de acceptance IDs.

### Telemetry

- [ ] Request/dependency outcome relevant a fost observat.
- [ ] Crash/error signals au fost verificate în fereastra corectă.
- [ ] Performance guardrails au fost verificate unde se aplică.
- [ ] Product analytics event a ajuns în destinație, unde consent permite.
- [ ] Build, environment și cohort pot fi identificate fără expunere de PII.
- [ ] Semnalele sunt proaspete și aparțin release-ului curent.

### Interpretarea dovezilor

Selectează exact una:

- [ ] **Exercised and healthy:** a existat exercițiu valid și nu au apărut blockers.
- [ ] **Exercised and unhealthy:** a existat exercițiu valid și au apărut erori/blockers.
- [ ] **Not exercised:** nu există trafic/control test suficient; absența erorilor nu
  este interpretată ca sănătate.
- [ ] **Inconclusive:** semnalele sunt contradictorii sau telemetry lipsește.

Pentru `Not exercised` sau `Inconclusive`, itemul rămâne `RELEASED` ori `BLOCKED` și are
owner + următoarea verificare. Nu avansează la `PRODUCTION_VERIFIED`.

## 9. Decizie și închidere

| Rol | Decizie | Actor | Dată | Evidence/link |
|---|---|---|---|---|
| Runtime verifier | Verified / Not verified / Inconclusive | | | |
| Engineering/Operations | Healthy / Unhealthy / Inconclusive | | | |
| QA | Accepted / Rejected / Conditional | | | |
| Release owner | Continue / Pause / Roll back / Mitigate | | | |

**Status rezultat:** `PRODUCTION_VERIFIED / REMAINS RELEASED / BLOCKED / REOPENED`

**Evidence window și sumar:**

**Anomalii, missing observability și follow-up:**

**Rollback/mitigation executat, dacă este cazul:**

---
