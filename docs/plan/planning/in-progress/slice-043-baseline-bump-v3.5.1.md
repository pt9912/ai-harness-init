# Slice slice-043: Baseline-Re-Vendor v3.5.0 → v3.5.1

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung — die vom Freshness-Nachtlauf gemeldete Baseline-Tag-Drift auflösen,
wie slice-026/027 Harness-Wartung ohne Welle waren).

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (committet vendored Baseline + Re-Baseline-Mechanik), [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) (`.d-check.yml`-`sources`-Kopplung), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit/Pins).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Die vendored Baseline wird von `v3.5.0` auf `v3.5.1` re-vendored (der neue Regelwerk-/Templates-Stand,
den `baseline-freshness` als neueren Tag meldete). Alle gekoppelten Pins ziehen mit, die alte
`<tag>`-Version weicht (Setzung „ein Tag zur Zeit"), und `make baseline-verify`/`make gates` bleiben grün.

## 2. Definition of Done

- [x] **Baum re-vendored:** `.harness/baseline/v3.5.1/{regelwerk,templates}/` + `SHA256SUMS`
  (aus dem Release-ZIP entpackt; SHA256SUMS neu erzeugt: `sha256sum` über alle Dateien, Pfade relativ
  zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei selbst ausgenommen — [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2). Der alte
  `.harness/baseline/v3.5.0/`-Baum ist **entfernt** (Setzung 4: ein Tag zur Zeit).
- [x] **Provenienz-Pin:** `BASELINE_ZIP_SHA256` (Makefile) = sha256 des v3.5.1-Release-Assets
  (`7268a8e6f36476c98d5cf0547d16deacec70fcddcf23df38f87d029e967cb10d`, live gemessen); `BASELINE_TAG` = `v3.5.1`.
- [x] **Gekoppelte Pins mitgezogen (fail-closed-Tests grün):** `DefaultTag` + `DefaultBaselineSHA256`
  ([`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go), Kopplung `TestDefaultTag_MatchesBaseline` /
  `TestDefaultBaselineSHA256_MatchesMakefile`) und der `.d-check.yml`-`sources`-Block (url + sha256,
  Kopplung `test/sources-pin.bats`, [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)).
- [x] **Doc-Reconciliation:** die **aktiven** `v3.5.0`-Referenzen auf `v3.5.1` gezogen
  (`harness/conventions.md` §Baseline/Adoptierte Quellen, `docs/user/benutzerhandbuch.md`,
  `docs/plan/planning/README.md`, die Command-Templates/`.claude`-Commands, `.harness/skills/reviewer.md`).
  **Ausgenommen** (unverändert): frozen `done/`-Slices + `docs/reviews/**` (Zeitdokumente),
  **accepted ADRs** ([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md), Hard Rule 3.4 immutable — historischer Bezug bleibt), der vendored Baum selbst
  (wird ersetzt). Diese Slice-Datei und die Roadmap dürfen `v3.5.0` als **historischen** Bezug führen.
- [x] `make baseline-verify` grün: `v3.5.1 OK — <N> Dateien` (Integrität + Vollständigkeit, netzlos).
- [x] `make gates` grün (alle Gates auf dem re-vendored Stand).
- [x] `make mutate` grün: die Baseline-Wächter (Fälle 01/02/03) bleiben scharf. **Vorab-Befund:**
  Fall 01 matcht generisch (`[0-9a-f]{64}`), 02/03 hardcoden Tag/Hash nicht → **kein** Re-Anchoring
  erwartet; im Lauf bestätigt (Go-Bump-Lehre: Wert-Bump zieht `make mutate` nach).
- [x] Doku: `harness/conventions.md` §Baseline auf `v3.5.1` + Re-Baseline-Datum; ggf.
  Regelwerks-Stand-Zeile (Kurs-Welle) nachgezogen.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-24, live belegt):**
- Release v3.5.1 erreichbar; `lab-regelwerk.zip` = 124657 Bytes, sha256
  `7268a8e6f36476c98d5cf0547d16deacec70fcddcf23df38f87d029e967cb10d`. **42 Dateien** (21 regelwerk +
  21 templates) — **gleicher Dateisatz** wie v3.5.0 (die „54" in `unzip -l` zählte Verzeichnis-Einträge
  mit, kein Wachstum). **36 der 42 Dateien inhaltlich geändert** (alle 21 Regelwerk-Module + 15
  Templates; 0 hinzugefügt, 0 entfernt) — ein breiter Minor-Content-Refresh, keine Struktur-Änderung.
- 5 Pin-Stellen: `BASELINE_TAG`/`BASELINE_ZIP_SHA256` (`Makefile`), `DefaultTag`/`DefaultBaselineSHA256`
  ([`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go)), `.d-check.yml`-`sources` (url+sha256).
- `internal/fetch/baseline_test.go` nutzt `"v3.5.0"` als **Test-internes Fetch-Argument** (arbiträrer
  Tag für die Mechanik-Tests) — bleibt; nur eine echte DefaultTag-Kopplung wäre zu ziehen (prüfen).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.5.1/**` <!-- d-check:ignore (geplant — entsteht beim Vendoren) --> | neu | entpackt aus dem Release-ZIP + `SHA256SUMS` neu erzeugt |
| `.harness/baseline/v3.5.0/**` | entfernt | ein Tag zur Zeit ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4) |
| `Makefile` | update | `BASELINE_TAG`, `BASELINE_ZIP_SHA256` |
| [`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go) | update | `DefaultTag`, `DefaultBaselineSHA256` (Kopplungstests halten) |
| `.d-check.yml` | update | `sources`-url + sha256 (Kopplung `test/sources-pin.bats`) |
| aktive Doc-Dateien (§2-Liste) | update | `v3.5.0`→`v3.5.1`, frozen/ADR/vendored ausgenommen |

**Reihenfolge:** erst vendoren + Pins (die Mechanik-Kopplungen), `make baseline-verify` grün; dann die
Doc-Reconciliation, `make gates` grün; dann `make mutate`.

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** der Freshness-Nachtlauf meldete `v3.5.0 < v3.5.1`
(real, vom Nutzer per `workflow_dispatch` gesehen); welle-06 ist geschlossen, kein Vorgänger blockiert.

Rückführungen:
- `in-progress` → `next`: falls die Doc-Reconciliation + der Re-Vendor zusammen über die
  Ein-Sitzungs-Review-Linie gehen (dann Vendor+Pins von der Doc-Reconciliation trennen).
- `in-progress` → `open`: falls das Release-Asset nicht verifizierbar ist oder der v3.5.1-Regelwerks-Inhalt
  eine Konventions-Kollision einführt, die einen eigenen ADR braucht (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make baseline-verify` + `make gates` + `make mutate` grün; Slice per `git mv` nach `done/`
(eigener Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Regelwerk-Inhalt änderte sich breit (36/42 Dateien, gleicher Dateisatz).** Der Re-Vendor übernimmt
  den neuen Stand; ob eine geänderte Regel eine Repo-Konventions-Kollision einführt, ist beim Review
  zu prüfen — Stichprobe auf die Rollen-Module (5/8/9/10/11), auf die sich das Repo stützt (der Baum ist
  derivativ; bei Konflikt gilt der Kurs). Kein Blocker erwartet — v3.5.0→v3.5.1 ist ein Minor.
- **Externe Kurs-URLs nicht d-check-geprüft** (netzlos). Ein `.../blob/v3.5.0/...`→`.../v3.5.1/...`-Bump
  bricht `docs-check` nicht (externe Anker werden nicht erreicht), aber die Ziel-Anker müssen im
  v3.5.1-Kurs real existieren — beim Bumpen der aktiven URLs stichprobenartig prüfen.
- **ADR-Immutabilität (Hard Rule 3.4).** [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) trägt `v3.5.0` als historischen Bezug — **nicht** editieren.
- **`SHA256SUMS`-Selbstausschluss.** Die Datei kann sich nicht selbst hashen; ihre Integrität trägt git
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2) — beim Erzeugen ausnehmen, sonst schlägt `baseline-verify` fehl.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Der Re-Vendor lief mechanisch sauber: Provenienz **vor** dem Entpacken
verifiziert, `SHA256SUMS` per `find | LC_ALL=C sort | sha256sum` (temp→mv, damit `find` die Datei
nicht sieht), alter Tag raus — `baseline-verify: v3.5.1 OK — 42 Dateien`. Der Verifier zog die
Provenienz-Kette unabhängig nach (Release-Asset gefetcht, sha == Pin, `diff -rq` byte-identisch zum
Baum). Die 5 gekoppelten Pins hielten (Kopplungstests grün). Die **Reconciliation-Trennung** (aktive
Refs bumpen · historische „seit v3.5.0"-Aussagen + test-interne Tags + ADR-0006 behalten) war korrekt
und vollständig — beide Rollen bestätigten es. Der Content-Delta (36/42 Dateien) war ein Minor-Refresh
ohne Konventions-Kollision (Rollen-Module 05/08/09/10/11 änderten real nur ihre Quell-URL + den
Welle-Stand 32→33). **Kein Mutations-Re-Anchoring nötig** (Fall 01 generisch; Go-Bump-Lehre honoriert:
`make mutate` nach dem Pin-Bump gefahren, 55 ok/0).

**Was anders lief als geplant.** Der Reviewer meldete ein MEDIUM „`make test` nichtdeterministisch rot"
— **widerlegt als Orchestrierungs-Artefakt** (nicht slice-043-induziert): ich hatte Review und Verify
**gleichzeitig** auf demselben Working Tree gestartet, und der Verifier fuhr `make mutate`, das den Baum
je Fall mutiert. Der Reviewer maß diese Mutationen (die vier „Fehlschläge" sind 1:1 Mutations-Ziele).
Nachweis: 6/6 `make test`-Läufe grün allein + der Emitter sortiert deterministisch
(`internal/emit/templates.go:169`). Der Report trägt einen Planner-Nachtrag.

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Eine mutierende Rolle nie parallel zu einer lesenden Rolle auf demselben Working Tree.** Der
  Verifier fährt `make mutate` (mutiert den Baum je Fall); läuft der Reviewer währenddessen `make test`
  auf demselben Tree, misst er die Mutationen und meldet Phantom-„Flakiness" (F-12-Klasse: „ein
  paralleler mutate-Lauf hat real den mutierten Stand gemessen"). Der `mutate.lock` schützt nur gegen
  **parallele mutate-Läufe**, nicht gegen mutate + konkurrierendes test. **Regel für die
  Rollen-Orchestrierung:** Review und Verify, wenn eine von beiden mutiert, **sequenziell** fahren —
  oder der mutierenden Rolle einen **isolierten Worktree** geben. (Diese Session hatte dieselbe
  Parallel-Orchestrierung bei slice-040/041/042; dort kollidierte das Timing zufällig nicht — hier tat
  es das und erzeugte einen Falsch-Befund.)
- **Ein „Nichtdeterminismus"-Befund ist erst real, wenn er ISOLIERT reproduziert wurde.** Die schnelle
  Gegenprobe (N Läufe allein) trennt echten Map-Seed-Nichtdeterminismus von einem Mess-Artefakt — und
  die Failure-Test-Namen gegen die Mutations-Fall-Namen zu halten, zeigt die wahre Ursache in Sekunden.

**Folge-Slices.** Keine. Der Reviewer-INFO (Aggregator-Order-Edge) folgt aus derselben Artefakt-Ursache
und ist gegenstandslos. **Beide vom Freshness-Nachtlauf gemeldeten Drifts sind jetzt aufgelöst**
(Go 1.26.5, ubuntu 26.04 LTS, Baseline v3.5.1) — der `upstream-drift`-Job fährt wieder vollständig grün.

## 8. Sub-Area-Modus-Begründung

### Sub-Area: vendored Baseline (`.harness/baseline/` + Pins + Kopplungstests)

- **Modus:** BF — die Sub-Area existiert (der committet-vendored Baseline-Mechanismus aus
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), die Kopplungstests, `baseline-verify`); dieser Slice **re-vendored** sie, baut nicht neu.
- **Konventionen-Dichte:** hoch. [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fixiert die vier Setzungen (Provenienz≠Integrität,
  `SHA256SUMS`-Umfang, Vollständigkeits-Check, ein Tag zur Zeit); [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) die Zwei-Pin-Kopplung.
  Der Re-Vendor muss sie **erben**, nicht neu erfinden — historisch als Slice geführt (slice-011/012/019).
- **Phase-Reife:** Phase 4 (reif). Der Re-Vendor ist eine wiederkehrende Wartung.
- **Evidenz-/Diskrepanz-Risiko:** mittel. Der gewachsene Baum (42→54) kann eine Konventions-Änderung
  bergen; die breite Doc-Reconciliation kann eine aktive Referenz übersehen — genau darum die
  Rollen-Sequenz (Review/Verify fangen die Lücke, wie bei slice-042).
- **Reconciliation-Aufwand:** ein Slice; Graduation-Trigger: falls Vendor+Pins und Doc-Reconciliation
  die Review-Linie sprengen, auf zwei Slices trennen.
