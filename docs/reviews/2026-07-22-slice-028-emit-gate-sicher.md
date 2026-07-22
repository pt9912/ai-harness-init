# Review — slice-028: Emit out-of-the-box gate-sicher

- **Rolle:** Unabhängiger Reviewer (Modul 10, frischer Kontext — Code nicht selbst geschrieben).
- **Reviewer-Skill:** `.harness/skills/reviewer.md` v1.2.0 (Baseline v3.5.0).
- **Prüfgegenstand:** `git diff f310d2d..HEAD` (4 Commits: 3× Lifecycle-Move/Churn `open→in-progress`, 1× Feature `8751e5c`).
- **Datum:** 2026-07-22.
- **Eingangs-Kontext (5 Pflicht-Punkte + Slice-Plan):** Diff-Range ✓ · `spec/lastenheft.md` LH-FA-02/-01, LH-QA-01 ✓ · `docs/plan/adr/0005-ziel-repo-distribution.md` ✓ · `AGENTS.md` §3 (3.1/3.4/3.6) ✓ · vorherige Findings `docs/reviews/` (slice-022b F-1/F-2/F-3/F-4, slice-026 F-1/F-2/F-5/N-2) ✓ · Slice-Plan `docs/plan/planning/in-progress/slice-028-emit-gate-sicher.md` §3/§6 ✓.
- **Betroffene Komponenten:** `internal/emit/templates.go`, `internal/emit/templates_test.go`, `harness/tools/smoke.sh`, `test/courseset-fixture.bats`, `test/mutations/08,26,27,28,29`.

---

## Findings

### F-1 (LOW) — Kommentar überzeichnet die Drift-Abdeckung des Roadmap-Wächters

- **kategorie:** LOW
- **quelle:** Maintainability (gate-safety-adjazent, LH-QA-01)
- **pfad:** `internal/emit/templates.go:~272` (Kommentar über `NeutralizeRoadmap`); Bezug `internal/emit/templates_test.go:TestTemplates_RoadmapGateSafe`, `test/courseset-fixture.bats:17-19`
- **befund:** Der Kommentar behauptet, eine geänderte/entfallene Kurs-Link-Form fange „`TestTemplates_RoadmapGateSafe` (kein `](../done/` im Ziel) bzw. der Voll-Smoke". `TestTemplates_RoadmapGateSafe` läuft aber gegen die **handgeschriebene** `courseSet()`-Fixture, deren Roadmap-Zeile fix `roadmapDoneLink` spiegelt; `courseset-fixture.bats` koppelt nur den **Dateibestand**, nicht den Zeilen-Inhalt. Ändert upstream die „Abgeschlossene Wellen"-Zeile (Label/Pfad), no-op-t `NeutralizeRoadmap` (exakter `ReplaceAll`) still auf dem realen Emit, während `TestTemplates_RoadmapGateSafe`/`make gates` grün bleiben. Real fängt es allein `make smoke` (Tier-2, DoD/Closure, **nicht** in `make gates`) über den docs-check-Exit. Die genannte Fidelity-Absicherung trägt also nur der Smoke, nicht der benannte go-Test.
- **verifizierbar:** ja — Zeilenform in der realen `templates/docs/plan/planning/roadmap.template.md` (oder `roadmapDoneLink`) divergieren lassen: `make test`/`make gates` bleiben grün, `make smoke` wird rot. Heute deckungsgleich (real Zeile 62 == `roadmapDoneLink`, verifiziert), also kein aktuelles Silent-Green.

---

## Negativbefunde (geprüft, ohne Befund)

- **Silent-Green / NeutralizeRoadmap-Fidelity:** `roadmapDoneLink` = `` [`welle-NN-results.md`](../done/welle-NN-results.md) `` stimmt **byte-genau** mit der realen `templates/docs/plan/planning/roadmap.template.md:62` überein — der `ReplaceAll` greift auf dem realen Emit, kein aktueller stiller No-op. `TestTemplates_RoadmapGateSafe` prüft das **Ausgabe-Property** (`](../done/` im emittierten `in-progress/roadmap.md` absent), nicht das Implementierungsdetail; Mutation 29 belegt Zähne. (Zukunfts-Drift → F-1.)
- **Fixture-Treue / Verdrahtung:** `courseSet()`-Roadmap trägt den realen broken Link; `TestTemplates_RoadmapGateSafe` ruft über `emit.Templates` echt `planTemplates→NeutralizeRoadmap`. `courseset-fixture.bats` Key-Abgleich (Pfad-Bestand, `awk` auf `courseSet()`-Rumpf) bleibt korrekt; die „15 in-scope"-Zahl (8 Singletons + 2 Indexe + 5 wiederkehrende) unverändert. Kein Befund.
- **`.gitkeep`-/Verzeichnis-Link-Kopplung:** `structureGitkeeps()` hält `docs/plan/adr` (Ziel des AGENTS.md/harness-Verzeichnis-Links) am Leben; Kopplung im Code kommentiert; `TestTemplates_Layout` + `EmittierterBestandVollstaendig` + Mutation 28 (`expect: TestTemplates_EmittierterBestandVollstaendig`) decken das Fehlen. `in-progress/` bewusst ausgelassen (trägt `roadmap.md`). Kein still-grün-Pfad im go-Test; der reale Link-Bruch fiele zusätzlich im Smoke-docs-check auf. Kein Befund.
- **Mutationen 26–29 (Kompilat + Zusage + `expect`):** 26 (isRecurring→Singleton-Durchfall→`slice.md`), 27 (isDerivativeIndex→`adr/README.md`), 28 (gitkeep-Dir entfällt), 29 (NeutralizeRoadmap-Aufruf entfällt) sind reine String-/Zeilen-Mutationen, die weiter kompilieren (kein Build-Rot statt Wächter-Rot, Bedingung 4). Jede mutiert die Zusage, nicht ein Nachbardetail; jedes `# expect:` benennt einen Test, der unter der Mutation real fällt und dessen Name in der `--- FAIL:`-Zeile steht. Mutation 08 (`# verify: smoke`) trifft die neue Meldung „Artefakt emittiert, das nicht darf (0.8.0)" (`sed`-Ziel `case !strings.HasSuffix…` existiert weiter). Kein Befund.
- **inScope vs. planTemplates:** Indexe/wiederkehrende werden in `planTemplates` übersprungen, **nicht** in `inScope` — die courseset-„15 in-scope"-Zahl bleibt konsistent (Plan §3/Kommentar decken das). Kein Befund.
- **Hard Rule 3.4 (immutable Baseline):** `git diff --name-only f310d2d HEAD` berührt `.harness/baseline/` **nicht** — alles emit-seitig. Kein Befund.
- **§6-Design-Entscheidung (b):** Option (b) emit-seitige Neutralisierung gewählt; im Code begründet (SSoT-Option a wegen immutabler vendored Baseline / AGENTS 3.4 blockiert) und mit Plan §6 + ADR-0005 (Fetch-SSoT, Fülle-wenn-Inhalt-da, referenziert-statt-co-located) konsistent. Kein Befund.
- **Inbound-Link-Prüfung (Plan §6):** Kein emittiertes Singleton verlinkt (Markdown-Link) auf eine nun nicht-emittierte co-located Vorlage oder einen derivativen Index; der einzige Treffer (`harness/conventions.template.md:89` nennt `spec/lastenheft.template.md`) ist **Prosa, kein `](…)`-Link** und pre-existing → kein neuer docs-check-Befund. Kein Befund.
- **Vorherige Findings am gleichen Modul:** slice-022b F-3 (falsche `make smoke`-Zuschreibung im Test-Kommentar) — der ersetzte `TestTemplates_RecurringNichtEmittiert` trägt die korrigierte Zuschreibung, nicht reintroduced. slice-026 F-2/F-5 (inerte Quell-Namen-Gegenprobe / unbewachter smoke-Wächter) — Smoke prüft jetzt Ziel-Namen (`README.md.md`) + Exit-Code; nicht reintroduced. slice-022b F-1 (Test behauptet Eigenschaft, prüft Implementierung) — die neuen Tests prüfen Ausgabe-Properties. Kein Befund.
- **LH-QA-01 (keine halluzinierten Gates):** Smoke Schritt 4 wertet jetzt den docs-check-**Exit-Code** aus (`dc_rc`), nicht nur „lief durch" — „0 Befunde out-of-the-box" ist als Exit-Aussage kodiert, kein still-grün. Kein Befund.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

---

## Verdikt

**KONFORM — kein blockierendes Finding.** Kein HIGH/MEDIUM. Ein LOW (F-1): der
`NeutralizeRoadmap`-Kommentar schreibt die Drift-Erkennung einem go-Test zu, der
sie fixturebedingt nicht leistet — die reale Absicherung trägt allein `make smoke`
(Tier-2). Aktuell kein Silent-Green (Fixture- und Const-Form byte-gleich zum realen
Template); die Beobachtung betrifft die Kommentar-Genauigkeit und die Zukunfts-Drift,
nicht die ausgelieferte Wächter-Wirkung. Kein Blocker.

*Nicht Teil dieses Reviews (Verifier-Rolle):* DoD-Abhakung, tatsächlicher
`make gates`/`make mutate`/`make smoke`-Grün-Lauf.
