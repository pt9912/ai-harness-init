**Vorgang:** slice-zeilenenden-meldungstest-bindet-das-verzeichnis
**Fund:** Die Aussage-Schleife von `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` suchte `path.Dir(rel)+"/"` per `strings.Contains`; mit `tools/harness/mk/` im Aussagesatz blieb `make test-go` grün (Review LOW F-1), behoben über eine Wortgrenze, Fall 587.
