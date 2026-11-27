**Stand:** geplant

Zähler 3 (`ls evidence | wc -l`), Lese-Schritt ist die Closure von
`slice-binraire-ziehen-ohne-docker` ([`ADR-0085`](../../../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) Festlegung 1). Ausgang:
**geplant** — die Verkörperung schreibt die Welle-Closure von
`welle-ohne-docker` (Zug 3b, Planner → Architect → Planner). Kandidaten-Regel:
*kein Mutations-Fall-Skript direkt im Arbeitsbaum starten* — Kopie oder
`make mutate`/`make mutate-greift`; Zielort-Kandidaten sind die Rollen-Sätze
(`.claude/commands/implement-slice.md`, `.claude/agents/verifier.md`)
und `.harness/skills/reviewer.md`.
· seit slice-binraire-ziehen-ohne-docker
