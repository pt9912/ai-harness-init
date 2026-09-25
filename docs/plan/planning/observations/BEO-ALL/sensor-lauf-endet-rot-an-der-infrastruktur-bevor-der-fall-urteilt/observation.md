# Sensor-Lauf endet rot an der Infrastruktur, bevor der Fall urteilt

**Sub-Area:** `*` (gesamtes Repo)

Ein voller Lauf eines Sensors, der Bilder baut oder Container startet, endet mit Befunden, deren Ursache
in der Registry oder im Docker-Daemon liegt, nicht im Fall: Das Urteil des Falls wird nie erreicht. Weil
der Sensor keinen Fall-Filter führt, hat der Beleg *jeder Fall wird aus dem behaupteten Grund rot* dann
keinen einzelnen grünen Lauf, sondern setzt sich aus der Vereinigung mehrerer Läufe zusammen, und wer
ihn liest, muss je Befund die Ursache lesen. Die Fehlerrichtung ist *das Gate ist rot*, wo der Wächter
nichts gemeldet hat; Modul 13 nennt ein Gate, das „manchmal“ rot sein darf, einen Vorschlag.

## Benannt, nicht gezählt

**Ein zweites Gate, dieselbe Richtung, ohne abgeschlossenen Vorgang.** Der `ci`-Lauf 36036245381 am
Commit `d235b24d` endete im Job `full-smoke` rot; die Ursache am Baseline-Fetch — `HTTP 500` — nennt der
Auftraggeber, das Log war beim Schreiben dieser Notiz nicht abrufbar. Ein späterer Lauf am Commit
`4c0e0f1f` ist grün (Lauf 36085391934). Der CI-Lauf ist ein anderes Gate mit anderer Quelle (Netz beim
Fetch, nicht die Registry beim Bild-Bau) und bewegt den Zähler nicht.

Zwei Nachbarklassen teilen die Wirkung und nicht die Ursache:
[`ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)
— dort ist die Ursache ein 404 vor der Publikation, und die Struktur-Entscheidung steht aus;
[`mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/observation.md)
— dort verliert ein vorhandener Beleg seinen Baum-Stand, hier fehlt der vollständige Lauf.
