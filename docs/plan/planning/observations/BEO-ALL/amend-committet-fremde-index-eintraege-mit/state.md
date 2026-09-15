**Stand:** offen

Ein Wächter besteht nicht. `make commit-msg-check` liest eine Commit-**Message**-Datei gegen die
Traceability-Kennung, `make history-range-guard` prüft eine Commit-**Range** auf Auflösbarkeit — der
**Index** eines Commits kommt in keinem der beiden vor, und kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest ihn. `make mutate` kennt keine
Fehlschlag-Form für einen Commit-Zuschnitt.

Träger ist der schreibende Lauf: Er weiß, welche Pfade sein Vorgang angefasst hat, und nur er kann
seine Commits pfadrein setzen. Ein `pre-commit`-Hook oder eine Pfadspec-Disziplin ist **baubar**;
gebaut ist keines. Ein Norm-Artefakt, das den Träger festhält, besteht nicht — den Zielort
schneidet der Lese-Schritt.
