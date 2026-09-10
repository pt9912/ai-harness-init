**Vorgang:** slice-073
**Fund:** Runde 3 fand die Begründung des Schlüssels `matrix.exclude-sections` in der emittierten
Vorlage falsch — sie nannte die zwei Klassen, die im frischen Ziel leer sind. Der Fix zog genau
diesen einen Fundort und setzte dort eine **zweite** ungemessene Behauptung ein: der Schlüssel
schütze die `spec-straten`-Klasse. Die Baseline-Vorlagen sagen das Gegenteil (*„keine ADR, kein
Slice … in keiner Spalte. Kein Spec-Stratum nimmt seine Historie davon aus"*), und die Messung, die
gefehlt hatte, war die über **alle** Vorlagen mit einer `Historie`/`Geschichte`-Überschrift — vier,
von denen genau eine die Behauptung trägt. Gefangen hat es eine Gegenmessung außerhalb der
Rollen-Kette, nicht die nächste Review-Runde; behoben ist es mit der Einschränkung auf die
`adr`-Klasse.
