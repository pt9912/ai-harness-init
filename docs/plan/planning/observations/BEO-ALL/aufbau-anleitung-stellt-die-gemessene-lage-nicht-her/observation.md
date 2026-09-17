# Aufbau-Anleitung stellt die gemessene Lage nicht her

**Sub-Area:** `*` (gesamtes Repo)

Ein Artefakt beschreibt den Aufbau, unter dem es eine Messung gefahren hat, als Folge von
Kommandos — und wörtlich ausgeführt entsteht die gemessene Lage daraus nicht: ein Schritt fehlt,
oder ein genanntes Kommando tut auf dem Host etwas anderes als unterstellt. Die Messwerte können
stimmen; getragen werden sie dann von Handgriffen, die nicht dastehen. Die Fehlerrichtung ist
*die Lage ist aus diesem Text wiederherstellbar*, und sie fällt erst dem Lauf auf, der sie
nachfahren will — bei einem eingefrorenen Artefakt ist das ein Lauf, der den Text nicht mehr
ändern kann.

Zwei Nachbarklassen decken den Fall nicht.
[`mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md)
bindet an eine **Einstellung des Hosts**, die das Rezept nicht nennt; hier ist der Host genannt und
die Schritt-Folge unvollständig.
[`zusage-ohne-herstellbares-gegenbeispiel`](../zusage-ohne-herstellbares-gegenbeispiel/observation.md)
setzt voraus, dass die Lage überhaupt nicht herstellbar ist; hier ist sie es, nur nicht nach
diesem Text.
