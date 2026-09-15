# `--amend` committet fremde Index-Einträge mit

**Sub-Area:** `*` (gesamtes Repo)

Ein Lauf korrigiert seinen letzten Commit mit `git commit --amend`, und im **Index** liegen daneben
Dateien, die ein **parallel** laufender Vorgang dort abgelegt hat. `--amend` committet den **Index**,
nicht die Pfade des eigenen Vorgangs, und reißt den fremden Commit samt seiner Dateien in den neuen.
Der Schaden ist nicht die Nachricht — er ist die **Historie**: Der fremde Commit verschwindet als
eigener Punkt, und der Audit sieht einen Commit, der zwei Vorgänge trägt; nach einem Push ist er
nicht mehr behebbar, ohne Historie zu schreiben.

Die Fehlerrichtung ist *der Index gehört mir*. In einem Repo mit einem Schreiber je Rolle ist der
Index faktisch exklusiv, und die Angewohnheit hält über den Fall hinaus, in dem er es nicht mehr
ist; teuer wird sie erst dort, wo mehrere Rollen gleichzeitig arbeiten — **und genau dann wird
parallel committet**. Der Fehler ist selbstheilend nur um den Preis eines `git reset --soft` und
eines pfadreinen Nachzugs, also nur, solange der fremde Commit nicht gepusht ist.

## Benannt, nicht gezählt

Zwei Nachbarklassen greifen hier **nicht**, und das ist der Grund, warum die Klasse einen eigenen
Eintrag braucht. Ein `commit-msg`-Wächter fängt die **Nachricht** eines Commits, nicht seinen
**Inhalt**; kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest den Index. Die Abhilfe ist eine **Disziplin**
— `git commit --only <pfad>` legt genau die genannten Pfade in den Commit, statt alles Gestagte —,
und sie ist mit einem `pre-commit`-Hook **baubar**; gebaut ist keines von beiden.
