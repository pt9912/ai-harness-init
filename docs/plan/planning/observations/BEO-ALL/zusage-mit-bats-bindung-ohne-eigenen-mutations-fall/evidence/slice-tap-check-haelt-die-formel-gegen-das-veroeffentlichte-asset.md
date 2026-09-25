**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** Der Wortlaut der `*)`-Meldung des `docker`-Zweigs von `tap-check` (sie sagt, der Transport
endete ohne Ergebnis der Nutzlast, und trifft keine Aussage über einen Zustand des Vergleichs) hängt in
`test/tap-nachzug.bats`, Fall `transport:`, allein an einer Positiv- und einer Negativ-Assertion; die
Plan-DoD 3 (a) listet keinen Zahn dafür, und `test/mutations/` führt keinen. Der Verifier fuhr zwei
Sonden — die Meldung um `(Formel-Unterschied)` ergänzt: Fall rot an der Negativ-Assertion; die ganze
Meldung ersetzt: Fall rot an der Positiv-Assertion — und stellte fest, dass die Assertions binden und
ein dauerhafter Zahn fehlt (`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§4 und §7). Dieselbe Klasse nannte die Summary-Zeile der Review-Runde 2 desselben Slice (*Zusage mit
Bats-Bindung, ohne gelisteten Mutations-Fall*); den `*)`-Arm tragen heute die Zähne 430 und 431.
Ein Vorgang zählt einmal: beide Vorkommen sind eine Gelegenheit.
