**Vorgang:** slice-go-testlauf-bekommt-einen-ressourcendeckel
**Fund:** F-1 (MEDIUM, Review-Runde 1): der neue Deckel-Wächter
(`internal/resourcecap`, Rezept `test-go-pids-guard`) hatte keinen Fall in `test/mutations/` —
eine stille Entfernung von `--pids-limit`/`--memory` aus dem `test-go`-Rezept wäre weder von
`make gates` noch von `make mutate` bemerkt worden. Im selben Vorgang geschlossen: `fb11116f`
legte die Fälle 498/499 an (sed-Anker am `test-go`-Block, `expect:` auf die neuen
bats-Assertionen), beide real rot gesehen. Ein Vorgang — gezählt als ein Auftreten.
