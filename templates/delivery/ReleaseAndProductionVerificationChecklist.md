# Release and Production Verification Checklist

This artifact covers the `QA_ACCEPTED → RELEASE_CANDIDATE → RELEASED →
PRODUCTION_VERIFIED` transitions. Complete it for the effective build and cohort.

## Release identity

| Field | Value |
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

- [ ] Requirements, the Figma reviewed version, and acceptance IDs have not changed materially.
- [ ] QA_ACCEPTED refers to this build or to a demonstrably equivalent build.
- [ ] All must acceptance criteria have passed evidence.
- [ ] Design and accessibility reviews are closed for material UI.
- [ ] Open defects have a severity, an owner, and an approved disposition.
- [ ] There is no P0/P1 or release blocker.
- [ ] Waivers are valid, unexpired, and visible to the risk owners.
- [ ] Release notes and known limitations are prepared.

## 2. Build, signing, and configuration

- [ ] A clean archive was produced by the supported toolchain/CI.
- [ ] Bundle ID, version, build, and commit match the Delivery Packet.
- [ ] The signing certificate and provisioning profile are the expected ones.
- [ ] Entitlements and capabilities are correct.
- [ ] Environment URLs and public client configuration are correct.
- [ ] There are no debug flags, test endpoints, mock data, or secrets in the build.
- [ ] dSYM/symbols and crash reporting upload are confirmed.
- [ ] The privacy manifest and required-reason APIs are verified.
- [ ] App Store/TestFlight compliance and metadata are complete.

## 3. Compatibility and data

- [ ] The API/backend supports the installed versions over the declared window.
- [ ] Schema/migrations are forward-safe and have been tested.
- [ ] Upgrading from the relevant versions has been verified.
- [ ] Downgrade assumptions are not used as an implicit rollback.
- [ ] Cache, stale data, and offline behavior have been assessed.
- [ ] Repeated actions and idempotency are safe where applicable.
- [ ] Feature flags have safe defaults for old and new clients.

## 4. Observability readiness

- [ ] Crash/error/performance dashboards or queries are linked.
- [ ] Backend/dependency health queries are linked.
- [ ] Typed product analytics events and their schema are documented.
- [ ] Consent behavior and the test account/cohort are known.
- [ ] Critical-path correlation includes build/environment without PII.
- [ ] The verifier can distinguish the absence of traffic from healthy traffic.
- [ ] The incident owner, channel, and escalation path are active during the release window.

## 5. Rollout and rollback

- [ ] The channel and cohort have Product + Release approval.
- [ ] Flag names, prerequisites, defaults, and release values are recorded.
- [ ] Abort conditions have a threshold, a window, and an owner.
- [ ] The kill switch/flag-off has been reviewed or tested in proportion to the risk.
- [ ] Server fallback and backward compatibility are confirmed.
- [ ] Data migration does not leave corrupted data after the behavior is disabled.
- [ ] The hotfix path and estimated time are known.
- [ ] The communication path for support/stakeholders is prepared.

## 6. RELEASE_CANDIDATE approvals

| Role | Decision | Actor | Date | Evidence/link |
|---|---|---|---|---|
| Engineering | Pending / Approved / Rejected / Conditional | | | |
| QA | Pending / Approved / Rejected / Conditional | | | |
| Product — cohort | Pending / Approved / Rejected / Conditional | | | |
| Release | Pending / Approved / Rejected / Conditional | | | |
| Security/Privacy/Legal — based on risk | Pending / Approved / Rejected / Conditional / N/A | | | |

**Decision:** `RELEASE_CANDIDATE / NOT READY`

## 7. Release execution

- [ ] The operator confirmed the build and target audience before acting.
- [ ] The build was distributed to the approved channel.
- [ ] Effective flag/cohort values were read back after the change.
- [ ] The release time and the operator are recorded.
- [ ] App Store/TestFlight status and link are recorded.
- [ ] No unapproved action extended the cohort or the scope.
- [ ] `current_status` was set to `RELEASED`, not `DELIVERED`.

## 8. Production verification

### Setup

- [ ] The verifier uses the distributed build, not a debug/local build.
- [ ] Device, OS, account state, locale, and network conditions are recorded.
- [ ] Build/version and effective flags are confirmed in the app/system.
- [ ] The telemetry window starts after the release/config change.

### Smoke and acceptance

- [ ] Install or upgrade.
- [ ] Launch and authentication/session state.
- [ ] Full critical path.
- [ ] At least one critical failure/recovery path, if safe to do so.
- [ ] Persistence/background/resume when they are part of acceptance.
- [ ] The visible result matches Figma/acceptance for the verified states.
- [ ] Evidence is linked to acceptance IDs.

### Telemetry

- [ ] The relevant request/dependency outcome was observed.
- [ ] Crash/error signals were checked in the correct window.
- [ ] Performance guardrails were checked where applicable.
- [ ] The product analytics event reached its destination, where consent allows.
- [ ] Build, environment, and cohort can be identified without exposing PII.
- [ ] The signals are fresh and belong to the current release.

### Evidence interpretation

Select exactly one:

- [ ] **Exercised and healthy:** there was valid exercise and no blockers appeared.
- [ ] **Exercised and unhealthy:** there was valid exercise and errors/blockers appeared.
- [ ] **Not exercised:** there is insufficient traffic/controlled testing; the absence of
  errors is not interpreted as health.
- [ ] **Inconclusive:** the signals are contradictory or telemetry is missing.

For `Not exercised` or `Inconclusive`, the item remains `RELEASED` or `BLOCKED` and has
an owner + the next verification. It does not advance to `PRODUCTION_VERIFIED`.

## 9. Decision and closure

| Role | Decision | Actor | Date | Evidence/link |
|---|---|---|---|---|
| Runtime verifier | Verified / Not verified / Inconclusive | | | |
| Engineering/Operations | Healthy / Unhealthy / Inconclusive | | | |
| QA | Accepted / Rejected / Conditional | | | |
| Release owner | Continue / Pause / Roll back / Mitigate | | | |

**Resulting status:** `PRODUCTION_VERIFIED / REMAINS RELEASED / BLOCKED / REOPENED`

**Evidence window and summary:**

**Anomalies, missing observability, and follow-up:**

**Rollback/mitigation executed, if applicable:**

---
