**Vorgang:** slice-200
**Fund:** Von den Test-Fällen über der neuen Verdrahtung `vendorBaselineMit` trägt genau die neu
gebaute Tag-Sperre einen Fall in `test/mutations/`
(`grep -l 'vendor_baseline' test/mutations/*.sh` nennt eine Datei). Wurzel-Auflösung, Zielpfad,
Exit-Codes und die zwei Rezept-Argumente `$(BASELINE_TAG)`/`$(BASELINE_ZIP_SHA256)` haben keinen —
vertauscht man die zwei Argumente oder bricht die Wurzel-Auflösung, meldet `make mutate` nichts
Neues. Zwei Hälften daneben sind gemessen gedeckt: die Fähigkeit darunter über fünf Fälle
(`grep -l 'internal/fetch/baseline.go' test/mutations/*.sh | wc -l`) und die Dispatch-Kopplung über
`test/unterkommando-kopplung.bats`. **Kein §3.6-Verstoß, und darum diese Zeile statt einer
Reparatur:** Weder Code noch Doku dieses Slice behaupten, die Verdrahtung sei durch
`test/mutations/` bewacht — es ist ein benannter, nicht geschlossener Rest, gefunden vom Review und
von der Verifikation einzeln nachgemessen.
