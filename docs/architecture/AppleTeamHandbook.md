# How We Build Apple Apps — v2

The team standard for iOS, iPadOS, and tvOS

| Metadata | Value |
|---|---|
| Status | Proposed v2.1 — ready for team review |
| Version | 2.1 |
| Owner | Apple Platform Team |
| Audience | Developers, tech leads, QA, and AI agents |
| Review | At least twice per year and after a major Swift/Xcode change |
| Companion | AppleTeamArchitectureStandard.md |

## How we use the documents

This handbook is **the canonical source for humans**: it explains the decisions, the
reasoning, the exceptions, and the examples. AppleTeamArchitectureStandard.md is the
compact operational form for agents and code review.

Every decision has an ARCH ID. The same IDs must exist in both documents.
Until the compact variant is generated automatically, any decision change:

1. updates the handbook;
2. updates the agent-facing standard in the same pull request;
3. keeps the same ARCH ID;
4. updates the changelog;
5. passes the CI check on the ID set.

A repo does not copy skills or rules from some randomly chosen project. Tooling and
skills come from a company-level versioned source, and the repo records the installed
version.

## Order of authority [ARCH-001]

When two rules appear to conflict, the order is:

1. the current requirement and the product constraints;
2. an ADR explicitly approved in the repo;
3. the deviation summary in AGENTS.md;
4. this standard;
5. the legacy convention in the code's immediate vicinity.

AGENTS.md stays short. It states **what differs** and points to an ADR in docs/adr/ that
explains why, who owns the decision, and when it can be re-evaluated.

An undocumented deviation is a process bug. At the same time, the standard is not an
excuse to turn a small task into a sweeping refactor. We adopt the rules at clean
seams — a feature, a flow, a service, or a whole target — not in one half of a
screen.

---

## 0. The decisions at a glance

| ID | Area | Default |
|---|---|---|
| ARCH-001 | Applicability | Greenfield applies v2. Legacy adopts at explicit seams; deviations have ADRs. |
| ARCH-002 | Language and UI | Swift 6 + SwiftUI for new code. UIKit stays at the edges and in legacy. |
| ARCH-003 | Architecture | Feature-first modular MVVM/R. TCA is an approved per-project alternative. |
| ARCH-004 | State | Local-first ownership, Observation on OS 17+, optional ViewModel, explicit states. |
| ARCH-005 | Navigation | Typed routes and a semantic Router; typed array by default, NavigationPath only for heterogeneous stacks. |
| ARCH-006 | DI | Explicit init injection; AppContainer is the composition root; no hidden live default. |
| ARCH-007 | Data | Core provides transport; each feature owns its small client and its mapping. |
| ARCH-008 | Persistence | UserDefaults for preferences, Keychain for credentials, SwiftData for queryable data. |
| ARCH-009 | Configuration | The environment is a value injected from xcconfig; in-app config is not secret. |
| ARCH-010 | Structure | Modular monolith and buildable folders; SPM only with a measurable reason. |
| ARCH-011 | Localization | String Catalogs, English literals in views, LocalizedStringResource outside them. |
| ARCH-012 | Analytics and logging | Typed events, providers behind the facade, os.Logger for diagnostics. |
| ARCH-013 | Testing and CI | Test pyramid, Swift Testing, XCTest UI, selective snapshots, deterministic commands. |
| ARCH-014 | Design and accessibility | Tokens in assets, reusable DesignSystem, Dynamic Type, VoiceOver, and per-platform input. |
| ARCH-015 | Agent tooling | Stable build/test/format/lint interface; no manual project.pbxproj edits. |
| ARCH-016 | Third-party | Apple-native first; owner, license, security, version, and an ADR when it changes the architecture. |
| ARCH-017 | Legacy | Migrate in vertical slices, in dependency order, with no speculative rewrites. |

---

## 1. Applicability and technical baseline [ARCH-001] [ARCH-002]

### 1.1 Greenfield projects

A new project starts with:

- Swift 6;
- complete concurrency checking;
- SwiftUI for the UI;
- Observation for reference-type state;
- async/await for asynchronous operations;
- Swift Testing for unit and integration tests;
- XCTest for UI tests;
- a deployment target of at least iOS/iPadOS/tvOS 17, so that native Observation
  is available.

The product may choose a higher deployment target. That is a product and distribution
decision, not one the architecture guesses.

### 1.2 Legacy projects below OS 17

If the minimum target does not support Observation, then ObservableObject, Published,
StateObject, and ObservedObject remain allowed **inside complete legacy flows**. We do
not introduce an improvised backport, and we do not mix the mechanisms in the same screen.

When the target rises:

1. migrate one complete flow;
2. update the tests;
3. remove the old mechanism from that flow;
4. only then move on to the next one.

### 1.3 UIKit

SwiftUI is the default for everything new, not a dogmatic ban on UIKit.
UIKit remains valid:

- in working legacy screens;
- when integrating with frameworks that have no mature SwiftUI equivalent;
- for local wrappers via UIViewRepresentable/UIViewControllerRepresentable;
- when an ADR and measurements show that SwiftUI does not meet the requirement.

The wrapper isolates UIKit at the edge. Business logic does not migrate into a
coordinator, delegate, or view controller just because the UI is UIKit.

---

## 2. The default architecture: Feature-first MVVM/R [ARCH-003]

MVVM/R stands for Model, View, ViewModel, and Router, but it does not mean four files
for every component. The roles exist only when they solve a real problem.

### 2.1 The roles

**Model**

- a value type, usually Identifiable and Equatable when identity or comparison
  are actually needed;
- named after the concept: HomeItem, EpisodeCard, AccountSummary;
- no generic HomeModel.swift files used merely as a drawer for unrelated types;
- a DTO, a SwiftData model, and a displayed model do not automatically become three
  different types; the separation appears only at a real boundary.

**View**

- describes the UI;
- reads state;
- sends the user's intent through methods, closures, or bindings;
- owns the adaptive layout and local visual state;
- does no networking, persistence, or deep-link parsing.

**ViewModel**

- an Observable class, isolated to the MainActor;
- optional;
- owns screen orchestration, not every visual detail;
- does not navigate and does not receive the whole AppContainer.

**Router**

- owns only navigation state and transitions;
- exposes semantic methods;
- contains no business logic, networking, or product analytics.

**Client**

- the narrow capability the feature needs;
- represents the seam with the network, storage, or an SDK;
- has one live implementation and small fakes for tests/previews.

### 2.2 When we create a ViewModel [ARCH-004]

We create XxxViewModel when the screen does at least one of the following:

- coordinates async operations;
- transforms data in a non-trivial way;
- manages loading, refresh, pagination, error, or retry;
- holds a form with validations and steps;
- orchestrates a timer, playback, an upload, or another side effect;
- owns state that must survive a change of view identity.

We do not create a ViewModel when the view:

- only displays received values;
- has only local UI state;
- is a leaf component from DesignSystem;
- forwards a tap through a closure;
- would have a ViewModel that merely forwards other methods.

A thin ViewModel can be correct. A ViewModel with no decision of its own is
boilerplate.

### 2.3 Local-first state [ARCH-004]

| Who owns the state | Mechanism |
|---|---|
| View, transient | State |
| Parent, the child writes | Binding |
| Screen, observable reference | State holding an Observable type |
| App/cross-feature | Observable store in Environment |
| Feature-local service | Explicit initializer parameter |

Environment is for dependencies and state shared across a wide area. We do not use it
just to avoid two parameters.

### 2.4 LoadState without dogma

For a single, simply loaded resource:

~~~swift
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(AppError)
}
~~~

The advantage is that loading and failed can never be accidentally active at the same
time.

We do not force LoadState when the screen has:

- existing content during a refresh;
- pagination;
- several independent resources;
- stale/offline content;
- partial errors;
- optimistic updates.

In those cases the feature defines its own State:

~~~swift
struct FeedState {
    var items: [FeedItem] = []
    var initialLoad: InitialLoadPhase = .idle
    var refresh: RefreshPhase = .idle
    var nextPage: PaginationPhase = .idle
}
~~~

The rule is not "a single enum at any cost" but "no impossible combinations and no
duplicated state".

CancellationError is a normal completion for a task tied to a lifecycle. We do not
surface it as a product error.

### 2.5 Unidirectional flow

State flows down, intent flows up:

~~~text
View -> method on ViewModel/Router/closure
     -> state update
     -> View re-renders
~~~

MVVM/R does not add Action/Reducer/Store on top of this flow. If the project needs
that level of formalization, choose TCA coherently instead of building an incomplete TCA.

### 2.6 TCA as an alternative

TCA is approved when one or more of the following exist:

- complex state machines;
- many concurrent effects and cancellations;
- offline/realtime/synchronization;
- deep composition across features;
- difficult shared state;
- a strong need for deterministic or exhaustive tests;
- a team that knows TCA and accepts its cost.

The decision is made at the start or through an ADR and a representative spike. The
ADR answers:

1. what problem TCA solves;
2. why MVVM/R is not enough;
3. who owns the expertise;
4. which version/upgrade policy we use;
5. how we test and how we migrate.

A TCA project follows the current Point-Free conventions for reducers, dependencies,
navigation, Observation, and TestStore. The MVVM/R recipes for ViewModel, Router, and
DI do not apply to TCA features.

We do not mix TCA and MVVM/R in the same feature. A temporary boundary is acceptable
only during a documented migration, with an owner and a removal condition.

---

## 3. The dependency graph [ARCH-007] [ARCH-010]

The graph matters more than the folder names:

~~~text
App                  -> Features, Core, DesignSystem
Features             -> Core, DesignSystem
DesignSystem         -> no app-internal module
Core                 -> does not import App, Features, or DesignSystem
AppExtensions        -> Core and optionally DesignSystem; never Features
~~~

Mandatory consequences:

- Core/Networking does not read AppEnvironment;
- Core does not return types defined in Features;
- a push service in Core does not call AppRouter;
- networking does not mutate SessionStore directly;
- DesignSystem does not start requests and does not read the session;
- App is the only place that knows all the concrete implementations.

### 3.1 The shape of the composition root

~~~text
Bundle + xcconfig
      |
      v
AppEnvironment
      |
      v
AppContainer
  |       |        |
HTTP    stores   feature clients
  \       |        /
      feature views
~~~

An external payload follows the inverted direction:

~~~text
push URL/payload -> Core parser -> NavigationIntent -> AppRouter
HTTP 401         -> AuthFailure -> Session orchestration in App
~~~

Core produces typed values; App decides what effect they have in the application.

---

## 4. Folder structure [ARCH-010]

### 4.1 Single-platform

~~~text
MyApp/
├── App/
│   ├── MyAppApp.swift
│   ├── AppContainer.swift
│   ├── AppEnvironment.swift
│   └── AppRouter.swift
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift       # optional
│   │   ├── HomeRoute.swift           # optional
│   │   ├── HomeClient.swift          # when I/O exists
│   │   ├── HomeItem.swift
│   │   ├── Data/                     # DTO + mapping when needed
│   │   └── Components/
│   └── Profile/
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   ├── Stores/
│   ├── Services/
│   ├── Analytics/
│   ├── Logging/
│   └── Utils/
├── DesignSystem/
├── Resources/
├── Config/
├── PreviewSupport/
├── Tests/
│   └── Support/
├── UITests/
├── docs/
│   ├── architecture.md
│   └── adr/
├── scripts/
├── tooling/
│   ├── skills.yml
│   └── tools.yml
├── skills.lock                   # when the distribution supports locking
├── AGENTS.md
└── Makefile
~~~

We replace the vague Managers folder with Stores or Services plus a semantic subfolder.
Utils stays small. When a helper grows, it takes the name of the concept it
implements.

### 4.2 The promotion rule

Everything starts as close as possible to the feature that owns it. We move code into
Core or DesignSystem when:

- a second real consumer appears;
- an app extension needs the same capability;
- a platform boundary exists;
- a product decision defines a global token/component.

We do not build shared code for hypothetical consumers.

### 4.3 Multi-platform iOS/tvOS

~~~text
App/
  iOS/
  tvOS/
  Shared/
Shared/
  Networking/
  Persistence/
  Stores/
  Services/
  Model/
  FeatureLogic/
iOS/
  Features/
tvOS/
  Features/
DesignSystem/
AppExtensions/
Resources/
Config/
Tests/
UITests/
~~~

Shared is the headless cross-platform layer. It may contain ViewModels and Observation,
but no platform-specific views. Large interaction divergence produces separate views
over the same logic.

tvOS-only types carry the TV prefix. Shared and iOS types get no platform
prefix.

### 4.4 App extensions

Widgets, Live Activities, and notification services:

- have their own entry point and resources;
- may depend on Core/Shared and DesignSystem;
- do not import Features;
- read shared data through an App Group container behind a protocol;
- do not import the app's runtime stores directly.

---

## 5. Dependency injection and configuration [ARCH-006] [ARCH-009]

### 5.1 Explicit dependencies

~~~swift
protocol HomeClient: Sendable {
    func loadHome() async throws -> [HomeItem]
}

@MainActor
@Observable
final class HomeViewModel {
    private(set) var state: LoadState<[HomeItem]> = .idle
    private let client: any HomeClient

    init(client: any HomeClient) {
        self.client = client
    }
}
~~~

We do not use:

~~~swift
init(client: any HomeClient = .live)
~~~

A live default hides the dependency, bypasses AppContainer, and can hit the network in
tests or previews. Production must construct the live system explicitly.

### 5.2 AppContainer

AppContainer:

- receives AppEnvironment as a value;
- builds HTTPClient, stores, services, and feature clients;
- is a composition root, not a service locator;
- is not injected as a giant object into every feature;
- provides narrow dependencies at the feature's creation point.

~~~swift
struct AppContainer {
    let sessionStore: SessionStore
    let homeClient: any HomeClient

    init(environment: AppEnvironment) {
        let http = HTTPClient(baseURL: environment.apiBaseURL)
        self.sessionStore = SessionStore()
        self.homeClient = LiveHomeClient(http: http)
    }
}
~~~

### 5.3 AppEnvironment

~~~swift
struct AppEnvironment: Sendable {
    enum Name: String, Sendable {
        case production
        case qa
        case staging
    }

    let name: Name
    let apiBaseURL: URL
    let analyticsEnabled: Bool

    static func fromBundle(_ bundle: Bundle = .main) throws -> AppEnvironment {
        // parse and validate once at startup
    }
}
~~~

AppEnvironment has no global current. App creates it at the root and passes it to
AppContainer. Core receives only the concrete values it needs.

### 5.4 xcconfig, targets, and secrets

~~~text
Config/
├── Shared.xcconfig
├── iOS/
│   ├── Production.xcconfig
│   ├── QA.xcconfig
│   ├── Staging.xcconfig
│   ├── Info.plist
│   └── *.entitlements
└── tvOS/
    └── ...
~~~

Environments are configuration differences, not code differences:

~~~text
xcconfig -> $(VARIABLE) in Info.plist -> AppEnvironment -> AppContainer
~~~

Rules:

- #if QA / #if STAGING is forbidden;
- #if os(...) is allowed for real API/platform differences;
- #if DEBUG is allowed only for local tooling and preview support;
- QA may have a debug menu injected as an implementation, without a compiled branch;
- feature flags are typed and injected.

Info.plist and xcconfig are visible in the binary. They may contain the bundle ID, the
base URL, and public config, but **never a secret**. A secret needed for authorization
stays on the server. The user's tokens live in the Keychain.

---

## 6. The data layer and persistence [ARCH-007] [ARCH-008]

### 6.1 Core provides transport, the feature provides the capability

Core/Networking takes care of:

- URLSession;
- request building;
- response validation;
- auth headers through an injected credential provider;
- retry and cancellation policy;
- typed transport errors;
- operational telemetry;
- decoding primitives.

The feature owns the endpoint contract and the mapping:

~~~swift
protocol ProfileClient: Sendable {
    func loadProfile(id: UserID) async throws -> Profile
    func updateProfile(_ draft: ProfileDraft) async throws -> Profile
}

struct LiveProfileClient: ProfileClient {
    let http: HTTPClient

    func loadProfile(id: UserID) async throws -> Profile {
        let dto: ProfileDTO = try await http.send(.profile(id: id))
        return Profile(dto: dto)
    }
}
~~~

There is no global ApiServiceProtocol with all of the app's endpoints. Protocols are
split by capability or feature, so that a test never implements methods unrelated
to its subject.

Transport does not leak:

- no import Apollo/Alamofire in a View or ViewModel;
- no generated GraphQL types in presentation;
- no raw JSON or HTTP status interpreted inside a feature;
- no SwiftData models used as DTOs.

### 6.2 Domain layer

Domain is not a mandatory folder. We introduce it through an ADR when there are:

- shared business invariants;
- critical calculations that must be tested independently;
- cross-feature use cases;
- offline workflows;
- the same logic across several platforms/products;
- a need to protect business rules from UI, transport, and storage.

The absence of a Domain folder does not mean the absence of business logic. For a
local rule, the ViewModel or a feature service can be the right place. When the rules
repeat or become critical, we promote the concept.

### 6.3 Repository

Repository is neither mandatory nor forbidden. It earns its place when it owns a
policy, not merely when it renames a call:

- it combines network and local storage;
- it decides cache freshness;
- it implements offline-first;
- it synchronizes and resolves conflicts;
- it provides a stable business-facing query contract;
- it coordinates several sources or versions.

A wrapper that just calls HomeClient.loadHome is not a useful Repository.

### 6.4 Persistence

| Data type | Mechanism |
|---|---|
| Small preferences/flags | UserDefaults or AppStorage through the owning store |
| Tokens/credentials | Keychain behind a protocol |
| Queryable local models | SwiftData by default |
| Temporary HTTP/media cache | dedicated client/cache |
| Server secret | never ships in the app |

ModelContainer is built in App. Simple SwiftData screens may use Query directly.
When business rules, synchronization, or complex testing appear, the feature
uses an injected persistence client/store.

### 6.5 Auth failures

Networking does not mutate SessionStore directly. The flow is:

~~~text
HTTPClient detects an unrecoverable 401
    -> throws AuthFailure.sessionExpired
    -> the orchestration layer in App updates SessionStore
    -> RootView observes the session
    -> AppRouter switches the flow
~~~

Alternatively, HTTPClient receives an AuthFailureHandler protocol defined at a
headless boundary, and the implementation that knows SessionStore is built in App. In
both variants, Core does not import the Router or the UI.

---

## 7. State, communication, and Swift Concurrency [ARCH-002] [ARCH-004]

### 7.1 Ownership before the wrapper

Before choosing State, Binding, or Environment, we answer:

1. who is the single owner;
2. how long the state must live;
3. who reads it;
4. who can modify it;
5. is it current state or a one-shot event?

Most data-flow bugs come from ambiguous ownership, not from picking the wrong
property wrapper.

### 7.2 Global stores

Cross-feature state, such as the session, favorites, or download progress,
lives in an Observable store isolated to the MainActor.

~~~swift
@MainActor
@Observable
final class SessionStore {
    private(set) var state: SessionState
    private let authClient: any AuthenticationClient

    init(
        initialState: SessionState,
        authClient: any AuthenticationClient
    ) {
        self.state = initialState
        self.authClient = authClient
    }
}
~~~

The store:

- is created exactly once in App;
- is injected into the Environment;
- receives its dependencies through init;
- has no static shared;
- exposes current state, not string-based notifications;
- stays focused on a single state domain.

We do not inject a universal AppStore holding the whole application into an MVVM/R
project. If the need for a global reducer store appears, we re-evaluate whether the
project should be TCA.

### 7.3 State versus event

**State:** a view appearing right now needs the current value.

Examples: session, favorites, progress, connectivity, feature flags.

**Event:** a one-shot fact with no meaningful current value.

Examples: an external URL received, a scroll-to-top request, a system result consumed
exactly once.

State becomes an observable property. An external event becomes a typed intent or an
AsyncSequence at the boundary. We do not simulate an event bus with a custom
NotificationCenter.

### 7.4 How views communicate

~~~text
parent -> child        value; Binding only for write-back
child -> parent        closure or Binding
siblings               lift the state to the common owner
cross-feature          Observable store with explicit ownership
external system        Core adapter -> typed value/event
~~~

A ViewModel does not implicitly subscribe to the whole global store. It receives the
capability or the value it needs. For a lifecycle-bound reload, the view can coordinate:

~~~swift
.task(id: sessionStore.state.userID) {
    await viewModel.reload(for: sessionStore.state.userID)
}
~~~

The task is cancelled automatically when the identity changes or the view disappears.

### 7.5 Actor isolation

For greenfield projects:

- App/UI targets use default MainActor isolation whenever the toolchain
  supports it;
- ViewModels, Routers, and UI stores are MainActor;
- value types crossing boundaries are Sendable;
- services with shared mutable state use an actor or another explicit isolation;
- local packages declare their concurrency settings explicitly instead of assuming
  they inherit them.

An async func does not mean "runs in the background". The operation may suspend
without blocking the actor, but the synchronous code between awaits runs in the
isolation context established by the toolchain and the declarations.

We do not mechanically mark every service nonisolated. We use nonisolated for
stateless/pure APIs that genuinely must be called from several domains. For
CPU-intensive work we use explicit concurrent execution only once the volume justifies it.

We avoid Task.detached. It is allowed only when:

- the task must intentionally be detached from the lifecycle;
- the captured values are Sendable;
- ownership of the result and cancellation are documented;
- a test or a measurable reason exists.

### 7.6 Errors and cancellation

We separate:

- the transport error;
- the business error;
- the localized message for the user;
- the diagnostic for Logger/crash reporting.

A ViewModel maps the error into a testable AppError or feature error. We do not show
error.localizedDescription directly as product copy.

CancellationError:

- is not reported as an incident;
- produces no toast;
- does not turn a valid state into an error;
- cleans up resources and ends the operation.

---

## 8. Navigation, deep links, and push [ARCH-005]

### 8.1 Typed routes

For a homogeneous flow:

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

    func popToRoot() {
        path.removeAll()
    }
}
~~~

We use a typed array because the route enum is homogeneous. NavigationPath is
reserved for stacks that must intentionally contain different types.

Routes carry small, stable identifiers. They do not carry views, ViewModels,
or large model graphs.

### 8.2 Flow ownership

- each tab has its own NavigationStack and history if the product expects
  independent histories;
- the feature router owns the local flow;
- AppRouter owns root switching, tab selection, and deep-link delegation;
- the Router does not decide permissions, eligibility, or business rules;
- an account/resource change may explicitly reset the relevant path.

Views use semantic methods such as showDetails(id:), not path.append scattered
across dozens of files.

### 8.3 Sheets

We use item/enum state for mutually exclusive presentations:

~~~swift
enum HomeSheet: Identifiable {
    case filters
    case share(itemID: String)
}
~~~

A purely local sheet stays in the view. We move it into the Router only when:

- it is part of the flow;
- it must be controlled by a deep link;
- it must be restored;
- a parent must coordinate it.

We do not turn the Router into an inventory of every local popover.

### 8.4 Deep links

~~~text
raw URL
 -> DeepLinkParser
 -> Result<NavigationIntent, DeepLinkError>
 -> AppRouter.handle(intent:)
~~~

The parser is pure and testable. AppRouter does not parse strings in onOpenURL.

For an unknown or malformed link:

- log without sensitive data;
- ignore it safely or show an explicit unsupported-link state;
- do not navigate silently to an unrelated screen.

### 8.5 Push notifications

The Core service decodes the payload into a NotificationIntent. It does not import
or call AppRouter.

~~~text
UNUserNotification payload
 -> NotificationIntentParser in Core
 -> NotificationIntent
 -> App-level handler
 -> AppRouter
~~~

The system delegate stays thin and contains no business logic.

---

## 9. Design system, layout, and accessibility [ARCH-014]

### 9.1 DesignSystem

The asset catalog/tokens hold:

- semantic colors;
- fonts and text styles;
- custom images and symbols;
- spacing/radius/elevation when the product standardizes them.

DesignSystem holds the components with at least two real consumers, or those defined
explicitly as product primitives.

A DesignSystem component:

- does not import networking, the session, or feature models;
- receives values and closures;
- has previews for the important states and sizes;
- has a small, semantic API;
- does not guess the layout of the whole screen.

### 9.2 Adaptive layout

Size classes, container size, and platform input live in Views. The ViewModel knows
nothing about orientation, screen width, or the focus engine.

Differences:

1. one isolated API difference: local #if os(...);
2. several differences in the same view: per-platform methods/extensions;
3. a different interaction model: separate views over shared logic.

### 9.3 Accessibility baseline

Every new feature checks:

- Dynamic Type, including the large sizes;
- VoiceOver label/value/hint for non-text controls;
- a logical focus order;
- contrast and differentiation that does not rely on color alone;
- Reduce Motion and Reduce Transparency where animation/material matters;
- comfortable interaction targets;
- focus and the remote on tvOS;
- keyboard/pointer on iPadOS when the flow benefits.

Accessibility identifiers are for stable tests. They do not replace semantic labels
for the user.

---

## 10. Localization and copy [ARCH-011]

We use String Catalogs as the source of truth.

In Views:

~~~swift
Text("Continue Watching")
Button("Try Again") { ... }
~~~

The English literal is both the key and the source text. We do not use a giant
AppStrings.swift, nor dotted keys with no visible semantic value.

Outside Views:

~~~swift
let message: LocalizedStringResource
~~~

Important rules:

- add a translator comment when the meaning is ambiguous;
- use the pluralization and interpolation the catalog supports;
- format dates, measurements, currencies, and numbers with FormatStyle;
- check RTL for the relevant layouts;
- an English copy change can create a new key, so the PR checks the impact on
  translations;
- do not build localized sentences by concatenating fragments.

One catalog per app is the default. Reusable packages may have their own catalog when
they have independent resources and ownership.

---

## 11. Analytics, logging, and crash reporting [ARCH-012]

### 11.1 Analytics

A typed facade hides Firebase, Datadog, or any other provider:

~~~swift
protocol AnalyticsClient: Sendable {
    func track(_ event: AnalyticsEvent) async
}
~~~

Events:

- are typed enums/structs;
- live next to the owning feature;
- do not use raw [String: Any] in the feature;
- have stable naming and parameters;
- contain no PII without approval and documentation.

Business events are emitted where the result becomes true. Networking does not emit
purchaseCompleted just because a request returned 200.

Screen tracking uses a shared modifier/helper that defines whether a reappearance of
the same view counts again. A raw onAppear can double events in SwiftUI.

### 11.2 Logging

We use os.Logger with:

- the app's subsystem;
- semantic categories: networking, auth, persistence, playback, navigation;
- appropriate levels;
- privacy annotations.

We do not use print in production paths. We do not log:

- tokens;
- passwords;
- full payloads containing personal data;
- payment information;
- the user's images/documents;
- complete signed URLs.

### 11.3 Three different channels

Do not confuse:

- the message to the user;
- the technical log;
- the analytics event.

Crash/error monitoring has its own facade. A catch may:

1. report the sanitized diagnostic;
2. map into a feature error;
3. update the UI;

but each step has a distinct purpose and can be tested.

---

## 12. Testing, previews, and CI [ARCH-013]

### 12.1 The test pyramid

1. **Many fast unit tests**
   ViewModels, state transitions, mappers, parsers, business rules.

2. **Fewer integration tests**
   HTTP adapters with URLProtocol/fake transport, in-memory persistence, composed
   features, and contracts between layers.

3. **Few, valuable UI tests**
   Login, checkout, playback, create/edit, deep link, or other critical journeys.

4. **Performance tests**
   Only for measured hot paths: launch, scrolling, large parsing, media pipeline.

Swift Testing is the default for new unit/integration tests. XCTest remains for
XCUITest and for legacy tests not worth migrating mechanically.

### 12.2 What we test in a feature

For a typical async feature:

- success;
- empty;
- mapped business failure;
- transport failure;
- retry;
- cancellation;
- a delayed response after the input changed;
- initial state and stable identity;
- the analytics/business event when relevant.

Fakes are narrow and deterministic. They do not use real sleeps and do not make live
requests.

### 12.3 Previews

A preview is mandatory for:

- every screen;
- every reusable DesignSystem component;
- loading, loaded, empty, and error when they exist;
- relevant accessibility states.

A trivial private leaf view does not need its own preview.

Previews use synthetic data. Never copies of payloads or customer/production
data.

Preview-only code does not reach Release. We use:

- a support target/module excluded from shipping; or
- a reviewed DEBUG boundary for local tooling.

Test doubles that previews do not need stay in Tests/Support.

### 12.4 Snapshot testing

Snapshots are selective:

- stable DesignSystem tokens and components;
- screens with high visual risk;
- visual bugs that have recurred;
- platform/locale/dynamic-type layouts where the image adds value.

We do not snapshot every View. The harness pins device, OS policy, locale, calendar,
time zone, color scheme, and content size. The library choice is company/repo policy,
not a dependency added unilaterally by a feature PR.

### 12.5 The command interface

Every new repo provides:

~~~text
make bootstrap   # only when setup exists
make build
make test
make test-ui
make format
make lint
~~~

The implementation may call xcodebuild, Xcode MCP, or scripts, but the interface stays
stable for humans and agents.

AGENTS.md documents:

- schemes;
- simulator/destination;
- Xcode/Swift version;
- required variables;
- the approximate duration;
- the quick per-feature commands;
- how to read xcresult/logs.

### 12.6 CI baseline

Every pull request verifies:

- clean dependency resolution;
- a build of all shipped app/extension targets;
- unit and integration tests;
- format and lint;
- no new warnings;
- validation of generated files;
- the UI test set established by the repo.

Expensive UI tests may be split between PR and nightly, but the most critical
journeys must have a signal before merge.

CI must run from a clean checkout, not from local DerivedData.

---

## 13. Xcode, modules, and external dependencies [ARCH-010] [ARCH-015] [ARCH-016]

### 13.1 Modular monolith as the default

Feature-first folders and the dependency graph are enough at the start for most
applications. We do not create a package for every screen.

We extract into a local SPM module when at least one measurable reason exists:

- build time or test isolation improves;
- the feature has an independent ownership/release boundary;
- the same code is used by the app and an extension;
- the same code is used in several products;
- review can no longer reliably enforce the dependency direction;
- a real technical boundary exists, not just the desire for more folders.

The ADR records the reason, the target graph, and the impact on the build.

### 13.2 Buildable folders and project.pbxproj

New projects use buildable folder references where appropriate, so that adding a
file does not permanently produce conflicts in project.pbxproj.

Rules for agents and developers:

- do not edit project.pbxproj by hand;
- use buildable folders, Xcode, or the repo's official generator;
- project generation must be deterministic;
- generated changes are inspected before commit;
- do not resolve a pbxproj conflict by deleting unknown entries;
- do not change signing/entitlements/capabilities outside the task's scope.

### 13.3 Third-party dependencies

We prefer Apple APIs when they reasonably satisfy the requirement. A new external
dependency requires:

1. a clear need and evaluated alternatives;
2. an internal owner;
3. a compatible license;
4. acceptable activity and maintenance;
5. a security/privacy review proportional to the data accessed;
6. a version and upgrade policy;
7. Package.resolved committed for applications;
8. an ADR if it changes the architecture, state management, networking, navigation, or
   persistence;
9. an exit/migration note for structural dependencies.

We do not add a DI framework, router framework, networking wrapper, or state framework
just to save a few lines.

TCA is a structural dependency approved only through the decision in ARCH-003.

### 13.4 Binary dependencies and SDKs

For analytics, ads, payments, or media SDKs:

- an adapter in Core/Services or Core/Analytics;
- features do not import the SDK;
- initialization happens in App;
- the privacy manifest and required reason APIs are verified;
- tracking is controlled by consent and config;
- the behavior without the SDK/consent has a testable no-op implementation.

---

## 14. Tooling and working with AI agents [ARCH-015]

### 14.1 What an agent must find in the first minutes

AGENTS.md must answer quickly:

- which product and target I am changing;
- what the architecture is;
- what the local deviations are;
- where the feature lives;
- which command builds;
- which command tests;
- which simulator I use;
- which files I do not touch;
- what the definition of done is.

AGENTS.md does not duplicate the whole handbook. It summarizes the repo and points to
the standard, the skills, and the ADRs.

### 14.2 The canonical Skill Map

The ARCH standard says **which architecture and which boundaries we use**. A skill
says **how to execute a specialized activity correctly**. A skill cannot implicitly
change an ARCH decision.

| Activity | Canonical skill | When it is mandatory |
|---|---|---|
| SwiftUI screen, state, or navigation | apple/swiftui-patterns | Any relevant task |
| Restructuring a SwiftUI View | apple/swiftui-refactoring | View refactoring |
| Rendering/performance diagnosis | apple/swiftui-performance | Performance audit or issue |
| Swift 6 isolation, actors, Sendable | apple/swift-concurrency | Any concurrency change |
| Unit/integration tests or migration | apple/swift-testing | Any testing task |
| Build, Simulator, logs, runtime debugging | apple/ios-runtime-debugging | Any runtime verification |
| SwiftData schema/query/migration | apple/swiftdata | Any SwiftData persistence change |
| UI implementation/review | apple/apple-accessibility | Mandatory step for UI |
| UIKit modernization | apple/uikit-modernization | Legacy UI migration |
| TCA feature | apple/tca | Only in TCA projects |
| App Intents, Shortcuts, Siri, Spotlight | apple/app-intents | System-intent integration |

We use the smallest set that covers the task. A SwiftUI screen that adds SwiftData
and App Intents may need three skills; a type rename does not need every Apple
skill.

The IDs in the table are tool-independent. Codex, Claude, Kiro, or another runtime may
expose different names. The concrete mapping lives in AGENTS.md, with no absolute
paths to caches or the home directory.

### 14.3 Manifest and versions

Every repo declares its skills in a machine-readable file:

~~~yaml
# tooling/skills.yml
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

Where the distribution system allows it, skills.lock pins the resolved versions.

A canonical skill:

- comes from the company registry/repo;
- has an owner, a version, and a changelog;
- declares its Swift/Xcode/deployment-target compatibility;
- has a documented install/update command;
- is not copied by hand from "a similar project";
- cannot change an ARCH decision without updating the standard.

CI verifies:

- a valid manifest;
- the baseline skills are present;
- versions within the accepted policy;
- the lock in sync with the manifest;
- no unknown IDs or local paths.

AGENTS.md contains the runtime mapping:

~~~text
Canonical skill                 Installed capability       Version
apple/swiftui-patterns          <tool-specific name>       <resolved>
apple/swift-concurrency         <tool-specific name>       <resolved>
apple/swift-testing             <tool-specific name>       <resolved>
~~~

### 14.4 MCP and the Tool Capability Map

A skill explains the working method; an MCP or another tool provides executable
actions. We do not put an MCP's name in `tooling/skills.yml`, and we do not assume
that installing a tool replaces the standard, the tests, or the approvals.

The repo declares its capabilities in `tooling/tools.yml`:

| Capability | Default implementation | Adoption | When we use it |
|---|---|---|---|
| `apple/xcode-automation` | Xcode MCP / the supported Xcode interface | Recommended | Build, tests, diagnostics, and runtime operations supported by Xcode |
| `apple/ios-simulator-automation` | Tapia MCP | Recommended/conditional | Agents frequently exercise UI flows in the Simulator, inspect the accessibility tree, or capture repeatable local evidence |

Tapia is conditional because it brings great value in an agent-heavy workflow but is
not necessary in a project where XCUITest and manual verification cover the runtime
well enough. A project that adopts it:

- pins the reviewed version and commit in `tooling/tools.yml`;
- runs the doctor/health check before relying on it;
- adds a stable `accessibilityIdentifier` for the critical controls;
- uses non-production accounts and data in an isolated Simulator;
- limits auto-approval to the commands the session needs;
- keeps XCUITest for stable regressions and CI;
- records the build, configuration, device, flow, and timestamp of the evidence.

A passing Tapia flow demonstrates the behavior observed in the declared Simulator. It
does not demonstrate behavior on a real device, signing, distribution, the release
configuration, or production. If Tapia is missing, the fallback is XCUITest,
`simctl`/`idb`, or documented manual verification, with the evidence level reported
explicitly.

The installation and operations guide lives in `docs/tooling/TapiaMCPGuide.md`.

### 14.5 Precedence and missing skills

If a skill and the standard contradict each other:

1. the ARCH decision wins;
2. the conflict is reported to the skill's owner;
3. the skill is corrected upstream;
4. we do not create a silent local fork.

If the mandatory skill is not available:

1. the agent/developer reports the tooling gap;
2. follows the standard and the current primary Apple/Swift documentation;
3. does not invent an incompatible convention;
4. notes the gap in the handoff;
5. fixing the skill installation happens separately from the feature if it would
   expand the scope.

A missing skill does not automatically block an urgent fix, but it lowers the level of
verification we can claim.

### 14.6 Operational rules for agents

An agent:

- inspects the feature's code and conventions before editing;
- preserves the user's changes in the worktree;
- works within scope;
- does not expand the refactor without authorization;
- does not modify project.pbxproj by hand;
- uses explicit dependencies and deterministic fakes;
- builds and tests proportionally to the risk;
- reports separately what was verified locally and what was not;
- does not declare runtime/production verified just because the local build passes;
- documents any architectural deviation through an ADR.

### 14.7 Definition of done for a change

- the feature respects the dependency graph;
- AppContainer wires the live system explicitly;
- the build passes with the repo's command;
- the relevant tests pass;
- the Simulator evidence declares the build, configuration, device, and flow;
- the important previews compile;
- success, empty, failure, retry, and cancellation were evaluated;
- accessibility and localization were evaluated;
- format/lint ran;
- no secrets or real data entered the fixtures;
- no live side effects were added to tests/previews;
- any deviation has an ADR and a summary in AGENTS.md.

---

## 15. Legacy and migration [ARCH-017]

### 15.1 The vertical-slice principle

We migrate:

- a complete screen;
- a complete flow;
- a service together with all its consumers;
- a clear target or boundary.

We do not migrate:

- half of a ViewModel;
- one Observation property inside an object still dominated by Combine;
- a Router over a flow where the coordinator keeps making the decisions;
- Swift 6 without solving shared-state isolation.

### 15.2 The recommended order

1. **Mechanical hygiene**
   Naming, giant files, assets, buildable folders, a deterministic project.

2. **Characterization and seams**
   Test the existing behavior and define the boundary of the change.

3. **Completion handlers to async/await**
   In services, with cancellation and typed errors.

4. **ObservableObject to Observation**
   Only for complete flows and a compatible target OS.

5. **Mutable singletons to explicit ownership**
   Stores/services created in App and injected.

6. **Strict concurrency**
   Targeted, fix the warnings, then complete.

7. **Swift language mode 6**

8. **Coordinator to Router/NavigationStack**
   Only when the flow is entirely SwiftUI.

### 15.3 When we temporarily keep the local pattern

We keep it if:

- the change would materially expand the scope;
- no safe seam exists;
- tests are missing and the behavior is critical;
- the deployment target does not allow the standard;
- the migration would fragment the flow.

The ADR records:

- the reason;
- the risk;
- the future boundary;
- the owner;
- the re-evaluation condition.

Small, safe boy-scout improvements are welcome, but we do not hide large refactors
inside a feature PR.

---

## 16. Guardrails — what we deliberately do not do

### Architecture and ownership

- we do not create empty ViewModels;
- we do not introduce a universal AppStore into an MVVM/R project;
- we do not put business logic in a Router, AppDelegate, or View;
- we do not create new mutable singletons;
- we do not inject the whole AppContainer into features;
- we do not introduce Domain/Repository as a ritual;
- we do not forbid Domain/Repository when a real policy exists.

### Data and configuration

- we do not create an ApiServiceProtocol with every endpoint;
- we do not expose DTOs/GraphQL/Alamofire/Apollo to the UI;
- Core does not read AppEnvironment;
- Core does not call AppRouter;
- networking does not mutate SessionStore;
- we do not use #if QA;
- we do not put secrets in source, plist, or xcconfig;
- we do not store tokens in UserDefaults/SwiftData.

### SwiftUI and navigation

- we do not use NavigationPath for a homogeneous route enum without a reason;
- we do not store views or large models in the path;
- we do not move every local sheet into the Router;
- we do not start requests from body;
- we do not duplicate the same state across several properties;
- we do not use AnyView as the default answer to weak design.

### Tests and tooling

- we do not make live requests in unit tests/previews;
- we do not use real customer data in fixtures;
- we do not snapshot every view;
- we do not add a snapshot library unilaterally;
- we do not edit project.pbxproj by hand;
- we do not copy unverified skills from another repo;
- we do not declare done without build/test proportional to the risk.

---

## 17. Cookbook: unambiguous answers

### 17.1 Where do I put the type?

| I am writing | Location |
|---|---|
| SwiftUI screen | Features/Feature/NameView.swift |
| Screen orchestration | Features/Feature/NameViewModel.swift |
| Displayed type | Features/Feature/ConceptName.swift |
| Local route | Features/Feature/NameRoute.swift |
| Local router | Features/Feature/NameRouter.swift |
| Capability client | Features/Feature/NameClient.swift |
| The client's live adapter | Features/Feature/LiveNameClient.swift or Data/ |
| Endpoint DTO/mapping | Features/Feature/Data/ |
| Generic HTTP | Core/Networking/ |
| Session/favorites/download state | Core/Stores/ConceptStore.swift |
| System/SDK integration | Core/Services/Capability/ |
| Analytics facade | Core/Analytics/ |
| Logging helpers | Core/Logging/ |
| SwiftData models/store | Core/Persistence/ |
| UI component with 2+ consumers | DesignSystem/ |
| UI component with one consumer | Features/Feature/Components/ |
| Preview fixture | PreviewSupport/ |
| Test-only fake | Tests/Support/ |
| Startup and wiring | App/ |
| Deep link parser | App/Navigation/ or a headless parser consumed by App |
| Public per-environment config | Config/*.xcconfig -> AppEnvironment |
| Architectural exception | docs/adr/ + AGENTS.md summary |

### 17.2 How do I build an API-backed feature?

1. Define HomeItem and HomeClient in the feature.
2. Use the Core HTTPClient for transport.
3. Define a DTO only if the payload differs from the model.
4. Implement LiveHomeClient.
5. Inject the client explicitly into HomeViewModel.
6. AppContainer builds the live variant.
7. Tests/Support provides the fake for the unit test.
8. PreviewSupport provides synthetic data for the preview.
9. Test success, empty, failure, retry, and cancellation.

### 17.3 How do I add global state?

First ask whether it is truly global. If it is:

1. define a semantic store, not a GlobalManager;
2. make it Observable and MainActor;
3. inject its dependencies;
4. create it in App;
5. inject it through the Environment;
6. views read only the properties they need;
7. split the store when the state domains do not share the same lifecycle.

### 17.4 How do I react to a 401?

Do not call the Router from networking:

1. attempt a refresh in the auth layer if the policy allows it;
2. on definitive failure produce AuthFailure.sessionExpired;
3. app/session orchestration updates SessionStore;
4. RootView/AppRouter switches the flow;
5. log technically, without token/payload;
6. a test verifies the transition.

### 17.5 How do I add a deep link?

1. extend NavigationIntent;
2. extend the pure parser;
3. add tests for valid, invalid, and missing parameters;
4. AppRouter consumes the intent;
5. routes keep only IDs;
6. define the behavior when the resource does not exist or the user is not signed in.

### 17.6 How do I decide between MVVM/R and TCA?

Choose MVVM/R if the app is predominantly API/CRUD, with standard flows and local
state. Choose TCA if state machines, concurrent effects, offline/realtime, and
composition are central problems. Do not choose TCA merely for uniformity, and do not
reject it merely because it has more concepts.

Run a spike on the most representative flow, not on a counter demo.

### 17.7 How do I decide whether to extract a package?

Measure:

- clean build and incremental build;
- test duration;
- team ownership;
- app/extension/product reuse;
- the number of graph violations.

If the only reason is "it looks cleaner", keep the folder.

---

## 18. Architectural review checklist

### Feature

- state ownership is clear;
- the ViewModel exists only if it has logic;
- the client is narrow;
- there is no dependency on another feature;
- transport does not leak;
- the Router has no business logic.

### Concurrency

- MainActor isolation is correct;
- boundary types are Sendable;
- cancellation is handled;
- there is no Task.detached without a reason;
- heavy CPU work is not accidentally placed on the UI path.

### Prod and security

- injected config is not treated as a secret;
- tokens go into the Keychain;
- logs contain no sensitive data;
- analytics respects consent;
- mocks/preview data do not reach Release uncontrolled.

### Quality

- build/test/format/lint pass;
- the important previews work;
- accessibility is verified;
- the copy is localizable;
- every dependency or deviation has the required approval.

---

## 19. Governance of the standard

### Owner and review

The Apple Platform Team owns this document. Any developer can propose a change through
a short ADR/RFC that includes:

- the observed problem;
- examples from at least one repo;
- the proposed change;
- the migration cost;
- the impact on agents/tooling;
- the rollout plan.

### Statuses

- Proposed: under review, not mandatory;
- Accepted: the default for new projects;
- Deprecated: no longer introduced;
- Superseded: replaced by another ID/version.

### Changelog v2.1

- separated skills from tool capabilities via `tooling/tools.yml`;
- introduced Tapia MCP as `recommended/conditional` for Simulator automation;
- defined the limits of Tapia evidence and the XCUITest, simctl/idb, and manual fallbacks;
- introduced the canonical task-to-skill Skill Map;
- separated the canonical IDs from the Codex/Claude/Kiro-specific names;
- added tooling/skills.yml and skills.lock;
- defined the CI verification for skills and versions;
- defined the ARCH versus skill precedence;
- documented the fallback when a mandatory skill is missing.

### Changelog v2.0

- separated the Core HTTP transport from feature-specific clients;
- removed the global ApiServiceProtocol;
- made live DI explicit, with no hidden default;
- removed AppEnvironment.current from Core;
- inverted the push/auth integration through intents and typed errors;
- introduced the explicit exception for legacy below OS 17;
- made LoadState a default for simple loads, not a universal obligation;
- preferred a typed array for a homogeneous route enum;
- defined the test pyramid, previews, and selective snapshots;
- established the CI baseline and the agent commands;
- added the logging, accessibility, and third-party policy;
- introduced buildable folders and the ban on manual project.pbxproj edits;
- defined the criteria for Domain, Repository, SPM, and TCA;
- separated AGENTS.md from ADRs and introduced sync through ARCH IDs.

---

The standard is a default that removes repetitive decisions. When product reality
contradicts it, we do not hide the exception and we do not apply the rule mechanically:
we measure, document, and change the standard if the exception becomes the new common
case.
