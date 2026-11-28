# Stamp-Abbruch hinterlässt Teilbestand im Fall-File

**Sub-Area:** `harness/tools/` (TOOLS)

Der Mutations-Result-Konsum prüft vor jedem Anhang, aber die Anhänge laufen
je Zeile nacheinander: bricht ein Stamp-Lauf zwischen zwei Anhängen
(Sammel-Result-File mit vielen Fall-Zeilen), bleibt ein Teilbestand im
Fall-File, und der Wiederhol-Lauf bricht an der `(fall, run, attempt)`-Paar-Doppelung
des bereits gestempelten Anteils fail-closed
([`ADR-0107`](../../../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
Festlegung 3) — eine Wiederaufnahme-Form existiert nicht.

## Benannt, nicht gezählt

Dieses Erst-Vorkommen wurde im Verifikations-Lauf von
`slice-stamp-records-konsum-v1` gemessen; als Beleg zählt der
abgeschlossene Vorgang des Slice (Evidence-Datei
`slice-stamp-records-konsum-v1.md`). Ein Agentenlauf des Treibers, der bei
einem Abbruch einen Teilbestand hinterließ, ist nicht aufgefallen.
