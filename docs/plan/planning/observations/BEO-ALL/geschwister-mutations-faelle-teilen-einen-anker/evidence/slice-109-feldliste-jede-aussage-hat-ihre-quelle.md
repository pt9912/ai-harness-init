**Vorgang:** slice-109-feldliste-jede-aussage-hat-ihre-quelle
**Fund:** Die Mutations-Fälle `489-feldliste-program-notiz-verneinung-verliert` und
`490-feldliste-program-notiz-positive-haelfte-falsch` (Notiz zum Feld `program`) ankern beide auf
dem Teilstring „das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile" —
nach
[`MR-071`](../../../../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
zulässig (Verifikations-Report 2026-09-27, Abschnitt zur Anker-Frage), aber eine
künftige Wortlaut-Änderung an genau dieser Zeile würde beide Fälle gleichzeitig entwaffnen.
