# Die Abweichung von einer Accepted-ADR trägt nur der Slice-Plan

**Sub-Area:** `*` (gesamtes Repo)

Eine dokumentierte Abweichung von einer `Accepted`-ADR ist im Slice-Plan begründet, und die Tests binden die abweichende Form — aber kein lebendes Artefakt trägt die Abweichung. Der Plan ist ein Planungs-Artefakt mit Lifecycle-Ende; das Fahrzeug für die Abweichung ist das Architect-Verdikt als Folge-ADR mit `supersedes` (Baseline-Regelwerk `v6.13.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz). Die Fehlerrichtung ist: mit dem Lifecycle-Ende des Plans steht die Abweichung nur noch in einem Zeitdokument, und die Implementation liest sich gegen die `Accepted`-Fassung, die sie gerade verletzt.
