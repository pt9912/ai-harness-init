**Vorgang:** slice-mutate-laeuft-ueber-einen-ci-branch
**Fund:** Das Rezept `mutate-branch` reichte den Ref als `'$(REF)'` an die Shell, und der Shard-Job setzte `SLICE` aus dem Ref ebenso (Review MEDIUM-1, behoben in `c4c9fa4e`, Mutations-Fall 661).
