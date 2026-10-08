**Vorgang:** slice-ci-wartet-die-publikation-des-gepinnten-releases-ab
**Fund:** Der Kommentar am `timeout-minutes` des `ci`-Jobs `full-smoke` begründete den Wert mit „4 bis 9 Minuten" Laufzeit am 2026-10-07, ohne Kommando; der Verifier maß über `gh run view <id> --json jobs` an demselben Tag 233 s bis 949 s. Behoben in `0d0ed654` (der Kommentar nennt die Zusage statt Messwerten).
