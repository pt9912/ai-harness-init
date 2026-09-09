**Stand:** offen

Ein Wächter besteht nicht, und die Lücke ist strukturell: Der Anker eines aufgelösten Eintrags
bleibt nach
[`MR-020`](../../../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
mit Absicht in der Index-Tabelle stehen, damit Verweise nicht brechen — genau deshalb kann kein
Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) den toten Verweis vom
lebenden unterscheiden. Träger ist der Lauf, der die Begründung schreibt, und das Review danach.
