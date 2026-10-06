**Vorgang:** slice-kennungs-erkennung-traegt-die-zugelassenen-formen
**Fund:** Die Fundliste des Reviews wurde über das Wortmuster `slice-\[0-9\]` gezogen und verfehlte `internal/archive/collect.go:101`, dessen Muster `([0-9]+` heißt; die Verifikation fand die Stelle erst durch Lesen der Erkennung.
