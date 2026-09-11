**Stand:** offen

Gemeldet wird die Klasse allein von `make mutate` (Nicht-Gate-Verify), und zwar erst im
Fall-Ablauf hinter Isolationskopie und Grün-Vorlauf — ein voller Lauf, der hinter Review und
Übergabe liegt. Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest ein `sed`-Muster, und `make gates` führt den
Treiber nicht. Der Vergleich, der *stumpf* von *scharf* trennt — den Patch auf eine Kopie anwenden
und fragen, ob sich etwas geändert hat —, braucht weder Docker noch Sensor-Lauf; als eigener,
vorgelagerter Durchgang besteht er nicht.
