# Delivery Loop RACI

Baseline matrix for the Apple Team. Adapt it to the project without removing the single
decision owner and without turning an agent into an implicit human authority.

## Legend

- **A — Accountable:** approves the result; ideally a single A per activity.
- **R — Responsible:** performs the work.
- **C — Consulted:** provides input before the decision.
- **I — Informed:** receives the result/decision.
- **—:** no implicit responsibility.

## Roles

| Role | Primary responsibility |
|---|---|
| Product (P) | Problem, outcome, scope, priority, target audience, final acceptance |
| Design (D) | Figma contract, UX, copy, design parity, and design accessibility intent |
| Engineering (E) | Architecture, technical plan, implementation, code quality, and technical risk |
| QA (Q) | Test strategy, acceptance execution, exploratory quality, and defect disposition |
| Security/Privacy/Legal (S) | Risk approval within their domain, when triggered |
| Release (R) | Signing/release readiness, distribution, operational cohort, and rollback execution |
| Analytics/Operations (O) | Measurement contract, telemetry, dashboards, and production evidence |
| Delivery owner (L) | Delivery Packet coherence, gates, status history, and follow-up |

## Baseline matrix

| Activity / Gate | P | D | E | Q | S | R | O | L |
|---|---|---|---|---|---|---|---|---|
| Define problem/outcome/scope | A/R | C | C | C | C | I | C | R |
| Write acceptance criteria | A | C | C | R | C | I | C | R |
| Approve Figma contract | C | A/R | C | C | C | I | — | R |
| Declare target audience | A/R | I | C | C | C | C | C | R |
| Assess privacy/security/legal | C | C | R | C | A/R | I | C | I |
| Gate READY | A | A for UI | A | C | C based on risk | I | C | R |
| Write technical plan | C | C | A/R | C | C | C | C | I |
| Approve architecture / ADR | I | C | A/R | C | C | I | — | I |
| Implement vertical slice | I | C | A/R | C | C | I | C | I |
| Code review | I | C | A/R | C | C | I | — | I |
| Design parity review | C | A/R | R | C | C | I | — | I |
| Accessibility verification | I | A for intent | R | A/R for verification | C | I | — | I |
| Test strategy and execution | C | C | R | A/R | C | I | C | I |
| Defect disposition before release | A | C | R | R | C | C | I | I |
| Gate QA_ACCEPTED | C | A for material UI | C | A/R | C | I | I | R |
| Measurement/telemetry readiness | C | I | R | C | C | I | A/R | I |
| Rollout and abort thresholds | A | I | C | C | C | A/R | R | I |
| Rollback plan | I | I | A/R technical | C | C | R operational | C | I |
| Gate RELEASE_CANDIDATE | C | C | A | A | C based on risk | A/R | C | R |
| Execute release/flag/cohort | I | I | C | I | I | A/R | C | I |
| Production verification | I | C | R | R | C | C | A/R | R |
| Declare DELIVERED | A | C | C | C | C | C | C | R |
| Incident / mitigation | I | I | R | C | C | A | R | I |
| Reopen / follow-up | A | C | C | C | C | I | C | R |

In rows with multiple `A`s, each A approves only its own domain. The Delivery owner
cannot substitute for Product, Design, Security, or Release approval.

## Small teams

Roles may be held by the same person, with the following guardrails:

- Product authority and release execution remain explicitly assigned.
- For high/critical risk, the code author is not the only engineering reviewer.
- Security/Privacy/Legal approval is not informally absorbed by Engineering.
- QA may be a shared responsibility, but acceptance evidence has an owner.
- Any combined role is declared in `owners`; we do not infer it from the absence of a name.

## AI agents

An agent may be `R` for analysis, implementation, testing, documentation, and evidence
collection. An agent may recommend a decision and may record a genuine approval that
came from the owner.

An agent does not become `A` for:

- scope and product acceptance;
- design acceptance;
- privacy/security/legal risk acceptance;
- gate waivers;
- signing, release, or production flag authority;
- the final Delivered declaration.

An agent does not present itself as an independent reviewer of its own output. If the
same agent runs a technical review, the result is a self-check until the project's
policy explicitly accepts it or an independent reviewer steps in.

## Adapting the matrix

Any project may add roles such as Backend, Data, Support, or Client. The adaptation:

1. keeps a clear owner for every gate;
2. documents combined roles;
3. does not remove approvals required by the risk level;
4. is linked from `AGENTS.md` or the Delivery Packet;
5. has an owner and a review date.
