**Vorgang:** slice-flache-welle-ist-eroeffnet-nicht-geplant
**Fund:** Zweimal in einem Vorgang, an beiden Enden des Lifecycle — für den Zähler **eine**
Gelegenheit. Der Übergang `next` → `in-progress` machte den Ruhe-Marker *„Nichts in Arbeit."* unter
*Offene Wellen* der Roadmap falsch, und der Übergang `in-progress` → `done` macht die Zeile
*„In Arbeit: …"* wieder falsch, die an seine Stelle trat. Das Modul `planning` hält genau dieses
Feld gegen den Inhalt von `docs/plan/planning/in-progress/`, in beide Richtungen; der Move färbt
also den Lauf rot, der ihn ausführt.

**Der Träger hat sich seit dem Vorgänger-Beleg nicht bewegt.**
[`make slice-mv`](../../../../../../../harness/sensors/slice-mv.md) zieht nach eigener Zusage Pfade
nach, keine Zustandssätze; kein Anweisungssatz und kein Werkzeug dieses Repos nennt den
Ausgleichs-Schritt. Er hängt daran, dass der bewegende Lauf ihn kennt — beim ersten Übergang
notiert der Planner-Lauf ihn ausdrücklich als eigenen Commit nach dem Move, beim zweiten ebenso.
