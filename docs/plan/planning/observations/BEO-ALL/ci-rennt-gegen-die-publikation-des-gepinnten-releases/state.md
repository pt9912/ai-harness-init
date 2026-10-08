**Stand:** verkörpert — `make release-warten`, im `ci`-Job `full-smoke` der Schritt vor
`make full-smoke` (`seit slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`).

Die Target-Zeile im `Makefile` trägt den Herkunfts-Anker nicht; die Herkunft steht hier. Der
Nachweis am Tag-Commit steht aus: der nächste Release-Schnitt liest diesen Eintrag — fällt der
`ci`-Lauf dort trotz Warte-Schritt an `make traeger-fetch` im frischen Klon, ist das ein neuer Beleg.
Der operative Ausgang nach überschrittener Grenze steht in
[`docs/user/releasing.md`](../../../../../../docs/user/releasing.md) §Prozedur, Schritt 6.
