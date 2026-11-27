# Review — slice-mutate-treiber-host-modi (diff ffe3c1eb..f68b15c4)

**Reviewer:** pt9912 (Typ `reviewer`, frischer Kontext) · **Datum:** 2026-11-27
**Geprüft:** 3 Implementer-Commits — (1) 372d360e Anker-Nachzug 784/785, (2) 430ecbd3
Treiber-Vertragszug + Wächter 75/76/77 + Anlagen 814/815/816, (3) f68b15c4 Sensor-Doku.
**Gegen den Plan:** `docs/plan/planning/in-progress/slice-mutate-treiber-host-modi.md` §1/§6,
`ADR-0109`, `MR-071`/`MR-090`, AGENTS.md §3.6/§3.7. Nicht geprüft: DoD-Abhakung (Verifier).

## Findings

### F-1 — LOW: der rot-Grund von Anlage 785 nennt eine zweite Hälfte, die die neue Mutation nicht färben kann

* **kategorie:** LOW
* **quelle:** AGENTS.md §3.6 (rot-gesehen-Belag je behaupteter Fall) · Skill „Mehrteilige
  Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil"
* **pfad:** `test/mutations/785-gates-fast-force-greift-nicht.sh:19-21` (`# ERWARTETER
  ROT-GRUND`)
* **befund:** Die Anlage behauptet, unter der Mutation fiele „mit ihm
  `fastpfad: GATES_FORCE=0 sagt nichts` (Exit 1 statt 0)". Die neue Anker-Form verschiebt beide
  Schalters-Vergleiche auf einen nie-wahren Literal-Vergleich (`[ ..force. = ..0. ]`), lässt
  das Verhalten bei `GATES_FORCE=0` aber byte-gleich unverändert. Bruchprobe an der realen
  Quelle: Anlage-Sed auf `harness/tools/gates-fast.sh` angewandt (diff = genau Zeilen 71 und
  118), dann `bats test/gates-fastpfad.bats --filter 'GATES_FORCE=0 sagt nichts'` → **grün**
  (`ok`), während `--filter 'GATES_FORCE=1 ueber gedecktem'` unter derselben Mutation **rot**
  fällt. Die zweite Hälfte war an die alte Ankerform gebunden (`[ "$force" = "0" ]`, die
  force=0 einfärbte) und wurde beim Nachzug inkorrekt mitgeschleppt.
* **verifizierbar:** nein — keiner der Lauf-Sensoren hält den rot-Grund-Text gegen die
  Mutation; `make mutate` hält nur den benannten `# expect:` (dessen erste Hälfte zutrifft),
  `make comment-claims` hält genannte Sensoren, nicht rot-Grund-Sätze.
* **klasse:** rot-Grund der Fall-Anlage nennt einen Wächter, den die Mutation unter der
  neuen Ankerform nicht färben kann

**Bewertung:** nicht blockierend — die Grenze der ungebundenen Hälfte ist nur die
Behauptung im Kopf; die Abdeckung selbst bleibt (der benannte Wächter fällt rot; der
`GATES_FORCE=0`-Rand bleibt im Bestand über `test/gates-fastpfad.bats:122` gebunden).
Der Kopf sollte die Zeile berichtigen, damit die MR-071-Messung des nächsten Laufs nicht
eine Hälfte liest, die die Anlage nicht einmal misst.

## Der Anker-Nachzug 784/785 an den Real-Bestand gemessen (MR-071)

| Fall | Anker | Treffer | Benannter Wächter unter Mutation |
|---|---|---|---|
| 784 | `/# gedeckt$/s@[ ..1. = ..2. ]@…` | `# gedeckt$` 1× (gates-fast.sh:60); diff = genau diese Zeile | `fehlender Key (leer) -> voller Lauf` → **rot** |
| 785 | `[ ..force. = .1. ]` | 2× (Zeilen 71 und 118 — exakt die zwei Schalters-Zeilen) | `GATES_FORCE=1 ueber gedecktem Satz` → **rot**; `GATES_FORCE=0` → grün (F-1) |

Beide Anlagen greifen wieder an der realen Quelle; die „trifft null Zeilen"-Lücke vom Claim
ist geschlossen. Kein Lücken-Silence: die `GATES_FORCE=0`-Abdeckung bleibt über den
Bestands-Test gebunden — die Beseitigung seiner Färbbarkeit **durch den Fall 785** ist keine
Abdeckungs-Lücke, nur die Behauptung im Kopf ist falsch (F-1).

## Die drei neuen Anlagen 814/815/816 — je einmal selbst rot-gesehen

Anlage an der realen Quelle im Bestand (Bruchprobe zwischen Proben per `git checkout`
restauriert, Baum danach clean), benannter Wächter vor der Mutation grün (Sanity gefahren),
unter der Mutation:

| Fall | Anker (Treffer im Bestand) | Wächter | Ausgang |
|---|---|---|---|
| 814 | `make --no-print-directory environment-check` — 1× (mutate.sh:1755) | `driver: die Umgebungs-Vorbedingung faehrt VOR Beleg-Entwertung und Isolationskopie` | **rot** (make-Protokoll-Assertion) |
| 815 | `exit 4` — 2× (Zeilen 1760, 1949, beide Umgebungs-Branches) | `driver: ein Umgebungs-Befund bricht vor …` | **rot** (`[ "$status" -eq 4 ]` failed) |
| 816 | `smoke | full-smoke) daemons=` — 1× (Zeile 1934) | `driver: fehlt der Daemon fuer einen Daemon-Modus …` | **rot** (Exit 1 statt 4) |

Alle drei Wächter fallen unter ihren Anlagen; die `# expect:`-Zeilen matchen die Testnamen
byte-genau. Die Mutation ist an der realen Quelle vollzogen, nicht an nachgebauten
Eingaben (der rot-Grund-Text von 815 sagt beide Branches — bestätigt, 2 Treffer).

## Geprüft, ohne Befund

* **Umgebungs-Vorbedingung vs. Plan §1/LP2:** der Inventar-Check steht im main-Einstieg
  vor Beleg-Lesung, Entwertung und Isolationskopie; Wächter 76 hält einen stehenden Beleg
  byte-gleich und misst via `find` keine Isolationskopie. Exit-Klasse 4 ist in der
  Sensor-Doku (`harness/sensors/mutate.md`, Exit-Tabelle + `§Umgebungs-Vorbedingung`,
  „über `make` mit 2") getragen — nicht ein neuer Exit-Vertrag ohne Doku.
* **Diagnose vom echten Check:** Wächter 76 führt die reale
  `environment-check.sh --inventar`-Zeile über eine manipulierte Inventar-Zeile
  (`go|exakt|…:99.99.0`) aus und hält die `umgebung: go · Soll: 99.99.0 · Ist:`-Zeile —
  kein nachgebauter Befund (Fixture-Erfolg verdeckt die reale Quelle nicht).
* **Daemon-Vorbedingung, Negative-Form am Bestand:** die Klassifikation
  (`case smoke|full-smoke`) färbt nur die zwei Modi; ein Fall mit `verify: test` läuft
  durch (Wächter 75, grün, Exit 0 auf diesem Host — Daemon hier gemessen: nicht erreichbar).
  Grenze zum Folge-Slice `slice-smoke-und-full-smoke-ohne-docker` ist in
  Treiber-Kommentar und Sensor-Doku benannt („Die Liste entfällt mit …").
* **Spur-Grenze:** `plan_self_contained` verlangt docker build/run je Trockenplan-Zeile;
  Trockenpläne von `test-go` (`go test -count=1 ./...`) und `test-bats` (`bats "test/"`)
  tragen kein docker → serielle Spur. Die Grenze ist am Ort benannt (Treiber-Kommentar und
  Sensor-Doku) und die Mechanik gegenüber Plan §1 nicht still erweitert
  (`plan_self_contained` unangetastet).
* **Sensor-Doku-Zeilen (f68b15c4):** Exit-Tabellen-Zeile 4, die zwei neuen Abbruch-Meldungen,
  `§Umgebungs-Vorbedingung`, Spur-Grenze — jede Aussage gegen Code oder Test gehalten;
  keine überzählige `make`-Ziele-Zeile (das `targets`-Modul urteilt im Gate).
* **Kommentar-Klassen des Diffs (§3.7):** Lock-Begründung (Kopplung), Umgebungs- und
  Daemon-Kommentare (Abgrenzung/Grenze), Go-Vorlauf-Umschreibung (Zusage in Ist-Form) —
  keine Chronik, keine verworfene Alternative, keine Befund-Kennung als Grund.

## Gates (Sensoren des Laufs)

* `make gates` — **rot (Exit 2)**, und zwar an der einzigen Stufe `docs-check-host`:
  d-check meldet **114 Befunde** über 3084 Dateien, Klassen `id-unlinked`,
  `target-missing`, `span-unclosed`, `section-cell-oversized` über den Planning-Baum
  (`done/`, `next/`, `observations/`, `welle-ohne-docker.md`, `harness/README.md`) —
  der Bestand, der vom nachgelagerten `slice-doku-nachzug-ohne-docker` (liegt in
  `next/`) nachgezogen wird. **Keiner der 114 Befunde berührt eine Datei des Diffs**
  (geprüft gegen die 8 geänderten Pfade — 0 Treffer); gegen den Claim `ffe3c1eb`
  gemessen (d-check in einem Worktree), ist die Befundmenge **byte-identisch** (114 =
  114, diff leer); der neue Review-Report selbst trägt 0 Befunde (3083 → 3084 Dateien,
  Menge unverändert). Der Gate-Rot ist Bestand vor dem Claim, nicht Arbeit dieses Slices;
  `make gates grün` (DoD) kann der Verifier darum nur über den Doku-Nachzug oder einen
  dokumentierten Carveout urteilen — Plan-vs-Gate-Spanne, nicht Review-Finding.
* Bruchproben: je Fall eine sed an der realen Quelle + gefilterter bats-Lauf
  (`bats --filter`), zwischen Proben `git checkout`; Working-Tree am Ende clean
  (`git diff --exit-code` je Datei).

## Verifier-Übergabe (vorgemerkt, nicht DoD geprüft)

* Plan §5: ein Teillauf (`MUTATE_CASES='<zwei echte Fälle>'`) docker-los **grün bis zum
  Bericht** und der Negative (manipulierte Inventar-Zeile → Umgebungs-Befund **vor der
  Isolationskopie**) — der reale Lauf.
* Die Fälle der Anlagen (784, 785, 814, 815, 816) über `make mutate-auswahl` am
  `f68b15c4`-Tip auf den `mutate/<kennung>-<sha8>`-Zweig posten (Push-Posten, hier
  nicht ausgeführt — kein push in dieser Betriebsform).
* Der Beleg-Slot verfällt mit dem Lauf-Ende (`MR-090`), nicht mit der Umgebung — der
  Beleg deckt Host-Werkzeuge ausdrücklich nicht; die Umgebungs-Vorbedingung steht vor
  dem Beleg-Übersprung (im Bestand verankert, Wächter 76).
* F-1 vor der Fall-Führung des Vollsweeps berichtigen (Kopf-Zeile der Anlage 785), sonst
  liest der nächste MR-071-Lauf eine ungedeckte rot-Grund-Hälfte.
