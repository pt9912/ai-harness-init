# Spec-Änderung ohne Historie-Zeile

**Sub-Area:** `*` (gesamtes Repo)

Ein Vorgang ändert ein Spec-Stratum, und die Änderung bekommt keine Zeile in dessen Historie.
Führt der Plan zugleich keine berührte Spec-Stelle, fällt die Änderung aus beiden Rastern, die
sie zeigen sollten.

Ein Wächter besteht nicht: Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml)
hält eine Änderung eines Spec-Stratums gegen seine Historie. Träger ist das Review.
