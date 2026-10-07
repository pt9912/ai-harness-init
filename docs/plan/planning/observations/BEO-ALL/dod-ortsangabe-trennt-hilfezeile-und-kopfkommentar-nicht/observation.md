# DoD-Ortsangabe trennt Hilfezeile und Kopfkommentar nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Text-DoD nennt eine Gattung („Hilfetext") statt des Orts im Artefakt; Implementer und Verifier
lesen verschiedene Stellen (Kopfkommentar gegen `##`-Hilfezeile eines make-Fragments), und das
Urteil fällt erst bei der Closure.
