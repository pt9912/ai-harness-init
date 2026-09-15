**Stand:** offen

Ein Wächter besteht nicht. `TestCommands_AdaptationMarker` und seine Mutations-Fälle prüfen, **dass**
ein Marker vorhanden ist (`strings.Contains(s, "ANPASSEN")`), nicht, ob die bezeichnete Stelle
innerhalb der Emissions-Klasse des Artefakts liegt. Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest eine Vorlage gegen die Klasse ihrer Emission,
und `make mutate` kennt keine Fehlschlag-Form dafür — die Frage *hält diese Klasse die Stelle?* ist
ein Urteil über den Text und kein Muster.

Träger ist der Lauf, der den Marker setzt: Er kennt die Klasse des Artefakts, das er schreibt, und
damit, welche Stelle er überhaupt freigeben darf. Ein Norm-Artefakt, das die Klasse je Artefakt
führt, besteht nicht — den Zielort schneidet der Lese-Schritt.
