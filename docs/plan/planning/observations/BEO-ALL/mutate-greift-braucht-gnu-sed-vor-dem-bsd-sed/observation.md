# `make mutate-greift` braucht GNU-`sed` vor dem BSD-`sed` und färbt sonst auf macOS

**Sub-Area:** `*` (gesamtes Repo)

`make mutate-greift` läuft auf dem Host und führt die Fall-Skripte unter `test/mutations/` aus, deren `sed -i` die GNU-Form voraussetzt. Auf einem macOS-Host mit dem BSD-`sed` des Systems vor GNU-`sed` im `PATH` meldet es 755 Befunde über dem Bestand, mit GNU-`sed` im `PATH` keinen (762 Fälle, 762 greifen). Die Voraussetzung steht für `make mutate` im Abschnitt *Lokaler Weg für `# verify: full-smoke`-Fälle auf macOS* von `harness/sensors/mutate.md`; für `make mutate-greift` ist sie dort nicht als eigene Aussage gemessen.

## Benannt, nicht gezählt

Drei Nachbarn tragen dieselbe Lage (Host-Lauf auf macOS, BSD- oder System-Variante eines Werkzeugs) mit anderem Werkzeug oder anderem Ziel und sind eigene Einträge:
[`mutate-auswahl-paste-ohne-operand-bricht-auf-bsd`](../mutate-auswahl-paste-ohne-operand-bricht-auf-bsd/observation.md),
[`mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32`](../mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32/observation.md),
[`lokaler-full-smoke-scheitert-auf-macos-host`](../lokaler-full-smoke-scheitert-auf-macos-host/observation.md).
Der Eintrag zum Full-Smoke nennt GNU-`sed` als Voraussetzung für `make mutate`; ob ein Eintrag die Klasse *Host-Werkzeug-Variante auf macOS* zusammenfassen soll, ist ungeurteilt.
