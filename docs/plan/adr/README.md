# ADR-Index — ai-harness-init

Architecture Decision Records im MADR-/Nygard-Stil. Akzeptierte ADRs sind
immutable (`AGENTS.md` §3.4) — Korrekturen entstehen als neue ADR mit
*Supersedes*.

| ADR | Titel | Status | Bezug |
|---|---|---|---|
| [ADR-0001](0001-skelett-distribution.md) | Distribution der Sprachskelette | Superseded by [ADR-0005](0005-ziel-repo-distribution.md) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0002](0002-test-tooling-grenze.md) | Test-Tooling-Grenze (bats) ggü. [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) | Superseded by [ADR-0003](0003-go-native-binaries.md) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0003](0003-go-native-binaries.md) | Implementierungssprache Go + native-Binary-Distribution | Accepted | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0004](0004-durchsetzungs-emission.md) | Durchsetzungsschicht-Emission + Guard in bash/awk | Accepted | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [ADR-0005](0005-ziel-repo-distribution.md) | Ziel-Repo-Distributionsmodell (Fetch Kurs-SSoT + deterministische Generierung) | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) | Durchsetzungsschicht + Workflow-Commands — Tool-als-Quelle statt Picker | Proposed | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
