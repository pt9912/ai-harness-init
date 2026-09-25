# Sensor leitet aus dem Meldungs-Wortlaut des Trägers ab, ohne Format-Halter

**Sub-Area:** `*` (gesamtes Repo)

Ein Sensor liest die Menge, die er fährt, aus dem Wortlaut einer Fehlermeldung des Werkzeugs, das er
prüft — Marker, Trenner, Zeilenform. Die **Inhalte** der Listen halten Tests über die Felder der
Fehlertypen; das **Format** der Meldung hält keiner. Die Fehlerrichtung ist doppelt: Eine Umbenennung
des Markers ist laut zu fangen (der Sensor schlägt fail-closed an), eine in sich stimmige Fehlmeldung —
eine getragene Kombination, abgelehnt mit einer Liste, die sie nicht nennt — ist aus der Meldung allein
von einer echten Ablehnung nicht zu unterscheiden, und der Sensor fährt still weniger.

## Benannt, nicht gezählt

[`exit-zusage-aus-anderem-aufruf-abgeleitet`](../exit-zusage-aus-anderem-aufruf-abgeleitet/observation.md)
trifft die Ableitung einer Zusage aus einem **anderen Aufruf** desselben Werkzeugs; hier ist die Quelle
der richtige Aufruf, und ihr Wortlaut hat keinen Vertrag.
