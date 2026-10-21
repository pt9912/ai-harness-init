#!/usr/bin/env bash
# files: harness/tools/extract-command.awk
# expect: extract (beide Fassungen): zwei Strings ohne Trenner -> Exit 3
#
# Nimmt dem Extraktor (Fassung dieses Repos) die Pruefung hinter dem String-Ende: ein
# weiteres `"` oder ein Zeichen ausserhalb von `: , } ]` und Leerraum haengt danach nicht
# mehr in Exit 3. Zwei Strings ohne Trenner im Feldwert liefern dann den zweiten mit
# Exit 0 — der erste Befehl geht verloren, und der Waechter urteilt ueber den zweiten.
#
# Rot werden in test/guard.bats die Faelle der Schleife ueber beide Fassungen: zwei
# Strings ohne Trenner und Zeichen hinter dem Feldwert (die Schleife meldet die
# gebrochene Fassung als `<pfad>: rc=0`). Die wohlgeformten Regressionsproben bleiben
# gruen.
#
# ANKER: die Zeile `if (c != ":" && c != "," && c != "}" && c != "]") exit 3` wird
# geloescht; `afterstr = 0` danach bleibt, die Marke wird weiter zurueckgesetzt.
set -euo pipefail
sed -i '/if (c != ":" && c != "," && c != "}" && c != "]") exit 3/d' harness/tools/extract-command.awk
