# Verifikation: slice-reviewer-skills-im-ziel-skip-if-present — 2026-10-07

**Rolle:** Verifier (Modul 11), frischer Kontext. **Gegenstand:** `d66451f5`, `361455f8`, `e8126fd0`,
`8c107d59`, `ee02d31e` gegen DoD des Slice-Plans und
[ADR-0084](../plan/adr/0084-reviewer-skills-im-ziel-skip-if-present.md); Review
`2026-10-07-skills-review.md`, Architect-Verdikt `2026-10-07-skills-architect-verdikt.md`.

## Verdikte je Liefer-Punkt

- **1 — Klasse und Meldung: bestätigt.**
  - Code: `Templates()` setzt für `.harness/skills/*` `skillWriter` (Meldung, dann
    `writeSkipIfPresent`); `skillMeldung` meldet nur bei Byte-Abweichung, Form wie
    `writeSkipIfPresentTold`, Vorlage `<vorlagen>/.harness/skills/<name>.template.md`.
    Einziger Produkt-Aufrufer `cmd/ai-harness-init/main.go:587` reicht
    `".harness/baseline/"+tag+"/templates"` und `notice` herein.
  - `TestTemplates_SkillsSkipIfPresent` fährt die drei Fälle (verändert/unverändert/fehlend).
  - Rot (b) **nachgetragen**: `case bytes.Equal(...)` → `case false && bytes.Equal(...)`,
    `make test` → EXIT 2, einziges `--- FAIL: TestTemplates_SkillsSkipIfPresent`,
    `templates_test.go:588: unveraenderter Skill .harness/skills/closure-note-reviewer.md gemeldet …`
    — die behauptete Ursache; danach `git checkout -- internal/emit/templates.go`.
  - Rot (a): nicht erneut gefahren; Beleg des Implementers in `e8126fd0`
    (`make mutate MUTATE_CASES='53-skills-konvergent …'`: 2 ok).
- **2 — Ziel: bestätigt.**
  - `make full-smoke` → EXIT 0 (404 s). Stufe *„Klasse der Reviewer-Skills"* gelesen: Re-Lauf meldet
    `.harness/skills/reviewer.md liegt bereits … Vorlage … unter .harness/baseline/v6.17.0/templates/.harness/skills/reviewer.template.md`;
    die Stufe prüft byte-gleich, Existenz der gemeldeten Vorlage im Ziel, Neuanlage des gelöschten
    `closure-note-reviewer.md` ohne Meldung, und keine Meldung des unveränderten Skills im Re-Lauf
    der Vorstufe (dort tatsächlich keine Skill-Zeile).
  - Rot **nachgetragen**: `sed` aus Fall 53 von Hand auf `internal/emit/templates.go`,
    `make full-smoke` → EXIT 2 mit
    `FEHLER — der Re-Lauf ueberschrieb den gefuellten .harness/skills/reviewer.md (skip-if-present verletzt, ADR-0084 Festlegung 1).`
    — FEHLER-Zeile der neuen Stufe; zurückgesetzt.
  - `docs/user/e2e-abdeckung.md` trägt die Stufe (Stufe 29) samt NICHT-gemessen-Grenze.
- **3 — Texte: bedingt.**
  - Erfüllt: Baum-Aussage leitet die gemeldeten Pfade aus Enforce ab (`gemeldetePfade`), Einzahl-Satz
    gefallen; `TestBaumAussage_NenntDieGemeldetenPfade` hält den Satz in beide Richtungen gegen
    einen realen Re-Lauf (Review M-1 damit behoben). `spec/architecture.md` §5 und `ARC-006` im
    Ist-Zustand.
  - **Befund V-1:** `docs/user/benutzerhandbuch.md:367` — in diesem Slice umgeschrieben — sagt nach
    commit-msg, den drei `.gitattributes` und den Skills *„Für die übrigen Dateien der zweiten
    Klasse bleibt er still."* Der Re-Lauf in `make full-smoke` meldet zusätzlich
    `harness/sensors/.gitkeep liegt bereits …` und `repo.mk liegt bereits …` (Log der Stufe
    *„Klasse des Commit-Traegers"*). Dieselbe Lücke, die M-1 im emittierten Text schloss, steht im
    Handbuch weiter; Handbuch und emittierte Baum-Aussage widersprechen sich jetzt. Die Aussage lag
    schon vor dem Slice so; der Slice zog sie nach, ohne sie zu korrigieren.
- **`make gates`:** nach dem Commit dieses Berichts gefahren (Ergebnis in der Übergabe an den Planner).
- **Review:** liegt vor; M-1 behoben (s. o.), M-2 per Architect-Verdikt ohne Folge-ADR.

## Plan-vs-Code

- Plan → Code: alle Zeilen der Plan-Tabelle §3 im Diff; [ADR-0007](../plan/adr/0007-bootstrap-phasen.md)
  unberührt (`git diff --stat d66451f5^ ee02d31e -- docs/plan/adr` leer).
- Code → Plan: `gemeldetePfade`/`backtickListe` gehen über DoD 3 hinaus (Liste aller gemeldeten
  Enforce-Pfade statt nur der zwei Skills) — gedeckt durch Review M-1. `ee02d31e` trägt eine fremde
  Message (ADR-0081, full-smoke); Inhalt ist der funlen-Nachzug in `baumaussage.go` — für die
  Closure zu nennen (Auftraggeber-Entscheidung).
- Risiko §6 (Meldung erreicht den Nutzer nicht): nicht eingetreten — einziger Produkt-Aufrufer
  reicht `notice` (= stderr), im Ziel sichtbar (full-smoke-Log).

## Offene Punkte für den Planner

- V-1 (Handbuch-Satz „übrige still"): Ausgang entscheiden — Nachzug in diesem Slice oder Folge-Slice.
