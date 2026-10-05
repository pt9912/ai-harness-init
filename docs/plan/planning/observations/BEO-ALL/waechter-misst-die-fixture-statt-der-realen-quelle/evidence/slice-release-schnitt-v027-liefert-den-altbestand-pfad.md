**Vorgang:** slice-release-schnitt-v027-liefert-den-altbestand-pfad
**Fund:** Der Pin-Wächter in `test/traeger-fetch.bats` läuft über einer Fixture; der reale
`Makefile`-Digest ist von keinem Fall gebunden (Verifikation 2026-10-05). Ob der Pin zum
veröffentlichten Asset passt, hält allein `make traeger-fetch` nach der Publikation (Exit 0 am Tag
`v0.2.7`); dessen Rot-Seite mit verfälschtem Digest wurde nicht gefahren.
