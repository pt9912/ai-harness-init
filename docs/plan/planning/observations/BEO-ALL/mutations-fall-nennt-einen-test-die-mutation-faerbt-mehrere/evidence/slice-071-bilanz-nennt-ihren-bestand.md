**Vorgang:** slice-071-bilanz-nennt-ihren-bestand
**Fund:** Verifikations-Nachrunde zum Review-MEDIUM: Mutations-Fall 495 nennt in `# expect:`
`TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend`; dieselbe Mutation
(Writer-Tausch `out`→`errOut`) färbt bei isolierter Gegenprobe auch den bereits vor diesem Slice
bestehenden Test `TestSpanReport_SchreibtBilanzUndGibtNullZurueck` (laut Verifikations-Bericht
ebenso `TestSubkommandoRouting_ReportSchreibtBilanz` und
`TestSpanReport_LeererBestandIstKeinFehler`) rot — kein Mangel (Fall 495 bindet real eine neue
Kombination, siehe DoD (1)-Review-Nachrunde), aber dieselbe strukturelle Lücke: `make mutate`
prüft nur Anwesenheit des genannten Fehlschlags, keine Exklusivität.
