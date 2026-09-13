# Delta-Messung trifft den Quelltext statt den vendorten Baum

**Sub-Area:** `*` (gesamtes Repo)

Ein Delta zwischen zwei Baseline-Ständen wird am `git`-Baum der Ursprungs-Quelle gemessen, und das
Ergebnis wird als Aussage über den **vendorten** Baum dieses Repos berichtet. Die zwei Bäume
tragen denselben Text und nicht dieselben Bytes: Das Release-Verfahren stempelt Beispiel-Links mit
dem Release-Tag, und eine Vorlage, deren Quelltext sich nicht bewegt hat, unterscheidet sich im
Asset trotzdem. Die Fehlerrichtung ist *kein Delta* statt *ein Delta ohne Inhalts-Änderung* — die
Zusage bleibt syntaktisch heil und ist für den Gegenstand, den sie nennt, falsch.

Ein Nachbar teilt die Ursache und nicht den Ausgang:
[`vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
trifft den **Herstellungs**-Weg — dort wird aus der falschen Quelle gebaut, hier aus der falschen
Quelle gemessen. Wer nur die Herstellungs-Hälfte kennt, hält einen korrekt über
`make vendor-baseline` entstandenen Baum für gegen Aussagen dieser Art gefeit.
