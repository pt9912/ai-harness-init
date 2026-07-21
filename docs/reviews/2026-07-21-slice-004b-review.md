# Review-Report: slice-004b (Sprachskelett verdrahten) — 2026-07-21

**Review-Art:** Code — Diff gegen Plan + `ADR-0005` + Hard Rules (`AGENTS.md` §3).
DoD-/Spec-Konformität ist bewusst NICHT geprüft (Verifier-Rolle, Modul 11).

**Gegenstand:** slice-004b · Commits `08a78c2` (reiner Move open→in-progress) +
`9d290cd` (Inhalt) · Diff-Range `d76ceb7..9d290cd`. Spätere Commits (`9628de9`,
`ce89ce5`) sind Planungs-/Roadmap-Arbeit und nicht Teil des Reviews.

**Skill:** `.harness/skills/reviewer.md` @ v1.2.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
**Modell:** claude-opus-4-8[1m] · **Datum:** 2026-07-21

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan: [slice-004b](../plan/planning/done/slice-004b-skeleton-wire.md)
- Aktive ADR: [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) (Herkunftsklassen/Ownership)
- Hard Rules: [AGENTS.md](../../AGENTS.md) §3 (3.1/3.2/3.3/3.5/3.6)
- Konventionen: [harness/conventions.md](../../harness/conventions.md) (`MR-010` d-check-Include)
- Betroffene IDs: `LH-FA-04`, `LH-FA-01`, `LH-QA-01`
- Vorherige Findings am gleichen Modul: keine slice-004b-Vorläufe (Erst-Review dieses Slice).

---

## Findings

### F-1 — smoke.sh-Kopf-Belegliste driftet gegen den umgeschriebenen Schritt 3

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift)
- `pfad`: `harness/tools/smoke.sh:15`
- `befund`: Der `Belege:`-Kopf beschreibt Schritt 3 weiterhin als „Skelett generiert?
  (slice-023-Generator-Beweis, `.harness/skeleton/`)", während der zugehörige
  Rumpf (Zeile 39–47) auf slice-004b umgeschrieben wurde und jetzt das Gegenteil
  prüft: Skelett am Ziel-Root (`Makefile`/`go.mod`) plus dass `.harness/skeleton/`
  nach der Verdrahtung **entfernt** ist. Der Implementer zog die beiden
  Schritt-5-Meldungen und den Schritt-3-Rumpf nach, ließ aber die Kopf-Belegliste stehen.
- `verifizierbar`: nein — Drift in einem Shell-Kommentar; kein aktives Gate (shellcheck/d-check) prüft sie.

### F-2 — wire.Place-Vorbedingung + Write-Schleife liegen in Phase 4 (nach allen Pre-Flights)

- `kategorie`: INFO
- `quelle`: `LH-FA-01` / slice-025 §6 (dokumentierte „ehrliche Grenze")
- `pfad`: `internal/wire/wire.go:74-108`, `cmd/ai-harness-init/main.go:183`
- `befund`: Der Kollisions-Vorpass (`wire.go:80-90`) hält die slice-025-Garantie
  „Kollision → kein Teil-Placement" korrekt ein (alle Ziele geprüft, bevor eines
  geschrieben wird). Zwei wire.Place-Fehlerpfade liegen jedoch NUR in Phase 4 und
  sind NICHT im Phase-3-Pre-Flight gespiegelt: die „gates-Target fehlt"-Vorbedingung
  (`wire.go:76-78`) und ein I/O-Fehler mitten in der Write-Schleife. Feuert einer,
  bleiben die zuvor emittierten Phase-4-Artefakte (`.d-check.yml`, `d-check.mk`,
  Verifier, Templates) liegen — ein Teil-Bootstrap. Das ist eine bewusste, in
  `main.go:158-161` dokumentierte Won't-Fix-Grenze (retry-freundlich statt
  Staging→Commit-Atomarität); die gates-Vorbedingung ist zudem im realen Fluss
  unerreichbar, weil der Generator (`internal/gen/golang.go:128`) stets ein
  gates-Target emittiert. Reine Designnotiz, kein Defekt.
- `verifizierbar`: nein — kein reproduzierbares Gate-Gegenbeispiel im realen Fluss.

## Negativbefunde

- geprüft, ohne Befund: **Hard Rule 3.3** — `08a78c2` ist ein reiner Rename
  (`R100`, similarity 100 %, 0 Inhaltsänderung), getrennt vom Inhalts-Commit `9d290cd`.
- geprüft, ohne Befund: **ADR-0005 Ownership** — `wire` fasst ausschließlich die
  gestagten Skelett-Dateien an (Generator besitzt `Makefile`/`Dockerfile`/`go.mod`);
  `AGENTS.md` wird nicht generiert (der Generator emittiert nur `go.mod`/`Dockerfile`/
  `Makefile`/`.golangci.yml`/`cmd/app/main.go`; `emit` legt `AGENTS.template.md` ab,
  nicht authored `AGENTS.md`). Keine halluzinierte Autorschaft (`LH-QA-01`).
- geprüft, ohne Befund: **slice-025-Garantie** — die Skelett-Root-Ziele hängen über
  `wire.Targets` im Phase-3-Pre-Flight (`main.go:220-227`), die Platzierung liegt in
  Phase 4 nach allen Pre-Flights (`main.go:183`); der Kollisions-Vorpass in `wire.Place`
  deckt geschachtelte Dateien (`cmd/app/main.go`) mit ab; der force-Pfad prüft die
  gates-Vorbedingung VOR jedem Write.
- geprüft, ohne Befund: **Makefile-Verdrahtung** — das angehängte `gates: docs-check`
  ist recipe-los und der generierte `gates: lint build test` (golang.go:128) ebenfalls,
  darum kombiniert Make die Prerequisites legal (kein Recipe-Konflikt). Die
  gates-Wache (`bytes.HasPrefix`/`bytes.Contains("\ngates:")`) trifft ein gates-Target
  am Dateianfang wie mittig und ignoriert die `.PHONY: gates`-Zeile. Idempotent:
  das Staging wird je Lauf frisch generiert und nach Placement entfernt, darum kein
  akkumulierendes Doppel-Include. Der volle `make gates`-E2E ist per DoD ausdrücklich
  auf slice-024 vertagt; smoke Schritt 5 belegt den Include strukturell und fährt
  `make lint build test` (nicht `make gates`) — plan-konform.
- geprüft, ohne Befund: **Hard Rule 3.6** — die drei Mutationen sind vom
  glob-basierten `mutate.sh` auto-entdeckt; jede trägt gültige `# files:`/`# expect:`-
  Köpfe, mutiert eine reale Zeile, kompiliert und färbt den benannten Test rot:
  `21` bricht `include d-check.mk` → `TestPlace_PlacesAndWires`; `22` deaktiviert die
  gates-Vorbedingung → `TestPlace_NoGatesTarget`; `23` streicht die Skelett-Ziele aus
  dem Phase-3-Pre-Flight → `TestRun_SkeletonKollisionSchreibtKeinEmit` (rot über die
  fehlende „Makefile existiert bereits"-Meldung, nicht über den Exit-Code).
- geprüft, ohne Befund: **Hard Rules 3.1/3.2/3.5** — keine halluzinierten Gates
  (nur lauffähige Targets verdrahtet), keine Lint-Suppression in `wire.go`, keine
  Gate-Lockerung ohne ADR (smoke ist Nicht-Gate-Verify; die Umstellung auf
  `lint build test` spiegelt die neue Realität, senkt keine Schwelle).
- geprüft, ohne Befund: **Fehlerbehandlung wire.go** — `os.RemoveAll(stagingDir)`
  läuft NACH allen Writes (bei Fehler bleibt das Staging retry-freundlich erhalten);
  die Rel-Pfade stammen aus `filepath.WalkDir` über den tool-generierten Staging-Baum
  (keine `..`-Traversierung aus Nutzer-Eingabe).
- geprüft, ohne Befund: **Plan-Scope** — der Diff deckt die §3-Plan-Tabelle
  (`cmd` update, `internal/` update via neuem `internal/wire`, Emit-Tests update) plus
  smoke/Mutationen/Lifecycle-Links; kein Scope-Creep, kein Merge (ADR-0005), kein
  fehlender Plan-Punkt.
- geprüft, ohne Befund: **Lifecycle-Move-Links** — die fünf Link-Reparaturen
  (slice-004a ×2, slice-004b intern ×2, welle-02 ×1) ziehen den open→in-progress-Move
  korrekt relativ nach.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

## Verdikt

**Merge-blockierend:** nein — keine HIGH/MEDIUM. F-1 ist Doku-Drift in einem
Shell-Kommentar (nice-to-fix), F-2 eine bewusste, bereits dokumentierte
Designgrenze. Der Diff ist **konform** zu Plan, `ADR-0005` (Ownership: kein Merge,
keine `AGENTS.md`-Generierung) und den Hard Rules (3.3-Move verifiziert, 3.6-Mutationen
färben real rot). Die slice-025-Garantie „Kollision → kein Teil-Bootstrap" hält für
die verdrahteten Skelett-Dateien.

**Übergabe:** Findings gehen an die Implementation. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
