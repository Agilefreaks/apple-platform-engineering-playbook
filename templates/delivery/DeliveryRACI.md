# Delivery Loop RACI

Matrice baseline pentru Apple Team. Se adaptează proiectului fără a elimina ownerul
unic de decizie și fără a transforma un agent într-o autoritate umană implicită.

## Legendă

- **A — Accountable:** aprobă rezultatul; ideal un singur A pe activitate.
- **R — Responsible:** execută munca.
- **C — Consulted:** oferă input înaintea deciziei.
- **I — Informed:** primește rezultatul/decizia.
- **—:** fără responsabilitate implicită.

## Roluri

| Rol | Responsabilitate principală |
|---|---|
| Product (P) | Problemă, outcome, scope, priority, target audience, acceptance final |
| Design (D) | Figma contract, UX, copy, design parity și design accessibility intent |
| Engineering (E) | Arhitectură, plan tehnic, implementare, code quality și technical risk |
| QA (Q) | Test strategy, acceptance execution, exploratory quality și defect disposition |
| Security/Privacy/Legal (S) | Aprobarea riscului în domeniul lor, când este declanșată |
| Release (R) | Signing/release readiness, distribuție, cohortă operațională și rollback execution |
| Analytics/Operations (O) | Measurement contract, telemetry, dashboards și production evidence |
| Delivery owner (L) | Coerența Delivery Packet-ului, gates, status history și follow-up |

## Matrice baseline

| Activitate / Gate | P | D | E | Q | S | R | O | L |
|---|---|---|---|---|---|---|---|---|
| Definește problemă/outcome/scope | A/R | C | C | C | C | I | C | R |
| Scrie acceptance criteria | A | C | C | R | C | I | C | R |
| Aprobă Figma contract | C | A/R | C | C | C | I | — | R |
| Declară target audience | A/R | I | C | C | C | C | C | R |
| Evaluează privacy/security/legal | C | C | R | C | A/R | I | C | I |
| Gate READY | A | A pentru UI | A | C | C după risc | I | C | R |
| Scrie plan tehnic | C | C | A/R | C | C | C | C | I |
| Aprobă arhitectura / ADR | I | C | A/R | C | C | I | — | I |
| Implementează vertical slice | I | C | A/R | C | C | I | C | I |
| Code review | I | C | A/R | C | C | I | — | I |
| Design parity review | C | A/R | R | C | C | I | — | I |
| Accessibility verification | I | A pentru intent | R | A/R pentru verificare | C | I | — | I |
| Test strategy și execuție | C | C | R | A/R | C | I | C | I |
| Defect disposition înainte de release | A | C | R | R | C | C | I | I |
| Gate QA_ACCEPTED | C | A pentru UI material | C | A/R | C | I | I | R |
| Measurement/telemetry readiness | C | I | R | C | C | I | A/R | I |
| Rollout și abort thresholds | A | I | C | C | C | A/R | R | I |
| Rollback plan | I | I | A/R tehnic | C | C | R operațional | C | I |
| Gate RELEASE_CANDIDATE | C | C | A | A | C după risc | A/R | C | R |
| Execută release/flag/cohort | I | I | C | I | I | A/R | C | I |
| Production verification | I | C | R | R | C | C | A/R | R |
| Declară DELIVERED | A | C | C | C | C | C | C | R |
| Incident / mitigation | I | I | R | C | C | A | R | I |
| Reopen / follow-up | A | C | C | C | C | I | C | R |

În tabelele cu mai mulți `A`, fiecare A aprobă numai domeniul său. Delivery ownerul nu
poate substitui aprobarea Product, Design, Security sau Release.

## Echipe mici

Rolurile pot fi deținute de aceeași persoană, cu următoarele guardrails:

- Product authority și release execution rămân explicit atribuite.
- Pentru risc high/critical, autorul codului nu este unicul engineering reviewer.
- Security/Privacy/Legal approval nu este absorbit informal de Engineering.
- QA poate fi o responsabilitate partajată, dar acceptance evidence are owner.
- Orice rol combinat este declarat în `owners`; nu îl deducem din lipsa unui nume.

## Agenți AI

Un agent poate fi `R` pentru analiză, implementare, testare, documentare și colectare de
dovezi. Un agent poate recomanda o decizie și poate înregistra o aprobare autentică
venită de la owner.

Un agent nu devine `A` pentru:

- scope și product acceptance;
- design acceptance;
- privacy/security/legal risk acceptance;
- gate waiver;
- signing, release sau production flag authority;
- declarația finală Delivered.

Un agent nu se prezintă drept reviewer independent al propriului output. Dacă același
agent rulează un review tehnic, rezultatul este o auto-verificare până când policy-ul
proiectului îl acceptă explicit sau intervine un reviewer independent.

## Adaptarea matricei

Orice proiect poate adăuga roluri precum Backend, Data, Support sau Client. Adaptarea:

1. păstrează un owner clar pentru fiecare gate;
2. documentează rolurile combinate;
3. nu elimină approvals cerute de nivelul de risc;
4. este legată din `AGENTS.md` sau Delivery Packet;
5. are owner și dată de review.
