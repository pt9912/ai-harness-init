**Vorgang:** slice-archive-welle-altbestand-hat-einen-schreibenden-pfad
**Fund:** Der Guard am Anfang von `Anwenden` (`internal/archive/anwenden.go`, Plan-Datei unter `altbestand`)
wiederholt, was `sperren` vorher abfängt; weder Test noch Mutations-Fall erreichen ihn allein
(`docs/reviews/2026-10-05-altbestand-traeger-review.md`, INFO). Die fünf neuen Fälle 504 bis 508 decken die
Sperren des Laufs, nicht diesen Guard.
