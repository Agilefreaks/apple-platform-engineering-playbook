# Figma Definition of Ready Checklist

Se completează pentru fiecare delivery item cu UI. Pentru un item fără UI, se bifează
doar declarația `UI not required`, cu motiv și aprobarea Product + Engineering.

## Identitate

| Câmp | Valoare |
|---|---|
| Delivery ID | |
| Design owner | |
| Engineering owner | |
| Figma file URL/key | |
| Page / flow | |
| Exact node IDs | |
| Named version sau reviewed timestamp | |
| Ultima verificare după schimbări | |

## 1. Sursa este neambiguă

- [ ] File URL/key, pagina și node IDs exacte sunt în `delivery.yml`.
- [ ] Named version sau timestamp-ul revizuit este înregistrat.
- [ ] Frames exploratorii, deprecated sau out of scope sunt marcate clar.
- [ ] Flow-ul de navigație/prototype care definește behavior este legat.
- [ ] Design ownerul și persoana care aprobă parity sunt identificate.
- [ ] Echipa are acces real la fișier, componente, variables și assets necesare.

## 2. Acoperirea stărilor

Pentru fiecare stare, bifează `designed`, `rule-defined` sau `not applicable` în
`design-map.md`. O stare rule-defined are o regulă neambiguă și componentă/tokens, chiar
dacă nu are frame separat.

- [ ] Initial/idle.
- [ ] Loading și/sau skeleton.
- [ ] Loaded/happy path.
- [ ] Empty/no results.
- [ ] Partial sau stale data.
- [ ] Recoverable error + retry.
- [ ] Blocking error.
- [ ] Offline/degraded mode.
- [ ] Permission denied/restricted.
- [ ] Validation inline și summary, dacă există input.
- [ ] Submitted/in progress și protecția la duplicate action.
- [ ] Success/confirmation.
- [ ] Destructive confirmation și undo, dacă se aplică.
- [ ] Cancellation/background/resume, dacă se aplică.

## 3. Stările de interacțiune

- [ ] Default.
- [ ] Pressed/highlighted.
- [ ] Disabled și motivul indisponibilității.
- [ ] Focused și keyboard behavior.
- [ ] Selected/unselected.
- [ ] Hover/pointer pentru iPadOS, dacă se aplică.
- [ ] tvOS focus, parallax și remote behavior, dacă se aplică.
- [ ] Gestures au alternativă accesibilă și nu ascund acțiuni critice.
- [ ] Tranzițiile și motion-ul au intenție și fallback Reduce Motion.

## 4. Layout și platforme

- [ ] Device classes suportate sunt declarate.
- [ ] Compact/regular width behavior este explicat.
- [ ] Orientările suportate sunt explicite.
- [ ] Safe areas, keyboard și scroll behavior sunt definite.
- [ ] Split view/multitasking pe iPadOS este acoperit, dacă se aplică.
- [ ] tvOS overscan/focus și distanța de vizualizare sunt acoperite, dacă se aplică.
- [ ] Light mode și dark mode sunt acoperite.
- [ ] Conținutul dinamic/lung are reguli de wrapping, truncation și expansion.
- [ ] Nu se deduce layout-ul adaptiv dintr-un singur screenshot.

## 5. Design system și tokens

- [ ] Fiecare componentă reutilizabilă indică componenta/varianta canonică.
- [ ] Culorile folosesc semantic variables/tokens, nu valori locale neexplicate.
- [ ] Tipografia, spacing, radius, borders, elevation și motion folosesc tokens.
- [ ] Stările componentelor sunt definite în component set sau în reguli.
- [ ] Orice componentă nouă are owner și decizie de promovare în DesignSystem.
- [ ] Deviațiile intenționate de la DesignSystem sunt listate și aprobate.

## 6. Accessibility intent

- [ ] Ordinea de citire VoiceOver este clară.
- [ ] Elementele au rol, label, value, hint și grouping intenționate.
- [ ] Acțiunile custom au alternativă accesibilă.
- [ ] Dynamic Type este suportat până la mărimile declarate, inclusiv accessibility.
- [ ] Contrastul textului și al controalelor a fost evaluat.
- [ ] Informația nu este transmisă numai prin culoare, poziție sau motion.
- [ ] Focus order pentru keyboard/tvOS este clar.
- [ ] Reduce Motion și Increase Contrast sunt considerate când sunt relevante.
- [ ] Touch targets și spacing permit interacțiune sigură.

## 7. Copy și localizare

- [ ] Copy-ul este final sau are owner și dată de finalizare înainte de READY.
- [ ] Titlurile, labels, errors, empty states și confirmations sunt acoperite.
- [ ] Textele cu impact legal/privacy sunt aprobate de ownerul potrivit.
- [ ] Plural, date, ore, numere, monede și unități au context localizabil.
- [ ] String-urile ambigue au context pentru traducător.
- [ ] Expansiunea textului și RTL sunt definite pentru localele suportate.
- [ ] Copy-ul din Figma și requirements nu se contrazice.

## 8. Assets

- [ ] Fiecare asset are sursă, owner și licență/drept de utilizare.
- [ ] Formatul de export este potrivit: vector/raster, scale, gamut, dark variant.
- [ ] Numele și variantele sunt mapate către Asset Catalog.
- [ ] Imaginile decorative versus informative sunt identificate pentru accessibility.
- [ ] Nu există secrete, date reale sau PII în assets/mockups.
- [ ] Asset-urile remote au placeholder, error și caching behavior definite.

## 9. Mapping și verificare

- [ ] Fiecare acceptance ID cu UI este mapat la node/state IDs.
- [ ] Fiecare node/state in scope este mapat la behavior sau acceptance.
- [ ] Matricea de screenshot/parity include device, appearance și Dynamic Type relevante.
- [ ] Toleranțele sau deviațiile acceptate au motiv și approver.
- [ ] Metoda de verificare este stabilită: screenshot, video, runtime sau design review.
- [ ] Material changes după READY declanșează revision + impact review.

## Decizie gate

| Rol | Decizie | Actor | Dată | Evidence/link |
|---|---|---|---|---|
| Design | Pending / Approved / Rejected / Conditional | | | |
| Product | Pending / Approved / Rejected / Conditional | | | |
| Engineering | Pending / Approved / Rejected / Conditional | | | |

**Figma Ready:** `YES / NO`

**Condiții, lipsuri sau deviații:**

---
