**Vorgang:** slice-release-bau-dockerlos-v1
**Fund:** Review Befund F-3: der [MR-014](../../../../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Text-Wächter über der YAML
(`test/release-host-bau.bats`) scannt erst nach `sed 's/#.*$//'` — ein
Container-Zug hinter einem `#` in einem quoted `run:`-Wert entkomgt dem Scan
(Formen-Probe, 5 Formen auf Kopien unter /tmp, Form 2 entkomgt). Der Wächter
besteht, trifft aber nicht; die Grenze nennt der Testkopf nicht. Kein Sensor
fährt die quoted-Hash-Text-Form; die Konsequenz trägt der reale
CI-Dispatch-Lauf. Benannt im Review-Report
`docs/reviews/2026-11-28-slice-release-bau-dockerlos-v1.md` (F-Klasse
"Grenzform eines Text-Wächters unbenannt") — hier nachgetragen, nicht behoben.
