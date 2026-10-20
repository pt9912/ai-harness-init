# Das Zähl-Kommando einer Doku-Zeile zählt nur eine Zeilenart der Quelle, die sie meint

**Sub-Area:** `*` (gesamtes Repo)

Eine Pflichtzeile in einer Nutzer-Doku sagt zu, ein Bericht nenne eine Menge (Fälle ohne Ergebnis) und liefert die Zahl über ein `grep -c` auf der Ergebnisdatei. Die Datei kennt für diese Menge mehr als eine Zeilenart (`FEHLT` für einen Fall ohne Shard-Beleg, `BEFUND (kein Ergebnis im Log)` für einen gezogenen Fall ohne Ergebniszeile); das Kommando zählt eine. Es liefert 0 für die Klasse, die den Anlass der Zeile bildet, und ein Bericht „0 Fälle ohne Ergebnis" ist über dem Ausschnitt grün. Die Fehlerrichtung ist *die Zahl ist gebunden*. Die Zeile ist gegen das Format der echten Quelle zu halten, nicht gegen die Vorstellung vom Format.

## Benannt, nicht gezählt

[`sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter`](../sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter/observation.md) liest die Menge eines **Sensors** aus einem Meldungs-Wortlaut; hier liest eine **Doku-Zeile** ein Zählkommando über einer Datei, deren Format der Schreiber vor Augen hatte.
[`vollstaendigkeits-zusage-misst-falsche-ebene`](../vollstaendigkeits-zusage-misst-falsche-ebene/observation.md) betrifft die Ebene (Datei statt Hunk); hier ist die Ebene richtig und die Zeilenart unvollständig. Ob eine der beiden die Klasse trägt, ist ungeurteilt.
