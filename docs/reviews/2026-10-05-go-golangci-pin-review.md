# Review — Go 1.27.1 / golangci-lint v2.14.0 Pin-Zug (Commit 911f4a93)

Gegenstand: slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140; Bezug LH-QA-02, MR-048, AGENTS.md §3.2/§3.5/§3.9.

## Findings

Keine HIGH/MEDIUM/LOW.

## Geprüft, ohne Befund

- **Pin-Vollständigkeit:** `grep -rn '1\.27\.0\|v2\.13\.1' . --exclude-dir={.git,baseline,reviews,done}` trifft nur Fixture-/Zeitdokument-Stellen (`test/full-smoke-ausgang.bats` CI-Log-Zitat, `test/mutate-driver.bats:489` synthetischer Plan-Text, Kommentar in `full-smoke-ausgang.sh`, Evidence-Datei); keine tragende Pin-Stelle bleibt.
- **Digests:** `docker buildx imagetools inspect golang:1.27.1` = `sha256:e0174e51…db190`, `golangci/golangci-lint:v2.14.0` = `sha256:ad862ba6…bf98f`; beide gleich den Dockerfile-Werten; die Dockerfile-Tags sind `golang:${GO_VERSION}` bzw. `golangci-lint:${GOLANGCI_LINT_VERSION}` ohne Variante, der Digest gilt für genau diese Tags.
- **Suppression/Gates:** `.golangci.yml` unberührt, 0 `nolint` im Diff, keine Schwellen-Änderung.
- **gen-Konsistenz:** `internal/gen/golang.go` (1.27.1 / v2.14.0) = Makefile = Dockerfile-ARG; `make test-go` grün inkl. `TestGoProfile_PinsMatchRepo`.
- **Lücken-Benennung im Plan:** §3.6 benennt Digest, Makefile-Pin und Fallbacks korrekt als ungewächtert (Test koppelt nur ARGs ↔ gen); kein Widerspruch zum Code.
