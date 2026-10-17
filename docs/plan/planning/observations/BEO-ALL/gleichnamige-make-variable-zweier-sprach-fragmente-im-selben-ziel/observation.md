# Gleichnamige Make-Variable zweier Sprach-Fragmente im selben Ziel

**Sub-Area:** `*` (gesamtes Repo)

Zwei Sprach-Fragmente, die in dasselbe Ziel emittiert werden, teilen sich den Make-Namensraum: Das
Java-Fragment trägt `JAVA_GRADLE_TAG`, weil `GRADLE_TAG` im Kotlin-Fragment desselben Ziels vergeben
ist. Ein Fragment mit gleichem Variablennamen überschriebe den Wert des anderen, ohne dass ein Sensor
es meldet.
