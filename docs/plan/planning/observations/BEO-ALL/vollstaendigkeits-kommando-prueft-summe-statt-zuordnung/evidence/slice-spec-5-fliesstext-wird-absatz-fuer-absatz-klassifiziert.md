**Vorgang:** slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert
**Fund:** Die Vollständigkeits-Zusage der Klassifikationstabelle (Byte-Summe gleich dem Fließtext, Namens-Differenz der Wächter leer) misst die **Summe** und die **Namensmenge**, während ihr Gegenstand auf der Ebene der **Zuordnung** lebt: eine Sammelzeile `T` trägt Testnamen, die das Namens-Kommando für die Zeilen des Fließtexts verdeckt, und die Summe bleibt grün, wenn Bytes zwischen zwei Einheiten verschoben werden.

Beide Blindheiten sind am Bericht gemessen, nicht vermutet (Kopien im Scratchpad, Bericht unverändert):

```sh
# Streichprobe: Einheiten U56, U57, U58, U59, U61 aus der Kopie gestrichen
awk -F'|' '/^\| (U|T)/ {s+=$8} END{print s}' <Kopie>     # 44407 statt 45889 — die Summe fällt
comm -23 <Testnamen der Spec> <Testnamen der Kopie>       # leer — die Namens-Differenz bleibt 0, weil T die Namen trägt
# Verschiebeprobe: U10 646 -> 600, U11 1426 -> 1472, U01 137–140 -> 137–141
awk -F'|' '/^\| (U|T)/ {s+=$8} END{print s}' <Kopie>     # 45889 — die Summe bleibt, alle Vollständigkeits-Kommandos grün
```

Nur die Einzel-Schleife (`sed -n '<a>,<b>p' spec/spezifikation.md | wc -c` je Einheit) meldet die
Verschiebung; sie ist ein Verifier-Kommando und kein Gate. Dieselbe Klasse wie in den Vorgängern:
die Zusage ist grün, während eine Position ohne Deckung dasteht.
