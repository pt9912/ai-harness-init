# Repo-Werkzeug führt eine Host-Abhängigkeit ein

**Sub-Area:** `*` (gesamtes Repo)

Ein Werkzeug oder Sensor des Repos ruft ein Programm auf dem Host auf (hier `unzip` in `archiv_gueltig`
von `harness/tools/full-smoke.sh`), obwohl der Host nach [`AGENTS.md`](../../../../../../AGENTS.md) §3.9
nur `git`, `docker` und GNU `make` braucht. Der Lauf ist auf dem Host des Schreibers grün und bricht
auf einem Host ohne das Programm an einer Stelle ab, die mit der Messung nichts zu tun hat. Der
PreToolUse-Guard sieht nur Befehle des Agenten, nicht Aufrufe innerhalb eines Skripts.
