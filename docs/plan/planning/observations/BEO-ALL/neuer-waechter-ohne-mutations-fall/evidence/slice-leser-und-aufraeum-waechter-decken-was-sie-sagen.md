**Vorgang:** slice-leser-und-aufraeum-waechter-decken-was-sie-sagen
**Fund:** Review-Runde 1 (F-2, LOW) fand, dass der zweite `span-clean`-Lauf-Zahn in
`harness/tools/full-smoke.sh` (Zeilen 1150–1157, Commit `3147fe59`) — anders als der
Nachbar-Zahn direkt darüber mit seinem `test/mutations/176`-Rot-Gegenbeispiel — keinen eigenen
bindenden Fall in `test/mutations/` trägt. Der Verifier hat den Fund als nicht blockierend
eingestuft, aber offen belassen: Bisher wurde nur isoliert und unpersistiert geprüft, dass der
Zahn aus dem richtigen Grund rot liefe, ohne dauerhaftes Artefakt. Bewusst nicht in diesem Slice
geschlossen — ein bindender Fall bräuchte `# verify: full-smoke` und damit einen vollen
`full-smoke`-Lauf, der auf diesem Host strukturell nicht läuft (siehe
`lokaler-full-smoke-scheitert-auf-macos-host`); der Aufwand hätte den Rahmen dieses Slice
gesprengt. Benannte, akzeptierte Lücke statt stiller Verschleppung.
