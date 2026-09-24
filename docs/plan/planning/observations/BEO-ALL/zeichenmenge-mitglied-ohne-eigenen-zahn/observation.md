# Zeichenmenge: Mitglied ohne eigenen Zahn

**Sub-Area:** `*` (gesamtes Repo)

Ein Wächter prüft ein Wort gegen eine Zeichenmenge, jede Testeingabe trägt neben dem geprüften
Zeichen ein weiteres Mitglied, und ein Mutations-Fall mutiert die Prüfung als Ganzes. Entfällt ein
einzelnes Mitglied, bleibt die Suite grün; ein Mitglied, das eine zweite Regel mitdeckt, ist ein
äquivalenter Mutant. Die Zusage *jedes Zeichen der Menge sperrt* hat je Mitglied kein rotes
Gegenbeispiel.

## Benannt, nicht gezählt

[`neuer-waechter-ohne-mutations-fall`](../neuer-waechter-ohne-mutations-fall/observation.md) trifft
den Wächter, den **kein** Fall nennt; hier nennt ihn ein Fall, und die Lücke liegt eine Ebene tiefer,
je Mitglied der Menge.
