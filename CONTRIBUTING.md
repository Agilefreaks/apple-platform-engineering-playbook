# Contributing

Changes should make the playbook more executable without turning it into a universal
framework or an unreviewable policy dump.

## Pull request rules

- Keep one coherent policy or artifact change per pull request.
- Explain the problem, affected projects, migration impact, and evidence from a real
  project or pilot.
- Update the human-facing handbook and agent-facing standard together.
- Preserve existing `ARCH-*` and `DLV-*` IDs. Add a new ID for a new decision; never
  reuse a retired ID for a different meaning.
- Update schema, template, checklist, starter kit, and changelog when affected.
- Do not add secrets, production identifiers, personal data, client-confidential
  screenshots, or internal tokens as evidence.
- Run `make validate` before requesting review.

## Decision changes

Every normative change states:

1. current problem and observed evidence;
2. proposed rule and scope;
3. alternatives considered;
4. migration/backward-compatibility impact;
5. owner and review date;
6. affected ARCH/DLV IDs and artifacts.

Project-specific exceptions remain in the project ADR and `AGENTS.md`. They do not
weaken the company standard for every project by accident.

## Reviews

- Architecture changes require an Apple Platform engineering reviewer.
- Delivery lifecycle changes require Product/Delivery and Engineering review.
- Design/Figma changes require Design review.
- Privacy, security, legal, signing, or release-authority changes require the owner of
  that risk.
- An agent may draft a change and evidence, but it cannot fabricate these approvals.

## Versioning

Use repository tags for consumable playbook releases:

- patch: clarification or compatible artifact fix;
- minor: new compatible decision/artifact or optional capability;
- major: breaking policy, schema, lifecycle, or adoption change.

Document versions inside the Markdown files may evolve independently while the
repository package version describes the complete consumable set.
