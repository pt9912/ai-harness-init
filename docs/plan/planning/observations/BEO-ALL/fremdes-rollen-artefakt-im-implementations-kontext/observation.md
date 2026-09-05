# Fremdes Rollen-Artefakt im Implementations-Kontext

**Sub-Area:** `*` (gesamtes Repo)

Ein Lauf ändert im Implementations-Kontext ein Artefakt, dessen Eigentum eine Quelle einer anderen
Rolle zuweist, und begründet das mit einer Ausnahme, die keine Quelle trägt — typischerweise dort,
wo die Änderung wie ein mechanischer Pfad-Nachzug aussieht und die Eigentums-Frage darum gar nicht
gestellt wird. Der Träger der Regel ist der Rollenwechsel **vor** der Änderung; kein Modul der
[`.d-check.yml`](../../../../../../.d-check.yml) liest Commits, und `make mutate` kennt keine
Fehlschlag-Form für einen Commit-Zuschnitt.
