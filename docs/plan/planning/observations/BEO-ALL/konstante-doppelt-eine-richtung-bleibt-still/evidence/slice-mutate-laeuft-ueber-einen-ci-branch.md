**Vorgang:** slice-mutate-laeuft-ueber-einen-ci-branch
**Fund:** Die Shard-Zahl stand in `mutate-branch.yml` als Matrix 0–9 und als `SHARDS=10`; wuchs die Matrix, fielen Shards still aus dem Ergebnis (Review MEDIUM-2, behoben mit einer Quelle `CI_SHARDS` und dem Urteil `FEHLT`, Fall 664).
