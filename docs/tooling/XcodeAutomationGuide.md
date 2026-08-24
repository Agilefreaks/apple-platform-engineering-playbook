# Xcode Automation Guide

The `apple/xcode-automation` capability covers build, test, diagnostics, and Simulator or
device operations driven by an agent. It has more than one legitimate implementation, and
the project chooses one deliberately in `tooling/tools.yml`.

This guide records the choice, the pinning rules, and the limits of the evidence each
implementation produces. It complements the Tapia MCP Guide, which covers semantic UI
interaction rather than build automation.

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
| Xcode MCP (`xcrun mcpbridge`) | The developer works with the project open in Xcode and approves external-agent access | Unusable headless: no open Xcode, no capability |
| XcodeBuildMCP (`xcodebuildmcp`) | Agents build, test, or drive Simulators headless, or parallel workers need scheme/destination discovery and parsed diagnostics | Third-party Node package running with local developer privileges; absent in CI |
| Repository commands only | No MCP is approved, dependency surface must stay minimal, or the run must match CI exactly | Raw `xcodebuild` output is long and easy for an agent to misread |

The default is the Xcode MCP, because it is first-party and versioned with the selected
Xcode. Its limitation is the reason the alternative exists: agent-heavy work in this
playbook is frequently headless and parallel, so a project that fans out work across
workers should expect to select XcodeBuildMCP or to run repository commands with filtered
output.

Declare exactly one selected implementation in `implementation`. Keep the evaluated but
unselected ones in `alternatives`, so the next reader sees the choice instead of guessing
that no alternative existed. Record the selected implementation and its pinned version in
`AGENTS.md` alongside schemes, destination, and Xcode version.

## Install and pin XcodeBuildMCP

The upstream source is the npm package `xcodebuildmcp`, published from
`https://github.com/getsentry/XcodeBuildMCP`. Ownership of that repository has already
moved once, so treat it as a reviewed third-party dependency rather than a stable
first-party interface.

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
    "xcodebuildmcp": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@<EVALUATED_VERSION>", "mcp"],
      "env": {
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,session-management,simulator,simulator-management,ui-automation,coverage,doctor,utilities",
        "XCODEBUILDMCP_SENTRY_DISABLED": "true"
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

One more trap worth knowing before you trust a screenshot: the screenshot and UI-snapshot tools act
on the session's default device and **ignore an explicitly passed simulator id**. Check the id
echoed back in the result, or capture through `xcrun simctl io <udid> screenshot`, before attaching
the output as evidence. Getting this wrong attributes one device's behaviour to another with no
error anywhere.

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
