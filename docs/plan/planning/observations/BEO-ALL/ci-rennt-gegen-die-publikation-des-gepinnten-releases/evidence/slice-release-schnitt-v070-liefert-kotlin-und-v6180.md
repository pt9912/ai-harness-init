**Vorgang:** slice-release-schnitt-v070-liefert-kotlin-und-v6180
**Fund:** `main` mit Pin `v0.7.0` lag bis zum Tag-Push vor der Publikation; der `full-smoke`-Job an `a6ed0813` wartete die Grenze von `make release-warten` ab und fiel an der Träger-Fetch-Stufe; grün nach `gh run rerun --failed` (Verifikation F1).
