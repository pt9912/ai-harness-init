# Review-Report: slice-125 (Re-Check der Nacharbeit) — 2026-09-06

**Review-Art:** Code — geprüft wird der Nacharbeits-Diff gegen den **Erst-Report**, gegen den
Slice-Plan, gegen die aktiven ADRs und gegen die Hard Rules (Modul 10 §Drei Review-Arten).
**Nicht** geprüft: DoD-Abhakung und Closure-Notiz §7 — Verifier- bzw. Planner-Arbeit in
getrenntem Kontext ([`AGENTS.md`](../../AGENTS.md) §3.10, Modul 11).

**Runde:** 2 von 2 · **Vorrunde:**
[`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md)
(F-1 HIGH · F-2/F-3/F-4/F-5 MEDIUM · F-6 LOW · F-7/F-8 INFO, Verdikt merge-blockierend)

**Gegenstand:** `slice-125` · Commit-Range `0491611..ac237dc` (fünf Commits: `48f7f58`,
`6584b06`, `1d18ea4`, `b3c0283`, `ac237dc`) auf `main` · 8 Dateien, +67/−13

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 (`278248f`) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan `slice-125` (§1 Anlass · §2 DoD (1)–(3) · §3 Plan-Tabelle · §4 Rückführungen ·
  §6 Risiken) — als Kennung genannt, weil sein Ort im Lifecycle wandert
  ([`AGENTS.md`](../../AGENTS.md) §3.11)
- Aktive ADRs:
  [`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)
- Berührte `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `MR`-Einträge: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
  [`MR-052`](../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules — namentlich §3.3, §3.5, §3.6, §3.7, §3.9, §3.10, §3.11
- **Vorherige Findings am gleichen Modul:** der Erst-Report dieses Slice (oben) sowie das
  Beobachtungs-Register [`BEO-ALL/`](../plan/planning/observations/README.md), namentlich
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)

## Prüfmittel und Sonden

Jede Aussage unten ist an diesem Stand neu gemessen, nicht aus einer Commit-Message übernommen.
Alle Läufe gegen **Kopien außerhalb des Arbeitsbaums** (`git archive HEAD | tar -x -C <kopie>`),
netzlos, Mount `:ro`, `docs-check` mit demselben Digest wie `make docs-check`
(`sha256:e31a372…`), bats mit demselben Digest wie `make test-bats`. Der Arbeitsbaum ist dabei
unberührt geblieben (`git status --porcelain` leer vor und nach dem Lauf).

| Sonde | Änderung an der Kopie | `docs-check` | `test/planning-modul-wiring.bats` |
|---|---|---|---|
| A | keine (Kontrolle) | `865 Datei(en) geprüft, 0 Befund(e)`, Exit **0** | 6× `ok`, Exit 0 |
| B′ | Fall `271` angewandt (`marker:`-Zeile gelöscht) | `0 Befund(e)`, Exit **0** — **still grün** | `not ok 4` (der benannte `# expect:`) |
| C′ | Fall `272` angewandt (`heading` → `## Meilensteine`) | `0 Befund(e)`, Exit **0** — **still grün** | `not ok 3` (der benannte `# expect:`) |
| D′ | Fall `273` angewandt (`planning:`-Rumpf entfernt) | `0 Befund(e)`, Exit **0** | `not ok 2/3/4/6`; **`ok 5`** |
| E′ | Fall `273` gegen die **alte** bats-Datei (`0491611`) | — | **`ok 6`** — still grün |
| F′ | `waves: {dir: docs/plan/planning}`, Modus **Default** | **2 Befunde**, `wave-drift` „*3 flache Wellendokumente — genau eines ist erwartet*", Exit **1** | — |
| G′ | dasselbe **plus** `mode: many` | **2 Befunde**, `wave-drift` „*welle-11 … der Abschnitt „## Offene Wellen" nennt es nicht*", Exit **1** | — |
| H′ | Ruhe-Marker in den besetzten Zustand gestellt, Lauf mit **den sechs `--disable`-Flags aus `make regelwerk-check`** | **1 Befund** `planning-drift`, Exit **1** | — |

Die Dateizahl ist kein Erwartungswert; tragend sind Befundzahl, Grund-Code und Exit-Code.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single
Source of Truth. Die Felder unten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung
gilt der Skill bzw. dessen Quelle Baseline-Regelwerk `modul-10-review-harness.md`
§Ziel-Form: Reviewer-Skill.

### N-1 — `make regelwerk-check` isoliert nicht mehr auf `sources`, und sein Kommentar sagt, dass er es tut

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar in Konfiguration beschreibt, was
  da ist) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `Makefile:181-182` (Kommentar) · `Makefile:185` (Rezept)
- `befund`: Der Kommentar sagt „*Die sechs `--disable`-Flags isolieren den Lauf auf `sources`:
  sie nennen genau die sechs Module, die `.d-check.yml` fuer docs-check aktiviert*", während
  `grep -m1 '^modules:' .d-check.yml` seit `c63ef63` **sieben** Module führt; `planning` steht
  in keinem `--disable` und läuft in diesem Rezept mit (Sonde H′: derselbe Flag-Satz liefert
  über einer Kopie mit verletzter Lifecycle-Invariante `1 Befund planning-drift`, Exit 1).
  `Makefile:185` ist damit der **einzige** d-check-Aufruf dieses Repos ohne `--disable planning`
  — die sechs Rezepte in `d-check.mk` tragen es (`git grep -c -- '--disable planning' d-check.mk`
  → 5, dazu `doc-planning`, das es enabled). Das Ziel läuft nächtlich in CI
  (`.github/workflows/upstream-drift.yml:48`, `cron: '0 1 * * *'`) als Upstream-Drift-Wecker;
  der Zustand, in dem es aus einem planning-Grund rot wird, ist derselbe, den der Erst-Report
  als F-5 (b) für die Closure dieses Slice vorhersagt.
- `verifizierbar`: ja — Sonde H′ (netzlos reproduzierbar, ohne `--enable sources`), dazu
  textuell `grep -m1 '^modules:' .d-check.yml` gegen `grep -n 'disable' Makefile`. **Kein Gate
  fängt es**, und das steht im Repo selbst: `make gates` führt `regelwerk-check` nicht
  (`grep -n '^record-gates:' Makefile`), `make docs-check` ist grün (Sonde A), und
  `make comment-claims` nimmt das `Makefile` **dauerhaft** aus — „*wer … ein `Makefile`-Rezept …
  schreibt, bekommt **gar keine** Prüfung — dort trägt allein das Review*"
  ([`harness/README.md`](../../harness/README.md) §Sensors).
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### N-2 — Der ergänzte Deckungs-Satz behauptet für `waves` einen eigenen Slice, den der Lifecycle nicht führt

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  · Maintainability
- `pfad`: `harness/README.md:77-78`
- `befund`: Der in `ac237dc` ergänzte Satz sagt zur `observations`-Fähigkeit „*anders als
  `waves` und `closure` trägt sie noch keinen eigenen Slice*"; für `closure` löst das auf
  (`slice-129`, vier Zeilen darüber genannt), für `waves` nicht — kein Slice in `open/`,
  `next/` oder `in-progress/` hat die `waves`-Aktivierung zum Gegenstand
  (`git grep -ln 'waves' -- 'docs/plan/planning/{open,next,in-progress}/slice-*.md'` nennt
  `slice-125` selbst und `slice-135`, einen d-check-Pin-Slice). Vier Zeilen darüber sagt
  derselbe Absatz das Gegenteil: das Zuschalten von `waves` setze die Auflösung einer
  Abweichung voraus, „*was dieser Slice nicht entscheidet*" — also ohne benannten Träger.
- `verifizierbar`: nein am Gate — kein Modul aus `modules:` urteilt über die Wahrheit von
  Prosa; nachprüfbar am Lifecycle-Bestand mit dem Kommando oben.
- `klasse`: Deckungs-Absatz behauptet einen Träger-Slice, den der Lifecycle nicht führt

### N-3 — Der Fall, der die Vakuität schließt, zählt eine Zusicherung als Wächter mit, die nicht fällt

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes
  Gegenbeispiel) · §3.7
- `pfad`: `test/mutations/273-planning-block-rumpf-entfernt.sh:6-8`
- `befund`: Der Kopf sagt „*Vier der sechs Zusicherungen fangen das laut ab
  (roadmap/heading/marker/Kopplung fallen)*"; gemessen fallen **drei** — Sonde D′ liefert
  `not ok 2/3/4` und **`ok 5`** für „*der konfigurierte heading existiert wortgleich als
  Abschnitt in der Roadmap*". Diese fünfte Zusicherung bleibt aus genau dem Grund grün, den
  der Fall für die sechste beseitigt: bei leerem Block liefert `field heading` den leeren
  String, und `grep -qxF "" roadmap.md` trifft jede der 24 Leerzeilen — die Klasse
  „Zusicherung über der leeren Menge wahr" steht eine Zeile weiter oben unverändert und wird
  im Kopf als Wächter geführt. Derselbe Kopf trägt in Zeile 8 mit „*faellt **jetzt** statt
  ueber der leeren Menge gruen zu bleiben*" zusätzlich eine Vorher-Nachher-Form.
- `verifizierbar`: ja — Sonde D′ (`docker run … $(BATS_IMAGE) test/planning-modul-wiring.bats`
  über einer Kopie mit angewandtem Fall `273`); die Ursache direkt mit
  `H=""; grep -qxF "$H" docs/plan/planning/in-progress/roadmap.md; echo $?` → `0`.
- `klasse`: Zusicherung über der leeren Menge wahr

### N-4 — Die Modul-Zahl im Roadmap-Arbeitspunkt widerspricht dem Kommando, das direkt daneben steht

- `kategorie`: MEDIUM
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  (Setzung 1 und 2) · [`AGENTS.md`](../../AGENTS.md) §3.7
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:59`
- `befund`: Der Arbeitspunkt (6) *Prosa-Aufzählung gegen ihre Config* der Zeile
  *Doku- und Sensor-Wartung* führt „*während `grep -n '^modules:' .d-check.yml` **sechs**
  führt (es fehlen `matrix` und `spans`)*"; genau dieses Kommando gibt seit `c63ef63` sieben
  Module aus. Die Zahl steht neben ihrem Kommando und widerspricht ihm — derselbe Mechanismus
  wie beim behobenen F-3, nur in dem Artefakt, das die Klasse *beschreibt*. Der Diff hat die
  Aussage falsch gemacht, nicht vorgefunden; die Datei ist von diesem Slice zweimal berührt
  worden.
- `verifizierbar`: ja, textuell — `grep -m1 '^modules:' .d-check.yml` gegen das Zitat. Kein
  Modul aus `modules:` urteilt über den Wahrheitsgehalt einer Prosa-Zahl.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### N-5 — Der bats-Kopf erklärt den Pfad weiter zur Review-Sache, für den der Diff gerade einen Fall angelegt hat

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7
- `pfad`: `test/planning-modul-wiring.bats:5-7`
- `befund`: Der Kopf sagt, eine Überschrift, die existiert und den Ruhe-Marker nie trägt,
  „*bleibt fuer `docs-check` unsichtbar und ist Gegenstand des Review, nicht dieses
  Waechters*". Die erste Hälfte ist weiter wahr (Sonde C′), die zweite seit `48f7f58` nicht
  mehr: `test/mutations/272-planning-heading-auf-marker-lose-sektion.sh` führt genau diese
  Konfigurationsänderung und nennt als `# expect:` die Zusicherung dieser Datei, die dabei
  fällt.
- `verifizierbar`: ja, textuell —
  `sed -n 's/^# expect: //p' test/mutations/272-*.sh` gegen die `@test`-Titel derselben Datei;
  verhaltensseitig Sonde C′.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### N-6 — Der Bündelungs-Grund von `ac237dc` benennt eine Unmöglichkeit, die keine ist

- `kategorie`: LOW
- `quelle`: Maintainability ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  (die Commit-Message dieses Repos steht im Geltungsbereich der Beleg-Disziplin)
- `pfad`: Commit `ac237dc`, Message-Absatz zu F-6
- `befund`: Die Message begründet die Bündelung von F-2 (MEDIUM) und der dritten
  F-6-Fundstelle (LOW) damit, die Stelle liege „*im selben Diff-Hunk wie die F-2-Ergaenzung
  und laesst sich darum nicht separat staged committen*". Gemessen sind es **zwei**
  voneinander unabhängige Änderungsblöcke — `git show -U0 ac237dc -- harness/README.md`
  liefert zwei `@@`-Köpfe (`-66,3 +66,4` und `-73 +74,8`), getrennt durch vier unveränderte
  Zeilen; zu **einem** Hunk werden sie erst durch den Default-Kontext von drei Zeilen
  (`git show ac237dc -- harness/README.md | grep -c '^@@'` → 1). Zwei Belange sind damit in
  einen Commit gelangt, und der genannte Hinderungsgrund ist nicht der Grund.
- `verifizierbar`: ja — die zwei `git show`-Aufrufe oben. Kein Gate liest Commit-Zuschnitte;
  [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 stellen dieselbe Lücke für ihre eigenen
  Commit-Regeln fest.
- `klasse`: Commit-Message begründet mit einer nicht gemessenen Unmöglichkeit

---

## Verdikt je Finding der Vorrunde

| Vorrunde | Kategorie | Verdikt | Beleg an diesem Stand |
|---|---|---|---|
| **F-1** | HIGH | **behoben** | `271` und `272` treffen beide die **stille** Stelle: Sonde B′ und C′ zeigen `docs-check` mit `0 Befund(e)`, Exit 0, und im selben Lauf fällt je exakt die im `# expect:` benannte Zusicherung (`not ok 4` bzw. `not ok 3`). `harness/tools/mutate.sh:698-699` verlangt genau diese Zeile — ein `ok` an dieser Stelle wäre `rot, aber '<expect>' faellt nicht` |
| **F-2** | MEDIUM | **behoben** | `harness/README.md:74-81` führt `observations` jetzt als vierte (additiv fünfte) Fähigkeit, *verfügbar und nicht aktiviert*, mit Zeiger auf `BEO-ALL/register-paarung-ohne-gate-modul` und die Drift-Log-Zeile. Ordinal und Beschreibung decken sich mit dem gepinnten Stand (`git show v0.74.1:internal/hexagon/core/model/config.go`, §`ObservationsConfig`). Die **Träger-Klausel** in derselben Ergänzung ist ein neuer Befund → N-2 |
| **F-3** | MEDIUM | **behoben** | `.github/workflows/ci.yml:24` nennt jetzt `links, anchors, ids, matrix, codepaths, spans, planning`; deckungsgleich mit `grep -m1 '^modules:' .d-check.yml`. Der **Zwilling im `Makefile`** war nicht Teil des Befundes und ist offen → N-1 |
| **F-4** | MEDIUM | **nicht behoben — korrekt unterlassen** | `docs/plan/planning/observations/BEO-ALL/register-paarung-ohne-gate-modul/state.md` ist im Diff nicht enthalten (`git diff --stat 0491611..ac237dc`). Planner-Artefakt nach [`AGENTS.md`](../../AGENTS.md) §3.10; Übergabe-Artefakt bleibt der Erst-Report |
| **F-5** | MEDIUM | **nicht behoben — korrekt unterlassen** | (a) `AGENTS.md` unberührt (Architect, §3.8) — die Sechser-Liste steht dort weiter in `AGENTS.md:325`. (b) Der Ruhe-Marker ist nicht zurückgestellt, und das ist am Ist-Stand richtig: `in-progress/` trägt `slice-125`. (c) wie F-4 |
| **F-6** | LOW | **behoben** | Alle drei Fundstellen nennen den Schalter — `.d-check.yml:36-39`, `docs/plan/planning/in-progress/roadmap.md:36-38`, `harness/README.md:66-67`. Die Aussage ist am gepinnten Stand gemessen: Default `one` (`EffectiveMode()`), Verzweigung in `CheckPlanningWaves`, und **beide** Modi fallen über diesem Baum (Sonden F′ und G′, je 2 Befunde mit verschiedenem `wave-drift`-Grund) |
| **F-7** | INFO | **nicht behoben — korrekt unterlassen** | Der Slice-Plan ist im Diff nicht enthalten; die leerlaufende Übergabe-Zeile bleibt Gegenstand der Closure |
| **F-8** | INFO | **behoben, mit dem stärksten Beleg des Laufs** | Sonde E′ gegen die alte bats-Fassung: `ok 6` — still grün. Sonde D′ gegen die neue: `not ok 6` mit der Meldung „*planning:-Block ist leer — die Zusicherung liefe ins Leere*". Der Fall `273` nennt als `# expect:` genau diese Zusicherung; ohne die Nacharbeit meldete `make mutate` für ihn `rot, aber … faellt nicht`. Der Fall behauptet daneben eine vierte fallende Zusicherung → N-3 |

## Negativbefunde

- **geprüft, ohne Befund: die drei neuen Mutations-Fälle gegen die Kopf-Pflichtfelder und
  `narrow_sensor`.** Alle drei tragen `# files:` und `# expect:`; keine `# expect:`-Zeile
  beginnt mit `Test[A-Z]`, sie fallen also auf die bats-Stufe
  (`harness/tools/mutate.sh` §`narrow_sensor`), und in allen drei Läufen erscheint der
  benannte Titel in einer `not ok`-Zeile — die Bedingung, die `mutate.sh:698-699` prüft. Der
  Datei-Modus `100644` ist ohne Belang: `mutate.sh:627` ruft `bash "$case_file"`, und der
  Bestand führt beide Modi (`git ls-files -s test/mutations/*.sh | awk '{print $1}' | sort -u`).
- **geprüft, ohne Befund: die drei neuen Fälle und die geänderten Kommentare gegen
  [`AGENTS.md`](../../AGENTS.md) §3.7, Herkunfts-Hälfte.** Keine Befund-Kennung, keine
  Slice-Nummer, kein Lauf-Protokoll:
  `grep -cE 'Review-Befund|slice-[0-9]' test/mutations/27{1,2,3}-*.sh test/planning-modul-wiring.bats`
  → je **0**, dasselbe über `sed -n '30,44p' .d-check.yml` und `sed -n '18,30p' .github/workflows/ci.yml`.
  Die eine Vorher-Nachher-Form steht in `273` und ist dort als Teil von N-3 geführt.
- **geprüft, ohne Befund: die Bedingtheit der zwei neuen Stille-Aussagen.** Beide Fälle sind
  nur über einem **besetzten** `in-progress/` still, und beide Köpfe sagen das („*ueber diesem
  Baum*", „*dieses Baums*") statt eine unbedingte Zusage zu machen. Der Fall selbst bleibt
  auch bei leerem `in-progress/` gültig, weil `mutate.sh` die bats-Zusicherung prüft und nicht
  `docs-check`.
- **geprüft, ohne Befund: die Kopplung der Fälle an die Stelle, die der Aufrufer benutzt.**
  Alle drei `sed`-Ausdrücke greifen an der realen `.d-check.yml`, und die bats-Datei liest
  dieselbe Datei über `$BATS_TEST_DIRNAME/..`; keine im Test nachgebaute Verdrahtung. Alle
  drei Mutationen lassen gültiges YAML zurück — sonst meldete d-check Exit 2 statt
  `865 Datei(en) geprüft` (Sonden B′, C′, D′).
- **geprüft, ohne Befund: die Aussage der `.d-check.yml`- und `ci.yml`-Kommentare gegen das
  gepinnte Werkzeug.** Der `planning`-Kommentar nennt Modul-Default-Überschrift und -Marker
  wortgleich mit `EffectiveHeading()`/`EffectiveMarker()` (`## Aktuelle Welle` /
  `Keine aktive Welle`), und der Schluss des CI-Kommentars („*keines davon liest
  `git`-Historie*") trägt weiter: `planning` ist hermetisch (`d-check.mk` §`doc-planning`:
  „*hermetisch, ohne Range*").
- **geprüft, ohne Befund: der Prüfbereich blieb grün.** `test/planning-modul-wiring.bats` über
  dem Arbeitsbaum: 6× `ok`, Exit 0. `docs-check` über einer Kopie des Ist-Stands:
  `865 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — die Zahlen des Auftrags sind damit
  unabhängig nachgestellt, nicht übernommen.
- **geprüft, ohne Befund: die übrigen d-check-Aufrufe des Repos.** Außer `Makefile:185`
  (N-1) trägt jeder Aufruf mit `--disable`-Liste ein `--disable planning`
  (`d-check.mk:92,96,104,108,112`) oder enabled das Modul absichtlich (`d-check.mk:100`).
  Die emittierte Ebene ist unberührt — der Diff fasst `internal/` nicht an.
- **geprüft, ohne Befund: `waves` und `closure` bleiben aus.** `grep -E '^[[:space:]]+(waves|closure):' .d-check.yml`
  ist leer; die Nacharbeit hat keine Fähigkeit zugeschaltet und damit
  [`AGENTS.md`](../../AGENTS.md) §3.5 nicht berührt (eine Aktivierung wäre ohnehin ein
  *Anheben* nach [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
- **geprüft, ohne Befund: Hard Rules ohne Treffer.** §3.3 (kein `git mv` im Diff), §3.9 (keine
  Host-Toolchain in den neuen Fällen — `sed` und `bash` laufen im gepinnten `BATS_IMAGE` bzw.
  im Mutations-Treiber), §3.10 (kein Closure-Artefakt berührt), §3.11 (die einzige neue
  Adresse ist der Register-Zeiger in `harness/README.md:79`, und das Beobachtungs-Register ist
  nach [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5 ortsfest).
- **geprüft, ohne Befund: die fünf Commit-Messages nennen ihre Kennungen.** Jede trägt das
  Rollen-Präfix `Rolle Implementation:` und eine `Bezug:`-Zeile mit `LH-*`-, `MR-*`- oder
  Hard-Rule-Referenz. Die inhaltliche Beanstandung an *einer* Message steht als N-6.
- **geprüft, ohne Befund: `272` gegenüber `270`.** Beide nennen dieselbe `# expect:`-Zusicherung
  und geben ihr am Mutations-Sensor keine zusätzliche Trennschärfe; der Zugewinn liegt darin,
  dass die **stille** Konfigurationsänderung damit als gelisteter Fall geführt wird — genau die
  Lücke, die F-1 benannt hat.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Zusage neben geänderter Ableitung bleibt stehen (**3×** in
diesem Lauf, N-1, N-4 und N-5) · Deckungs-Absatz behauptet einen Träger-Slice, den der
Lifecycle nicht führt · Zusicherung über der leeren Menge wahr · Commit-Message begründet mit
einer nicht gemessenen Unmöglichkeit

Zwei dieser Klassen führt das Beobachtungs-Register bereits; ihr Stand am Tag dieses Laufs
steht neben seinem Kommando:

```sh
ls docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/*.md | wc -l   # 15
ls docs/plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/evidence/*.md | wc -l    # 1
```

Keine Erwartungswerte — die Zähler wandern mit dem Register. **Ein Vorgang zählt einmal**
(`modul-06-roadmap.md` §Das Beobachtungs-Register): Runde 1 und Runde 2 sind derselbe Vorgang
`slice-125`. Die drei Instanzen von *Zusage neben geänderter Ableitung* aus diesem Lauf und die
zwei aus Runde 1 (F-3, F-4) gehören zusammen in **einen** Beleg, ebenso *Zusicherung über der
leeren Menge wahr* aus F-8 und N-3.

## Verdikt

**Merge-blockierend:** ja — ein HIGH und drei MEDIUM.

**Die Nacharbeit hat geliefert, was der Erst-Report verlangt hat.** Alle fünf angegangenen
Findings sind behoben, und zwar gemessen: F-1 an zwei Fällen, die beide die stille Stelle
treffen (`docs-check` bleibt grün, die benannte Zusicherung fällt), F-8 mit dem klarsten Beleg
des Laufs (`ok 6` gegen die alte Datei, `not ok 6` gegen die neue), F-6 an allen drei
Fundstellen und über beide Modi des gepinnten Werkzeugs gegengemessen. Die drei bewusst nicht
behobenen Findings sind sauber unterlassen — kein fremdes Rollen-Artefakt ist im
Implementations-Kontext angefasst worden.

**Blockierend ist, was die Nacharbeit neu erzeugt oder weiter offen gelassen hat.** N-1 ist
HIGH, weil es nicht wie F-3 nur eine Aussage betrifft, sondern das **Verhalten** eines
nächtlich laufenden Sensors: `make regelwerk-check` fährt seit der Modul-Aktivierung ein
zweites Modul mit, sein Kommentar sagt das Gegenteil, und kein Gate dieses Repos erreicht die
Stelle — `Makefile`-Rezepte liegen nach der eigenen Feststellung des Repos allein beim Review.
N-2 und N-4 sind derselbe Mechanismus wie das behobene F-3, einmal in dem Absatz, den F-2
gerade vervollständigt hat, und einmal in dem Arbeitspunkt, der die Klasse beschreibt. N-3
zeigt, dass die F-8-Klasse eine Zusicherung weiter unverändert steht und im Kopf des neuen
Falls als Wächter mitgezählt wird.

**Steering-Loop-Signal:** *Zusage neben geänderter Ableitung bleibt stehen* trifft in diesem
Slice zum fünften Mal (F-3, F-4, N-1, N-4, N-5) und im Register bei einem Stand von 15. Der
Skill-Anker „*die dritte Wiederholung derselben Klasse in einer Sitzung ist ein
Steering-Loop-Signal*" ist damit überschritten; das gehört in die Closure §7, nicht in einen
weiteren Report.

**Übergabe:** Findings gehen an den Implementer. **N-4 berührt ein Planner-Artefakt**
(`roadmap.md`, Arbeitspunkt unter *Nächste Wellen*) — wer die Zeile zieht, ist eine
Zuständigkeitsfrage nach [`AGENTS.md`](../../AGENTS.md) §3.10 und wird hier nicht entschieden;
für sie ist dieser Report das Übergabe-Artefakt. Die **Finding-Klassen** gehen zusätzlich in
die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein **Lauf-Beleg** und wird
über Läufe hinweg nicht wieder gelesen. Er ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11).
