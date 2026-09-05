# Review Runde 4 — slice-175, die Kette vom Bedien-Einstieg bis zum Schreibvorgang

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung des HIGH-1 aus Runde 3 mit **selbst gefahrenen** Sonden **und** eine Vollständigkeits-Frage an die ganze Kette. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff d96e9df..94f2552` — ein Behebungs-Commit `94f2552` (`cmd/ai-harness-init/archive_welle_echt_test.go` neu, 216 Zeilen; `archive_welle.go` +31/−10; `harness/README.md`; `test/mutations/249`–`252`) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Runde 2** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-2.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-2.md) — 1 HIGH, 1 MEDIUM |
| **Runde 3** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-3.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-3.md) — 1 HIGH (Verdrahtung `echterEingang()`, zwei Sonden a/b) |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**`Accepted`**), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.8, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus den eigenen Reports der Runden 1–3 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht beim Befund. Wo eine Stufe **nicht** selbst gemessen wurde, steht das ausdrücklich dabei |

**Wie gemessen wurde.** Sieben Läufe von `make test-go` über einer **Kopie des Baums außerhalb
des Repos** (`tar --exclude=.git --exclude=.harness/state`, Scratch-Verzeichnis), dazu ein über
`make artifact DEST=…` gebauter Träger, der in einem leeren Scratch-Verzeichnis lief. Alle Läufe
Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9). Die Kopie ist **byte-gleich zum
HEAD-Blob** (`diff <(git show HEAD:cmd/ai-harness-init/archive_welle_echt_test.go) <kopie>` leer,
ebenso für `archive_welle.go`) — die Messungen unten gelten für `94f2552`.

**Ausgangs-Lauf, unmutiert:** `make test-go` über der Kopie meldet alle **acht** Pakete `ok`,
Exit **0**. Jedes Rot unten hebt sich gegen dieses Grün ab.

---

## Die beiden Sonden aus Runde 3 — selbst gefahren

Runde 3 nannte zwei einzeilige, **übersetzende** Änderungen an der Verdrahtung, die je eine
fail-closed-Sperre entfernten, ohne dass ein Sensor rot wurde. Beide sind hier neu angewandt.

**Sonde (a) — nicht committete Arbeit landet im Archiv-Zip statt im sauberen Move-Commit.**
Mutation: `porcelain: gitStatusPorcelain` → `func(root string) (string, error) { _, err := gitStatusPorcelain(root); return "", err }`
(identisch mit `test/mutations/250`). `make test-go` färbt rot:

```
--- FAIL: TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum (0.06s)
    archive_welle_echt_test.go:158: die Sperre [unsauber] steht nicht im Bericht:
      Sperren: keine — der schreibende Lauf liefe.
FAIL	github.com/pt9912/ai-harness-init/cmd/ai-harness-init
```

Der Fall legt den Schmutz auf **die Slice-Datei, die der Lauf bewegt**, und fährt den Träger aus
einem **Unterverzeichnis** — damit hängt er zugleich am Feld `wurzel`. Er prüft die Sperre
zuerst (`t.Fatalf`), dann Exit 3, dann die Commit-Zahl und die Abwesenheit des Ziel-Verzeichnisses.
**Sonde (a) wird gefangen.**

**Sonde (b) — ein referenzierter Review-Report wird gelöscht statt als Sperre erkannt.**
Zwei Fassungen gefahren, beide rot:

1. `dateien: gitLsFiles` → `func(root string) ([]string, error) { _, err := gitLsFiles(root); return nil, err }`
   (identisch mit `test/mutations/251`).
2. **Die Fassung, die Runde 3 wörtlich nannte** — derselbe Aufruf, **gefiltert auf `docs/`**:
   `func(root string) ([]string, error) { a, err := gitLsFiles(root); var b []string; for _, p := range a { if strings.HasPrefix(p, "docs/") { b = append(b, p) } }; return b, err }`.
   Sie ist die schärfere: der Report bleibt im Suchraum und wird weiter eingesammelt, nur der
   Verweis aus `spec/lastenheft.md` — **Rang 1** der Source Precedence, außerhalb von `docs/` —
   ist unsichtbar.

Beide färben denselben Fall rot, und die Ausgabe nennt den Schaden benannt:

```
--- FAIL: TestArchiveWelleEchtSperrtAmHaengendenVerweis (0.05s)
    archive_welle_echt_test.go:176: die Sperre [haenger] steht nicht im Bericht:
      …
      Sperren: keine — der schreibende Lauf liefe.
    archive-welle ok: welle-10
      Commit 2 (Inhalt): archiv.zip (734 Bytes), 2 Stub(s), 1 Review-Report(s) entfernt
```

**Sonde (b) wird gefangen, auch in ihrer schwächeren Form.**

Damit sind die zwei **schreibenden Abnahme-Kriterien** aus
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) §Drei Abnahme-Kriterien —
Kriterium 1 (Hänger-Wächter schließt `docs/reviews/**` nicht aus) und Kriterium 2
(Sauberkeits-Prüfung deckt untrackte Dateien) — an dem Eingang gemessen, an dem sie im Betrieb
entstehen. **HIGH-1 aus Runde 3 ist geschlossen.**

---

## Die Kette, Stufe für Stufe — und die Stufe davor

Runde 3 zählte neun Stufen und fand Stufe 4 ungewächtert. Die Zählung begann am
`main()`-Dispatch. **Vor ihm liegt eine weitere Stufe**, die der dokumentierte Bedien-Einstieg
ist und in keiner der drei Runden vorkam:

| # | Stufe | Stelle | Wächter | Sonde dieser Sitzung |
|---|---|---|---|---|
| **0** | **Bedien-Einstieg `make archive-welle`** | `Makefile:322` | **keiner** | **gefahren → grün (die Lücke)** |
| 1 | Dispatch-Zweig | `cmd/ai-harness-init/main.go:512` | `TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad`, `237` | nicht gefahren (Bestand) |
| 2 | Argument-Schnitt `os.Args[2:]` | `main.go:513` | derselbe Fall | nicht gefahren (Runde 3) |
| 3 | Wrapper `archiveWelle` → `archiveWelleMit` | `archive_welle.go:80-82` | die drei Echt-Fälle | **mittelbar gefahren** (s. u.) |
| 4 | Verdrahtung `echterEingang()`, vier Felder | `archive_welle.go:113-120` | `249`, `250`, `251` (drei von vier Feldern) | **gefahren → rot** |
| 5 | Parser gewinnt `--vorschau` | `archive_welle.go:230-231` | `246` | nicht gefahren (Runde 3) |
| 6 | Weitergabe an den Zweig | `archive_welle.go:153` | `247` | nicht gefahren (Runde 3) |
| 7 | Guard `if vorschau` | `archive_welle.go:176` | `242` | nicht gefahren (Runde 2) |
| 8 | Sperren-Logik | `internal/archive/clean.go`, `scan.go` | `232`, `233` | **mittelbar gefahren** (beide Sonden oben) |
| 9 | Schreibvorgang | `internal/archive/anwenden.go` | `243`, `245`, `252` | **mittelbar gefahren** (Ausgangs-Lauf) |

**Stufe 3 ist erreicht.** Die Mutationen an `echterEingang()` sind nur über `archiveWelle` →
`archiveWelleMit` erreichbar; dass sie rot färben, ist der Beleg, dass die Echt-Fälle den Wrapper
durchlaufen. Runde 3 hatte ihn als „von keinem Test durchlaufen" geführt.

---

## Findings

### HIGH-1 — Der dokumentierte Bedien-Einstieg `make archive-welle` nennt das Unterkommando ein zweites Mal, hält es an nichts, und sein Fehlschlag ist **Exit 0 mit Schreibzugriff**

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — eine Zusage ist fertig, wenn
  benannt ist, was sie brechen ließe, und das rot gesehen wurde) ·
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 2 (`make`-Ziel
  fährt den Träger) · Plan §2, Liefer-Punkt 3 (*„`make archive-welle` fährt den Träger, und er ist
  der einzige"*)
- **pfad:** `Makefile:322` (`@$(HOST_BIN) archive-welle "$(WELLE)"`) ·
  `cmd/ai-harness-init/main.go:512` (die erste Nennung desselben Literals) ·
  [`harness/README.md`](../../harness/README.md) (die Zusage in Prosa)
- **befund:** Das Literal `archive-welle` steht **zweimal** im Baum außerhalb der Doku, und
  nichts koppelt die beiden Stellen: `git grep -n '"archive-welle"\|archive-welle ' -- 'cmd/**/*.go' Makefile`
  nennt `Makefile:322` und die Go-Seite getrennt. Für `Makefile:322` existiert **kein** Sensor —
  kein bats-Fall nennt das Kommando (`git grep -ln "archive-welle" -- 'test/*.bats'` **leer**),
  kein Mutations-Fall fasst den Makefile an
  (`grep -ln "Makefile" test/mutations/*archive*.sh` **leer**), und `make comment-claims` hat den
  `Makefile` per Definition dauerhaft außerhalb seines Prüfbereichs
  ([`AGENTS.md`](../../AGENTS.md) §4). Keine Erwartungswerte
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  **Gemessen, nicht abgeleitet:** ein über `make artifact` gebauter Träger, in einem **leeren**
  Scratch-Verzeichnis als `ai-harness-init archive-well welle-10` gefahren (ein Buchstabe fehlt),
  endet mit **Exit 0**, druckt
  *„ai-harness-init: Bootstrap (Baseline v5.18.0 vendored + Doc-Gate + Aggregator + Durchsetzung +
  Template-Baseline) — sprach-agnostisch (doc-only Gate)."* und legt **elf** Einträge im
  Arbeitsverzeichnis an (`AGENTS.md`, `.claude`, `d-check.mk`, `.d-check.yml`, `docs`, `.harness`,
  `harness`, `Makefile`, `README.md`, `spec`, `tools`) — der Init-Pfad, nicht die Archivierung.
  Der Weg dorthin steht im Code: `main.go:505-515` trifft den `switch` nicht, `run()`
  (`main.go:117-151`) behandelt den Namen als Positionsargument, das `flag.Parse` stehen lässt,
  und ruft `bootstrap`. Genau diese Durchfall-Richtung ist der erklärte Gegenstand von
  `test/mutations/237`, dessen eigener Text sie beschreibt (*„der Init-Pfad legt ein Repo im
  Arbeitsverzeichnis an. Im Betrieb sieht das nicht nach einem Fehler aus"*) — der Wächter sitzt
  auf der **Go**-Seite des Literals und erreicht die Makefile-Seite nicht. Die **Form** dieses
  Fehlschlags ist mit diesem Slice entstanden: bis `f85e9a4` lautete die Zeile
  `@ARCHIVE_IMAGE='$(ARCHIVE_IMAGE)' bash harness/tools/archive-welle.sh "$(WELLE)"`, und ein
  Vertipper in einem **Dateipfad** schlägt laut fehl. Ein Vertipper in einem
  **Unterkommando-Namen** schlägt nicht fehl, er schreibt.
- **verifizierbar:** ja — `make artifact DEST=<dir>`, dann
  `cd <leeres verzeichnis> && <dir>/ai-harness-init archive-well welle-10; echo $?; ls -a`;
  heute Exit 0 und elf Einträge, erwartet ein Aufruf-Fehler. Ein Gate-Lauf bestätigt den Befund
  **nicht** — dass keiner ihn bestätigt, ist der Befund.
- **klasse:** Ein Literal an zwei Stellen, der Wächter nur an einer — die ungewächterte Stelle
  ist der Bedien-Einstieg

### MEDIUM-1 — Der Arbeitsbaum trägt einen unaufgelösten Merge-Konflikt in der Datei, die dieser Slice neu anlegt; `make build` sieht ihn nicht

- **kategorie:** MEDIUM
- **quelle:** Maintainability · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `cmd/ai-harness-init/archive_welle_echt_test.go:145` · `.git/MERGE_HEAD`
- **befund:** `git status -sb` meldet `## main...origin/main [voraus 1, hinterher 1]` und
  `AA cmd/ai-harness-init/archive_welle_echt_test.go`; `.git/MERGE_HEAD` steht auf `787f7e8`, der
  **vor-amend**-Fassung von `94f2552`. Die Datei trägt drei Konfliktmarker
  (`grep -c '^<<<<<<<\|^=======\|^>>>>>>>'` → **3**). Der Inhalts-Unterschied der zwei Seiten ist
  klein — zwei Kommentarzeilen (`Beiläufigkeit`/`Beilaeufigkeit`, `bewegte`/`bewegt`,
  `git diff --stat 787f7e8 94f2552` → 1 Datei, 2+/2−) —, die **Folge** ist es nicht:
  `make test-go` über dem Ist-Arbeitsbaum meldet
  `cmd/ai-harness-init/archive_welle_echt_test.go:145:1: expected declaration, found '<<'` und
  `FAIL … [setup failed]`, Exit **2**. `make compile` über demselben Baum meldet Exit **0** — die
  Build-Stufe übersetzt keine `_test.go`-Dateien und sieht den Defekt nicht. Ein Handoff, der sich
  auf `build` stützt, liest hier Grün über einem Baum, der nicht testbar ist.
- **verifizierbar:** ja — `make test-go` (rot, `setup failed`) gegen `make compile` (grün) über
  demselben Arbeitsbaum.
- **klasse:** Nicht-abgeschlossene git-Operation im Arbeitsbaum, von der Build-Stufe nicht sichtbar

### LOW-1 — Die schreibende Hälfte der Kette läuft nur mit Arbeitsverzeichnis = Repo-Wurzel, und diese Grenze steht nicht bei den anderen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Grenze*)
- **pfad:** `cmd/ai-harness-init/archive_welle.go:97-112` (die ZUSAGE/ABGRENZUNG) ·
  `cmd/ai-harness-init/archive_welle_echt_test.go:196` (der einzige durchlaufende Fall,
  Arbeitsverzeichnis `root`)
- **befund:** Die zwei Sperren-Fälle fahren den Träger aus einem **Unterverzeichnis** — der
  Kommentar an `:144-146` nennt das ausdrücklich als das, was das Feld `wurzel` trägt. Der
  **durchlaufende** Fall fährt ihn aus der Wurzel. Damit läuft die schreibende Hälfte nie aus
  einem Unterverzeichnis, und eine Verdrahtung von `schreibend`, die statt ihres Parameters das
  Arbeitsverzeichnis des Prozesses nimmt, übersetzt und bleibt grün: gemessen mit
  `schreibend: func(root string) archive.Git { _ = root; return gitSchreibend{"."} }` —
  `make test-go` alle acht Pakete `ok`, Exit **0**. Die **benannte** Zusage bricht dabei nicht:
  sie sagt, `schreibend` falle, *„sobald es den vier Operationen eine andere Wurzel gibt"*, und
  das ist wahr — mit `gitSchreibend{root + "/docs"}` fällt der Fall mit
  `Exit 1 … git mv … fatal: bad source`. Auch die Zählung in
  [`harness/README.md`](../../harness/README.md) ist ehrlich (*„drei der vier Felder … je
  einzeln"*). Was fehlt, ist die **Grenze** daneben — die Datei benennt sonst jede
  (`Rm`/`Add`/`Commit` nur im Zusammenspiel), und ein Leser nimmt aus „Feld für Feld gegen ein
  echtes Repo gemessen" mehr mit, als der eine Aufruf-Kontext trägt.
- **verifizierbar:** ja — `make test-go` nach der `gitSchreibend{"."}`-Fassung; heute grün.
- **klasse:** Deckungs-Grenze der schreibenden Hälfte auf einen Aufruf-Kontext, nicht benannt

---

## Negativbefunde — geprüft, ohne Befund

**Die zwei Sonden aus Runde 3:** oben ausgeführt, beide rot, Sonde (b) in **zwei** Fassungen.
Kein Befund.

- **Der vierte Feld-Sensor ist nicht behauptet, wo er nicht existiert.** `test/mutations/249`,
  `250` und `251` decken `wurzel`, `porcelain` und `dateien`; für `schreibend` steht kein Fall
  unter `test/mutations/`, und weder der Code-Kommentar noch
  [`harness/README.md`](../../harness/README.md) behaupten einen. Der README nennt ausdrücklich
  *„drei der vier Felder"*. Nach [`AGENTS.md`](../../AGENTS.md) §3.6 (*„gelistet heißt: wer keinen
  Fall in `test/mutations/` hat, ist unbewacht"*) ist die Lage damit korrekt beschrieben statt
  überzeichnet. Kein Befund an der Aussage; die Grenze daneben steht als LOW-1.
- **Jeder genannte Sensor existiert.** Die sechs in den neuen Kommentaren genannten Test-Namen
  lösen je auf einen `func`-Rumpf auf (`git grep -c "func <Name>(" -- '*_test.go'` je **1**), und
  die vier `# expect:`-Namen von `249`–`252` ebenso. Kein Befund.
- **Der Ausgangs-Lauf fährt den Schreibvorgang wirklich durch.** Das Grün des unmutierten Laufs
  enthält `TestArchiveWelleEchtArchiviertUndSetztZweiCommits`, und dieser Fall prüft vier
  unabhängige Wege ins Rot (Exit-Code · zwei Commits · leerer Arbeitsbaum danach · Stub-Form).
  Dass er nicht leer durchläuft, zeigen die drei Mutationen oben, die ihn bzw. seine Nachbarn
  fallen lassen. Kein Befund.
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2). Der Commit führt kein
  `//nolint`, kein `# shellcheck disable`, kein `d-check:ignore` ein
  (`git diff d96e9df..HEAD | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'` leer).
  Kein Befund.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  `git log --oneline d96e9df..HEAD -- AGENTS.md harness/conventions.md harness/conventions/ docs/plan/adr/ docs/plan/planning/ .claude/commands/ .claude/agents/`
  ist leer. Kein Befund.
- **Die neuen Kommentare tragen ihre Klasse und keine Chronik**
  ([`AGENTS.md`](../../AGENTS.md) §3.7). Die Blöcke sind als *ZUSAGE*, *ABGRENZUNG*, *GRENZE* und
  *KOPPLUNG* ausgewiesen, stehen im Indikativ und nennen weder eine Befund-Kennung noch ein
  Lauf-Protokoll (`git diff d96e9df..HEAD -- '*.go' '*.sh' Makefile | grep -nE '^\+.*(Review-Befund|hier und heute|bis slice-|frueher stand)'`
  leer). Die zwei Treffer auf `Runde [0-9]` sind **Fixture-Inhalt** der synthetischen Dateien
  (`"# Review slice-100 — Runde 1\n"`), kein Kommentar. Kein Befund.
- **Docker-only** ([`AGENTS.md`](../../AGENTS.md) §3.9). Der Commit führt keinen neuen
  Host-Aufruf ein; der neue Fall startet `git` und den Träger als Kind-Prozess **innerhalb** der
  Test-Stufe, deren Basis `git` mitbringt — belegt dadurch, dass der Ausgangs-Lauf im Container
  grün ist und die Aufbau-Schritte `t.Fatalf` tragen. Kein Befund.
- **Der Tombstone in `.d-check.yml` ist korrekt.** `harness/tools/archive-welle.sh` steht unter
  `ignore-refs` und existiert nicht mehr (`ls` schlägt fehl, entfernt in `f85e9a4`) — genau die
  Verwendung, die der Kommentar darüber beschreibt. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, `make gates`, `make mutate`,
`make full-smoke`, `make lint` über dem echten Baum, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
erreicht hat.

**Nicht neu geprüft, unverändert delegiert:** MEDIUM-3 (Zähler-Stand in §6/§8 des Slice-Plans),
MEDIUM-4 (`Stand`-Zellen im Beobachtungs-Register), MEDIUM-5 (`.claude/commands/close-welle.md`)
aus Runde 2 — alle drei Planner, vor dem `git mv` nach `done/`.

**Nicht gefahren, aus dem Bestand gelesen:** die Stufen 1, 2, 5, 6 und 7 (`237`, `246`, `247`,
`242`). Ihre `# expect:`-Namen lösen auf und die Fälle stehen; **ob** sie heute rot färben, ist in
dieser Sitzung nicht gemessen und wird hier nicht behauptet.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Ein Literal an zwei Stellen, der Wächter nur an einer — die ungewächterte Stelle ist der Bedien-Einstieg |
| **MEDIUM** | 1 | Nicht-abgeschlossene git-Operation im Arbeitsbaum, von der Build-Stufe nicht sichtbar |
| **LOW** | 1 | Deckungs-Grenze der schreibenden Hälfte auf einen Aufruf-Kontext, nicht benannt |
| **INFO** | 0 | — |

**Geschlossen aus Runde 3:** HIGH-1 — beide Sonden hier selbst gefahren, beide rot, Sonde (b)
auch in der Fassung, die dort wörtlich stand.

**Vierte Runde, und die Klasse wandert weiter dieselbe Kette entlang.** Runde 1 traf den Guard,
Runde 2 die Strecke vom Argument zum Guard, Runde 3 die Verdrahtung, Runde 4 den Aufruf **vor**
dem Argument. Das Muster ist über vier Runden stabil: gemessen wird jeweils dort, wo ein Wert als
**Parameter** ankommt, und die Stelle, an der er aus der **Außenwelt** entsteht, bleibt daneben
stehen — diesmal eine Ebene über dem Prozess, im `make`-Ziel. Für die Closure §7 ist es derselbe
Vorgang und dieselbe Kennung `BEO-025`; **ob** der Zähler-Schritt fällt und was er auslöst,
entscheidet die Closure und nicht dieser Report
(`docs/plan/planning/observations.md`).

---

## Verdikt

**Nicht freigegeben für die Verifikation.** Der Auftrag dieser Runde ist an seiner Hälfte erfüllt
und an der anderen nicht.

- **Die zwei Sonden aus Runde 3 werden real gefangen, selbst gemessen.** Sonde (a) — nicht
  committete Arbeit wandert ins Archiv-Zip — färbt
  `TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum` rot. Sonde (b) — ein referenzierter
  Review-Report verschwindet — färbt `TestArchiveWelleEchtSperrtAmHaengendenVerweis` rot, sowohl
  in der ausgelieferten Fassung `251` als auch in der schärferen, auf `docs/` gefilterten Fassung,
  die Runde 3 wörtlich nannte. Beide Sperren sind damit an dem Eingang gemessen, an dem sie im
  Betrieb entstehen, und die zwei schreibenden Abnahme-Kriterien aus
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) tragen dort einen Zahn.
  Der Seam ist gut geschnitten: der Träger läuft als Prozess, nicht als nachgebaute Verdrahtung.
- **Die Kette ist nicht lückenlos — es gibt eine Stufe vor der ersten.** Alle vier Runden haben
  am `main()`-Dispatch zu zählen begonnen. Der dokumentierte Bedien-Einstieg liegt eine Ebene
  darüber, in `Makefile:322`, und nennt das Unterkommando ein zweites Mal. Nichts hält diese
  Nennung: kein bats-Fall, kein Mutations-Fall, und `make comment-claims` hat den `Makefile`
  dauerhaft außerhalb. Der Fehlschlag ist **Exit 0** und ein unaufgeforderter Bootstrap ins
  Arbeitsverzeichnis — hier gemessen, nicht abgeleitet. Das ist dieselbe Durchfall-Richtung, für
  die `test/mutations/237` eigens existiert, nur eine Ebene höher; und die **Form** dieses
  Fehlschlags ist mit `f85e9a4` entstanden, als ein Dateipfad (laut scheiternd) durch einen
  Unterkommando-Namen (still schreibend) ersetzt wurde.
- **Der Arbeitsbaum ist nicht übergabefähig.** Ein Merge steht offen (`.git/MERGE_HEAD` auf der
  vor-amend-Fassung), die neue Test-Datei trägt Konfliktmarker, `make test-go` ist rot. Dass
  `make compile` daneben grün meldet, ist die eigentliche Beobachtung: die Build-Stufe übersetzt
  keine Test-Dateien. **Dieser Report ist deshalb geschrieben, aber nicht committet** — ein
  Commit über unaufgelösten Pfaden schlösse eine fremde git-Operation ab, und das ist weder
  Reviewer-Arbeit noch vom Auftrag gedeckt.

**Was trägt.** Der Betriebs-Eingang ist jetzt an einem echten Repo gemessen, drei der vier Felder
mit je einem dauerhaften Fall. Die Deckungs-Aussagen in `archive_welle.go` und
[`harness/README.md`](../../harness/README.md) sind gegen die Messung gehalten und zählen `drei
der vier` statt `alle vier` — die Stelle, an der bis Runde 3 *„der Compiler statt eines Tests"*
stand, nennt jetzt ihren Sensor. Kein Kommentar trägt Chronik, kein fremdes Rollen-Artefakt ist
berührt, keine Lint-Suppression ist dazugekommen.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation HIGH-1 mit dem Argument bestreiten,
ein Vertipper im `Makefile` sei kein Sensor-Gegenstand, greift der Konflikt-Pfad aus Modul 8
§Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt als Artefakt); die Herabstufung
eines Findings, weil die Implementation widerspricht, ist dort ausdrücklich der vierte, falsche
Pfad. Das Gegenbeispiel zu diesem Befund ist ein Sensor, der die zwei Nennungen des Literals
aneinander hält und rot wird, wenn sie auseinanderlaufen — nicht eine Einschätzung.
