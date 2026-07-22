# Review — slice-024 Voll-E2E-Smoke des Bootstraps

**Rolle:** Unabhängiger Reviewer (Modul 10, frischer Kontext — Code nicht selbst geschrieben).
**Datum:** 2026-07-22.
**Reviewer-Skill:** `.harness/skills/reviewer.md` v1.2.0 (Baseline v3.5.0).

## Kopf-Metadaten (Pflicht-Eingangs-Kontext)

1. **Diff/Commit-Range:** `4a4221a..HEAD` (3 Commits: `b62354d` Move, `620a09f` Move-Churn, `f4922de` Feature).
2. **Anforderungen:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Repo bootstrappen, Happy-Path), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (keine halluzinierten Gates).
3. **Aktive ADRs:** [`ADR-0005`](../plan/adr/0005-ziel-repo-distribution.md) (Ziel-Repo-Distribution).
4. **Hard Rules:** `AGENTS.md` §3 (insb. 3.1 keine halluzinierten Gates, 3.6 keine Zusage ohne rot gesehenes Gegenbeispiel).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/` — slice-026 F-1/F-2/F-5 (inerte Prüfung des QUELL-Namens statt des WIRKLICH geschriebenen; „Sensor ohne Trigger"); slice-028 (Emit gate-sicher).
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-024-voll-smoke.md` §2/§3/§6.

**Kern-Dateien:** `harness/tools/full-smoke.sh` (neu, 61 Z.), `Makefile` (`full-smoke`-Target), `AGENTS.md` §4 + `harness/README.md` §Nicht-Gate-Verify, `.github/workflows/ci.yml` (`full-smoke`-Job). Verifikations-Kontext (gelesen, nicht im Diff): `internal/gen/golang.go`, `internal/wire/wire.go`, `d-check.mk`, `harness/tools/smoke.sh`.

---

## Findings

### F-1 · LOW · Maintainability / LH-QA-01-Sensor-Anker · `harness/tools/full-smoke.sh:53`

**Befund:** `full-smoke.sh` verlangt als Doc-Gate-lief-Marker den Substring `Befund`
(`grep -qF -- "Befund"`, Pflicht — fehlt er, Exit 1). Der bewährte Geschwister-Sensor
`smoke.sh` gegen dasselbe Tool verlangt statt dessen `geprüft` (Zeile 92, harte
Pflicht: „d-check lief nicht") und behandelt `Befund` nur als optionale Anzeige
(Zeile 97, `grep -E "geprüft|Befund" || true`). Damit ist der einzige d-check-
Runtime-Marker, dessen Anwesenheit auf dem 0-Befunde-Happy-Path durch *bewährten,
grün gelaufenen* Code belegt ist, `geprüft` — nicht `Befund`. `full-smoke` hängt an
dem *nicht* belegten Marker. **Failure-Szenario:** Druckt der (digest-gepinnte)
d-check v0.51.1 auf 0 Befunde eine Summenzeile ohne den Substring `Befund` (z. B.
„N Dateien geprüft" allein, `Befund(e)`-Zeilen nur bei Count > 0), meldet
`full-smoke` FEHLER über einem *wirklich grünen* frisch gebootstrappten Repo — genau
dem LH-FA-01-Happy-Path, den der Sensor beweisen soll. Richtung ist fail-safe (nie
falsch-grün, nur falsch-rot). **verifizierbar:** ja — ein realer `make full-smoke`
über grünem Bootstrap; enthält die 0-Befunde-Ausgabe den Substring `Befund` nicht,
eskaliert dieses Finding. Gegen-Evidenz aus Closure-Notizen („9 Dateien, 0 Befunde",
slice-028): der Marker erscheint dort vermutlich — die reale Verify-Ausgabe entscheidet.

### F-2 · LOW · Maintainability (Ketten-Duplikat) · `harness/tools/full-smoke.sh:20-34`

**Befund:** Der Bootstrap-Vorspann (mktemp `tmpbin`/`tmprepo`, `chmod 755` mit
identischem 0700-Traversal-Kommentar, `trap cleanup EXIT`, `docker build --target
artifact --output`, `ai-harness-init --lang go --name …`) ist ~15 Zeilen und liegt
byte-nah dupliziert in `smoke.sh:27-41`. **Failure-Szenario:** Ändert sich der
Bootstrap-Vertrag (z. B. ein neues Pflicht-Flag von `ai-harness-init`, ein anderer
`--output`-Mechanismus, der `GO_VERSION`-Default), muss er in beiden Sensoren
nachgezogen werden; wird einer vergessen, testet dieser Sensor still einen veralteten
Pfad. **verifizierbar:** ja — ein Bootstrap-Flag-Change, der nur in einem Sensor
nachgezogen wird, lässt den anderen über einem toten Pfad grün/rot laufen. Vertretbar
als bewusste Trennung zweier Sensoren (Schritte-einzeln vs. zusammengeführt); als
Wartungsfalle notiert, nicht blockierend.

### F-3 · INFO · Maintainability · `harness/tools/full-smoke.sh:20`

**Befund:** `GO_VERSION="${GO_VERSION:-1.26.4}"` verdrahtet den Toolchain-Pin als
Fallback hart (ebenso `smoke.sh:27`). Das Makefile reicht `$(GO_VERSION)` durch, der
Default greift nur bei Direktaufruf ohne Env — latent beim nächsten Toolchain-Bump,
kein aktueller Defekt. **verifizierbar:** nein (Design-Notiz).

---

## Negativbefunde (geprüft, ohne Befund)

- **Silent-Green / §3.6 (Kern-Achse):** `full-smoke.sh:37-43` prüft `gates_rc` VOR den
  Markern — ein nicht-0-Exit fällt zuerst auf. Die Marker sind Zweitverteidigung, kein
  Ersatz für den Exit. Kein Pfad, auf dem alle vier Marker erscheinen und `make gates`
  dennoch nicht grün war. Kein stilles Teilmengen-Gate: die Marker sind
  Laufzeit-emittiert (Recipe-Echo bzw. d-check-stdout), nicht durch inertes
  Quell-Namen-Echo erfüllbar (kein slice-026-F-2-Rückfall). **geprüft, ohne Befund.**
- **Marker `--target lint`/`--target build`/`--target test` — Robustheit:** Das
  generierte Skelett-Makefile (`internal/gen/golang.go:119-128`) macht die Recipes
  NICHT `@`-silenced; `lint`/`build`/`test` sind `.PHONY` (Zeile 114) → Make echot
  bei jedem Lauf `docker build … --target <stage> …`. Unter `gates: lint build test`
  laufen alle drei → alle drei Marker erscheinen zuverlässig im `make gates`-Output.
  **geprüft, ohne Befund.**
- **Marker `Befund` — Echtheit (Achse b):** Das `docs-check`-Recipe ist
  `docker run … $(DCHECK_REF)` (`d-check.mk:29`) — kein Literal `Befund` im
  Recipe-Text; die `## …(Befund-Gate…)`-Hilfe steht auf der Target-Deklarationszeile,
  die Make bei der Ausführung NICHT echot. `Befund` kann nur aus der d-check-
  Laufzeit-Ausgabe stammen → echter „docs-check-lief"-Marker, nicht inert. (Der
  Zuverlässigkeits-Vorbehalt ist F-1.) **geprüft, ohne Befund.**
- **Marker `--target build` — Spezifität:** Kein Falsch-Match, wenn nur test/lint
  liefen: unter `gates` läuft `build` immer mit, und `--target build` erscheint nur
  aus dem build-Recipe-Echo (die lint/test-BuildKit-Ausgaben drucken es nicht).
  **geprüft, ohne Befund.**
- **MR-010-Verdrahtung + rot-färbende Mutation (Achse c):** `wire.go:31-32` hängt
  `include d-check.mk` + `gates: docs-check` an; bricht man diesen Anhang, läuft
  docs-check nicht mit → `Befund` fehlt → `full-smoke` rot. Die Mutation trifft die
  LH-QA-01-Zusage („docs-check läuft wirklich als Teil von gates"), nicht ein
  Nachbar-Detail. Die Verdrahtung selbst ist permanent durch `wire_test.go` gedeckt;
  der Verzicht auf einen zusätzlichen permanenten Mutationsfall ist begründet.
  **geprüft, ohne Befund** (Rot-gesehen-Beleg selbst prüft die Verifikation, nicht ich).
- **Halluziniertes Gate (LH-QA-01, §3.1):** `full-smoke` ist NICHT in den
  `make gates`-Prereqs (`Makefile:131`); ehrlich als Nicht-Gate-Verify in `AGENTS.md`
  §4 und `harness/README.md` §Nicht-Gate-Verify geführt, die nur beschreiben, was
  läuft. **geprüft, ohne Befund.**
- **ci.yml `full-smoke`-Job:** `if: github.event_name != 'schedule'`,
  `runs-on: ubuntu-24.04`, `actions/checkout` auf gepinnten SHA
  `11bd719…` — konsistent mit dem bestehenden `smoke`-Job; ruft nur `make full-smoke`
  (keine zweite Gate-Definition, MR-014-Geist). Kopf-Kommentare konsistent
  nachgezogen. **geprüft, ohne Befund** (actionlint-Grün ist Verifier-Sache).
- **Plan-Abweichung `test/` → `harness/tools/` (§3):** Der shell-lint-Glob
  (`Makefile:76-77`) deckt `harness/tools/*.sh` und `test/mutations/*.sh`, aber NICHT
  top-level `test/*.sh`. Ein Skript unter `test/full-smoke.sh` wäre shell-lint-blind;
  die Ablage in `harness/tools/` ist damit korrekt begründet. **geprüft, ohne Befund.**
- **ci.yml-Job nicht in Plan §3:** Scope per expliziter Nutzer-Entscheidung
  („in slice-024 falten") erweitert; sauber, kein Finding. **geprüft, ohne Befund.**
- **Move-Churn (`620a09f`):** Alle Inbound-Links `../open/` → `../in-progress/` in
  `slice-004b`/`slice-005`/`slice-028` (done/) und `welle-03-readme-und-smoke.md`
  stimmen mit dem neuen Ablageort der Datei überein; kein gebrochener/veralteter Link
  eingeführt. **geprüft, ohne Befund.**
- **Trennung zu `make smoke`:** `full-smoke` fährt den ZUSAMMENGEFÜHRTEN `make gates`
  (Nutzer-Sicht), `smoke` die Schritte einzeln — keine Redundanz der Aussage, zwei
  getrennte Sensoren. **geprüft, ohne Befund.**

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 0 | — |
| LOW | 2 | F-1, F-2 |
| INFO | 1 | F-3 |

## Verdikt

**KONFORM (kein Blocker).** Keine HIGH/MEDIUM. Die Kern-Achse (Silent-Green / §3.6)
ist sauber: `full-smoke` prüft Exit 0 UND vier laufzeit-emittierte Marker; kein
stilles-Grün-Pfad, kein halluziniertes Gate, ehrliche Nicht-Gate-Verdrahtung. Die
beiden LOW-Findings (F-1 Marker-Anker-Divergenz zu `smoke.sh`; F-2 Bootstrap-Duplikat)
sind Wartungs-/Robustheits-Notizen und blockieren nicht. **Auflage an die Verifikation:**
F-1 wird durch die ohnehin fällige reale `make full-smoke`-Ausgabe geschlossen —
enthält die 0-Befunde-d-check-Ausgabe den Substring `Befund`, ist der Marker validiert;
fehlt er, eskaliert F-1 zum Blocker (falsch-rot auf dem LH-FA-01-Happy-Path).
