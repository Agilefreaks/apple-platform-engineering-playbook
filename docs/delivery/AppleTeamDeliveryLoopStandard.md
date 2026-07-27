# Apple Team Delivery Loop Standard v0.1

Agent-facing operational standard for taking an Apple-platform delivery item from
requirements and Figma to verified delivery.

| Metadata | Value |
|---|---|
| Status | Proposed v0.1 — ready for pilot |
| Version | 0.1 |
| Canonical source | AppleTeamDeliveryLoopHandbook.md |
| Audience | Coding agents, automation, reviewers, and release operators |
| Applies to | iOS, iPadOS, and tvOS product delivery |
| Companion | Apple Team Architecture Standard v2.1 |
| Review cadence | After each pilot, then at least twice per year |

This is the compact operational form of the handbook. Decision IDs in this document
must exist in the handbook. CI should verify that both documents expose the same DLV
ID set.

## 1. Authority and vocabulary [DLV-001]

Order of authority:

1. Current approved product requirements and acceptance criteria.
2. Approved security, privacy, legal, and platform constraints.
3. Approved repository ADRs and the Apple Team Architecture Standard.
4. This Delivery Loop Standard.
5. Repository-local delivery conventions.

Normative words:

- **MUST**: required to pass the gate.
- **SHOULD**: default; deviation requires a recorded reason.
- **MAY**: optional.
- **Evidence**: a durable link, file, build identifier, test result, screenshot, log
  query, or approval that another reviewer can inspect.
- **Delivery item**: the smallest independently verifiable product outcome. A ticket
  is not automatically a valid delivery item.
- **Target audience**: the users for whom the result must be available. This may be
  an internal cohort, TestFlight group, phased App Store cohort, or all production
  users.

The Architecture Standard governs code shape. This standard governs the delivery
process. A merge, release submission, App Store approval, or feature-flag deployment
is not automatically a delivered outcome.

## 2. Decisions

| ID | Area | Rule |
|---|---|---|
| DLV-001 | Authority | Requirements, compliance constraints, ARCH, and this standard have explicit precedence. |
| DLV-002 | Unit of delivery | Work is tracked as a small, independently verifiable user or operational outcome. |
| DLV-003 | Requirements contract | Problem, outcome, scope, acceptance, risks, telemetry, rollout, owners, and unknowns are explicit. |
| DLV-004 | Figma contract | Exact nodes, reviewed version, state matrix, tokens, copy, assets, interactions, and accessibility intent are recorded. |
| DLV-005 | Delivery Packet | Every delivery item has one versioned `delivery.yml` plus linked plans and evidence. |
| DLV-006 | State machine | Status transitions are explicit, evidence-backed, monotonic by default, and never inferred from Git alone. |
| DLV-007 | Definition of Ready | Implementation starts only after requirements, design, dependencies, owners, and acceptance are ready. |
| DLV-008 | Technical plan | The plan maps acceptance to architecture, data, analytics, tests, rollout, and rollback. |
| DLV-009 | Implementation | Build vertical slices, keep the app runnable, and preserve requirement-to-code-to-test traceability. |
| DLV-010 | Quality gates | Build, tests, runtime, design, accessibility, localization, performance, privacy, security, and analytics are gated proportionally. |
| DLV-011 | Agents and autonomy | Agent roles are logical capabilities; agents may execute reversible work but may not self-approve or perform protected release actions. |
| DLV-012 | Approval | Product, design, engineering, QA, and release approvals are explicit; authors do not approve their own gate where separation is required. |
| DLV-013 | Release and rollback | Channel, cohort, build, flag, compatibility, owner, abort thresholds, and rollback path are known before release. |
| DLV-014 | Production verification | Verify the distributed build and critical path using fresh evidence; no traffic is not evidence of health. |
| DLV-015 | Delivered | Delivered means available to the target audience, acceptance verified, telemetry exercised, and no unresolved release blocker. |
| DLV-016 | Feedback loop | Production evidence, defects, design drift, and delivery metrics create new inputs; history is never silently rewritten. |
| DLV-017 | Parallel execution | Each concurrent worker owns a dedicated Simulator (unique UDID) and pins every operation to it; no worker runs destructive lifecycle actions on a device it does not own. |
| DLV-018 | Design fidelity | A Figma frame defines visual intent, not fixed geometry; parity means native SwiftUI layout that reproduces the design's hierarchy, proportion, and tokens on every supported device, appearance, and Dynamic Type size. |

## 3. Required inputs [DLV-002] [DLV-003] [DLV-004]

### 3.1 Requirements contract

Before READY, the Delivery Packet MUST identify:

- delivery ID, title, problem, intended outcome, target users, and owner;
- in-scope and out-of-scope behavior;
- testable acceptance criteria with stable IDs;
- loading, empty, error, offline, permission, retry, and cancellation behavior when
  relevant;
- supported platforms, minimum OS, device classes, orientations, and languages;
- analytics events and success/guardrail metrics, or an explicit `not applicable`;
- privacy, security, data-retention, account, entitlement, and legal implications;
- backend/API dependencies and compatibility assumptions;
- rollout channel, target audience, feature-flag policy, and rollback concept;
- dependencies, unresolved questions, decision owners, and due dates;
- product, design, engineering, QA, and release owners.

Acceptance criteria MUST describe observable behavior, not implementation. Every
criterion has an ID such as `AC-01` and a verification method.

### 3.2 Figma contract

Before READY, design input MUST include:

- Figma file URL/key, page, exact node IDs, and review timestamp or named version;
- supported device frames and layout intent, not a single unexplained screenshot;
- state coverage: loading, loaded, empty, error, offline, permission, destructive
  confirmation, and success where applicable;
- interaction states: default, pressed, disabled, focused, selected, validation, and
  keyboard/focus behavior where applicable;
- light/dark mode, Dynamic Type, VoiceOver reading intent, contrast, Reduce Motion,
  and tvOS focus where relevant;
- component/variant names, variables/tokens, asset sources, export rules, and final
  copy;
- navigation/prototype behavior, ownership of design parity, and accepted deviations;
- an explicit design-change policy after READY.

Asset export rule: assets MUST export from Figma as SVG whenever Figma renders the
artwork faithfully as vector; otherwise as PNG at 3x only. Each Asset Catalog image
set MUST hold one universal Single Scale variant — never 1x/2x/3x triplets — and
views size images explicitly instead of relying on intrinsic size.

Node IDs and review timestamp prevent a silently changed Figma file from becoming an
unreviewed requirement. A material design change after READY returns the item to an
appropriate earlier gate.

### 3.3 Design fidelity [DLV-018]

A Figma frame is one sample of the layout drawn at one canvas size. The contract is
the visual intent behind it — hierarchy, proportion, spacing rhythm, typography ramp,
color, and state — not the pixel coordinates of that frame.

`Pixel perfect` in this standard means: on every supported device, appearance, and
Dynamic Type size, the running app is indistinguishable from what the designer
intended. It does not mean a pixel-for-pixel reproduction of the reference frame on
one device.

Required:

- Design handoff MUST state the layout rule wherever the frame alone is ambiguous:
  what is fixed, what is fluid, what wraps, what reflows, and what the smallest and
  largest supported device do.
- Implementation MUST express layout with native SwiftUI containers, modifiers, and
  system components — stacks, `Grid`, `ViewThatFits`, `Spacer`, padding and spacing
  tokens, layout priority, size classes, safe-area insets, `List`/`Form`,
  `ScrollView`, text styles, and `.containerRelativeFrame` where a proportion is
  genuinely the rule.
- Implementation MUST NOT reconstruct the design by measuring the canvas: no scale
  factors derived from a reference width or height, no hardcoded
  `.frame(width:height:)` on text or containers to match a mockup, no absolute
  offsets or manual `GeometryReader` positioning where a stack and spacing express
  the same intent, no hardcoded font point sizes in place of text styles, and no
  per-device magic numbers derived from screen bounds.
- Fixed dimensions are permitted only where the design is genuinely context
  independent — icon and glyph frames, hairlines, minimum touch targets, fixed-size
  imagery — and they come from DesignSystem tokens, not feature literals.
- Any value that exists as a Figma variable MUST reach the code as a token, never as
  a duplicated literal.
- Type MUST scale with Dynamic Type and layout MUST reflow rather than clip: designed
  fixed heights become minimum heights, single-line labels get explicit wrapping or
  truncation rules, and horizontal groupings collapse as declared.
- Native platform behavior — navigation, sheets and detents, swipe actions, focus,
  keyboard avoidance, scroll and safe areas — takes precedence over a redrawn
  look-alike unless the design explicitly requires a custom control and an approver
  accepts the cost.
- Differences forced by the platform (system control metrics, safe areas,
  accessibility minimums) are recorded as accepted deviations, not corrected with
  fixed geometry.

Design parity evidence MUST therefore cover the reference device plus the smallest
and largest supported devices, both appearances, and at least the largest declared
Dynamic Type size. A screenshot that matches the reference frame on one device is not
sufficient parity evidence.

## 4. Delivery Packet [DLV-005]

Canonical repository shape:

~~~text
delivery/items/<DELIVERY-ID>/
  delivery.yml               # machine-readable source of status and links
  requirements.md            # detail only when delivery.yml is insufficient
  design-map.md               # node/state/component mapping
  technical-plan.md
  test-plan.md
  decisions.md                # delivery decisions; architecture decisions use ADR
  evidence/
    implementation/
    tests/
    design/
    qa/
    release/
    production/
~~~

Rules:

- `delivery.yml` MUST validate against `schemas/delivery.schema.json` before READY.
- Durable sources are linked; their full content is not copied unnecessarily.
- Evidence MUST be inspectable by the team and MUST NOT contain secrets or personal
  data.
- Status changes append a history entry with actor, time, evidence, and reason.
- A reopened item preserves prior evidence and records why it moved backward.
- Product facts belong in requirements; technical decisions belong in the plan or
  ADR; current lifecycle truth belongs in `delivery.yml`.

## 5. Lifecycle state machine [DLV-006]

Primary flow:

~~~text
DRAFT
  -> READY
  -> PLANNED
  -> IMPLEMENTING
  -> CODE_COMPLETE
  -> MERGED
  -> QA_ACCEPTED
  -> RELEASE_CANDIDATE
  -> RELEASED
  -> PRODUCTION_VERIFIED
  -> DELIVERED
~~~

Exceptional statuses:

- `BLOCKED`: progress cannot continue; owner, reason, unblock condition, and next
  review time are required.
- `CANCELLED`: an authorized product owner stopped the outcome; reason is required.
- `REOPENED`: previous evidence was invalidated or a delivered behavior regressed;
  the next target status and reason are required.

Transition rules:

- Git, CI, App Store Connect, or a feature-flag system MAY propose a transition but
  MUST NOT invent missing product/design/QA approval.
- A status MUST NOT be advanced because time passed or because no failure was seen.
- `MERGED` proves integration into the selected branch only.
- `RELEASED` proves availability of a build/configuration in the declared channel
  only.
- `PRODUCTION_VERIFIED` requires fresh exercise of the critical path.
- `DELIVERED` requires the complete DLV-015 gate.

## 6. Gates and required evidence [DLV-007] [DLV-008] [DLV-010]

| Target status | Required gate | Minimum evidence |
|---|---|---|
| READY | Definition of Ready | Approved requirements, Figma contract or explicit no-UI declaration, owners, dependencies, acceptance IDs |
| PLANNED | Technical Plan | Architecture mapping, API/data plan, risk, test matrix, analytics, rollout and rollback |
| CODE_COMPLETE | Implementation | Acceptance-to-code/test trace, build, automated tests, preview/runtime proof, no known P0/P1 |
| MERGED | Integration | Approved review, protected-branch CI, merge commit/PR, migration compatibility |
| QA_ACCEPTED | QA | Acceptance matrix results, exploratory evidence, defects dispositioned, design/accessibility review |
| RELEASE_CANDIDATE | Release readiness | Signed/archive build ID, release notes, compliance metadata, flag/cohort plan, rollback rehearsal or review |
| RELEASED | Distribution | Channel, version/build, release time, cohort/flag state, release operator |
| PRODUCTION_VERIFIED | Production verification | Fresh distributed-build smoke test, telemetry queries, critical analytics event, backend/flag health |
| DELIVERED | Definition of Delivered | Target audience access, all acceptance satisfied, no unresolved blocker, evidence and final approvals |

Gate waivers:

- MUST name the waived check, risk, rationale, approver, expiry, mitigation, and follow-up.
- MUST be approved by the owner of that risk; an agent cannot create an approval.
- MUST NOT be used to relabel missing production exercise as verified.
- Security, privacy, legal, signing, and release-authority requirements are never
  implicitly waivable.

## 7. Technical planning [DLV-008]

The technical plan MUST map each acceptance criterion to:

- owning feature and affected modules;
- UI/state/navigation changes;
- API, storage, migration, cache, and offline behavior;
- analytics and operational telemetry;
- concurrency, performance, accessibility, localization, privacy, and security risk;
- automated test level and runtime verification;
- feature-flag, compatibility, rollout, abort, and rollback behavior;
- expected evidence and approval owner.

The plan MUST call out unknowns and spikes. A spike may reduce uncertainty but MUST NOT
be represented as shipped product behavior. Architecture deviations require an ADR
under ARCH v2.1.

Prefer slices that can be built and verified end to end. Horizontal layers that leave
the application unrunnable SHOULD be avoided.

## 8. Implementation loop [DLV-009]

For each vertical slice:

1. Select acceptance IDs and design node/state IDs.
2. Confirm current requirements and Figma review version.
3. Implement using the Architecture Standard and repository-local instructions.
4. Run deterministic format, lint, build, test, and relevant runtime commands.
5. Capture evidence for normal, boundary, failure, and accessibility states.
6. Review requirement traceability, code, design parity, and risk.
7. Update the Delivery Packet and continue with the next slice.

The application SHOULD remain buildable after each merged slice. Generated or
agent-authored code has the same quality bar as human-authored code.

## 9. Quality model [DLV-010]

Apply checks proportionally, but record `not applicable` with a reason instead of
silently omitting a relevant area.

Required categories:

- **Build:** clean checkout, supported toolchain, declared scheme/destination.
- **Behavior:** unit/integration/UI tests plus runtime exercise of critical behavior.
- **Design:** mapped states and devices, tokens, assets, copy, approved deviations, and
  adaptive fidelity — native SwiftUI layout, no canvas-derived geometry [DLV-018].
- **Accessibility:** Dynamic Type, VoiceOver semantics/order, contrast, focus/input,
  Reduce Motion, and identifiers for stable critical UI tests.
- **Localization:** String Catalog coverage, truncation/layout, locale-sensitive values,
  and right-to-left behavior when supported.
- **Performance:** launch, responsiveness, memory, scrolling, energy, network, or media
  budgets where the feature can affect them.
- **Reliability:** offline, retry, cancellation, idempotency, migration, stale data,
  partial failure, and dependency failure where relevant.
- **Privacy/security:** data classification, consent, storage, logging, permissions,
  secrets, ATS, third-party SDKs, privacy manifest, and required-reason APIs.
- **Analytics:** typed events, consent behavior, schema validation, deduplication, and
  successful ingestion in the target environment.

A screenshot can prove appearance, not behavior. A unit test can prove logic, not
distribution. A green CI run can prove declared checks, not product acceptance.
A successful Tapia flow can prove an observed interaction on the identified local
Simulator build; it cannot prove real-device, distributed-build, or production behavior.

## 10. Agent roles, skills, and autonomy [DLV-011]

Roles are logical capabilities. One person or agent may perform multiple execution
roles, but approval separation still applies.

| Role | Responsibility | Cannot claim alone |
|---|---|---|
| Orchestrator | Maintains packet, selects next gate, detects missing evidence | Product/design/release approval |
| Requirements analyst | Normalizes requirements and acceptance IDs | Scope approval |
| Design-context agent | Maps Figma nodes, states, tokens, assets, and changes | Final design acceptance |
| iOS implementation agent | Implements vertical slices under ARCH | Merge, QA, or Delivered approval |
| Test agent | Builds verification matrix and runs automated checks | Product acceptance |
| Review agent | Reviews code, architecture, security, and traceability | Its own authored change where independence is required |
| Runtime verifier | Exercises built/distributed app and captures evidence | Production release authority |
| Release operator | Executes approved distribution and flags | Scope or quality waiver |

Agents MAY, within repository authorization:

- read requirements, Figma context, code, CI results, and telemetry;
- create/update the Delivery Packet, code, tests, and local evidence;
- run deterministic local checks and draft a pull request;
- recommend a gate transition or identify a blocker.

Agents MUST NOT without explicit human authority:

- approve scope, design, privacy/legal risk, a gate waiver, or their own required
  independent review;
- change signing, certificates, entitlements, App Store contracts, pricing, or
  production credentials;
- submit/release a build, change a production flag/cohort, message users, or delete
  production data;
- hide a failing check, fabricate evidence, or infer success from absent telemetry.

### Skill/capability mapping

Use the canonical Apple skills declared by ARCH v2.1 when relevant:

| Work | Skill |
|---|---|
| SwiftUI implementation | `apple/swiftui-patterns` |
| SwiftUI restructuring | `apple/swiftui-refactoring` |
| SwiftUI performance | `apple/swiftui-performance` |
| Concurrency | `apple/swift-concurrency` |
| Tests | `apple/swift-testing` |
| Simulator/device runtime | `apple/ios-runtime-debugging` |
| Accessibility | `apple/apple-accessibility` |
| TCA project | `apple/tca` |

Delivery capabilities proposed for the company skill registry:

- `delivery/requirements-normalization`
- `delivery/figma-handoff`
- `delivery/technical-planning`
- `delivery/release-verification`

Until those skills exist and are versioned, their checklist in this package is the
fallback authority. A missing skill blocks automation of that capability, not the
team's ability to execute the documented workflow manually. Repository runtime names
are mapped in `AGENTS.md`; required versions live in `tooling/skills.yml` and
`skills.lock` when supported.

Tool capabilities are declared separately in `tooling/tools.yml`. Xcode automation is
recommended. Tapia MCP implements `apple/ios-simulator-automation` with
`recommended_conditional` adoption for agent-heavy projects that need repeatable
semantic UI flows, accessibility-tree inspection, and local Simulator evidence.

When adopted, pin the reviewed revision, use stable accessibility identifiers, keep
the session isolated from production data, and capture build/configuration/destination
with the result. Tapia does not replace XCUITest regression coverage, CI, real-device
testing, release checks, or protected approvals. Use the manifest fallbacks and report
the reduced evidence level when the capability is unavailable.

### Parallel execution and shared-resource isolation [DLV-017]

A Simulator is a single-writer, stateful resource per UDID. When work fans out across
concurrent workers (agents, worktrees, loop iterations), they MUST NOT share one booted
device: implicit "current Simulator" access makes workers overwrite each other and can
trigger a boot/restart thrash loop that stalls the whole fleet.

Rules for concurrent runs:

- Each concurrent worker owns exactly one dedicated Simulator device with a unique UDID,
  provisioned up front into a pool sized to the fan-out width (for example
  `xcrun simctl clone` or `create` plus `boot`). The orchestrator owns pool lifecycle;
  workers do not create or tear down shared devices.
- Every Simulator operation is pinned to the owned UDID — Tapia target selection,
  `xcrun simctl <op> <UDID>`, and `xcodebuild -destination 'id=<UDID>'`. A worker never
  acts on the booted Simulator implicitly.
- A worker MUST NOT run `restart`, `shutdown`, `erase`, or re-`boot` on a device it does
  not own. Destructive lifecycle actions on a shared device are prohibited during a
  parallel session.
- Runtime evidence records the assigned UDID alongside the Simulator model, OS, and build.
- Teardown is the orchestrator's responsibility at end of session, not the worker's.
- Fallback when a per-worker device pool cannot be provisioned: serialize all Simulator
  access into a single Runtime-verifier lane; build, lint, and test still fan out.

## 11. Approvals and separation of duties [DLV-012]

Minimum approvals:

- READY: Product, Design for UI work, and Engineering.
- PLANNED: Engineering; Security/Privacy when triggered by risk.
- QA_ACCEPTED: QA or designated acceptance owner; Design for material UI work.
- RELEASE_CANDIDATE: Engineering, QA, and Release owner; Product confirms cohort.
- DELIVERED: Product or Delivery owner after production verification.

Approval is an attributable record with actor, role, status, time, scope, and optional
conditions. A chat reaction without durable identity/scope is not sufficient for a
protected gate.

Low-risk teams MAY combine roles, but the change author MUST NOT fabricate another
role's approval. High-risk work SHOULD require an independent engineering reviewer and
designated security/privacy approval.

## 12. Release and rollback [DLV-013]

Before RELEASE_CANDIDATE, record:

- channel, environment, target audience, cohort percentage, and release window;
- bundle identifier, marketing version, build number, commit, and CI/archive run;
- feature-flag names, defaults, prerequisites, and operator;
- App Store/TestFlight metadata and compliance status where applicable;
- server/API/schema backward-compatibility window;
- health signals, abort thresholds, incident owner, and communication path;
- rollback/mitigation: flag off, server fallback, safe data migration behavior,
  previous compatible build, or hotfix path.

Because an installed iOS binary cannot generally be force-downgraded, rollback design
MUST prioritize feature flags, backward-compatible services, safe migrations, and
forward fixes. "Upload another build" alone is not a complete rollback plan.

## 13. Production verification [DLV-014]

Verification MUST use the declared distributed build and target environment. Local or
debug proof is useful but cannot replace release proof. This includes successful
Xcode preview, Simulator, Tapia, `simctl`, or local XCUITest results.

Minimum fresh evidence:

- version/build/commit and effective feature-flag configuration;
- install/upgrade/launch and critical-path smoke test on a representative device;
- key backend requests or dependency outcomes;
- crash/error/performance query for the verification window;
- expected product analytics event reaching the destination, subject to consent;
- acceptance-specific outputs and any cohort restrictions;
- verifier, timestamp, environment, and evidence links.

Interpretation rules:

- `no errors and valid traffic` may support health.
- `no errors and no traffic` means **not exercised**, not healthy.
- stale evidence from an older build cannot verify the current release.
- local success, merge success, archive success, App Review success, and production
  exercise are distinct facts and MUST be reported separately.

## 14. Definition of Delivered [DLV-015]

Set `DELIVERED` only when all are true:

1. The declared version/configuration is accessible to the target audience.
2. Every in-scope acceptance criterion is passed or has an approved, non-blocking
   disposition visible to Product.
3. The critical path was freshly exercised on the distributed build.
4. Required design, accessibility, localization, performance, privacy, security, and
   analytics gates passed or have valid waivers.
5. Expected telemetry was generated and its ingestion was checked; no-traffic windows
   are explicitly marked unverified.
6. There is no unresolved P0/P1, release blocker, or expired waiver.
7. Release and rollback facts, known limitations, approvals, and evidence are linked.
8. Product or Delivery owner approved the final outcome for the declared audience.

`DELIVERED` is scoped. A result delivered to an internal TestFlight cohort is not
delivered to all App Store users unless that was the declared target audience.

## 15. Feedback and metrics [DLV-016]

After release:

- defects and user feedback create linked delivery items;
- changed requirements or Figma nodes create a new revision and gate impact review;
- a regression sets `REOPENED` rather than rewriting the original history;
- incidents link to the affected version, feature flag, and Delivery Packet;
- reusable lessons update the standard, skill, test suite, or project bootstrap.

Measure the system, not individual people or agent token volume:

- READY-to-DELIVERED lead time;
- blocked time and top blocker classes;
- first-pass rate per gate;
- post-READY requirement/design churn;
- escaped-defect and change-failure rate;
- rollback/mitigation time;
- production-verification latency;
- acceptance criteria with automated and runtime evidence.

Metrics MUST retain context. Faster delivery with rising escaped defects, missing
telemetry, or shrinking scope is not an improvement.

## 16. Agent completion checklist

Before reporting a delivery-loop task complete, an agent MUST state:

- current status and target audience;
- acceptance IDs addressed and any remaining scope;
- files/commit/build/configuration changed;
- checks actually run and their results;
- runtime/distributed evidence actually observed;
- approvals obtained versus still required;
- blockers, waivers, known limitations, and next authorized action;
- whether the result is code-complete, merged, released, production-verified, or
  delivered — never a less precise synonym.
