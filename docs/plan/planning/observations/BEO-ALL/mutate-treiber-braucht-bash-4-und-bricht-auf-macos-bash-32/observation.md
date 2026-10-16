# Der Mutations-Treiber braucht Bash ≥ 4 und bricht auf dem macOS-System-Bash

**Sub-Area:** `*` (gesamtes Repo)

`harness/tools/mutate.sh` läuft auf dem Host, nicht im Container. Steht auf einem macOS-Host die Bash 3.2 des Systems vor einer neueren Bash im `PATH`, bricht der Treiber an Zeile ~910 mit `local: -A: invalid option` ab (assoziatives Array, Bash ≥ 4). Gemessen ist allein diese Zeile; weitere Bash-4-Stellen sind nicht gesucht. Die Voraussetzung steht in keiner Doku des Treibers. Nachbar mit anderem Werkzeug, derselben Lage: `BEO-ALL/mutate-auswahl-paste-ohne-operand-bricht-auf-bsd`.
