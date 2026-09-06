**Stand:** offen

Ein Wächter besteht nicht: `make shell-lint` urteilt über Form, nicht über den Ausgang eines
Zweigs, und `make mutate` sieht nur, was ein Fall in `test/mutations/` trifft — ein Zweig ohne
Fall ist dort nicht abwesend, sondern unsichtbar. Träger ist der Lauf, der den Zweig schreibt,
und das Review danach.
