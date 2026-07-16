# Definition of Ready

Acest gate autorizează planificarea finală și implementarea unui delivery item. Nu
garantează că nu vor apărea schimbări; garantează că necunoscutele și autoritatea sunt
vizibile.

## Identitate

| Câmp | Valoare |
|---|---|
| Delivery ID | |
| Revision | |
| Target audience | |
| Product owner | |
| Design owner | |
| Engineering owner | |
| Data evaluării | |

## 1. Outcome și scope

- [ ] Problema este formulată din perspectiva utilizatorului/operațiunii.
- [ ] Outcome-ul observabil este explicit.
- [ ] Target users și target audience sunt explicite.
- [ ] In scope și non-goals nu se contrazic.
- [ ] Itemul este suficient de mic pentru verificare independentă.
- [ ] Prioritatea și motivul livrării sunt cunoscute.

## 2. Acceptance contract

- [ ] Fiecare criteriu are un ID stabil `AC-*`.
- [ ] Criteriile descriu behavior observabil, nu structura codului.
- [ ] Happy path este acoperit.
- [ ] Edge/failure states relevante sunt acoperite.
- [ ] Fiecare criteriu are una sau mai multe metode de verificare.
- [ ] Must/should/could sau altă prioritate este explicită.
- [ ] Orice criteriu amânat este mutat în non-goals sau într-un item legat.

## 3. Design

- [ ] `UI required` este declarat.
- [ ] Dacă există UI, checklist-ul Figma Definition of Ready este trecut.
- [ ] Node IDs și reviewed version/timestamp sunt în Delivery Packet.
- [ ] Stările, interacțiunile, copy-ul, assets și accessibility intent sunt suficiente.
- [ ] Dacă nu există UI, Product + Engineering au aprobat `not applicable`.
- [ ] Design change policy după READY este cunoscută.

## 4. Platforme și produs

- [ ] Platformele, minimum OS, device classes și orientările sunt declarate.
- [ ] Localele și comportamentul de localizare sunt declarate.
- [ ] Account state, permissions, entitlements și subscription state sunt clare.
- [ ] Upgrade/background/offline behavior este clar când este relevant.
- [ ] Apple platform/App Store constraints cunoscute sunt înregistrate.

## 5. Date și dependențe

- [ ] API/backend contract este disponibil sau are un stub/fake aprobat.
- [ ] Compatibilitatea cu versiunile vechi ale aplicației este definită.
- [ ] Storage, cache, migration și data retention sunt evaluate.
- [ ] Fiecare dependență are owner și status.
- [ ] Accesul la environments, test data și conturi necesare este confirmat.
- [ ] Dependențele blocking sunt `ready` sau itemul nu avansează.

## 6. Risk și compliance

- [ ] Risk level este estimat.
- [ ] Privacy impact și data classification sunt evaluate.
- [ ] Security/auth/permissions/secrets impact este evaluat.
- [ ] Legal/content/licensing impact este evaluat.
- [ ] Third-party SDK și privacy manifest impact sunt evaluate.
- [ ] Reviewerii obligatorii au fost identificați.
- [ ] Nu există un risc critic fără owner și decizie.

## 7. Măsurare și operare

- [ ] Success metrics sunt definite sau `not applicable` cu motiv.
- [ ] Guardrails sunt definite sau `not applicable` cu motiv.
- [ ] Analytics events și consent behavior sunt schițate.
- [ ] Operational telemetry necesară pentru verificare există sau este în scope.
- [ ] Canalul, cohorta și condiția pentru Delivered sunt explicite.
- [ ] Rollout și rollback concept sunt fezabile.

## 8. Necunoscute și ownership

- [ ] Fiecare unknown are owner, due date și blocking flag.
- [ ] Nu există unknown blocking fără decizie înainte de READY.
- [ ] Product, Design, Engineering, QA și Release ownerii aplicabili sunt cunoscuți.
- [ ] Acțiunile protejate și approval path sunt clare.
- [ ] Delivery Packet-ul validează contra schemei v0.1.

## Aprobări READY

| Rol | Obligatoriu | Decizie | Actor | Dată | Evidence/link |
|---|---:|---|---|---|---|
| Product | Da | Pending / Approved / Rejected / Conditional | | | |
| Design | Pentru UI | Pending / Approved / Rejected / Conditional / N/A | | | |
| Engineering | Da | Pending / Approved / Rejected / Conditional | | | |
| Security | După risc | Pending / Approved / Rejected / Conditional / N/A | | | |
| Privacy/Legal | După risc | Pending / Approved / Rejected / Conditional / N/A | | | |

**Decizie:** `READY / NOT READY`

**Condiții rămase, cu owner și termen:**

---
