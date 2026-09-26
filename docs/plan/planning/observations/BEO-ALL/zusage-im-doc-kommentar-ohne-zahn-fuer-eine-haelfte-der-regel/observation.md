# Zusage im Doc-Kommentar ohne Zahn für eine Hälfte der Regel

**Sub-Area:** `*` (gesamtes Repo)

Ein Doc-Kommentar sagt eine Grenze der Regel zu — die Regel überquere weder eine Link- noch eine
Zeilengrenze, der Baum ende am Verzeichnis —, und die Mutations-Fälle des Wächters binden die eine
Hälfte der Zusage, die andere nicht: Entfällt `\n` aus den Zeichenklassen, entfällt der Schrägstrich
hinter dem Verzeichnis oder die Maskierung des Namens, bleibt die ganze Suite grün. Die Zusage steht
im Kommentar, ihr rotes Gegenbeispiel fehlt für eine Hälfte; die Fehlerrichtung ist *die Regel hält,
was ihr Kommentar sagt*.

## Benannt, nicht gezählt

[`zeichenmenge-mitglied-ohne-eigenen-zahn`](../zeichenmenge-mitglied-ohne-eigenen-zahn/observation.md)
(**1×**) liegt daneben: dort prüft ein Wächter ein Wort gegen eine Zeichenmenge, und die Zusage
*jedes Zeichen sperrt* hat je Mitglied keinen Fall. Hier ist `\n` zwar ein Mitglied einer
Zeichenklasse, aber die Zusage ist eine Aussage des Kommentars über die **Grenze der Regel**, nicht
über ein Wort; die Zuordnung ist ein Urteil des Planners, und wer sie anders zieht, hebt den Zähler
jener Beobachtung auf 2×.
[`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
setzt eine vorhandene Assertion voraus; hier besteht für die Hälfte weder Assertion noch Fall.
Eine Regel-Ausprägung ohne Fall, für die **kein Kommentar etwas zusagt**, ist keine Instanz: der
Shell-Träger derselben Regel trug sie als Review-Befund der Stufe INFO, und seine Closure hat sie
nicht eingetragen.
