**Vorgang:** slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget
**Fund:** Im Re-Lauf eines `v0.8.0`-Go-Ziels mit dem `v0.9.0`-Träger baut `make lint` die `deps`-Stage mit Go `1.27.1`, weil das Lint-Rezept in `go.mk` `GO_VERSION` nicht übergibt (Verifikation F-2, Review F-2).
