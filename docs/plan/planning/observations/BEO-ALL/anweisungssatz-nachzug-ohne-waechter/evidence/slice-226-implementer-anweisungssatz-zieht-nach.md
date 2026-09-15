**Vorgang:** slice-226-implementer-anweisungssatz-zieht-nach
**Fund:** Der Nachzug der vier Plan-vor-Code-Blöcke und der Kennungs-Notation lief von Hand gegen
zwei Quellen — das Regelwerks-Modul `modul-09-implementierung.md` (vendored Stand `v6.8.0`) und die
Platzhalter-Form aus [`MR-057`](../../../../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 3. Der Beleg beider Liefer-Punkte ist eine Ad-hoc-Sonde über genau eine Datei — kein Ziel,
kein Test, kein Mutations-Fall. Gemessen fällt nichts, wenn ein Block des Nachzugs wieder
verschwindet: derselbe Lauf, der einen Block entfernt, läßt die Notations-Sonde grün, und kein Modul
aus `modules:` der [`.d-check.yml`](../../../../../../../.d-check.yml) liest den Anweisungssatz gegen
seine Quelle. Die Klasse ist im Plan §1 als ausdrücklich ausgeschlossener Sensor benannt und §6 als
Risiko geführt.
