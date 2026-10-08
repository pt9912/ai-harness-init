**Stand:** verkörpert

Zielort: [`spec/spezifikation.md`](../../../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5 — `SPEC-088` (`rule_version` in jeder Zeile), `SPEC-089` (Zählregel und Fassungs-Tabelle),
`SPEC-094` (die geschriebene Fassung ist die letzte Tabellenzeile). Kein Herkunfts-Anker: der Zielort
trägt seine eigene Kennung
([ADR-0049](../../../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1).

Sensor: `TestCurrentRuleVersionIsTheLastSpecFassung` (`make test`) hält die Konstante gegen die reale
Fassungs-Tabelle, Mutations-Fall `593-span-fassung-ohne-tabelle-hochgezaehlt`; Fall `592` hält das
Feld in jeder Zeile.

Grenze: ob ein Bedeutungswechsel als solcher erkannt und hochgezählt wird, hält kein Wächter
(`SPEC-094`). Ein Golden-Test je Fassung wäre baubar und ist nicht gebaut; tritt ein unangekündigter
Bedeutungswechsel auf (neuer Beleg dieser Klasse), wird er als Slice geschnitten.
