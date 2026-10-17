**Vorgang:** slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor

**Fund:** Die Verifikation fuhr `make freshness-digest` am echten Baum: die zwei Hub-Pins endeten als
`FETCH-FEHLER (kein Urteil)`, die drei Pins ohne Hub (`d-check`, `d-check (emit)`, `a-check (emit)`)
als `aktuell`, Exit 2. Der Review-Report nennt dasselbe als INFO F-2; beide sahen es im selben
Vorgang. Der konkrete Bruch (Digest des Go-Images 1.27.1 an Tag 1.27.2) war deshalb nicht fahrbar.
