# JVM-Paket außerhalb seines Verzeichnisses entgeht der Import-Auflösung

**Sub-Area:** `*` (gesamtes Repo)

Das Arch-Gate der Sprachen Kotlin und Java löst Importe über Verzeichnis und `package_base` auf. Ein
Paket, das nicht seinem Verzeichnis entspricht, und ein voll qualifizierter Name ohne `import` entgehen
der Auflösung; im Skelett hält ein Go-Test „Paket gleich Verzeichnis", im Adopter-Code hält es nichts. Die
Abdeckungs-Zeilen beider Stufen nennen die Grenze unter NICHT gemessen.

## Benannt, nicht gezählt

Kotlin trägt dieselbe Grenze seit der Kotlin-hexslice-Lieferung ohne Register-Beleg; sie ist nicht
nachgezählt.
