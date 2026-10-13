# Xcode Automation Guide

The `apple/xcode-automation` capability covers build, test, diagnostics, and Simulator or
device operations driven by an agent. It has more than one legitimate implementation, and
the project chooses one deliberately in `tooling/tools.yml`.

This guide records the choice, the pinning rules, and the limits of the evidence each
implementation produces. It complements the Tapia MCP Guide, which covers semantic UI
interaction rather than build automation.

## Tooling baseline checked 2026-10-02

This is a dated discovery and compatibility snapshot. Refresh it when adopting a
toolchain update; project pins and runtime evidence remain the authority for a run.

| Tool | Current upstream / local verification | Adoption guidance |
|---|---|---|
| Xcode / Swift | Apple lists Xcode 27 as the stable release and 27.2 beta 2 plus 27.1 beta as previews. Local verification used Xcode 27.0 build `27A266a`, Swift compiler 6.4. | Record the Xcode build and Swift language mode separately. A beta listing is not approval to upgrade a project's toolchain. |
| Command Line Tools | Local package 27.0; the previously installed 26.6 package blocked Homebrew's idb upgrade despite full Xcode 27 being selected. | Check the standalone package with `pkgutil`; update it separately through Software Update when required. |
| Simulator / Device Hub | Local available iOS runtimes: 27.0 (`24A434`), 26.5 (`23F77`), and 18.5 (`22F77`). Tapia input verified on iPhone 18 Pro / iOS 27.0. | Discover installed runtime/device pairs and pin the chosen UDID; do not assume a device name or downloaded runtime exists. |
| Native Xcode MCP | Xcode 27 provides `mcpbridge` and `mcp-server`, including opt-in headless mode. Local command help/status verified; no project build through the native MCP is claimed. | Use approved agent/project access; check `xcrun mcp-server status`. |
| MobileBuildMCP | Latest release `2.7.1`, commit `d13ff0c707b0681769cf31da0eb42c4f94ceafff`; startup, 44 exposed tools, and `list_sims` verified locally. | Starter configuration is pinned; each adopter still validates its own build/test flows. |
| Tapia MCP / idb | Tapia `0.2.0` at `74ddfd95710801f7ff33a48e0a42bdfff5c15e02`; matched idb client/companion `1.6.4`. | Install the pinned Tapia checkout; Xcode 27 input needs current DTUHID-capable idb. See [TapiaMCPGuide.md](TapiaMCPGuide.md). |

Sources: [Apple's Xcode compatibility table](https://developer.apple.com/xcode/system-requirements/),
[Command Line Tools updates](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/),
[MobileBuildMCP 2.7.1](https://github.com/getsentry/MobileBuildMCP/releases/tag/v2.7.1),
[Tapia source](https://github.com/Agilefreaks/tapia-mcp/commit/74ddfd95710801f7ff33a48e0a42bdfff5c15e02),
and local CLI/MCP checks. Beta SDKs and the other installed runtimes were inventoried,
not runtime-tested as part of this tooling refresh.

Before a session, capture the actual environment:

~~~bash
xcode-select -p
xcodebuild -version
xcrun swift --version
pkgutil --pkg-info com.apple.pkg.CLTools_Executables
xcrun simctl list runtimes --json
xcrun simctl list devices available --json
xcrun mcp-server status
command -v idb
brew list --versions facebook/fb/idb-cli facebook/fb/idb-companion
~~~

Use `DEVELOPER_DIR` per session when selecting another installed Xcode, and pass it
to the MCP process as well. Resolve the project's newest-runtime and minimum-OS
lanes against the inventory, preserving its declared support policy. A missing
required runtime is a validation gap; another version is not an equivalent pass.
New device models and runtimes should be discovered rather than added to an
allowlist. Keep each worker's UDID explicit even when only one device is booted.

## The command interface stays the contract

`make bootstrap | build | test | test-ui | format | lint` is the interface for humans,
agents, and CI. An automation server is an accelerator on top of those commands, never a
second definition of how the project builds.

If a build succeeds only through an MCP path and nobody can reproduce it with `make`, the
project has two build definitions and CI is the one that decides. Keep the make targets
authoritative and let the server call them or the same underlying `xcodebuild`
invocation.

## Choosing an implementation

| Implementation | Select when | Main limitation |
|---|---|---|
| Xcode MCP (`xcrun mcpbridge`) | An approved open-project session, or an explicitly enabled Xcode 27 headless session with agent/project access | Requires a configured native session and project access; check the selected Xcode's command help |
| MobileBuildMCP (`mobilebuildmcp`) | Agents build, test, or drive Simulators headless, or parallel workers need scheme/destination discovery and parsed diagnostics | Third-party Node package running with local developer privileges; absent in CI |
| Repository commands only | No MCP is approved, dependency surface must stay minimal, or the run must match CI exactly | Raw `xcodebuild` output is long and easy for an agent to misread |

The native bridge is first-party and versioned with the selected Xcode. Xcode 27's
`mcp-server` can manage approved headless sessions, so absence of the Xcode UI alone
does not make it unavailable. Use `xcrun mcp-server --help` and `status` to inspect
setup; `open <PROJECT_OR_WORKSPACE>` opens a project in that session. Headless
enablement and permission changes require the operator's authority and are not
automatic consequences of installing the playbook.

The starter selects MobileBuildMCP and records the native bridge as an alternative.
A project may choose either or repository commands with filtered output; keep its
manifest, `.mcp.json`, and server approval settings consistent.

Declare exactly one selected implementation in `implementation`. Keep the evaluated but
unselected ones in `alternatives`, so the next reader sees the choice instead of guessing
that no alternative existed. Record the selected implementation and its pinned version in
`AGENTS.md` alongside schemes, destination, and Xcode version.

## Install and pin MobileBuildMCP

The upstream source is the npm package `mobilebuildmcp`, published from
`https://github.com/getsentry/MobileBuildMCP`. Ownership of that repository has already
moved once, so treat it as a reviewed third-party dependency rather than a stable
first-party interface.

Release 2.7.1 renamed XcodeBuildMCP to MobileBuildMCP. The old npm package remains
at `2.7.0`; querying only that name misses the current release. Migrate the package
and command to `mobilebuildmcp`, environment variables to `MOBILEBUILDMCP_*`, the
project configuration directory to `.mobilebuildmcp/`, and resource URIs to
`mobilebuildmcp://`. Update the MCP server approval name too. Inputs such as `env`
and `testRunnerEnv` now use arrays of `{ "key": "...", "value": "..." }`, and
`xcode_ide_call_tool.arguments` is a JSON object string. Inspect current tool schemas
before carrying forward old client calls. Existing project pins migrate explicitly.

Before adoption:

- evaluate one specific version, run the project's build and test flows through it, and
  record that version — and the commit, when the release is not tagged — in
  `tooling/tools.yml`;
- never resolve the server from a floating tag such as `@latest`; an unpinned server
  changes the agent's build behavior without a pull request;
- enable only the tool groups the project needs, following the upstream configuration
  documentation. A server exposing dozens of unused tools costs context in every session;
- do not run it alongside another Simulator driver in the same session. Tapia owns
  semantic UI interaction; if both are active, state in `AGENTS.md` which one drives the
  Simulator.

Project configuration. The starter kit installs this as `.mcp.json`; merge into an existing file
rather than overwriting it:

~~~json
{
  "mcpServers": {
    "mobilebuildmcp": {
      "command": "npx",
      "args": ["-y", "mobilebuildmcp@2.7.1", "mcp"],
      "env": {
        "MOBILEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,session-management,simulator,simulator-management,ui-automation,coverage,utilities",
        "MOBILEBUILDMCP_SENTRY_DISABLED": "true"
      }
    }
  }
}
~~~

Four details in that snippet each cost a debugging session when they are missing:

- **The `mcp` subcommand.** From 2.x the package needs it. Without it the process prints CLI help
  and exits, which looks like a server that never starts rather than a wrong argument.
- **The enabled-workflow list replaces the server's defaults, it does not extend them.** Only the
  simulator workflows load by default, so anything else — UI automation in particular — must be
  named. Naming one workflow silently removes the rest.
- **Telemetry off.** The server reports its own internal runtime faults to a third-party service by
  default. It does not send source, build output, or tool inputs, but a client project should emit
  nothing outward that the project has not agreed to. Set the opt-out explicitly rather than
  relying on the default staying as it is.
- **Commit both files.** `.mcp.json` plus the settings file that approves the server. A capability
  configured only in one developer's local settings is invisible to everyone else, and the project
  then behaves differently depending on who is running it.

The 2.7.1 `screenshot` and `snapshot_ui` schemas have no Simulator-ID argument;
they use the session default. Set `simulatorId` through `session_set_defaults`,
check the device in the returned evidence, or capture through
`xcrun simctl io <udid> screenshot`. An extra ID passed to the screenshot call is
not a targeting contract.

Signing, entitlement, certificate, distribution, and release actions stay protected. A
build server never receives unattended approval for them, regardless of which tools it
exposes.

## Reduce log noise before adding a server

The usual reason to reach for a build MCP is that `xcodebuild` output is unreadable, not
that the CLI cannot do the work. Fix the output first — it is cheaper, it needs no new
dependency, and it is the only option that also works in CI:

~~~bash
set -o pipefail
xcodebuild -scheme "<SCHEME>" -destination "<DESTINATION>" \
  -resultBundlePath build/last.xcresult test 2>&1 \
  | tee build/last.log \
  | xcbeautify
~~~

- the filtered stream is what a human or an agent reads;
- the raw log stays on disk for the rare case that needs it;
- failures are read from the result bundle rather than from scrollback;
- `pipefail` keeps the real exit status, so filtering never turns a failure into a pass.

A project that does this well gets most of the practical benefit an automation server
offers, and keeps it in CI. Treat it as the baseline, then add a server for what remains:
discovery, Simulator lifecycle, and structured tool calls.

## Parallel execution

`DLV-017` in the Delivery Loop Standard requires each concurrent worker to own a
dedicated Simulator UDID and to pin every operation to it. That applies to build
automation as well:

- pass `-destination 'id=<UDID>'`, never "the booted Simulator";
- when a server selects the destination, select the worker's own device explicitly;
- never restart, shut down, erase, or re-boot a device the worker does not own.

The provisioning mechanics live in [TapiaMCPGuide.md](TapiaMCPGuide.md).

## Evidence semantics

A successful MCP build or test run proves the declared local build on the declared
destination. It proves nothing about signing, the Release configuration, a real device, a
distributed build, or production.

For any gate result:

- reproduce it through the repository commands before reporting it, so a reviewer can
  rerun it from a clean checkout;
- record the implementation and pinned version, Xcode version, scheme, configuration,
  destination or UDID, and commit;
- keep `PRODUCTION_VERIFIED` and `DELIVERED` tied to CI and distributed-build
  verification, never to a local tool call.

## When the capability is unavailable

A missing automation capability is a tooling gap, not permission to skip verification.
Run the repository commands, report the reduced convenience rather than a reduced
standard, and fix the tooling separately from the feature.

Related: [AppleTeamHandbook.md](../architecture/AppleTeamHandbook.md) sections 12.5 and
14.4, [AppleTeamArchitectureStandard.md](../architecture/AppleTeamArchitectureStandard.md)
(`ARCH-015`), and [TapiaMCPGuide.md](TapiaMCPGuide.md).
