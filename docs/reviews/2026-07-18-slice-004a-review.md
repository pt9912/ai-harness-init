# Code-Review — slice-004a: Sprachskelett-Fetch

**Reviewer-Skill:** `.harness/skills/reviewer.md` v1.1.0 (Modul 10) ·
**Datum:** 2026-07-18 · **Rolle:** Reviewer (unabhängiger Kontext, Code nicht selbst geschrieben).

## Kopf-Metadaten (Eingangs-Kontext)

- **Diff/Commit:** `a364d91` — „slice-004a: Sprachskelett-Fetch (internal/fetch)".
- **Betroffene Anforderungen:** LH-FA-04 (Sprachskelett-Picker, Fetch-Teil), LH-QA-02
  (Reproduzierbarkeit/Tag-Pin), LH-QA-01 (kein halluziniertes Gate / offline-grün),
  LH-QA-03 (minimale Abhängigkeiten).
- **Referenzierte ADRs:** ADR-0001 (Skelett-Distribution, Variante C — Fetch vom
  gepinnten Kurs-Tag). ADR-0003 (Docker-only) nur als Scope-Grenze.
- **Hard Rules:** AGENTS.md §3.1–3.5.
- **Konventionen:** MR-007 (BASELINE_TAG = einzige Tag-Quelle), MR-001/MR-009 (Doc-Gate
  `scan.ignore`/Ventile), MR-010 (d-check.mk `docs-check`).
- **Slice-Plan:** `docs/plan/planning/in-progress/slice-004a-skeleton-fetch.md`.
- **Vorherige Findings am Modul (Emit/Bootstrap-Kette):** slice-002 I1 + slice-003 I1
  (Teil-Emit über die Emit-Schritte) — hier ein **drittes Mal** fortgeschrieben (siehe L3).
- **Prüfmaßstab:** Plan · ADR · Hard Rules · Repo-Konventionen. **Nicht** die DoD (Verifier).

---

## Findings

### MEDIUM

**M1 — `fetch.DefaultTag` ist eine zweite Quelle des Tag-Strings (Drift/Reproduzierbarkeit).**
- **Quelle:** LH-QA-02 · MR-007 (Setzung 4)
- **Pfad:** `internal/fetch/fetch.go:26`
- **Befund:** `const DefaultTag = "v3.1.0"` verdrahtet den Kurs-Tag als eigenes Go-Literal.
  Das Makefile deklariert `BASELINE_TAG` ausdrücklich als „die EINZIGE Quelle des
  Tag-Strings in der Mechanik" (`Makefile:21`, MR-007 Setzung 4); der Skelett-Fetch zieht
  aus demselben Kurs-Repo/Tag wie der vendored Baum, führt den Tag aber unabhängig. Bei
  der nächsten Re-Baseline (Bump von `BASELINE_TAG` — genau die Operation aus slice-011/012,
  v1.2.0→v3.1.0) folgt das Go-Literal nicht automatisch: das Skelett würde von einem
  **anderen** Tag geholt als der vendored Baseline entspricht → Reproduzierbarkeits-Mismatch
  zwischen Baseline und Skelett. Der Doc-Kommentar nennt `BASELINE_TAG` als Soll-Quelle,
  koppelt aber nicht mechanisch. Heute (beide „v3.1.0") ist das Verhalten korrekt; das Risiko
  ist latent auf den nächsten Bump.
- **verifizierbar:** ja — kein Sensor koppelt `DefaultTag` an `BASELINE_TAG`; ein Bump-Trockenlauf
  oder ein Test `DefaultTag == BASELINE_TAG` (existiert nicht) würde die Divergenz zeigen.

**M2 — main-Verdrahtung (Exit 2 / Exit 1) ist nicht unit-getestet (neuer öffentlicher Vertrag).**
- **Quelle:** Reviewer-Skill MEDIUM („fehlende Negativtests bei neuem öffentlichen Vertrag")
- **Pfad:** `cmd/ai-harness-init/main.go:88-99`
- **Befund:** `run()` verdrahtet den realen Netz-Fetcher `fetch.DownloadTarball` **fest**.
  Damit erreicht kein Unit-Test die neuen Exit-Pfade in `run()`: Unknown-Lang → Exit 2
  (`errors.As(*UnknownLangError)`) und Netz-/Extrakt-Fehler → Exit 1 sind nur netzgebunden
  erreichbar und werden laut Commit nur **manuell** belegt. `TestRun` deckt ausschließlich
  Arg-Parser-Pfade (vor DocGate), `TestRun_EmitFehler` bricht bei DocGate ab (vor dem Fetch)
  — beide sinnvoll netzlos, aber die neue Exit-Code-Zuordnung des Fetch-Schritts bleibt ohne
  Unit-Deckung. Die Fetch-**Logik** selbst (Unknown-Lang, Fetch-Fehler) ist auf Paket-Ebene
  gut getestet; die Lücke betrifft nur die 3-Zeilen-Glue in `main`.
- **verifizierbar:** ja — Coverage über `cmd/ai-harness-init`; ein Test mit injiziertem
  Fetcher in `run()` ist mit der aktuellen Signatur nicht möglich (Fetcher nicht injizierbar).

### LOW

**L1 — `skeletonEntry`-Marker ist unverankert; Nicht-Dir-Einträge verunreinigen die Sprachliste.**
- **Quelle:** Maintainability (Robustheit) · LH-FA-04 (Liste verfügbarer Skelette)
- **Pfad:** `internal/fetch/fetch.go:113` (`skeletonEntry`)
- **Befund:** `strings.Index(name, "/lab/example/")` matcht **jedes** Vorkommen, nicht das
  Top-Level-`<repo-prefix>/lab/example/`. Zwei Failure-Szenarien: (a) enthält der Tag-Tarball
  irgendwo einen **verschachtelten** Pfad `…/lab/example/<lang>/…` (z. B. ein Doku-Beispiel
  oder eine Fixture im Kurs-Repo), werden dessen Dateien still in das Staging gemerged;
  (b) eine **Datei direkt** unter `lab/example/` (etwa ein `README.md`) landet als
  `parts[0]` in der Sprachliste und erscheint im Unknown-Lang-Fehler als Pseudo-„Sprache".
  Die Fixture-Tests decken beide Kanten nicht ab (nur Sprach-Dirs + Traversal). Der
  Substring-Sprachvergleich selbst ist korrekt (`fetch.go:121`, Vergleich auf dem vollen
  Pfad-Segment mit Gleichheit — „go" matcht **nicht** „gogo").
- **verifizierbar:** ja — eine Fixture mit verschachteltem `lab/example`-Pfad bzw. einer
  blanken Datei unter `lab/example/` würde beides zeigen.

**L2 — Loses Smoke-Orakel: `|| true` + Substring `geprüft`.**
- **Quelle:** Maintainability (Messmethode) · Nicht-Gate
- **Pfad:** `harness/tools/smoke.sh` (Schritt 4/4)
- **Befund:** `out="$(… docs-check … || true)"` schluckt den Exit-Code; die Prüfung ist
  nur `grep -q "geprüft"`. Der Smoke besteht also, sobald d-check das Wort „geprüft" druckt
  — er erkennt einen **Config-Crash**, aber **keinen Inhalts-Regress** (andere/mehr kaputte
  Refs im emittierten Repo). Die Umstellung selbst ist plan-autorisiert (Slice-Plan §6:
  Voll-Green-Run = slice-005) und ehrlich (surft den slice-003-Zustand, verdeckt keinen von
  004a verursachten Regress), aber das Orakel ist schwächer als nötig.
- **verifizierbar:** ja — `make smoke` (Host-Docker/Netz, Nicht-Gate).

**L3 — Teil-Bootstrap auf dem Netz-Fehlerpfad (3. Wiederholung der Teil-Emit-Klasse → Steering-Loop-Signal).**
- **Quelle:** Slice-Plan §6 / Maintainability · Reviewer-Skill Kontext-Eskalation
- **Pfad:** `cmd/ai-harness-init/main.go:74-99`
- **Befund:** Der Fetch läuft **nach** DocGate + Templates. Der Netz-Fehler ist laut ADR-0001
  der **realistische** Bootstrap-Fehler (nicht die ENOSPC-Kante aus slice-002 I1): schlägt er
  fehl (Exit 1), sind DocGate + Templates schon geschrieben, das Skelett fehlt, und es gibt
  kein Cleanup. Ein Retry ohne `--force` scheitert dann an DocGate („existiert bereits").
  Damit erscheint die Teil-Emit-Klasse zum **dritten Mal** (slice-002 I1 → slice-003 I1 →
  hier) — nach Reviewer-Skill ein Steering-Loop-Signal (Guide/Sensor nachziehen statt jede
  Sitzung neu als INFO abzulegen).
- **verifizierbar:** ja — `run()` mit einem fehlschlagenden Fetcher nach erfolgreichem
  DocGate/Templates hinterlässt das Ziel partiell (aktuell nicht abgedeckt, siehe M2).

### INFO

**I1 — Fetch-Schritt ignoriert `--force`; Staging wird nicht geleert.**
- **Quelle:** Maintainability (bewusste Design-Notiz)
- **Pfad:** `internal/fetch/fetch.go:128-142` (`writeFile`) · `main.go:88-92`
- **Befund:** `Skeleton` schreibt stets `O_CREATE|O_TRUNC`, unabhängig von `*force`, und
  `.harness/skeleton/` wird vor dem Extrakt nicht geleert. Da das Staging tool-intern und
  d-check-exempt ist (siehe I2), ist Überschreiben-ohne-`--force` vertretbar; ein Re-Run mit
  **anderer** `--lang` ließe aber Alt-Dateien der vorigen Sprache stehen (Cross-Kontamination).
  LH-QA-02 („zwei Läufe, **gleicher** Tag/Sprache → identisch") bleibt gewahrt.

**I2 — Emittierter `.d-check.yml` nimmt `.harness/**` aus — plan-autorisiert.**
- **Quelle:** MR-001/MR-009 (`scan.ignore`) · Slice-Plan §6
- **Pfad:** `internal/emit/templates/d-check.yml:7`
- **Befund:** Der Ausschluss ist im Slice-Plan §6 ausdrücklich benannt und sachlich begründet
  (Staging ist tool-interne Ablage, keine Adopter-Doku). Kein Verstoß gegen die
  Config-Minimalität aus slice-002 (`modules: [links, anchors]` unverändert; eine additive,
  begründete `ignore`-Zeile). Der Scope `.harness/**` im **emittierten** (Adopter-)Config
  trifft dort nur das Skelett-Staging — kein Adopter erhält den vendored Baseline-Baum.

---

## Negativbefunde (geprüft, ohne Befund)

- **Symlink-/Hardlink-/Dir-Tar-Einträge:** nur `tar.TypeReg` wird extrahiert
  (`fetch.go:94`); TypeSymlink/TypeLink/TypeDir werden übersprungen — kein Symlink-Erzeugen.
- **Pfad-Traversal (`../`):** `!filepath.IsLocal(rel)` weist `../evil.txt` ab (`fetch.go:94`);
  `TestSkeleton_Extract` prüft die Abwesenheit. Der tar-Writer normalisiert den Namen nicht,
  d. h. der Test übt tatsächlich `IsLocal`.
- **Substring-Sprache:** exakter Vergleich auf dem vollen Pfad-Segment (`entryLang != lang`,
  `fetch.go:121`) — „go" matcht nicht „gogo".
- **Unknown-Lang-Liste:** = Tarball-Sprachen, `sort.Strings`-sortiert (`fetch.go:148`);
  `TestSkeleton_UnknownLang` verankert „go,python" (modulo L1-Verunreinigung).
- **Exit-Semantik:** `*UnknownLangError` (Zeiger-Empfänger, `errors.As` mit `**T`) → Exit 2;
  Netz-/Extrakt-Fehler → Exit 1 — Zeiger-Semantik korrekt (`main.go:94-98`).
- **Reihenfolge DocGate/Templates vor Fetch:** hält `TestRun_EmitFehler` netzlos (Abbruch bei
  DocGate vor dem Fetch); `TestRun`-Erfolgsfälle erreichen den Fetch nicht → kein echtes Netz
  im go-test.
- **Injizierbarkeit / Test-Ehrlichkeit:** Fetcher über `TarballFetch` injizierbar; Fixtures
  bauen den gzip-Tar in-memory; kein `t.Skip`, kein echtes Netz (`fetch_test.go`).
- **LH-QA-03 (keine neue Dep):** `fetch.go` nutzt nur stdlib (`archive/tar`, `compress/gzip`,
  `net/http`, …); `go.mod` unverändert, dependency-frei.
- **Hard Rule 3.1/3.5:** `make smoke` ist explizit **Nicht-Gate**; `make gates` unverändert,
  offline-grün; kein neuer Gate behauptet; keine Gate-Lockerung ohne ADR.
- **Hard Rule 3.2:** kein `//nolint`, kein `# shellcheck disable` (gegrept, keiner).
- **Hard Rule 3.3:** Slice-Plan-Move (`8660124`) ist ein separater Commit vor der
  Inhaltsänderung (`a364d91`); in `a364d91` kein Rename+Inhalt gebündelt (`fetch.go`/`_test.go`
  neu, übrige modifiziert).
- **Hard Rule 3.4:** ADR-0001 nicht verändert.
- **ADR-0001 „Picker, kein Generator" / Variante C:** Implementierung **pickt** und extrahiert
  `lab/example/<lang>/` verbatim aus dem codeload-Tag-Tarball (`refs/tags/<tag>`) — keine
  Generierung; konsistent mit Variante C und Slice-Plan §3 (Tag-Tarball, kein Release-Asset).

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | M1 DefaultTag zweite Tag-Quelle · M2 main-Exit-Verdrahtung untested |
| LOW | 3 | L1 unverankerter Marker/Listen-Verunreinigung · L2 loses Smoke-Orakel · L3 Teil-Bootstrap (Steering-Loop) |
| INFO | 2 | I1 Fetch ignoriert `--force`/kein Staging-Clean · I2 `.harness/**`-Ignore (plan-autorisiert) |

## Verdikt

**Merge-blockierend: JA** — getragen von M1 und M2 (Reviewer-Skill: „HIGH und MEDIUM
blockieren typischerweise"). Beide sind **keine** Fehler im heutigen Verhalten
(v3.1.0 == BASELINE_TAG; Fetch-Logik paket-getestet), sondern (M1) ein latentes
Reproduzierbarkeits-/Drift-Risiko gegen MR-007s Ein-Quellen-Setzung auf den nächsten
Re-Baseline und (M2) eine Deckungslücke der neuen CLI-Exit-Codes. Vor Merge zu klären:
`DefaultTag` an `BASELINE_TAG` koppeln (oder Kopplung per Test/Sensor absichern) und die
main-Exit-Verdrahtung netzlos testbar machen (Fetcher in `run()` injizierbar) — oder die
manuelle Belegung mit begründeter Abweichung im Report akzeptieren. L3 ist über den
Einzel-Slice hinaus ein Steering-Signal (Teil-Bootstrap-Vertrag dokumentieren/Cleanup),
kein Slice-Blocker.

Keine HIGH-Findings; keine Harness-Lüge, kein halluziniertes Gate, keine Hard-Rule-Verletzung.
