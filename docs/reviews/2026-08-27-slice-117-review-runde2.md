# Review-Report: slice-117 (Code) — zweite Runde, 2026-08-27

**Review-Art:** **Code**, zweite Runde. Geprüft wird der Diff `9b9866b` („die Fix-Runde") gegen den
Slice-Plan, die referenzierten Anforderungen/ADRs, die Hard Rules — **und** gegen die Befunde der
ersten Runde, jeder einzeln nachgemessen statt aus der Commit-Message übernommen (Modul 10 §Drei
Review-Arten, §Vorherige Findings am gleichen Modul).

**Gegenstand:** der **committete** Diff. `git rev-parse HEAD` →
`9b9866bf4e781d41e11ec75db5749ae60e9b8a37`; `git status --porcelain=v1` → leer (vor **und** nach
allen meinen Sonden). `git show --stat 9b9866b` → **9 Dateien, 1689 insertions(+), 41
deletions(-)**: `M harness/tools/mutate.sh` (+136/−37), `M test/mutate-driver.bats` (+108/−2),
`M harness/README.md` (1 Zeile), `M test/mutations/198`, `A test/mutations/201`, `202`, `203`,
dazu die beiden Report-Dateien der ersten Runde.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-27

**Eingangs-Kontext:**

- **Diff:** Volltext gelesen (alle 9 Dateien), dazu `harness/tools/mutate.sh` in Gänze
  (1496 Zeilen), `test/mutate-driver.bats` in den geänderten Bereichen und beide Vorfassungen
  (`git show 6020941:…`, `git show 6020941^:…`).
- **Slice-Plan:**
  [slice-117](../plan/planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) — §1 Lage 1/2,
  §2 DoD (1)–(3), §3 Plan-Tabelle + Mitnahme-Liste + die **vor dem Code** entschiedenen Fragen
  A/B/C, §4 Trigger, §5 Closure-Trigger.
- **Vorherige Findings am gleichen Modul:**
  [`2026-08-27-slice-117-review.md`](2026-08-27-slice-117-review.md) (1 HIGH, 6 MEDIUM, 6 LOW,
  1 INFO) und [`2026-08-27-slice-117-verify.md`](2026-08-27-slice-117-verify.md) (6 MEDIUM aus der
  Verifikation) — beide als **Eingabe** gelesen, keine ihrer Aussagen ungeprüft übernommen. Dazu
  [`2026-08-27-slice-105-review.md`](2026-08-27-slice-105-review.md), aus dem zwei der hier
  wiederkehrenden Klassen stammen.
- **Anforderungen, gelesen als Constraint:**
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- **ADRs:** der Diff referenziert in neuen Code-Zeilen **keine** ADR-ID
  (`git show 9b9866b | grep -E '^\+' | grep -oE 'ADR-[0-9]{4}' | sort -u` → nur `ADR-0003`, und
  das steht in einer Zeile des mitcommitteten Round-1-Reports, nicht im Code). Keine superseded
  ADR im Spiel.
- **Register:** [`CO-003`](../plan/carveouts/CO-003-mutate-ohne-zeitschranke.md), Status **Aktiv**
  — sein Geltungsbereich ist die Zusage, die dieser Diff einlösen soll.
- **Hard Rules:** `AGENTS.md` §3.1, §3.2, §3.3, §3.5, §3.6, §3.7, §3.8, §3.9 — jede unten mit
  eigenem Kommando.
- **Adaptionen:**
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  (Geltungsbereich: lebende repo-eigene Markdown-Artefakte; für `.sh`-Kommentare trägt
  `AGENTS.md` §3.7),
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions).

---

## Selbst gefahren — nichts aus Commit-Message, Plan oder Auftrag übernommen

[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1: jede Zahl unten trägt das Kommando, das genau sie ausgibt, und ich habe es gefahren.
Die Zeitwerte sind Maschinen- und Cache-Zustände, **keine** Erwartungswerte. Die Commit-Message
behauptet Messwerte (167,03 s · Faktor 5,39 · 664→142 s · 80,24 · 62,04) — keine davon ist hier
übernommen.

### Bestand und Diff

| Zahl / Aussage | Kommando | Ergebnis |
|---|---|---|
| HEAD, Arbeitsbaum | `git rev-parse HEAD`; `git status --porcelain=v1` | `9b9866b`, leer |
| berührte Dateien | `git show --name-only --pretty=format: 9b9866b` | 9; **kein** `AGENTS.md`, `harness/conventions.md`, `docs/plan/adr/`, `Makefile`, `.github/workflows/ci.yml`, `roadmap.md`, **kein** Slice-Plan, **kein** `CO-003` |
| Fall-Bestand | `ls -1 test/mutations/*.sh \| wc -l` | **196** |
| `@test` in der Treiber-Datei | `grep -c '^@test' test/mutate-driver.bats` | **46** |
| `mutate.sh`-Zeilen | `wc -l < harness/tools/mutate.sh` | **1496** |
| neue Zeilen in `mutate.sh`, davon Kommentar | `git show 9b9866b -- harness/tools/mutate.sh \| grep -c '^+[^+]'`; `… \| grep -cE '^\+[[:space:]]*#'` | **132** / **71** (54 %) |
| Zeilennummer-Adressen im Fall-Bestand | `grep -lE "sed -i +['\"]?[0-9]+s/" test/mutations/*.sh \| wc -l` | **0** von 196 (war 1 von 193) |

### Die zwei Sonden aus dem Auftrag (F-1)

| Sonde | Kommando | Ergebnis |
|---|---|---|
| beide `kill`-Zeilen in `stop_workers` → `: "$pid"` | Kopie des Baums, `sed`, dann `docker run --rm --network none -v <kopie>:/code:ro -w /code bats/bats@sha256:e8f1… test/mutate-driver.bats` | **45 ok / 1 not ok**, Wanduhr **59,80 s** — `not ok 44 driver: das Einsammeln endet OHNE Hilfe von aussen` |
| die `await_workers`-Zeile aus `collect_workers` entfernt (`sed -i '918d'`) | dasselbe Kommando | **1 not ok**, Wanduhr **55,22 s** — derselbe Fall |
| Kontrolle: unveränderte Kopie | dasselbe Kommando | **46 ok / 0 not ok**, Wanduhr **15,65 s** |

### Die Zähne, je einzeln gefahren

Je Fall eine frische Kopie (`git checkout -- harness test`), Mutation angewandt, `git diff -U0`
gegen das Original, dann dasselbe `docker run … bats/bats@sha256:e8f1… test/mutate-driver.bats`:

| Fall | greift an | `not ok` | trifft den in `# expect:` benannten Wächter? |
|---|---|---|---|
| `198` (neu verankert) | genau 1 Zeile (`return 2`→`return 1`) | 1 | ja (`queue_take … QUEUE_LOCK_TRIES`) |
| `199` | genau 1 Zeile (`SECONDS - marke`) | **2** | ja — **plus** `driver: das Einsammeln endet OHNE Hilfe von aussen` |
| `200` | genau 2 Zeilen (die zwei `main`-Traps) | 1 | ja |
| `201` (neu) | genau 2 Zeilen (die zwei Worker-Traps) | 1 | ja (`ein Worker unter TERM meldet KEIN Fall-Urteil`) |
| `202` (neu) | genau 1 Zeile (`await_workers` → `:`) | 1 | ja (identisch zur Hand-Sonde oben) |
| `203` (neu) | genau 1 Zeile (`if ! require_positive_int "$STALL_SECONDS"` → `if false`) | 1 | ja |

Muster-Eindeutigkeit im Bestand, je `grep -c` über `harness/tools/mutate.sh`: `^      return 2$`
→ **1**; `  trap 'worker_on_signal INT' INT` → **1**; `  trap 'worker_on_signal TERM' TERM` →
**1**; `^  await_workers ` → **1**; `  if ! require_positive_int "$STALL_SECONDS"; then` → **1**.

### Was **keinen** Zahn hat — jede Neutralisierung gefahren

| Neutralisierung | Kommando | Ergebnis |
|---|---|---|
| `timeout "$STALL_SECONDS" ` aus `mutate.sh:628` entfernt | `docker run … bats/bats@sha256:e8f1… test/` | **187 ok / 0 not ok**, 23,83 s |
| `BERICHT_GEFAHREN=1` (`mutate.sh:1488`) → `:` | dasselbe Kommando | **187 ok / 0 not ok** |
| Zahn für „Fortschritt setzt die Zeitschranke zurueck" | `grep -rl '^# expect: driver: Fortschritt setzt die Zeitschranke zurueck$' test/mutations/ \| wc -l` | **0** |
| Wächter für den zweiten Signal-Zweig | `grep -n 'BERICHT_GEFAHREN\|nach dem Bericht\|zweites' test/mutate-driver.bats`; `grep -rn 'BERICHT_GEFAHREN' test/mutations/` | je **keine** Fundstelle |
| Wächter für den 124-Zweig des Vorlaufs | `grep -n 'ueberschritten\|Zeitschranke von\|Ueberschreitung' test/*.bats test/mutations/*.sh` | **keine** (der einzige Treffer liegt in `test/mutations/11`, anderer Gegenstand) |

### Laufzeit der bats-Stufe — dieselbe Methode über drei Ständen

Je eine vollständige Arbeitskopie des Repos (inkl. `.git`, damit der `.git`-abhängige Fall nicht
künstlich rot ist), `git checkout <rev> -- harness test`, dann
`docker run --rm --network none -v <kopie>:/code:ro -w /code bats/bats@sha256:e8f1… <ziel>`,
Wanduhr per `date +%s.%N`:

| Stand | `test/mutate-driver.bats` | `test/` (= `make test-bats`) | Fälle in `test/` |
|---|---|---|---|
| `6020941^` (vor slice-117) | **3,19 s** | **10,83 s** | 180 |
| `6020941` (erster Commit) | **9,95 s** | **18,33 s** | 184 |
| `9b9866b` (HEAD) | **15,65 s** | **23,95 s** | 187 |

### Prozess- und Signal-Mechanik der neuen `timeout`-Zeile

| Frage | Sonde | Ergebnis |
|---|---|---|
| Überleben `make`s Kinder das `timeout`? | Nachbau von `mutate.sh:628` mit `make`-Stub, dessen Rezept ein Kind startet; danach `kill -0` auf das Kind | **kind-tot** — das Kind stirbt mit |
| Kontrolle dazu | dasselbe Kind, aber `TERM` direkt an `make` statt via `timeout` | **KIND-LEBT** |
| Prozessgruppe unter dem **echten** `green_prerun` (HEAD) | `source mutate.sh`, `WORK=…`, `green_prerun test` mit `make`-Stub in eigener Session; `ps -o pid=,ppid=,pgid=` | Treiber PGID **3812728**, `make` PGID **3812737** — **getrennte** Gruppe |
| dasselbe gegen `6020941` | dieselbe Sonde, Treiber `git show 6020941:harness/tools/mutate.sh` | Treiber PGID **3812869**, `make` PGID **3812869** — **dieselbe** Gruppe |
| `kill -INT -- -<Treiber-PGID>` (das, was ein Ctrl-C im Terminal tut) | beide Sonden, Vordergrund, Default-Disposition | HEAD: **make LEBT nach Gruppen-INT** · `6020941`: **make TOT nach Gruppen-INT** |
| Kann ein echter `make`-Fehlschlag 124 liefern? | Makefile mit `x:\n\t@exit 124`, dann `make -s x` | **rc=2** (GNU Make 4.3) — auch für `@bash -c "exit 124"` |

### Der Bericht-Zweig

| Frage | Sonde | Ergebnis |
|---|---|---|
| Verdoppelt ein Signal **nach** `merge_report` den Bericht noch? | Fixture aus 2 Fällen, `merge_report 2` über dem gesourcten Treiber, dann `kill -INT $$` | **ja** — `mutate: 4 ok, 0 Befund(e) — ABGEBROCHEN` über **2** Fällen, vier Zeilen unter `2 von 2 Fall-Dateien mit Ergebnis`; Exit 130 |
| Wie groß ist das offene Fenster? | Fixture mit 196 `status.*`/`case.*.log` + 4 `draws.*`, `merge_report 196` + `report_times 196`, Wanduhr | **0,94 s** (dazu der `target_fingerprint`-Schritt dazwischen) |
| Was sagt ein zweites Signal in der `stop_workers`-Frist? | Worker, der `TERM` ignoriert; `kill -INT $$`, zweites `INT` nach 1,5 s | `mutate: zweites INT **waehrend des Berichts** — Abbruch OHNE Bericht.`, Exit 130, Wanduhr **1,52 s** — der Bericht hatte nicht begonnen |

### Die neue Vorgabe-Prüfung

`require_positive_int` isoliert gefahren:

| Eingabe | Ergebnis |
|---|---|
| `''`, `abc`, `0`, `-5`, `1.5`, `3 4`, `+5`, `0x10`, `' 5'`, `'5 '`, `1e3` | **abgelehnt** (rc=1) |
| `99999999999999999999` | abgelehnt (rc=2, Meldung von `[` auf stderr) |
| `1`, `08`, `007`, `900` | akzeptiert |

Und: `make mutate MUTATE_STALL_SECONDS=60` erreicht den Treiber. Nachbau von `Makefile:129`
(`@MUTATE_JOBS='$(MUTATE_JOBS)' bash …`) mit einem Stub, der beide Variablen ausgibt:
Kommandozeilen-Variablen **und** Umgebungsvariablen kommen beide an
(`JOBS=[2] STALL=[60]` in beiden Aufrufformen).

### Sonstiges

| Zahl / Aussage | Kommando | Ergebnis |
|---|---|---|
| `progress_count` bei I/O-Fehler | Fixture, `chmod a-r draws.1`, `progress_count` | `n + : Syntaxfehler` — leerer Wert, Abbruch der Substitution; **unverändert** gegenüber Runde 1 |
| Entstehungs-/Abwesenheits-Prosa in neuen Zeilen | `git show <rev> -- harness/tools/mutate.sh test/ \| grep -E '^\+' \| grep -icE 'frueher\|frueheste\|erste[rn]? Entwurf\|Fix-Runde\|das Review\|Vorgaenger\|Stand hier\|war leer'` | `9b9866b` → **7**, `6020941` → **5** |
| doppelt stehende Kommentar-Passage | `grep -c 'Der Worker-Trap hatte denselben Defekt' test/mutate-driver.bats` | **2** |
| `CO-003`s eigene mitwandernde Zahl | `grep -c 'timeout' harness/tools/mutate.sh` | **4** (bei `6020941`: **0**) |
| welche Deskriptoren ein Hintergrund-Prozess unter bats erbt | Mini-bats-Fall, `ls -l /proc/<pid>/fd` im gepinnten Image | `0,1,2 → /dev/null`, **`3 → pipe:[…]`**, **`4 → /tmp/bats-run-…/bats.NN.out`** |
| Wirkung, wenn 3 und 4 geschlossen werden | dieselbe entzahnte Kopie, `sleep 45 … 3>&- 4>&-` | **48,09 s** statt **59,80 s** (−11,71 s) |
| `make shell-lint` | `make shell-lint` | grün, Exit **0** |
| `make comment-claims` | `make comment-claims` | grün, **46 Datei(en), 0 Befund(e)** |
| `make docs-check` | `make docs-check` | grün, **417 Datei(en), 0 Befund(e)** |
| beide neuen `Sensor:`-Zeiger | je `grep -cF '@test "<titel>"' test/mutate-driver.bats` | **1** / **1** — beide existieren |

### Aus dem `make mutate`-Protokoll (fremde Messung, eigene Kommandos)

Ich habe `make mutate` **nicht** gestartet (Auflage 1). Aus
`/tmp/claude-1000/…/scratchpad/mutate-fix3.log` und dem Protokoll der ersten Runde
(`mutate-117.log`) mit eigenen Kommandos gezogen:

| Größe | Kommando | `mutate-117.log` (`6020941`) | `mutate-fix3.log` (`9b9866b`) |
|---|---|---|---|
| Verdikt / Wanduhr | `tail -1` | `MUTATE_SECONDS=648.70` | `MUTATE_SECONDS=744.07` |
| Fall-Arbeit gesamt | `grep 'laengster Einzelfall'` | **2315,9 s** | **2694,2 s** |
| längster Einzelfall | dasselbe | **56,20 s** (`152-cpp-lint-schichtfilter`) | **80,24 s** (`199-mutate-zeitschranke-greift-nie`) |
| `test-bats` | `sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'` | n=51, summe **990,4**, mittel **19,42**, max 36,80 | n=54, summe **1422,8** (**52,8 %**), mittel **26,35**, max **80,24** |
| `full-smoke` max | dasselbe | **56,20** | **53,71** |
| `ci-lint` | dasselbe | **0,73** | **0,64** |
| größter Grün-Vorlauf | `sed -n '/Gruen-Vorlaeufe/,/Zeit je Fall/p'`, Maximum der dritten Spalte | **110,83** | **95,26** |
| zweitteuerster Fall | `sed -n '/Zeit je Fall/,$p'` | 36,80 | **62,04 s** (`202-mutate-einsammeln-ohne-schranke`) |

---

## 1. Status der Befunde der ersten Runde — je einzeln nachgemessen

| Befund | Kategorie R1 | Status | Beleg |
|---|---|---|---|
| **F-1** `stop_workers` ohne Zahn | HIGH | **behoben** | beide Auftrags-Sonden färben `not ok 44`; `202` greift an genau einer Zeile |
| **F-2** Worker-Traps kehren zurück | MEDIUM | **behoben** | `worker_on_signal` (`:961`) verdrahtet in `:1022-1023`; `201` färbt genau `driver: ein Worker unter TERM meldet KEIN Fall-Urteil` |
| **F-3** Bericht doppelt nach Signal | MEDIUM | **teilweise** | dieselbe Sonde liefert weiter `4 ok` über 2 Fällen → **B-4** |
| **F-4** `MUTATE_STALL_SECONDS` ungeprüft | MEDIUM | **behoben** | `require_positive_int` (`:129`), Aufruf `:1322`, bats-Fall `:814`, Zahn `203`, README-Eintrag |
| **F-5** Bemessung misst, was der Code nicht misst | MEDIUM | **teilweise** | Herleitung ist jetzt strukturell richtig, ihre Zahlen sind vom eigenen Lauf überholt und ihre Tabelle kennt den Vorwärmlauf nicht → **B-6** |
| **F-6** Prosa über abwesenden Text | MEDIUM | **nicht behoben, gewachsen** | 7 neue Zeilen gegen 5 im korrigierten Commit → **B-7** |
| **F-7** Preis der neuen bats-Fälle | MEDIUM | **nicht behoben, verschärft** | 10,83 → 18,33 → **23,95 s**; `test-bats` summe 990,4 → **1422,8 s** → **B-8** |
| **F-8** zweites Ctrl-C verwirft den Bericht | LOW | **teilweise** | wird jetzt gesagt, aber mit falscher Phasen-Angabe → **B-10** |
| **F-9** `progress_count` bei I/O-Fehler | LOW | **offen** | Sonde reproduziert unverändert; `git diff 6020941 HEAD -- harness/tools/mutate.sh \| grep -c 'progress_count'` → **0** → **B-13** |
| **F-10** Zeilennummer-Adresse in `198` | LOW | **behoben** | 0 von 196 Fällen adressieren per Zeilennummer |
| **F-11** überholte Zahlen im Kommentar | LOW | **nicht behoben, wiederholt** | vier Werte, alle vom Lauf desselben Commits überholt → **B-6** |
| **F-12** Reset-Wächter ohne Zahn | LOW | **offen** | Zähl-Kommando → **0** → **B-14** |
| **F-13** `harness/README.md` unvollständig | LOW | **behoben im Umfang, eine neue Aussage ist falsch** | Schranke, `MUTATE_STALL_SECONDS` und Vorlauf-Deckung stehen jetzt dort; die Kinder-Aussage trifft für den neuen Pfad nicht zu → **B-2** |
| **F-14** `stop_workers` signalisiert eingesammelte PIDs | INFO | **offen, Charakter geändert** | der neue Zweig `:337-341` ruft `stop_workers` genau in diesem Fenster **absichtlich** → **B-15** |

---

## 2. Findings

### B-1 — Drei der sechs Reparaturen dieses Commits sind Zusagen **ohne** rot gesehenes Gegenbeispiel; jede einzeln neutralisiert, und die bats-Ebene bleibt jedes Mal vollständig grün

- **Kategorie:** HIGH
- **Quelle:** `AGENTS.md` §3.6 (Hard Rule — *„Eine Zusage … ist erst fertig, wenn benannt ist, was
  passieren müsste, damit sie bricht, und das einmal rot gesehen wurde"*; *„wer keinen Fall in
  `test/mutations/` hat, ist unbewacht"*); Plan §2 DoD (3)
- **Pfad:** `harness/tools/mutate.sh:617-636` (Schranke im Grün-Vorlauf samt 124-Zweig),
  `:337-341` + `:1488` (`BERICHT_GEFAHREN`), `:326-332` (der neue zweite Signal-Zweig)
- **Befund:** Der Commit schließt drei Befunde durch neuen Code und gibt keinem davon einen
  Sensor. **(a)** `timeout "$STALL_SECONDS" ` aus `:628` entfernt — also die Reparatur zu
  Verifikations-B-1 vollständig zurückgenommen —, und
  `docker run --rm --network none -v <kopie>:/code:ro -w /code bats/bats@sha256:e8f1… test/` meldet
  **187 ok / 0 not ok**. Der ganze 124-Zweig (`:629-636`) ist von keinem Fall berührt:
  `grep -n 'ueberschritten\|Zeitschranke von\|Ueberschreitung' test/*.bats test/mutations/*.sh`
  findet ihn nicht, und `grep -rn 'green_prerun' test/mutations/*.sh` ist leer. **(b)**
  `BERICHT_GEFAHREN=1` in `:1488` durch `:` ersetzt — die Reparatur zu F-3/B-6 — und derselbe Lauf
  meldet wieder **187 ok / 0 not ok**; weder `test/mutate-driver.bats` noch `test/mutations/`
  nennen den Namen. **(c)** Der zweite Signal-Zweig (`:328-332`) trägt eine neue Ausgabe-Zusage
  und hat keinen Fall, der sie prüft. Die Zusage in (a) steht dabei nicht nur im Kommentar
  (*„DIE SCHRANKE GILT AUCH HIER, und dieser Zweig ist der einzige Ort, an dem sie greifen MUSS
  statt zu koennen"*, `:619-620`), sondern öffentlich in `harness/README.md:70` (*„Die Schranke
  deckt auch den Grün-Vorlauf, einschließlich des Vorwärmlaufs vor dem Fork"*). Das ist dieselbe
  Klasse, die dieser Commit in seiner eigenen Message als seine Lehre führt — nur an drei neuen
  Stellen statt an einer.
- **Verifizierbar:** ja — die drei Neutralisierungen oben, je gefolgt von
  `docker run … bats/bats@sha256:e8f1… test/`; alle drei bleiben grün. Ein `make mutate`-Lauf
  fängt es nicht: ohne Fall in `test/mutations/` ist die Stelle für den Sensor nicht vorhanden.

### B-2 — Der Kommentar an der neuen `timeout`-Zeile sagt, `make`s Kinder überlebten sie; gemessen sterben sie mit, und `harness/README.md` trägt dieselbe Aussage ein zweites Mal

- **Kategorie:** MEDIUM
- **Quelle:** `AGENTS.md` §3.7 (*„Ein Kommentar beschreibt, was da ist"*); F-13-Nachfolge
- **Pfad:** `harness/tools/mutate.sh:625-626`; `harness/README.md:70`
- **Befund:** Der Kommentar lautet *„`timeout` schickt TERM an `make`; dessen Kinder ueberleben
  es, dieselbe benannte Grenze wie bei stop_workers."* Gemessen trifft das Gegenteil zu: coreutils
  `timeout` legt sich und sein Kind in eine **eigene** Prozessgruppe und signalisiert die Gruppe.
  Nachbau von `:628` mit einem `make`-Stub, dessen Rezept ein langlaufendes Kind startet: nach
  Ablauf meldet die Sonde `rc=124` und `kind-tot`. Die Kontrolle — dasselbe Kind, aber `TERM`
  direkt an `make` statt via `timeout` — meldet `KIND-LEBT`. Die im Kommentar behauptete
  Gleichsetzung mit `stop_workers` gilt also gerade **nicht**: dort überlebt das Kind (in Runde 1
  gemessen und dort als zutreffend bestätigt), hier nicht. `harness/README.md:70` schreibt
  dieselbe Aussage ohne Pfad-Einschränkung fort (*„Was sie nicht deckt, steht im Treiber: beendet
  wird der Worker, nicht dessen Kinder — ein hängendes `make` überlebt ihn"*), obwohl der Satz
  davor gerade die Vorlauf-Deckung zusagt. Wer den überlebenden Prozess sucht, den der Kommentar
  ankündigt, sucht im Vorlauf-Fall nach etwas, das es nicht gibt.
- **Verifizierbar:** ja — die zwei Sonden oben (`timeout N make-stub` gegen `TERM` an denselben
  Stub), `kill -0` auf das Enkel-Kind.

### B-3 — Die neue `timeout`-Zeile nimmt den Vorwärmlauf aus der Prozessgruppe des Treibers; ein Ctrl-C im Terminal erreicht den ersten Docker-Build seitdem nicht mehr

- **Kategorie:** MEDIUM
- **Quelle:** Plan §2 DoD (2) (der Abbruch-Pfad ist Gegenstand dieses Slice);
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); `AGENTS.md` §3.7
- **Pfad:** `harness/tools/mutate.sh:628`, wirksam für `main:1439` (Vorwärmlauf vor dem Fork) und
  `worker_main:1047`
- **Befund:** Gegen den **echten** `green_prerun` gemessen, mit `make`-Stub und in eigener
  Session, damit die Signal-Disposition die eines Vordergrund-Laufs ist: bei `9b9866b` liegt der
  Treiber in PGID **3812728**, das `make` in PGID **3812737** — `timeout` hat eine eigene
  Prozessgruppe aufgemacht. Ein `kill -INT -- -<Treiber-PGID>`, also genau das, was ein Ctrl-C im
  Terminal an die Vordergrund-Gruppe schickt, lässt das `make` **leben**
  (`ERGEBNIS: make LEBT nach Gruppen-INT`). Dieselbe Sonde gegen `git show
  6020941:harness/tools/mutate.sh`: Treiber und `make` teilen PGID **3812869**, und dasselbe
  Gruppen-INT beendet das `make` (`ERGEBNIS: make TOT nach Gruppen-INT`). Der Vorwärmlauf ist
  ausweislich des Kommentars an `:621-624` *„der erste Docker-Build des Laufs"*; wer ihn mit
  Ctrl-C abbricht, hinterlässt seit diesem Commit ein `timeout`, ein `make` und dessen
  `docker`-Aufruf als Waisen — und der Worker, der darauf steht, nimmt sein `TERM` von
  `stop_workers` erst entgegen, wenn `timeout` zurückkehrt, also nach bis zu `STALL_SECONDS`.
  Die Residuum-Aufzählung in `harness/README.md:70` (*„außerhalb bleiben ein Temp-Verzeichnis und,
  nach hartem Kill, das Lock-Verzeichnis liegen"*) kennt diesen Posten nicht.
- **Verifizierbar:** ja — die zwei Sonden oben (`green_prerun` mit `make`-Stub, `ps -o pgid=`,
  dann `kill -INT -- -<pgid>`), gegen `HEAD` und gegen `6020941`.

### B-4 — Der Wächter gegen den doppelten Bericht steht am falschen Ende: dieselbe Sonde der ersten Runde liefert weiter `4 ok` über zwei Fällen

- **Kategorie:** MEDIUM
- **Quelle:** Plan §2 DoD (2) (*„Der Bericht eines abgebrochenen Laufs sagt nichts, was seine
  eigene Fortschritts-Ausgabe widerlegt"*); `AGENTS.md` §3.6
- **Pfad:** `harness/tools/mutate.sh:1488` (`BERICHT_GEFAHREN=1`) gegen `:1473` (`merge_report`)
  und `:1487` (`report_times`); Zweig `:337-341`
- **Befund:** `BERICHT_GEFAHREN` wird **nach** `report_times` gesetzt, während die Verdopplung
  entsteht, sobald `merge_report` gezählt hat: `merge_report` und `report_times` erhöhen
  `pass_count`/`fail_count`, statt sie zu setzen. Die Sonde aus Runde 1 — Fixture aus zwei Fällen
  mit Urteil, `merge_report 2` über dem gesourcten Treiber, dann `kill -INT $$` — liefert an
  `9b9866b` unverändert: `mutate: Vollstaendigkeit — 2 von 2 Fall-Dateien mit Ergebnis`, darunter
  ein zweiter vollständiger Bericht und als Schlusszeile `mutate: 4 ok, 0 Befund(e) —
  ABGEBROCHEN, keine vollstaendige Messung.` — **vier** bestandene Fälle über **zwei**
  Fall-Dateien, in derselben Ausgabe wie die Bestätigung, dass es zwei sind. Das Fenster ist von
  „der ganze Rest des Prozesses" auf `merge_report` + `target_fingerprint` + `report_times`
  geschrumpft und damit deutlich schmaler — eigen gemessen **0,94 s** für `merge_report` +
  `report_times` über einer 196-Fall-Fixture —, aber der Fehlermodus, gegen den DoD (2) steht, ist
  in ihm unverändert erreichbar. Dass die Reparatur zugleich keinen Zahn hat, ist B-1 (b).
- **Verifizierbar:** ja — Fixture mit `case.$i.log`/`status.$i`/`draws.1` für zwei Fälle,
  `merge_report 2`, dann `kill -INT $$`: die Schlusszeile nennt die doppelte Zahl.

### B-5 — Dieselbe Zahl trägt jetzt zwei Bedeutungen: `STALL_SECONDS` begrenzt im Grün-Vorlauf die **Dauer**, während der Kommentar zwei Bildschirmseiten weiter sagt, genau das tue sie nicht — und Plan §3 Frage A hatte die Wanduhr **vor dem Code** verworfen

- **Kategorie:** MEDIUM
- **Quelle:** Plan §3 Frage A (vor dem Code entschieden); `AGENTS.md` §3.7; Reviewer-Anker
  *„Spec-Treue-Lücke einer Messmethode"*;
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **Pfad:** `harness/tools/mutate.sh:628` gegen `:832-836`; Plan §3 Frage A
- **Befund:** Der Kopf des Schranken-Blocks lautet *„STALL_SECONDS begrenzt die STILLE des Laufs,
  **nicht seine Dauer** — und das ist der ganze Entwurf"* (`:832`) und begründet das damit, dass
  eine Schranke um einen einzelnen Lauf *„je Modus verschieden sein"* müsste (`:833`). Plan §3
  Frage A hat dieselbe Wahl **vor dem Code** getroffen und beide Wanduhr-Orte ausdrücklich
  verworfen: *„Beide angebotenen Orte haben denselben Fehler: sie bemessen eine Wanduhr … Gemessen
  wird darum Stille."* `:628` installiert genau eine Wanduhr-Schranke um genau einen Modus-Lauf,
  mit derselben Zahl. Weder der Plan noch der Block-Kopf ist nachgezogen, und keine Zeile
  benennt, dass die Variable ab hier zwei Größen misst. Die Folge ist die Richtung, die Plan §4
  als **blockierende** Rückführung führt: ein Grün-Vorlauf, der Fortschritt macht, aber langsam
  ist, wird nach 900 s abgebrochen. Der Abstand ist kleiner als der, den die Herleitung ausweist —
  der größte Grün-Vorlauf im Protokoll dieses Commits ist **95,26 s**
  (`sed -n '/Gruen-Vorlaeufe/,/Zeit je Fall/p'`, Maximum der dritten Spalte), bei den im selben
  Kommentar genannten 2,4× für die CI also rund 229 s, Faktor **3,9** statt der für die Stille
  ausgewiesenen 5,39.
- **Verifizierbar:** ja — `sed -n '832,836p' harness/tools/mutate.sh` gegen `sed -n '628p'`, und
  Plan §3 Frage A; die 95,26 s mit dem `sed`-Kommando oben über dem Lauf-Protokoll.

### B-6 — Die neu geschriebene Herleitung ist von dem Lauf überholt, den derselbe Commit als seinen Beleg führt — vier Werte —, und die Tabelle, aus der sie rechnet, enthält den Vorlauf nicht, den die neue Schranke bewacht

- **Kategorie:** MEDIUM
- **Quelle:** `AGENTS.md` §3.7 (Cutoff bindet die neu geschriebene Zeile); F-5/F-11-Nachfolge
- **Pfad:** `harness/tools/mutate.sh:832-845`
- **Befund:** Der ersetzte Kommentar nennt vier Werte: *„der teuerste Fall kostet **56,20** s, ein
  ci-lint-Fall **0,73** s"*, *„eine um die Gesamtlaufzeit muesste **648,70** s hier … decken"* und
  *„gemessen **110,83 + 56,20 = 167,03** s. 900 s ist damit das **5,39**-fache"*. Alle vier stammen
  aus dem Protokoll des **korrigierten** Commits (`mutate-117.log`, `tail -1` →
  `MUTATE_SECONDS=648.70`). Das Protokoll, das die Commit-Message desselben Commits als Beleg
  führt (`mutate-fix3.log`), sagt an denselben Stellen: längster Einzelfall **80,24 s**
  (`grep 'laengster Einzelfall'`), `ci-lint` **0,64 s** und `full-smoke` max **53,71 s**
  (`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'`), Gesamtlaufzeit **744,07 s** (`tail -1`),
  größter Grün-Vorlauf **95,26 s**. Die im Kommentar **selbst angegebene** Rechenvorschrift
  („Maximum der dritten Spalte … plus der `laengster Einzelfall`-Wert") ergibt über dem eigenen
  Protokoll **95,26 + 80,24 = 175,50 s** und damit Faktor **5,13**, nicht 167,03 / 5,39. Das ist
  F-11 in derselben Zeile ein zweites Mal. Dazu kommt eine strukturelle Lücke: die
  `Gruen-Vorlaeufe`-Tabelle wird ausschließlich in `worker_main` gefüllt
  (`printf … >>"$RUN_DIR/prerun.times.$id"`, `:1056`); der **Vorwärmlauf vor dem Fork**
  (`main:1439 green_prerun test-go`) schreibt dort nichts. Die Größe, aus der die neue Schranke
  ihren Sicherheitsfaktor zieht, enthält genau den Lauf nicht, den die neue Schranke in `:628`
  bewachen soll. Und der Wert, mit dem gerechnet wird, ist inzwischen ein Artefakt dieses Slice
  selbst: der „längste Einzelfall" ist `199-mutate-zeitschranke-greift-nie` mit 80,24 s, dessen
  Kosten aus B-8 stammen.
- **Verifizierbar:** ja — die fünf Kommandos oben über `mutate-fix3.log`, gegen
  `sed -n '832,845p' harness/tools/mutate.sh`; `grep -n 'prerun.times' harness/tools/mutate.sh`
  zeigt die einzige schreibende Stelle.

### B-7 — Die Kommentar-Klasse, die Runde 1 als F-6 gemeldet hat, ist in der Fix-Runde **gewachsen**: 7 neue Zeilen gegen 5 im korrigierten Commit

- **Kategorie:** MEDIUM
- **Quelle:** `AGENTS.md` §3.7 (zweite Falsch-Klasse: *„beschreibt abwesenden Text … die vorige
  hält `git`"*); Plan §3 Mitnahme-Punkt 3; vorheriges Finding am selben Modul (F-6;
  [slice-105-review](2026-08-27-slice-105-review.md) F-9)
- **Pfad:** `harness/tools/mutate.sh:843-844`, `:906-907`, `:952-958`;
  `test/mutate-driver.bats:790-791`, `:847-848`; `test/mutations/201-…:6`,
  `test/mutations/202-…:11-12`
- **Befund:** Dieselbe Messung über beiden Commits, mit **einem** Muster:
  `git show <rev> -- harness/tools/mutate.sh test/ | grep -E '^\+' | grep -icE
  'frueher|frueheste|erste[rn]? Entwurf|Fix-Runde|das Review|Vorgaenger|Stand hier|war leer'`
  → `6020941` **5**, `9b9866b` **7**. Neu hinzugekommen sind unter anderem *„die frueher hier
  stehende Herleitung mass die kleinere der beiden Groessen"* (`:843`), *„genau so ist der erste
  Entwurf durch den Review gefallen"* (`:906`), *„Der frueheste Entwurf dieses Tests raeumte den
  Testprozess selbst weg"* (`bats:790`), *„so ist der erste Entwurf dieses Zahns durch `make
  mutate` gefallen"* (`bats:848`) sowie zwei Verweise auf Prüf-Runden in Fall-Dateien (*„der
  Zustand vor der Fix-Runde zu slice-117"*, `201:6`; *„genau der Zustand, den das Review als
  ungedeckt gemessen hat"*, `202:11-12`). Das ist Prosa über die **Entstehung des eigenen Textes**
  und über Code, den dieses Repo nicht mehr trägt — die tragende Zusage steht in jedem der Fälle
  im Satz davor. Der §3.7-Cutoff schützt den Bestand, nicht die neu geschriebene Zeile; hier
  wächst der Bestand in derselben Datei, in der der Plan ihn als Mitnahme-Posten führt, und im
  selben Commit, der den Befund darüber entgegennimmt. Insgesamt sind **71** der **132** neuen
  `mutate.sh`-Zeilen Kommentar (54 %, nach 47 % in Runde 1).
- **Verifizierbar:** ja — das Zähl-Kommando oben über beiden Revisionen.

### B-8 — Die bats-Stufe hat sich über diesen Slice **verdoppelt** (10,83 → 23,95 s), und die Ursache, die der Commit als behoben führt, ist nur zur Hälfte behoben: Hintergrund-Prozesse erben weiter die Deskriptoren 3 und 4 von bats

- **Kategorie:** MEDIUM
- **Quelle:** Maintainability + [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (Reviewer-Anker *„Reproduzierbarkeits-Risiko"*); Kontext-Eskalation (Sensor-Pfad); F-7-Nachfolge
- **Pfad:** `test/mutate-driver.bats:696`, `:718`, `:793` (`</dev/null >/dev/null 2>&1 &` ohne
  `3`/`4`), `:784-803` (`sleep 45` unter `timeout 30`)
- **Befund:** Zwei Messungen. **(a) Der Preis.** Dieselbe Methode über drei Ständen (volle
  Arbeitskopie, `git checkout <rev> -- harness test`, `docker run … bats/bats@sha256:e8f1…
  test/`): **10,83 s** (`6020941^`) → **18,33 s** (`6020941`) → **23,95 s** (`9b9866b`). Der
  Aufschlag fällt **je `test-bats`-Mutationsfall** an; im Protokoll dieses Commits steht
  `test-bats` bei **n=54, summe 1422,8 s, mittel 26,35 s** gegen **n=51, summe 990,4 s, mittel
  19,42 s** im Protokoll davor — **+432,4 s** Fall-Arbeit, während die Fall-Arbeit insgesamt nur
  um 378,3 s wuchs (2315,9 → 2694,2 s); die übrigen Sensoren wurden also billiger und die
  gesamte Zunahme liegt in dieser einen Stufe, die jetzt **52,8 %** der Fall-Arbeit trägt.
  **(b) Die halb behobene Ursache.** Die Commit-Message führt *„Mit eigenen Deskriptoren: 80,24 s
  und 62,04 s"* als Lösung des Waisen-Problems. Die neuen Zeilen leiten `0`, `1` und `2` um — aber
  ein Hintergrund-Prozess unter bats erbt zusätzlich **fd 3 (eine Pipe)** und **fd 4**: eigen
  gemessen mit einem Mini-bats-Fall, der `ls -l /proc/<pid>/fd` ausgibt (`3 -> pipe:[…]`,
  `4 -> /tmp/bats-run-…/bats.NN.out`). Auf die Pipe wartet bats. In der entzahnten Kopie (beide
  `kill`-Zeilen neutralisiert) kostet der Lauf der Treiber-Datei **59,80 s**; dieselbe Kopie mit
  `3>&- 4>&-` an der `sleep 45`-Zeile kostet **48,09 s** — **11,71 s** allein aus dem geerbten
  Kanal, obwohl `timeout 30` den Fall längst beendet hat. Genau diese Waisen machen die zwei
  teuersten Fälle des ganzen Laufs aus: `199` mit **80,24 s** und `202` mit **62,04 s**, gegen
  rund 24 s für jeden anderen `test-bats`-Fall.
- **Verifizierbar:** ja — die drei `git checkout`-Läufe für (a); für (b) der Mini-bats-Fall mit
  `ls -l /proc/<pid>/fd` und der Vergleich der entzahnten Kopie mit und ohne `3>&- 4>&-`.

### B-9 — Mutation `199` färbt seit diesem Commit **zwei** Wächter rot, benennt aber nur einen

- **Kategorie:** LOW
- **Quelle:** Maintainability; `AGENTS.md` §3.6 (die `# expect:`-Zeile ist die Zuordnung
  Mutation → Wächter)
- **Pfad:** `test/mutations/199-mutate-zeitschranke-greift-nie.sh:3` gegen
  `test/mutate-driver.bats:687` und `:784`
- **Befund:** Unter `199` meldet
  `docker run … bats/bats@sha256:e8f1… test/mutate-driver.bats` **2 `not ok`**:
  `40 driver: ein Lauf ohne Fortschritt endet an der Zeitschranke` (der benannte) und
  `44 driver: das Einsammeln endet OHNE Hilfe von aussen` (der neue, weil `collect_workers`
  dieselbe Schranke benutzt). Der Lauf bleibt grün, weil `run_case` den benannten Wächter fallen
  sieht; die Datei behauptet aber eine Eins-zu-eins-Zuordnung, die sie nicht mehr hat, und die
  Wanduhr des Falls (eigen gemessen **73,02 s** für die Treiber-Datei allein) ist zur Hälfte die
  des unbenannten zweiten Wächters. Wer `199` künftig liest, um zu erfahren, welche Zusage die
  Schranke trägt, bekommt die halbe Antwort.
- **Verifizierbar:** ja — `bash test/mutations/199-*.sh` in einer Kopie, dann der bats-Lauf: zwei
  `not ok`, einer davon nicht in `# expect:`.

### B-10 — Die neue Meldung des zweiten Signals nennt eine Phase, in der der Lauf messbar nicht ist

- **Kategorie:** LOW
- **Quelle:** `AGENTS.md` §3.7; Plan §2 DoD (2); F-8-Nachfolge
- **Pfad:** `harness/tools/mutate.sh:328-332` gegen `:297-317` (die 5-Sekunden-Schleife in
  `stop_workers`) und `:343-344` (`stop_workers` **vor** `merge_report`)
- **Befund:** Die Meldung lautet *„zweites $sig **waehrend des Berichts** — Abbruch OHNE
  Bericht."*. `on_signal` ruft `stop_workers` aber **vor** dem Bericht, und `stop_workers` wartet
  bis zu **5 s**. Sonde mit einem Worker, der `TERM` ignoriert, und einem zweiten `INT` nach
  1,5 s: Ausgabe ist `mutate: ABBRUCH — INT empfangen. Berichtet wird, was bis hierher gemessen
  ist.` gefolgt von `mutate: zweites INT waehrend des Berichts — Abbruch OHNE Bericht.`, Exit 130,
  Wanduhr **1,52 s** — der Bericht hatte nicht begonnen. Der Fortschritt gegenüber Runde 1 ist
  echt (der Bruch wird nicht mehr stillschweigend vollzogen), aber die Begründung, die der Nutzer
  liest, zeigt auf den falschen Ort: verworfen wird nicht ein laufender Bericht, sondern ein noch
  nicht begonnener, und das Fenster ist die Frist von `stop_workers`.
- **Verifizierbar:** ja — die Sonde oben; die Meldung erscheint, während der Lauf in
  `stop_workers` steht.

### B-11 — Eine Kommentar-Passage steht doppelt in der Datei, und die erste Kopie beschreibt den Test unter ihr nicht

- **Kategorie:** LOW
- **Quelle:** `AGENTS.md` §3.7 (*„Ein Kommentar beschreibt, was da ist"*)
- **Pfad:** `test/mutate-driver.bats:805-809` (verwaiste Kopie) gegen `:841-848` (die Passage an
  ihrem Ort)
- **Befund:** `grep -c 'Der Worker-Trap hatte denselben Defekt' test/mutate-driver.bats` → **2**.
  Die Kopie in `:805-809` steht zwischen dem Ende des `collect_workers`-Tests und dem Kommentar
  zum `MUTATE_STALL_SECONDS`-Test; sie beschreibt den Worker-Trap-Defekt, hat aber unter sich den
  Test zur Vorgabe-Prüfung, der damit nichts zu tun hat. Der nächste Leser bezieht sie auf den
  Test darunter — das ist genau die Wirkung, gegen die §3.7 steht.
- **Verifizierbar:** ja — das `grep -c` oben und `sed -n '805,814p' test/mutate-driver.bats`.

### B-12 — `CO-003` ist Status **Aktiv** und trägt eine als *mitwandernd* deklarierte Zahl, die jetzt gegen ihre eigene Aussage steht

- **Kategorie:** LOW
- **Quelle:**
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 (mitwandernde Zahlen); Reviewer-Anker *„Doku-Drift"*
- **Pfad:** [`docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md`](../plan/carveouts/CO-003-mutate-ohne-zeitschranke.md)
  §Geltungsbereich gegen `harness/tools/mutate.sh:628`
- **Befund:** Der Carveout sagt *„Nicht gedeckt ist hängt: `main()` wartet mit `wait "$pid"` ohne
  Zeitschranke (`grep -c 'timeout' harness/tools/mutate.sh` → **0** …, mitwandernd — `MR-025`
  Setzung 2)"*. Bei `6020941` lieferte das Kommando tatsächlich **0**, und die Verifikation hatte
  daraus (B-10) gefolgert, das Mess-Kommando sei gegen die Reparatur blind. Seit `9b9866b`
  liefert es **4** — die Zahl ist mitgewandert, der Satz daneben nicht: der Carveout behauptet
  weiterhin eine Lücke, die HEAD an zwei Stellen schließt, und belegt sie mit einer Zahl, die das
  Gegenteil sagt. Der Diff fasst `CO-003` nicht an
  (`git show --name-only --pretty=format: 9b9866b | grep -c carveouts` → 0).
- **Verifizierbar:** ja — `grep -c 'timeout' harness/tools/mutate.sh` gegen den zitierten Satz;
  `git show 6020941:harness/tools/mutate.sh | grep -c timeout` → 0 belegt den Sprung.

### B-13 — `progress_count` degradiert bei einem I/O-Fehler weiter still (F-9 unverändert)

- **Kategorie:** LOW
- **Quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (rot ohne Befund) + Maintainability
- **Pfad:** `harness/tools/mutate.sh:861-870` gegen `:885-889`
- **Befund:** `git diff 6020941 HEAD -- harness/tools/mutate.sh | grep -c 'progress_count'` → **0**
  — die Funktion ist unangetastet. Die Sonde reproduziert unverändert: Fixture mit `draws.1`,
  `chmod a-r`, dann `progress_count` → `n + : Syntaxfehler: Operator erwartet`, leerer Wert. Der
  Vergleich `"$cur" != "$last"` sieht dann zweimal denselben leeren String, die Marke bleibt
  stehen, und nach `STALL_SECONDS` meldet der Lauf *„kein Worker hat einen Fall gezogen oder
  abgeschlossen"*, während die Worker arbeiten. Seit diesem Commit endet der Lauf danach
  tatsächlich (`collect_workers` beendet die Worker), der Befund ist also nicht mehr nur eine
  Meldung, sondern ein Abbruch — die Wirkung des Falschbefunds ist damit größer als in Runde 1.
- **Verifizierbar:** ja — die Sonde oben.

### B-14 — Der Wächter „Fortschritt setzt die Zeitschranke zurueck" hat weiterhin keinen Zahn (F-12 unverändert)

- **Kategorie:** LOW
- **Quelle:** `AGENTS.md` §3.6; Plan §4 (Rückführung `in-progress` → `open`)
- **Pfad:** `test/mutate-driver.bats:709-727` gegen `test/mutations/`
- **Befund:**
  `grep -rl '^# expect: driver: Fortschritt setzt die Zeitschranke zurueck$' test/mutations/ | wc -l`
  → **0**. Alle sechs anderen Wächter dieses Slice tragen einen Fall (Zählung in der Tabelle
  oben). Der ungedeckte ist der, der die Schranke gegen **Über**-Auslösung sichert — also gegen
  das Rot ohne Befund, das Plan §4 zur blockierenden Rückführung macht. Mit B-5 hat diese
  Richtung eine zweite, ungeprüfte Auslösestelle bekommen (`:628`).
- **Verifizierbar:** ja — das Zähl-Kommando oben.

### B-15 — `stop_workers` auf eingesammelten PIDs ist jetzt ein absichtlich gebauter Pfad, nicht mehr ein Zufallsfenster

- **Kategorie:** INFO
- **Quelle:** Maintainability; F-14-Nachfolge
- **Pfad:** `harness/tools/mutate.sh:339` (`stop_workers` im `BERICHT_GEFAHREN`-Zweig) gegen
  `:915-934` (`collect_workers` hat jede PID bereits `wait`-eingesammelt) und `:284`
  (`WORKER_PIDS` wird nie geleert)
- **Befund:** Der neue Zweig läuft ausschließlich **nach** dem regulären Bericht, also nachdem
  `collect_workers` jede PID eingesammelt hat. `stop_workers` schickt dort `SIGTERM` an genau
  diese PIDs. Der `kill -0`-Test bricht die Frist sofort ab, solange keine PID existiert; existiert
  eine wieder, weil das Betriebssystem sie neu vergeben hat, trifft das Signal einen fremden
  Prozess. Runde 1 führte denselben Gegenstand als INFO über ein Fenster, das der Code nicht
  ansteuerte; jetzt steuert er es an.
- **Verifizierbar:** nein — nicht ohne PID-Wiederverwendung zu erzwingen; der Pfad ist lesbar
  (`:337-341` gegen `:1462`).

### B-16 — `timeout(1)` ist eine neue Host-Abhängigkeit des Treibers, und seine eigenen Fehlercodes werden als „der Baum ist rot" gemeldet

- **Kategorie:** INFO
- **Quelle:** [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten);
  `AGENTS.md` §3.9 (*„der Host braucht `git`, `docker` und GNU `make`, sonst nichts"*)
- **Pfad:** `harness/tools/mutate.sh:628` und `:637-646`
- **Befund:** `grep -c 'timeout' harness/tools/*.sh | grep -v ':0'` nennt genau **eine** Datei
  (`mutate.sh:4`); kein anderes Werkzeug dieses Repos ruft `timeout`. Der Treiber war bis
  `6020941` bewusst ohne es gebaut (`grep -c 'timeout' harness/tools/mutate.sh` → 0 dort; die
  Schranke benutzt `SECONDS`, `kill` und `wc`). Der Zugewinn ist klein — `sed`, `grep`, `wc`,
  `awk` stehen ohnehin in derselben Klasse —, aber die Fehlerbehandlung unterscheidet ihn nicht:
  `timeout` liefert **125** bei eigenem Fehler, **126/127**, wenn das Kommando nicht ausführbar
  bzw. nicht vorhanden ist, und **128+n**, wenn es an einem Signal starb. Alle fallen in den
  Zweig `:637`, der *„make $m ist in der isolierten Kopie ohne Mutation rot"* meldet — eine
  Diagnose über den Baum für einen Fehler des Wrappers. Der 124-Zweig selbst ist dagegen
  eindeutig: GNU Make 4.3 liefert für ein gescheitertes Rezept **2**, auch wenn das Rezept selbst
  mit 124 endet (`x:\n\t@exit 124` → `make -s x` → rc=2), ein echter Fehlschlag kann 124 also
  nicht erzeugen.
- **Verifizierbar:** ja — das `grep -c` über `harness/tools/*.sh`; das Makefile-Experiment für die
  124-Eindeutigkeit; `PATH=/nonexistent timeout …` für 127.

---

## 3. Negativbefunde

- **geprüft, ohne Befund — F-1 ist geschlossen, und zwar in genau der Form, in der Runde 1 ihn
  gemessen hat.** Beide Sonden aus dem Auftrag gefahren: mit `: "$pid"` an beiden `kill`-Zeilen
  fällt `not ok 44 driver: das Einsammeln endet OHNE Hilfe von aussen` (45 ok / 1 not ok gegen
  46 ok / 0 not ok in der Kontrolle), und mit gelöschter `await_workers`-Zeile fällt derselbe
  Fall. Der Test misst das **Enden**, nicht einen Rückgabewert: er fährt `collect_workers` unter
  `timeout 30` und verlangt `[ "$status" -ne 124 ]` sowie `worker-beendet`.
- **geprüft, ohne Befund — F-2 ist geschlossen, und der Zahn misst die Verdrahtung, nicht die
  Funktion.** `worker_on_signal` (`:961`) ist in `:1022-1023` verdrahtet; `201` ersetzt genau
  diese zwei Zeilen (`git diff -U0` zeigt zwei geänderte Zeilen, keine Streuwirkung) und färbt
  genau `driver: ein Worker unter TERM meldet KEIN Fall-Urteil`. Der Test ruft `worker_main`
  selbst mit `make`-Stub, setzt also keine eigenen Traps — die Klasse, an der der erste Entwurf
  fiel, ist hier nicht wieder aufgetreten. Der Test hängt zudem `3>&2` an das `run`, sodass sein
  Waisen-Kind den bats-Kanal nicht hält (anders als die zwei Fälle in B-8).
- **geprüft, ohne Befund — F-4 ist geschlossen, über den ganzen Weg und ohne das Repo zu
  berühren.** `require_positive_int` lehnt leer, nicht-numerisch, negativ, gebrochen, mit
  Leerzeichen, mit Vorzeichen, hexadezimal und null ab und akzeptiert `1`, `08`, `900` (Tabelle
  oben). Der bats-Fall fährt den **echten** Treiber aus einer Kopie außerhalb des Repos siebenmal
  durch; `LOCK` leitet sich aus `REPO` und damit aus dem Kopie-Ort ab (`:99`, `:113`), der Lock
  liegt also im Temp-Baum, und `git status --porcelain=v1` war vor und nach dem Lauf leer. Der
  Fall prüft beide Richtungen: die leere Vorgabe fällt auf den Default zurück, `42` kommt an der
  Schranke vorbei. Zahn `203` trifft ausschließlich die Zeit-Prüfung und lässt die Worker-Zahl
  geprüft.
- **geprüft, ohne Befund — F-10 ist geschlossen und die neuen Muster sind eindeutig.**
  `grep -lE "sed -i +['\"]?[0-9]+s/" test/mutations/*.sh | wc -l` → **0** von 196. Jedes der fünf
  neuen bzw. geänderten Muster kommt im Treiber genau **einmal** vor (Tabelle oben), und jeder
  Fall greift ausweislich `git diff -U0` an genau den Zeilen, die er meint.
- **geprüft, ohne Befund — die drei alten Zähne dieses Slice greifen weiter.** `198` (neu
  verankert), `199` und `200` färben je ihren benannten Wächter; `200` genau einen. Die
  Ausweitung bei `199` ist B-9 und kein Fehlschlag.
- **geprüft, ohne Befund — beide neuen `Sensor:`-Zeiger benennen existierende bats-Titel.**
  `mutate.sh:911` → *driver: das Einsammeln endet OHNE Hilfe von aussen* (`grep -cF '@test "…"'` →
  1); `mutate.sh:959` → *driver: ein Worker unter TERM meldet KEIN Fall-Urteil* (→ 1).
  `make comment-claims` ist grün (**46 Datei(en), 0 Befund(e)**) — es prüft die **Existenz** eines
  genannten Sensors, nicht seinen Wert; B-1 bis B-8 liegen außerhalb seiner Frage, sein Grün
  widerlegt keinen davon.
- **geprüft, ohne Befund — der 124-Zweig ist von einem echten Fehlschlag unterscheidbar.** GNU
  Make 4.3 liefert für jedes gescheiterte Rezept **2**, auch für `@exit 124` und für
  `@bash -c "exit 124"` (eigen gefahren). Ein `make`, das 124 zurückgibt, ist damit ausschließlich
  ein `timeout`-Ablauf. Was **nicht** unterschieden wird, sind `timeout`s eigene Fehlercodes —
  das ist B-16.
- **geprüft, ohne Befund — die Vorgabe erreicht den Treiber in beiden Aufrufformen.** Nachbau von
  `Makefile:129` mit einem Stub: sowohl `make ziel MUTATE_STALL_SECONDS=60` als auch
  `MUTATE_STALL_SECONDS=60 make ziel` liefern `STALL=[60]` — GNU Make exportiert
  Kommandozeilen-Variablen an Rezepte. Die fehlende Durchreich-Zeile im `Makefile` ist also kein
  Befund, und die Plan-Auflage („die Schranke steht an **einer** Stelle im Treiber, keine zweite
  Vorgabe im `Makefile`") ist eingehalten.
- **geprüft, ohne Befund — §3.1, §3.2, §3.3, §3.5, §3.8.** Kein neues `make`-Ziel, `Makefile`
  unberührt (`git show 9b9866b -- Makefile | wc -l` → 0), `mutate` bleibt außerhalb von
  `make gates`. `git show 9b9866b | grep -cE '^\+.*(nolint|shellcheck disable)'` → 1, und die eine
  Fundstelle ist eine zitierte Kommandozeile im mitcommitteten Round-1-Report, kein
  Suppression-Kommentar; `make shell-lint` ist grün und deckt `test/mutations/*.sh`.
  `git show --stat -M 9b9866b | grep -c '=>'` → 0 (kein Rename).
  `git show --pretty=format: --name-only 9b9866b | grep -cE '^(AGENTS|harness/conventions)\.md$|^docs/plan/adr/'`
  → 0 (kein Architect-Artefakt). Die Änderung hebt Zusagen an und senkt keine Schwelle — kein ADR
  nötig.
- **geprüft, ohne Befund — die „unverändert"-Zeilen der Plan-Tabelle halten alle.**
  `.github/workflows/ci.yml`, `docs/plan/adr/`, `roadmap.md` und `Makefile` sind nicht im Commit.
  Die Wachstums-Kopplung aus Plan §3 (*„wächst er, wächst die bats-Ebene mit"*) hält: `mutate.sh`
  1252 → **1496**, `@test` 39 → **46**, Fälle 190 → **196**.
- **geprüft, ohne Befund — kein Residuum aus meinem Lauf, und keine Referenz-Drift.**
  `git status --porcelain=v1` vor und nach allen Sonden leer; alle Kopien und Fixtures lagen unter
  dem Scratchpad. `make docs-check` grün (**417 Datei(en), 0 Befund(e)**), `make shell-lint` grün,
  `make comment-claims` grün.
- **geprüft, ohne Befund — §3.9 und Auflage 4 in meinem eigenen Lauf.** Nur `make`-Ziele, `git`,
  `grep`, `sed`, `awk`, `ps`, `bash`, `setsid` und `docker run` mit exakt dem digest-gepinnten
  Bild, das das `Makefile` nennt (`bats/bats@sha256:e8f1…`). Keine Host-Toolchain, kein
  Host-Paketmanager in Befehlsposition; `make mutate` habe ich nicht gestartet (Auflage 1). Jede
  Sonde hat ihre eigenen PIDs bzw. Prozessgruppen protokolliert und exakt diese beendet; die
  Abschluss-Prüfung `ps -eo pid=,ppid=,pgid=,etimes=,args= | grep -E 'sleep (3600|45|30|20)$'`
  fand **einen** Treffer, und der gehört `/snap/cups/1238/scripts/run-cups-browsed` (PPID 3921,
  seit 03:42 laufend) — **nicht** angefasst. `docker ps` ist leer.

---

## 4. Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 (B-1) |
| MEDIUM | 7 (B-2, B-3, B-4, B-5, B-6, B-7, B-8) |
| LOW | 6 (B-9, B-10, B-11, B-12, B-13, B-14) |
| INFO | 2 (B-15, B-16) |

**Bilanz gegen Runde 1:** von 14 Befunden sind **5 behoben** (F-1 HIGH, F-2, F-4, F-10, F-13 im
Umfang), **4 teilweise** (F-3, F-5, F-8, F-13), **5 offen oder verschärft** (F-6, F-7, F-9, F-12,
F-14). Die tragende Mechanik ist repariert: die zwei Sonden, an denen der erste Entwurf gefallen
ist, färben jetzt beide rot.

---

## 5. Verdikt

**Nicht formal frei — ein HIGH und sieben MEDIUM vor Merge/Closure zu klären.**

**Was trägt, trägt jetzt wirklich.** Der HIGH der ersten Runde ist geschlossen, und zwar an der
Stelle, an der er saß: `collect_workers` fasst Schranke und Einsammeln zusammen, der Test fährt das
Ganze unter `timeout` als Detektor, und beide Entzahnungen aus dem Auftrag — die `kill`-Zeilen und
der `await_workers`-Aufruf — färben denselben Fall rot. Der Worker-Trap ist getrennt, sein Zahn
misst die **Verdrahtung** und nicht die Funktion. Die neue Vorgabe ist fail-closed, teilt sich eine
Quelle mit `MUTATE_JOBS`, ist getestet, bezahnt und dokumentiert. Alle fünf neuen bzw. geänderten
Mutationen greifen an genau ihrer Zeile; die Zeilennummer-Adresse ist aus dem Bestand
verschwunden. §3.1, §3.2, §3.3, §3.5, §3.8 und §3.9 sind eingehalten.

**Der HIGH ist derselbe Satz, den dieser Commit über sich selbst schreibt.** Seine Message führt
als Lehre, dass der eigene Zahn zuerst nicht biss. Drei der sechs Reparaturen haben gar keinen: die
Schranke im Grün-Vorlauf, die Nicht-Wiederholung des Berichts und die neue Meldung des zweiten
Signals. Jede einzeln neutralisiert, und die bats-Ebene bleibt **187 ok / 0 not ok**. Für die
Vorlauf-Schranke ist das besonders schwer, weil sie nicht nur im Kommentar zugesagt ist
(*„der einzige Ort, an dem sie greifen MUSS"*), sondern in `harness/README.md` öffentlich steht —
und weil sie zugleich zwei Nebenwirkungen hat, die niemand gemessen hatte, bevor ich sie gemessen
habe: `timeout` **tötet** `make`s Kinder (der Kommentar sagt das Gegenteil, B-2) und nimmt den
ersten Docker-Build **aus der Prozessgruppe des Treibers**, sodass ein Ctrl-C ihn seit diesem
Commit nicht mehr erreicht (B-3, in beide Richtungen gegen `6020941` gemessen). Beides sind
Aussagen über den Abbruch-Pfad, also über den Gegenstand dieses Slice.

**Vier MEDIUM sind Wiederholungen.** F-3 ist nicht geschlossen, sondern verengt: die Flagge steht
hinter `report_times` statt vor `merge_report`, und dieselbe Sonde liefert weiter `4 ok` über zwei
Fällen (B-4). F-5/F-11 kehren in derselben Zeile wieder: die neu geschriebene Herleitung nennt vier
Werte, die alle aus dem Protokoll des **korrigierten** Commits stammen und vom Protokoll dieses
Commits widerlegt werden — die eigene Rechenvorschrift ergibt über dem eigenen Lauf 175,50 s und
Faktor 5,13 statt 167,03 und 5,39 —, und die Tabelle, aus der sie rechnet, enthält den
Vorwärmlauf, den die neue Schranke bewacht, überhaupt nicht (B-6). F-6 ist nicht behoben, sondern
gewachsen: 7 neue Zeilen Entstehungs-Prosa gegen 5 im korrigierten Commit, darunter zwei Verweise
auf Prüf-Runden in Fall-Dateien (B-7). F-7 ist verschärft: die bats-Stufe hat sich über diesen
Slice von 10,83 auf 23,95 s verdoppelt, `test-bats` trägt jetzt 52,8 % der Fall-Arbeit, und die
Ursache, die der Commit als behoben führt, ist es nur zur Hälfte — die neuen Zeilen schließen
`0/1/2`, aber bats wartet auf **fd 3**, gemessene 11,71 s je rotem Lauf (B-8).

**Das ist die dritte Wiederholung derselben zwei Klassen in diesem Slice** — Zusage ohne Zahn und
Kommentar über abwesenden Text. Nach `.harness/skills/reviewer.md` §Kontext-Eskalation ist das ein
Steering-Loop-Signal: die Klasse „neuer Code trägt eine Zusage, die kein `test/mutations/`-Fall
adressiert" ist in diesem Repo dreimal an derselben Datei aufgetreten und wird von keinem Gate
gesehen, weil `make mutate` nur prüft, was in `test/mutations/` **gelistet** ist. Das gehört an den
Guide, nicht an den nächsten Review.

Die sechs LOW sind Präzisions- und Abdeckungsposten (die doppelte Zuordnung von `199`, die falsche
Phasenangabe im zweiten Signal, die verwaiste Kommentar-Kopie, die stehengebliebene Zahl in
`CO-003`, `progress_count` bei I/O-Fehler, der ungedeckte Reset-Wächter) und blockieren nichts.
Zwei INFO halten fest, was benannt gehört: `stop_workers` läuft jetzt absichtlich über
eingesammelte PIDs, und `timeout(1)` ist eine neue Host-Abhängigkeit, deren eigene Fehlercodes als
„der Baum ist rot" gemeldet werden.
