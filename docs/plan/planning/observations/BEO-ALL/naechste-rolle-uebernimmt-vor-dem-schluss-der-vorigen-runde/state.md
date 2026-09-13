**Stand:** offen

Ein Wächter besteht nicht, und zwar an beiden Enden: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest ein Review-Verdikt oder die Reihenfolge
zweier Läufe, und `make mutate` kennt dafür keine Fehlschlag-Form. Auch die DoD trägt ihn nicht —
sie verlangt *„Review durchgeführt, Report unter `docs/reviews/` liegt vor"*, und das ist von zwei
blockierenden Runden erfüllt. Träger ist die Rolle, die übernimmt; sie liest das Verdikt der letzten
Runde, bevor sie beginnt.
