# Apple Team Architecture Standard v2

Agent-facing reference for iOS, iPadOS, and tvOS repositories.

| Metadata | Value |
|---|---|
| Status | Proposed v2.1 — ready for team review |
| Version | 2.1 |
| Canonical source | AppleTeamHandbook.md |
| Audience | Coding agents and reviewers |
| Review cadence | At least twice per year and after a major Swift/Xcode change |
| Local deviations | Short summary in AGENTS.md, rationale in docs/adr/ |

This file is the compact operational form of the handbook. The decision IDs below
must exist in both documents. Until generation is automated, any decision change
updates both files in the same pull request and CI verifies the ID sets.

## Precedence and applicability [ARCH-001]

Order of authority:

1. The current task and product requirements.
2. A repository ADR explicitly approved by the team.
3. The repository AGENTS.md summary.
4. This company standard.
5. Nearby legacy conventions.

Do not create a half-migrated screen merely to satisfy this standard. New work uses
the standard at a clean feature or service seam. If no clean seam exists, preserve
local correctness, document the temporary deviation, and propose a migration slice.

Platform baseline:

- Greenfield projects: Swift 6, SwiftUI, and a deployment target that supports
  Observation (iOS/iPadOS/tvOS 17 or newer). Product needs may choose a higher target.
- Legacy projects below OS 17 may keep ObservableObject/Published/StateObject inside
  complete legacy flows until the deployment target is raised.
- Swift 6 and complete concurrency checking are goals for legacy projects, adopted
  incrementally as described in the legacy section.

## Decisions

| ID | Area | Rule |
|---|---|---|
| ARCH-001 | Applicability | Greenfield follows v2. Legacy adopts it at explicit seams; deviations have ADRs. |
| ARCH-002 | Language and UI | Swift 6 and SwiftUI for new work. UIKit remains at integration and legacy boundaries. |
| ARCH-003 | Architecture | Feature-first modular MVVM/R by default. TCA is an approved project-level alternative. |
| ARCH-004 | State | State ownership is local-first. Observation on OS 17+. ViewModels are optional. LoadState is for simple loads, not every workflow. |
| ARCH-005 | Navigation | Typed routes and semantic Router methods. Typed arrays for homogeneous paths; NavigationPath only for heterogeneous paths. |
| ARCH-006 | Dependency injection | Explicit init injection. AppContainer is the composition root. No hidden live defaults, service locators, or new mutable singletons. |
| ARCH-007 | Data | Core supplies transport primitives. Each feature owns small capability clients and mapping. Transport types never reach UI. |
| ARCH-008 | Persistence | UserDefaults for trivial preferences, Keychain for credentials, SwiftData as the Apple-first queryable store. Repository is policy-driven, not mandatory. |
| ARCH-009 | Configuration | Environment differences are values from xcconfig, not code branches. AppEnvironment is created at the root and injected. Client configuration is public, never secret. |
| ARCH-010 | Structure and modules | Modular monolith first. Buildable folders and clear extraction boundaries. SPM extraction requires a measured reason. |
| ARCH-011 | Localization | String Catalogs. English source literals in views; LocalizedStringResource outside views. Add translator context where ambiguous. |
| ARCH-012 | Analytics and logging | Typed analytics behind a facade. os.Logger for operational logs. Networking never owns product analytics. |
| ARCH-013 | Testing and CI | Test pyramid: unit, integration, critical UI. Swift Testing for code tests, XCTest for UI. Snapshots are selective. |
| ARCH-014 | Design and accessibility | Asset-backed tokens, reusable DesignSystem, native adaptive layout instead of canvas-derived geometry, Dynamic Type, VoiceOver, contrast, focus, Reduce Motion, and platform input support. |
| ARCH-015 | Agent tooling | Every repo exposes deterministic build/test/format/lint commands. Agents do not hand-edit project.pbxproj. |
| ARCH-016 | Third-party dependencies | Apple-native first. New packages require an owner, license/security review, version policy, and ADR when architecture-affecting. |
| ARCH-017 | Legacy | Migrate complete vertical slices in dependency order; never rewrite working legacy code without an approved outcome. |

## Dependency graph [ARCH-007] [ARCH-010]

Allowed app-internal dependencies:

~~~text
App                  -> Features, Core, DesignSystem
Features             -> Core, DesignSystem
DesignSystem         -> no app-internal module
Core                 -> no App, Features, or DesignSystem
AppExtensions        -> Core and optionally DesignSystem; never Features
~~~

Core never imports App or Features. Therefore:

- Core networking never reads AppEnvironment.
- Core notification services never call AppRouter.
- Core clients never return feature-owned types.
- Networking never mutates a SessionStore directly.

Composition is inverted at App:

~~~text
AppEnvironment -> AppContainer -> feature clients / stores / routers
system payload  -> Core parser -> typed intent -> AppRouter
HTTP 401        -> typed auth failure -> app/session orchestration
~~~

## Folder structure [ARCH-010]

Single-platform default:

~~~text
App/
  MyAppApp.swift
  AppContainer.swift
  AppEnvironment.swift
  AppRouter.swift
Features/
  Home/
    HomeView.swift
    HomeViewModel.swift?       # only when logic exists
    HomeRoute.swift?
    HomeClient.swift?          # feature capability and live adapter
    HomeItem.swift
    Data/                      # DTOs/mappers only when needed
    Components/
Core/
  Networking/                 # HTTPClient, request/response primitives
  Persistence/
  Stores/
  Services/
  Analytics/
  Logging/
  Utils/                      # small; never a dumping ground
DesignSystem/
Resources/
Config/
PreviewSupport/               # debug/development-only preview fixtures
Tests/
  Support/
UITests/
docs/
  architecture.md
  adr/
scripts/
tooling/
  skills.yml
  tools.yml
skills.lock                   # when supported by the skill distribution system
AGENTS.md
Makefile
~~~

Promotion rule: start inside the owning feature. Move code to Core or DesignSystem
only after a second real consumer or a platform/extension boundary appears.

Use semantic folders and type names. Avoid generic HomeModel.swift, Managers/, or
Utils/ when a more precise concept exists.

Multi-platform projects use Shared/ as the headless cross-platform layer and keep
platform-specific UI under iOS/Features and tvOS/Features. Shared ViewModels may use
Observation but do not import platform UI. tvOS-only UI types use the TV prefix.

## Feature shape and MVVM/R [ARCH-003] [ARCH-004]

Roles:

- Model: small value types named after the business/UI concept.
- View: renders state and forwards intent.
- ViewModel: optional MainActor observable reference that owns presentation logic.
- Router: navigation state and transitions only, never business logic.
- Client: narrow feature capability for external work.

Create a ViewModel when a screen coordinates async work, transformations, retries,
timers, non-trivial forms, multiple UI states, or state that must survive view
identity changes. Do not create forwarding-only ViewModels for leaf components.

Use the narrowest state mechanism:

| Ownership | Mechanism |
|---|---|
| Local transient UI | State |
| Child writes parent value | Binding |
| Screen reference state on OS 17+ | State holding an Observable type |
| Shared application state | Observable store injected through Environment |
| Feature-local dependency | Explicit initializer parameter |

LoadState is the default only for one simple resource:

~~~swift
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(AppError)
}
~~~

For refresh-with-content, pagination, partial failure, offline/stale content, or
multiple resources, define a feature-specific State value. Prefer one explicit state
machine per independent resource; do not force valid concurrent conditions into one
enum or recreate impossible combinations with unrelated booleans.

Cancellation is normal. A cancelled view task does not become a user-facing error.

## Dependency injection and composition [ARCH-006]

Production dependencies are explicit:

~~~swift
@MainActor
@Observable
final class HomeViewModel {
    private let client: any HomeClient

    init(client: any HomeClient) {
        self.client = client
    }
}
~~~

Do not use a default live dependency in a feature initializer. AppContainer constructs
live implementations from an injected AppEnvironment. Tests and previews construct
their own systems with fakes.

Environment is for broadly shared app state or services, not a shortcut around one or
two initializer parameters. A feature receives only the narrow capability it needs,
never the entire AppContainer.

Immutable process-wide constants are allowed only when they contain no environment,
user, or mutable state. AppEnvironment.current and mutable Xxx.shared instances are
not allowed.

## Data and persistence [ARCH-007] [ARCH-008]

Core networking owns HTTP mechanics:

- URLSession transport
- request construction and response validation
- authentication headers through injected credential providers
- typed transport errors
- retry/cancellation policy
- observability hooks

A feature client owns the endpoint contract and maps DTOs to feature/domain values:

~~~swift
protocol HomeClient: Sendable {
    func loadHome() async throws -> [HomeItem]
}
~~~

The live adapter may depend on Core.HTTPClient. The feature protocol does not expose
Apollo, Alamofire, generated GraphQL, raw JSON, or persistence models.

Do not create one application-wide ApiServiceProtocol. Split by capability or feature
so tests do not implement unrelated endpoints.

A Domain layer is not a default folder. Add one with an ADR when business invariants,
cross-feature rules, critical calculations, offline workflows, or platform-independent
use cases need a stable home.

A Repository is justified when it owns retrieval policy: multiple sources, caching,
offline behavior, synchronization, merge/conflict rules, or a stable business-facing
query contract. The number of sources is a trigger, not the only criterion.

Storage:

- Small preferences and flags: a typed owning store over UserDefaults/AppStorage.
- Credentials and tokens: Keychain behind a narrow protocol.
- Queryable local model data: SwiftData by default, with the container created at App.
- Sensitive server secrets: never shipped in the app, xcconfig, plist, or source.

Simple SwiftData screens may use Query directly. Complex persistence flows use a
feature store/client so tests can exercise policy without a live database.

## Swift concurrency [ARCH-002] [ARCH-004]

- Use Swift 6 complete concurrency checking in greenfield targets.
- App/UI modules use MainActor default isolation when supported by the toolchain.
- ViewModels, routers, and UI-facing stores are MainActor-isolated.
- Boundary values are Sendable value types.
- Stateful services with shared mutable state use actors or another explicit isolation.
- Async means suspendable, not automatically background.
- Do not blanket-mark all services nonisolated.
- Use nonisolated for stateless/pure APIs that truly cross isolation domains.
- Use concurrent execution only for deliberate CPU-heavy work; profile before adding it.
- Prefer structured tasks tied to lifecycle. Task.detached requires a documented reason.
- Propagate cancellation and never convert CancellationError into a product failure.

Repository packages must mirror the Xcode target concurrency settings explicitly.

## Navigation and communication [ARCH-005]

Use one NavigationStack per tab when independent history is expected.

For a homogeneous route enum:

~~~swift
enum HomeRoute: Hashable {
    case details(id: String)
    case player(id: String)
}

@MainActor
@Observable
final class HomeRouter {
    var path: [HomeRoute] = []
    var sheet: HomeSheet?

    func showDetails(id: String) {
        path.append(.details(id: id))
    }
}
~~~

Use NavigationPath only when one stack intentionally stores heterogeneous route types.
Routes carry lightweight stable identifiers, not view instances or large models.

Sheets use item/enum state when mutually exclusive. Keep a purely local sheet in its
view; move it to the Router only when the wider flow, deep links, or restoration needs
to control it.

DeepLinkParser and push parsers return typed navigation intents. AppRouter consumes
them. Unknown or malformed inputs are logged and safely ignored or shown as an
explicit unsupported-link state; do not silently route to an unrelated default.

Communication:

- parent to child: value; Binding only for write-back
- child to parent: closure or Binding
- siblings: lift state to their common owner
- cross-feature current value: shared Observable store
- one-shot external event: typed AsyncSequence or typed intent at the boundary

Custom NotificationCenter notifications are not application architecture. System
notifications may be consumed at Core adapters and converted to typed state/events.

## Configuration and secrets [ARCH-009]

Prod, QA, and Staging are configuration values, not source-code variants:

~~~text
xcconfig -> Info.plist substitution -> AppEnvironment.fromBundle()
         -> AppContainer(environment:) -> live dependencies
~~~

Only App reads the bundle into AppEnvironment. Core receives concrete values such as
baseURL through initializers.

Conditional compilation:

- environment branches such as #if QA are forbidden
- #if os(...) is allowed for actual platform API differences
- #if DEBUG is allowed only for local developer and preview tooling

xcconfig and Info.plist are visible in the application bundle. They may contain public
configuration such as bundle identifiers and base URLs, never secrets.

`Info.plist` and `*.entitlements` live in `Config/` beside the xcconfig files they draw
their values from, not in the application source folder. They are configuration inputs,
not source, and keeping them next to the xcconfig makes the substitution chain visible in
one directory. When a generator produces `Info.plist` from a manifest, it writes it to
`Config/` and the file is gitignored like any other generated output.

## Localization, analytics, and logging [ARCH-011] [ARCH-012]

Localization:

- Use String Catalogs.
- In SwiftUI views, the English source literal is the localization key.
- Outside views, use LocalizedStringResource for user-facing copy.
- Add translator comments for ambiguous text, interpolation, plurals, and context.
- Product copy changes require checking translation impact.

Analytics:

- One typed facade; provider SDKs remain behind adapters.
- Feature events are typed and owned near the feature.
- Business events are emitted where the business result is known.
- Screen events use a shared tracking modifier/policy that defines deduplication.
- Networking reports operational telemetry, never product analytics.

Logging:

- Use os.Logger with subsystem and semantic categories.
- No print statements in production paths.
- Do not log tokens, credentials, personal data, or full payloads.
- Mark privacy-sensitive interpolations appropriately.
- User-facing errors, diagnostics, and analytics are separate concerns.

## Design system and accessibility [ARCH-014]

- Colors, fonts, spacing tokens, and images come from assets/tokens, not feature literals.
- Reference asset catalog colors and images through the compiler-generated asset
  symbols (`Color(.brandPurple)`, `Image(.logo)`), never the stringly-typed
  initializers (`Color("BrandPurple")`, `Image("Logo")`). Keep the `Generate Swift
  Asset Symbol Extensions` build setting enabled so a renamed or deleted asset fails
  the build instead of falling back at runtime. String-based lookups are a
  review-blocking violation.
- Image assets export from design as SVG when the artwork is faithfully vector,
  otherwise as PNG at 3x; each image set is one universal Single Scale variant
  (no 1x/2x/3x triplets) and views size images explicitly.
- Promote UI to DesignSystem after a second consumer or a product-wide token decision.
- Reproduce a design with native SwiftUI layout — stacks, `Grid`, `ViewThatFits`,
  `Spacer`, spacing tokens, layout priority, size classes, safe-area insets,
  `List`/`Form`, text styles, and `.containerRelativeFrame` where a proportion is the
  actual rule. A design frame states visual intent; it does not state geometry.
- Do not derive layout from the design canvas: no scale factors computed from a
  reference width or height, no `.frame(width:height:)` around text or containers to
  match a mockup, no absolute offsets or manual `GeometryReader` positioning where a
  stack expresses the same intent, no hardcoded font point sizes instead of text
  styles, and no layout math on screen bounds.
- Use fixed dimensions only where the size is genuinely context independent — icon
  and glyph frames, hairlines, minimum touch targets, fixed imagery — and source them
  from DesignSystem tokens rather than feature literals.
- Treat a designed height as a minimum height, define wrapping/truncation explicitly,
  and prefer system components over redrawn look-alikes.
- Support Dynamic Type without truncating critical content.
- Provide VoiceOver labels, values, hints, and logical focus order.
- Respect contrast, Reduce Motion, Reduce Transparency, and platform input methods.
- tvOS supports focus and remote interaction; iPadOS supports adaptable layouts and
  keyboard/pointer behavior where relevant.
- Add accessibility identifiers for stable critical UI tests, not as a substitute for
  accessibility semantics.

## Tests, previews, and CI [ARCH-013]

Use a pyramid:

1. Many fast unit tests for feature state, mapping, and business rules.
2. Fewer integration tests for HTTP adapters, persistence, and composed features.
3. A small set of XCTest UI tests for critical user journeys and regressions.
4. Performance tests for measured hot paths.

Use Swift Testing for new unit/integration tests and XCTest for UI tests.

Previews are required for:

- every screen
- every reusable DesignSystem component
- important loading, loaded, empty, error, and accessibility states

Tiny private leaf views do not require standalone previews.

Snapshots are selective: stable DesignSystem components and visually risky screens.
Do not snapshot every SwiftUI view. Use the repository-approved harness and fixed
device/locale/content-size settings.

Preview fixtures contain synthetic data only. Keep preview-only code out of Release
with a development-only support target/module or a reviewed DEBUG boundary. Test
doubles that are not needed by previews remain in Tests/Support.

Every new repository exposes these stable commands, backed by Makefile or scripts:

~~~text
make bootstrap   # when setup is needed
make build
make test
make test-ui
make format
make lint
~~~

`build` and `test` filter output through `xcbeautify` or an equivalent, keep the raw log,
write a result bundle, and set `pipefail` so filtering cannot mask a failure.

Required pull-request CI:

- clean dependency resolution
- build all shipping app/extension targets
- unit and integration tests
- formatting/lint verification
- no compiler warnings introduced
- selected critical UI tests according to repository policy

AGENTS.md records exact schemes, destinations, commands, and expected runtime.

## Modules, Xcode, and dependencies [ARCH-010] [ARCH-015] [ARCH-016]

Default to a modular monolith with buildable folder references. Extract a local SPM
module when at least one measurable reason exists:

- build-time or test-isolation improvement
- independent ownership/release boundary
- reuse across app and extension
- reuse across products
- enforced dependency direction that review cannot maintain reliably

Agents do not manually edit project.pbxproj. Add files through buildable folders or
the repository's project-generation/Xcode tooling. Generated project files must be
deterministic and reviewed.

Third-party package checklist:

- Apple-native API cannot reasonably satisfy the requirement
- named internal owner
- active maintenance and compatible license
- security/privacy review proportional to access
- version/update policy and Package.resolved committed for apps
- architecture-affecting packages have an ADR and exit/migration note

Do not add a DI, navigation, networking, or state framework for convenience alone.

## Required skill map [ARCH-015]

Skills describe how to execute specialized work correctly. ARCH decisions define the
architecture and boundaries. A skill cannot silently override this standard.

| Task | Canonical skill | Requirement |
|---|---|---|
| SwiftUI screen, state, or navigation | apple/swiftui-patterns | Required for that task |
| Restructure a SwiftUI view | apple/swiftui-refactoring | Required for that task |
| Diagnose SwiftUI rendering/performance | apple/swiftui-performance | Required for that task |
| Swift 6 isolation, actors, Sendable | apple/swift-concurrency | Required for concurrency work |
| Unit/integration test creation or migration | apple/swift-testing | Required for test work |
| Build, Simulator, logs, runtime debugging | apple/ios-runtime-debugging | Required for runtime work |
| SwiftData schema, query, or migration | apple/swiftdata | Required for persistence work |
| User-interface implementation or review | apple/apple-accessibility | Required accessibility pass |
| UIKit modernization | apple/uikit-modernization | Required for legacy UI migration |
| TCA feature | apple/tca | Required only in TCA projects |
| App Intents, Shortcuts, Siri, Spotlight | apple/app-intents | Required for system-intent work |

Use the smallest applicable skill set. The canonical IDs are tool-independent; Codex,
Claude, Kiro, or other tool-specific names are mapped in AGENTS.md without absolute
local paths.

Each repository declares skills in tooling/skills.yml and pins resolved versions in
skills.lock when the distribution system supports locking:

~~~yaml
schema: 1
source: company://apple-skills
required:
  apple/swift-concurrency: "1.x"
  apple/swift-testing: "1.x"
  apple/ios-runtime-debugging: "1.x"
conditional:
  apple/swiftui-patterns: "2.x"
  apple/swiftui-refactoring: "1.x"
  apple/swiftui-performance: "1.x"
  apple/swiftdata: "1.x"
  apple/apple-accessibility: "1.x"
  apple/uikit-modernization: "1.x"
  apple/tca: "1.x"
  apple/app-intents: "1.x"
~~~

CI verifies that the manifest is valid, baseline skills are present, resolved versions
match policy, and the lock is not stale. Do not copy an unknown skill version from
another repository.

When an applicable required skill is unavailable:

1. report the tooling gap;
2. follow this standard and current primary Apple/Swift documentation;
3. do not invent a conflicting local convention;
4. record the gap in the handoff and fix the skill installation separately.

### Tool capability map [ARCH-015]

Skills encode reusable working guidance. Tools expose executable capabilities. Keep
them separate: repositories declare tools in `tooling/tools.yml`, while `AGENTS.md`
maps the declared capabilities to commands and runtime configuration.

Baseline adoption:

| Capability | Implementation | Adoption | Scope |
|---|---|---|---|
| `apple/xcode-automation` | Xcode MCP or the supported Xcode automation interface | Recommended | Build, tests, diagnostics, previews, Simulator/device operations supported by Xcode |
| `apple/ios-simulator-automation` | Tapia MCP | Recommended/conditional | Agent-heavy semantic UI interaction, accessibility-tree inspection, screenshots, and repeatable local Simulator flows |

Declare one selected implementation per capability and keep evaluated but unselected ones
in `alternatives`. The Xcode MCP requires the project open in Xcode; headless or parallel
agent work therefore selects a pinned headless build server, such as XcodeBuildMCP, or
runs the repository commands with filtered output. Pin a third-party server to an
evaluated version, never a floating tag, and record the selected implementation and its
version in `AGENTS.md`. No MCP implementation runs in CI: `make` targets remain the
gate-facing interface, and a gate result must be reproducible through them before it is
reported as evidence. See `docs/tooling/XcodeAutomationGuide.md`.

Adopt Tapia when agents must repeatedly exercise runtime flows or capture evidence in
iOS Simulator. Pin the reviewed commit in `tooling/tools.yml`, run its health check,
prefer stable accessibility identifiers, and limit automation to an isolated Simulator
session with non-production accounts and data. Do not grant broad unattended command
approval.

Tapia complements rather than replaces XCUITest, `xcodebuild`, Xcode MCP, real-device
testing, CI, signing/distribution checks, or production verification. Its flow result
proves only the declared local Simulator build, configuration, device, and interaction.
If Tapia is unavailable or unsuitable, use XCUITest, `simctl`/`idb`, or documented
manual verification and report the reduced evidence level.

## TCA alternative [ARCH-003]

Choose TCA at project start or through an approved ADR/migration plan when the app has
meaningful state-machine complexity, effect cancellation, offline/realtime workflows,
deep composition, shared state, or a strong need for exhaustive deterministic tests.

TCA projects follow current Point-Free practices for reducers, dependencies,
navigation, Observation, and TestStore. MVVM ViewModel/Router/DI recipes above do not
apply to TCA presentation features; the data, configuration, security, accessibility,
tooling, and CI rules still apply.

Do not mix MVVM/R and TCA inside one feature. A temporary architecture boundary is
allowed only during a documented migration with an owner and removal condition.

## Legacy migration [ARCH-017]

Preferred order:

1. Mechanical hygiene: naming, file size, resources, deterministic project structure.
2. Define seams and add tests around current behavior.
3. Completion handlers to async/await in services.
4. ObservableObject to Observation only for complete flows whose target supports it.
5. Mutable singletons to explicitly owned stores/services.
6. Strict concurrency targeted, then complete; fix Sendable and isolation.
7. Swift language mode 6.
8. Coordinator to Router/NavigationStack only for complete SwiftUI flows.

Do not force v2 patterns into half a screen. A local legacy pattern is temporarily
acceptable when changing it would expand scope materially; document the reason and
the future seam in an ADR.

## Placement quick reference

| New code | Location |
|---|---|
| Screen | Features/Feature/NameView.swift |
| Screen orchestration | Features/Feature/NameViewModel.swift |
| Feature route | Features/Feature/NameRoute.swift and Router if needed |
| Feature capability | Features/Feature/NameClient.swift |
| Endpoint DTO/mapping | Features/Feature/Data/ |
| Generic HTTP transport | Core/Networking/ |
| Cross-feature current state | Core/Stores/ |
| System integration | Core/Services/Capability/ |
| Queryable persistence | Core/Persistence/ |
| Shared UI | DesignSystem/ after a second consumer |
| Preview fixture | PreviewSupport/; never real customer data |
| Test-only fake | Tests/Support/ |
| Top-level wiring | App/ |
| Public environment value | Config xcconfig -> injected AppEnvironment |
| Architecture exception | docs/adr/ plus AGENTS.md summary |

## Definition of done for agent changes [ARCH-015]

Before declaring a change complete:

- scope and architecture boundary match the task
- no dependency-direction violation was introduced
- live dependencies are wired explicitly
- build succeeds with the documented command
- relevant unit/integration/UI tests pass
- Simulator automation evidence identifies the build, configuration, destination, and flow when used
- important previews compile
- loading, failure, cancellation, and empty states were considered
- accessibility and localization were considered
- formatter/linter ran
- no secrets, customer data, or production-only side effects entered tests/previews
- architectural deviations have an ADR and AGENTS.md summary
