# Übernommener Regelwerk-Satz kollidiert mit eigener Hard Rule

**Sub-Area:** `*` (gesamtes Repo)

Ein Satz wird sinntreu aus einem Baseline-Regelwerk-Modul in den Anweisungssatz einer Rolle
übernommen, und das Regelwerk kennt die Normen des adoptierenden Repos nicht: Der übernommene Satz
nennt eine Handlung, die eine Hard Rule dieses Repos einer **anderen** Rolle zuweist. Er liest sich
an der Stelle, an der die übernehmende Rolle ihn liest, als deren eigene Anweisung — die Kollision
entsteht erst beim Übertragen und ist in der Quelle nicht sichtbar, weil das Regelwerk keine Rollen
führt. Die Fehlerrichtung ist *der Satz sagt, was zu tun ist*, während er die Zuständigkeit
offenlässt.

Teuer ist nicht der Satz, sondern sein Ort: Er steht in der Lese-Anweisung genau der Rolle, die die
Hard Rule ausnimmt, und sein Umfeld im Modul stützt die Gegenlesart.

## Benannt, nicht gezählt

Zwei Nachbarklassen sind enger und decken den Fall nicht.
[`out-of-scope-und-doku-dod-widersprechen-sich`](../out-of-scope-und-doku-dod-widersprechen-sich/observation.md)
lässt **zwei Artefakte desselben Repos** über dieselbe Grenze Verschiedenes sagen; hier ist die
zweite Quelle ranghöher und außerhalb.
[`schwellen-uebertritt-ohne-zustaendige-rolle`](../schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
setzt eine Handlung voraus, die **keiner** Rolle zusteht; hier steht die Zuständigkeit fest und der
übernommene Satz sagt sie nicht.
