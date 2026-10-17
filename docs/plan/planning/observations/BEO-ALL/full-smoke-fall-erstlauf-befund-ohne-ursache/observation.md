# Erstlauf eines `full-smoke`-Mutationsfalls meldet BEFUND ohne ermittelte Ursache

**Sub-Area:** `*` (gesamtes Repo)

Ein Mutationsfall, der über `make mutate` die `full-smoke`-Stufe fährt, meldet im ersten Lauf `BEFUND` mit
Status 1; Wiederholungen derselben Fälle sind grün. Die Ursache ist nicht ermittelt (Netz bei der
Paketinstallation im `docker build` oder gleichnamige Image-Tags im Docker-Daemon sind benannt, nicht
belegt); ein solcher Befund färbt den Fall rot und nie ein falsches `ok` (Fall 695, Python-Stufe).
