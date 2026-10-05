# Verifikation — Pin-Zug Go 1.27.1 / golangci-lint v2.14.0 (Commit 911f4a93)

- **DoD 1 und 2 bestätigt.** `make freshness-go` Exit 0 („gepinnt und latest sind beide 1.27.1"), `make freshness-golangci` Exit 0 („… beide v2.14.0"). Auf den gebauten Images gelesen: `go version` im Lint- und Build-Image `go1.27.1 linux/amd64`, `golangci-lint --version` `2.14.0` (selbst mit go1.27.0 gebaut — Eigenschaft des Upstream-Binärs). Dockerfile-Digests stehen in Commit-Message und Diff; Pin-Menge im Diff = Plan (Makefile, Dockerfile, `internal/gen/golang.go`, beide Fallbacks).
- **DoD 3 bestätigt.** `make lint` Exit 0, Docker-Ausgabe „0 issues."; `make build` Exit 0. Kein `//nolint`, keine `.golangci.yml`-Änderung im Diff (Diff-Dateien: Dockerfile, Makefile, smoke.sh, full-smoke.sh, golang.go, Review-Report).
- **Rot-Belege selbst hergestellt, Baum danach sauber.** (a) Makefile `GO_VERSION` → 1.27.0: `make freshness-go` Exit 1/2, Meldung „gepinnt: 1.27.0 / latest: 1.27.1 -> GO_VERSION (Makefile) bumpen …" — trifft genau den Fehler. (b) `DefaultGoVersion` → 1.27.0: `make test-go` rot, `TestGoProfile_PinsMatchRepo`: „ARG GO_VERSION: generiert \"1.27.0\" != Repo-Dockerfile \"1.27.1\" (Drift, LH-QA-02)" — richtiger Grund.
- **Nicht bewacht, nicht bestätigt:** Dockerfile-`@sha256` (kein Wächter; ein vergessener Digest bliebe grün, hier nicht real gebrochen) und die Fallbacks in `smoke.sh`/`full-smoke.sh` (kein Wächter, Wert nur per Diff gelesen). Abgrenzung bestätigt: kein d-check-/Baseline-Pfad im Diff. Keine Findings.
- **`make gates`** (einmal am Ende, Exit ohne Pipe): Exit 0 (Stempel vom Lauf, Baum sauber bis auf diesen Bericht).

Laufzeit: ca. 8 Min.
