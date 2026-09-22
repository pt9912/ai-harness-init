**Vorgang:** slice-216
**Fund:** Der Architect-Lauf zu ADR-0061 (`522acc0f`) aktualisierte die Zahlen im ADR-Text nach
einem Reviewer-Finding (F-1/F-3), ließ den parallelen Adaptions-Eintrag `MR-072` — dieselbe
Entscheidung, dieselbe Messung — dabei unverändert. Der Verifier fand die Abweichung; ein
Folge-Commit (`c619f314`) zog `MR-072` nach (144/345 → 171/520 Report-Verweise, 44 → 58
`[haenger]`-Fundstellen). Kein Gate dieses Repos hält zwei Norm-Artefakte zur selben Entscheidung
gegeneinander.
