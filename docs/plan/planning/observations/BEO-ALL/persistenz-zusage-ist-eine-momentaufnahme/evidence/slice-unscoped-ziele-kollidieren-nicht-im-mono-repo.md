**Vorgang:** slice-unscoped-ziele-kollidieren-nicht-im-mono-repo
**Fund:** Plan §3 ("Gewählte Form") und drei Code-Kommentare (`cmd/ai-harness-init/main.go`,
`internal/gen/golang.go`, `internal/gen/cpp.go`) behaupteten, das zuerst schreibende
Sprach-Fragment behalte dauerhaft sein unscoped-Rezept. Der eigene Konvergenz-Test
(`TestRun_AddLangMixedRoot`, Re-Lauf-Block) widerlegt das: Wird das zuerst geschriebene
Fragment erneut geschrieben, verliert *es selbst* sein Rezept — nach einem dritten Schreiben
trägt keines der beiden Fragmente mehr die ursprüngliche Form. Review-Finding F-1 (MEDIUM),
`docs/reviews/2026-09-20-slice-unscoped-ziele-kollidieren-nicht-im-mono-repo-runde-1.md`.
Behoben in Commit `e1008ecc` — die Zusage wurde auf die tatsächlich haltbare Eigenschaft
eingeschränkt (Präzedenz-Erweiterung ist stabil, welches Fragment das Rezept trägt nicht).
