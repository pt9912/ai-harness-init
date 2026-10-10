**Vorgang:** slice-release-schnitt-v070-liefert-kotlin-und-v6180
**Fund:** Der Pin im realen `Makefile` ist wieder nur durch `make traeger-fetch` nach der Publikation an das Asset gebunden (Verifikation F3); kein Fall in `test/traeger-fetch.bats` färbt bei verfälschtem realem Digest.
