# Fitness-Zeile einer angenommenen ADR ist nach einer späteren Änderung tot

**Sub-Area:** `*` (gesamtes Repo)

Eine Fitness-Zeile einer `Accepted`-ADR erwartet einen Zustand, den eine spätere, in derselben ADR vorgesehene Änderung
(dort: Lastenheft 0.23.0) schon hergestellt hat: Das Kommando gibt nichts mehr aus, und die Zeile meldet rot, obwohl der Zustand dem
Soll entspricht. Dazu ein Platzhalter im Kommando, der es unausführbar lässt. Korrigieren darf sie nur eine Folge-ADR (`AGENTS.md` §3.4).

## Benannt, nicht gezählt

Nachbar [`lebendes-register-traegt-eine-ueberholte-fundliste`](../lebendes-register-traegt-eine-ueberholte-fundliste/observation.md): dort ein lebender Eintrag; hier ein eingefrorener.
