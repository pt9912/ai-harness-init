# Review-Report: slice-018 Plan (Baseline-Freshness — Release-Listen-Sensor) — 2026-07-18

**Review-Art:** Plan-Review — unabhängiger Reviewer (kein Selbst-Review; diesen Plan
nicht geschrieben). Geprüft wird der **Plan vor Implementierung** gegen Spec + Accepted-ADRs;
es existiert **kein Diff** — Eingabe ist der Plan selbst (Modul 10 §Plan-Review).

**Gegenstand:** `docs/plan/planning/open/slice-018-baseline-freshness.md` (Slice-Plan, noch
kein Code). Geprüft gegen `LH-QA-01` (offline-grün / keine halluzinierten Gates), `LH-QA-02`
(Reproduzierbarkeit), `LH-QA-03` (minimale Abhängigkeiten), `ADR-0003` (Go-native, Docker-only),
`MR-007` (Auflösungs-Trigger „Release-Liste-Sensor fehlt"), sowie slice-009 (`regelwerk-check`,
Asset-Achse) als Vorgänger am gleichen Modul.

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 ·
**Modell:** claude-opus-4-8[1m] (unabhängiger Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — Plan-Review-Adaption):**
1. **Diff/Range:** **keiner** — Plan-Review prüft den Plan *vor* dem Diff. Gegenstand ist die
   Plan-Datei oben.
2. **Betroffene LH:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
   [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
   [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
3. **Referenzierte ADRs:** [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Go-native, Docker-only) —
   ADR-Verträglichkeit geprüft (Negativ N-8). Der Plan nennt keine weitere ADR.
4. **Hard Rules:** `AGENTS.md` §3.1 (keine halluzinierten Gates), §4/§Sensors (keine
   Sensor-Promotion ins Gate-Set).
5. **Vorherige Findings/Slices am gleichen Modul:**
   `docs/plan/planning/done/slice-009-regelwerk-drift-check.md` (Asset-Achse, `regelwerk-check`,
   Netz-Target-außerhalb-gates-Präzedenz), `docs/reviews/2026-07-18-slice-016-impl-review.md`
   (d-check-Ventile / `codepaths`-Roots, Marker-Klassen).
6. **Slice-Plan:** der zu prüfende Plan selbst (Plan-Review-Gegenstand).

**Ausgeführte Verifikationsmittel (Belege):**
- `make docs-check` → **„44 Datei(en) geprüft, 0 Befund(e)"**, **Exit 0** (Image-Digest
  `sha256:9c317bf1…`). Die Plan-Datei ist unter den 44 (liegt unter `docs/`, kein Ignore-Glob) →
  ihr `d-check:ignore (geplante Datei)`-Marker auf `harness/tools/baseline-freshness.sh` trägt.
- `curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/pt9912/ai-harness-course/releases/latest`
  → effektive URL **`https://github.com/pt9912/ai-harness-course/releases/tag/v3.2.0`**, Exit 0
  (reine Leseoperation). Belegt: (a) der `releases/latest`-Redirect-Follow funktioniert und die
  effektive URL endet auf `/releases/tag/<tag>`; `basename` → `v3.2.0`; (b) der Stack ist
  jq/API/JSON-frei (nur curl + coreutils); (c) **Upstream steht auf `v3.2.0`, gepinnt ist
  `BASELINE_TAG = v3.1.0`** — der Sensor würde beim ersten Lauf real Alarm melden (vom Plan
  in §Plan-Review-Vermerk antizipiert).
- `.d-check.yml:44` → `codepaths.roots = [spec, docs, harness]`; `test/` ist **kein** Root →
  erklärt, warum der Plan die geplante `.sh` (unter `harness/`) markieren muss, die geplante
  `.bats` (unter `test/`) aber nicht. Deckt sich mit docs-check 44/0.
- `Makefile:35` → `make test` reicht das **Verzeichnis** `test/` an bats → eine neue
  `test/baseline-freshness.bats` läuft **automatisch** in `make test`, und `make test` ist in
  `gates` (`Makefile:83`). Basis für F-1.
- `Makefile:29,83` → `gates: baseline-verify docs-check test shell-lint record-gates`; kein
  Netz-Rezept in der Kette, `baseline-freshness` nicht darunter (Negativ N-1).

---

## Findings

### F-1 — Der hermetische bats-Test landet über `make test` **in** `gates` — seine Netzlosigkeit ist damit gate-tragend (undokumentierte Interaktion)

- `kategorie`: INFO
- `quelle`: `LH-QA-01` (offline-grün) / Maintainability (undokumentierte Annahme)
- `pfad`: `docs/plan/planning/open/slice-018-baseline-freshness.md:49` (DoD „Hermetischer bats-Test");
  Mechanik: `Makefile:35` (`make test` → `test/`) + `Makefile:83` (`test` in `gates`)
- `befund`: Der Plan hält korrekt fest, dass das **Target** `baseline-freshness` **nicht** in
  `gates` liegt (DoD 3, §6) und der **Test** „nie das Netz trifft" (DoD 4). Er benennt jedoch
  **nicht**, dass eine neue `test/baseline-freshness.bats` von `make test` (das das ganze
  `test/`-Verzeichnis an bats reicht) automatisch aufgenommen wird und `make test` **in `gates`**
  läuft. Die Netzlosigkeit des Tests ist damit **gate-tragend**, nicht nur eine Testeigenschaft:
  Failure-Szenario — invoziert der Test versehentlich den echten Fetch-Pfad (Kopplung statt
  Fetch↔Vergleich-Trennung), trifft `make test` das Netz und `make gates` verliert offline-grün
  (`LH-QA-01`). Der Plan mandatiert die Trennung (DoD 2 „Fetch↔Vergleich getrennt", DoD 4 „nie
  das Netz"), macht aber die *Warum-kritisch*-Kopplung an `gates` nicht explizit.
- `verifizierbar`: **ja** — nach Impl: `grep -L 'curl\|BASELINE_URL\|releases/latest'
  test/baseline-freshness.bats` muss leer sein (Test ruft keinen Fetch); Gegenprobe: ein Test,
  der den Fetch-Pfad aufruft, ließe `make test`/`make gates` netz-abhängig werden. Zur Planzeit
  kein Gate-Lauf möglich (kein Diff) — Prüfpunkt für das Code-Review.

## Negativbefunde (geprüft, ohne Befund — mit ausgeführten Belegen)

- **N-1 · Offline-grün gehalten, keine Sensor-Promotion (`LH-QA-01`, HIGH-Anker) — kein Befund:**
  `gates: baseline-verify docs-check test shell-lint record-gates` (`Makefile:83`) enthält **kein**
  Netz-Rezept; `baseline-freshness` ist **nicht** darunter und nicht in der Sensors-Tabelle
  (`harness/README.md:38-44` / `AGENTS.md:82-88`, wo auch das Schwester-Netz-Target
  `regelwerk-check` bewusst fehlt). Der Plan schließt Promotion mehrfach aus (DoD 3, §6). `make
  gates` bleibt netzlos — kein halluziniertes/offline-brechendes Gate.
- **N-2 · MR-007-Achsen sauber getrennt, „ergänzt, ersetzt nicht" stimmig — kein Befund:** §1 trennt
  explizit Asset-Achse (slice-009/`regelwerk-check`: „ob das Asset des gepinnten Tags nachträglich
  verändert wurde") von Tag-Achse (slice-018: „ob ein neuer Tag erschien") und sagt „Zusammen ergeben
  beide das volle Upstream-Bild". `MR-007`-Auflösungs-Trigger (`harness/conventions.md:270-279`) nennt
  wörtlich „ein Sensor auf die Release-*Liste* (statt auf ein Asset) fehlt und ist Kandidat für einen
  eigenen Slice" — slice-018 **ist** dieser Slice; die „löst die offene Lücke"-Behauptung trägt.
- **N-3 · Mechanik solide, jq/API-frei (`LH-QA-03`) — real getestet, kein Befund:** `curl -fsSLI …
  releases/latest` → effektive URL endet auf `/releases/tag/v3.2.0`; `basename` liefert `v3.2.0`;
  Vergleich gegen `BASELINE_TAG` (`Makefile:18`, `v3.1.0`) = Mismatch → Alarm. Nur curl + coreutils
  (`basename`) — kein jq, keine GitHub-API, kein JSON. Deckt sich mit dem etablierten
  `releases/latest`-Redirect (`regelwerk/README.md`-Baseline-Download).
- **N-4 · Hermetik im DoD zwingend formuliert — kein Befund (Restrisiko als F-1):** DoD 2
  („Fetch↔Vergleich getrennt (hermetisch testbar)") **und** DoD 4 („der Vergleicher wird mit
  Fixture-Strings getestet … der Test trifft **nie** das Netz") mandatieren die Trennung an zwei
  Stellen. Der Plan lässt korrekt offen, *wie* (kein Lösungsvorschlag) — die Trennung als
  verifizierbarer DoD-Vertrag reicht. Die gate-tragende Kopplung ist als F-1 (INFO) festgehalten.
- **N-5 · Modul-5-Schnitt prüfbar — kein Befund:** Kern = 4 berührte Dateien
  (`harness/tools/baseline-freshness.sh` neu, `Makefile` update inkl. `regelwerk-check`-`@echo`,
  `test/baseline-freshness.bats` neu, `harness/conventions.md` MR-007) — Größenordnung von slice-009.
  Der **scheduled CI-Job** (`.github/workflows/`, neue Sub-Area) ist als **Folge-Slice** ausgelagert
  (§6, §8) — genau die Auslagerung, die slice-009 §7 als offen ließ. In einer Review-Sitzung prüfbar.
- **N-6 · Herkunfts-Ehrlichkeit — kein Befund:** Der Plan führt die „Release-Liste-statt-Asset"-Idee
  **nicht** als normatives Zitat, sondern als Vermerk „upstream, nicht vendored (Baseline = Welle 26)"
  und stützt jede DoD auf **präsente** Quellen (`MR-007`, `regelwerk-check`, `BASELINE_TAG`). Die
  Bindung „v3.1.0 = Welle 26" ist in-repo belegt (`reviewer.md:4`). **Keine** DoD hängt an einer
  nicht-präsenten Quelle; DoD 5 zeigt auf die *präsenten* `regelwerk-check`-`@echo` (`Makefile:75`)
  und den `MR-007`-Text. Konsistent und ehrlich.
- **N-7 · d-check-Sauberkeit des Plans — real getestet, kein Befund:** `make docs-check` grün (44/0).
  `codepaths.roots = [spec, docs, harness]` (`.d-check.yml:44`): die geplante `harness/tools/
  baseline-freshness.sh` liegt unter einem Root → Existenz-Prüfung → korrekt mit `d-check:ignore
  (geplante Datei)` markiert (DoD-Zeile + §3-Tabelle). Die geplante `test/baseline-freshness.bats`
  liegt unter `test/` (**kein** Root) → nicht geprüft → korrekt **ohne** Marker. Planned ≠ Tombstone
  (Inline-`ignore`-Marker statt `codepaths.ignore-refs`, das für **entfernte** Artefakte reserviert
  ist — slice-016-Abgrenzung); die grüne docs-check-Ausgabe bestätigt die Konsistenz.
- **N-8 · ADR-0003-Verträglichkeit (Docker-only) — kein Befund:** Host-`curl` für die read-only
  Netz-Sonde ist **kein** ADR-0003-Verstoß: ADR-0003 §Entscheidung bindet **den Build** an Docker
  („Cross-Compile im gepinnten Build-Image, **kein Host-`go`**"), nicht jede Host-Utility; der
  CLAUDE.md-Guard blockt Paketmanager/Toolchains (`go/pip/npm/…`), **nicht** curl. Präzedenz:
  `regelwerk-check` (`Makefile:63`) nutzt bereits Host-`curl`, slice-009 approved. Der **Test** läuft
  Docker-only im gepinnten `BATS_IMAGE` (DoD 4), `shell-lint` (Docker, `harness/tools/*.sh`) deckt die
  neue `.sh` (`Makefile:41`). Der Plan folgt der `regelwerk-check`-Linie (§6 „Kein neuer ADR/Werkzeug").
- **N-9 · 0/1/2-Exit-Semantik konsistent zu slice-009 — kein Befund:** DoD 1 spiegelt die
  `regelwerk-check`-Semantik (0 = aktuell, nonzero = neuer Tag, Fetch-Fehler ≠ veraltet, eigener
  Exit/Hinweis). Die bekannte Grenze (`make` kollabiert Recipe-Fehler auf Exit 2, die Meldung ist
  kanonisch — `Makefile:57-60`, slice-009 Closure) ist im „spiegelt … Semantik von regelwerk-check"
  mitgetragen. Fetch-Fehler wird nicht als „veraltet" dargestellt.
- **N-10 · Reuse `BASELINE_TAG` als einzige Tag-Quelle (`LH-QA-02`) — kein Befund:** DoD 2 verlangt
  Reuse von `BASELINE_TAG`, **kein** neuer Pin-Speicher — deckungsgleich mit `MR-007` Setzung 4
  („Der Tag-String hat genau eine Quelle: `BASELINE_TAG`", `harness/conventions.md:254-256`).

## Nicht abschließend verifizierbar (Planzeit, nicht anlage-tragend)

- Die **Welle-Nummerierung** upstream (v3.2.0 = „Welle 27"?) ist netz-/kurs-seitig und ohne die
  nicht-vendored Kurs-Fassung nicht gegengeprüft. Der Plan behandelt sie korrekt als **nicht-normativen
  Provenienz-Vermerk** (N-6), keine DoD hängt daran — Nicht-Verifizierbarkeit ist damit unschädlich.
- Ob `baseline-freshness` beim ersten Lauf **DRIFT** meldet, ist über den curl-Beleg (Upstream v3.2.0
  vs. Pin v3.1.0) **bestätigt** und vom Plan antizipiert; es bricht `make gates` nicht (Target nicht in
  `gates`) und ist kein Anlage-Blocker — das Handeln auf den Alarm ist Prozess, kein Code (§6).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 (F-1 — hermetischer Test ist über `make test` gate-tragend; undokumentierte Kopplung) |

## Verdikt

**Anlage-/Merge-blockierend:** **nein.** Kein HIGH, kein MEDIUM, kein LOW. Der Plan ist über alle
Prüf-Schwerpunkte tragfähig: `make gates` bleibt netzlos (Target bewusst außerhalb `gates`, keine
Sensor-Promotion, N-1); die MR-007-Achsen-Trennung (Asset vs. Tag) ist sauber und die „löst die
offene Lücke"-Behauptung durch den wörtlichen `MR-007`-Auflösungs-Trigger gedeckt (N-2); die
Kernmechanik ist **real getestet** — `releases/latest` → `/releases/tag/v3.2.0`, `basename`
funktioniert, jq/API-frei (N-3, `LH-QA-03`); die Hermetik ist im DoD **zweifach** zwingend
formuliert (N-4); der Modul-5-Schnitt ist mit ausgelagertem CI-Job prüfbar (N-5); die
Herkunft ist ehrlich als nicht-vendored markiert, ohne DoD-Abhängigkeit von einer nicht-präsenten
Quelle (N-6); der Plan selbst ist d-check-sauber (`make docs-check` 44/0, N-7); ADR-0003 ist
gewahrt (Host-`curl` = etablierte `regelwerk-check`-Präzedenz, Build/Test bleiben Docker-only, N-8).

Das eine INFO (F-1) ist **nicht** anlage-blockierend: der Plan mandatiert die Hermetik bereits
(DoD 2 + 4); F-1 macht nur explizit, dass diese Hermetik über `make test` **gate-tragend** wird —
ein konkreter Prüfpunkt fürs spätere **Code-Review**, kein Plan-Defekt. Empfehlung: den Satz
„der Test läuft via `make test` in `gates` — Netzlosigkeit ist offline-grün-tragend" in DoD 4
ergänzen (eine Zeile), damit die Kopplung dokumentiert ist.

**Ausgeführte Belege real:** `make docs-check` **Exit 0 / 44 Datei(en), 0 Befund(e)**; `curl -fsSLI`
gegen die Kurs-Release-URL **Exit 0**, effektive URL `…/releases/tag/v3.2.0` (Nebenbefund: Upstream
ist v3.2.0 > gepinnt v3.1.0 — der Sensor hätte sofort recht). Kein Host-`go/pip/npm`. Nichts
implementiert, committet oder verschoben.
