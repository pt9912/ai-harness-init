**Vorgang:** slice-221
**Fund:** Review-Runde 2, LOW-1 — `test/mutations/314-archive-welle-go-haenger-nachzug-suchraum.sh`
adressierte mit `sed -i '180s/Suchraum(/SuchraumNachzug(/'` als einziger Fall des Bestands per
Zeilennummer (`grep -lE "sed -i '[0-9]+s" test/mutations/*.sh` → eine Datei gegen
`ls test/mutations/*.sh | wc -l` → 300; keine Erwartungswerte), obwohl ein eindeutiges Muster in
derselben Datei vorlag. Wie beweglich die Adresse ist, zeigt derselbe Slice: In Runde 1 traf sie
noch bei Zeile 168, die 12 Kommentarzeilen der Nacharbeit schoben sie auf 180. Der Reviewer hat
beide Ausgänge an einer Kopie außerhalb des Baums real gemessen — Verschiebung um 1 Zeile:
No-op, Meldung *„Patch veraltet?"*; Verschiebung um 12 Zeilen: Treffer auf die
`// SUCHRAUM:`-Kommentarzeile, Code unberührt, Meldung *„hat keine Zaehne mehr"*. Behoben in
derselben Runde: Der Fall ankert seither am Muster `range Suchraum(dateien)` und trägt die
Begründung in seinem Kopf.
