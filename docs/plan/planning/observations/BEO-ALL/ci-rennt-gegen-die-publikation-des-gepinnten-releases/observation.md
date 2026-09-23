# CI rennt gegen die Publikation des gepinnten Releases

**Sub-Area:** `*` (gesamtes Repo)

Ein Commit, der `TRAEGER_TAG` auf eine noch unveröffentlichte Fassung zieht und denselben Stand als
Tag pusht, triggert zwei Workflows nebeneinander: der `ci`-Lauf fährt im `full-smoke` den
`traeger-fetch` aus dem **gepinnten** Release, während der `release`-Lauf seine Assets erst noch
publiziert — die Anfrage 404t, und der Fetch fällt fail-closed (`ADR-0058` Festlegung 2: laut-Bruch
statt stiller Ausweichung). Der Schnitt-Commit ist damit bis zur Publikation **unerreichbar grün**;
die erste Lage der Klasse, denn `v0.2.1` wurde geschnitten, bevor der Fetch-Schritt in
`full-smoke` lag.

## Benannt, nicht gezählt

Das Auftreten vom 2026-09-23 (Tag-Push `v0.2.2`, Commit `0591a414`) trug kein
abgeschlossener Vorgang — der Release-Schnitt ist ein wellenloser Posten; die zwei `ci`-Läufe
(`main` und Tag) fielen beide am `traeger-fetch` mit Exit 2/404, während der `release`-Lauf
erfolgreich publizierte. Der operative Ausgang dieses Auftretens war ein Re-Run nach der
abgeschlossenen Publikation.