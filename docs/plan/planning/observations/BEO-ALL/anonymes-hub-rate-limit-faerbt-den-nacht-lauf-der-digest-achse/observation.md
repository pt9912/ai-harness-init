# Ein anonymes Hub-Rate-Limit färbt den Nacht-Lauf der Digest-Achse

**Sub-Area:** `*` (gesamtes Repo)

`make freshness-digest` löst den Digest jedes tag-tragenden Image-Pins gegen die Registry auf. Für die
zwei Docker-Hub-Pins (`golang`, `golangci-lint`) endet ein anonymes Hub-429 als `FETCH-FEHLER (kein
Urteil)` mit Exit 2, ohne dass ein Digest abweicht. Die Positivrichtung gegen die Registry ist für
diese beiden Pins unbelegt; wie oft der GitHub-Runner anonym limitiert wird, ist ungemessen. Das Risiko:
der Nacht-Lauf von `upstream-drift.yml` bleibt dauerhaft rot, und ein echter Digest-Befund geht im
Dauer-Rot unter.
