**Stand:** geplant

Kennung: `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, Teil (c): ein
kommentar-bereinigter Vergleich je Paar aus Dogfood und Vorlage in `make test`.

Bis dahin hält kein Wächter: `make test` fährt die Dogfood-Fassung, die Go-Textanker und der
E2E-Lauf die emittierte, und kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält zwei Dateien gegeneinander.
