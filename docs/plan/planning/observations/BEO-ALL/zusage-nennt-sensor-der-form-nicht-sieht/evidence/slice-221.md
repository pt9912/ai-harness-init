**Vorgang:** slice-221
**Fund:** Drei Zusagen desselben Slice nannten je einen Sensor, der die zugesagte Form nicht
erreicht. (a) Der Kommentar in `internal/archive/scan.go` sagte zu, `Haenger` behalte seinen
vollen Suchraum, und nannte `TestHaengerFindetVerweisAusReviewReport` samt `test/mutations/233`
als wirksam — beide messen `docs/reviews/**`, das in **beiden** Suchräumen liegt und unter der
Trennungs-Mutation nicht rot werden kann (Runde 1, HIGH-1). (b) Der Skriptkopf von
`harness/tools/slice-mv.sh` verwies für die Verdrahtungs-Hälfte auf einen BELEG-Block, der eine
Ausnahmeliste ohne `docs/plan/adr` misst (Runde 1, MEDIUM-1). (c) DoD (1) nannte `test-bats` als
den Wächter, der der Ausnahme die Zähne nimmt; das gepinnte `BATS_IMAGE` führt kein `git` und
erreicht die Verdrahtung nicht — diese Hälfte trägt `test-go`. Alle drei sind geschlossen: (a) und
(b) in der Nacharbeit, (c) von der Closure, die die DoD-Zeile auf die zwei tragenden Wächter
nachgezogen hat.
