# Verifikation slice-adopter-seite-der-anweisungssatz-grenze

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-08 · **Stand:** `8c14fcee` (Diff `2a9ca452`, `b1a8195d`,
`8c14fcee` gegen `4c456e2b`) · **Bezug:** ADR-0086 (Accepted), ADR-0051, ADR-0028 · **Empfänger:** Planner.
Review `2026-10-08-adr-0086-review` hat die ADR vollständig gelesen; hier gemessen, nicht übernommen.

## Verdikte je DoD-Punkt

- **LP 1 — Adopter-Seite entschieden: bestätigt.** ADR-0086 Festlegung 1 (Ausgang *keine Aussage*, mit Grund),
  Festlegung 2 (Ort: Adaptions-Block der `harness/conventions.md` oder Hard Rule in der `AGENTS.md` des Adopters),
  Festlegung 3 (Geltungsbereich, `.claude/agents/*.md` ausgenommen). Index-Zeile: `grep -n '0086' docs/plan/adr/README.md`
  → Zeile 93, `Accepted`.
- **LP 2 — Quelle fortgeschrieben: bestätigt.** ADR-0051 trägt `Accepted` → Zweig *Folge-ADR*: ADR-0086 führt
  `Supersedes (Teil)`, die Klammer-Marke steht an Zeile 58 des Index (Form wie ADR-0041 ← ADR-0081, Zeile 48).
  ADR-0051 selbst unberührt: `git log --oneline 4c456e2b..HEAD -- docs/plan/adr/0051-*.md | wc -l` → 0. Der abgelöste
  Satz existiert: `tr '\n' ' ' < docs/plan/adr/0051-*.md | grep -o 'Für das Ziel ist sie es[^.]*'` → 1 Treffer
  (im Original fett gesetzt). Review-F-3 (Marke vor Accept) ist damit erledigt.
- **`make gates`: bestätigt über den Stempel, nicht selbst gefahren.** `.harness/state/gates-passed.head` =
  `git rev-parse HEAD` = `8c14fcee`, Baum sauber; dieser Bericht ändert nur sich selbst.
- **Review: bestätigt.** Report liegt vor, `0 HIGH · 1 MEDIUM · 1 LOW · 1 INFO`; F-1 und F-2 sind in `b1a8195d`
  eingearbeitet (§Kontext nennt *„R aktualisiert Skill-Datei"*, Trigger 1 benennt den Wort-Grep als Grenze).
- **Doku-Update (= LP 1): bestätigt.**
- **Reconciliation: entfällt bestätigt** (`ls reconciliation.md docs/plan/reconciliation.md` → beide fehlen).
- **Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge: offen — Planner-Closure**, kein Verifier-Gegenstand.
- **Rot-Beleg:** entfällt — kein DoD-Punkt beruft sich auf einen Test; ADR-0086 §Fitness Function benennt die
  Lücke selbst (Abwesenheit einer Norm-Aussage, kein Modul liest Rollen-Zuordnungen).

## Messungen der ADR-0086, nachgefahren

| Kommando | ADR | gemessen |
|---|---|---|
| `git grep -l 'Dieser Command führt die' -- internal/emit/templates/commands/ \| wc -l` | 3 | 3 |
| `grep -rn 'Anweisungssatz' .harness/baseline/v6.17.0/regelwerk/*.md \| wc -l` | 0 | 0 |
| `grep -rn 'claude/commands' .harness/baseline/v6.17.0/ \| wc -l` | 1 | 1 (`grundlagen-durchsetzungsschicht.md:112`, Artefakt-Liste) |
| `grep -c 'R aktualisiert Skill-Datei' …/modul-08-agentenrollen.md` | 1 | 1 (Zeile 218) |

Stützende Aussagen geprüft: Commands `SkipIfPresent` (`internal/emit/commands.go:30-32`), Kurs-Vorlagen eine
Klasse SKIP-IF-PRESENT (`internal/emit/templates.go:320`), Skills `writeSkipIfPresent` (`templates.go:337-345`).
Keine Baseline-Stelle nennt eine Rolle für Commands (`grep -rni command …/regelwerk/*.md | grep -iE 'rolle|schreibt|gehört|architect|planner|implementer|reviewer'` → leer).

## Plan gegen Artefakt

- **Emission unverändert: bestätigt.** `git diff --name-only 4c456e2b HEAD` → nur ADR-0086, ADR-Index, Review-Report;
  nichts unter `internal/`. Die Command-Vorlagen nennen die **ausführende** Rolle, keine Eigentums-Aussage über die Datei
  (die `gehört`-Treffer in `internal/emit/templates/commands/` sind Prozess-Sätze, kein Eigentum).
- **Nichts gebaut ohne Plan.** Der Geltungsbereich *Commands und Reviewer-Skills* liegt innerhalb des Begriffs
  Anweisungssatz (ADR-0028); Typkarten sind wie §1 ausgenommen.
- **Rückführungen nicht eingetreten: bestätigt.** `in-progress → next`: ADR-0086 Festlegung 3 *„sie zerfällt nicht"* —
  eine Antwort für beide Klassen. `in-progress → open`: ADR-0051 hat sich unter dem Lauf nicht bewegt (0 Commits, s. o.);
  die Teil-Ablösung ist der Ausgang dieses Slice, nicht eine fremde Überholung.
- **§1-/§8-Bestandszahlen veraltet: bestätigt** (datierte Messungen, keine Erwartungswerte — kein Bruch einer Zusage,
  aber die Closure liest sie):
  - `git ls-files internal/emit/templates/ | wc -l` → **39** (Plan 25).
  - `git grep -c 'writeSkipIfPresent' -- internal/emit/commands.go` → **kein Treffer** (Plan 1); die Aussage
    *Commands sind skip-if-present* hält weiter, getragen vom Klassen-Feld `class: SkipIfPresent`.
  - `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **232** (Plan 115).
  - Zähler (Evidence-Dateien): `anweisungssatz-eigentum-ohne-quelle` 5 (=), `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`
    **12** (Plan 1, Stand `geplant` — ADR-0062, `Proposed`), `uebergabe-an-andere-rolle-ohne-traeger-artefakt` 7 (6),
    `fremdes-rollen-artefakt-im-implementations-kontext` 9 (=), `zusammenfassung-staerker-als-ihre-quelle` 9 (8),
    `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` 7 (6).

## Offene Punkte für den Planner

- §6 Risiko (2) und §8 („keiner erreicht 3×") lesen gegen 1× — real 12× mit Ausgang `geplant`; der Ausgang des Risikos
  ist gegen den heutigen Stand zu setzen. Sachlich: Ausgang *keine Aussage* mit benanntem Ort (Festlegung 2) nimmt dem
  Risiko den Gegenstand; Risiko (1) fängt Festlegung 3, Risiko (3) ist nicht eingetreten (s. Rückführungen).
- §7 `BEO-ALL/anweisungssatz-eigentum-ohne-quelle`: ob ADR-0086 die emittierte Ebene schließt, entscheidet die Closure.
- Keine Frage an den Architect.
