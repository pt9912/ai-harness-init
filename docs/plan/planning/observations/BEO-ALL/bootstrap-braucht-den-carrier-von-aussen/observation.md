# Der Bootstrap braucht den Gate-Carrier von außen

**Sub-Area:** ALL (gesamtes Repo)

**Kurzbeschreibung:** die Zusage „Bootstrap braucht nur git" ist auf dem
Carrier-Weg der emittierten Gates-Kante nicht erreicht: das gebootstrappte
Ziel liest `DCHECK_CARRIER` als Umgebungsaufgabe (`--print-mk`-Weg), bevor der
Bootstrap-Lauf läuft — ohne von außen gelieferten Carrier bleibt der
Default-Weg Docker-getrieben, und die d-check-Ablage im Ziel entsteht ebenso
von außen (oder einmalig über `make dcheck-fetch`, Netz). Der Default-Weg ist
damit kein git-only-Weg.
