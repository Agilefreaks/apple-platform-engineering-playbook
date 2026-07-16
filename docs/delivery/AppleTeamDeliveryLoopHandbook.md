# Cum livrăm continuu aplicații Apple — v0.1

Handbook-ul Apple Team pentru transformarea requirements + Figma într-un rezultat
livrat și verificat pe iOS, iPadOS și tvOS.

| Metadata | Valoare |
|---|---|
| Status | Propunere v0.1 — pregătită pentru pilot |
| Versiune | 0.1 |
| Owner propus | Apple Platform Team + Product Delivery |
| Audiență | Product, Design, Engineering, QA, Release și agenți AI |
| Companion | AppleTeamDeliveryLoopStandard.md |
| Standard tehnic | Apple Team Architecture Standard v2.1 |
| Review | După fiecare pilot, apoi minimum de două ori pe an |

## Cum folosim acest handbook

Standardul de arhitectură răspunde la întrebarea „cum construim codul?”. Acest handbook
răspunde la întrebarea „cum știm că am transformat o intenție într-un rezultat real,
disponibil și verificat?”.

Documentul de față este sursa canonică pentru oameni. Companion-ul compact este forma
normativă pentru agenți și automatizări. Fiecare decizie are un ID `DLV-*`; setul de
ID-uri trebuie să fie identic în ambele documente.

Acesta este un draft pentru pilot, nu un proces final impus tuturor proiectelor. Îl
testăm pe 1–2 vertical slices reale, măsurăm unde produce claritate și unde adaugă
fricțiune, apoi îl promovăm la v1.0.

---

## 0. Rezumatul deciziilor

| ID | Zonă | Decizie |
|---|---|---|
| DLV-001 | Autoritate | Requirements aprobate, constrângerile de compliance, ARCH și acest standard au precedență explicită. |
| DLV-002 | Unitatea de livrare | Urmărim un rezultat mic, independent verificabil, nu doar un ticket sau un set de fișiere. |
| DLV-003 | Contract requirements | Problema, rezultatul, scope-ul, acceptance, riscurile, măsurarea, rollout-ul și ownerii sunt explicite. |
| DLV-004 | Contract Figma | Păstrăm nodurile exacte, versiunea verificată, stările, tokens, copy, assets, interacțiunile și intenția de accesibilitate. |
| DLV-005 | Delivery Packet | Fiecare rezultat are un `delivery.yml` versionat și legături către planuri și dovezi. |
| DLV-006 | State machine | Statusurile sunt explicite, susținute de dovezi și nu sunt deduse doar din Git sau CI. |
| DLV-007 | Definition of Ready | Implementarea începe după clarificarea cerinței, designului, dependențelor, ownerilor și acceptance-ului. |
| DLV-008 | Plan tehnic | Planul leagă acceptance de arhitectură, date, analytics, teste, rollout și rollback. |
| DLV-009 | Implementare | Construim vertical slices, ținem aplicația rulabilă și păstrăm trasabilitatea. |
| DLV-010 | Quality gates | Build, behavior, runtime, design, accessibility, localization, performance, privacy, security și analytics sunt verificate proporțional. |
| DLV-011 | Agenți și autonomie | Rolurile agenților sunt capabilități; agenții execută muncă reversibilă, dar nu se auto-aprobă și nu fac release protejat fără autoritate. |
| DLV-012 | Aprobări | Product, Design, Engineering, QA și Release aprobă explicit punctele care le aparțin. |
| DLV-013 | Release și rollback | Canalul, cohorta, build-ul, flags, pragurile de oprire și mitigarea sunt cunoscute înainte de release. |
| DLV-014 | Verificare în producție | Verificăm build-ul distribuit cu dovezi proaspete; lipsa traficului nu demonstrează sănătatea. |
| DLV-015 | Delivered | Rezultatul este disponibil audienței declarate, acceptance-ul este verificat și nu există blocker de release. |
| DLV-016 | Feedback loop | Dovezile, defectele, schimbările de design și metricile creează noi intrări fără a rescrie istoria. |

---

## 1. De ce avem nevoie de un Delivery Loop [DLV-001] [DLV-002]

Într-un proces fără contract comun, fiecare disciplină folosește altă definiție pentru
„gata”:

- Product: cerința este scrisă;
- Design: ecranul principal este în Figma;
- Engineering: pull request-ul este merged;
- QA: scenariul fericit a trecut pe un build;
- Release: build-ul este aprobat sau disponibil;
- utilizatorul: comportamentul funcționează pentru el.

Toate afirmațiile pot fi adevărate simultan și totuși rezultatul să nu fie livrat.
Delivery Loop-ul creează un limbaj comun, un status comun și o urmă comună de dovezi.

Unitatea de lucru este un **delivery item**: cel mai mic rezultat de produs sau
operațional care poate fi verificat independent. Poate corespunde unui ticket, dar nu
este definit de forma ticketului.

Exemplu bun:

> Un utilizator autentificat își poate salva traseul favorit și îl regăsește după
> relansarea aplicației, pentru cohorta internă TestFlight.

Exemplu slab:

> Implementăm view model-ul, endpoint-ul și trei ecrane.

Al doilea descrie activitate și structură, nu rezultatul observabil.

### Ordinea autorității

Când sursele se contrazic:

1. requirements și acceptance aprobate pentru itemul curent;
2. constrângeri aprobate de security, privacy, legal și platformă;
3. ADR-uri și standardul de arhitectură v2.1;
4. acest Delivery Loop;
5. convenții locale de delivery.

Conflictul nu este rezolvat în tăcere de persoana sau agentul care implementează. El
este documentat și trimis ownerului care are autoritatea asupra deciziei.

---

## 2. Loop-ul complet

~~~text
Requirements + Figma
        │
        ▼
Normalizează și clarifică
        │
        ▼
Definition of Ready ────────┐
        │                    │ lipsuri / schimbări
        ▼                    │
Plan tehnic                 │
        │                    │
        ▼                    │
Vertical slice              │
        │                    │
        ▼                    │
Build + Test + Runtime      │
        │                    │
        ▼                    │
Code / Design / Product review
        │
        ▼
Release candidate
        │
        ▼
TestFlight / App Store / cohortă
        │
        ▼
Production verification
        │
        ▼
Delivered
        │
        ▼
Metrics + feedback + incidente ─┘
~~~

Loop-ul nu presupune că toate livrările ajung imediat la întregul App Store. Audiența
poate fi un grup intern, beta externă, 10% rollout sau toți utilizatorii. Important este
ca audiența să fie declarată înainte și ca `DELIVERED` să fie interpretat în acel scope.

---

## 3. Contractul de requirements [DLV-003]

Un agent poate scrie cod repede dintr-o propoziție ambiguă. Tocmai aceasta este una
dintre cele mai riscante situații: viteza ascunde presupunerile. Contractul de
requirements nu trebuie să fie lung, ci suficient de precis încât două persoane să
poată verifica același rezultat.

### Conținut minim

- **Problemă:** ce nu poate face utilizatorul sau operațiunea astăzi.
- **Outcome:** ce devine adevărat după livrare.
- **Target users:** pentru cine și în ce condiții.
- **In scope / out of scope:** granițe vizibile.
- **Acceptance criteria:** comportamente observabile cu ID-uri stabile `AC-01`,
  `AC-02` etc.
- **Edge cases:** loading, empty, error, offline, permission, retry, cancellation,
  duplicate action, background/foreground, unde sunt relevante.
- **Platform constraints:** iOS/iPadOS/tvOS, minimum OS, device classes, orientări,
  limbi și conturi/entitlements.
- **Analytics și succes:** evenimentele și semnalul că outcome-ul este folosit.
- **Guardrails:** crash, latency, conversion, privacy sau alte metrici care nu trebuie
  degradate.
- **Date și compliance:** clasificare, consimțământ, retenție, logging, third-party.
- **Dependențe:** backend, schema, content, feature flag, App Store metadata.
- **Rollout:** canal, cohortă, owner, abort și rollback concept.
- **Unknowns:** întrebare, owner și termen, nu doar o listă fără responsabilitate.

### Cum scriem acceptance criteria

Un criteriu bun poate fi verificat fără a citi implementarea:

> AC-03 — Dat fiind că utilizatorul nu are rețea, când salvează un favorit, aplicația
> păstrează acțiunea local, arată starea pending și sincronizează o singură dată după
> reconectare.

Un criteriu slab spune cum să scriem codul:

> Se folosește un repository și un enum pentru loading.

Aceasta poate fi o decizie tehnică, dar nu este acceptance de produs.

Fiecare criteriu primește o metodă de verificare: test automat, runtime, design review,
analytics sau o combinație. Criteriile care nu pot fi verificate sunt rescrise înainte
de READY.

---

## 4. Contractul Figma [DLV-004]

Un URL Figma singur nu este un contract. Fișierul poate conține explorări, ecrane
vechi, componente detașate sau modificări făcute după ce implementarea a început.

### Identitatea designului

Delivery Packet-ul păstrează:

- file URL/key;
- pagina și flow-ul;
- node IDs exacte pentru ecrane și componente;
- timestamp-ul review-ului sau named version;
- ownerul design parity;
- data ultimei verificări după o schimbare.

Nu blocăm designul tehnic prin exporturi fără context, dar putem demonstra ce versiune
a fost aprobată.

### Matricea de stări

Pentru fiecare ecran relevant, designul declară cel puțin stările aplicabile:

| Categorie | Exemple |
|---|---|
| Conținut | loading, loaded, empty, partial, stale |
| Eroare | recoverable, blocking, offline, permission denied |
| Input | default, focused, validation, disabled, submitted |
| Acțiune | pressed, selected, destructive confirmation, success |
| Sistem | light/dark, Dynamic Type, Reduce Motion, VoiceOver, tvOS focus |

Nu cerem mockup separat pentru fiecare combinație dacă intenția este clară prin
componentă și reguli. Cerem însă ca stările să nu fie inventate în implementare.

### Tokens, componente, assets și copy

Design handoff-ul indică:

- componenta și varianta din design system;
- variables/tokens pentru culori, spațiere, tipografie, radius și motion;
- assets sursă și formatul corect de export;
- copy final și cine aprobă schimbările;
- interacțiuni, navigation și tranziții care nu se văd într-un frame static.

### Schimbări după READY

O modificare cosmetică minoră poate fi înregistrată fără resetarea întregului flow. O
schimbare materială — navigation, behavior, component contract, state, asset, copy cu
impact legal sau acceptance — declanșează impact review și întoarcerea la gate-ul
potrivit. Statusul nu rămâne artificial în față doar pentru a proteja un deadline.

Artefactul `FigmaDefinitionOfReadyChecklist.md` oferă checklist-ul complet.

---

## 5. Delivery Packet [DLV-005]

Delivery Packet-ul este memoria operațională a itemului. Nu înlocuiește Figma, ticketul,
PR-ul sau dashboard-ul; le leagă într-un contract verificabil.

~~~text
delivery/items/AF-123/
├── delivery.yml
├── requirements.md
├── design-map.md
├── technical-plan.md
├── test-plan.md
├── decisions.md
└── evidence/
    ├── implementation/
    ├── tests/
    ├── design/
    ├── qa/
    ├── release/
    └── production/
~~~

### Ce aparține unde

| Informație | Sursa potrivită |
|---|---|
| Scope și acceptance | requirements + `delivery.yml` |
| Figma node/state mapping | `design-map.md` + `delivery.yml` |
| Decizie arhitecturală | ADR |
| Plan de implementare | `technical-plan.md` |
| Test matrix | `test-plan.md` |
| Status curent, approvals, release facts | `delivery.yml` |
| Rezultate, screenshots, logs, build IDs | `evidence/` sau link durabil |

Evităm copierea integrală a surselor, fiindcă apar versiuni divergente. Păstrăm
identificatori stabili, versiunea revizuită, rezumatul necesar și legătura durabilă.

### Dovezi bune

- rezultat CI legat de commit;
- output de test cu toolchain și destinație;
- screenshot al stării și device/configuration;
- flow Tapia cu build, configurație, Simulator, pași și timestamp declarate;
- video scurt pentru o interacțiune sau focus;
- build/version identificat fără ambiguitate;
- query de telemetry cu interval și environment;
- approval atribuit, datat și limitat la un scope.

Un mesaj „works for me” sau un screenshot fără build/state nu este o dovadă suficientă
pentru un gate protejat.

---

## 6. State machine [DLV-006]

Statusurile sunt fapte distincte:

| Status | Ce dovedește | Ce nu dovedește |
|---|---|---|
| DRAFT | itemul există și este clarificat | că poate fi implementat |
| READY | inputurile și ownerii sunt pregătiți | că soluția tehnică este aprobată |
| PLANNED | soluția, testarea și rollout-ul sunt planificate | că există cod |
| IMPLEMENTING | există muncă activă autorizată | că feature-ul este complet |
| CODE_COMPLETE | scope-ul implementat trece verificările locale/CI declarate | că este integrat sau distribuit |
| MERGED | codul este în branch-ul protejat | că există în build-ul utilizatorului |
| QA_ACCEPTED | acceptance-ul a trecut pe build-ul declarat | că build-ul este disponibil audienței |
| RELEASE_CANDIDATE | build-ul este pregătit și aprobat pentru distribuție | că a fost distribuit |
| RELEASED | build/config a devenit disponibil în canal | că flow-ul a fost exercitat cu succes |
| PRODUCTION_VERIFIED | build-ul distribuit și critical path au dovezi proaspete | că toate criteriile de Delivered sunt închise |
| DELIVERED | outcome-ul este disponibil și acceptat pentru audiența declarată | că este livrat tuturor audiențelor posibile |

### BLOCKED, CANCELLED și REOPENED

`BLOCKED` are owner, motiv, condiție de deblocare și următor review. Nu este un sertar
pentru „lucrăm mai târziu”.

`CANCELLED` păstrează motivul și autoritatea Product care a oprit rezultatul.

`REOPENED` păstrează istoria și explică dovada invalidată sau regresia. Nu ștergem
statusul vechi pentru a arăta un istoric mai curat.

Integrările pot propune statusuri: CI poate sugera `CODE_COMPLETE`, merge-ul poate
sugera `MERGED`, iar App Store Connect poate sugera `RELEASED`. Ele nu pot inventa
approvals sau acceptance lipsă.

---

## 7. Definition of Ready [DLV-007]

READY este un gate împotriva implementării pe presupuneri, nu o ceremonie de
perfecționism. Un item este ready când necunoscutele rămase sunt suficient de mici și au
owner, iar echipa știe ce rezultat verifică.

Condiții minime:

- outcome și audiență clare;
- scope și non-goals clare;
- acceptance IDs verificabile;
- Figma contract complet sau declarație explicită că nu există UI;
- dependențe accesibile și contracte backend suficient de stabile;
- privacy/security/analytics evaluate;
- rollout și rollback concept;
- Product, Design și Engineering owners;
- aprobările READY înregistrate.

Un spike este permis pentru o necunoscută tehnică, dar are output și limită proprie. Nu
folosim spike-ul drept pretext pentru a declara implementat behavior de produs.

Checklist-ul separat `DefinitionOfReady.md` este forma de lucru.

---

## 8. Planul tehnic [DLV-008]

Planul nu trebuie să prezică fiecare linie de cod. Trebuie să reducă riscurile care,
dacă sunt descoperite după implementare, ar schimba scope-ul sau ar invalida soluția.

### Mapare obligatorie

Pentru fiecare acceptance ID:

- feature/modules afectate;
- UI, state și navigation;
- API, model, mapping, cache și persistence;
- offline, retry, cancellation și failure modes;
- analytics și operational telemetry;
- test unit/integration/UI/runtime;
- accessibility, localization și performance;
- privacy/security și third-party impact;
- feature flag, compatibilitate, rollout, abort și rollback;
- dovada așteptată și cine o aprobă.

Planul respectă ARCH v2.1. Dacă propune TCA într-un proiect MVVM/R, un package nou, o
dependență care schimbă arhitectura sau o abatere de la dependency graph, decizia are
ADR. Delivery Packet-ul leagă ADR-ul; nu îl înlocuiește.

### Vertical slices

Preferăm o bucată care poate fi demonstrată end-to-end: UI + state + dependency + test
+ runtime. Separarea exclusiv pe layere poate produce multe „90% complete” care nu pot
fi folosite sau verificate.

---

## 9. Loop-ul de implementare [DLV-009]

Pentru fiecare slice:

1. Selectăm acceptance IDs și nodurile/stările Figma.
2. Confirmăm că sursele nu s-au schimbat material după READY.
3. Implementăm conform ARCH și instrucțiunilor repo-ului.
4. Rulăm comenzile deterministe relevante: format, lint, build, tests, runtime.
5. Verificăm happy path, edge/failure state și accessibility aplicabilă.
6. Capturăm dovezi atribuite build-ului/commitului.
7. Facem review de cod, design parity și trasabilitate.
8. Actualizăm `delivery.yml` și continuăm.

Aplicația rămâne buildable și, pe cât posibil, rulabilă între slices. Feature flags pot
separa integrarea de expunere, dar nu trebuie să creeze combinații neverificate sau cod
fără owner care rămâne ascuns permanent.

---

## 10. Quality gates și evidence matrix [DLV-010]

„Testele sunt verzi” este necesar, dar incomplet. Fiecare tip de dovadă răspunde la
altă întrebare:

| Dovadă | Poate demonstra | Nu poate demonstra singură |
|---|---|---|
| Unit test | logică și state transitions | integrarea reală sau distribuția |
| Integration test | contracte între componente | UI și experiența completă |
| UI test | flow repetabil în app | fidelitate completă și producție |
| Screenshot | aspect într-o stare | behavior și interacțiune |
| Runtime local | behavior pe build local | build-ul distribuit |
| CI verde | setul declarat de verificări | acceptance necodificat în checks |
| App Store approval | acceptarea build-ului de Apple | outcome funcțional pentru utilizator |
| Telemetry proaspătă | behavior exercitat în environment | întreaga experiență fără context |

### Categoriile verificate

- clean build și toolchain suportat;
- behavior și failure modes;
- design parity pentru stări/dispozitive relevante;
- Dynamic Type, VoiceOver, contrast, focus/input și Reduce Motion;
- localizare, truncation, valori locale și RTL când este suportat;
- performance/energy/memory/network unde feature-ul le poate afecta;
- reliability: offline, retry, duplicate action, cancellation, migrations;
- privacy/security: date, consent, storage, logs, permissions, SDK-uri;
- analytics: schema, consent, deduplicare și ingestie;
- upgrade și backward compatibility pentru aplicația instalată.

`not applicable` este o decizie cu motiv, nu un câmp omis. Rigoarea este proporțională
cu riscul: un text static nu primește același plan ca payments, health data sau o
migrare persistentă.

---

## 11. Roluri, agenți și skills [DLV-011]

Rolurile sunt **capabilități logice**, nu obligația de a porni opt agenți simultan.
O persoană sau un agent poate face analiză și implementare, dar nu poate fabrica
approval-ul Product, Design sau Release.

### Roluri de execuție

- **Orchestrator:** ține Delivery Packet-ul coerent și selectează următorul gate.
- **Requirements analyst:** normalizează outcome-ul și acceptance IDs.
- **Design-context agent:** extrage nodes, states, tokens, assets și detectează schimbări.
- **iOS implementation agent:** implementează vertical slice sub ARCH.
- **Test agent:** construiește matricea de verificare și rulează checks.
- **Review agent:** verifică cod, arhitectură, risc și trasabilitate.
- **Runtime verifier:** exercită aplicația și capturează dovezi.
- **Release operator:** execută numai release-ul aprobat.

### Ce pot face agenții autonom

În limitele accesului acordat repo-ului:

- citesc requirements, Figma, cod, CI și telemetry;
- creează plan, cod, tests și evidence local;
- rulează checks deterministe;
- actualizează Delivery Packet-ul cu fapte observate;
- propun statusul următor sau raportează un blocker.

### Unde se opresc

Fără autoritate umană explicită, agenții nu:

- aprobă scope, design, legal/privacy sau gate waivers;
- se auto-aprobă unde este cerut review independent;
- schimbă signing, certificates, entitlements, App Store contracts sau production
  credentials;
- trimit build-ul, modifică un flag/cohort de producție, comunică utilizatorilor sau
  șterg date;
- ascund un check eșuat ori transformă lipsa traficului în „healthy”.

### Skill map

Loop-ul reutilizează skills canonice din ARCH v2.1:

| Context | Skill |
|---|---|
| Implementare SwiftUI | `apple/swiftui-patterns` |
| Refactor SwiftUI | `apple/swiftui-refactoring` |
| Performance SwiftUI | `apple/swiftui-performance` |
| Concurrency | `apple/swift-concurrency` |
| Testare | `apple/swift-testing` |
| Simulator/device runtime | `apple/ios-runtime-debugging` |
| Accessibility | `apple/apple-accessibility` |
| Proiect TCA | `apple/tca` |

Propunem patru skills noi pentru registrul companiei:

- `delivery/requirements-normalization`;
- `delivery/figma-handoff`;
- `delivery/technical-planning`;
- `delivery/release-verification`.

Până când acestea există și sunt versionate, checklist-urile din pachet sunt fallback-ul
manual. Nu inventăm că un skill există doar fiindcă avem un ID propus. `AGENTS.md`
mapează numele canonice la runtime-ul disponibil; `tooling/skills.yml` și `skills.lock`
declară versiunile atunci când sistemul le suportă.

### Tool capabilities și Tapia MCP

Skills-urile descriu cum lucrăm. Tool-urile oferă acțiuni executabile și se declară
separat în `tooling/tools.yml`.

- `apple/xcode-automation` este recomandat pentru build, test, diagnostics și operații
  Xcode suportate;
- `apple/ios-simulator-automation`, implementat prin Tapia MCP, este
  `recommended_conditional` când agenții trebuie să exercite repetabil flow-uri UI,
  să inspecteze accessibility tree sau să captureze dovezi locale în Simulator.

Tapia folosește selectori semantici și `accessibilityIdentifier` stabil pentru
controalele critice. Îl rulăm într-un Simulator izolat, cu conturi/date non-production,
commit revizuit fixat și aprobări restrânse. Păstrăm XCUITest pentru suitele de regresie
și CI. Un flow Tapia reușit demonstrează numai interacțiunea observată pe build-ul și
Simulatorul declarat; nu acordă approval și nu demonstrează distribuția sau producția.
Ghidul operațional se află în `docs/tooling/TapiaMCPGuide.md`.

---

## 12. Aprobări și RACI [DLV-012]

Approval înseamnă actor, rol, scope, rezultat, timestamp și eventuale condiții. Un
emoji sau un „ok” fără context durabil nu este suficient pentru un gate protejat.

Baseline:

- READY: Product + Design pentru UI + Engineering;
- PLANNED: Engineering, plus Security/Privacy când riscul o cere;
- QA_ACCEPTED: QA/acceptance owner + Design pentru UI material;
- RELEASE_CANDIDATE: Engineering + QA + Release, iar Product confirmă cohorta;
- DELIVERED: Product sau Delivery owner după production verification.

Într-o echipă mică rolurile se pot combina, dar autoritatea rămâne explicită. Autorul
unei schimbări cu risc ridicat nu este singurul engineering reviewer. Matricea completă
se află în `DeliveryRACI.md`.

### Waivers

Un waiver conține:

- check-ul exact;
- riscul și impactul;
- motivul;
- ownerul riscului și aprobarea sa;
- mitigation;
- expirare;
- follow-up obligatoriu.

Un agent poate redacta waiver-ul, dar nu poate produce aprobarea. Nu folosim waiver
pentru a numi `PRODUCTION_VERIFIED` un release care nu a fost exercitat.

---

## 13. Release și rollback [DLV-013]

Release readiness fixează:

- canalul: internal, TestFlight, phased App Store sau full production;
- environment-ul și audiența;
- bundle ID, version, build, commit și archive/CI run;
- flags, defaults, prerequisites și operator;
- metadata și compliance App Store;
- compatibilitatea cu API/schema și versiunile vechi instalate;
- health signals, praguri de abort și incident owner;
- rollback sau mitigation concretă.

Pe mobile, rollback-ul nu este echivalent cu web deploy rollback. Nu putem conta că
toți utilizatorii vor instala imediat o versiune nouă și, în general, nu putem forța
downgrade-ul binarului instalat. De aceea:

- serviciile rămân backward compatible pe fereastra declarată;
- migrations sunt forward-safe și tolerant citibile unde este necesar;
- feature flags permit dezactivarea comportamentului riscant;
- server-side fallback și kill switch au owner;
- hotfix-ul este ultima linie, nu singurul plan.

Checklist-ul `ReleaseAndProductionVerificationChecklist.md` este forma executabilă.

---

## 14. Production verification [DLV-014]

Verificarea folosește build-ul distribuit în environment-ul declarat. Un debug build
local poate demonstra implementarea, dar nu poate demonstra signing, configuration,
distribution, flags sau dependențele de producție. Același lucru este valabil pentru
un flow reușit în Tapia, Simulator, preview sau XCUITest local.

### Dovezi minime proaspete

- version/build/commit și flag state efectiv;
- install sau upgrade, launch și critical-path smoke pe device reprezentativ;
- răspunsurile dependențelor și backend-ului relevant;
- crash/error/performance în intervalul verificării;
- evenimentul analytics așteptat ajuns în destinație, respectând consent;
- output specific acceptance-ului;
- verifier, timestamp, cohortă și links.

### Cum interpretăm lipsa erorilor

- trafic valid + fără erori relevante poate susține „healthy”;
- fără erori + fără trafic înseamnă „not exercised”;
- datele vechi de la alt build nu verifică release-ul curent;
- install, launch, backend request, analytics ingestion și outcome sunt semnale
  distincte.

Dacă feature-ul are trafic natural prea mic, folosim un cont/control test autorizat
sau un smoke sintetic sigur. Dacă nici acesta nu este posibil, statusul rămâne
`RELEASED`, iar blocker-ul pentru `PRODUCTION_VERIFIED` este raportat onest.

---

## 15. Definition of Delivered [DLV-015]

`DELIVERED` înseamnă că:

1. build-ul/configurația este accesibilă audienței declarate;
2. toate acceptance criteria in scope au trecut sau au o dispoziție non-blocking
   aprobată și vizibilă Product;
3. critical path a fost exercitat proaspăt pe build-ul distribuit;
4. design, accessibility, localization, performance, privacy, security și analytics au
   trecut unde sunt aplicabile;
5. telemetry a fost generată și ingestia verificată;
6. nu există P0/P1, release blocker sau waiver expirat;
7. release, rollback, limitări și approvals sunt legate;
8. Product/Delivery owner a acceptat rezultatul pentru audiență.

Nu spunem „delivered” pentru:

- cod local complet;
- PR deschis sau merged;
- build arhivat;
- App Review aprobat;
- build `RELEASED` dar neexercitat;
- absența incidentelor într-o fereastră fără trafic.

Checklist-ul `DefinitionOfDelivered.md` trebuie completat înaintea tranziției finale.

---

## 16. Feedback loop și îmbunătățire [DLV-016]

Delivery nu închide învățarea. După release:

- feedback-ul și defectele devin itemuri legate;
- o schimbare materială în requirements/Figma creează revision și impact review;
- regresiile folosesc `REOPENED`;
- incidentele sunt legate de build, flags și Delivery Packet;
- lecțiile reutilizabile intră în standard, bootstrap, skills sau regression tests.

### Metrici sănătoase

- lead time READY → DELIVERED;
- timp blocat și cele mai frecvente cauze;
- first-pass rate per gate;
- churn de requirements/design după READY;
- escaped defects și change failure rate;
- timp de rollback/mitigation;
- latență RELEASED → PRODUCTION_VERIFIED;
- procent de acceptance cu dovadă automată și runtime.

Nu măsurăm productivitatea individuală prin număr de commits, linii, prompts sau tokeni.
O scădere a lead time-ului nu este progres dacă au crescut escaped defects, waivers sau
zonele fără telemetry.

---

## 17. Ce automatizăm și ce rămâne judecată umană

### Automatizabil

- validarea `delivery.yml`;
- consistența ID-urilor DLV între documente;
- existența acceptance IDs și mapping-ului către tests;
- build, lint, tests, coverage policy și artifact capture;
- detectarea schimbării node/version Figma când integrarea permite;
- colectarea build/commit/release facts;
- verificarea existenței approvals și evidence links;
- interogări de health și analytics definite în plan;
- propunerea următorului status.

### Rămâne cu autoritate umană

- aprobarea problemei, outcome-ului și scope-ului;
- trade-off-uri de design și experiență;
- acceptarea riscului privacy/security/legal;
- waiver-ul unui gate;
- decizia de release, cohortă și comunicare;
- acceptarea finală a valorii livrate.

Automatizarea produce fapte și recomandări. Autoritatea explicită produce aprobări.

---

## 18. Integrarea în repo

Un repo pregătit pentru acest loop oferă:

~~~text
AGENTS.md
Makefile
tooling/skills.yml
tooling/tools.yml
skills.lock
delivery/
  schema/delivery.schema.json
  templates/delivery-template.yml
  items/
docs/adr/
scripts/
~~~

`AGENTS.md` spune rapid:

- comenzile build/test/lint/format/runtime;
- scheme, destinations și toolchain;
- cum se accesează design context;
- cum se validează Delivery Packet-ul;
- ce skills/capabilități sunt instalate;
- ce MCP/tool capabilities sunt active, condițiile și fallback-urile lor;
- ce acțiuni sunt protejate;
- unde se găsesc CI, release și telemetry;
- deviațiile locale și ADR-urile lor.

Bootstrap-ul proiectului trebuie să creeze această interfață înainte ca loop-ul să fie
folosit la scară. Delivery Loop-ul nu poate compensa un repo fără build determinist,
signing ownership, environments sau observability.

---

## 19. Pilotul recomandat

### Alegerea itemurilor

Pentru v0.1 alegem:

- un vertical slice UI + API de risc mediu;
- opțional, un item mic fără UI sau un bug de producție pentru contrast;
- fără payments/health/legal-critical ca prim experiment;
- cu acces real la requirements, Figma, CI, TestFlight și telemetry.

### Ce observăm

- câmpuri care nu au owner sau sursă;
- gates care se dublează;
- evidence dificil de obținut;
- statusuri care nu descriu realitatea;
- aprobări imposibile într-o echipă mică;
- pași pe care agenții îi pot automatiza sigur;
- lipsuri în bootstrap, skills sau observability.

### Criterii pentru v1.0

- schema a funcționat pentru cel puțin două itemuri diferite;
- fiecare status a avut semnificație clară;
- Product, Design, Engineering, QA și Release au confirmat ownership-ul;
- `DELIVERED` a putut fi demonstrat din dovezi, nu din memorie;
- waivers și `not applicable` nu au devenit scurtături;
- costul de menținere a Delivery Packet-ului este mai mic decât costul ambiguității pe
  care o elimină.

---

## 20. Guvernanță și changelog

Ownerii propuși sunt Apple Platform Team pentru integrarea tehnică și Product Delivery
pentru lifecycle/approval. Security, Privacy, DesignOps, QA și Release revizuiesc
secțiunile care le afectează autoritatea.

O modificare de decizie:

1. actualizează handbook-ul și standardul compact în același PR;
2. păstrează același ID `DLV-*`;
3. actualizează schema/template/checklist-urile afectate;
4. include impactul asupra itemurilor active și o strategie de migrare;
5. actualizează changelog-ul.

### Changelog v0.1

- a definit unitatea de livrare și target audience;
- a introdus contractele requirements și Figma;
- a introdus Delivery Packet și schema de status;
- a separat CODE_COMPLETE, MERGED, RELEASED, PRODUCTION_VERIFIED și DELIVERED;
- a definit gates, evidence, approvals, waivers și RACI;
- a delimitat autonomia agenților de autoritatea umană;
- a legat skills Apple existente și a propus patru capabilities de delivery;
- a introdus release/rollback și regula „no traffic is not health”;
- a definit feedback loop și metricile pentru pilot.
