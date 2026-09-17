# Exit-Zusage aus einem anderen Aufruf abgeleitet

**Sub-Area:** `*` (gesamtes Repo)

Eine Sensor-Datei sagt einen Exit-Code für `make <ziel>` zu und hat ihn am direkten Aufruf des
Skripts gemessen. Das Rezept meldet jeden Fehlschlag anders, und die Zusage stimmt für einen
Aufruf, den der Satz nicht nennt.

Die Nachbarklasse
[`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md)
verfehlt den Zeitpunkt, diese den Aufruf.

Ein Wächter besteht nicht: Keine Prüfung hält einen Exit-Satz einer Sensor-Datei gegen das
Rezept. Träger ist der Lauf, der den Satz schreibt, und das rote Gegenbeispiel über `make`.
