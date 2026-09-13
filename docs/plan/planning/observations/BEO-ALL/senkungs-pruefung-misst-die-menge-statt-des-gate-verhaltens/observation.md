# Senkungs-Prüfung misst die Menge statt des Gate-Verhaltens

**Sub-Area:** `*` (gesamtes Repo)

Vor einer Änderung an einer Gate-Konfiguration wird die Frage *ist das eine Senkung?*
([`AGENTS.md`](../../../../../../AGENTS.md) §3.5) mit einer Messung über den **Inhalts-Mengen**
der zwei Stände beantwortet — welche Namen vorher und nachher dokumentiert sind. Die Frage ist
aber eine über **Verhalten**: welchen Zustand das Gate vorher zurückwies und nachher durchlässt.
Eine leere Mengen-Differenz belegt darum nichts, und die Fehlerrichtung ist *kein §3.5-Fall*.
Die Klasse hält über mehrere Läufe, weil jeder folgende die vorhandene Messung **nachfährt**
statt eine zweite zu bauen: Sie steht im Plan, sie ist reproduzierbar, sie ist grün.

Zwei Nachbarn teilen den Anschein und nicht den Gegenstand:
[`vollstaendigkeits-zusage-misst-falsche-ebene`](../vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
misst auf der falschen **Granularität** desselben Gegenstands — Datei statt Hunk —, hier ist die
Granularität richtig und der **Gegenstand** falsch. Und
[`byte-gleichheit-als-aussage-ueber-die-regel-gelesen`](../byte-gleichheit-als-aussage-ueber-die-regel-gelesen/observation.md)
setzt eine Messung voraus, die etwas **übersieht** (die Delegation in eine andere Datei); hier
übersieht die Messung nichts — sie beantwortet vollständig und richtig eine andere Frage als die
gestellte.

Widerlegbar ist die Klasse nur durch eine **Sonde**: derselbe konstruierte Zustand über beiden
Ständen, einmal zurückgewiesen und einmal durchgelassen. Ein Mengen-Vergleich kann sie weder
zeigen noch ausschließen.
