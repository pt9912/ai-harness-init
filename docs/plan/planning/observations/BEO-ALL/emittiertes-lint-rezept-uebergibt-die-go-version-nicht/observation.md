# Das emittierte Lint-Rezept des Go-Skeletts übergibt die Go-Version nicht

**Sub-Area:** `*` (gesamtes Repo)

Das Rezept `lint` in der emittierten `harness/mk/go.mk` (Vorlage `internal/gen/golang.go`) reicht `GO_VERSION` nicht als Build-Argument weiter. Die `deps`-Stage des `Dockerfile` baut dadurch mit ihrem eigenen Default, während `make test` und `make build` den Pin der `go.mk` setzen. Nach einem Pin-Sprung läuft ein erneut aufgesetztes Go-Ziel gemischt: Lint-Binary neu, `deps`-Stage alt. Gemessen am Re-Lauf eines `v0.8.0`-Ziels mit dem `v0.9.0`-Träger (Go `1.27.1` in der `deps`-Stage, `1.27.2` in Test und Build). Das Lint-Ergebnis des gemischten Standes ist nicht gemessen.
