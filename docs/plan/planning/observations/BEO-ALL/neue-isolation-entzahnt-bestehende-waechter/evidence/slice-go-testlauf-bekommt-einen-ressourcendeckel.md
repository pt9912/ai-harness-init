**Vorgang:** slice-go-testlauf-bekommt-einen-ressourcendeckel
**Fund:** `fa94d667` (Implementer-Fix auf einen Verifier-Befund hin): der Umbau des
`test-go`-Rezepts auf `docker run --network none` (DoD 1 — kein Mount) entzahnte
`TestUnfallVektor_OhneArgumentImRepoWurzel` gegenüber
`test/mutations/378-init-argumentlos-bricht-aber-schreibt.sh`: der produktive Baseline-Fetch
scheiterte unter der Netz-Isolation sofort am Netz, bevor ein mutiertes `bootstrap()` den
Schreibzugriff erreichte — der Wächter blieb grün, die Mutation war folgenlos. Fix:
Opt-in-Override `AI_HARNESS_INIT_BASELINE_URL_BASE` mit Loopback-Server im Prozess-Test; Rot und
Grün am realen Ort gefahren (Mutation angewandt → FAIL mit der behaupteten Meldung,
zurückgesetzt → PASS), vom Review in Nachtrag 2 mit eigenem Rot/Grün-Zyklus bestätigt.
