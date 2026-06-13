# ADR-Index — ai-harness-init

Architecture Decision Records im MADR-/Nygard-Stil. Akzeptierte ADRs sind
immutable (`AGENTS.md` §3.4) — Korrekturen entstehen als neue ADR mit
*Supersedes*.

| ADR | Titel | Status | Bezug |
|---|---|---|---|
| [ADR-0001](0001-skelett-distribution.md) | Distribution der Sprachskelette | Accepted | `LH-FA-04`, `LH-QA-02` |
| [ADR-0002](0002-test-tooling-grenze.md) | Test-Tooling-Grenze (bats) ggü. `LH-QA-03` | Superseded by [ADR-0003](0003-go-native-binaries.md) | `LH-QA-03`, `LH-QA-01` |
| [ADR-0003](0003-go-native-binaries.md) | Implementierungssprache Go + native-Binary-Distribution | Accepted | `LH-QA-03`, `LH-QA-04`, `LH-QA-02` |
