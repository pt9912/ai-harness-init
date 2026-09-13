**Vorgang:** slice-werkzeug-erkennt-die-benannte-kennung
**Fund:** Der Closure-Move macht **zwei** Stellen derselben Roadmap-Zeile falsch, und keine davon
zieht ein Werkzeug nach. Die Zeile lautet `In Arbeit: [<slice>](<slice>.md) (wellenlos)` unter
*Offene Wellen*: Ihr **Zustandssatz** fällt unter Grenze 1 des Skriptkopfs von
`harness/tools/slice-mv.sh` (*„zieht PFADE nach, keine ZUSTANDSSÄTZE"*), ihr **Verweis** ist
präfixlos und fällt unter Grenze 3 (kein Verzeichnis-Literal, an dem die Eingehend-Ersetzung
ankert) — obwohl derselbe Vorgang die ausgehende Richtung gerade für benannte Kennungen geöffnet
hat: Die ausgehende Ersetzung greift nur **innerhalb** der bewegten Datei, und die Roadmap ist
eine andere. Dazu der Ruhe-Marker *Nichts in Arbeit.*, den das Modul `planning` gegen
`docs/plan/planning/in-progress/` hält und den der Move fällig macht. Alle drei sind von Hand
ausgeglichen.
