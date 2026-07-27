# Definition of Ready

This gate authorizes final planning and implementation of a delivery item. It does not
guarantee that no changes will appear; it guarantees that unknowns and authority are
visible.

## Identity

| Field | Value |
|---|---|
| Delivery ID | |
| Revision | |
| Target audience | |
| Product owner | |
| Design owner | |
| Engineering owner | |
| Evaluation date | |

## 1. Outcome and scope

- [ ] The problem is stated from the user/operations perspective.
- [ ] The observable outcome is explicit.
- [ ] Target users and target audience are explicit.
- [ ] In scope and non-goals do not contradict each other.
- [ ] The item is small enough for independent verification.
- [ ] The priority and the reason for delivering are known.

## 2. Acceptance contract

- [ ] Every criterion has a stable `AC-*` ID.
- [ ] Criteria describe observable behavior, not code structure.
- [ ] The happy path is covered.
- [ ] Relevant edge/failure states are covered.
- [ ] Every criterion has one or more verification methods.
- [ ] Must/should/could or another priority scheme is explicit.
- [ ] Any deferred criterion is moved to non-goals or to a linked item.

## 3. Design

- [ ] `UI required` is declared.
- [ ] If there is UI, the Figma Definition of Ready checklist is passed.
- [ ] Node IDs and the reviewed version/timestamp are in the Delivery Packet.
- [ ] States, interactions, copy, assets, and accessibility intent are sufficient.
- [ ] Layout intent is stated beyond the reference frame: what is fixed, what is
      fluid, and how the smallest and largest supported device behave.
- [ ] If there is no UI, Product + Engineering have approved `not applicable`.
- [ ] The design change policy after READY is known.

## 4. Platforms and product

- [ ] Platforms, minimum OS, device classes, and orientations are declared.
- [ ] Locales and localization behavior are declared.
- [ ] Account state, permissions, entitlements, and subscription state are clear.
- [ ] Upgrade/background/offline behavior is clear where relevant.
- [ ] Known Apple platform/App Store constraints are recorded.

## 5. Data and dependencies

- [ ] The API/backend contract is available or has an approved stub/fake.
- [ ] Compatibility with older versions of the app is defined.
- [ ] Storage, cache, migration, and data retention are assessed.
- [ ] Every dependency has an owner and a status.
- [ ] Access to the required environments, test data, and accounts is confirmed.
- [ ] Blocking dependencies are `ready` or the item does not advance.

## 6. Risk and compliance

- [ ] The risk level is estimated.
- [ ] Privacy impact and data classification are assessed.
- [ ] Security/auth/permissions/secrets impact is assessed.
- [ ] Legal/content/licensing impact is assessed.
- [ ] Third-party SDK and privacy manifest impact are assessed.
- [ ] Mandatory reviewers have been identified.
- [ ] There is no critical risk without an owner and a decision.

## 7. Measurement and operations

- [ ] Success metrics are defined or `not applicable` with a reason.
- [ ] Guardrails are defined or `not applicable` with a reason.
- [ ] Analytics events and consent behavior are outlined.
- [ ] The operational telemetry needed for verification exists or is in scope.
- [ ] The channel, cohort, and condition for Delivered are explicit.
- [ ] The rollout and rollback concepts are feasible.

## 8. Unknowns and ownership

- [ ] Every unknown has an owner, a due date, and a blocking flag.
- [ ] There is no blocking unknown without a decision before READY.
- [ ] The applicable Product, Design, Engineering, QA, and Release owners are known.
- [ ] Protected actions and the approval path are clear.
- [ ] The Delivery Packet validates against schema v0.1.

## READY approvals

| Role | Mandatory | Decision | Actor | Date | Evidence/link |
|---|---:|---|---|---|---|
| Product | Yes | Pending / Approved / Rejected / Conditional | | | |
| Design | For UI | Pending / Approved / Rejected / Conditional / N/A | | | |
| Engineering | Yes | Pending / Approved / Rejected / Conditional | | | |
| Security | Based on risk | Pending / Approved / Rejected / Conditional / N/A | | | |
| Privacy/Legal | Based on risk | Pending / Approved / Rejected / Conditional / N/A | | | |

**Decision:** `READY / NOT READY`

**Remaining conditions, with owner and due date:**

---
