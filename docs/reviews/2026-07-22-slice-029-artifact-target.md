# Review — slice-029: Binary-Extraktion in `make artifact` konsolidieren

**Rolle:** Unabhängiger Reviewer (Modul 10, frischer Kontext, kein Selbst-Review).
**Skill:** `.harness/skills/reviewer.md` v1.2.0 (Baseline v3.5.0).
**Datum:** 2026-07-22.

## Kopf — Pflicht-Eingangs-Kontext (die 5 v3.5.0-Punkte + Slice-Plan)

1. **Diff/Range:** `09d4bab..HEAD` — 3 Commits (`7773549` plan-schneiden, `c678907`
   reiner Move nach `in-progress/`, `96f4b17` Feature).
2. **Anforderungen:** `spec/lastenheft.md` — LH-QA-03 (minimale Abhängigkeiten),
   LH-QA-01 (keine halluzinierten Gates), LH-QA-02 (Reproduzierbarkeit).
3. **Aktive ADR:** `docs/plan/adr/0003-go-native-binaries.md` (native Binaries,
   Option C; eigenes OCI-Image als Vertriebsmittel explizit verworfen).
4. **Hard Rules:** `AGENTS.md` §3 (3.1 keine halluzinierten Gates; 3.6 keine
   Zusage ohne rot gesehenes Gegenbeispiel).
5. **Vorherige Findings:** `docs/reviews/2026-07-22-slice-024-voll-smoke.md` **F-2**
   (Bootstrap-Duplikation `smoke.sh` ↔ `full-smoke.sh`) — der Slice soll ihn auflösen.
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-029-artifact-target.md`
   (§2 DoD, §3 Plan, §6 Risiken).

**Kern-Dateien:** `Makefile` (neues `artifact`-Target), `Dockerfile` (`artifact`-
Scratch-Stage entfernt), `harness/tools/smoke.sh` + `harness/tools/full-smoke.sh`
(Extraktion → `make artifact`). Empirisch gefahren (billig, Docker-only): `make artifact`.

---

## Findings

### F-1 · LOW · Maintainability (hart verdrahteter Wert) · `Makefile:50` ↔ `Makefile:59`

**Befund:** Der Image-Tag `ai-harness-init:build` ist als Literal an **zwei** Stellen
verdrahtet: `build` taggt ihn (`-t ai-harness-init:build`), `artifact` verbraucht ihn
(`docker create ai-harness-init:build true`) — ohne gemeinsame Variable und ohne
koppelndes Gate. Ändert jemand den Tag im `build`-Target und vergisst `artifact`,
zielt `docker create` auf einen dann nicht mehr existierenden Tag.
**Failure-Szenario:** Tag-Rename nur in `build` → `make artifact` scheitert am
`docker create` (fail-loud, nicht still), die Smokes werden rot. Nuisance, kein
Silent-Green. Anmerkung: die Kopplung folgt der bestehenden Datei-Konvention
(`test`/`lint`/`build` hart-verdrahten `ai-harness-init:<stage>` je einzeln),
ist also kein *neuer* Stil-Bruch. **verifizierbar:** ja — ein Tag-Rename nur in
`build`; `make artifact` bricht am `docker create`.

### F-2 · INFO · Maintainability · `Makefile:57–58`

**Befund:** Der `DEST`-Guard (`@test -n "$(DEST)" || … exit 2`) ist die **erste
Recipe-Zeile**, läuft aber **nach** dem `build`-Prereq. Ein `make artifact` ohne
`DEST` fährt damit den vollen `build` (empirisch: die `docker build`-Stage lief,
cached-instant, bevor der Guard mit Exit 2 abbrach), statt fail-fast. In den Smokes
ist `DEST` immer gesetzt → real nie getroffen; reine Design-Notiz.
**Failure-Szenario:** Entwickler tippt `make artifact` ohne `DEST` → wartet einen
(ggf. uncached) Build ab, bevor der Guard greift. Verschwendung, kein Defekt.
**verifizierbar:** ja — `make artifact DEST=` fährt den `build`-Prereq vor dem
Guard-Exit 2 (beobachtet).

---

## Negativbefunde (geprüft, ohne blockierenden Befund)

- **F-2 (slice-024) aufgelöst — Kern-Auftrag:** Die byte-nahe Bootstrap-Extraktions-
  Duplikation ist weg. Beide Smokes rufen jetzt dieselbe eine Stelle
  `make artifact DEST="$tmpbin" GO_VERSION="$GO_VERSION"` (`smoke.sh:37`,
  `full-smoke.sh:30`). Der alte `docker build --target artifact --output …`-Block ist
  in beiden ersetzt. **Geprüft, ohne Befund.**
- **Korrektheit des `artifact`-Targets (empirisch):** `make artifact DEST=<tmp>` →
  Exit 0, liefert ein valides `statically linked ELF x86-64`-Binary unter
  `$DEST/ai-harness-init` (byte-Größe ~6,3 MB, ausführbar). Der Pfad ist konsistent
  mit dem, den die Smokes danach exec'en (`"$tmpbin/ai-harness-init"`) — kein
  Pfad-Drift ggü. dem alten `--output type=local`. **Geprüft, ohne Befund.**
- **`trap … EXIT`-Cleanup (empirisch):** `docker create`/`trap`/`docker cp` stehen
  per `\`-Continuation in **einer** Recipe-Zeile → **eine** Shell; der Trap feuert
  in derselben Shell. Nach erfolgreichem Lauf **und** nach erzwungenem `docker cp`-
  Fehler (`DEST=/nonexistent/deep/path`) blieb **kein** Wegwerf-Container zurück
  (`docker ps -a --filter ancestor=ai-harness-init:build` leer). **Geprüft, ohne Befund.**
- **Exit-Status-Propagation (empirisch, §3.6-relevant):** `docker cp`-Fehler
  propagiert als Target-Fehler (`make: *** [Makefile:59] Fehler 1`, Prozess-Exit ≠ 0);
  der EXIT-Trap (`docker rm … ; kein explizites exit`) überschreibt `$?` nicht. Damit
  bricht `set -euo pipefail` in beiden Smokes bei defekter Extraktion ab.
  **Geprüft, ohne Befund.**
- **`DEST`-Guard greift (empirisch):** `make artifact DEST=` → Exit 2 mit
  Pflicht-Meldung. **Geprüft, ohne Befund.**
- **Silent-Green / §3.6 — DoD „die Smokes SIND der Wächter":** Ein Exit-0-`make artifact`
  mit kaputtem/leerem Binary ist von den Smokes gefangen: der jeweils nächste Schritt
  exec't das Binary (`smoke.sh:40`, `full-smoke.sh:33`) unter `set -euo pipefail` →
  rot. Ein leeres Binary entsteht ohnehin nicht: ein Compile-Fehler bräche schon den
  `build`-Prereq (`RUN go build`). Die DoD-Zusage hält; **kein eigener Wächter nötig**
  (§3.6 sauber begründet). **Geprüft, ohne Befund.**
- **Dockerfile-Stage-Entfernung — kein toter Referent:** Repo-weiter Grep
  (`Makefile`, `Dockerfile`, `internal/`, `.github/`, `test/`) findet **keinen**
  `--target artifact`/`AS artifact`-Referenten mehr. Die verbliebenen Root-`--target`-
  Aufrufe (`test`/`lint`/`build`/`compile`) haben je eine gleichnamige `AS <stage>`;
  `artifact` fährt `docker create` statt `--target` → kein halluziniertes Gate
  (LH-QA-01/§3.1). **Geprüft, ohne Befund.**
- **`internal/gen`-Kopplungstest unberührt:** `TestGenerate_MakefileTargetsMatchStages`
  (`gen_test.go:63`) prüft das **generierte Skelett** (`genGo(t)`), dessen Makefile
  kein `artifact`-Target und dessen Dockerfile Stages `deps/test/lint/build` führt —
  die Entfernung der Root-`artifact`-Stage berührt es nicht. Ebenso liest
  `TestGoProfile_PinsMatchRepo` das Root-Dockerfile nur für ARG-Pins, nicht für Stages.
  Die Mutation `test/mutations/15-gen-stage-target-kopplung.sh` zielt auf die
  Skelett-Kopplung, nicht die Root-`artifact`-Stage. **Geprüft, ohne Befund.**
- **ADR-0003-Konformität:** Die Extraktion bleibt nativ — `docker cp` aus der
  `build`-Stage auf den Host, **kein** OCI-Image als Vertriebsmittel; die tote
  scratch-`artifact`-Stage ist entfernt. Konsistent mit Option C (native Binaries).
  **Geprüft, ohne Befund.**
- **GO_VERSION-Durchreichung:** `make artifact DEST=… GO_VERSION="$GO_VERSION"` — das
  Kommandozeilen-`GO_VERSION` überschreibt global und erreicht den `build`-Prereq
  (`docker build --build-arg GO_VERSION=$(GO_VERSION)`), also dieselbe Version, die die
  Smokes setzen. **Geprüft, ohne Befund.**
- **Shared-Tag `ai-harness-init:build`:** `make artifact` mutiert den Tag wie `make build`
  (und `make gates`) schon heute — **kein neues** Shared-State. Deterministische Quelle,
  Copy folgt unmittelbar dem Build. Plan §6 benennt es. **Geprüft, ohne Befund.**
- **`docker create … true`-Robustheit:** golang-Basis (Debian, coreutils) bringt `true`;
  `docker create` speichert das Command nur (führt es nicht aus), `docker cp` arbeitet
  auf dem gestoppten Container. Empirisch fehlerfrei. Plan §6 benennt die Basis-Wechsel-
  Abhängigkeit. **Geprüft, ohne Befund.**
- **Plan-Treue:** Diff == §3-Plan-Tabelle (Makefile-Target + `.PHONY`, Dockerfile-Stage
  raus, beide Smokes umgestellt). Nichts Ungeplantes; `git mv` als eigener Commit
  (`c678907`, AGENTS §3.3). **Geprüft, ohne Befund.**

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 0 | — |
| LOW | 1 | F-1 |
| INFO | 1 | F-2 |

---

## Verdikt

**Kein Blocker.** Keine HIGH/MEDIUM-Findings. Das `artifact`-Target ist korrekt und
robust (Extraktion, Trap-Cleanup, Guard und Exit-Propagation empirisch bestätigt), die
`artifact`-Stage restlos entfernt ohne toten Referenten, die slice-024-F-2-Duplikation
aufgelöst, ADR-0003 gewahrt und die §3.6-Wächter-Zusage („die Smokes fangen eine defekte
Extraktion rot") trägt. Verbleibend zwei nicht-blockierende Maintainability-Notizen
(F-1 doppeltes Tag-Literal, F-2 Guard nach `build`-Prereq). Freigabe.
