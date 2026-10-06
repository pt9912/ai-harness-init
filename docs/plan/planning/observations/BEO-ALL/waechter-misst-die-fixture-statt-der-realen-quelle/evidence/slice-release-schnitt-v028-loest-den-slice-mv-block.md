**Vorgang:** slice-release-schnitt-v028-loest-den-slice-mv-block
**Fund:** Der Pin-Wächter in `test/traeger-fetch.bats` läuft über einer Fixture; ein verfälschter
Digest im realen `Makefile` färbt keinen Fall (Verifikation 2026-10-06). Ob der Pin zum
veröffentlichten Asset passt, hält allein `make traeger-fetch` nach der Publikation (Exit 0 am Tag
`v0.2.8`, Exit 2 „Digest-Abweichung" mit verfälschtem Digest).
