**Stand:** geplant

Kennung: `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor` (Datei in
`open/`): ein Vergleich je Paar aus Dogfood und Vorlage in `make test`, der die benannte
Abweichungsmenge hält. Der Teil (c) von `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`
ist dort ausgeschnitten, weil die Abweichungen je Paar mehr als eine benannte betragen.

Bis dahin hält kein Wächter: `make test` fährt die Dogfood-Fassung, die Go-Textanker und der
E2E-Lauf die emittierte, und kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält zwei Dateien gegeneinander.
