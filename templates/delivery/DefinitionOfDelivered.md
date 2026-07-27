# Definition of Delivered

This checklist is completed after release and production verification. `MERGED`,
`QA_ACCEPTED`, `RELEASE_CANDIDATE`, or `RELEASED` are not synonyms for `DELIVERED`.

## Delivery identity

| Field | Value |
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

## 1. Availability to the audience

- [ ] The build/configuration is accessible to the declared target audience.
- [ ] The effective cohort and percentage match the approved plan.
- [ ] Feature flags and prerequisites have the expected values.
- [ ] Signing, entitlements, and environment configuration have been confirmed.
- [ ] The observed version/build is the declared one, not a local or earlier build.

## 2. Acceptance

- [ ] Every `must` acceptance ID has a `passed` result and evidence.
- [ ] Every incomplete `should/could` has an approved disposition and a linked item.
- [ ] The happy path has been exercised on the distributed build.
- [ ] Critical failure/edge paths have been verified at the appropriate level.
- [ ] There are no undeclared differences between requirements, Figma, and behavior.
- [ ] Product has confirmed the outcome for the declared audience.

## 3. Quality gates

- [ ] Build/CI.
- [ ] Applicable unit/integration/UI tests.
- [ ] Runtime behavior.
- [ ] Design parity and approved deviations, verified on the reference, smallest, and
      largest supported device in both appearances.
- [ ] Accessibility.
- [ ] Localization.
- [ ] Performance/energy/memory/network, as applicable.
- [ ] Reliability/offline/retry/cancellation/migration, as applicable.
- [ ] Privacy and data handling.
- [ ] Security/auth/permissions/secrets.
- [ ] Analytics and consent.
- [ ] Distribution/install/upgrade.

Every `not applicable` has a reason. Every waiver has an approver, mitigation,
expiry, and follow-up.

## 4. Production verification

- [ ] Install or upgrade and launch have been verified on a representative device.
- [ ] The critical path has been freshly exercised.
- [ ] Relevant backend/dependency requests have the expected outcome.
- [ ] Crash/error/performance signals have been queried for the correct window.
- [ ] The expected analytics event was generated and its ingestion verified, where
  consent exists and it is applicable.
- [ ] Evidence includes build, environment, actor, and timestamp.
- [ ] The data does not come exclusively from another build or from before the release.
- [ ] The window has valid traffic/exercise; otherwise the item is marked `not exercised`.

## 5. Risk and operations

- [ ] There is no open P0/P1.
- [ ] There is no open release blocker.
- [ ] There is no expired waiver.
- [ ] Known limitations are visible to Product, QA, Support, and Release.
- [ ] Rollback/mitigation remains executable and has an owner.
- [ ] Dashboards/queries and the incident path are linked.
- [ ] Support/release notes are updated where needed.

## 6. Delivery Packet integrity

- [ ] `delivery.yml` validates against the current schema.
- [ ] `current_status` was not advanced automatically without approvals.
- [ ] Status history contains actor, time, reason, and evidence.
- [ ] PR, CI, release console, and telemetry links are current.
- [ ] No piece of evidence contains a secret or unauthorized PII.
- [ ] Follow-ups and defects have linked items.

## Final approvals

| Role | Decision | Actor | Date | Evidence/link |
|---|---|---|---|---|
| Runtime verifier | Verified / Not verified | | | |
| QA / Acceptance owner | Approved / Rejected / Conditional | | | |
| Release owner | Approved / Rejected / Conditional | | | |
| Product / Delivery owner | Approved / Rejected / Conditional | | | |

**Final decision:** `DELIVERED / REMAINS PRODUCTION_VERIFIED / REMAINS RELEASED / REOPENED`

**Exact scope of the Delivered claim:**

**Limitations and follow-up:**

---
