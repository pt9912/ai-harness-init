**Vorgang:** slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft
**Fund:** Verifier L2: Fälle 772 und 773 decken Stelle 1 und 2 mit einem abgeschnittenen Zip; die dritte Stelle hat keinen Fall, `archiv_gueltig` prüft keine Byte-Gleichheit (Plan: „verfälschtes Zip"). Benannt in `harness/sensors/full-smoke.md`.
