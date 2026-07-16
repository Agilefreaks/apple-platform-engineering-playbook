# Cum construim aplicații Apple — v2

Standardul echipei pentru iOS, iPadOS și tvOS

| Metadata | Valoare |
|---|---|
| Status | Propunere v2.1 — pregătită pentru review de echipă |
| Versiune | 2.1 |
| Owner | Apple Platform Team |
| Audiență | Developeri, tech leads, QA și agenți AI |
| Review | Minimum de două ori pe an și după schimbări majore Swift/Xcode |
| Companion | AppleTeamArchitectureStandard.md |

## Cum folosim documentele

Acest handbook este **sursa canonică pentru oameni**: explică deciziile, motivele,
excepțiile și exemplele. AppleTeamArchitectureStandard.md este forma operațională,
compactă, pentru agenți și code review.

Fiecare decizie are un ID ARCH. Aceleași ID-uri trebuie să existe în ambele documente.
Până când varianta compactă este generată automat, orice modificare de decizie:

1. actualizează handbook-ul;
2. actualizează standardul pentru agenți în același pull request;
3. păstrează același ID ARCH;
4. actualizează changelog-ul;
5. trece verificarea CI a setului de ID-uri.

Un repo nu copiază skills sau reguli dintr-un proiect ales la întâmplare. Tooling-ul și
skills-urile vin dintr-o sursă versionată la nivel de companie, iar repo-ul înregistrează
versiunea instalată.

## Ordinea autorității [ARCH-001]

Când două reguli par să se contrazică, ordinea este:

1. cerința curentă și constrângerile produsului;
2. un ADR aprobat explicit în repo;
3. sumarul deviațiilor din AGENTS.md;
4. acest standard;
5. convenția legacy aflată în vecinătatea codului.

AGENTS.md rămâne scurt. El spune **ce diferă** și trimite la un ADR din docs/adr/ care
explică de ce, cine deține decizia și când poate fi reevaluată.

O deviație nedocumentată este un bug de proces. În același timp, standardul nu este o
scuză pentru a transforma un task mic într-un refactor amplu. Adoptăm regulile la
cusături curate — feature, flow, serviciu sau target întreg — nu într-o jumătate de
ecran.

---

## 0. Deciziile pe scurt

| ID | Zonă | Default |
|---|---|---|
| ARCH-001 | Aplicabilitate | Greenfield aplică v2. Legacy adoptă la cusături explicite; deviațiile au ADR. |
| ARCH-002 | Limbaj și UI | Swift 6 + SwiftUI pentru cod nou. UIKit rămâne la margini și în legacy. |
| ARCH-003 | Arhitectură | Feature-first modular MVVM/R. TCA este alternativă aprobată per proiect. |
| ARCH-004 | Stare | Ownership local-first, Observation pe OS 17+, ViewModel opțional, stări explicite. |
| ARCH-005 | Navigație | Rute tipizate și Router semantic; array tipizat implicit, NavigationPath doar eterogen. |
| ARCH-006 | DI | Injecție explicită prin init; AppContainer este composition root; fără default live ascuns. |
| ARCH-007 | Date | Core oferă transport; fiecare feature își deține clientul mic și maparea. |
| ARCH-008 | Persistență | UserDefaults pentru preferințe, Keychain pentru credențiale, SwiftData pentru date interogabile. |
| ARCH-009 | Configurare | Mediul este valoare injectată din xcconfig; config-ul din aplicație nu este secret. |
| ARCH-010 | Structură | Modular monolith și buildable folders; SPM doar cu motiv măsurabil. |
| ARCH-011 | Localizare | String Catalogs, literale engleze în views, LocalizedStringResource în afara lor. |
| ARCH-012 | Analytics și logging | Evenimente tipizate, providerii în spatele facade-ului, os.Logger pentru diagnostic. |
| ARCH-013 | Testare și CI | Piramidă de teste, Swift Testing, XCTest UI, snapshots selective, comenzi deterministe. |
| ARCH-014 | Design și accesibilitate | Tokens în assets, DesignSystem reutilizabil, Dynamic Type, VoiceOver și input per platformă. |
| ARCH-015 | Tooling pentru agenți | Interfață stabilă build/test/format/lint; fără editare manuală project.pbxproj. |
| ARCH-016 | Third-party | Apple-native first; owner, licență, securitate, versiune și ADR când schimbă arhitectura. |
| ARCH-017 | Legacy | Migrare în vertical slices, în ordine de dependențe, fără rescrieri speculative. |

---

## 1. Aplicabilitate și baseline tehnic [ARCH-001] [ARCH-002]

### 1.1 Proiecte greenfield

Un proiect nou pornește cu:

- Swift 6;
- complete concurrency checking;
- SwiftUI pentru UI;
- Observation pentru starea de tip referință;
- async/await pentru operații asincrone;
- Swift Testing pentru unit și integration tests;
- XCTest pentru UI tests;
- un deployment target de minimum iOS/iPadOS/tvOS 17, pentru a putea folosi
  Observation nativ.

Produsul poate alege un deployment target mai mare. Aceasta este o decizie de produs
și distribuție, nu una pe care arhitectura o ghicește.

### 1.2 Proiecte legacy sub OS 17

Dacă targetul minim nu suportă Observation, ObservableObject, Published, StateObject
și ObservedObject rămân permise **în flow-urile legacy complete**. Nu introducem un
backport improvizat și nu amestecăm mecanismele în același ecran.

Când targetul crește:

1. migrăm un flow complet;
2. actualizăm testele;
3. eliminăm vechiul mecanism din acel flow;
4. abia apoi trecem la următorul.

### 1.3 UIKit

SwiftUI este default pentru tot ce este nou, nu o interdicție dogmatică asupra UIKit.
UIKit rămâne valid:

- în ecrane legacy funcționale;
- la integrarea cu framework-uri fără echivalent SwiftUI matur;
- pentru wrappers locale prin UIViewRepresentable/UIViewControllerRepresentable;
- când un ADR și măsurători arată că SwiftUI nu satisface cerința.

Wrapper-ul izolează UIKit la margine. Business logic nu migrează în coordinator,
delegate sau view controller doar pentru că UI-ul este UIKit.

---

## 2. Arhitectura default: Feature-first MVVM/R [ARCH-003]

MVVM/R înseamnă Model, View, ViewModel și Router, dar nu înseamnă câte patru fișiere
pentru fiecare componentă. Rolurile există numai când rezolvă o problemă reală.

### 2.1 Rolurile

**Model**

- value type, de regulă Identifiable și Equatable când identitatea sau comparația
  chiar sunt necesare;
- numit după concept: HomeItem, EpisodeCard, AccountSummary;
- nu folosim fișiere generice HomeModel.swift doar ca sertar pentru tipuri fără legătură;
- un DTO, un model SwiftData și un model afișat nu devin automat trei tipuri diferite;
  separarea apare doar la o graniță reală.

**View**

- descrie UI-ul;
- citește stare;
- trimite intenția utilizatorului prin metode, closures sau bindings;
- deține layout-ul adaptiv și starea vizuală locală;
- nu face networking, persistență sau parsing de deep link.

**ViewModel**

- clasă Observable, izolată pe MainActor;
- opțional;
- deține orchestration de ecran, nu fiecare detaliu vizual;
- nu navighează și nu primește AppContainer întreg.

**Router**

- deține numai stare și tranziții de navigație;
- expune metode semantice;
- nu conține business logic, networking sau analytics de produs.

**Client**

- capabilitate îngustă necesară feature-ului;
- reprezintă cusătura cu rețea, storage sau un SDK;
- are o implementare live și fake-uri mici pentru test/preview.

### 2.2 Când creăm ViewModel [ARCH-004]

Creăm XxxViewModel când ecranul face cel puțin una dintre următoarele:

- coordonează operații async;
- transformă date în mod non-trivial;
- gestionează loading, refresh, pagination, eroare sau retry;
- ține un formular cu validări și pași;
- orchestrează timer, playback, upload sau alt side effect;
- deține stare care trebuie să supraviețuiască schimbării identității view-ului.

Nu creăm ViewModel când view-ul:

- doar afișează valori primite;
- are numai stare locală de UI;
- este un leaf component din DesignSystem;
- transmite un tap prin closure;
- ar avea un ViewModel care doar forwardează alte metode.

Un ViewModel subțire poate fi corect. Un ViewModel fără nicio decizie proprie este
boilerplate.

### 2.3 Stare local-first [ARCH-004]

| Cine deține starea | Mecanism |
|---|---|
| View, tranzitoriu | State |
| Părinte, copilul scrie | Binding |
| Ecran, referință observabilă | State care deține un tip Observable |
| Aplicație/cross-feature | Store Observable în Environment |
| Serviciu local feature-ului | Parametru explicit de initializer |

Environment este pentru dependențe și stare partajată pe o arie largă. Nu îl folosim
doar ca să evităm doi parametri.

### 2.4 LoadState fără dogmă

Pentru o singură resursă încărcată simplu:

~~~swift
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(AppError)
}
~~~

Avantajul este că loading și failed nu pot fi simultan active accidental.

Nu forțăm LoadState când ecranul are:

- conținut existent în timpul refresh-ului;
- pagination;
- mai multe resurse independente;
- stale/offline content;
- erori parțiale;
- optimistic updates.

În aceste cazuri feature-ul definește propriul State:

~~~swift
struct FeedState {
    var items: [FeedItem] = []
    var initialLoad: InitialLoadPhase = .idle
    var refresh: RefreshPhase = .idle
    var nextPage: PaginationPhase = .idle
}
~~~

Regula nu este „un singur enum cu orice preț”, ci „fără combinații imposibile și fără
stare duplicată”.

CancellationError este o încheiere normală pentru un task legat de lifecycle. Nu îl
afișăm ca eroare de produs.

### 2.5 Flux unidirecțional

Starea curge în jos, intenția în sus:

~~~text
View -> metodă pe ViewModel/Router/closure
     -> actualizare de stare
     -> View se redesenează
~~~

MVVM/R nu adaugă Action/Reducer/Store peste acest flux. Dacă proiectul are nevoie de
acest nivel de formalizare, alege TCA coerent, nu construi un TCA incomplet.

### 2.6 TCA ca alternativă

TCA este aprobat când există una sau mai multe dintre următoarele:

- state machines complexe;
- multe efecte concurente și anulări;
- offline/realtime/synchronization;
- compoziție adâncă între feature-uri;
- shared state dificil;
- nevoie ridicată de teste deterministe sau exhaustive;
- o echipă care cunoaște și acceptă costul TCA.

Decizia se ia la început sau prin ADR și spike reprezentativ. ADR-ul răspunde:

1. ce problemă rezolvă TCA;
2. de ce MVVM/R nu este suficient;
3. cine deține expertiza;
4. ce versiune/politică de upgrade folosim;
5. cum testăm și cum migrăm.

Un proiect TCA urmează convențiile Point-Free curente pentru reducers, dependencies,
navigation, Observation și TestStore. Rețetele MVVM/R de ViewModel, Router și DI nu se
aplică feature-urilor TCA.

Nu amestecăm TCA și MVVM/R în același feature. O graniță temporară este acceptabilă
numai într-o migrare documentată, cu owner și condiție de eliminare.

---

## 3. Graful de dependențe [ARCH-007] [ARCH-010]

Graful este mai important decât numele folderelor:

~~~text
App                  -> Features, Core, DesignSystem
Features             -> Core, DesignSystem
DesignSystem         -> niciun modul intern aplicației
Core                 -> nu importă App, Features sau DesignSystem
AppExtensions        -> Core și opțional DesignSystem; niciodată Features
~~~

Consecințe obligatorii:

- Core/Networking nu citește AppEnvironment;
- Core nu întoarce tipuri definite în Features;
- un serviciu de push din Core nu cheamă AppRouter;
- networking-ul nu modifică direct SessionStore;
- DesignSystem nu pornește request-uri și nu citește sesiunea;
- App este singurul loc care cunoaște toate implementările concrete.

### 3.1 Forma composition root-ului

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

Un payload extern urmează direcția inversată:

~~~text
push URL/payload -> Core parser -> NavigationIntent -> AppRouter
HTTP 401         -> AuthFailure -> Session orchestration din App
~~~

Core produce valori tipizate; App decide ce efect au în aplicație.

---

## 4. Structura de foldere [ARCH-010]

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
│   │   ├── HomeViewModel.swift       # opțional
│   │   ├── HomeRoute.swift           # opțional
│   │   ├── HomeClient.swift          # dacă există I/O
│   │   ├── HomeItem.swift
│   │   ├── Data/                     # DTO + mapping când e necesar
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
│   └── skills.yml
├── skills.lock                   # dacă distribuția suportă lock
├── AGENTS.md
└── Makefile
~~~

Înlocuim folderul vag Managers cu Stores sau Services și un subfolder semantic.
Utils rămâne mic. Dacă un helper crește, primește numele conceptului pe care îl
implementează.

### 4.2 Regula de promovare

Totul pornește cât mai aproape de feature-ul care îl deține. Mutăm în Core sau
DesignSystem când:

- apare al doilea consumator real;
- un app extension are nevoie de aceeași capabilitate;
- există o limită de platformă;
- o decizie de produs definește un token/component global.

Nu construim shared code pentru consumatori ipotetici.

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

Shared este stratul headless cross-platform. Poate conține ViewModels și Observation,
dar nu view-uri specifice platformei. Divergența mare de interacțiune produce view-uri
separate peste aceeași logică.

Tipurile exclusiv tvOS au prefix TV. Tipurile shared și iOS nu primesc prefix de
platformă.

### 4.4 App extensions

Widgets, Live Activities și notification services:

- au entry point și resurse proprii;
- pot depinde de Core/Shared și DesignSystem;
- nu importă Features;
- citesc date comune printr-un App Group container în spatele unui protocol;
- nu importă direct store-urile runtime ale aplicației.

---

## 5. Dependency injection și configurare [ARCH-006] [ARCH-009]

### 5.1 Dependențe explicite

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

Nu folosim:

~~~swift
init(client: any HomeClient = .live)
~~~

Un default live ascunde dependența, ocolește AppContainer și poate porni rețeaua în
teste sau previews. Producția trebuie să construiască explicit sistemul live.

### 5.2 AppContainer

AppContainer:

- primește AppEnvironment ca valoare;
- construiește HTTPClient, stores, services și feature clients;
- este composition root, nu service locator;
- nu este injectat ca obiect gigantic în fiecare feature;
- oferă dependențe înguste la punctul de creare a feature-ului.

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
        // parsează și validează o singură dată la startup
    }
}
~~~

AppEnvironment nu are current global. App îl creează la root și îl pasează către
AppContainer. Core primește numai valorile concrete de care are nevoie.

### 5.4 xcconfig, target-uri și secrete

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

Mediile sunt diferențe de configurație, nu de cod:

~~~text
xcconfig -> $(VARIABLE) în Info.plist -> AppEnvironment -> AppContainer
~~~

Reguli:

- #if QA / #if STAGING este interzis;
- #if os(...) este permis pentru diferențe reale de API/platformă;
- #if DEBUG este permis doar pentru tooling local și preview support;
- QA poate avea un debug menu injectat ca implementare, fără ramură compilată;
- feature flags sunt tipizate și injectate.

Info.plist și xcconfig sunt vizibile în binar. Ele pot conține bundle ID, base URL și
config public, dar **niciodată un secret**. Un secret necesar pentru autorizare rămâne
pe server. Tokenurile utilizatorului stau în Keychain.

---

## 6. Layerul de date și persistența [ARCH-007] [ARCH-008]

### 6.1 Core oferă transport, feature-ul oferă capabilitatea

Core/Networking se ocupă de:

- URLSession;
- request building;
- validarea răspunsului;
- auth headers printr-un credential provider injectat;
- retry și cancellation policy;
- erori de transport tipizate;
- telemetry operațională;
- decoding primitives.

Feature-ul deține endpoint contract și maparea:

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

Nu există un ApiServiceProtocol global cu toate endpoint-urile aplicației. Protocoalele
se împart după capabilitate sau feature, astfel încât un test să nu implementeze metode
fără legătură cu subiectul lui.

Transportul nu se scurge:

- fără import Apollo/Alamofire în View sau ViewModel;
- fără tipuri GraphQL generate în prezentare;
- fără raw JSON sau HTTP status interpretat în feature;
- fără modele SwiftData folosite ca DTO-uri.

### 6.2 Domain layer

Domain nu este un folder obligatoriu. Îl introducem prin ADR când există:

- invariants de business partajate;
- calcule critice care trebuie testate independent;
- use cases cross-feature;
- workflow-uri offline;
- aceeași logică pe mai multe platforme/produse;
- nevoia de a proteja business rules de UI, transport și storage.

Lipsa folderului Domain nu înseamnă lipsa business logic. Pentru o regulă locală,
ViewModel-ul sau un feature service poate fi locul potrivit. Când regulile se repetă
sau devin critice, promovăm conceptul.

### 6.3 Repository

Repository nu este obligatoriu și nici interzis. Își câștigă locul când deține o
politică, nu doar când redenumește un apel:

- combină network și local storage;
- decide cache freshness;
- implementează offline-first;
- sincronizează și rezolvă conflicte;
- oferă query contract stabil business-facing;
- coordonează mai multe surse sau versiuni.

Un wrapper care doar cheamă HomeClient.loadHome nu este Repository util.

### 6.4 Persistență

| Tip de date | Mecanism |
|---|---|
| Preferințe/flags mici | UserDefaults sau AppStorage prin store-ul owner |
| Tokenuri/credențiale | Keychain prin protocol |
| Modele locale interogabile | SwiftData default |
| Cache temporar HTTP/media | client/cache dedicat |
| Secret de server | nu se livrează în aplicație |

ModelContainer se construiește în App. Ecranele SwiftData simple pot folosi Query
direct. Când apar business rules, sincronizare sau testare complexă, feature-ul
folosește un client/store de persistență injectat.

### 6.5 Auth failures

Networking-ul nu modifică direct SessionStore. Fluxul este:

~~~text
HTTPClient detectează 401 nerecuperabil
    -> aruncă AuthFailure.sessionExpired
    -> orchestration layer din App actualizează SessionStore
    -> RootView observă sesiunea
    -> AppRouter schimbă flow-ul
~~~

Alternativ, HTTPClient primește un AuthFailureHandler protocol definit la o graniță
headless, iar implementarea care cunoaște SessionStore este construită în App. În
ambele variante, Core nu importă Router sau UI.

---

## 7. Stare, comunicare și Swift Concurrency [ARCH-002] [ARCH-004]

### 7.1 Ownership înainte de wrapper

Înainte să alegem State, Binding sau Environment, răspundem:

1. cine este owner-ul unic;
2. cât timp trebuie să trăiască starea;
3. cine o citește;
4. cine o poate modifica;
5. este stare curentă sau eveniment one-shot?

Majoritatea bug-urilor de data flow vin din ownership ambiguu, nu din alegerea
property wrapper-ului greșit.

### 7.2 Store-uri globale

Starea cross-feature, precum sesiunea, favoritele sau progresul download-urilor,
trăiește într-un store Observable izolat pe MainActor.

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

Store-ul:

- este creat o singură dată în App;
- este injectat în Environment;
- primește dependențele prin init;
- nu are static shared;
- expune stare curentă, nu notificări cu stringuri;
- rămâne concentrat pe un singur domeniu de stare.

Nu injectăm un AppStore universal care conține toată aplicația într-un proiect MVVM/R.
Dacă apare nevoia unui store reducer global, reevaluăm dacă proiectul ar trebui să fie
TCA.

### 7.3 Stare versus eveniment

**Stare:** un view care apare acum are nevoie de valoarea curentă.

Exemple: sesiune, favorite, progres, conectivitate, feature flags.

**Eveniment:** un fapt one-shot fără valoare curentă semnificativă.

Exemple: URL extern primit, cerere de scroll-to-top, rezultat de sistem consumat o
singură dată.

Starea devine proprietate observabilă. Evenimentul extern devine intent tipizat sau
AsyncSequence la margine. Nu simulăm event bus cu NotificationCenter custom.

### 7.4 Cum comunică view-urile

~~~text
părinte -> copil       valoare; Binding doar pentru write-back
copil -> părinte       closure sau Binding
frați                  ridică starea la owner-ul comun
cross-feature          store Observable cu ownership explicit
sistem extern          adapter Core -> valoare/event tipizat
~~~

Un ViewModel nu se abonează implicit la tot store-ul global. Primește capabilitatea sau
valoarea necesară. Pentru un reload legat de lifecycle, view-ul poate coordona:

~~~swift
.task(id: sessionStore.state.userID) {
    await viewModel.reload(for: sessionStore.state.userID)
}
~~~

Task-ul este anulat automat la schimbarea identității sau dispariția view-ului.

### 7.5 Izolarea actorilor

Pentru proiecte greenfield:

- targeturile App/UI folosesc default MainActor isolation atunci când toolchain-ul îl
  suportă;
- ViewModels, Routers și UI stores sunt MainActor;
- value types care traversează granițe sunt Sendable;
- serviciile cu stare mutabilă partajată folosesc actor sau altă izolare explicită;
- pachetele locale declară explicit setările de concurență, nu presupun că le moștenesc.

Un func async nu înseamnă „rulează în background”. Operația poate suspenda fără să
blocheze actorul, dar codul sincron dintre await-uri rulează în contextul de izolare
stabilit de toolchain și declarații.

Nu marcăm toate serviciile nonisolated mecanic. Folosim nonisolated pentru API-uri
stateless/pure care chiar trebuie chemate din mai multe domenii. Pentru muncă CPU
intensivă folosim execuție concurentă explicită doar după ce volumul o justifică.

Evităm Task.detached. Este permis numai când:

- task-ul trebuie intenționat desprins de lifecycle;
- valorile capturate sunt Sendable;
- ownership-ul rezultatului și anularea sunt documentate;
- există test sau motiv măsurabil.

### 7.6 Erori și cancellation

Separăm:

- eroarea de transport;
- eroarea de business;
- mesajul localizat pentru utilizator;
- diagnosticul pentru Logger/crash reporting.

Un ViewModel mapează eroarea într-un AppError sau feature error testabil. Nu afișăm
error.localizedDescription direct ca text de produs.

CancellationError:

- nu este raportată ca incident;
- nu produce toast;
- nu schimbă o stare validă într-o eroare;
- curăță resursele și încheie operația.

---

## 8. Navigație, deep links și push [ARCH-005]

### 8.1 Typed routes

Pentru un flow omogen:

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

Folosim un array tipizat deoarece route enum-ul este omogen. NavigationPath este
rezervat stack-urilor care trebuie intenționat să conțină tipuri diferite.

Rutele transportă identificatori stabili și mici. Nu transportă view-uri, ViewModels
sau grafuri mari de modele.

### 8.2 Flow ownership

- fiecare tab are NavigationStack și history propriu dacă produsul așteaptă istorii
  independente;
- feature router-ul deține flow-ul local;
- AppRouter deține root switching, tab selection și delegarea deep link-urilor;
- Router-ul nu decide permisiuni, eligibilitate sau reguli de business;
- schimbarea contului/resursei poate reseta explicit path-ul relevant.

View-urile folosesc metode semantice precum showDetails(id:), nu path.append răspândit
în zeci de fișiere.

### 8.3 Sheets

Folosim item/enum state pentru prezentări mutual exclusive:

~~~swift
enum HomeSheet: Identifiable {
    case filters
    case share(itemID: String)
}
~~~

Un sheet pur local rămâne în view. Îl mutăm în Router numai când:

- face parte din flow;
- trebuie controlat de deep link;
- trebuie restaurat;
- un părinte trebuie să îl coordoneze.

Nu transformăm Router-ul într-un inventar al fiecărui popover local.

### 8.4 Deep links

~~~text
URL brut
 -> DeepLinkParser
 -> Result<NavigationIntent, DeepLinkError>
 -> AppRouter.handle(intent:)
~~~

Parser-ul este pur și testabil. AppRouter nu parsează stringuri în onOpenURL.

Pentru link necunoscut sau malformat:

- logăm fără date sensibile;
- ignorăm sigur sau afișăm o stare explicită de link nesuportat;
- nu navigăm silențios către un ecran fără legătură.

### 8.5 Push notifications

Serviciul din Core decodează payload-ul într-un NotificationIntent. El nu importă și
nu cheamă AppRouter.

~~~text
UNUserNotification payload
 -> NotificationIntentParser din Core
 -> NotificationIntent
 -> App-level handler
 -> AppRouter
~~~

Delegate-ul de sistem rămâne subțire și nu conține business logic.

---

## 9. Design system, layout și accesibilitate [ARCH-014]

### 9.1 DesignSystem

În asset catalog/tokens stau:

- culori semantice;
- fonturi și text styles;
- imagini și symbols custom;
- spacing/radius/elevation când produsul le standardizează.

În DesignSystem stau componentele cu minimum doi consumatori reali sau definite
explicit ca primitive de produs.

O componentă DesignSystem:

- nu importă networking, session sau feature models;
- primește valori și closures;
- are preview pentru stările și dimensiunile importante;
- are API mic și semantic;
- nu ghicește layout-ul întregului ecran.

### 9.2 Layout adaptiv

Size classes, container size și platform input stau în Views. ViewModel-ul nu știe
orientare, screen width sau focus engine.

Diferențe:

1. o diferență punctuală de API: #if os(...) local;
2. mai multe diferențe în același view: metode/extensii per platformă;
3. model de interacțiune diferit: view-uri separate peste logică partajată.

### 9.3 Baseline de accesibilitate

Orice feature nou verifică:

- Dynamic Type, inclusiv dimensiuni mari;
- VoiceOver label/value/hint pentru controale non-textuale;
- ordinea logică a focusului;
- contrast și diferențiere care nu depinde doar de culoare;
- Reduce Motion și Reduce Transparency unde animația/materialul contează;
- target-uri de interacțiune confortabile;
- focus și remote pe tvOS;
- keyboard/pointer pe iPadOS când flow-ul beneficiază.

Accessibility identifiers sunt pentru teste stabile. Ele nu înlocuiesc labels
semantice pentru utilizator.

---

## 10. Localizare și copy [ARCH-011]

Folosim String Catalogs ca sursă de adevăr.

În Views:

~~~swift
Text("Continue Watching")
Button("Try Again") { ... }
~~~

Literalul englez este cheia și textul sursă. Nu folosim un AppStrings.swift gigantic
și nici chei punctate fără valoare semantică vizibilă.

În afara Views:

~~~swift
let message: LocalizedStringResource
~~~

Reguli importante:

- adăugăm comentariu pentru traducător când sensul este ambiguu;
- folosim pluralizare și interpolare suportate de catalog;
- formatăm date, măsuri, monede și numere cu FormatStyle;
- verificăm RTL pentru layout-urile relevante;
- o schimbare de copy în engleză poate crea o cheie nouă, deci PR-ul verifică impactul
  asupra traducerilor;
- nu construim propoziții localizate concatenând fragmente.

Un catalog per app este default. Pachetele reutilizabile pot avea catalog propriu când
au resurse și ownership independent.

---

## 11. Analytics, logging și crash reporting [ARCH-012]

### 11.1 Analytics

Un facade tipizat ascunde Firebase, Datadog sau alt provider:

~~~swift
protocol AnalyticsClient: Sendable {
    func track(_ event: AnalyticsEvent) async
}
~~~

Evenimentele:

- sunt enum-uri/structuri tipizate;
- trăiesc lângă feature-ul owner;
- nu folosesc raw [String: Any] în feature;
- au naming și parametri stabili;
- nu conțin PII fără aprobare și documentare.

Business events sunt emise unde rezultatul devine adevărat. Networking-ul nu emite
purchaseCompleted doar pentru că un request a întors 200.

Screen tracking folosește un modifier/helper comun care definește dacă reapariția
aceluiași view se numără din nou. Un onAppear brut poate dubla evenimente în SwiftUI.

### 11.2 Logging

Folosim os.Logger cu:

- subsystem-ul aplicației;
- categorii semantice: networking, auth, persistence, playback, navigation;
- niveluri potrivite;
- privacy annotations.

Nu folosim print în production paths. Nu logăm:

- tokenuri;
- parole;
- payload-uri complete cu date personale;
- informații de plată;
- imagini/documente ale utilizatorului;
- URL-uri semnate complete.

### 11.3 Trei canale diferite

Nu confundăm:

- mesajul către utilizator;
- log-ul tehnic;
- evenimentul analytics.

Crash/error monitoring are facade separat. Un catch poate:

1. raporta diagnosticul sanitizat;
2. mapa într-o eroare de feature;
3. actualiza UI-ul;

dar fiecare pas are un scop distinct și poate fi testat.

---

## 12. Testare, previews și CI [ARCH-013]

### 12.1 Piramida de teste

1. **Unit tests multe și rapide**
   ViewModels, state transitions, mappers, parsers, business rules.

2. **Integration tests mai puține**
   HTTP adapters cu URLProtocol/fake transport, persistence in-memory, feature-uri
   compuse și contracte între straturi.

3. **UI tests puține și valoroase**
   Login, checkout, playback, creare/editare, deep link sau alte journey-uri critice.

4. **Performance tests**
   Numai pentru hot paths măsurate: launch, scrolling, parsing mare, media pipeline.

Swift Testing este default pentru unit/integration tests noi. XCTest rămâne pentru
XCUITest și pentru testele legacy care nu merită migrate mecanic.

### 12.2 Ce testăm într-un feature

Pentru un feature async tipic:

- success;
- empty;
- mapped business failure;
- transport failure;
- retry;
- cancellation;
- răspuns întârziat după schimbarea inputului;
- stare inițială și identitate stabilă;
- analytics/business event când este relevant.

Fake-urile sunt înguste și deterministe. Nu folosesc sleep real și nu fac request-uri
live.

### 12.3 Previews

Preview obligatoriu pentru:

- fiecare screen;
- fiecare componentă reutilizabilă din DesignSystem;
- loading, loaded, empty și error când există;
- stări accessibility relevante.

Un leaf view privat trivial nu are nevoie de preview separat.

Preview-urile folosesc date sintetice. Niciodată copii de payload-uri sau date de
client/producție.

Preview-only code nu ajunge în Release. Folosim:

- un support target/module exclus din shipping; sau
- o graniță DEBUG revizuită pentru tooling local.

Test doubles care nu sunt necesare preview-urilor rămân în Tests/Support.

### 12.4 Snapshot testing

Snapshots sunt selective:

- tokens și componente DesignSystem stabile;
- ecrane cu risc vizual mare;
- bug-uri vizuale care au recidivat;
- layout-uri platformă/locale/dynamic type unde imaginea aduce valoare.

Nu snapshot-uim fiecare View. Harness-ul fixează device, OS policy, locale, calendar,
time zone, color scheme și content size. Alegerea librăriei este companie/repo policy,
nu dependență adăugată unilateral de un feature PR.

### 12.5 Interfața de comenzi

Fiecare repo nou oferă:

~~~text
make bootstrap   # numai dacă există setup
make build
make test
make test-ui
make format
make lint
~~~

Implementarea poate chema xcodebuild, Xcode MCP sau scripts, dar interfața rămâne
stabilă pentru oameni și agenți.

AGENTS.md documentează:

- scheme;
- simulator/destination;
- Xcode/Swift version;
- variabile necesare;
- durata aproximativă;
- comenzile rapide per feature;
- cum se citesc xcresult/logurile.

### 12.6 Baseline CI

Orice pull request verifică:

- dependency resolution curat;
- build pentru toate app/extension targets livrate;
- unit și integration tests;
- format și lint;
- lipsa warning-urilor noi;
- validarea fișierelor generate;
- setul de UI tests stabilit de repo.

Testele UI scumpe pot fi împărțite între PR și nightly, dar journey-urile cele mai
critice trebuie să aibă un semnal înainte de merge.

CI trebuie să ruleze din clean checkout, nu din DerivedData local.

---

## 13. Xcode, module și dependențe externe [ARCH-010] [ARCH-015] [ARCH-016]

### 13.1 Modular monolith ca default

Folderele feature-first și graful de dependențe sunt suficiente la început pentru
majoritatea aplicațiilor. Nu creăm un package pentru fiecare ecran.

Extragem într-un modul SPM local când există cel puțin un motiv măsurabil:

- build time sau test isolation se îmbunătățesc;
- feature-ul are ownership/release boundary independent;
- același cod este folosit de app și extension;
- același cod este folosit în mai multe produse;
- review-ul nu mai poate impune fiabil direcția dependențelor;
- există un boundary tehnic real, nu doar dorința de foldere mai multe.

În ADR notăm motivul, graful targeturilor și impactul asupra buildului.

### 13.2 Buildable folders și project.pbxproj

Proiectele noi folosesc buildable folder references unde este potrivit, astfel încât
adăugarea unui fișier să nu producă permanent conflicte în project.pbxproj.

Reguli pentru agenți și developeri:

- nu edita manual project.pbxproj;
- folosește buildable folders, Xcode sau generatorul oficial al repo-ului;
- project generation trebuie să fie determinist;
- schimbările generate se inspectează înainte de commit;
- nu rezolva un conflict pbxproj prin ștergerea intrărilor necunoscute;
- nu modifica signing/entitlements/capabilities în afara scope-ului.

### 13.3 Third-party dependencies

Preferăm API-uri Apple când satisfac cerința rezonabil. O dependență externă nouă
necesită:

1. nevoie clară și alternative evaluate;
2. owner intern;
3. licență compatibilă;
4. activitate și mentenanță acceptabile;
5. evaluare security/privacy proporțională cu datele accesate;
6. politică de versiune și upgrade;
7. Package.resolved committed pentru aplicații;
8. ADR dacă schimbă arhitectura, state management-ul, networking-ul, navigația sau
   persistența;
9. o notă de exit/migrare pentru dependențele structurale.

Nu adăugăm DI framework, router framework, networking wrapper sau state framework doar
pentru reducerea câtorva linii.

TCA este o dependență structurală aprobată numai prin decizia din ARCH-003.

### 13.4 Dependențe binare și SDK-uri

Pentru SDK-uri analytics, ads, payments sau media:

- adapter în Core/Services sau Core/Analytics;
- feature-urile nu importă SDK-ul;
- inițializarea se face în App;
- privacy manifest și required reason APIs sunt verificate;
- tracking-ul este controlat de consimțământ și config;
- comportamentul fără SDK/consimțământ are implementare no-op testabilă.

---

## 14. Tooling și lucru cu agenți AI [ARCH-015]

### 14.1 Ce trebuie să găsească un agent în primele minute

AGENTS.md trebuie să răspundă rapid:

- ce produs și target modific;
- care este arhitectura;
- care sunt deviațiile locale;
- unde se află feature-ul;
- ce comandă construiește;
- ce comandă testează;
- ce simulator folosesc;
- ce fișiere nu modific;
- care este definiția de done.

AGENTS.md nu duplică întregul handbook. El rezumă repo-ul și trimite la standard,
skills și ADR-uri.

### 14.2 Skill Map canonic

Standardul ARCH spune **ce arhitectură și ce limite folosim**. Un skill spune **cum
executăm corect o activitate specializată**. Skill-ul nu poate schimba implicit o
decizie ARCH.

| Activitate | Skill canonic | Când este obligatoriu |
|---|---|---|
| Ecran, state sau navigație SwiftUI | apple/swiftui-patterns | Orice task relevant |
| Restructurarea unui View SwiftUI | apple/swiftui-refactoring | Refactorizare de View |
| Diagnostic rendering/performance | apple/swiftui-performance | Audit sau problemă de performanță |
| Izolare Swift 6, actori, Sendable | apple/swift-concurrency | Orice schimbare de concurență |
| Teste unit/integration sau migrare | apple/swift-testing | Orice task de testare |
| Build, Simulator, logs, runtime debugging | apple/ios-runtime-debugging | Orice verificare runtime |
| SwiftData schema/query/migration | apple/swiftdata | Orice schimbare de persistență SwiftData |
| Implementare/review de UI | apple/apple-accessibility | Pas obligatoriu pentru UI |
| Modernizare UIKit | apple/uikit-modernization | Migrare de UI legacy |
| Feature TCA | apple/tca | Numai în proiecte TCA |
| App Intents, Shortcuts, Siri, Spotlight | apple/app-intents | Integrare cu system intents |

Folosim cel mai mic set care acoperă task-ul. Un ecran SwiftUI care adaugă SwiftData
și App Intents poate necesita trei skills; un rename de tip nu necesită toate
skills-urile Apple.

ID-urile din tabel sunt independente de tool. Codex, Claude, Kiro sau alt runtime pot
expune nume diferite. Maparea concretă se află în AGENTS.md, fără căi absolute către
cache-uri sau home directory.

### 14.3 Manifest și versiuni

Fiecare repo declară skills-urile într-un fișier machine-readable:

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

Unde sistemul de distribuție permite, skills.lock fixează versiunile rezolvate.

Un skill canonic:

- vine din registry/repo de companie;
- are owner, versiune și changelog;
- declară compatibilitatea Swift/Xcode/deployment target;
- are comandă documentată de instalare/update;
- nu este copiat manual din „un proiect asemănător”;
- nu poate schimba o decizie ARCH fără actualizarea standardului.

CI verifică:

- manifest valid;
- skills baseline prezente;
- versiuni în politica acceptată;
- lock sincronizat cu manifestul;
- lipsa ID-urilor necunoscute sau a căilor locale.

AGENTS.md conține maparea runtime:

~~~text
Canonical skill                 Installed capability       Version
apple/swiftui-patterns          <tool-specific name>       <resolved>
apple/swift-concurrency         <tool-specific name>       <resolved>
apple/swift-testing             <tool-specific name>       <resolved>
~~~

### 14.4 Precedență și lipsa unui skill

Dacă un skill și standardul se contrazic:

1. decizia ARCH câștigă;
2. conflictul se raportează owner-ului skill-ului;
3. skill-ul se corectează upstream;
4. nu creăm un fork local tăcut.

Dacă skill-ul obligatoriu nu este disponibil:

1. agentul/developerul raportează tooling gap-ul;
2. urmează standardul și documentația Apple/Swift primară curentă;
3. nu inventează o convenție incompatibilă;
4. notează lipsa în handoff;
5. instalarea skill-ului se repară separat de feature, dacă ar extinde scope-ul.

Lipsa unui skill nu blochează automat un fix urgent, dar reduce nivelul de verificare
pe care îl putem pretinde.

### 14.5 Reguli operaționale pentru agenți

Un agent:

- inspectează codul și convențiile din feature înainte de editare;
- păstrează modificările utilizatorului din worktree;
- lucrează în scope;
- nu extinde refactorul fără autorizare;
- nu modifică manual project.pbxproj;
- folosește dependențe explicite și fake-uri deterministe;
- construiește și testează proporțional cu riscul;
- raportează separat ce a fost verificat local și ce nu;
- nu declară runtime/producție verificată doar pentru că build-ul local trece;
- documentează deviația arhitecturală prin ADR.

### 14.6 Definition of done pentru o schimbare

- feature-ul respectă graful de dependențe;
- AppContainer face wiring-ul live explicit;
- build-ul trece cu comanda repo-ului;
- testele relevante trec;
- previews importante compilează;
- success, empty, failure, retry și cancellation au fost evaluate;
- accesibilitatea și localizarea au fost evaluate;
- format/lint au rulat;
- nu au intrat secrete sau date reale în fixtures;
- nu au fost adăugate side effects live în tests/previews;
- orice deviație are ADR și sumar în AGENTS.md.

---

## 15. Legacy și migrare [ARCH-017]

### 15.1 Principiul vertical slice

Migrăm:

- un ecran complet;
- un flow complet;
- un serviciu cu toți consumatorii lui;
- un target sau boundary clar.

Nu migrăm:

- jumătate de ViewModel;
- o proprietate Observation într-un obiect încă dominat de Combine;
- Router peste un flow în care coordinatorul continuă să ia deciziile;
- Swift 6 fără să rezolvăm izolarea shared state.

### 15.2 Ordinea recomandată

1. **Igienă mecanică**
   Naming, fișiere gigant, assets, buildable folders, proiect determinist.

2. **Caracterizare și seam**
   Testează comportamentul existent și definește boundary-ul schimbării.

3. **Completion handlers spre async/await**
   În servicii, cu cancellation și erori tipizate.

4. **ObservableObject spre Observation**
   Numai pentru flow-uri complete și target OS compatibil.

5. **Singletoni mutabili spre ownership explicit**
   Stores/services create în App și injectate.

6. **Strict concurrency**
   Targeted, reparare warnings, apoi complete.

7. **Swift language mode 6**

8. **Coordinator spre Router/NavigationStack**
   Numai când flow-ul este SwiftUI complet.

### 15.3 Când păstrăm temporar pattern-ul local

Îl păstrăm dacă:

- schimbarea ar extinde material scope-ul;
- nu există un seam sigur;
- testele lipsesc și comportamentul este critic;
- deployment targetul nu permite standardul;
- migrarea ar fragmenta flow-ul.

ADR-ul notează:

- motivul;
- riscul;
- boundary-ul viitor;
- owner-ul;
- condiția de reevaluare.

Boy-scout improvements mici și sigure sunt binevenite, dar nu ascundem refactoruri
mari într-un feature PR.

---

## 16. Guardrails — ce nu facem deliberat

### Arhitectură și ownership

- nu creăm ViewModels goale;
- nu introducem un AppStore universal într-un proiect MVVM/R;
- nu punem business logic în Router, AppDelegate sau View;
- nu creăm singletoni mutabili noi;
- nu injectăm AppContainer întreg în features;
- nu introducem Domain/Repository ca ritual;
- nu interzicem Domain/Repository când există politică reală.

### Date și configurare

- nu creăm un ApiServiceProtocol cu toate endpoint-urile;
- nu expunem DTO-uri/GraphQL/Alamofire/Apollo către UI;
- Core nu citește AppEnvironment;
- Core nu cheamă AppRouter;
- networking-ul nu modifică SessionStore;
- nu folosim #if QA;
- nu punem secrete în source, plist sau xcconfig;
- nu stocăm tokenuri în UserDefaults/SwiftData.

### SwiftUI și navigație

- nu folosim NavigationPath pentru un route enum omogen fără motiv;
- nu stocăm view-uri sau modele mari în path;
- nu mutăm fiecare sheet local în Router;
- nu pornim request-uri din body;
- nu duplicăm aceeași stare în mai multe proprietăți;
- nu folosim AnyView ca soluție implicită la design slab.

### Teste și tooling

- nu facem request-uri live în unit tests/previews;
- nu folosim date reale de client în fixtures;
- nu snapshot-uim fiecare view;
- nu adăugăm unilateral o librărie de snapshots;
- nu edităm manual project.pbxproj;
- nu copiem skills neverificate din alt repo;
- nu declarăm done fără build/test proporțional cu riscul.

---

## 17. Cookbook: răspunsuri fără ambiguitate

### 17.1 Unde pun tipul?

| Scriu | Loc |
|---|---|
| Ecran SwiftUI | Features/Feature/NameView.swift |
| Orchestration de ecran | Features/Feature/NameViewModel.swift |
| Tip afișat | Features/Feature/ConceptName.swift |
| Rută locală | Features/Feature/NameRoute.swift |
| Router local | Features/Feature/NameRouter.swift |
| Client de capabilitate | Features/Feature/NameClient.swift |
| Adapter live al clientului | Features/Feature/LiveNameClient.swift sau Data/ |
| DTO/mapare endpoint | Features/Feature/Data/ |
| HTTP generic | Core/Networking/ |
| Sesiune/favorite/download state | Core/Stores/ConceptStore.swift |
| Integrare sistem/SDK | Core/Services/Capability/ |
| Analytics facade | Core/Analytics/ |
| Logging helpers | Core/Logging/ |
| SwiftData models/store | Core/Persistence/ |
| Componentă UI cu 2+ consumatori | DesignSystem/ |
| Componentă UI cu un consumator | Features/Feature/Components/ |
| Fixture preview | PreviewSupport/ |
| Fake numai pentru teste | Tests/Support/ |
| Startup și wiring | App/ |
| Parser deep link | App/Navigation/ sau parser headless consumat de App |
| Config public per mediu | Config/*.xcconfig -> AppEnvironment |
| Excepție arhitecturală | docs/adr/ + sumar AGENTS.md |

### 17.2 Cum construiesc un feature API-backed?

1. Definește HomeItem și HomeClient în feature.
2. Folosește HTTPClient din Core pentru transport.
3. Definește DTO numai dacă payload-ul diferă de model.
4. Implementează LiveHomeClient.
5. Injectează clientul explicit în HomeViewModel.
6. AppContainer construiește varianta live.
7. Tests/Support oferă fake-ul unit testului.
8. PreviewSupport oferă date sintetice pentru preview.
9. Testează success, empty, failure, retry și cancellation.

### 17.3 Cum adaug stare globală?

Întreabă mai întâi dacă este cu adevărat globală. Dacă da:

1. definește un store semantic, nu GlobalManager;
2. fă-l Observable și MainActor;
3. injectează dependențele;
4. creează-l în App;
5. injectează-l prin Environment;
6. view-urile citesc numai proprietățile necesare;
7. sparge store-ul când domeniile de stare nu au același lifecycle.

### 17.4 Cum reacționez la 401?

Nu chema Router-ul din networking:

1. încearcă refresh în auth layer dacă politica permite;
2. la eșec definitiv produce AuthFailure.sessionExpired;
3. app/session orchestration actualizează SessionStore;
4. RootView/AppRouter schimbă flow-ul;
5. loghează tehnic fără token/payload;
6. testul verifică tranziția.

### 17.5 Cum adaug un deep link?

1. extinde NavigationIntent;
2. extinde parser-ul pur;
3. adaugă teste pentru valid, invalid și lipsă de parametri;
4. AppRouter consumă intentul;
5. rutele păstrează numai ID-uri;
6. definește comportamentul când resursa nu există sau userul nu este autentificat.

### 17.6 Cum decid MVVM/R versus TCA?

Alege MVVM/R dacă aplicația este predominant API/CRUD, cu flow-uri standard și state
locală. Alege TCA dacă state machine-ul, efectele concurente, offline/realtime și
compoziția sunt probleme centrale. Nu alege TCA doar pentru uniformitate și nu îl
respinge doar pentru că are mai multe concepte.

Rulează un spike pe cel mai reprezentativ flow, nu pe un counter demo.

### 17.7 Cum decid dacă extrag un package?

Măsoară:

- clean build și incremental build;
- timpul testelor;
- ownership-ul echipei;
- reutilizarea app/extension/product;
- numărul de încălcări ale grafului.

Dacă motivul este numai „arată mai curat”, păstrează folderul.

---

## 18. Checklist de review arhitectural

### Feature

- ownership-ul stării este clar;
- ViewModel-ul există numai dacă are logică;
- clientul este îngust;
- nu există dependență către alt feature;
- transportul nu se scurge;
- Router-ul nu are business logic.

### Concurrency

- izolarea MainActor este corectă;
- tipurile de boundary sunt Sendable;
- cancellation este tratată;
- nu există Task.detached fără motiv;
- munca CPU grea nu este pusă accidental în UI path.

### Prod și securitate

- config-ul injectat nu este tratat ca secret;
- tokens merg în Keychain;
- logs nu conțin date sensibile;
- analytics respectă consimțământul;
- mocks/preview data nu ajung necontrolat în Release.

### Calitate

- build/test/format/lint trec;
- previews importante funcționează;
- accesibilitatea este verificată;
- copy-ul este localizabil;
- orice dependență sau deviație are aprobarea necesară.

---

## 19. Guvernanța standardului

### Owner și review

Apple Platform Team deține documentul. Orice developer poate propune o schimbare prin
ADR/RFC scurt care include:

- problema observată;
- exemple din minimum un repo;
- schimbarea propusă;
- costul de migrare;
- impactul asupra agenților/tooling-ului;
- planul de rollout.

### Statusuri

- Proposed: în review, nu este obligatoriu;
- Accepted: default pentru proiecte noi;
- Deprecated: nu se mai introduce;
- Superseded: înlocuit de alt ID/versiune.

### Changelog v2.1

- a introdus Skill Map-ul canonic task-to-skill;
- a separat ID-urile canonice de numele specifice Codex/Claude/Kiro;
- a adăugat tooling/skills.yml și skills.lock;
- a definit verificarea CI pentru skills și versiuni;
- a definit precedența ARCH versus skill;
- a documentat fallback-ul când un skill obligatoriu lipsește.

### Changelog v2.0

- a separat HTTP transportul Core de clienții feature-specific;
- a eliminat ApiServiceProtocol global;
- a făcut DI-ul live explicit, fără default ascuns;
- a eliminat AppEnvironment.current din Core;
- a inversat integrarea push/auth prin intents și erori tipizate;
- a introdus excepția explicită pentru legacy sub OS 17;
- a făcut LoadState un default pentru încărcări simple, nu o obligație universală;
- a preferat array tipizat pentru route enum omogen;
- a definit test pyramid, previews și snapshots selective;
- a stabilit baseline CI și comenzile pentru agenți;
- a adăugat logging, accessibility și third-party policy;
- a introdus buildable folders și interdicția editării manuale project.pbxproj;
- a definit criterii pentru Domain, Repository, SPM și TCA;
- a separat AGENTS.md de ADR și a introdus sync prin ID-uri ARCH.

---

Standardul este un default care reduce deciziile repetitive. Când realitatea produsului
îl contrazice, nu ascundem excepția și nu aplicăm regula mecanic: măsurăm, documentăm
și schimbăm standardul dacă excepția devine noul caz comun.
