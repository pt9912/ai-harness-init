**Stand:** offen

Gemeldet wird die Klasse allein von `make mutate` (Nicht-Gate-Verify), und zwar erst im
Fall-Ablauf hinter Isolationskopie und Grün-Vorlauf — ein voller Lauf, der hinter Review und
Übergabe liegt. Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest ein `sed`-Muster, und `make gates` führt den
Treiber nicht.

**Ein vorgelagerter Durchgang müsste zwei Fragen stellen, nicht eine.** Die Klasse bricht auf zwei
Wegen, und nur der erste ist ein No-Op: Ein Anker, der die verschobene Zeile sucht, verändert
nichts (Treiber-Bedingung 2) — ein Fall, der das alte Symbol **einfügt**, verändert die Datei sehr
wohl, aber der mutierte Baum übersetzt nicht, und der erwartete Test fällt aus einem anderen Grund
(Bedingung 4). Ein Vergleich, der nur fragt *hat sich etwas geändert*, lässt den zweiten Weg
hindurch. Beide zusammen brauchen weder Docker noch Sensor-Lauf für die erste Frage, wohl aber
einen Übersetzungslauf für die zweite; als eigener, vorgelagerter Durchgang besteht keiner von
beiden.
