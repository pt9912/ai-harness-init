**Stand:** verkörpert — `make release-warten`, im `ci`-Job `full-smoke` der Schritt vor
`make full-smoke` (`seit slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`).

Die Target-Zeile im `Makefile` trägt den Herkunfts-Anker nicht; die Herkunft steht hier. Der
Warte-Schritt trägt bis zu seiner Grenze: folgt der Tag dem Push von `main` später, fällt `ci` an
`make traeger-fetch` im frischen Klon, bis ein Re-Run nach der Publikation es hebt (Beleg
`slice-release-schnitt-v070-liefert-kotlin-und-v6180`). Der operative Ausgang nach überschrittener Grenze steht in
[`docs/user/releasing.md`](../../../../../../docs/user/releasing.md) §Prozedur, Schritt 6.
