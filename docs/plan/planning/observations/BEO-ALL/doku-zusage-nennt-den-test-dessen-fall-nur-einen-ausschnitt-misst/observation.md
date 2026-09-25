# Eine Doku-Zusage nennt den Test, dessen Fall nur einen Ausschnitt der Eigenschaft misst

**Sub-Area:** `*` (gesamtes Repo)

Ein Satz in einer Nutzer-Doku sagt eine Eigenschaft eines Werkzeugs zu (*„der Vergleich liest keine
Version"*) und nennt daneben den `bats`-Fall, der sie hält. Der Fall fährt nur einen Ausschnitt der
Eigenschaft (gleiche Bytes), und eine Mutation, die die Eigenschaft bricht (Versions-Vergleich bei
ungleichen Bytes), überlebt die ganze Datei. Der Fall ist grün und trifft die Eigenschaft nicht; die
Fehlerrichtung ist *die Eigenschaft ist gebunden*.

## Benannt, nicht gezählt

Vier Nachbarklassen tragen den Fall nicht.
[`zusage-nennt-sensor-der-form-nicht-sieht`](../zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
sitzt im Kopf eines Skripts oder einer Funktion; hier steht die Zusage in Prosa einer Nutzer-Doku und
nennt einen Test statt eines Sensors im Code.
[`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md)
setzt ein benanntes Gate voraus; ein `bats`-Fall ist keines.
[`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
fehlt der Mutations-Fall für eine Zusage, die ein Fall **trifft**; hier trifft der genannte Fall die
Eigenschaft nicht.
[`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
liest die Zuordnung Mutation zu Test in der Gegenrichtung.
