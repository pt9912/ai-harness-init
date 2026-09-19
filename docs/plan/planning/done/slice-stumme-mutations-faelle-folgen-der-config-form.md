# Slice slice-stumme-mutations-faelle-folgen-der-config-form: Die drei stummen Mutations-Fälle und der Zahn-Kommentar folgen der re-geschnittenen Config-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — die drei Zahnen und der Kommentar sind Belege der Liefer-Punkte
selbst; ein repo-weites Mehr über sie hinaus existiert nicht.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` meldet jeden
gelisteten Wächter, der seine Zähne verloren hat — gelistet heißt, wer keinen
Fall in `test/mutations/` hat, ist unbewacht),
[Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md)
V-1 (Befund MEDIUM: die Fälle 68, 71, 96 sind No-Ops) und V-4 (LOW: der
Zahn-Kommentar behauptet einen Rot-Beleg, den es nicht gibt);
[`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
(die Config-Re-Schnitte `366c8837`/`34c9e446` änderten die Literale, auf deren
Muster die Fälle fahren).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-19.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ziel:** Die drei gelisteten Mutations-Fälle **68, 71, 96** fahren wieder rot —
ihre sed-Muster treffen die re-geschnittene Config-Form
([`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)):
alle drei sind heute No-Ops, `make mutate` würde dort BEFUND melden
(gemessen, Verifikations-Report V-1: statisch gegen ihre Muster, je exit 1).
Dazu der **Zahn-Kommentar**
(`internal/gen/archgate_test.go:227-232`): er behauptet ein Rot-Gegenbeispiel,
das nicht existiert (kein Fall von 365 setzt den Pin auf die
Vorgänger-Fassung); der **Rot-Beleg selbst** steht (Runde 2, Rot-Probe (c),
selbst gefahren mit der exakten Meldung) — der Kommentar trägt entweder den
Beleg, den es gibt, oder einen Fall, der ihn trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine neuen Mutation-Fälle für bewachte Klassen** — **Bestand bleibt
  bewusst stehen:** der Umschnitt richtet die drei stummen Fälle auf die
  re-geschnittene Form; ein Fall je zusätzlichem Wächter ist eigene
  Bedarf-Entscheidung, nicht Zahnpflege.
- **Kein Gate** — **Schicht-Abgrenzung:** `make mutate` ist kein Gate
  (nächtliche Stufe); der Slice pflegt den kuratierten Satz, keine
  Gate-Schwelle.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß.

- [x] **Liefer-Punkt 1 — die drei Fälle fahren wieder rot:** die sed-Muster
      der Fälle 68, 71, 96 treffen die re-geschnittene Config-Form; die
      Mutation färbt ihren benannten Wächter rot. Rote Gegenprobe: bis zum
      Umschnitt meldet `make mutate` die drei als BEFUND — gemessen
      (Verifikation V-1, statisch); der Umschnitt dreht die Meldung um.
- [x] **Liefer-Punkt 2 — der Zahn-Kommentar trägt den Beleg, den es gibt:**
      `internal/gen/archgate_test.go:227-232` behauptet keine Listedung mehr,
      die es nicht gibt — er trägt den tatsächlichen Rot-Beleg (Runde 2,
      Rot-Probe (c), exakte Meldung) oder einen Fall, der ihn trägt. Grenze:
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
| `test/mutations/` (Fälle 68, 71, 96) | update | die sed-Muster folgen den re-geschnittenen Config-Literalen — je Fall der Wächter, den er bewacht |
| `internal/gen/archgate_test.go` | update | der Kommentar `:227-232` trägt den Beleg, den es gibt (V-4) |

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn der Umschnitt mehr als die drei
Fälle trifft; blockiert → `open`, falls der kuratierte Satz sich
widersprüchlich zum Umschnitt verhält.

## 5. Closure-Trigger

DoD mit den roten Gegenproben belegt und `make mutate` meldet keinen BEFUND
auf den drei Fällen.

## 6. Risiken und offene Punkte

- **Der nächtliche Lauf bestätigt die Stummheit erst nach dem Umschnitt** —
  die statische Messung deckt die Muster, nicht den Lauf. — **Ausgang:**
  *entfallen* → die Zähne sind dynamisch gemessen (Runde 1, Wegwerf-Klon:
  die drei gezogenen Fälle fahren rot am benannten Wächter); der nächtliche
  Lauf meldet jetzt nur die drei F-1-Fälle, die der Folge-Slice zieht.

## 7. Closure-Notiz

- **Was hat funktioniert:** der Umschnitt auf die re-geschnittene Config-Form
  — Runde 1 zählt 362 greifen · 3 stumm · 0 defekt über den Bestand, und die
  drei gezogenen Fälle fahren rot am benannten Wächter, statisch und
  dynamisch im Wegwerf-Klon.
- **Was ging anders als geplant:** der Umschnitt erfasste nur die vom
  Config-Re-Schnitt getragenen Fälle — der Zensus über alle 365 fand die drei
  Bestand-Fundstellen (29, 275, 114), die dieselbe Defekt-Klasse an anderen
  Zielen tragen; sie sind Bestand, nicht vom Umschnitt getragen (F-1), und
  der Kommentar-Schlussform-Rest (F-2) blieb stehen. Beide sind Übergaben an
  den Folge-Slice.
- **Steering-Loop-Eintrag:** geschärfte Regel für die Fall-Anlage: „die
  Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht gegen die
  Fassung der letzten Fassung" — die Klasse
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` trägt
  5×; ihr Ausgang steht im Register auf *geplant* mit der Kennung des
  Folge-Slices, der sie schreibt. Kein `liegt in`-Feld — der Zielort
  entsteht mit der Verkörperung, nicht mit der Zuweisung.
- **Beobachtungs-Register (`../observations/`):** neuer Beleg
  `evidence/slice-stumme-mutations-faelle-folgen-der-config-form.md` in
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/` —
  Zähler steht damit bei 5×; die zwei Fundmengen (68/71/96 und 29/275/114)
  liegen im selben Vorgang — ein Beleg, benannt, nicht doppelt gezählt.
- **Folge-Slices:** `slice-mutations-faelle-pruefen-ihre-ziel-stellen` (Die
  Mutations-Fälle prüfen ihre Ziel-Stellen) — ist eine Datei in `open/`.
- **Risiken aus §6:** nächtlicher Lauf → *entfallen* (dynamischer Beleg,
  Runde 1).
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der
kuratierte Mutations-Satz (`test/mutations/`) und der Zahn-Kommentar. Schwelle
≥ 2 von 3 erfüllt (Inventur: ja; mehrere Dateien: ja; Aussage: ja — die
Kommentar-Behauptung). `*` steht in der Modus-Deklaration als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-19 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: keine für die Mutations-Zahnpflege-Klasse — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.