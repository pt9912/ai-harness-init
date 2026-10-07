# Archiv-Grenze über einer Merge-Historie ungemessen

**Sub-Area:** `*` (gesamtes Repo)

Die Einordnung der Archiv-Läufe liest den Add-Commit eines Slice per `git log --diff-filter=A`; über
einen Merge eingebrachte Pfade liefern ggf. keinen oder einen anderen Commit. Kein Test und keine
`full-smoke`-Stufe baut eine Historie mit Merge; die Stufe deklariert „lineare Historie".
