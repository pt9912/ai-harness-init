**Vorgang:** slice-124
**Fund:** Zwei Fälle in **einem** Vorgang, darum ein Beleg. `test/mutations/269` und
`test/mutations/279` ankerten auf dem vollständigen Listen-Literal der `modules:`-Zeile in
`.d-check.yml`; die Aufnahme von `targets` in dieselbe Zeile verschob den Wortlaut und machte beide
Patches zu No-Ops. Beide sind seither auf das Token statt auf die volle Zeile verankert.
