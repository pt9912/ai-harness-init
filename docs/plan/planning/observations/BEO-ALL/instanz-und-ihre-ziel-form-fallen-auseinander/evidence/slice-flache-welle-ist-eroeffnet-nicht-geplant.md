**Vorgang:** slice-flache-welle-ist-eroeffnet-nicht-geplant
**Fund:** Beide Richtungen der Klasse in einem Vorgang — für den Zähler **eine** Gelegenheit, und
zugleich die Erstauftreten, die ihr die Kennung geben.

**Nach vorn** (Runde 1, F-2, MEDIUM, merge-blockierend): Der Nachzug glich
`docs/plan/planning/README.md` §Slices vs. Wellen an die Kopfnote der **Welle**-Vorlage an — den
Text, der für dieselbe Arbeit ohnehin offen lag — statt an `README.template.md` §Slices vs. Wellen,
die das Instanz-Register `harness/migration.md` für genau diese Datei führt. Dabei entfiel die
Zuschreibung *Sequenzierungs-Autorität* an die Roadmap, die beide Seiten trugen — der Bestand vor
dem Diff und die richtige Ziel-Form —, und die die Welle-Kopfnote gar nicht führen kann: Sie
beschreibt ein anderes Artefakt.

**Nach hinten** (Runde 2, R2-2, INFO): Dieselbe Datei führt in §Lifecycle-Bedeutungen für
`in-progress/` *„Branch / PR existiert."*, während ihre Ziel-Form dort *beansprucht* setzt — der
`git mv` liegt auf dem Hauptzweig, **vor** der Arbeit, der Branch entsteht danach —, und die
`next/`-Zelle den Zeiger auf das Feld `Verantwortlich:` verliert. Bestand, von diesem Vorgang nicht
erzeugt, aber in ihm sichtbar geworden, weil sein Plan für genau diese Datei ihre Ziel-Form
deklariert hatte.

Beide Richtungen tragen dieselbe Wächter-Lücke: Kein Modul des Doku-Gates hält eine Instanz gegen
ihre Vorlage, `make docs-check` ist über allen Fassungen grün. Der Ausgang der zweiten Richtung ist
der Folge-Slice `slice-planning-readme-beschreibt-die-eigenen-lifecycle-verzeichnisse`.
