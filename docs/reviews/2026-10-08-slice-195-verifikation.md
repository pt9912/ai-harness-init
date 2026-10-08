# Verifikation — slice-195 (Handbuch nennt die zugesagten Fähigkeiten)

* Rolle: Verifier (Modul 11) · Gegenstand: `5e701f80`, `bb8c97a5` gegen den Plan
  `slice-195-handbuch-nennt-die-zugesagten-faehigkeiten` (Welle `welle-handbuch-zeigt-den-bestand`)
* Eingang: Plan §1–§3/§6, Review `2026-10-08-slice-195-review.md` (LOW-1 in `bb8c97a5` behoben),
  Handbuch-Setzung (Ist-Zustand, keine Kennungen, keine Chronik)
* Prüfgrundlage: frisch emittiertes Ziel — `make host-bin`, dann
  `ai-harness-init --name meinrepo .` in einem `git init` unter dem Scratchpad (doc-only)
* Stichprobe statt Vollnachbau: das Review hat jede Aussage am Ziel gelesen und die
  Gate-Sicherheit der README-Verweise rot gesehen (`target-missing`, rc=2); hier nicht wiederholt.

## Verdikte je DoD-Punkt

- **(1) Workflow-Commands im Rumpf — bestätigt.**
  `grep -c '".claude/commands/' internal/emit/commands.go` → `3`;
  `grep -cE 'implement-slice|plan-welle|close-welle' docs/user/benutzerhandbuch.md` → `5` (vorher 0).
  Am Ziel: `.claude/commands/` = `close-welle.md implement-slice.md plan-welle.md`;
  `implement-slice.md` trägt `Argument: $ARGUMENTS`, `make gates`, Übergabe an
  `.harness/skills/reviewer.md`; `close-welle.md` §„Die sechs Schritte" deckt die Tabelle;
  `grep -c ANPASSEN` → 3/3/2 (je Datei ≥ 1, wie das Handbuch sagt).
- **(2) Review-Skills beschrieben — bestätigt.**
  `grep -ic 'reviewer' …` → `1` (vorher 0), `grep -c '\.harness/skills/' …` → `4`.
  Am Ziel: genau `reviewer.md`, `closure-note-reviewer.md`; Titel `<Repo-Name>` bleibt trotz
  `--name meinrepo`; Abschnitte `Kontext-Eingang`, `Klassifikation`, `Output-Schema` vorhanden;
  `closure-note-reviewer.md` prüft Inhalt vs. Floskel. Die LOW-1-Korrektur deckt sich mit
  `reviewer.md` Z. 5–13 (`Gilt für: <agent-review-Make-Target>`, Eingang „Diff des PR",
  Lastenheft, genannte ADRs, `AGENTS.md` Hard Rules); der fünfte Eingangs-Punkt (vorherige Findings)
  ist nicht genannt — keine Gegenaussage, kein Befund.
- **(3) Verweis-Abschnitt der README beschrieben — bestätigt.**
  `grep -icE 'pointer|vertrauenswürdig|vorwärts' …` → `1` (vorher 0). Am Ziel: „Was macht es
  vertrauenswürdig?" führt gefüllte Zeilen Prozess/Verträge/Auditierbarkeit mit Links auf
  `AGENTS.md`, `harness/README.md`, `spec/lastenheft.md`; allein *Gates:* ist Platzhalter — wie
  das Handbuch sagt. Rot-Beleg der Gate-Sicherheit: vom Review gefahren (s. o.), nicht nachgeholt.
- **`make gates` grün — bestätigt (Stempel).** `.harness/state/gates-passed.head` =
  `bb8c97a5…` = `git rev-parse HEAD`, Arbeitsbaum sauber; nicht erneut gefahren.
- **Closure-Punkte (Notiz, Register, Risiko-Ausgänge, Paarungen)** — offen, Planner-Arbeit
  (`AGENTS.md` §3.10); §6 trägt alle drei Ausgänge noch als `<offen>`.

## Plan vs. Doku

- Abschnitts-Wahl wie Plan §3: Aufgaben-Abschnitt mit Tabelle in §4, ein `###` in §6 nach den
  Bau-Dateien, §9 mit *Slash-Command* und *Skill*; Baum in §6 unberührt; `internal/emit/`,
  `spec/`, `docs/plan/adr/` unberührt (`git diff --stat 73f992c8 HEAD` → drei Dateien: Plan,
  Review, Handbuch). Kein Gebautes ohne Plan.
- `CLAUDE.md` und die Sprachenliste (Plan §6, ausgeschlossen) stehen im Diff nicht.
- Handbuch-Setzung: `git diff 73f992c8 HEAD -- docs/user | grep '^+' | grep -cE
  'LH-|ADR-|MR-|slice-|seit |bisher|neu ab|früher|künftig|geplant'` → `1`, der Treffer ist
  „gemeinsam **geplant** und geschlossen" (Definition einer Welle) — keine Kennung, keine Chronik.

## Findings

### LOW-1 — Plan §3: Begründung der Zeile „unverändert" hängt an der falschen Zeile

- `pfad`: Plan §3, Tabelle (Änderung in `5e701f80`)
- `befund`: Die Zeile `internal/emit/`, `spec/`, `docs/plan/adr/` | **unverändert** | hat nur noch
  zwei Zellen; ihre Begründung („es wächst keine Anforderung … die drei Fähigkeiten liegen (§1)")
  steht jetzt als **vierte** Zelle hinter der neuen Zeile *am Text entschieden* in einer
  dreispaltigen Tabelle — im Rendering entfällt sie, und die Unverändert-Zusage steht ohne Grund.
  Bedeutung, nicht Form: die Begründung gehört zur ersten der beiden Zeilen.
- `kommando`: `git show 5e701f80 -- docs/plan | grep '^[-+]|'`
- `adresse`: Planner bei der Closure (eine Zelle zurückschieben); verschiebt keine Abnahme.

## Negativbefunde

- Commands, Skills, README-Abschnitt, Glossar: jede geprüfte Handbuch-Aussage deckt sich mit dem
  frisch emittierten Ziel.
- Kein DoD-Punkt ist sicherheits- oder korrektheitskritisch im Sinn von Modul 11; der einzige
  Rot-Beleg (README-Verweise → `docs-check`) liegt im Review vor.

## Offene Punkte für den Planner

- Closure schreiben (§7, Register, drei Risiko-Ausgänge, Paarungen), LOW-1 dabei mitnehmen.
- Plan §2 benennt richtig: kein Gate hält die drei Beschreibungen — die Messungen oben sind
  Anwesenheit, nicht Deckung.
