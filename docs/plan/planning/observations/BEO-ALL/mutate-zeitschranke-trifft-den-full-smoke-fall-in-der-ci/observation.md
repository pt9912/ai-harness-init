# Die Zeitschranke des Mutations-Treibers trifft einen full-smoke-Fall in der CI

**Sub-Area:** `*` (gesamtes Repo)

Im CI-Branch-Lauf (`mutate-branch`, Worker auf einem Runner) endete ein Shard an der Zeitschranke des Treibers (`STALL_SECONDS`, 900 s in `harness/tools/mutate.sh`:
„seit 900 s hat kein Worker einen Fall gezogen oder abgeschlossen", Worker Status 137), und der Fall blieb ohne Ergebnis; ein zweiter `full-smoke`-Fall desselben
Laufs brauchte 862 s. Die Herleitung der Schranke im Kopf von `mutate.sh` nennt `full-smoke` mit 148,97 s als längste legitime Stille und die CI als 2,4× langsamer; die
CI-Messung liegt darüber. Die Klasse umfasst nicht den 404 auf ein unveröffentlichtes Release (`ci-rennt-gegen-die-publikation-des-gepinnten-releases`) und nicht den
roten Grün-Vorlauf unter Last (`gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`): hier fällt weder ein Test noch ein Fetch, die Zeit allein reicht nicht.

## Benannt, nicht gezählt

Welcher Anteil der 862 s auf den Grün-Vorlauf und welcher auf den Fall entfällt, ist nicht gemessen; ebenso, ob die Ursache die Runner-Last, ein kalter Cache oder
die Fall-Länge selbst ist.
