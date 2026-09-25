**Stand:** offen

Unterhalb der Schwelle; `offen` ist hier der Normalzustand und kein Ausgang — *geplant* und
*verkörpert* sind die Antwort auf die Schwelle
(`modul-06-roadmap.md` §Das Beobachtungs-Register), und sie ist mit einem Beleg nicht erreicht.

Die Entscheidung gegen eine Datei in der Wurzel des Ziels steht in
[`ADR-0067`](../../../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
(Festlegung 5 und Alternative D): eine skip-if-present-Datei dort schützte ein Ziel mit eigener
Wurzel-Datei nicht, und ein Marker-Block schriebe in eine Adopter-Datei. Ein Wächter besteht nicht
über die Wurzel-Dateien: die Stufe `zeilenenden_im_klon` zählt sie als Restmenge und urteilt nicht
über sie. Träger ist der Lauf, der die Restmenge liest.
