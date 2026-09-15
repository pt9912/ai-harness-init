**Vorgang:** slice-lifecycle-move-geht-ins-ziel
**Fund:** Der Vorgang legt sieben Wächter in `internal/emit/slicemv_test.go` an; **drei** davon nennt
je ein Fall unter `test/mutations/`, **vier** keiner. Gemeldet hat der Review **einen** davon (den
neuen Durchreichungs-Wächter); die Klasse ist größer als der Befund, und die Zuordnung Wächter →
`# expect:`-Zeile gibt ein Kommando für alle sieben aus:

```sh
for g in $(grep -oE '^func Test[A-Za-z_]+' internal/emit/slicemv_test.go | sed 's/func //'); do \
  printf '%s  %s\n' "$(grep -rl "expect: $g" test/mutations/ | wc -l)" "$g"; done
#  1  TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette
#  1  TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen
#  0  TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert
#  0  TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch
#  0  TestSliceMvFragment_TraegtDieFailClosedKante
#  1  TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen
#  0  TestSliceMvWerkzeug_IstNichtDerDogfoodPfad
```

Von den vier ohne Fall trägt einer seine rote Richtung außerhalb des Mutations-Satzes: die
fail-closed-Kante des Fragments fällt im E2E, und dort ist sie rot gelesen. Die drei übrigen haben
ihre rote Richtung nicht vorgeführt. **Kein Verstoß gegen AGENTS.md §3.6, und darum diese Zeile
statt einer Reparatur:** weder Code noch Doku behaupten, die sieben Wächter seien über
`test/mutations/` bewacht — der Rest ist benannt, nicht geschlossen.
