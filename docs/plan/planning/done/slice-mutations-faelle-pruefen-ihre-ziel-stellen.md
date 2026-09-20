# Slice slice-mutations-faelle-pruefen-ihre-ziel-stellen: Die Mutations-Fälle prüfen ihre Ziel-Stellen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — die drei nachgezogenen Zähne und die Kommentar-Form sind Belege
der Liefer-Punkte selbst.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` meldet jeden
gelisteten Wächter, der seine Zähne verloren hat),
[Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-stumme-mutations-faelle-folgen-der-config-form-verifikation.md)
(F-1: die drei Bestand-Fundstellen, dynamisch im Wegwerf-Klon als
`MUTATE-EXIT=2` gemessen; F-2-Rest: die Schlusssform des Zahn-Kommentars),
[Runde 1](../../../../docs/reviews/2026-09-19-slice-stumme-mutations-faelle-folgen-der-config-form-runde-1.md)
F-1/F-2 (Übergaben deklariert);
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (Herkunft als ein auflösbares Feld
oder nicht genannt).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ziel:** Die drei Bestand-Fundstellen fahren wieder rot — ihre sed-Muster
treffen den Quell-Bestand wieder: Fall 29 sucht `body = NeutralizeRoadmap(body)`
(`grep -cF` → **0**; die Quelle liest sich
`internal/emit/templates.go:414` als `return NeutralizeRoadmap(body), nil`),
Fall 275 sucht `body = NeutralizePlanningReadmeCarveoutsDoneRef(body)`
(`grep -cF` → **0**; `:428`), Fall 114 sucht
`if rmErr := syscall.Rmdir(path); rmErr != nil {` (`grep -cF` → **0**; kein
`Rmdir` mehr in `internal/span/emit.go` — die Span-Sperre trägt je-OS-Dateien).
`make mutate` meldet die drei als BEFUND (Bedingung 2, dynamisch gemessen im
Verifikations-Lauf: `MUTATE-EXIT=2`). Dazu die **Kommentar-Schlussform**
(`internal/gen/archgate_test.go:233-234`): „der Gegenbeispiel-Nachweis liegt
als Hand-Messung vor" behauptet Beleg-Existenz ohne auflösbaren Ort — der
Kommentar trägt die Herkunft als ein auflösbares Feld oder streicht die
Behauptung ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Und die **Regel**, die
die Klasse trägt (sie steht im Register bei 5×, Ausgang *geplant* mit dieser
Kennung): die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht
gegen die Fassung der letzten Fassung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine neuen Fälle für bewachte Klassen** — **Bestand bleibt bewusst
  stehen:** der Umschnitt richtet die drei verlorenen Ziele; ein Fall je
  zusätzlichem Wächter ist eigene Bedarf-Entscheidung.
- **Kein Gate** — **Schicht-Abgrenzung:** `make mutate` ist kein Gate;
  der Slice pflegt den kuratierten Satz.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß.

- [x] **Liefer-Punkt 1 — die drei Zähne treffen wieder:** die sed-Muster der
      Fälle 29, 275, 114 treffen den Quell-Bestand; die Mutation greift und
      färbt ihren benannten Wächter rot; `make mutate` meldet keinen BEFUND
      auf den drei Fällen. Rote Gegenprobe: bis zum Umschnitt meldet der Lauf
      die drei als BEFUND (gemessen, Verifikation: `MUTATE-EXIT=2`,
      Bedingung 2); der Umschnitt dreht die Meldung um.
- [x] **Liefer-Punkt 2 — die Kommentar-Schlussform trägt ihre Herkunft
      auflösbar oder gar nicht:** `internal/gen/archgate_test.go:233-234`
      behauptet keine Beleg-Existenz mehr ohne auflösbaren Ort
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Grenze:
      Kommentar-Behauptungen sind keinem Sensor unterworfen — die Form prüft
      das Review, nicht ein Gate.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — oder
      „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/29-roadmap-nicht-neutralisiert.sh` | update | das sed-Muster folgt der Quell-Fassung (`internal/emit/templates.go:414`) |
| `test/mutations/275-planning-readme-carveouts-done-ref-nicht-neutralisiert.sh` | update | das sed-Muster folgt der Quell-Fassung (`:428`) |
| `test/mutations/114-span-lock-verzeichnis.sh` | update | der Fall folgt der Span-Sperre mit je-OS-Dateien (kein `Rmdir` mehr) |
| `internal/gen/archgate_test.go` | update | die Schlussform `:233-234` trägt die Herkunft auflösbar oder nicht |

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn die Quelle-Re-Schnitte über die
drei Stellen hinaus wachsen; blockiert → `open`, falls der kuratierte Satz
sich widersprüchlich zum Umschnitt verhält.

## 5. Closure-Trigger

DoD mit den roten Gegenproben belegt und `make mutate` meldet keinen BEFUND
auf den drei Fällen.

## 6. Risiken und offene Punkte

- **Der nächtliche Lauf bestätigt das Greifen erst nach dem Umschnitt** — der
  dynamische Beleg kommt vom Wegwerf-Klon (Runde 1). — **Ausgang:**
  *entfallen* → der reale Lauf der Verifikation liefert den dynamischen
  Beleg: 365 ok, 0 Befunde, die drei Fälle OK am benannten Wächter.

## 7. Closure-Notiz

- **Was hat funktioniert:** die drei Zähne treffen wieder — Neumuster je 1,
  Alt-Formen 0, je Zahn real rot am benannten Wächter (dynamisch, je Fall
  eigener Wegwerf-Klon, Runde 1), und der reale `make mutate`-Lauf meldet
  **365 ok, 0 Befunde**.
- **Was ging anders als geplant:** der Register-Ausgang (*geplant*) löste
  ins Leere — die Verkörperung war an „Liefer-Punkt 2 und 3 dieses Plans"
  verankert, §2 trägt die Regel nicht (Verifikation F-1, MEDIUM). Die
  Closure dreht den Ausgang auf die Kennung des Architektur-Slices, der die
  Regel schreibt. Der F-2-Rest (Commit-Message nennt zum Fall 114 den Ort
  nicht — `internal/span/lock_unix.go:25` trägt `syscall.Rmdir` innerhalb
  `removeStaleDir` weiter) ist eingefroren: die Message ist gepusht; die
  Klasse (Aussage ohne Ort liest sich weiter als Paket-Aussage) trägt der
  Lese-Schritt.
- **Steering-Loop-Eintrag:** geschärfte Regel für die Fall-Anlage: „die
  Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht gegen die
  Fassung der letzten Fassung" — die Klasse
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` trägt
  5×; ihr Ausgang steht im Register auf *geplant* mit der Kennung
  `slice-fall-anlage-misst-gegen-den-quell-bestand` — der Architektur-Zug
  der Closure (Planner → Architect → Planner, §3.8). Kein `liegt in`-Feld —
  der Zielort entsteht mit der Verkörperung, nicht mit der Zuweisung.
- **Beobachtungs-Register (`../observations/`):** keine Beobachtung
  angefallen — der bestehende Eintrag trägt die F-1-Fundstellen (29, 275,
  114) als Bestand-Fund dieses Vorgangs; die Zählregel „ein Vorgang zählt
  einmal" legt keinen zweiten Beleg an (Zählerstand 5×).
- **Folge-Slices:** `slice-fall-anlage-misst-gegen-den-quell-bestand` (Die
  Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand) — ist eine Datei
  in `open/`.
- **Risiken aus §6:** nächtlicher Lauf → *entfallen* (realer Lauf,
  Verifikation).
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der
kuratierte Mutations-Satz und der Zahn-Kommentar. Schwelle ≥ 2 von 3 erfüllt.
`*` steht in der Modus-Deklaration als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer:
`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` —
**Zählerstand 5×** nach dem Beleg dieses Vorgangs, Ausgang *geplant* mit
dieser Kennung (die Verkörperung der Regel ist Liefer-Punkt 2 und 3 dieses
Plans, s. o.); die Klasse trägt die zwei Fundmengen
(68/71/96 — die vom Config-Re-Schnitt gezogenen; 29/275/114 — die
Bestand-fund) als benannte Fundorte, nicht als zweite Zählung. Keine
weiteren Treffer — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.