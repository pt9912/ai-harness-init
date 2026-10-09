**Vorgang:** slice-ziel-traegt-keine-kennung-dieses-repos
**Fund:** Der Kommentar an `agentsAbschnittMuster` sagt, es gelte nur für Meldungen des Trägers; `TestTraegerMeldungenTragenKeineKennung` liest jedes Literal unter `cmd/` und `internal/`, auch emittierten Text, und meldete einen dort auflösenden Ziel-Abschnittsverweis falsch (Nachprüfung INFO-1, offen; heute kein Treffer).
