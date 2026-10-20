**Vorgang:** slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft
**Fund:** Die Erst-Fassung von `archiv_gueltig` rief `unzip` auf dem Host. Review und Verifier fanden es nicht; der Hauptkontext fing es im Handoff, der Implementer legte die Leseprobe in einen Container (`BATS_IMAGE`, kein neuer Pin).
