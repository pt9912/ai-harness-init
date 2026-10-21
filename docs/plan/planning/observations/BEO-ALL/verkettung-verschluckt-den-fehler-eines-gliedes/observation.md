# Verkettung verschluckt den Fehler eines Gliedes

**Sub-Area:** `*` (gesamtes Repo)

Ein Skript oder Rezept verkettet mehrere Glieder (Schleife über Dateien, Strom mit Trennzeilen, Pipe), und das Ergebnis der Kette trägt nur den Exit des letzten Gliedes oder eine Zählung, die ein immer gedrucktes Element mitzählt. Scheitert ein früheres Glied, bleibt die Kette grün und die Eigenschaft *geprüft* gilt für eine Datei, die nie gelesen wurde; das Verhalten hängt an der Reihenfolge der Glieder.

## Benannt, nicht gezählt

**Verwandt, nicht gezählt:** `BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung` (der Status des letzten Schleifendurchlaufs bestimmt den Fall) — anderes Objekt (bats-Zusicherung statt Gate-Skript), kein Beleg dieser Klasse.

**Andere Verkettungs-Skripte nicht gemessen.** `harness/tools/traeger-pins-check.sh` und die übrigen Skripte unter `harness/tools/` setzen `set -euo pipefail` (`grep -c "pipefail" harness/tools/traeger-pins-check.sh`), das fängt die Pipe, nicht die Schleife über Dateien; ob dieselbe Klasse dort besteht, hat kein Lauf gelesen.

**Ein Sensor für den Exit-Pfad von `harness/tools/bats-lint.sh` ist nicht baubar:** ein Mutations-Fall färbte den Lauf grün, den er rot lassen soll; ein bats-Test liefe im bats-Image ohne `docker`, das Skript ruft aber `docker`. Der Pfad ist nur von Hand rot gesehen (Symlinks ins Leere, je Exit 2).
