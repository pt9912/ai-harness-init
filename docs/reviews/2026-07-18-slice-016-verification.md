# Verifikation slice-016 — d-check-Pin-Sprung v0.10.0 → v0.46.0 + `codepaths`-Ventile

**Rolle:** Verifier (Modul 11, Verification Harness) — unabhängig, frischer Kontext,
NICHT Implementer, NICHT Reviewer.
**Datum:** 2026-07-18.
**Eingabe:** DoD + Spec + Plan (Modul 11) — `docs/plan/planning/open/slice-016-dcheck-pin-sprung.md`
§2/§3/§7; `spec/lastenheft.md` `LH-QA-01`/`LH-QA-02`; realer uncommitteter Working-Tree.
**Frage:** „Hat das Gebaute umgesetzt, was Plan/DoD/Spec verlangt?" (nicht „ist es gut?" = Review).
**Mittel:** ausgeführte Gates/Docker/git — jede Zeile mit Beleg-Befehl. Der Verifier committet/
verschiebt nichts.

---

## DoD-Punkt für DoD-Punkt (§2, 7 Punkte — alle als `[x]` behauptet)

### DoD-1 — `D_CHECK_IMAGE` auf v0.46.0-Digest gepinnt; §Baseline nachgezogen — **CONFIRMED**
- `harness.mk:3` = `ghcr.io/pt9912/d-check@sha256:9c317bf116a614a00f417871da4ca6057bdbabf0ca53af24c6d8e8b776de36a1`.
- **Digest-Bindung doppelt belegt:** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.46.0`
  → `Digest: sha256:9c317bf116a614a00f417871da4ca6057bdbabf0ca53af24c6d8e8b776de36a1` —
  der Tag v0.46.0 löst auf **exakt** den in `harness.mk` gepinnten Digest auf ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- §Baseline: `harness/conventions.md:14` = „**d-check:** Image v0.46.0 (Digest in harness.mk)"
  (`grep -n "d-check: Image" harness/conventions.md`).
- Kein Rest-`v0.10.0` in lebenden Quellen ausser den zwei **historischen** Nennungen im MR-009-
  Eintrag selbst (Beschreibung des Sprungs *von* v0.10.0), belegt via
  `grep -rn "v0\.10\.0" --include=*.md --include=*.mk . | grep -v .harness/baseline | grep -v docs/reviews | grep -v docs/plan/planning`.
  Insbesondere `README.md` ist auf v0.46.0 nachgezogen (Review-Befund F-1 behoben).

### DoD-2 — Trockenlauf v0.46.0 gegen unveränderten Baum, 0 Befund-Differenz — **CONFIRMED (reproduziert)**
- Non-destruktive Reproduktion: `git archive HEAD | tar -x` (committeter Prä-Änderungs-Baum:
  **alte** `.d-check.yml` ohne `exempt-paths`/`ignore-refs`, die 16 Marker noch vorhanden),
  dann `docker run --rm -v <export>:/repo:ro <v0.46.0-digest>`.
- Ergebnis: **`d-check: 40 Datei(en) geprüft, 0 Befund(e)`, Exit 0** — deckt sich exakt mit der
  Closure-Behauptung (40 Dateien / 0 Befunde). Der 29-Minor-Sprung bricht das Schema nicht;
  die explizite `modules:`-Liste immunisiert gegen neu default-aktive Module.
- `--print-config` des v0.46.0-Image listet `codepaths.exempt-paths` und `codepaths.ignore-refs`
  als autoritative Schema-Keys (`ignore-refs` dokumentiert als „Tombstones entfernter Artefakte") —
  keine geratenen Keys.

### DoD-3 — `exempt-paths: ["docs/reviews/**"]` gesetzt; Marker entfernt; docs-check ohne sie grün — **CONFIRMED**
- `.d-check.yml:48` = `exempt-paths: ["docs/reviews/**"]` (`Read .d-check.yml`).
- **16 Marker entfernt:** `git diff docs/reviews/ | grep -c "^-.*d-check:ignore"` → **16**
  (verteilt: slice-010/011/012/013/014 je 1, slices-011-014-plan-review 11). Deckt sich mit
  der Closure-Zahl „16".
- Keine aktiven Marker mehr in `docs/reviews/**`: die 4 verbleibenden `d-check:ignore`-Treffer
  stehen ausschliesslich als **Prosa-Erwähnung** in der neuen `2026-07-18-slice-016-impl-review.md`
  (Review-Report beschreibt die Tilgung), kein funktionaler Marker.
- **Grün OHNE die Marker belegt:** die DoD-2-Reproduktion (alte Config **mit** Markern → 0 Befunde)
  zeigt, dass die Marker die Exemption trugen; `make gates` auf dem neuen Baum (Config **mit**
  `exempt-paths`, Marker **entfernt**) gibt „42 Datei(en) geprüft, 0 Befund(e)" — die Exemption
  ist auf `exempt-paths` übergegangen, docs-check bleibt grün ohne die Marker.

### DoD-4 — `ignore-refs` = die in slice-013 gelöschten Templates; MR-008-Geltungsbereich deckt sie — **CONFIRMED**
- `git log --diff-filter=D --name-only -- '*.template.md'` → Commit `1b2428d` (slice-013) löschte
  **genau fünf**: `docs/plan/adr/NNNN-titel.template.md`, `docs/plan/carveouts/carveout.template.md`,
  `docs/plan/planning/slice.template.md`, `docs/plan/planning/welle.template.md`,
  `docs/reviews/review-report.template.md`.
- `.d-check.yml:52-57` `ignore-refs` listet **exakt** diese fünf — kein sechster, keine breite Liste.
  Die separat (Commit `1d360e1`) gelöschte `roadmap.template.md` ist korrekt **nicht** enthalten
  (nicht slice-013-Scope).
- MR-008-Geltungsbereich (`harness/conventions.md` MR-008) auf genau diese fünf vollen Pfade
  gezogen und verweist auf MR-009 als referenz-weite Deklaration — deckt die `ignore-refs` sauber.

### DoD-5 — `make gates` grün — **CONFIRMED**
- `make gates` → **Exit 0**. Teilläufe: `baseline-verify: v3.1.0 OK — 42 Dateien`;
  `d-check: 42 Datei(en) geprüft, 0 Befund(e)` (v0.46.0-Digest); `1..47 … ok 47` (bats);
  shellcheck ohne Befund. (42 statt der Closure-40, weil seither die zwei untrackten Dateien
  slice-017 + slice-016-impl-review hinzukamen — 0 Befunde unverändert.)
- Nuance: Lauf auf dem Working Tree, nicht auf frischem Klon — vom Slice §7 offen als
  MR-003-Restlücke (CI-Sache nach Commit) deklariert; deterministische Config/Doku auf grünem Repo.

### DoD-6 — Neuer Adaptions-Eintrag MR-009 in `harness/conventions.md`; Anker löst auf — **CONFIRMED**
- `harness/conventions.md:343` = `### MR-009 — d-check-Pin-Sprung und Codepath-Ventile`, voller
  Eintrag (Geltungsbereich, Adaption, belegter Bedarf, Trockenlauf, kein-stilles-Grün, Auflösungs-
  Trigger), ergänzt MR-001.
- **Anker maschinell bestätigt:** `harness/conventions.md:293` verlinkt
  `[MR-009](#mr-009--d-check-pin-sprung-und-codepath-ventile)`; `make gates` (d-check `anchors`-Modul)
  meldet 0 Befunde — ein toter Anker würde flaggen. Anker löst auf.

### DoD-7 — Closure-Notiz mit echtem Steering-Loop-Lerneintrag — **CONFIRMED**
- §7 enthält fünf **substantielle**, spezifische Einträge (keine Floskel): (1) neue opt-in-Module
  benannt-nicht-aktiviert (`planning`/`commits`/`tracked`/`targets`, `LH-QA-01`-konform); (2) geschärfte
  Praxis (künftige Lifecycle-Wanderungen ohne Marker); (3) offene Lücke MR-007 (Release-Listen-Sensor)
  unberührt; (4) wiederkehrende Klasse Review-F-1 mit konkreter Lehre („grep alle Vorkommen der
  Alt-Version") + Behebung README; (5) Lifecycle-Disziplin-Lücke (open→done ohne in-progress) mit
  Wurzel-Analyse + Fix am `implement-slice`-Command. Erfüllt die Modul-5-„→done braucht Lerneintrag,
  nicht nur grüne Gates".

---

## Plan-vs-Code-Diff (Verifier-spezifisch)

**Plan-Tabelle §3 vollständig gedeckt:** `harness.mk` (update), `.d-check.yml` (update),
`docs/reviews/**` (update), `harness/conventions.md` (update) — alle vier im realen Diff präsent.

**Zusätzliche Änderungen im Diff — bewertet:**
- `README.md` (v0.10.0→v0.46.0): **nicht** in §3-Tabelle, aber direkte Konsequenz der DoD-1-
  Versions-Nachführung und als Review-Befund F-1 dokumentiert (Steering-Loop-Eintrag 4). Im Geist
  von DoD-1, load-bearing, begründet — **keine** Scope-Verletzung, wohl aber eine §3-Tabellen-Lücke
  (die Tabelle nannte nur conventions.md, nicht alle Versions-Nennungen). Notiert, nicht als
  Verletzung gewertet.
- `docs/plan/planning/in-progress/roadmap.md`: Lifecycle-Bookkeeping (slice-016 done, slice-017
  startbereit) — erwartete Closure-Buchung, im Rahmen.
- `docs/plan/planning/open/slice-016-…md`: der Slice selbst (DoD-Häkchen + Closure-Notiz) — erwartet.
- `docs/reviews/2026-07-18-slice-016-impl-review.md` (untrackt): Review-Report aus dem Modul-10-
  Handoff — erwartetes Artefakt.
- `.claude/commands/implement-slice.md` (Modul-5/8/10-Nachzug): **ausserhalb slice-016-Scope,
  separates Anliegen** (Steering-Loop-Eintrag 5 dokumentiert es als Prozess-Fix). Kein slice-016-
  DoD-Punkt — nicht als Verletzung gewertet, wie vorgegeben.
- `docs/plan/planning/open/slice-017-print-mk-fragment.md` (untrackt): **separater Folge-Slice**,
  ausserhalb slice-016-Scope. Nicht als Verletzung gewertet.

**Kein Scope-Creep innerhalb der DoD-relevanten Dateien.**

## ADR-Konformität

slice-016 behauptet, keine ADR zu berühren. **Bestätigt:** kein `docs/plan/adr/000*.md` im
`git status`/`git diff` (nur `.d-check.yml`, `harness.mk`, `harness/conventions.md`, README,
roadmap, Slice-Datei, Review-Reports, `implement-slice.md`). Der `matrix`-Sensor (spec-straten→adr
verboten) läuft in `make gates` mit 0 Befunden. Keine ADR angefasst.

---

## Verdikt

- **DoD vollständig bestätigt:** **JA** — 7/7 CONFIRMED, 0 VIOLATED. Jede Behauptung mit
  ausgeführtem Beleg bestätigt (Digest-Bindung doppelt, Trockenlauf reproduziert, Marker-Zahl 16
  belegt, ignore-refs = genau die 5 gelöschten Templates, MR-009-Anker maschinell grün, Gates Exit 0).
- **Plan-vs-Code:** Plan-Tabelle §3 gedeckt; Zusatz-Änderungen begründet (README = F-1-Fix im
  DoD-1-Geist) bzw. explizit separat (`implement-slice.md`, slice-017). Kein Scope-Creep.
- **ADR-Konformität:** keine ADR berührt (wie behauptet).
- **Slice reif für `done/`:** **JA** — DoD vollständig, Review-Report vorhanden, Closure-Notiz mit
  echtem Steering-Loop-Lerneintrag. Der `git mv open→done` bleibt dem Planner (Verifier verschiebt
  nichts). Eine dokumentierte Rest-Nuance (Gate-Lauf auf Working Tree statt Frisch-Klon) ist als
  MR-003-Restlücke/CI-Sache offen deklariert, kein Blocker.
