#!/usr/bin/env bash
# files: internal/report/report.go
# expect: der Leser meldet seine Leere OHNE ihren Grund
# verify: full-smoke
#
# NIMMT DEN GRUND-SATZ AUS DER AUSGABE DES LESERS: er meldet dann noch seine Leere,
# aber nicht mehr, woher sie kommt.
#
# Eine Abdeckungs-Zeile ueber einem Bestand ohne Verbrauchs-Zaehler meldet einen
# ZUSTAND und laesst offen, ob er morgen anders ist. Die Grenze ist eine andere
# Aussage: dass die Zaehler an der Mechanik des Agenten-Werkzeugs haengen und kein Lauf
# des Adopters sie herbeifuehrt. Ohne sie liest ein Adopter die Leere als Defekt seiner
# Erfassung und sucht einen Fehler, den es nicht gibt — die Einloesung von ADR-0021
# Folgepflicht 6 im Ziel waere eine Absicht.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage ist, dass ein
# ADOPTER den Satz in SEINEM Repo liest. Der Weg dorthin ist die Kette Aggregator ->
# emittiertes Fragment -> abgelegter Traeger -> Bestand, und die gibt es nur im echten
# Bootstrap. Kein Go-Waechter behauptet diesen Satz; behauptete einer ihn, waere er die
# schmalere Stufe und dieser Fall gehoerte dorthin. Der Preis des Modus steht im Kopf
# von harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@^func leereDerZaehler() string { return keineBilanz + grundDerZaehler }$@func leereDerZaehler() string { return keineBilanz }@' internal/report/report.go
