**Vorgang:** slice-migration-hat-ein-instanz-register
**Fund:** Derselbe Befund wie beim Vorgänger, unverändert und in derselben Zeile: Der Closure-Move
macht die Zeile *„In Arbeit: …"* unter *Offene Wellen* falsch, und
[`make slice-mv`](../../../../../../../harness/sensors/slice-mv.md) zieht sie nicht nach. Beide
Hälften fallen in seine benannten Grenzen — der **Zustandssatz** unter Grenze 1 (*„zieht Pfade
nach, keine Zustandssätze"*), der **präfixlose Verweis** derselben Zeile unter Grenze 3 (kein
Verzeichnis-Literal, an dem die Eingehend-Ersetzung ankert). Der Lauf meldete `3 eingehend, 0
ausgehend`; die Roadmap war in keiner der drei Dateien.

Nach dem Move trägt `docs/plan/planning/in-progress/` keinen Slice mehr
(`ls docs/plan/planning/in-progress/` → nur `roadmap.md`), und das Modul `planning` hält den
Ruhe-Marker gegen genau dieses Verzeichnis. Von Hand ausgeglichen — dieselbe Handarbeit wie in den
sechzehn Vorgängen davor.
