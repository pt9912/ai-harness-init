**Vorgang:** slice-stop-hook-bindet-an-den-commit
**Fund:** Liefer-Punkt 1 und Plan §3 nannten bats über dem echten Hook; geliefert ist
`internal/emit/stophook_test.go` (Go, `make test`), weil das bats-Image kein `git` führt. Weder Plan
noch ein Übergabe-Artefakt nannten den Tausch (Review LOW-1); die Verifikation gab DoD 1 darum nur
bedingt. Der Planner zog DoD 1 und §3 bei der Closure nach.
