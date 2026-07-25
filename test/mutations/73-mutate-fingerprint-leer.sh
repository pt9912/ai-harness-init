#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: target_fingerprint FAELLT bei leerer Ziel-Liste
#
# Dreht die fail-closed-Schranke in target_fingerprint auf ERFOLG: bei leerer
# Ziel-Liste liefert sie dann Status 0 (und nichts), statt zu fallen. Damit meldete die fuenfte
# Bedingung ("der Host-Baum ist unveraendert") Erfolg, ohne je gemessen zu haben —
# das stille Gruen, gegen das dieser Sensor gerichtet ist.
#
# WARUM NICHT `|| true`: das war der erste Entwurf (gegen die damalige git-basierte
# Fassung), und `make mutate` meldete ihn korrekt als zahnlos — unter `pipefail`
# propagierte der Folgefehler ohnehin, die Funktion fiel weiterhin. `return 0`
# verlaesst die Funktion sofort und bricht die Eigenschaft wirklich.
# Der Anker `|| return 1` kommt in mutate.sh genau einmal vor (geprueft).
set -euo pipefail
sed -i 's/|| return 1/|| return 0/' harness/tools/mutate.sh
