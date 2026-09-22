**Vorgang:** slice-leser-und-aufraeum-waechter-decken-was-sie-sagen
**Fund:** Review-Runde 2 (F-3, HIGH) fand den Kommentar über
`TestErfassung_ZeileMitDerMarkeBleibtOhneBefund` (Commit `e03908fe`), der den abwesenden
Vorzustand vor einem Commit im Konjunktiv erzählte („Vor 3147fe59 waren Pruefung und Meldung an
zwei unabhaengig getippten Literalen aufgehaengt; eine Zeile … waere dort trotzdem als Befund
gemeldet worden") statt die geltende Zusage im Indikativ zu nennen — drittes reale Auftreten
derselben Klasse in dieser Sitzung (nach dem Vorgänger-Review vom 2026-09-21 für Commit `3147fe59`
und dessen dortiger F-1). Behoben in `a147be2b`: Kommentar nennt jetzt nur, dass Prüfung und
Meldung dieselbe Konstante lesen, keine Chronik über eine frühere Fassung.
