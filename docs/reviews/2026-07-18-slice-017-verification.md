# Verifikation slice-017 — d-check-Gate-Fragment aus `--print-mk` statt handgepflegter `harness.mk`

**Rolle:** Verifier (Modul 11, Verification Harness) — unabhängig, frischer Kontext,
NICHT Implementer, NICHT Reviewer.
**Datum:** 2026-07-18.
**Eingabe:** DoD + Spec + Plan (Modul 11) —
`docs/plan/planning/in-progress/slice-017-print-mk-fragment.md` §2 (7 DoD-Punkte) / §3 (Plan) /
§1 (Ziel/Adaption); `spec/lastenheft.md` `LH-QA-01`/`LH-QA-02`/`LH-QA-03`; realer Stand aus
Working-Tree-Diff **plus** den zwei committeten slice-017-Vorbereitungs-Commits
(`61cadfa` Eintritts-Move open→in-progress, `503f186` Rename `harness.mk`→`d-check.mk`).
**Frage:** „Hat das Gebaute umgesetzt, was Plan/DoD/Spec verlangt?" (nicht „ist es gut?" = Review).
**Mittel:** ausgeführte Gates/Docker/git — jede Zeile mit Beleg-Befehl. Der Verifier committet/
verschiebt nichts.

**Vorbemerkung zum Abhak-Zustand.** Die 7 DoD-Kästchen in §2 stehen im Working Tree noch auf
`[ ]` (unabgehakt), und §7 trägt weiter den Platzhalter. Es liegt hier also **keine** positive
Implementer-Behauptung „`[x]`" vor, die zu bestätigen/widerlegen wäre — der Verifier prüft die
**Substanz** jedes DoD-Punkts gegen den realen Stand. Das Abhaken (Implementer) und die
Closure-Notiz (Planner) sind Vor-`done/`-Buchführung, unten als „ausstehend" vermerkt (kein
VIOLATED — die geforderten Sachverhalte sind erfüllt).

---

## DoD-Punkt für DoD-Punkt (§2, 7 Punkte)

### DoD-1 — Gate aus `--print-mk`-Fragment (v0.46.0) abgeleitet: Target `docs-check`, Pin via `DCHECK_DIGEST`, `--network none` aktiv — **CONFIRMED**
- Herkunft belegt: `git log --follow d-check.mk` tracet sauber über `503f186` (Rename) auf
  `harness.mk` (slice-016 `8429e41`, slice-013, Bootstrap) zurück; der Kopfkommentar
  (`d-check.mk:1-11`) deklariert „Abgeleitet aus `d-check --print-mk` (v0.46.0)".
- Target-Name: `d-check.mk:24-26` = `.PHONY: docs-check` / `docs-check:` (mit „s", nicht `doc-check`).
- Pin via `DCHECK_DIGEST`: `d-check.mk:13` = `DCHECK_DIGEST ?= sha256:9c317bf1…36a1`; die
  `ifeq`-Logik (`d-check.mk:17-22`) lässt den Digest den Tag stechen. **Live bestätigt beide Wege:**
  `make -n docs-check` → `…d-check@sha256:9c317bf1…36a1` (Digest-Ref); `make -n docs-check
  DCHECK_DIGEST=` → `…d-check:v0.46.0` (Tag-Ref bei leerem Override) — `ifeq` greift korrekt.
- `--network none`: im Recipe (`d-check.mk:26`) und in **jedem** Dry-Run/Live-Run sichtbar
  (`docker run --rm --network none …`).

### DoD-2 — MR-010-Struktur: `d-check.mk` aus `harness.mk` **umbenannt** per reinem git-mv vor dem Inhalt (Hard Rule 3.3); Makefile-`include`/§Baseline/MR-009-Pointer nachgezogen — **CONFIRMED**
- **Reiner Rename-Commit R100 VOR dem Rewrite:** `git show --find-renames --name-status 503f186`
  → `R100  harness.mk  d-check.mk` (similarity index 100 %, **0** Inhaltszeilen im `.mk`) plus
  `M Makefile` (anderes File, tangiert die `.mk`-Rename-Detection nicht). Der Inhalts-Rewrite auf
  das volle `--print-mk`-Fragment liegt **getrennt** im uncommitteten Working Tree (`git diff
  d-check.mk`, 69 geänderte Zeilen). Reihenfolge Move→Inhalt = Hard Rule 3.3 gewahrt.
- Makefile nachgezogen (im selben Commit `503f186`): `Makefile:5` = `include d-check.mk`;
  Kopfkommentar `Makefile:1-2` = „Doc-Gate via d-check-Fragment (d-check.mk, aus `d-check
  --print-mk`, MR-010)".
- §Baseline nachgezogen: `harness/conventions.md:14` = „**d-check:** Image v0.46.0 (Digest in
  **d-check.mk**, MR-010)" — von `harness.mk` umgestellt, MR-010-Pointer ergänzt.
- MR-009-Pointer nachgezogen: `harness/conventions.md:382` verlinkt aus dem MR-009-Auflösungs-
  Trigger vorwärts auf `[MR-010]` („seit MR-010 via `DCHECK_DIGEST`, früher `D_CHECK_IMAGE`").
- Die verbliebenen `harness.mk`-Nennungen im MR-009-**Body** (`conventions.md:346,351`,
  „Digest in harness.mk") sind per **MR-010 Setzung 3** ausdrücklich als **historischer
  Zeitbezug** stehen gelassen (feuern kein `codepaths` — root-level Datei) — bewusst, dokumentiert,
  kein VIOLATED.

### DoD-3 — Volles Target-Set (elf), aber nur `docs-check` als Gate *behauptet* (in `gates` + AGENTS §4 + README §Sensors); kein advisory-Target als Gate behauptet — **CONFIRMED (LH-QA-01)**
- **Elf Targets vorhanden:** `grep -cE '^\.PHONY:' d-check.mk` → **11**; Namen: `docs-check`
  + zehn advisory (`doc-trace`/`doc-complete`/`doc-doctor`/`doc-repair`/`doc-immutable`/
  `doc-commits`/`doc-planning`/`doc-tracked`/`doc-targets`/`doc-help`).
- **Nur `docs-check` behauptet:** `Makefile:84` = `gates: baseline-verify docs-check test
  shell-lint record-gates` (kein `doc-*`); `AGENTS.md:85` (§4-Tabelle) nennt nur `make docs-check`;
  `harness/README.md:41` (§Sensors) nennt nur `make docs-check`.
- **Kein advisory-Target als Gate behauptet:** `grep 'doc-trace\|doc-doctor\|…\|doc-help'
  AGENTS.md harness/README.md Makefile` → **leer**. Die zehn advisory-Targets sind **verfügbar,
  aber nicht behauptet** (wie `regelwerk-check`) — „behauptet" ≠ „vorhanden", kein halluziniertes
  Gate. LH-QA-01 gewahrt.

### DoD-4 — Netzlos belegt: `docs-check` mit `--network none` grün — **CONFIRMED (ausgeführt)**
- `make docs-check` → `docker run --rm --network none … d-check@sha256:9c317bf1…36a1` →
  **„d-check: 46 Datei(en) geprüft, 0 Befund(e)"**, **Exit 0**. `--network none` aktiv, Gate grün —
  kein aktives Modul braucht Netz (`external` als einzige Netz-Tür ist nicht aktiv).

### DoD-5 — `make gates` grün; Name/Version konsistent (`docs-check`, v0.46.0 in §Baseline/README) — **CONFIRMED**
- `make gates` → **Exit 0**. Teilläufe: `baseline-verify: v3.1.0 OK — 42 Dateien` · `d-check:
  46 Datei(en) geprüft, 0 Befund(e)` (Digest-Ref, `--network none`) · `1..47 … ok 47` (bats) ·
  shellcheck ohne Befund · `record-gates`.
- Namens-/Versions-Konsistenz: `docs-check` in `Makefile` (`gates`), `AGENTS.md:85` §4,
  `harness/README.md:41` §Sensors, `harness/conventions.md:14` §Baseline und `README.md:16/48`;
  `v0.46.0` in §Baseline (`conventions.md:14`) und Root-`README.md:16` („d-check v0.46.0") —
  deckungsgleich, kein Rest-`v0.10.0` in lebenden Quellen.
- Nuance (wie slice-016): Lauf auf dem Working Tree, nicht auf frischem Klon — deterministische
  Config/Doku auf grünem Repo; der Frisch-Klon-Beweis ist die MR-003-CI-Restlücke nach Commit.

### DoD-6 — Neuer Adaptions-Eintrag MR-010 in `harness/conventions.md`; Anker löst auf; ergänzt MR-009 — **CONFIRMED**
- `harness/conventions.md:385` = `### MR-010 — d-check-Gate-Fragment tool-generiert`, voller
  Eintrag (Geltungsbereich, Adaption, Setzung 1–3, Begründung, Auflösungs-Trigger). Setzung 2
  kodiert „nur `docs-check` behauptet" (LH-QA-01), Setzung 3 „reiner git-mv vor Rewrite"
  (Hard Rule 3.3).
- **Anker maschinell bestätigt:** MR-010 wird aus §Baseline (`:14`), MR-009-Trigger (`:382`),
  `AGENTS.md`, `harness/README.md:41` verlinkt; `make gates` (d-check `anchors`-Modul) meldet
  0 Befunde — ein toter Anker würde flaggen. Ergänzt MR-009 explizit (`conventions.md:389`
  „ergänzt MR-009"; Rück-Verweis `:382`).

### DoD-7 — Closure-Notiz mit Steering-Loop-Lerneintrag — **AUSSTEHEND (Planner-Schritt, kein VIOLATED)**
- `slice-017-…md` §7 (`:100-102`) trägt weiter den Platzhalter „`<!-- Erst nach Abschluss
  füllen. -->`". Die Closure-Notiz wird per Prozess **nach** der Verifikation in der Planner-Rolle
  geschrieben (wie in der Aufgabe vorgegeben) — daher **erwartet leer**, kein VIOLATED.
  Vor `git mv → done/` nachzutragen (mit echtem Steering-Loop-Lerneintrag, Modul 5).

---

## Plan-vs-Code-Diff (Verifier-spezifisch)

**Plan wurde nachgezogen — Plan ⇄ Implementierung deckungsgleich.** Der Slice-Datei-Diff
(`git diff slice-017-…md`) ist eine reine **Plan-Schärfung**: §1-Adaption, §2-DoD (2. + 3. Punkt),
§3-Tabelle und §6-Risiken wurden auf die tatsächliche Entscheidung umgeschrieben — „volles
`--print-mk`-Fragment, nur `docs-check` behauptet, `d-check.mk` per git-mv, MR-010". Kein
Widerspruch zwischen dem nachgezogenen Plan (§1/§3) und dem Gebauten.

**Plan-Tabelle §3 vollständig gedeckt:**
- `harness.mk`→`d-check.mk` (`git mv`, rename): Commit `503f186` (R100). ✓
- `d-check.mk` (Inhalt, refactor): Working-Tree-Diff (volles Fragment, `doc-check`→`docs-check`,
  `DCHECK_DIGEST`, `--network none`). ✓
- `Makefile` (`include harness.mk`→`include d-check.mk` + Kommentar): Commit `503f186`. ✓
- `harness/conventions.md` (MR-010 + §Baseline + MR-009-Pointer): Working-Tree-Diff. ✓
- `AGENTS.md` §4 / `harness/README.md` §Sensors („nur falls berührt"): `harness/README.md`
  im Diff (MR-010-Bindung + „netzlos `--network none`"); `AGENTS.md` **nicht** berührt — der
  Name `docs-check` stand dort schon, kein Nachzug nötig (plangerecht „nur falls berührt"). ✓
- `README.md` („falls dort genannt"): **nicht** berührt — Root-`README.md` nennt bereits
  `docs-check`/`v0.46.0` konsistent (aus slice-016), kein Nachzug nötig. ✓

**Realer Änderungs-Umfang:** Working Tree = 4 Dateien (`d-check.mk`, `slice-017-…md`,
`harness/README.md`, `harness/conventions.md`) + 1 untrackt (`…-slice-017-impl-review.md`,
Modul-10-Review-Artefakt); committet = `503f186` (Rename + Makefile) + `61cadfa` (Eintritts-Move).
**Kein Scope-Creep** — alles innerhalb §3.

**Bekannte, nicht-slice-017-Drift (kein VIOLATED):** `spec/lastenheft.md:52` (`LH-FA-03`
Emit-Spec) benennt das **vom künftigen Emitter** erzeugte Fragment weiter `harness.mk`. Das ist
die **Forward**-Emit-Spec, nicht das Dogfood-Fragment; slice-017 rührt `spec/` nicht an
(nicht im Diff). Als Review-Befund **LOW-1** dokumentiert, beim Bau von slice-001/002 zu
reconcilen — außerhalb der slice-017-DoD.

## ADR-Konformität

- **Keine ADR berührt:** kein `docs/plan/adr/000*.md` im `git diff`/`git status` (bestätigt via
  `git diff --name-only | grep adr` → leer). Der `matrix`-Sensor läuft in `make gates` mit 0 Befunden.
- **ADR-0003 (Docker-only) gewahrt:** `d-check.mk` hat **keinen** Host-Egress — nur `docker run`,
  kein `curl`/`wget`/Host-Toolchain. `--network none` **härtet** netzlos (keine Gate-Lockerung →
  §3.5 nicht berührt). Alle Checks liefen ausschließlich über `make`/`docker`, kein Host-`go`/`pip`/`npm`.

## Pin-Integrität (LH-QA-02)

`DCHECK_DIGEST` (`d-check.mk:13`) = `sha256:9c317bf116a614a00f417871da4ca6057bdbabf0ca53af24c6d8e8b776de36a1`
— **identisch** zum slice-016-Pin, **unverändert**. **Tag→Digest live bestätigt:**
`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.46.0` → `Digest:
sha256:9c317bf1…36a1`. Der Tag `v0.46.0` löst auf **exakt** den gepinnten Digest auf. Dieser
Slice ändert Herkunft/Struktur des Fragments, nicht die Version — kein Rückschnitt von slice-016.

---

## Verdikt

- **DoD substanziell bestätigt:** **JA** — 6/7 CONFIRMED, **0 VIOLATED**, 1 AUSSTEHEND
  (DoD-7 Closure-Notiz = erwarteter Planner-Schritt nach der Verifikation). Jede Behauptung mit
  ausgeführtem Beleg (git-mv R100, `git log --follow`, elf Targets, `make gates` Exit 0,
  `docs-check` netzlos grün, Digest-Bindung live, MR-010-Anker grün).
- **Plan-vs-Code:** Plan wurde nachgezogen und ist deckungsgleich mit dem Gebauten; §3-Tabelle
  vollständig gedeckt; kein Scope-Creep. Die eine bekannte Drift (Emit-Spec `harness.mk`,
  Review-LOW-1) liegt außerhalb der slice-017-DoD.
- **ADR-Konformität:** keine ADR berührt; ADR-0003 Docker-only gewahrt (kein Host-Egress,
  `--network none` härtet statt zu lockern).
- **Pin:** `DCHECK_DIGEST` == slice-016-Pin, live gegen `:v0.46.0` gebunden — unverändert.
- **Reif für `done/`:** **NOCH NICHT — zwei Buchführungs-Schritte offen:** (1) die 7 DoD-Kästchen
  in §2 abhaken (Implementer), (2) §7 Closure-Notiz mit echtem Steering-Loop-Lerneintrag füllen
  (Planner). Die **Substanz** aller DoD-Punkte ist erfüllt; sobald Abhakung + Closure-Notiz stehen,
  ist der `git mv → done/` frei (der Verifier verschiebt nichts). Die Working-Tree-vs-Frisch-Klon-
  Nuance bleibt als MR-003-CI-Restlücke nach Commit offen, kein Blocker.
