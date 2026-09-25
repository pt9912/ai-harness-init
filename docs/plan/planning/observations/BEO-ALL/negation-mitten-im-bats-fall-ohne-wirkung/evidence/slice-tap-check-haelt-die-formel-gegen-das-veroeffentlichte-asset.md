**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** Runde 1 des Reviews fand zwei Stellen in `test/tap-nachzug.bats`, an denen die Zusicherung
wirkungslos war: `! grep -qF "$S" …` mitten im Token-Fall — das Token zusätzlich als Argument der
Nutzlast (`-H "X-Debug: ${TAP_TOKEN}"`) ließ **keinen** Fall rot werden — und `! grep -qE …` in einer
`for`-Schleife über fünf Programme, deren Status der des letzten Durchlaufs ist (`bash -c true` in der
Nutzlast ließ den Fall grün). Behoben im selben Slice durch die Funktion `nirgends`, die den Status des
`grep` trägt und im Fund-Zweig `return 1` sagt; der Verifier fuhr die Sonde erneut — Fall rot mit der
Meldung `nirgends: grep Status 0 …; Fund in: …/curl.log`, und die Gegenprobe (nur die `nirgends`-Zeile
gelöscht) grün
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§3.3 und §7).
