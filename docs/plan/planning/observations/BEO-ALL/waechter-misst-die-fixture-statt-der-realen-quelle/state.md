**Stand:** verkörpert

Der Slice [`slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`](../../../in-progress/slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor.md)
liefert für die Pin-Kopplung (Fallbacks, Digest) den Rot-Beleg am **realen** Wert; einen Sensor, der
eine Fixture allgemein gegen ihre Quelle hält, baut er nicht und kann ihn nicht bauen. Die Zeile in
`AGENTS.md` §3.6 unten trägt die Klasse weiter.

Zielort: [`AGENTS.md`](../../../../../../AGENTS.md) §3.6 — das vierte Falsch/Richtig-Paar: ein
Wächter, der grün bleibt, weil er über einer nachgebauten Eingabe statt der realen Quelle läuft.
Herkunfts-Anker: `· seit slice-release-schnitt-v025-bereitet-vor`.

**Grenze der Verkörperung, benannt** — die Zeile selbst trägt sie: Kein Sensor hält eine Fixture
gegen ihre reale Quelle; Träger bleibt der Lauf, der den Wächter schreibt.

**Unterklasse Fremd-Werkzeug-Verhalten nachgebaut:** Halter der realen Quelle ist die
`full-smoke`-Stufe in CI. Der geplante Kopplungs-Sensor deckt sie nicht und muss es nicht (Verdikt `2026-10-09-welle-kotlin-skelett-architect-verdikt`, B-5).
