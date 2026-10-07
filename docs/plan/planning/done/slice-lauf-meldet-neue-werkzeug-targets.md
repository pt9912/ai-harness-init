# Slice slice-lauf-meldet-neue-werkzeug-targets: Der Lauf nennt jedes Target, das seine Regeneration neu mitbringt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`ADR-0080`](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md);
Baseline-Regelwerk `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) — ein Target, das eine
Regeneration mitbringt, ist im Teil des Werkzeugs deklariert, nicht gemeldet. Bedingung aus der
Kurs-Antwort zu `v6.16.0` Welle 159 (vom Auftraggeber am 2026-10-07 weitergegeben): *„Der Sensor
schweigt, sichtbar ist es im Diff des Laufs. Das sollte euer Lauf dem Adopter deutlich machen,
besonders bei einem neuen Gate in make gates."* Fällig vor dem Release `v0.3.0`
(Auftraggeber-Entscheidung 2026-10-07).

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Bootstrap und `add-lang` nennen auf stdout jedes Target, das der neu geschriebene
Werkzeug-Teil des Gate-Index (im Ziel die Datei harness/mk/ai-harness-init.md) gegenüber dem vorigen neu führt, und
heben ein neues Gate hervor. Gemessen am Stand des Schnitts schreiben beide Läufe den Teil still neu
(`emit.WerkzeugIndex` in `internal/emit/werkzeugindex.go`, aufgerufen in
`cmd/ai-harness-init/main.go` am Ende von `addLang` und des Bootstrap); stdout nennt keine Targets.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Meldung im Doku-Gate.** *Anderer Vorgang:* dass der Sensor ein Target aus der Regeneration
  nicht meldet, ist die Zusage der adoptierten Fassung (`modul-13-quality-gates.md`); getragen wird
  die Sichtbarkeit vom Lauf, nicht vom Gate.
- **Weggefallene Targets.** *Bestand bleibt stehen:* die Bedingung nennt neue; ein weggefallenes
  Target meldet der Sensor als `gate-phantom`, falls eine Zeile in `harness/README.md` es noch führt.
- **Targets des Adopters** (`harness/README.md`, `repo.mk`). *Schicht-Abgrenzung:* sie gehören dem
  Repo ([`ADR-0080`](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md));
  der Lauf schreibt sie nicht und meldet sie nicht.
- **Der Release `v0.3.0` selbst.** *Anderer Vorgang:* dieser Slice ist seine Vorbedingung.

## 2. Definition of Done

- [x] **1 — Meldung im Lauf:** Bootstrap und `add-lang` lesen den vorhandenen Werkzeug-Teil vor dem
      Neuschreiben und nennen auf stdout je neu hinzugekommenem Target eine Zeile; ein Target ohne
      Marke `kein Gate` steht hervorgehoben als neues Gate; ohne neues Target keine solche Zeile, und
      beim ersten Lauf (kein voriger Teil) keine Einzelzeilen. Ein Go-Test hält das; **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Ausgabe-Zeile entfernt, und der Test fällt mit
      dem Namen des fehlenden Targets.
- [x] **2 — E2E:** eine `make full-smoke`-Stufe mit Deklaration fährt im Ziel einen zweiten Lauf, der
      ein neues Fragment-Target mitbringt, und prüft dessen Nennung auf stdout; die Stufe steht mit
      ihrer Grenze in der E2E-Abdeckungs-Sicht (`make e2e-abdeckung`,
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] **3 — Handbuch (Ist-Zustand):** `docs/user/benutzerhandbuch.md` nennt die Meldung, die
      Hervorhebung eines neuen Gates und dass das Doku-Gate ein solches Target nicht meldet.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/werkzeugindex.go` | update | Liefer-Punkt 1: vorigen Teil lesen, neue Targets samt Gate-Eigenschaft zurückgeben |
| `cmd/ai-harness-init/main.go` (Bootstrap, `addLang`) | update | Liefer-Punkt 1: Ausgabe auf stdout |
| `internal/emit/werkzeugindex_test.go` bzw. `cmd/ai-harness-init/*_test.go` | update | Liefer-Punkt 1: neues Target, neues Gate, kein neues, Erstlauf ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| `harness/tools/full-smoke.sh` (neue Stufe mit Deklaration), `docs/user/e2e-abdeckung.md` (erzeugt) | update | Liefer-Punkt 2 |
| `docs/user/benutzerhandbuch.md` | update | Liefer-Punkt 3 |
| `internal/emit/emit.go` (`DocGate` nimmt die `PrintMK`-Quelle als Parameter) | update | Liefer-Punkt 1: Bootstrap-Meldung im Go-Test ohne Docker-Lauf; mit der Closure nachgeführt |
| `test/mutations/532–535` | create | Liefer-Punkt 1: Zähne für Gate-Zeile, Erstlauf, Bootstrap-Meldung, kein-Gate-Zeile; mit der Closure nachgeführt |

- Die Gate-Eigenschaft liest der Lauf aus der Marke `kein Gate`, die der Werkzeug-Teil je Zeile
  trägt — keine zweite Erkennung neben dem Index.

## 4. Trigger

**Start** (`next` → `in-progress`): Auftraggeber-Entscheidung 2026-10-07 (vor `v0.3.0`);
`slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` liegt in `done/`, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gate-Hervorhebung verlangt eine Erkennung außerhalb des Werkzeug-Teils
  (etwa die Voraussetzungen von `gates:` im Makefile des Ziels) und sprengt die drei Liefer-Punkte.
- `in-progress` → `open`: die Meldung widerspricht einer Festlegung von
  [`ADR-0080`](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) —
  Übergabe an den Architect.

## 5. Closure-Trigger

1. `make full-smoke` endet EXIT 0 mit der neuen Stufe, und `make e2e-abdeckung` führt sie.
2. Der Rot-Beleg zu Liefer-Punkt 1 steht im Review- oder Verifikationsbericht mit der Meldung des
   Tests; `make gates` grün.

## 6. Risiken und offene Punkte

- **Die Marke `kein Gate` sagt, was der Index deklariert, nicht, was `make gates` fährt** — ein
  Fragment-Target ohne Marke, das `gates` nicht aufruft, wird als Gate hervorgehoben. — **Ausgang:**
  *entfallen* — Gate ist im Werkzeug-Teil, was ein Fragment an `GATE_CHECKS` hängt
  (`sammleWerkzeugTargets` in `internal/emit/werkzeugindex.go`), und der emittierte Aggregator fährt
  genau das (`record-gates: $(GATE_CHECKS)`, `internal/emit/makefile.go`).
- **Ein umbenanntes Target erscheint als neu** (und das alte verschwindet still). — **Ausgang:**
  *weiter offen* →
  [`BEO-ALL/lauf-meldung-vergleicht-nur-namen-gegen-einen-vorhandenen-teil`](../observations/BEO-ALL/lauf-meldung-vergleicht-nur-namen-gegen-einen-vorhandenen-teil/observation.md).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** DoD 2 und 3 bestätigt, `make full-smoke` EXIT 0 mit der neuen Stufe,
  `make e2e-abdeckung` führt sie ([Verifikation](../../../reviews/2026-10-07-werkzeug-meldung-verifikation.md));
  [Review](../../../reviews/2026-10-07-werkzeug-meldung-review.md) 0 HIGH / 0 MEDIUM, F-1 (LOW,
  Bootstrap-Meldung ohne Test) behoben in `34d425cb`. DoD 1 nach dem bedingten Verdikt der
  Verifikation geschlossen in `ece52b28`: `TestRun_AddLangMeldetNeueTargets` hält die Zeile
  `(kein Gate)`, Mutationsfall 535 färbt ihn rot; Gate-Zeile, Erstlauf und Bootstrap tragen die
  Fälle 532–534 (`make mutate` 3 ok, Verifikation).
- **Was ging anders als geplant:** DoD 1 sagte „ein Go-Test hält das" für beide Zeilen, gefahren war
  nur die Gate-Zeile; die kein-Gate-Zeile hielt allein `make full-smoke`. `internal/emit/emit.go`
  und `test/mutations/532–535` standen nicht in §3; mit der Closure nachgeführt. Über den
  DoD-Wortlaut hinaus meldet der Lauf den Wechsel `kein Gate` → Gate als NEUES GATE (Review F-2,
  durch §1 gedeckt).
- **Steering-Loop-Eintrag:** *Benannte Lücke*: die Meldung vergleicht nur Namen gegen einen
  vorhandenen Teil — eine Umbenennung erscheint als neu, ein Erstlauf in einem Alt-Ziel hebt kein
  Gate hervor (Review F-3); beide Ränder nennt das Handbuch, kein Lauf hebt sie hervor. Gezählt,
  nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** je `evidence/slice-lauf-meldet-neue-werkzeug-targets.md` in
  [`BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan`](../observations/BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan/observation.md)
  (erreicht **4×**; den Ausgang weist der Lese-Schritt der nächsten Welle-Closure zu, und nach
  `modul-06-roadmap.md` Schritt 3 verlangt die vierte Schwelle einen Sensor oder die Begründung,
  warum keiner möglich ist),
  [`BEO-ALL/beleg-faehrt-den-behaupteten-pfad-nicht`](../observations/BEO-ALL/beleg-faehrt-den-behaupteten-pfad-nicht/observation.md)
  (DoD 1, kein-Gate-Zeile; erreicht **3×**, Ausgang beim selben Lese-Schritt) und neu
  [`BEO-ALL/lauf-meldung-vergleicht-nur-namen-gegen-einen-vorhandenen-teil`](../observations/BEO-ALL/lauf-meldung-vergleicht-nur-namen-gegen-einen-vorhandenen-teil/observation.md)
  (Risiko 2, F-3).
- **Folge-Slices:** keiner.
- **Trigger-Audit:** Carveouts, Bootstrap-aware Gates, Hard Rules: keine berührt.
  [`ADR-0080`](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md)
  `Accepted`; die Meldung widerspricht keiner Festlegung, kein Trigger fällig.
- **Risiken aus §6:** jede Zeile trägt ihren Ausgang (1 *entfallen*, 2 *weiter offen*).
- **Archivierung:** keine bei dieser Closure — das Repo fährt Wellen, die nächste Welle-Closure
  sammelt den Slice ein ([`MR-078`](../../../../harness/conventions.md#mr-078)).
- **Paarungen geprüft am 2026-10-07** (nach dem Move `5148e754`): (a) *Anker*: §7 führt kein Feld
  `liegt in <Zielort>` (`grep -c` über §7 → 0). (b) *Folge-Slice*: keiner genannt; §1 trägt keine
  Slice-Kennung (`grep -oE 'slice-[a-z0-9-]+'` über §1 → leer). (c) *Register*: die drei zitierten
  Pfade existieren, `evidence/` trägt 4 · 3 · 1 Dateien (`ls <pfad>/evidence/*.md | wc -l`).
  Zweite Hälfte über das ganze Register: 3 Verzeichnisse ohne Beleg, namentlich
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/emit/`, `cmd/`,
`harness/tools/full-smoke.sh`, Handbuch); `TOOLS` deckt `harness/tools/` als Ort der Harness-Mechanik
— die neue Stufe ändert keine Mechanik, nur den E2E-Lauf; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`:
`regel-rand-ohne-benannte-luecke` (6, `verkörpert`) — die Grenze der Meldung (DoD 3, Risiken §6)
vollständig nennen; `plan-abweichung-landet-im-commit-bericht-statt-im-plan` (3, Ausgang beim
Lese-Schritt der nächsten Welle-Closure) — wer eine Datei außerhalb von §3 mitnimmt, trägt sie in §3
nach. Kein Eintrag erreicht mit diesem Slice 3×.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
