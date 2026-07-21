# How we continuously deliver Apple applications — v0.1

The Apple Team handbook for turning requirements + Figma into a delivered, verified
outcome on iOS, iPadOS, and tvOS.

| Metadata | Value |
|---|---|
| Status | Proposed v0.1 — ready for pilot |
| Version | 0.1 |
| Proposed owner | Apple Platform Team + Product Delivery |
| Audience | Product, Design, Engineering, QA, Release, and AI agents |
| Companion | AppleTeamDeliveryLoopStandard.md |
| Technical standard | Apple Team Architecture Standard v2.1 |
| Review | After each pilot, then at least twice per year |

## How we use this handbook

The Architecture Standard answers the question "how do we build the code?". This
handbook answers the question "how do we know we turned an intent into a real,
available, and verified outcome?".

This document is the canonical source for humans. The compact companion is the
normative form for agents and automation. Every decision has a `DLV-*` ID; the set of
IDs must be identical in both documents.

This is a pilot draft, not a final process imposed on every project. We test it on 1–2
real vertical slices, measure where it produces clarity and where it adds friction,
then promote it to v1.0.

---

## 0. Decision summary

| ID | Area | Decision |
|---|---|---|
| DLV-001 | Authority | Approved requirements, compliance constraints, ARCH, and this standard have explicit precedence. |
| DLV-002 | Unit of delivery | We track a small, independently verifiable outcome, not just a ticket or a set of files. |
| DLV-003 | Requirements contract | Problem, outcome, scope, acceptance, risks, measurement, rollout, and owners are explicit. |
| DLV-004 | Figma contract | We record the exact nodes, the reviewed version, states, tokens, copy, assets, interactions, and accessibility intent. |
| DLV-005 | Delivery Packet | Every outcome has a versioned `delivery.yml` plus links to plans and evidence. |
| DLV-006 | State machine | Statuses are explicit, evidence-backed, and never inferred from Git or CI alone. |
| DLV-007 | Definition of Ready | Implementation starts only after the requirement, design, dependencies, owners, and acceptance are clarified. |
| DLV-008 | Technical plan | The plan ties acceptance to architecture, data, analytics, tests, rollout, and rollback. |
| DLV-009 | Implementation | We build vertical slices, keep the app runnable, and preserve traceability. |
| DLV-010 | Quality gates | Build, behavior, runtime, design, accessibility, localization, performance, privacy, security, and analytics are verified proportionally. |
| DLV-011 | Agents and autonomy | Agent roles are capabilities; agents execute reversible work but do not self-approve and do not perform protected releases without authority. |
| DLV-012 | Approvals | Product, Design, Engineering, QA, and Release explicitly approve the points they own. |
| DLV-013 | Release and rollback | Channel, cohort, build, flags, abort thresholds, and mitigation are known before release. |
| DLV-014 | Production verification | We verify the distributed build with fresh evidence; the absence of traffic does not prove health. |
| DLV-015 | Delivered | The outcome is available to the declared audience, acceptance is verified, and no release blocker remains. |
| DLV-016 | Feedback loop | Evidence, defects, design changes, and metrics create new inputs without rewriting history. |

---

## 1. Why we need a Delivery Loop [DLV-001] [DLV-002]

In a process without a shared contract, every discipline uses a different definition of
"done":

- Product: the requirement is written;
- Design: the main screen is in Figma;
- Engineering: the pull request is merged;
- QA: the happy path passed on some build;
- Release: the build is approved or available;
- the user: the behavior works for them.

All of these statements can be true at the same time while the outcome is still not
delivered. The Delivery Loop creates a shared language, a shared status, and a shared
trail of evidence.

The unit of work is a **delivery item**: the smallest product or operational outcome
that can be verified independently. It may correspond to a ticket, but it is not
defined by the shape of the ticket.

A good example:

> A signed-in user can save their favorite route and find it again after relaunching
> the app, for the internal TestFlight cohort.

A weak example:

> We implement the view model, the endpoint, and three screens.

The second describes activity and structure, not an observable outcome.

### Order of authority

When sources conflict:

1. approved requirements and acceptance for the current item;
2. approved security, privacy, legal, and platform constraints;
3. ADRs and the Architecture Standard v2.1;
4. this Delivery Loop;
5. local delivery conventions.

A conflict is not resolved silently by the person or agent doing the implementation. It
is documented and routed to the owner who holds authority over the decision.

---

## 2. The full loop

~~~text
Requirements + Figma
        │
        ▼
Normalize and clarify
        │
        ▼
Definition of Ready ────────┐
        │                    │ gaps / changes
        ▼                    │
Technical plan              │
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
TestFlight / App Store / cohort
        │
        ▼
Production verification
        │
        ▼
Delivered
        │
        ▼
Metrics + feedback + incidents ─┘
~~~

The loop does not assume every delivery immediately reaches the entire App Store. The
audience may be an internal group, an external beta, a 10% rollout, or all users. What
matters is that the audience is declared up front and that `DELIVERED` is interpreted
within that scope.

---

## 3. The requirements contract [DLV-003]

An agent can write code quickly from an ambiguous sentence. That is exactly one of the
riskiest situations: speed hides assumptions. The requirements contract does not need
to be long; it needs to be precise enough that two people can verify the same outcome.

### Minimum content

- **Problem:** what the user or the operation cannot do today.
- **Outcome:** what becomes true after delivery.
- **Target users:** for whom and under what conditions.
- **In scope / out of scope:** visible boundaries.
- **Acceptance criteria:** observable behaviors with stable IDs `AC-01`,
  `AC-02`, and so on.
- **Edge cases:** loading, empty, error, offline, permission, retry, cancellation,
  duplicate action, background/foreground, where relevant.
- **Platform constraints:** iOS/iPadOS/tvOS, minimum OS, device classes, orientations,
  languages, and accounts/entitlements.
- **Analytics and success:** the events and the signal that the outcome is being used.
- **Guardrails:** crash, latency, conversion, privacy, or other metrics that must not
  degrade.
- **Data and compliance:** classification, consent, retention, logging, third parties.
- **Dependencies:** backend, schema, content, feature flags, App Store metadata.
- **Rollout:** channel, cohort, owner, abort, and rollback concept.
- **Unknowns:** question, owner, and due date, not just a list without accountability.

### How we write acceptance criteria

A good criterion can be verified without reading the implementation:

> AC-03 — Given that the user has no network, when they save a favorite, the app keeps
> the action locally, shows the pending state, and syncs exactly once after
> reconnecting.

A weak criterion says how to write the code:

> Use a repository and an enum for loading.

That may be a technical decision, but it is not product acceptance.

Every criterion gets a verification method: automated test, runtime, design review,
analytics, or a combination. Criteria that cannot be verified are rewritten before
READY.

---

## 4. The Figma contract [DLV-004]

A Figma URL on its own is not a contract. The file may contain explorations, old
screens, detached components, or changes made after implementation started.

### Design identity

The Delivery Packet records:

- the file URL/key;
- the page and the flow;
- exact node IDs for screens and components;
- the review timestamp or named version;
- the design-parity owner;
- the date of the last check after a change.

We do not freeze the design through context-free exports, but we can prove which
version was approved.

### The state matrix

For every relevant screen, the design declares at least the applicable states:

| Category | Examples |
|---|---|
| Content | loading, loaded, empty, partial, stale |
| Error | recoverable, blocking, offline, permission denied |
| Input | default, focused, validation, disabled, submitted |
| Action | pressed, selected, destructive confirmation, success |
| System | light/dark, Dynamic Type, Reduce Motion, VoiceOver, tvOS focus |

We do not require a separate mockup for every combination when the intent is clear from
the component and its rules. We do require that states are not invented during
implementation.

### Tokens, components, assets, and copy

The design handoff identifies:

- the design-system component and variant;
- variables/tokens for color, spacing, typography, radius, and motion;
- source assets and the correct export format;
- the final copy and who approves changes to it;
- interactions, navigation, and transitions that a static frame cannot show.

### Changes after READY

A minor cosmetic change can be recorded without resetting the whole flow. A material
change — navigation, behavior, component contract, state, asset, copy with legal
impact, or acceptance — triggers an impact review and a return to the appropriate gate.
The status does not stay artificially ahead just to protect a deadline.

The `FigmaDefinitionOfReadyChecklist.md` artifact provides the complete checklist.

---

## 5. Delivery Packet [DLV-005]

The Delivery Packet is the item's operational memory. It does not replace Figma, the
ticket, the PR, or the dashboard; it ties them together into a verifiable contract.

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

### What belongs where

| Information | Correct source |
|---|---|
| Scope and acceptance | requirements + `delivery.yml` |
| Figma node/state mapping | `design-map.md` + `delivery.yml` |
| Architecture decision | ADR |
| Implementation plan | `technical-plan.md` |
| Test matrix | `test-plan.md` |
| Current status, approvals, release facts | `delivery.yml` |
| Results, screenshots, logs, build IDs | `evidence/` or a durable link |

We avoid copying sources wholesale, because divergent versions appear. We keep stable
identifiers, the reviewed version, the necessary summary, and a durable link.

### Good evidence

- a CI result tied to a commit;
- test output with toolchain and destination;
- a screenshot of the state plus device/configuration;
- a Tapia flow with declared build, configuration, Simulator, steps, and timestamp;
- a short video for an interaction or focus behavior;
- an unambiguously identified build/version;
- a telemetry query with time window and environment;
- an approval that is attributed, dated, and limited to a scope.

A "works for me" message or a screenshot without build/state is not sufficient evidence
for a protected gate.

---

## 6. State machine [DLV-006]

Statuses are distinct facts:

| Status | What it proves | What it does not prove |
|---|---|---|
| DRAFT | the item exists and is being clarified | that it can be implemented |
| READY | the inputs and owners are in place | that the technical solution is approved |
| PLANNED | the solution, testing, and rollout are planned | that any code exists |
| IMPLEMENTING | authorized active work exists | that the feature is complete |
| CODE_COMPLETE | the implemented scope passes the declared local/CI checks | that it is integrated or distributed |
| MERGED | the code is in the protected branch | that it exists in the user's build |
| QA_ACCEPTED | acceptance passed on the declared build | that the build is available to the audience |
| RELEASE_CANDIDATE | the build is prepared and approved for distribution | that it was distributed |
| RELEASED | the build/config became available in the channel | that the flow was exercised successfully |
| PRODUCTION_VERIFIED | the distributed build and critical path have fresh evidence | that every Delivered criterion is closed |
| DELIVERED | the outcome is available and accepted for the declared audience | that it is delivered to every possible audience |

### BLOCKED, CANCELLED, and REOPENED

`BLOCKED` has an owner, a reason, an unblock condition, and a next review. It is not a
drawer for "we'll work on it later".

`CANCELLED` records the reason and the Product authority that stopped the outcome.

`REOPENED` preserves the history and explains the invalidated evidence or the
regression. We do not delete the old status to show a cleaner history.

Integrations may propose statuses: CI may suggest `CODE_COMPLETE`, a merge may suggest
`MERGED`, and App Store Connect may suggest `RELEASED`. They cannot invent missing
approvals or acceptance.

---

## 7. Definition of Ready [DLV-007]

READY is a gate against implementing on assumptions, not a perfectionism ceremony. An
item is ready when the remaining unknowns are small enough and have an owner, and the
team knows what outcome it is verifying.

Minimum conditions:

- a clear outcome and audience;
- clear scope and non-goals;
- verifiable acceptance IDs;
- a complete Figma contract or an explicit declaration that there is no UI;
- accessible dependencies and sufficiently stable backend contracts;
- privacy/security/analytics assessed;
- a rollout and rollback concept;
- Product, Design, and Engineering owners;
- the READY approvals recorded.

A spike is allowed for a technical unknown, but it has its own output and its own
limit. We do not use a spike as a pretext to declare product behavior implemented.

The separate `DefinitionOfReady.md` checklist is the working form.

---

## 8. The technical plan [DLV-008]

The plan does not have to predict every line of code. It has to reduce the risks that,
if discovered after implementation, would change the scope or invalidate the solution.

### Mandatory mapping

For each acceptance ID:

- the affected feature/modules;
- UI, state, and navigation;
- API, model, mapping, cache, and persistence;
- offline, retry, cancellation, and failure modes;
- analytics and operational telemetry;
- unit/integration/UI/runtime tests;
- accessibility, localization, and performance;
- privacy/security and third-party impact;
- feature flag, compatibility, rollout, abort, and rollback;
- the expected evidence and who approves it.

The plan follows ARCH v2.1. If it proposes TCA in an MVVM/R project, a new package, a
dependency that changes the architecture, or a deviation from the dependency graph, the
decision gets an ADR. The Delivery Packet links the ADR; it does not replace it.

### Vertical slices

We prefer a piece that can be demonstrated end to end: UI + state + dependency + test
+ runtime. Splitting purely by layer can produce many "90% complete" pieces that cannot
be used or verified.

---

## 9. The implementation loop [DLV-009]

For each slice:

1. Select the acceptance IDs and the Figma nodes/states.
2. Confirm that the sources have not changed materially since READY.
3. Implement according to ARCH and the repository instructions.
4. Run the relevant deterministic commands: format, lint, build, tests, runtime.
5. Verify the happy path, edge/failure states, and applicable accessibility.
6. Capture evidence attributed to the build/commit.
7. Review the code, design parity, and traceability.
8. Update `delivery.yml` and continue.

The app stays buildable and, as far as possible, runnable between slices. Feature flags
may separate integration from exposure, but they must not create unverified
combinations or ownerless code that stays hidden permanently.

---

## 10. Quality gates and the evidence matrix [DLV-010]

"The tests are green" is necessary but incomplete. Each kind of evidence answers a
different question:

| Evidence | Can prove | Cannot prove on its own |
|---|---|---|
| Unit test | logic and state transitions | real integration or distribution |
| Integration test | contracts between components | the UI and the full experience |
| UI test | a repeatable in-app flow | full fidelity and production |
| Screenshot | appearance in one state | behavior and interaction |
| Local runtime | behavior on a local build | the distributed build |
| Green CI | the declared set of checks | acceptance not encoded in checks |
| App Store approval | Apple's acceptance of the build | a working outcome for the user |
| Fresh telemetry | behavior exercised in an environment | the whole experience without context |

### The verified categories

- clean build and a supported toolchain;
- behavior and failure modes;
- design parity for the relevant states/devices;
- Dynamic Type, VoiceOver, contrast, focus/input, and Reduce Motion;
- localization, truncation, locale-sensitive values, and RTL when supported;
- performance/energy/memory/network where the feature can affect them;
- reliability: offline, retry, duplicate action, cancellation, migrations;
- privacy/security: data, consent, storage, logs, permissions, SDKs;
- analytics: schema, consent, deduplication, and ingestion;
- upgrade and backward compatibility for the installed app.

`not applicable` is a decision with a reason, not an omitted field. Rigor is
proportional to risk: a static text does not get the same plan as payments, health
data, or a persistent-store migration.

---

## 11. Roles, agents, and skills [DLV-011]

Roles are **logical capabilities**, not an obligation to start eight agents at once.
One person or agent can do analysis and implementation, but cannot fabricate the
Product, Design, or Release approval.

### Execution roles

- **Orchestrator:** keeps the Delivery Packet coherent and selects the next gate.
- **Requirements analyst:** normalizes the outcome and the acceptance IDs.
- **Design-context agent:** extracts nodes, states, tokens, and assets, and detects changes.
- **iOS implementation agent:** implements the vertical slice under ARCH.
- **Test agent:** builds the verification matrix and runs checks.
- **Review agent:** reviews code, architecture, risk, and traceability.
- **Runtime verifier:** exercises the app and captures evidence.
- **Release operator:** executes only the approved release.

### What agents can do autonomously

Within the access granted to them in the repository:

- read requirements, Figma, code, CI, and telemetry;
- create the plan, code, tests, and evidence locally;
- run deterministic checks;
- update the Delivery Packet with observed facts;
- propose the next status or report a blocker.

### Where they stop

Without explicit human authority, agents do not:

- approve scope, design, legal/privacy risk, or gate waivers;
- self-approve where independent review is required;
- change signing, certificates, entitlements, App Store contracts, or production
  credentials;
- submit the build, change a production flag/cohort, communicate with users, or delete
  data;
- hide a failed check or turn the absence of traffic into "healthy".

### Skill map

The loop reuses the canonical skills from ARCH v2.1:

| Context | Skill |
|---|---|
| SwiftUI implementation | `apple/swiftui-patterns` |
| SwiftUI refactoring | `apple/swiftui-refactoring` |
| SwiftUI performance | `apple/swiftui-performance` |
| Concurrency | `apple/swift-concurrency` |
| Testing | `apple/swift-testing` |
| Simulator/device runtime | `apple/ios-runtime-debugging` |
| Accessibility | `apple/apple-accessibility` |
| TCA project | `apple/tca` |

We propose four new skills for the company registry:

- `delivery/requirements-normalization`;
- `delivery/figma-handoff`;
- `delivery/technical-planning`;
- `delivery/release-verification`.

Until these exist and are versioned, the checklists in this package are the manual
fallback. We do not pretend a skill exists just because we have a proposed ID.
`AGENTS.md` maps the canonical names to the available runtime; `tooling/skills.yml` and
`skills.lock` declare the versions once the system supports them.

### Tool capabilities and Tapia MCP

Skills describe how we work. Tools provide executable actions and are declared
separately in `tooling/tools.yml`.

- `apple/xcode-automation` is recommended for build, test, diagnostics, and supported
  Xcode operations;
- `apple/ios-simulator-automation`, implemented through Tapia MCP, is
  `recommended_conditional` when agents need to exercise UI flows repeatably, inspect
  the accessibility tree, or capture local evidence in the Simulator.

Tapia uses semantic selectors and stable `accessibilityIdentifier` values for critical
controls. We run it in an isolated Simulator, with non-production accounts/data, a
pinned reviewed commit, and narrow approvals. We keep XCUITest for the regression
suites and CI. A successful Tapia flow proves only the interaction observed on the
declared build and Simulator; it does not grant approval and does not prove
distribution or production. The operational guide lives in
`docs/tooling/TapiaMCPGuide.md`.

---

## 12. Approvals and RACI [DLV-012]

An approval means actor, role, scope, result, timestamp, and any conditions. An emoji
or an "ok" without durable context is not sufficient for a protected gate.

Baseline:

- READY: Product + Design for UI work + Engineering;
- PLANNED: Engineering, plus Security/Privacy when the risk demands it;
- QA_ACCEPTED: QA/acceptance owner + Design for material UI work;
- RELEASE_CANDIDATE: Engineering + QA + Release, with Product confirming the cohort;
- DELIVERED: Product or Delivery owner after production verification.

In a small team the roles may combine, but the authority stays explicit. The author of
a high-risk change is not the only engineering reviewer. The full matrix lives in
`DeliveryRACI.md`.

### Waivers

A waiver contains:

- the exact check;
- the risk and the impact;
- the rationale;
- the risk owner and their approval;
- the mitigation;
- an expiry;
- a mandatory follow-up.

An agent may draft the waiver, but cannot produce the approval. We do not use a waiver
to call a release `PRODUCTION_VERIFIED` when it was never exercised.

---

## 13. Release and rollback [DLV-013]

Release readiness pins down:

- the channel: internal, TestFlight, phased App Store, or full production;
- the environment and the audience;
- bundle ID, version, build, commit, and archive/CI run;
- flags, defaults, prerequisites, and the operator;
- App Store metadata and compliance;
- compatibility with the API/schema and with older installed versions;
- health signals, abort thresholds, and the incident owner;
- a concrete rollback or mitigation.

On mobile, rollback is not equivalent to a web deploy rollback. We cannot count on all
users immediately installing a new version and, in general, we cannot force a downgrade
of the installed binary. Therefore:

- services stay backward compatible for the declared window;
- migrations are forward-safe and tolerantly readable where necessary;
- feature flags allow the risky behavior to be disabled;
- the server-side fallback and kill switch have an owner;
- a hotfix is the last line of defense, not the only plan.

The `ReleaseAndProductionVerificationChecklist.md` checklist is the executable form.

---

## 14. Production verification [DLV-014]

Verification uses the distributed build in the declared environment. A local debug
build can prove the implementation, but it cannot prove signing, configuration,
distribution, flags, or the production dependencies. The same holds for a successful
flow in Tapia, the Simulator, a preview, or local XCUITest.

### Minimum fresh evidence

- version/build/commit and the effective flag state;
- install or upgrade, launch, and a critical-path smoke test on a representative device;
- the responses of the relevant dependencies and backend;
- crash/error/performance for the verification window;
- the expected analytics event arriving at its destination, respecting consent;
- acceptance-specific output;
- verifier, timestamp, cohort, and links.

### How we interpret the absence of errors

- valid traffic + no relevant errors can support "healthy";
- no errors + no traffic means "not exercised";
- stale data from another build does not verify the current release;
- install, launch, backend request, analytics ingestion, and outcome are distinct
  signals.

If the feature has too little natural traffic, we use an authorized test
account/control or a safe synthetic smoke test. If even that is not possible, the
status stays `RELEASED`, and the blocker for `PRODUCTION_VERIFIED` is reported
honestly.

---

## 15. Definition of Delivered [DLV-015]

`DELIVERED` means that:

1. the build/configuration is accessible to the declared audience;
2. every in-scope acceptance criterion passed or has an approved non-blocking
   disposition visible to Product;
3. the critical path was freshly exercised on the distributed build;
4. design, accessibility, localization, performance, privacy, security, and analytics
   passed where applicable;
5. telemetry was generated and its ingestion verified;
6. there is no P0/P1, release blocker, or expired waiver;
7. the release, rollback, limitations, and approvals are linked;
8. the Product/Delivery owner accepted the outcome for the audience.

We do not say "delivered" for:

- locally complete code;
- an open or merged PR;
- an archived build;
- an approved App Review;
- a `RELEASED` but unexercised build;
- the absence of incidents in a window with no traffic.

The `DefinitionOfDelivered.md` checklist must be completed before the final transition.

---

## 16. Feedback loop and improvement [DLV-016]

Delivery does not close the learning. After release:

- feedback and defects become linked items;
- a material change in requirements/Figma creates a revision and an impact review;
- regressions use `REOPENED`;
- incidents are linked to the build, the flags, and the Delivery Packet;
- reusable lessons flow into the standard, the bootstrap, skills, or regression tests.

### Healthy metrics

- READY → DELIVERED lead time;
- blocked time and the most frequent causes;
- first-pass rate per gate;
- requirements/design churn after READY;
- escaped defects and change failure rate;
- rollback/mitigation time;
- RELEASED → PRODUCTION_VERIFIED latency;
- percentage of acceptance criteria with automated and runtime evidence.

We do not measure individual productivity by the number of commits, lines, prompts, or
tokens. A drop in lead time is not progress if escaped defects, waivers, or the areas
without telemetry have grown.

---

## 17. What we automate and what stays human judgment

### Automatable

- validating `delivery.yml`;
- the consistency of DLV IDs across documents;
- the existence of acceptance IDs and of their mapping to tests;
- build, lint, tests, coverage policy, and artifact capture;
- detecting Figma node/version changes when the integration allows it;
- collecting build/commit/release facts;
- checking that approvals and evidence links exist;
- the health and analytics queries defined in the plan;
- proposing the next status.

### Stays under human authority

- approving the problem, the outcome, and the scope;
- design and experience trade-offs;
- accepting privacy/security/legal risk;
- waiving a gate;
- the release, cohort, and communication decision;
- the final acceptance of the delivered value.

Automation produces facts and recommendations. Explicit authority produces approvals.

---

## 18. Repository integration

A repository prepared for this loop provides:

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

`AGENTS.md` states at a glance:

- the build/test/lint/format/runtime commands;
- schemes, destinations, and toolchain;
- how design context is accessed;
- how the Delivery Packet is validated;
- which skills/capabilities are installed;
- which MCP/tool capabilities are active, their conditions, and their fallbacks;
- which actions are protected;
- where CI, release, and telemetry are found;
- the local deviations and their ADRs.

The project bootstrap must create this interface before the loop is used at scale. The
Delivery Loop cannot compensate for a repository without a deterministic build, signing
ownership, environments, or observability.

---

## 19. The recommended pilot

### Choosing the items

For v0.1 we choose:

- one medium-risk UI + API vertical slice;
- optionally, one small no-UI item or one production bug for contrast;
- no payments/health/legal-critical work as the first experiment;
- with real access to requirements, Figma, CI, TestFlight, and telemetry.

### What we watch for

- fields that have no owner or source;
- gates that duplicate each other;
- evidence that is hard to obtain;
- statuses that do not describe reality;
- approvals that are impossible in a small team;
- steps that agents can automate safely;
- gaps in the bootstrap, skills, or observability.

### Criteria for v1.0

- the schema worked for at least two different items;
- every status had a clear meaning;
- Product, Design, Engineering, QA, and Release confirmed their ownership;
- `DELIVERED` could be demonstrated from evidence, not from memory;
- waivers and `not applicable` did not become shortcuts;
- the cost of maintaining the Delivery Packet is lower than the cost of the ambiguity
  it removes.

---

## 20. Governance and changelog

The proposed owners are the Apple Platform Team for technical integration and Product
Delivery for lifecycle/approval. Security, Privacy, DesignOps, QA, and Release review
the sections that affect their authority.

A decision change:

1. updates the handbook and the compact standard in the same PR;
2. keeps the same `DLV-*` ID;
3. updates the affected schema/templates/checklists;
4. includes the impact on active items and a migration strategy;
5. updates the changelog.

### Changelog v0.1

- defined the unit of delivery and the target audience;
- introduced the requirements and Figma contracts;
- introduced the Delivery Packet and the status schema;
- separated CODE_COMPLETE, MERGED, RELEASED, PRODUCTION_VERIFIED, and DELIVERED;
- defined gates, evidence, approvals, waivers, and RACI;
- separated agent autonomy from human authority;
- linked the existing Apple skills and proposed four delivery capabilities;
- introduced release/rollback and the "no traffic is not health" rule;
- defined the feedback loop and the pilot metrics.
