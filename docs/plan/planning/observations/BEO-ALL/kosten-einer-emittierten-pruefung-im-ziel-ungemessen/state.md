**Stand:** verkörpert — [`MR-089`](../../../../../../harness/conventions.md#mr-089--eine-laufzeit-aussage-über-einen-emittierten-oder-e2e-lauf-nennt-image-lage-und-variante) (`· seit slice-kotlin-flaches-skelett`, Feld Begründung)

**Grenze der Verkörperung, benannt.** Kein Sensor misst die Klasse: [`make full-smoke`](../../../../../../harness/sensors/full-smoke.md)
urteilt über Exit-Codes und Ausgabe-Spuren, nicht über Laufzeit, und
[`make hook-overhead`](../../../../../../harness/sensors/hook-overhead.md) misst den Aufschlag je
Tool-Call, nicht die Kette eines gebootstrappten Ziels. Träger ist der Lauf, der eine emittierte
Prüfung schreibt, und die Frage, an welcher Ziel-Variante ihre Kosten-Aussage gemessen ist.
