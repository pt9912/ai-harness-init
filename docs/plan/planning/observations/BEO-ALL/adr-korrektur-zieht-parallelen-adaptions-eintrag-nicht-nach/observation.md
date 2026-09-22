# ADR-Korrektur zieht parallelen Adaptions-Eintrag nicht nach

**Sub-Area:** `*` (gesamtes Repo)

Eine ADR und ein `MR-<NNN>`-Eintrag im Adaptions-Block dokumentieren dieselbe Entscheidung und
dieselbe Messung parallel, in zwei Dateien. Ein Fix am ADR-Text — Reviewer- oder Verifier-Befund —
korrigiert die Zahlen an einer Stelle und lässt die zweite unverändert stehen: Kein Sensor hält die
beiden Artefakte gegeneinander, weil `MR-025`/`MR-051` die Form einer Zahl je Kommando prüfen, nicht
die Übereinstimmung zwischen zwei Kommandos in zwei Dateien, die dieselbe Messung behaupten.
