**Fundstelle:** Closure slice-waechter-umgebungs-robustheit (2026-11-27), drei Beobachtungen (Messung: Verifikations-Bericht `docs/reviews/2026-11-27-slice-waechter-umgebungs-robustheit-verify.md`, Läufe L-1 … L-7):

1. Die Rot-Menge der Ziel-Modus-Fälle von `test/traeger-fetch.bats` ist vor
   dem Fix eine Funktion der ambienten `TRAEGER_*`-Teilmenge (das
   `make test-bats`-Rezept exportiert Tag und die sechs Digest-Pins): voller
   Pin-Satz → {3, 5, 7, 9} rot 3×, Teilmenge nur `TRAEGER_SHA256_DARWIN_AMD64`
   → {3, 5, 9} rot, ohne Ambiente → 10/10 grün. Der Zwilling
   `test/traeger-fetch-host.bats` trägt dieselbe Klasse ({603, 605, 606, 607, 608}
   im Sweep). Nach dem Setup-Ausmerz (die Setups setzen die Stellen je Setup
   selbst frei): Einzellauf und Sweep je 0 rot.
2. `test/targets-modul-wiring.bats` Fall 6 bricht unter `LANG=en_US.UTF-8` an
   `comm -23` („file 1 is not in sorted order“), grün unter `LC_ALL=C`; nach
   dem Fix grün unter beiden Varianten. Bruchproben: `LC_ALL=C ` nur an den
   `sort`-Stellen entfernt → rot; nur an den `comm`-Stellen entfernt → grün —
   der Zahn der Kollations-Festlegung sitzt an den `sort`-Stellen, der
   `comm`-Teil der Zusage trägt keinen eigenen Mutations-Fall (Review F-1
   2026-11-27, Grenze).
3. Nach dem Fix liefern Einzellauf und voller Sweep je berührter Wächter-Datei
   dieselbe Rot-Menge (an HEAD: nur der vorbestehende Fall 273 von
   `test/ignore-refs-restbreite.bats`, Vorbestand ohne Diff-Bezug).
