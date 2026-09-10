**Vorgang:** slice-140
**Fund:** Wieder beide Richtungen im selben Vorgang. Der Eingangs-Move machte den Ruhe-Marker
*„Nichts in Arbeit."* unter `## Offene Wellen` falsch und verlangte einen eigenen Commit
(`1d7cd066`), der Closure-Move macht seine **Abwesenheit** falsch und verlangt denselben Commit
in die Gegenrichtung. `make slice-mv` kann das nicht abnehmen — es zieht nach eigener, gemessener
Zusage Pfade nach, keine Zustandssätze —, und das Modul `planning` färbt genau diesen Widerspruch
rot (`planning-drift`). Ein bewachtes Zustandsfeld, dessen Wächter trägt und dessen Pflege bei
jedem einzelnen Lifecycle-Übergang von Hand anfällt: der Sensor ist in Ordnung, der fehlende
Träger ist der Move.
