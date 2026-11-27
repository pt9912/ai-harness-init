**Fundstelle:** Closure slice-labor-gates-host-rezepte (2026-11-27), drei Beobachtungen:

1. Die Ziel-Modus-Fälle von `test/traeger-fetch.bats` (Ziel-Modus, fail-closed,
   Plattform-Matrix) rot im vollen Sweep bei grünem Einzellauf laut
   Auftraggeber-Befundlage; am Closure-Host schwankte außerdem die Rot-Menge
   zwischen zwei identischen Einzelläufen (Lauf 1: Fall 3 ok, 5/7/9 rot;
   Lauf 2: 3/5/7/9 rot).
2. `test/targets-modul-wiring.bats` Fall 6: die Deckungs-Mengen
   Makefile-Regeln, Sensors-Befundzeilen, exempt-targets stehen als Sets
   identisch (78/18/60, Differenzmenge leer), der Fall fällt trotzdem —
   `sort` und `comm` divergieren im Ambient-`en_US.UTF-8` in der Ordnung
   („comm: file 1 is not in sorted order“); unter `LC_ALL=C` ohne Befund.
   Der Fall misst damit teils das Host-Locale.
3. Review-Report `docs/reviews/2026-11-27-slice-labor-gates-host-rezepte.md`
   F-2 (Rezept-Wächter hängen an `make`/`git`, die der gepinnte bats-Image-Weg
   nicht trägt) und F-4 (Rot-Beleg von Mutations-Fall 810 an die
   `awk`-Zeichen-Semantik des Hosts gebunden).
