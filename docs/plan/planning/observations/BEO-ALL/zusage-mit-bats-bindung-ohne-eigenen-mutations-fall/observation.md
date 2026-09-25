# Zusage mit Bats-Bindung, ohne eigenen Mutations-Fall

**Sub-Area:** `*` (gesamtes Repo)

Ein Wächter trägt Mutations-Fälle, und eine seiner Zusagen — hier der Wortlaut einer Fehlermeldung —
hängt allein an einer Assertion in einem `bats`-Fall; für sie besteht kein Fall in
`test/mutations/`. `make mutate` meldet jeden **gelisteten** Fall, der seine Zähne verliert; die
ungelistete Zusage kann sie verlieren, ohne dass ein Lauf davon spricht. Die Fehlerrichtung ist
*die Zusage ist gebunden*: der Wächter ist gelistet, ein Teil seiner Zusagen nicht.

## Benannt, nicht gezählt

[`neuer-waechter-ohne-mutations-fall`](../neuer-waechter-ohne-mutations-fall/observation.md) trifft
den Wächter, den **kein** Fall nennt; hier nennt ihn ein Fall, und die Lücke liegt eine Ebene tiefer,
je Zusage. [`zeichenmenge-mitglied-ohne-eigenen-zahn`](../zeichenmenge-mitglied-ohne-eigenen-zahn/observation.md)
ist dieselbe Ebene für die Mitglieder einer Zeichenmenge.
