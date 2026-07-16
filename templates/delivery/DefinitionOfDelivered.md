# Definition of Delivered

Acest checklist se completează după release și production verification. `MERGED`,
`QA_ACCEPTED`, `RELEASE_CANDIDATE` sau `RELEASED` nu sunt sinonime cu `DELIVERED`.

## Identitatea livrării

| Câmp | Valoare |
|---|---|
| Delivery ID / revision | |
| Target audience | |
| Channel / environment / cohort | |
| Bundle ID | |
| Marketing version / build | |
| Commit / CI archive | |
| Effective feature flags | |
| Released at | |
| Production verification window | |

## 1. Disponibilitate pentru audiență

- [ ] Build-ul/configurația este accesibilă target audience declarate.
- [ ] Cohorta și procentul efectiv corespund planului aprobat.
- [ ] Feature flags și prerequisites au valorile așteptate.
- [ ] Signing, entitlements și environment configuration au fost confirmate.
- [ ] Versiunea/build-ul observat este cel declarat, nu un build local sau anterior.

## 2. Acceptance

- [ ] Fiecare `must` acceptance ID are rezultat `passed` și evidence.
- [ ] Fiecare `should/could` incomplet are dispoziție aprobată și item legat.
- [ ] Happy path a fost exercitat pe build-ul distribuit.
- [ ] Failure/edge paths critice au fost verificate la nivelul potrivit.
- [ ] Nu există diferențe nedeclarate între requirements, Figma și behavior.
- [ ] Product a confirmat outcome-ul pentru audiența declarată.

## 3. Quality gates

- [ ] Build/CI.
- [ ] Unit/integration/UI tests aplicabile.
- [ ] Runtime behavior.
- [ ] Design parity și deviații aprobate.
- [ ] Accessibility.
- [ ] Localization.
- [ ] Performance/energy/memory/network aplicabil.
- [ ] Reliability/offline/retry/cancellation/migration aplicabil.
- [ ] Privacy și data handling.
- [ ] Security/auth/permissions/secrets.
- [ ] Analytics și consent.
- [ ] Distribution/install/upgrade.

Pentru orice `not applicable` există motiv. Pentru orice waiver există approver,
mitigation, expiry și follow-up.

## 4. Production verification

- [ ] Install sau upgrade și launch au fost verificate pe device reprezentativ.
- [ ] Critical path a fost exercitat proaspăt.
- [ ] Backend/dependency requests relevante au outcome-ul așteptat.
- [ ] Crash/error/performance signals au fost interogate pentru fereastra corectă.
- [ ] Evenimentul analytics așteptat a fost generat și ingestia verificată, dacă există
  consimțământ și este aplicabil.
- [ ] Evidence include build, environment, actor și timestamp.
- [ ] Datele nu provin exclusiv de la alt build sau înainte de release.
- [ ] Fereastra are trafic/exercițiu valid; altfel itemul este marcat `not exercised`.

## 5. Risk și operare

- [ ] Nu există P0/P1 deschis.
- [ ] Nu există release blocker deschis.
- [ ] Nu există waiver expirat.
- [ ] Known limitations sunt vizibile Product, QA, Support și Release.
- [ ] Rollback/mitigation rămâne executabil și are owner.
- [ ] Dashboards/queries și incident path sunt legate.
- [ ] Support/release notes sunt actualizate când sunt necesare.

## 6. Integritatea Delivery Packet-ului

- [ ] `delivery.yml` validează contra schemei curente.
- [ ] `current_status` nu a fost avansat automat fără approvals.
- [ ] Status history conține actor, timp, reason și evidence.
- [ ] PR, CI, release console și telemetry links sunt actuale.
- [ ] Nicio dovadă nu conține secret sau PII neautorizat.
- [ ] Follow-up-urile și defectele au itemuri legate.

## Aprobări finale

| Rol | Decizie | Actor | Dată | Evidence/link |
|---|---|---|---|---|
| Runtime verifier | Verified / Not verified | | | |
| QA / Acceptance owner | Approved / Rejected / Conditional | | | |
| Release owner | Approved / Rejected / Conditional | | | |
| Product / Delivery owner | Approved / Rejected / Conditional | | | |

**Decizie finală:** `DELIVERED / REMAINS PRODUCTION_VERIFIED / REMAINS RELEASED / REOPENED`

**Scope-ul exact al afirmației Delivered:**

**Limitări și follow-up:**

---
