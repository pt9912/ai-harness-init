# Marker-Ziehung folgt dem Claim mit Versatz

**Sub-Area:** `*` (gesamtes Repo)

Der Ruhe-Marker der Offenen Wellen („Nichts in Arbeit.") wird **nicht** im Claim-Commit des
Slices gezogen, sondern erst ein bis zwei Commits später — zwischen Claim und Korrektur trägt
der Hauptzweig den Marker gegen einen belegten Slice in `in-progress/` (beobachtbar als
`d-check`-`planning`-Drift am Zwischenstand). Ursache ist die reine-Move-Form des Claims
(Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine): der Move
trägt keine Inhalte, und keine Quelle bindet die Reihenfolge der zwei Commits.
