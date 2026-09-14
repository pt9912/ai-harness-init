**Stand:** offen

Ein Wächter besteht nicht: `make test` fährt die bats-Suite über der Dogfood-Fassung, die
Go-Textanker und der E2E-Lauf fahren die emittierte — keine der beiden Suiten liest die andere —,
und kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) hält zwei
Dateien gegeneinander. Ein Vergleichs-Sensor ist **baubar**: ein kommentar-bereinigter `diff` der
zwei Fassungen ist genau die Messung, die die Sensor-Prosa heute in Worten behauptet; gebaut ist er
nicht. Träger ist der Lauf, der die Entscheidungslogik in einer der beiden Fassungen ändert.
