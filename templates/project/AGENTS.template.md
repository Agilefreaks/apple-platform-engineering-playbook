# AGENTS.md — <PROJECT_NAME>

Short operational contract for developers and coding agents. Project-specific facts
belong here; durable rationale belongs in `docs/adr/`.

## Authority

1. Current approved requirements and task constraints.
2. Project ADRs.
3. This file.
4. Apple Platform Engineering Playbook `<TAG_OR_COMMIT>`.
5. Nearby legacy conventions.

The playbook repository is public, but a browser `blob/` URL is still not a readable reference —
it returns an HTML page rather than the document, which leaves an agent with this file's summary
and nothing else. Read a playbook document at the pinned commit in `.apple-playbook-version`,
with the GitHub CLI when one is installed and authenticated, and over plain HTTPS when it is not:

~~~bash
scripts/check_playbook_access.sh   # confirms the standard is readable, and prints which command to use

gh api 'repos/<PLAYBOOK_SLUG>/contents/<path>?ref=<PLAYBOOK_COMMIT>' --jq .content | base64 -d

curl -fsSL 'https://raw.githubusercontent.com/<PLAYBOOK_SLUG>/<PLAYBOOK_COMMIT>/<path>'
~~~

Architecture standard: `docs/architecture/AppleTeamArchitectureStandard.md`

Delivery standard: `docs/delivery/AppleTeamDeliveryLoopStandard.md`

Handbook (rationale): `docs/architecture/AppleTeamHandbook.md`

If the access check fails, say so in the handoff and fall back to this file plus current primary
Apple documentation. Do not proceed as though the standard had been read.

## Project facts

| Fact | Value |
|---|---|
| Platforms | `<iOS / iPadOS / tvOS>` |
| Minimum OS | `<VERSION>` |
| Xcode / Swift | `<VERSIONS>` |
| Bundle IDs | `<IDS>` |
| Default scheme/configuration | `<SCHEME> / <CONFIG>` |
| Simulator destination | `<DESTINATION>` |
| Signing owner | `<ROLE_OR_TEAM>` |
| Release owner | `<ROLE_OR_TEAM>` |
| Privacy/security owner | `<ROLE_OR_TEAM>` |
| Telemetry owner | `<ROLE_OR_TEAM>` |

## Deterministic commands

| Intent | Command | Expected result |
|---|---|---|
| Setup | `<COMMAND>` | Clean checkout becomes buildable |
| Format | `<COMMAND>` | No diff after formatting |
| Lint | `<COMMAND>` | Zero blocking findings |
| Build | `<COMMAND>` | Supported scheme/destination builds |
| Unit/integration tests | `<COMMAND>` | Test suite passes |
| Critical UI tests | `<COMMAND>` | Declared critical flows pass |
| Runtime launch | `<COMMAND>` | App launches on declared destination |
| Delivery validation | `<COMMAND>` | Delivery Packet validates |
| Playbook access | `scripts/check_playbook_access.sh` | the architecture standard is readable at the pinned commit, through `gh` when it is installed and authenticated and over plain HTTPS otherwise |

## Architecture and folders

- Default: feature-first modular MVVM/R under ARCH v2.1.
- TCA status: `<NOT_ADOPTED / ADOPTED_BY_ADR>`.
- Composition root: `<PATH>`.
- Feature root: `<PATH>`.
- Core root: `<PATH>`.
- DesignSystem root: `<PATH>`.
- Tests and fixtures: `<PATHS>`.
- Delivery items: `delivery/items/`.

## Environments and configuration

- Environments: `<LIST>`.
- Configuration sources: `<XCCONFIG_PATHS>`.
- Feature flags and owner: `<SYSTEM_AND_OWNER>`.
- Test accounts/data: `<SAFE_ACCESS_INSTRUCTIONS>`.
- Never place secrets, tokens, or production credentials in this file or the repo.

## Skills

Canonical requirements are in `tooling/skills.yml`. Map them to the installed runtime:

| Canonical skill | Runtime skill/tool | Version |
|---|---|---|
| `apple/swift-concurrency` | `.agents/skills/swift-concurrency-pro` | `1.0` |
| `apple/swift-testing` | `.agents/skills/swift-testing-pro` | `1.0` |
| `apple/ios-runtime-debugging` | none installed — tooling gap | — |
| `apple/swiftui-patterns` (conditional) | `.agents/skills/swiftui-pro` | `1.1` |

Those runtimes are checked into this repository, not installed. The files live in
`.agents/skills/<name>/`, and `.claude/skills/<name>` symlinks into that tree, which is what makes
each one a project-scope skill in Claude Code; an agent that reads this file rather than
`CLAUDE.md` finds the same content at the same paths. So the skills are present the moment the
repository is cloned — no marketplace, no trust prompt, no network — and identical for every
contributor and every headless run. `.agents/skills/VENDORED.md` records each upstream repository,
its pinned commit and its licence. Do not edit the vendored files: a local edit is
indistinguishable from upstream content and is lost on the next re-vendor, so project-specific
rules belong in this file.

Add conditional mappings only when that work is in scope. A missing skill uses the
standard/checklist as manual fallback and is reported as a tooling gap.

## Tool capabilities

Canonical declarations are in `tooling/tools.yml`. Record the runtime mapping and
enable only capabilities whose adoption conditions apply:

| Capability | Runtime implementation | Adoption | Health/setup command |
|---|---|---|---|
| `apple/xcode-automation` | `xcodebuildmcp@2.7.0` (see `.mcp.json`) | Recommended | `npx -y -p xcodebuildmcp@2.7.0 xcodebuildmcp-doctor` |
| `apple/ios-simulator-automation` | Tapia MCP | Recommended/conditional | `<TAPIA_SOURCE_CLONE>/scripts/tapia-doctor` |

Name the selected Xcode-automation implementation and its pinned version, not just
"an MCP" — the shipped row does, and stays true only if it is updated with `.mcp.json`. The make targets stay authoritative: reproduce any gate result through them
before reporting it, because no MCP implementation runs in CI.

`.mcp.json` carries the server configuration and `.claude/settings.json` approves it, both
committed. The server version is pinned exactly (`xcodebuildmcp@2.7.0`); bump it deliberately and
never to `latest` or a range. The shipped configuration disables the server's own telemetry and names
every enabled workflow explicitly, because that variable replaces the server's defaults rather
than extending them. A project that keeps Xcode open and prefers the first-party bridge should
swap the file's contents and say so here.

When Tapia is enabled, pin the reviewed revision, use stable
`accessibilityIdentifier` values, isolate the Simulator from production accounts/data,
and keep command approval narrow. A Tapia flow is local Simulator evidence only; it
does not replace XCUITest, CI, real-device/distributed-build checks, or human approval.
If unavailable, use a declared fallback and report the reduced evidence level.

## Protected actions

Agents require explicit human authority before:

- signing/certificate/entitlement changes;
- App Store/TestFlight submission or production release;
- production feature-flag/cohort changes;
- privacy/security/legal waiver;
- external communication or destructive production operations;
- declaring final Product/Design/Release approval.

## Local deviations

| Area | Summary | ADR | Owner | Review date |
|---|---|---|---|---|
| None | | | | |
