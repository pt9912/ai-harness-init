**Vorgang:** slice-mutate-fall-filter-und-die-belegform-vereinigung
**Fund:** Drei Sperren-Tests in `test/mutate-driver.bats` prüften *„keine Isolationskopie entsteht"* als
`[ -z "$(ls -A "$TL_ROOT/tmp")" ]`. Der EXIT-Trap des Treibers räumt das Isolations-Verzeichnis bei jedem Ausstieg, die Menge ist
nach dem Abbruch leer, **auch wenn die Kopie vorher entstand**: die Zusicherung war über der geleerten Menge wahr. Die
Ersatz-Mutation (`mktemp -d` und `cp -a` vor der Filter-Prüfung) ließ alle 64 Fälle grün (Review R-2, MEDIUM,
`docs/reviews/2026-09-26-slice-mutate-fall-filter-und-die-belegform-vereinigung.md`). Behoben im selben Slice durch eine
PATH-Wrapper-Sonde (Aufrufe von `mktemp` und `tar` vor dem Abbruch werden protokolliert; ein Gegenfall sieht sie bei einem gültigen
Lauf); der Verifier sah die Mutation jetzt in vier Tests rot mit der Meldung *„vor der Pruefung wurde kopiert oder ein Verzeichnis
angelegt"*. **Urteil des Planners:** dieselbe Fehlerrichtung (die Zusicherung gilt, wo nichts gemessen wurde), anderer Mechanismus —
die Menge fällt nicht weg, der Trap leert sie. Trägt der Architect die Zuordnung nicht, steht der Eintrag bei 2×.
