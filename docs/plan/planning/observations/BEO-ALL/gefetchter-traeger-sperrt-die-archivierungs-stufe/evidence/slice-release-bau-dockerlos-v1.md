**Vorgang:** slice-release-bau-dockerlos-v1
**Fund:** Der planmäßige CI-Branch-Lauf der Mutations-Probe (Workflow
`mutate-branch.yml`, Run 46158137040, Zweig
`mutate/slice-release-bau-dockerlos-v1-908725fe`, 124 Fälle auf 10 Shards,
577 s Wanduhr) brach je Grün-Vorlauf an `make full-smoke` in der Kopie —
**ohne Mutation**: der aus `TRAEGER_TAG` (gepinnt `v0.10.0`) gefetchte Träger
sperrt über dem heutigen Bestand (`[untergrenze]`-Sperre der eigenen
Archivierung) — dieselbe Kante, die der `ci`-Job `full-smoke` am Push von
`main` fährt. Die Shards liefen nie durch: kein Fall-Ergebnis,
`mutate-ergebnis.txt` trägt `Urteil: BEFUND` je ABRUCH. Die direkte
Rot-Messung der Fälle 835–838 trägt der lokale Beleg an der realen Quelle
(Hand-Mutation je Wächter `not ok`; Fall 838 je Treiber-Lauf, Commit
`7063c0b9`) — der ABBRUCH ist kein Beleg-Defekt des Slices
`slice-release-bau-dockerlos-v1`, sondern derselbe benannte Blocker; Träger
des Bruchs ist `slice-traeger-tag-nachzug-untergrenze-v1` (liegt in
`in-progress/`). Zweites Auftreten der Klasse.
