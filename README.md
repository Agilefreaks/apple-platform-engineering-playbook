# Apple Platform Engineering Playbook

Internal Agile Freaks standards and starter artifacts for building iOS, iPadOS, and
tvOS products with developers and coding agents.

This repository is the versioned source of truth for:

- how Apple-platform code is structured;
- how requirements and Figma become a verified delivery;
- which artifacts a new project should adopt;
- which checks humans and agents must pass before claiming completion.

It is intentionally a **playbook**, not yet a production Xcode project generator. It
provides the contracts and starter files that a generator or template repository can
consume later.

## Start here

| Need | Human-facing source | Agent-facing standard |
|---|---|---|
| Code architecture | [Architecture Handbook](docs/architecture/AppleTeamHandbook.md) | [Architecture Standard](docs/architecture/AppleTeamArchitectureStandard.md) |
| Requirements-to-delivery loop | [Delivery Loop Handbook](docs/delivery/AppleTeamDeliveryLoopHandbook.md) | [Delivery Loop Standard](docs/delivery/AppleTeamDeliveryLoopStandard.md) |
| Start a new project | [Adoption Guide](docs/AdoptionGuide.md) | [Project starter kit](templates/project/README.md) |
| Run one delivery item | [Delivery templates](templates/delivery/) | [Delivery schema](schemas/delivery.schema.json) |
| Configure Simulator automation | [Tapia MCP Guide](docs/tooling/TapiaMCPGuide.md) | [Tool capability manifest](templates/project/tooling/tools.yml) |
| Configure build automation | [Xcode Automation Guide](docs/tooling/XcodeAutomationGuide.md) | [Tool capability manifest](templates/project/tooling/tools.yml) |

Current document versions:

- Architecture: `2.1`
- Delivery Loop: `0.1 — proposed for pilot`
- Repository package: `0.3.0`

## Validate the playbook

~~~bash
make setup
make validate
~~~

The checks verify:

- paired ARCH and DLV decision IDs;
- the JSON Schemas and sample `delivery.yml`/`tools.yml` manifests;
- local Markdown links and balanced fenced blocks.

GitHub Actions runs the same validation on pull requests and `main`.

## Adopt it in a new project

1. Read [Adoption Guide](docs/AdoptionGuide.md).
2. Run `./scripts/bootstrap_project.sh /path/to/new-app-repository` or copy the starter
   files manually, then replace every project placeholder.
3. Record the adopted playbook version and any deviations in `AGENTS.md` and ADRs.
4. Establish signing, environments, CI, privacy, security, observability, release, and
   ownership before the first production delivery.

Do not copy a random historical branch. Adopt a tagged version or an explicitly
recorded commit so projects can decide when to upgrade.

## Changes and ownership

See [CONTRIBUTING.md](CONTRIBUTING.md). Paired human/agent documents change together,
decision IDs remain stable, and schema/template changes include migration impact.

This repository is public and released under the [MIT License](LICENSE). Client-specific
facts, credentials, and production identifiers belong in the projects that adopt the playbook,
never here.
