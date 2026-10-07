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

**Verantwortlich:** —

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
  weitere Leser (`full-smoke.sh`, `mutate.sh`), ADR-0083 Festlegung 3.
- **Schalter in `repo.mk` oder `.claude/settings.json`; das Werkzeug schreibt `.harness/stop-gate-streng`.**
  *Bestand bleibt:* von ADR-0083 Festlegung 6 verworfen bzw. Repo-Eigentum.
- **Codex-Seite.** *Schicht-Abgrenzung:* `.codex/hooks.json` führt keinen Stop-Hook.

## 2. Definition of Done

- [ ] **1 — Hook und Stempel, Dogfood und emittiert:** beide Fassungen von `record-gates.sh`
      schreiben `.harness/state/gates-passed.head` (aufgelöste SHA, `kein-commit` eng nach §4); der
      Hook blockiert nur bei neuem HEAD **und** ungedecktem Inhalt, endet bei jedem unerwarteten
      Fehler mit Exit 2 (§5), streng bei Datei `.harness/stop-gate-streng` oder
      `STOP_GATE_STRENG=1` (§6). bats über dem **echten** Hook und dem echten `record-gates.sh` in
      einem tmp-Repo mit den Fällen der Fitness-Zeile 1. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md)
      §3.6): die fünf Mutationsfälle der §Fitness Function in `test/mutations/`,
      `make mutate MUTATE_CASES=…` meldet jeden gebunden, Meldung gelesen.
- [ ] **2 — Ziel:** `make selbstpruefung` am emittierten Hook — Turn-Ende ohne Commit frei, Commit
      ohne Nachweis blockiert —, gefahren von `make full-smoke` (EXIT 0); die Stufen-Deklaration
      nennt, was sie misst (`make e2e-abdeckung`).
- [ ] **3 — Texte:** die Command-Vorlagen `implement-slice.md`, `plan-welle.md`, `close-welle.md`
      (`internal/emit/templates/commands/`) und der Stop-Hook-Satz in `CLAUDE.md` nennen die
      Commit-Bindung, den Schalter und die Grenze — Ist-Zustand, keine Chronik.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — Folge-MR mit Grenz-Zeile
      *„eine ‚fertig'-Meldung ohne neuen HEAD geht ohne Gate-Lauf durch; das Netz dort ist CI auf dem
      Push"* und Kopf-Marken an [`MR-002`](../../../../harness/conventions.md#mr-002) und
      [`MR-003`](../../../../harness/conventions.md#mr-003) nach [`MR-032`](../../../../harness/conventions.md#mr-032)
      (ADR-0083 Festlegung 7).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/stop-require-gates.sh`, `internal/emit/templates/enforce/stop-require-gates.sh` | update | Commit-Bindung, Exit 2, Schalter (Liefer-Punkt 1) |
| `harness/tools/record-gates.sh`, `internal/emit/templates/enforce/record-gates.sh` | update | HEAD-Stempel als Zusatz |
| `test/*.bats`, `test/mutations/` | neu / update | Fitness-Zeilen 1 und 3 |
| `internal/emit/templates/enforce/selbstpruefung.sh`, `harness/tools/full-smoke.sh` | update | Liefer-Punkt 2 |
| Command-Vorlagen, `CLAUDE.md` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): ADR-0083 `Accepted` (erfüllt); WIP-Limit frei.

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

- **Exit-2-Semantik der Hooks-Referenz im Repo ungemessen** (ADR-0083 §5) — ein Exit-Code, den Claude
  Code anders liest, gäbe frei. — **Ausgang:** offen bis zur Closure.
- **Übergang nach dem Update** — ohne Stempel-Datei gilt der strenge Zweig bis zum ersten grünen Lauf
  (akzeptiertes Negativ); ein Klon im Ziel meldet das ggf. als Blockade ohne Grund. — **Ausgang:**
  offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

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
