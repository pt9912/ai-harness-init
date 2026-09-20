**Vorgang:** slice-unscoped-ziele-kollidieren-nicht-im-mono-repo
**Fund:** Zwei aufeinanderfolgende Commits (`1d8c0081`, `3d818d90`) tragen wortgleiche
Commit-Messages, obwohl der zweite ein inhaltlicher Fix ist (entfernt fälschliche
`--build-arg`-Marker und `einordnen`-Aufrufe aus dem E2E-Zahn). Review-Finding F-4 (LOW),
`docs/reviews/2026-09-20-slice-unscoped-ziele-kollidieren-nicht-im-mono-repo-runde-1.md`.
Bewusst nicht behoben — Wartungs-Nit ohne Failure-Pfad am Gate, kein Rewrite der
Commit-Historie für einen bereits gemergten Stand.
