**Fundstelle:** Closure slice-mutate-treiber-host-modi (2026-11-27), drei Beobachtungen (Messung: Verifikations-Bericht `docs/reviews/2026-11-27-slice-mutate-treiber-host-modi-verify.md`):

1. Die Ursachentrennung ist jetzt Treiber-Vertrag: der Umgebungs-Befund
   (`umgebung: go · Soll: 99.99.0 · Ist: 1.27.4`, Manipulation der
   Inventar-Zeile) bricht **vor** Beleg-Lesung, Entwertung und
   Isolationskopie — kein Fall läuft, kein Lock-Rest, Beleg-Slot unberührt;
   make-Meldung `Fehler 4` (Exit 4), getrennt von jedem Test-Ausgang.
2. Der Vorbestand bricht am Treiber nicht mehr an einem Fall-Ausgang: der
   blockierte Fall-Satz (64 `smoke`/`full-smoke`-Fälle am Daemon-Befund, 267
   am Fall-Vorlauf der Vorbestand-Klassen) meldet seine Ursache — der
   Grün-Vorlauf benennt „der Gruen-Vorlauf ‚make test-go' ist in SEINER Kopie
   ohne Mutation rot“ statt eines Befunds ohne Grund.
3. Die Ausgangs-Lesung der Klasse (Verifikations-Läufe 1–3): Teillauf
   `10-ci-workflow-syntax` Exit 0 mit `TEILLAUF 1 von 800 — kein Beleg` —
   der Beleg-Übersprung ist hinter der Umgebungs-Vorbedingung gebunden.
