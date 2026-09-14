**Vorgang:** slice-wellen-schnitt-folgt-der-eroeffnungs-regel
**Fund:** Derselbe Doppel-Defekt wie beim Vorgänger, unverändert: Der Closure-Move macht die Zeile
*„In Arbeit: …"* unter *Offene Wellen* der Roadmap falsch — das Feld, das das Modul `planning` gegen
den Inhalt von `docs/plan/planning/in-progress/` hält —, und der **präfixlose** Verweis *in* dieser
Zeile zeigt danach ins Leere.
[`make slice-mv`](../../../../../../../harness/sensors/slice-mv.md) zieht Pfade nach, keine
Zustandssätze (Grenze 1 seines Skriptkopfs), und eine präfixlose Referenz aus einer anderen,
unbewegten Datei fällt unter Grenze 3: Der Lauf meldete **2** eingehend und **0** ausgehend — die
zwei sind der Review-Report und ein `done/`-Slice, die Roadmap ist keine davon. Beide Defekte
behebt derselbe Handgriff, weil der Ruhe-Marker die Zeile im Ganzen ersetzt.

**Was sich seit dem Vorgänger-Beleg nicht bewegt hat, ist der Träger:** Kein Anweisungssatz und
kein Werkzeug dieses Repos nennt den Ausgleichs-Schritt; er hängt daran, dass der schließende Lauf
ihn kennt.
