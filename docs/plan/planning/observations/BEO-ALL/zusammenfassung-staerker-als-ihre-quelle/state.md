**Stand:** geplant

Kennung: `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle` — er schreibt die Regel, die heute
nirgends normiert ist: eine Zusammenfassung eines referenzierten Artefakts sagt nicht mehr zu, als
ihre Quelle sagt.

Die Klasse hat keinen Zielort: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält eine Zusammenfassung gegen das Artefakt, auf
das sie zeigt — `links` prüft die Auflösbarkeit, nicht die Aussage. Träger der Wirkung bleibt bis
dahin der Lauf, der die referenzierte Quelle vollständig liest.
