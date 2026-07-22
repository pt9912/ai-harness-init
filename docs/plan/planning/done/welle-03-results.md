# welle-03 — Closure-Notiz (Ergebnisse)

**Welle:** [welle-03-readme-und-smoke](welle-03-readme-und-smoke.md). **Meilenstein:** M2 (vollständiger Bootstrap) — **erreicht durch diese Welle**.
**Abschluss:** 2026-07-22 (beobachtbarer Trigger, kein Kalendertag).

Lerneintrag zur Wellen-Closure (Modul 6, Schritt 3): *was gelernt wurde*, nicht nur *dass sie weg ist*.

---

## 1. Geliefert

Der Bootstrap wird **vollständig und bewiesen**: ein frisch gebootstrapptes Zielrepo fährt sein eigenes `make gates` **out-of-the-box grün** ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — der Beweis, den welle-01 aufschob und welle-02 aus Schnitt-Gründen weitergab. **M2 erreicht.**

- **slice-005** — Root-README emittiert ([`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)): `emit.RootReadme` aus `project-readme.template.md`, gate-sichere Vorwärts-Verweise; senkte die Ziel-`docs-check`-Befunde real 5→3.
- **slice-028** — Emit out-of-the-box gate-sicher ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) 0.8.0, [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)): wiederkehrende Vorlagen referenziert statt co-located, derivative Indexe Fülle-wenn-Inhalt, Struktur via `.gitkeep`, Roadmap emit-seitig neutralisiert — `make smoke` 3→**0 Befunde**. Alles emit-seitig, vendored Baseline unberührt.
- **slice-024** — Voll-E2E-Smoke ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): neuer Nicht-Gate-Verify `make full-smoke` fährt im Ziel den **zusammengeführten** `make gates` ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check + Go-Gates) — real **9 Dateien, 0 Befunde, Exit 0**.

## 2. Was funktionierte

- **Rollen-treuer Lifecycle je Slice** (Modul 8/10/11): Reviewer **und** Verifier je in *frischem Kontext* (Subagenten) — fingen DoD-Behauptung vs. Bestätigung und je ein LOW (slice-028 Kommentar-Ehrlichkeit, slice-024 Marker `Befund`→`geprüft`).
- **Messen vor Implementieren** (Modul 9): slice-024s Ist-Messung deckte den Blocker (Emit nicht gate-sicher) **vor** dem Code auf → [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) an [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) nachgezogen (0.8.0) + **slice-028 eingeschoben** (Modul-5-Rücksprung statt Durchdrücken).
- **Sensor-Anhebung statt print-only** (slice-028): `make smoke` Schritt 4 *assertet* jetzt 0 Befunde; `make full-smoke` belegt, dass **alle vier** Gates wirklich liefen — beide mit rot gesehenem Gegenbeispiel (§3.6).

## 3. Was anders lief

- **slice-028 mitten in der Welle geschnitten**: slice-024s Voll-Smoke war der erste Integrations-Punkt und deckte auf, dass das emittierte Repo **nicht** out-of-the-box grün ist (3 docs-check-Befunde + Co-Location-Redundanz + Selbstwiderspruch der emittierten `AGENTS.md`). Statt Durchdrücken: Spec-Reconciliation ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) 0.8.0) + neuer Slice. Die Kette wurde 005 → **028** → 024.
- **Nutzer-Checkpoint bei Scope-Erweiterung** (slice-024): der CI-`full-smoke`-Job stand nicht im Plan §3; die Entscheidung „in slice-024 falten" fiel per AskUserQuestion, nicht einseitig — Review + Verifier bestätigten sie als legitim.

## 4. Steering-Loop-Einträge (wellen-übergreifend)

1. **print-only ist kein Sensor** (slice-028): ein „Beleg", der nur druckt statt zu *asserten*, lässt einen Defekt (nicht-gate-sicheres Ziel) unbemerkt durchlaufen. `make smoke` Schritt 4 + `make full-smoke` asserten jetzt Exit/0-Befunde. Muster für jeden Smoke-Schritt.
2. **Getrennte Targets ≠ zusammengeführter Gate** (slice-024): der Tier-2 `make smoke` fuhr docs-check und Go-Gates *getrennt* — das belegte **nie** den verdrahteten `make gates`-Einstiegspunkt ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)). `make full-smoke` fährt genau den, den ein Adopter tippt, und belegt per Lauf-Marker, dass keine Teilmenge still übersprungen wird.
3. **Load-bearing `.gitkeep`** (slice-028): ein Struktur-`.gitkeep` (`docs/plan/adr/`) hält den Verzeichnis-Link aus AGENTS.md/harness-README nach Wegfall von Index + NNNN-Template — Dekoration nur auf den ersten Blick; aufgedeckt durch Inbound-Link-Tracing, bestätigt durch Smoke.
4. **done/-Link-Churn — 7. Instanz, ÜBERFÄLLIG**: die zwei Lifecycle-Moves (slice-024 open→in-progress→done) brachen je 9 Inbound-Links in drei frozen `done/`-Slices + welle-03. Die Klasse liegt seit slice-025 als Backlog-Kandidat (Cluster D: `done/**`-Lifecycle-Link-Exemption als Gate-Policy-Änderung) vor — bei 7 Instanzen ist sie reif für einen eigenen Wartungs-Slice, nicht weiteres Vertagen.

## 5. Folge-Slices

Keine offenen aus welle-03. Benannte Kandidaten (in der [Roadmap](../in-progress/roadmap.md) mit Trigger-Bedingungen): **Cluster A** (Durchsetzung & Emission, [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)/[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) → **welle-04** bei erstem Slice-Schnitt; **Cluster D** die `done/**`-Link-Exemption + gemeinsamer Bootstrap-Helfer für die Smoke-Skripte (slice-024 Review-F-2), falls ein dritter Smoke-Sensor entsteht.

## 6. Verifikation (Belege, Modul 6 Schritt 1)

- **Trigger:** alle Slices (005/028/024) in `done/`; `make gates` grün (d-check **104 Dateien / 0 Befunde**, `baseline-verify` 42 Dateien, golangci-lint 0 issues, bats grün, `go test ./...` ok).
- **`make full-smoke` grün** (der welle-spezifische Beleg): Bootstrap in tmp-Repo → dort `make gates` **Exit 0 out-of-the-box**, d-check `9 Dateien geprüft, 0 Befunde`; alle vier Gates real gelaufen (`--target lint/build/test` + `geprüft`).
- **`make mutate` grün:** 29 Wächter, je rot unter ihrer Mutation (inkl. 26–29 neu aus slice-028).
- **Carveout-Audit** (Modul 7): [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) aktiv **und dokumentiert** (Auflösungs-Trigger nicht erfüllt — welle-03 fügte keine bats-Logik mit Verzweigung/Schleifen hinzu) → belegte „0 offen oder dokumentiert", kein stilles rotes Gate.
- **Pro Slice:** frischer-Kontext-Reviewer (je nicht merge-blockierend) + Verifier (je DoD bestätigt); Berichte unter [`docs/reviews/`](../../../reviews/).
