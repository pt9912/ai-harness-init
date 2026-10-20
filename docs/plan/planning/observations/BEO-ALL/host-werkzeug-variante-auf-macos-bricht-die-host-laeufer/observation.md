# Host-Werkzeug-Variante auf macOS bricht die Host-Läufer

**Sub-Area:** `*` (gesamtes Repo)

Die Host-Läufer dieses Repos (`harness/tools/mutate.sh`, `mutate-auswahl.sh`, die Fall-Skripte unter `test/mutations/`, `full-smoke.sh`/`smoke.sh` über `make artifact`) laufen auf dem Host, nicht im Container, und nehmen GNU/Linux-Werkzeuge an: Bash ≥ 4, GNU-`sed -i`, GNU-`paste`, ein Linux-Binary als Träger. Auf einem macOS-Host trifft jede dieser Annahmen auf die BSD- oder System-Variante und bricht oder liefert leise Exit 0. Gemeinsame Ursache: der Host ist macOS, die Skripte nehmen GNU/Linux an; die Docker-only-Regel (`AGENTS.md` §3.9) deckt Läufer nicht, die auf dem Host selbst laufen.

Dieser Eintrag fasst die Klasse zusammen. Die Belege stehen unter `evidence/` als Verweis auf die Einzel-Einträge, nicht als Kopie; die vier Einzel-Einträge bleiben stehen:
[`mutate-auswahl-paste-ohne-operand-bricht-auf-bsd`](../mutate-auswahl-paste-ohne-operand-bricht-auf-bsd/observation.md),
[`mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32`](../mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32/observation.md),
[`lokaler-full-smoke-scheitert-auf-macos-host`](../lokaler-full-smoke-scheitert-auf-macos-host/observation.md),
[`mutate-greift-braucht-gnu-sed-vor-dem-bsd-sed`](../mutate-greift-braucht-gnu-sed-vor-dem-bsd-sed/observation.md).

## Benannt, nicht gezählt

Nicht Teil der Klasse, weil ein anderer Mechanismus: `mess-rezept-setzt-unbenannte-host-konfiguration-voraus` (Host-Konfiguration wie git-Identität, eigener Ausgang *geplant*) und `bind-mount-sicht-auf-umgeschriebene-dateien-ist-unter-macos-verzoegert` (Mount-Verzögerung, unter der Schwelle).
