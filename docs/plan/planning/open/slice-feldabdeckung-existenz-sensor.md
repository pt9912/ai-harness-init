# Slice slice-feldabdeckung-existenz-sensor: Bidirektionaler Existenz-Abgleich zwischen Feldliste im Träger und Spec §5

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD
dieses Slice verschieden ist (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
(Rang 1 — Redaktion des emittierten Dokuments),
[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md)
(**Proposed** — trägt die Entscheidung *„bidirektionaler Existenz-Abgleich, keine
Wortgleichheit, keine Erzeugung"*, die dieser Slice umsetzt; ein Slice darf sich auf eine
Proposed-ADR beziehen, solange sie in Arbeit ist — **bindend** ist der Bezug erst mit ihrer
Annahme, siehe §4 Trigger),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(fail-closed bei unbekannter Zeilenform ist dieselbe Disziplin, mit der jeder Wächter dieses Repos
auf unbekannte Eingabe reagiert),
Baseline-Regelwerk `modul-11-verification.md` §Fitness Function ohne Standard-Tool (die
Sensor-Schicht-Tabelle — Begründung der Gate-Wahl unten),
Baseline-Regelwerk `modul-13-quality-gates.md` §Gate-Typ ↔ Fehlerbild (Architekturtest-Zeile —
Struktur-/Konsistenz-Regel zwischen zwei Artefakten).

**Herkunft:** benannt im Architect-Verdikt
`docs/reviews/2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md` §3, als Folge-Slice zu
[`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../done/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md)
(Kennung und Scope wie dort vorgeschlagen; angelegt durch den Planner nach
[`AGENTS.md`](../../../../AGENTS.md) §3.10).

**Berührte Spec-Stellen:** [`spec/spezifikation.md` §5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— der Sensor liest die Tabelle, ändert sie nicht.

**Verantwortlich:** — (noch nicht priorisiert; blockiert, siehe §4 Trigger — [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) ist
`Proposed`, nicht `Accepted`).

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Skript/Make-Target hält jedes `{Field: "X"}`-Literal in
`internal/span/fieldlist.go` (`SchemaNotes()`) gegen ein Token `` `X` `` in der §5-Tabelle von
`spec/spezifikation.md` — und umgekehrt jedes Feld-Token der Tabelle gegen ein Literal im Träger.
Beide Richtungen fail-closed bei unbekannter Zeilenform (analog [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Geprüft wird
ausschließlich **Existenz**, nicht Wortlaut, Detailgrad oder Kernaussage.

**Gate, nicht bloßes Werkzeug — begründet:** Der Existenz-Abgleich ist eine deterministische,
computational Prüfung ohne semantisches Urteil — genau die Schicht, die Modul 11 als *„mittel —
Make-Target im `make gates`/`verify`-Block … Standardweg"* einordnet, nicht die teure
inferentielle Doku-Konsistenz-Agent-Schicht (die bliebe für die Kernaussage-Achse zuständig, die
dieser Slice ausdrücklich nicht baut). Er ist billig (ein `grep`/`awk`-Skript über zwei Dateien),
schnell und startet **grün** — der heutige Bestand ist bereits deckend (26 Zeilen + 6
Mehrfach-Literale = 32 Felder, siehe Architect-Verdikt §0). Er schließt außerdem die erste Hälfte
von Risiko 4 aus der DoD des Vorgänger-Slice (*„`make gates` sieht den Gegenstand nur zum
Teil"*) — ein Werkzeug ohne Gate-Bindung schlösse diese Lücke nicht, weil niemand es routinemäßig
liefe.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Wortlaut- oder Kernaussage-Angleichung zwischen Träger und Spec §5** — bleibt bewusst offen.
  [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) §Konsequenzen benennt das als **akzeptiertes Negativ**; ein Sensor dafür ist teuer
  (inferentiell, Modul 11) und ohne belegten Schadensfall über die zwei bisher von Menschen
  gefundenen Abweichungen hinaus. *Bestand bleibt bewusst stehen* — Träger ist die Sichtung bei
  künftiger Slice-Planung, kein Gate (`BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`).
- **Keine inhaltliche Änderung an §5 oder am Träger.** Der heutige Bestand ist bereits deckend
  (26 + 6 = 32, Architect-Verdikt §0) — der Sensor hat beim Bau kein sofortiges Rot zu beheben.
  *Bestand bleibt bewusst stehen.*
- **Keine Änderung an der vierten Spalte von §5** (Sensor-Bindung je Zeile). Sie ist laut
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  weiterhin ungebundenes Feedforward und von dieser Existenz-Prüfung (Spalte 2) nicht berührt.
  *Schicht-Abgrenzung.*

## 2. Definition of Done

**Drei Liefer-Punkte** (Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: ≤ 3).

- [ ] **(1) Bidirektionaler Existenz-Sensor gebaut.** Skript/Make-Target prüft beide Richtungen
      (Träger → Spec, Spec → Träger), bricht fail-closed bei unbekannter Zeilenform ab
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und läuft grün über dem heutigen Bestand (0 Befunde bei 26 Spec-Zeilen /
      32 Feldern).
- [ ] **(2) `make gates` grün**, inklusive des neuen Ziels.
- [ ] **(3) Doku-Update:** [`harness/README.md`](../../../../harness/README.md) §Sensors trägt den
      neuen Eintrag (Target, Vertrag, Bindung [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md)/[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)).

Standard-Punkte der Vorlage gelten unverändert: Review-Report, Closure-Notiz mit
Steering-Loop-Lerneintrag, Beobachtungs-Register fortgeschrieben, jedes Risiko aus §6 trägt einen
Ausgang, die drei Paarungen getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/feldabdeckung-check.sh` (Name vom Implementer bestätigt) <!-- d-check:ignore (geplante Datei) --> | neu | der Existenz-Sensor selbst |
| `Makefile` | update | neues Ziel, in `gates` aufgenommen |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | Liefer-Punkt (3) |
| Testdatei unter `test/` (bats, Konvention dieses Repos) | neu | Happy (heutiger Bestand grün) · Boundary (ein Feld nur auf einer Seite → rot) · Negative (unbekannte Zeilenform → fail-closed) |

## 4. Trigger

**Start** (`open` → `next` → `in-progress`): **[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) ist `Accepted`.** Bis dahin hat dieser
Slice keinen bindenden ADR-Bezug (Architect-Verdikt §Was offen bleibt: *„der Folge-Slice hat bis
zur Annahme keinen bindenden ADR-Bezug"*) und bleibt in `open/` liegen, unabhängig vom
WIP-Limit-Stand.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass fail-closed bei
  unbekannter Zeilenform einen Parser mit mehr als einer eigenen Grammatik-Klasse verlangt (mehr
  als: Feld-Literal-Form im Go-Quelltext, Tabellenzeilen-Form in Markdown).
- `in-progress` → `open` (blockiert): wenn [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) vor Abschluss dieses Slice doch nicht
  angenommen, sondern durch eine andere Lesart ersetzt wird — dann trägt der neue ADR-Bezug einen
  anderen Sensor-Scope, und dieser Slice-Plan ist nicht mehr aktuell.

## 5. Closure-Trigger

Sensor läuft grün über dem heutigen Bestand (0 Befunde); `make gates` grün inklusive des neuen
Ziels; Doku-Eintrag in `harness/README.md` §Sensors vorhanden; Closure-Notiz mit
Steering-Loop-Eintrag; jedes Risiko aus §6 trägt einen Ausgang.

## 6. Risiken und offene Punkte

- **Die fail-closed-Behandlung unbekannter Zeilenformen wird selbst zum kleinen Parser**, dessen
  Muster brüchiger sind als geplant (zwei Grammatiken: Go-Literal, Markdown-Tabellenzeile). —
  **Ausgang:** wird bei Closure dieses Slice zugewiesen.
- **Der Sensor deckt nur die Existenz-Teilmenge**, nicht die Kernaussage-Teilmenge — ein Leser
  könnte den grünen Sensor als vollständige Deckung der Kopplungsfrage lesen, obwohl
  [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) §Konsequenzen das ausdrücklich als offenes Negativ benennt. **Gegenmittel im Plan:**
  §1 und die Doku-Zeile in `harness/README.md` nennen die Grenze explizit. — **Ausgang:** wird bei
  Closure dieses Slice zugewiesen.
- **Der Sensor wird als Gate verdrahtet, bevor [`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) `Accepted` ist**, und prüft dann eine
  Form, die niemand entschieden hat. **Gegenmittel im Plan:** §4 Trigger startet erst nach
  Annahme. — **Ausgang:** wird bei Closure dieses Slice zugewiesen.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine Sub-Area ist berührt: `*` (gesamtes Repo) — die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt
`internal/span/` und `spec/` nicht als eigene Sub-Area; beide fallen unter `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, 2026-09-27. Ein Treffer:
[`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
(1×, unter der Schwelle) — dieser Slice ist der in ihrem `state.md` benannte Träger des
Existenz-Sensors, ändert aber nichts an ihrem offenen Stand, weil er die Kernaussage-Achse nicht
baut.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (siehe
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md));
kein BF/Hybrid-Block nötig.
