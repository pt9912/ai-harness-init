# Inline-Zählmuster paart Backticks über Zellgrenzen

**Sub-Area:** `*` (gesamtes Repo)

Ein Zählmuster für Inline-Code (Backtick, beliebige Zeichen außer Backtick, das Suchmuster,
Backtick) paart in einer Tabellenzeile den schließenden Backtick einer Zelle mit dem öffnenden der
nächsten. Steht zwischen beiden ein Link mit dem Suchmuster, zählt das Kommando einen Inline-Pfad,
wo keiner steht. Die Fehlerrichtung ist *zu viel*, und die Zahl sieht belegt aus, weil ihr
Kommando neben ihr steht.

Die Nachbarklasse
[`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
hat die Gegenrichtung: Dort trennt Markup das Muster, und das Kommando zählt zu wenig.

Ein Wächter besteht nicht: Ob ein Muster die Einheit trifft, die es zählen soll, ist ein Urteil
über das Kommando. Träger ist der Lauf, der die Zahl schreibt, und die Stichprobe seiner Treffer.
