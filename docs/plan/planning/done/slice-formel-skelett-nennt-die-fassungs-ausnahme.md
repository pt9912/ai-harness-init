# Slice slice-formel-skelett-nennt-die-fassungs-ausnahme: Das Formel-Skelett nennt die eine Fassungs-Ausnahme, statt breiter zu behaupten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-handbuch-zeigt-den-bestand](welle-handbuch-zeigt-den-bestand.md) — erster
Slice der Welle (Welle-Plan §4).

**Bezug:** [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) (Festlegung 1 lässt
genau einen Wert ins Binary reisen — die Fassung), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix).

**Berührte Spec-Stellen:** — (Doku-Satz am Skelett).

**Verantwortlich:** pt9912.

**Autor:** Planner. **Datum:** 2026-09-23.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice.

**Ziel:** Der Kopf-Kommentar des Formel-Skeletts
([`harness/tools/homebrew-formula.rb.tmpl`](../../../../harness/tools/homebrew-formula.rb.tmpl))
behauptet *„kein Wert reist im Binary"* — überbreit seit
[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1 (die Fassung reist
per `ldflags` in jedes Release-Binary). Der Satz sagt, dass der Bau genau einen Wert injiziert,
die Fassung — ein Satz, nicht eine zweite Quelle für die Festlegung (der Skelett-Satz
verweist auf [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md), er ordnet nicht neu).
Er spricht über die **Injektion des Baus**, nicht über alles, was im Binary steht: eingebettete
Vorgaben aus dem Quellstand (etwa `TRAEGER_TAG`, zulässig nach
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2, und `DefaultTag`/`DefaultBaselineSHA256`) liegen außerhalb seiner Aussage.

**Plan geändert nach Review** (Review-Report dieses Slice vom 2026-10-08, F-2 und F-3):
der zuvor vorgegebene Wortlaut *„kein Wert reist im Binary außer der Fassung"* war als Allaussage
falsch, und die Rot-Angabe von DoD (1) nannte mit `docs-check` einen Sensor, der den Fall nicht
sieht; §3 führt dazu den Test und die Mutations-Fälle, die der Diff trägt.

**Ausdrücklich NICHT in diesem Slice:**

- **Kein weiteres Formel-Griff** — der Skelett-Satz bleibt bei der einen
  Ausnahme; jede weitere Aussage darüber wäre eine zweite Quelle. — **Schicht-Abgrenzung**.
- **Der Emissions-Griff bleibt der gleiche.** Das Skelett wird je Release
  befüllt; der Nachzug ändert die Form, nicht den Vorgang. — **Bestand
  bleibt bewusst stehen** mit demselben Grund.
- **Kein Re-Publish eines Releases.** Die Zusage lebt im Quell-Skelett; der
  nächste Schnitt trägt sie in das Asset. — **Es wäre ein anderer Vorgang**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice.

- [x] **(1) Der Skelett-Kommentar nennt die eine Injektion.** Der Satz lautet *„der Bau
      injiziert genau einen Wert ins Binary, die Fassung ([`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1); eingebettete
      Vorgaben aus dem Quellstand berührt das nicht."* — der Zeiger ersetzt die breite Aussage,
      er formuliert die Festlegung nicht um.
      **Rot:** [`test/release-matrix.bats`](../../../../test/release-matrix.bats), Test *„das
      Formel-Skelett nennt genau die eine Ausnahme, die der Bau ins Binary injiziert"* — hält
      den Satz als Literal und die `-X`-Menge des Baus gegen ihn; Mutations-Fälle 610 (zweiter
      injizierter Wert) und 611 (Satz gestrichen).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor — Rollenwechsel nach Schritt 8
      des Minimal Agent Workflow, kein Self-Review. **Bei einem Ein-Satz-Slice:** der Review
      kann als Stich-Befund im Closure-Commit berichtet werden, wenn der Diff ein Byte-Satz
      bleibt; sonst eigener Report.
- [x] Closure-Notiz mit Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben — der Eintrag
      [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
      trägt den Ausgang dieses Vorkommens.
- [x] Jedes Risiko aus §6 trägt einen Ausgang.
- [x] Die drei Paarungen — dieses Repo führt Wellen-Betrieb; der Träger ist die nächste
      Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/homebrew-formula.rb.tmpl`](../../../../harness/tools/homebrew-formula.rb.tmpl) | update | der Kopf-Kommentar nennt die eine Injektion statt der breiten Aussage |
| [`test/release-matrix.bats`](../../../../test/release-matrix.bats) | update | Test hält den Satz als Literal und die `-X`-Operanden des Baus gegen ihn (Rot von DoD 1) |
| `test/mutations/610-fassungs-ausnahme-zweiter-injizierter-wert.sh`, `test/mutations/611-fassungs-ausnahme-aus-dem-skelett-satz-gestrichen.sh` | neu | Zähne des Tests: zweiter injizierter Wert · Satz gestrichen |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

**Start** (`open` → `next`): WIP-Limit frei. **Rückführung:** entfällt — ein Satz, kein Gegenstand
für eine Zerlegung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

1. `make gates` ist grün.
2. Der Skelett-Satz nennt die Ausnahme und ihren Anker ([`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 1), nicht die Festlegung selbst — gelesen vor dem Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

1. **Der Skelett-Satz wird an zwei Stellen gelesen** (Skeleton und emittierte Formel je Release).
   **Ausgang: entfallen** — der Satz ändert die Form, nicht den Vorgang; das Literal am Skelett
   hält `test/release-matrix.bats`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`.

**Rolle:** Planner · **Datum:** 2026-10-08.

- **Was hat funktioniert:** Der Satz im Skelett trägt die eine Injektion des Baus samt Anker;
  `test/release-matrix.bats` hält ihn als Literal und die `-X`-Menge des Baus dagegen. Rot
  gelesen (Verifikation): je eine der vier `-X`-Formen am Makefile färbt den Test, eine
  unlesbare Form bricht ihn fail-closed; `make mutate` über 610–613 → `4 ok, 0 Befund(e)`.
- **Was ging anders als geplant:** Der Plan gab einen überbreiten Wortlaut und eine Rot-Angabe
  mit `docs-check` vor (Review F-2/F-3), nachgeschnitten vor der Nacharbeit. Die
  Test-Erkennung sah vier gültige `-X`-Formen nicht (F-1, HIGH), behoben mit den Fällen
  612 (Makefile, `-X=`) und 613 (Workflow, `-X "…"`) — beide ohne Zeile in §3, hier
  nachgewiesen (Verifikation V-2). Die Testkopf-Zusage Punkt 8 blieb zunächst als Allaussage
  stehen (V-1), nachgezogen.
- **Grenze des Satzes:** *„genau einen Wert"* gilt für den Release-Bau; ohne `TRAEGER_VERSION`
  injiziert der Bau keinen, und der Test hält *„höchstens die Fassung"*, den Null-Fall nicht
  (V-3). Der Satz und das Test-Literal verweisen auf Festlegung 1 der **Proposed**
  [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md); dass Nummer und Inhalt bis
  zur Annahme bleiben, hält kein Sensor. Träger ist der Accept-Übergang
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11); die Annahme entscheidet der Auftraggeber.
- **Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum kein
  `liegt in`-Feld. Beide berührten Einträge tragen ihren Ausgang schon (*geplant*); der Slice
  legt nur Belege an.
- **Beobachtungs-Register (`../observations/`):** zwei Belege
  `evidence/slice-formel-skelett-nennt-die-fassungs-ausnahme.md` — in
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (Review-Klasse F-1: Testkopf nennt Formen, die das Muster nicht erkennt; Ausgang *geplant*,
  `slice-181`) und in
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (F-2/V-1; Ausgang *geplant*, `slice-153`). Ein Vorgang je Eintrag; kein Eintrag steht danach
  `offen` über der Schwelle ([`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)
  Festlegung 1 greift nicht).
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) **entfallen** — der Satz ändert die Form, nicht den Emissions-Vorgang;
  das Literal am Skelett hält der Test.
- **Paarungen geprüft am 2026-10-08, nach dem `git mv`:** (a) Anker — kein `liegt in`-Feld in §7,
  kein Gegenstand · (b) Folge-Slice — keiner genannt; die Ausgangs-Kennungen `slice-181` und
  `slice-153` liegen in `open/` (`ls docs/plan/planning/open/slice-1{81,53}-*`) · (c) Register —
  beide genannten Verzeichnisse existieren, `evidence/*.md` je nicht leer (20 bzw. 37,
  `ls …/evidence/*.md | wc -l`, keine Erwartung). Grün.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `harness/tools/` — in `*`. Die
berührte Sub-Area erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Der Eintrag
[`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
trägt den Ausgang dieses Vorkommens; sein Zähler steht über der Schwelle, der Ausgang ist
zugewiesen — dieser Slice vollzieht die geplante Regel.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).