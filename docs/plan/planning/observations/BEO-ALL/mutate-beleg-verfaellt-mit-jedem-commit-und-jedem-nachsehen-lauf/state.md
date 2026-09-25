**Stand:** geplant

Kennung: `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`. Die Bezugsmenge
des Schlüssels verengt sich um Zeitdokumente durch Ausschluss aus der Isolationskopie, und eine reine
Beleg-Prüfung beantwortet, ob der Beleg am Endstand gilt, ohne einen Lauf zu starten. Der Slice wendet
[`ADR-0035`](../../../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3 und Trigger 1 an; die ADR steht auf `Proposed`.

Nach der Closure des Slice steht der Stand `verkörpert`, Zielort `harness/tools/mutate.sh` mit dem
Herkunfts-Anker `seit slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`.

Ein Wächter besteht nicht für den Rest: Ein Commit, der eine von einem Sensor gelesene Datei ändert
— `docs/plan/planning/in-progress/roadmap.md`, eine Slice-Datei in `docs/plan/planning/in-progress/` —,
entwertet den Beleg weiterhin. Das ist eine Eigenschaft der Bauart, keine Verletzung einer Regel; die
Rolle, die den Beleg braucht, fragt nach ihm oder fährt den Lauf am Endstand selbst.
