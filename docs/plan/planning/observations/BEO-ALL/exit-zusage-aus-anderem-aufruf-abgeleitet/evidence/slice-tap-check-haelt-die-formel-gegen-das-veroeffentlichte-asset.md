**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** Die Fitness-Zeile *Rot-Beleg* der Accepted-Entscheidung
[`ADR-0064`](../../../../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
sagt für `make tap-check` gegen `v0.2.2` Exit 1 zu. Gemessen am Skript stimmt sie; über `make` endet
der Prozess mit Exit 2 (GNU Make 4.3, vom Verifier gemessen), die Klasse steht dort nur in der Zeile des
Skripts `tap-check: Exit 1` und als Ziffer in der Meldung von `make`. Review Runde 1 desselben Slice
meldete den Exit-Vertrag der ADR als über `make` nicht erreichbar; der Plan liest die Zeile seither nach
[`ADR-0066`](../../../../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
(`Proposed`: Klasse gleich Exit des Skripts, Träger über `make` die Zeile des Skripts)
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§6 und Ü-1).
