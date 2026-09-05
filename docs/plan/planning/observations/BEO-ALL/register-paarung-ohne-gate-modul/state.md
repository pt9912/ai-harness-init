**Stand:** offen

Der gepinnte Doku-Gate-Stand trägt ein Modul für diese Hälfte: `planning.observations.dir` weist
eine zitierte Kennung `<pfad>` als nachgewiesen aus, wenn `<observations.dir>/<pfad>/observation.md`
existiert — genau die Verzeichnis-Form dieser Ablage
([`MR-052`](../../../../../../harness/conventions.md#mr-052)). Es ist **verfügbar, nicht
aktiviert**: `grep -m1 '^modules:' .d-check.yml` führt es nicht, und eine Aktivierung ist ein
Anheben über den Steering-Loop
([`MR-001`](../../../../../../harness/conventions.md#mr-001)) mit eigener Config-Entscheidung und
eigenem Trockenlauf. Die Deckung fehlt also weiter, und der Grund ist nicht mehr die fehlende
Fähigkeit des Fremd-Werkzeugs. **`d-check --print-config` beantwortet die Frage nicht** — es gibt
eine kommentierte Beispiel-Config aus, keine Schema-Liste.
