# Slice slice-stop-hook-bindet-an-den-commit: Der Stop-Hook bindet an den Commit

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht. Ziel-Release: `v0.5.0`.

**Bezug:**
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Festlegungen 1–7, §Fitness Function, Folgepflicht),
[ADR-0004](../../adr/0004-durchsetzungs-emission.md).

**Berührte Spec-Stellen:** `—` — [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) schärft kein Spec-Stratum.

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Stop-Hook blockiert im Dogfood und im Ziel nur noch einen neuen HEAD mit ungedecktem
Inhalt; das bisherige Verhalten gilt per Schalter
([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
Festlegungen 1–6).

**Lage** (keine Erwartungswerte): `grep -n 'state_file=' .claude/hooks/stop-require-gates.sh
internal/emit/templates/enforce/stop-require-gates.sh` nennt den heutigen Nachweis (`gates-passed.diffsha`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Folge-MR zu [`MR-002`](../../../../harness/conventions.md#mr-002)/[`MR-003`](../../../../harness/conventions.md#mr-003).**
  *Anderer Vorgang:* Architect-Artefakt (`AGENTS.md` §3.8); dieser Slice liefert die Übergabe
  (DoD-Zeile *Doku-Update*).
- **Format von `gates-passed.diffsha`, Checks und Kante von `record-gates`.** *Bestand bleibt:*
  weitere Leser (`full-smoke.sh`, `mutate.sh`), [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 3.
- **Schalter in `repo.mk` oder `.claude/settings.json`; das Werkzeug schreibt `.harness/stop-gate-streng`.**
  *Bestand bleibt:* von [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 6 verworfen bzw. Repo-Eigentum.
- **Codex-Seite.** *Schicht-Abgrenzung:* `.codex/hooks.json` führt keinen Stop-Hook.

## 2. Definition of Done

- [x] **1 — Hook und Stempel, Dogfood und emittiert:** beide Fassungen von `record-gates.sh`
      schreiben `.harness/state/gates-passed.head` (aufgelöste SHA, `kein-commit` eng nach §4); der
      Hook blockiert nur bei neuem HEAD **und** ungedecktem Inhalt, endet bei jedem unerwarteten
      Fehler mit Exit 2 (§5), streng bei Datei `.harness/stop-gate-streng` oder
      `STOP_GATE_STRENG=1` (§6). Ein Go-Test unter `make test` (`internal/emit/stophook_test.go`)
      fährt je Fassung den **echten** Hook und das echte `record-gates.sh` in einem tmp-Repo mit
      echtem `git` über den Fällen der Fitness-Zeile 1 — Go statt bats, weil das bats-Image kein
      `git` führt. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md)
      §3.6): die fünf Mutationsfälle der §Fitness Function in `test/mutations/`,
      `make mutate MUTATE_CASES=…` meldet jeden gebunden, Meldung gelesen.
- [x] **2 — Ziel:** `make selbstpruefung` am emittierten Hook — Turn-Ende ohne Commit frei, Commit
      ohne Nachweis blockiert —, gefahren von `make full-smoke` (EXIT 0); die Stufen-Deklaration
      nennt, was sie misst (`make e2e-abdeckung`).
- [x] **3 — Texte:** die Command-Vorlagen `implement-slice.md`, `plan-welle.md`, `close-welle.md`
      (`internal/emit/templates/commands/`) und der Stop-Hook-Satz in `CLAUDE.md` nennen die
      Commit-Bindung, den Schalter und die Grenze — Ist-Zustand, keine Chronik.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — Folge-MR mit Grenz-Zeile
      *„eine ‚fertig'-Meldung ohne neuen HEAD geht ohne Gate-Lauf durch; das Netz dort ist CI auf dem
      Push"* und Kopf-Marken an [`MR-002`](../../../../harness/conventions.md#mr-002) und
      [`MR-003`](../../../../harness/conventions.md#mr-003) nach [`MR-032`](../../../../harness/conventions.md#mr-032)
      ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 7).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/stop-require-gates.sh`, `internal/emit/templates/enforce/stop-require-gates.sh` | update | Commit-Bindung, Exit 2, Schalter (Liefer-Punkt 1) |
| `harness/tools/record-gates.sh`, `internal/emit/templates/enforce/record-gates.sh` | update | HEAD-Stempel als Zusatz |
| `internal/emit/stophook_test.go`, `test/mutations/` | neu / update | Fitness-Zeilen 1 und 3 (Go-Test: das bats-Image führt kein `git`) |
| `internal/emit/templates/enforce/selbstpruefung.sh`, `harness/tools/full-smoke.sh` | update | Liefer-Punkt 2 |
| Command-Vorlagen, `CLAUDE.md` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) `Accepted` (erfüllt); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Dogfood- und Ziel-Hälfte passen nicht in eine Review-Sitzung — dann wird
  Liefer-Punkt 2 mit den Texten als eigener Slice geschnitten.
- `in-progress` → `open`: ein Fall der Fitness-Zeile 1 ist mit den Festlegungen nicht entscheidbar
  (z. B. ein HEAD-Zustand außerhalb von §4) — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make full-smoke` EXIT 0 mit der Selbstprüfung am emittierten Hook.
2. `make gates` grün und die fünf Mutationsfälle als gebunden gemeldet.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Exit-2-Semantik der Hooks-Referenz im Repo ungemessen** ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) §5) — ein Exit-Code, den Claude
  Code anders liest, gäbe frei. — **Ausgang:** entfallen — die Semantik ist in der Referenz
  [`docs/user/claude-hooks-referenz.md`](../../../user/claude-hooks-referenz.md) belegt (Exit 2
  blockiert, Exit 1 nicht; Review INFO-2); ein Lauf gegen Claude Code selbst liegt in keinem Gate,
  die Grenze nennt [`MR-085`](../../../../harness/conventions.md#mr-085) — Urteil, kein Messwert.
- **Übergang nach dem Update** — ohne Stempel-Datei gilt der strenge Zweig bis zum ersten grünen Lauf
  (akzeptiertes Negativ); ein Klon im Ziel meldet das ggf. als Blockade ohne Grund. — **Ausgang:**
  entfallen — das Verhalten ist als akzeptiertes Negativ bestätigt (Verifikation, Zeile „Stempel
  gelöscht") und in den Texten aus Liefer-Punkt 3 genannt.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** LP 2 und 3 bestätigt, LP 1 im Verhalten bestätigt; `make full-smoke`
  EXIT 0 mit der Selbstprüfung am emittierten Hook; Dogfood-Hook vom Verifier selbst gefahren, Rot-Beleg
  für die Dogfood-Fassung nachgetragen
  ([Verifikation](../../../reviews/2026-10-07-stop-hook-verifikation.md)). Review 0 HIGH · 0 MEDIUM;
  LOW-2 behoben in `807071ba`
  ([Review](../../../reviews/2026-10-07-stop-hook-review.md)). Architect-Übergabe
  [`MR-085`](../../../../harness/conventions.md#mr-085) mit Kopf-Marken an `MR-002`/`MR-003` liegt als
  eigener Commit vor; Verifikations-Befund F-1 (Grenze `git switch --orphan`) behoben in `e04f60ff`.
- **Was ging anders als geplant:** Liefer-Punkt 1 nannte bats, geliefert ist ein Go-Test, weil das
  bats-Image kein `git` führt (Review LOW-1); DoD 1 und §3 sind im Closure-Commit auf das Werkzeug
  nachgezogen, die Regel-Spalte der Fitness Function ist unverändert gehalten.
- **Steering-Loop-Eintrag:** *Geschärfte Regel*: wechselt ein Lauf das Prüf-Werkzeug eines
  Liefer-Punkts, übergibt er den Wechsel dem Planner, bevor der Review ihn findet
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10, Übergabe-Artefakt). Nicht verkörpert, gezählt im
  Register (unten).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/pruef-werkzeug-gewechselt-ohne-uebergabe`](../observations/BEO-ALL/pruef-werkzeug-gewechselt-ohne-uebergabe/observation.md)
  neu (1×, Review LOW-1);
  [`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  Beleg ergänzt (Review INFO-1: `head_wert` viermal, Kopplung nur per Kommentar; Dogfood-Fassung
  ohne eigenen Mutationsfall) — 3×, Stand `offen` bis zum Lese-Schritt der nächsten Welle-Closure.
- **Folge-Slices:** keiner.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines berührt. ADR:
  [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) umgesetzt,
  kein Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine mit Auflösungs-Trigger aus diesem Vorgang.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: keiner genannt. (c) *Register*: die zwei genannten Pfade
  existieren, `evidence/` trägt 1 und 3 Dateien. Zweite Hälfte über das ganze Register: 3
  Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; sie gelten nicht als getragen
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`.claude/hooks/`, `internal/emit/templates/`,
`test/`, `CLAUDE.md`) und `TOOLS` (`harness/tools/record-gates.sh`, `full-smoke.sh` — adoptierte
Gate-Nachweis-Mechanik); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l 'stop-hook\|Stop-Hook\|record-gates\|Handoff' docs/plan/planning/observations/BEO-ALL/*/observation.md`):
`BEO-ALL/lauf-beleg-ist-zeitgebunden` (1, offen); daneben `BEO-ALL/gate-flaeche-haengt-am-arbeitsbaum`
(1, offen). Keiner erreicht mit diesem Slice 3×.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
