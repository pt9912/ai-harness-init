# Zwei Fassungen eines Wächters ohne vergleichenden Sensor

**Sub-Area:** `*` (gesamtes Repo)

Dieselbe Regel liegt zweimal im Repo — als lauffähige Dogfood-Fassung und als Text der
Emissions-Vorlage —, und kein Sensor hält die zwei Fassungen gegeneinander. Jede Suite fährt ihre
eigene Kopie: ändert ein Lauf die Entscheidung in einer Fassung und nicht in der anderen, bleiben
beide grün, und eine Zusage, die ihre Gleichheit behauptet, wird still falsch. Die Fehlerrichtung
ist *beide Fassungen tragen dieselbe Entscheidung*, und der Auslieferungs-Stand ist der, den das
eigene Gate nie fährt.

## Benannt, nicht gezählt

Der Nachbar [`emittierter-stand-laeuft-dem-dogfood-voraus`](../emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
deckt den Fall nicht: dort liest eine **Ebene** eine Regel schärfer als die andere, und die
Abweichung kann die richtige Dauerform sein; hier **sollen** beide Fassungen gleich sein und dürfen
nicht auseinanderlaufen.
