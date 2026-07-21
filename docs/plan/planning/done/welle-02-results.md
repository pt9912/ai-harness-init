# welle-02 — Closure-Notiz (Ergebnisse)

**Welle:** [welle-02-fetch-und-readme](welle-02-fetch-und-readme.md). **Meilenstein:** M2 (vollständiger Bootstrap) — **beitragend**; M2 wird in welle-03 erreicht.
**Abschluss:** 2026-07-21 (beobachtbarer Trigger, kein Kalendertag).

Lerneintrag zur Wellen-Closure (Modul 6, Schritt 3): *was gelernt wurde*, nicht nur *dass sie weg ist*.

---

## 1. Geliefert

Der **Distributions-Umbau** aus [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md): das Tool bezieht Regelwerk + Doc-Templates per **Fetch** aus der Kurs-SSoT (das Embed-Duplikat entfällt), **generiert** das Sprachskelett deterministisch aus tool-eigenem Wissen und **verdrahtet** beides zu einem kohärenten Zielrepo.

- **slice-022a** — Baseline-Fetch additiv ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): das Zielrepo erhält erstmals ein vendored Regelwerk mit Verifier.
- **slice-022b** — Embed raus ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)): die gefetchte Baseline ist einzige Template-Quelle; die Embed-Drift-Klasse ganz eliminiert.
- **slice-025** — Bootstrap-Kette per Pre-Flight abgesichert ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): „Kollision → kein Teil-Bootstrap", eingeschoben **vor** 023/004b, weil die Teil-Bootstrap-Klasse viermal aufgetreten war.
- **slice-023** — Go-Skelett-Generator deterministisch ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): Picker → Generator (Fetch abgelöst), Pins an das Repo-Dockerfile/`go.mod` gekoppelt, kuratiert-reiche `.golangci.yml`.
- **slice-004b** — Skelett verdrahtet ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)): Skelett am Ziel-Root, `Makefile` bindet `d-check.mk` ein ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) — **ein** `make gates` statt zweier Gate-Quellen.

slice-004a (Skelett-Fetch) lag bereits in `done/`, lieferte aber den Fetch-Pfad, den [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) ablöst — `done/` wird nicht zurückgesetzt (Modul 5: der Zustand ist die Verzeichnis-Position, Historie liegt in git).

## 2. Was funktionierte

- **Rollen-treuer Lifecycle je Slice** (Modul 8/10/11): Reviewer **und** Verifier je in *frischem Kontext* (Subagenten) — fing DoD-Behauptung vs. Bestätigung, was Tests übersehen und der Reviewer nicht sieht.
- **Messen vor Implementieren** (Modul 9): fand echte Plan-Drift **vor** Code — u. a. den 022-Re-Slice und den 004b-Re-Scope (verdrahten statt merge).
- **Mutations-Sensor** (`make mutate`, seit slice-026): jeder neue Wächter trägt seinen rot gesehenen Gegenbeispiel-Beleg (§3.6) — für die wire-Wächter 21/22/23 belegt.

## 3. Was anders lief

- **welle-02 umgeplant, nicht gekappt**: [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) machte das ursprüngliche Wellen-Ziel („Skelett vom Kurs-Tag holen") ungültig; Root-README + Voll-E2E-Smoke nach welle-03 verschoben, M2 mit ihnen.
- **slice-022 → 022a/022b re-sliced** und **slice-025 eingeschoben** (vor 023/004b) — beide aus der Ist-Messung vor der Implementierung (Modul-5-Rücksprung).
- **slice-004b re-gescopet**: kein Merge mehr (der Generator besitzt das `Makefile`), nur noch verdrahten.

## 4. Steering-Loop-Einträge (wellen-übergreifend)

1. **Pre-Flight vor Teil-Emit** (slice-025): eine mehrphasige Emit-Kette prüft **alle** Ziele, bevor sie das erste schreibt — „Kollision → kein Teil-Bootstrap". Muster für jeden künftigen Emit-Slice.
2. **Determinismus per statischem Inhalt + sortierten Writes** (slice-023): ein Generator ohne Netz/Zeit/Map-Iteration ist reproduzierbar; Pins an eine drift-test-gekoppelte Quelle (Repo-Dockerfile/`go.mod`) binden, nicht frei hardcoden.
3. **Ein `make gates` statt zweier Gate-Quellen** (slice-004b, [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)): das tool-generierte Doc-Gate-Fragment via `include` ans Code-Gate-`gates` hängen (Make kombiniert recipe-lose Prerequisites legal), nicht zwei konkurrierende `gates`.
4. **Benannte Prozess-Grenze — der Lifecycle-Move-Link-Churn**: er traf über die Welle wiederholt und bei dieser Closure ~zwölffach. Statt ihn weiter zu vertagen, wurde der §6-Follow-up-Backlog in die [Roadmap](../in-progress/roadmap.md) mit Trigger-Bedingungen gehoben; die `done/`-Lifecycle-Link-Exemption liegt als Cluster-D-Gate-Policy-Kandidat vor. Erster realer Carveout [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) angelegt (shell-lint deckt die bats-Dateien nicht ab).
5. **Benannte Spec-Grenze**: welle-02 lieferte den Distributions-Umbau, **nicht** den Voll-E2E-Grün-Beweis. Dass das emittierte Repo sein eigenes `make gates` 0-Befunde out-of-the-box fährt ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Happy-Path [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), ist bewusst welle-03 (slice-005/024).

## 5. Folge-Slices

Keine offenen aus welle-02. welle-03 (README & Voll-Smoke): slice-005 (Root-README, [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)) + slice-024 (Voll-E2E-Smoke, [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) — beide in `open/`. Weitere Kandidaten (Durchsetzung/Emission, Freshness, Doc-Gate-Härtung) im Roadmap-Backlog mit Trigger-Bedingungen.

## 6. Verifikation (Belege, Modul 6 Schritt 1)

- **Trigger:** alle Slices (022a/022b/025/023/004b; 004a schon vorher) in `done/`; `make gates` grün (d-check 98/0, `baseline-verify` 42 Dateien, golangci-lint 0 issues, bats `1..71`, `go test ./...` ok).
- **Tier-2-`make smoke` grün:** Bootstrap in tmp-Repo real — Skelett an den Root verdrahtet (`d-check.mk` eingebunden) + Go-Gates grün. Der **Voll**-E2E-`make gates`-Green-Run bleibt welle-03 (Smoke Schritt 4: fünf erwartete Forward-Verweis-Befunde).
- **`make mutate` grün:** 23 Wächter, je rot unter ihrer Mutation (inkl. wire 21/22/23).
- **Carveout-Audit** (Modul 7): [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) aktiv **und dokumentiert** (mit Auflösungs-Trigger) → belegte „0 offen oder dokumentiert", kein stilles rotes Gate.
- **Pro Slice:** frischer-Kontext-Reviewer (je nicht merge-blockierend) + Verifier (je DoD bestätigt); Berichte unter [`docs/reviews/`](../../../reviews/).
