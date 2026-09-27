**Vorgang:** slice-fall-406-trifft-die-umgebaute-zerlegung
**Fund:** Mutations-Fall 406 wurde am 2026-09-24 (Commit `fb1ca361`) korrekt gegen den damaligen
Quell-Bestand angelegt (`sed`-Anker traf exakt `fields := splitWords(cmd)`,
[`MR-071`](../../../../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-konform). Eine
spätere, berechtigte Änderung (Commit `92f03d31`, Nachrunde slice-204, `splitWords` auf einen
`words`-Struct umgestellt) entwaffnete den Anker, ohne den Fall selbst zu berühren — CI meldete
„Patch veraltet". Reparatur: neuer Anker auf die heute eindeutige Boundary-Zeile in `splitWords`
(`grep -c` = 1 gegen den Quell-Bestand,
[`MR-071`](../../../../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
Sechster Vorgang der bereits verkörperten Klasse; ihr eigener Auflösungs-Trigger — drei weitere
Vorkommen seit der Verkörperung — ist mit
diesem einen Beleg noch nicht erreicht (1 von 3).
