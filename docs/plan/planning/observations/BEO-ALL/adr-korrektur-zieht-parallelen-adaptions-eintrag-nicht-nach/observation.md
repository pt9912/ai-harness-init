# ADR-Korrektur zieht parallelen Adaptions-Eintrag nicht nach

**Sub-Area:** `*` (gesamtes Repo)

Eine ADR und ein `MR-<NNN>`-Eintrag im Adaptions-Block dokumentieren dieselbe Entscheidung und
dieselbe Messung parallel, in zwei Dateien. Ein Fix am ADR-Text — Reviewer- oder Verifier-Befund —
korrigiert die Zahlen an einer Stelle und lässt die zweite unverändert stehen: Kein Sensor hält die
beiden Artefakte gegeneinander, weil
[`MR-025`](../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)/[`MR-051`](../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
die Form einer Zahl je Kommando prüfen, nicht die Übereinstimmung zwischen zwei Kommandos in zwei
Dateien, die dieselbe Messung behaupten.
