# Review Runde 5 — slice-175, der Bedien-Einstieg und der Sensor, der ihn hält

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung des HIGH-1 aus Runde 4 mit **selbst gefahrenen** Sonden, dazu die Frage, ob nach der zehnten Stufe eine elfte steht. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git show 2b1e5da` — ein Behebungs-Commit (`cmd/ai-harness-init/main.go` +26/−1, `main_test.go` +41, `archive_welle_test.go` +47, `harness/README.md`, `test/mutations/253`–`255`, `test/unterkommando-kopplung.bats` neu) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Runde 2** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-2.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-2.md) — 1 HIGH, 1 MEDIUM |
| **Runde 3** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-3.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-3.md) — 1 HIGH (Verdrahtung `echterEingang()`) |
| **Runde 4** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-4.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-4.md) — 1 HIGH (Bedien-Einstieg `Makefile:322`), 1 MEDIUM, 1 LOW |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) (**`Accepted`**), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**`Accepted`**), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.8, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus den eigenen Reports der Runden 1–4 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht beim Befund. Wo eine Stufe **nicht** selbst gemessen wurde, steht das ausdrücklich dabei |

**Wie gemessen wurde.** Ein über `make artifact DEST=…` gebauter Träger, gefahren in leeren
Scratch-Verzeichnissen und in einem eigens gebauten sperrenfreien Fixture-Repo; dazu sieben
Sonden über einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git --exclude=.harness/state`), je mit `make test-go` bzw. `make test-bats`.
Alle Läufe Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9). Die Kopie ist
byte-gleich zum HEAD-Blob (`diff <(git show HEAD:cmd/ai-harness-init/main.go) <kopie>` leer,
ebenso für `Makefile` und `test/unterkommando-kopplung.bats`) — die Messungen gelten für
`2b1e5da`.

**Ausgangs-Läufe, unmutiert.** `make test-go` über der Kopie: alle **acht** Pakete `ok`.
`make test-bats` über der Kopie: ein einziges `not ok 127 driver: die Kopie traegt den
Sensor-Bedarf inklusive .git` — ein Artefakt der Kopie ohne `.git`, kein Befund; **`ok 211
jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()`** ist grün. Jedes Rot
unten hebt sich gegen diese zwei Grün ab.

---

## Der Fund aus Runde 4 — selbst reproduziert

Runde 4 maß am gebauten Träger: `ai-harness-init archive-well welle-10` in einem leeren
Verzeichnis endete mit **Exit 0** und **elf** Einträgen im Arbeitsverzeichnis. Derselbe Aufruf,
derselbe Weg, heute:

```
$ cd <leeres verzeichnis> && <dest>/ai-harness-init archive-well welle-10; echo $?; ls -a
Fehler: unbekanntes Argument "archive-well" — der Init-Pfad nimmt nur Flags; Unterkommandos siehe unten
ai-harness-init — bootstrappt ein Git-Repo mit dem AI-Harness-Prozess.
…
EXIT=2
.
..
```

**Exit 2, null Einträge.** Der Fund aus Runde 4 ist geschlossen, und zwar an genau dem Eingang,
an dem er gemessen wurde.

**Der echte Bedien-Einstieg, zweimal gefahren.** Nicht nur der Träger, sondern das Ziel:

- `make archive-welle` **ohne** `WELLE=` → der Träger druckt *„Fehler: archive-welle braucht
  eine `<welle-id>`"* und endet mit **2**; `git status --porcelain` danach leer.
- `make archive-welle WELLE=welle-99` (unbekannte Welle) → **vier** Sperren
  (`[ergebnisnotiz]`, `[kein-plan]`, `[untergrenze]`, `[haenger]`), Träger-Exit **3**,
  `git status --porcelain` danach leer.

---

## Die sieben Sonden dieser Sitzung

| # | Sonde | Stufe | Erwartet | Gemessen |
|---|---|---|---|---|
| 1 | die Sperre `if fs.NArg() > 0 { … }` in `run()` **ganz gelöscht** (fünf Zeilen), nicht nur die Schwelle verschoben | Init-Pfad | rot | **rot** — `TestInitPfadNimmtKeinPositionsargument` in allen drei Unterfällen, dazu `TestSubkommandoRouting_UnbekannterNameSchreibtNicht` |
| 2 | eigener Vertipper im Rezept: `archive-welle` → `archiv-welle` (andere Form als `254`) | `Makefile:322` | rot | **rot** — `not ok 211`, Meldung nennt den Namen und den heutigen Dispatch |
| 3 | **Gegenrichtung**: `case "archive-welle":` in `main.go` umbenannt, Rezept unberührt | Dispatch | rot | **rot** — `not ok 211` |
| 4a | neue `$(HOST_BIN)`-Nennung in **eigener** Zeile, Name aus einer Variablen | Kalibrierung | rot | **rot** — *„aus 5 Nennung(en) … sind 4 Name(n) gewonnen"* |
| 4b | zweite `$(HOST_BIN)`-Nennung in **derselben** Zeile, Name aus einer Variablen | Kalibrierung | rot | **grün** — s. MEDIUM-1 |
| 7 | `if welle == ""` → `if len(args) == 0` (eigene Fassung von `255`) | Parser | rot | **rot** — `TestArchiveWelleAufrufFehler/leeres_Argument` und `/nur_--vorschau` |
| 5 | das Literal `span-emit` in `.claude/settings.json` (3×) vertippt | Hook-Kanal | ? | **kein Gate wird rot** — s. MEDIUM-2 |

Sonde 1 fällt in allen drei Unterfällen an der **Exit-Code**-Prüfung (`Exit 1 … want 2`), nicht
an der Verzeichnis-Prüfung — dazu LOW-1.

---

## Die Kette, Stufe für Stufe — Stand nach `2b1e5da`

| # | Stufe | Stelle | Wächter | diese Sitzung |
|---|---|---|---|---|
| **−1** | Anweisungssatz für Schritt 4 | `.claude/commands/close-welle.md:65-79` | **keiner**, und die Datei nennt das Ziel nicht (`grep -c 'archive-welle' …` → **0**) | gemessen — Runde-1-MEDIUM-5, unverändert offen, **Planner** |
| **0** | Bedien-Einstieg `make archive-welle` | `Makefile:322` | `test/unterkommando-kopplung.bats` **+** die Sperre in `run()` | **gefahren → rot** (Sonden 2, 3, 1) |
| **0b** | das Argument `"$(WELLE)"` | `Makefile:322` | `255` für die **leere** Kennung | **gefahren → rot** (Sonde 7) |
| 1 | Dispatch-Zweig | `main.go:536` | `237` | nicht gefahren (Bestand) |
| 2 | Argument-Schnitt `os.Args[2:]` | `main.go:537` | derselbe Fall | nicht gefahren (Bestand) |
| 3 | Wrapper `archiveWelle` → `archiveWelleMit` | `archive_welle.go:80-82` | die drei Echt-Fälle | nicht gefahren (Runde 4) |
| 4 | Verdrahtung `echterEingang()`, vier Felder | `archive_welle.go:113-120` | `249`, `250`, `251` — **drei** der vier | nicht gefahren (Runde 4); `schreibend` weiter ohne Fall (`grep -ln 'schreibend:' test/mutations/*.sh` → **0**) |
| 5 | Parser gewinnt `--vorschau` | `archive_welle.go:230-231` | `246` | nicht gefahren (Runde 3) |
| 6 | Weitergabe an den Zweig | `archive_welle.go:153` | `247` | nicht gefahren (Runde 3) |
| 7 | Guard `if vorschau` | `archive_welle.go:176` | `242` | nicht gefahren (Runde 2) |
| 8 | Sperren-Logik | `internal/archive/clean.go`, `scan.go` | `232`, `233` | **mittelbar gefahren** (`make archive-welle WELLE=welle-99` → 4 Sperren) |
| 9 | Schreibvorgang | `internal/archive/anwenden.go` | `243`, `245`, `252` | **mittelbar gefahren** (Ausgangs-Lauf) |

**Eine elfte Stufe im Sinne der vier Vorrunden gibt es nicht.** Die Kette vom Bedien-Einstieg
bis zum Schreibvorgang trägt an jeder Stelle einen benannten Wächter; die zwei Ausnahmen —
Stufe −1 und das vierte Feld auf Stufe 4 — stehen seit Runde 1 bzw. Runde 4 auf dem Protokoll
und sind im Code und in [`harness/README.md`](../../harness/README.md) als Grenze benannt, nicht
verschwiegen. Was diese Runde neu findet, liegt **nicht** tiefer in der Kette, sondern **im
Sensor, der sie schließt** (MEDIUM-1) und **im Wirkungsradius der Behebung** (MEDIUM-2).

---

## Findings

### MEDIUM-1 — Die Selbst-Kalibrierung des neuen Sensors vergleicht Zeilen mit Vorkommen; eine zweite Nennung in derselben Zeile bleibt ungekoppelt und der Fall grün

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — eine Zusage ist fertig, wenn
  benannt ist, was sie brechen ließe, und das rot gesehen wurde) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `test/unterkommando-kopplung.bats:29-31` (die drei Zählungen) und `:39-47`
  (der Kalibrierungs-Zweig)
- **befund:** Der Fall zählt `nennungen` mit `grep -cE '\$\(HOST_BIN\)[[:space:]]'` — das sind
  **Zeilen** mit mindestens einem Treffer — und `gefunden` mit
  `grep -oE '…' | sed … | grep -c .` — das sind **Vorkommen**. Der Zweig darüber verspricht
  wörtlich *„jede Nennung muss einen Namen hergeben. Eine Zeile, aus der das Muster keinen
  zieht, ist eine Form, die dieser Fall nicht sieht — und ein unbewachtes Literal."* Für zwei
  Nennungen in **einer** Zeile hält das nicht. **Gemessen, nicht abgeleitet:** Zeile 322 der
  Kopie zu `@$(HOST_BIN) archive-welle "$(WELLE)" || $(HOST_BIN) $(FALLBACK)` geändert —
  `nennungen` bleibt **1**, `gefunden` ist **1**, die Gleichheit hält, und `make test-bats`
  meldet `ok 211`. Die zweite Nennung ist an nichts gekoppelt. Die Gegenprobe steht daneben:
  dieselbe unlesbare Nennung in einer **eigenen** Zeile färbt den Fall rot (*„aus 5 Nennung(en)
  von `$(HOST_BIN)` sind 4 Name(n) gewonnen"*) — die Kalibrierung wirkt also, nur nicht über
  ihrer eigenen Bezugsmenge. Kein zweiter Sensor deckt die Stelle: `shell-lint` nimmt `.bats`
  ausdrücklich aus (`Makefile:130-131`), und `make comment-claims` hat den `Makefile` dauerhaft
  außerhalb ([`AGENTS.md`](../../AGENTS.md) §4).
- **verifizierbar:** ja — die Zeile im `Makefile` zu zwei `$(HOST_BIN)`-Nennungen ändern, davon
  eine mit einem Namen aus einer Variablen, dann `make test-bats`; heute grün, erwartet rot.
- **klasse:** Selbst-Kalibrierung vergleicht zwei verschiedene Zählgrößen und deckt die Menge
  nicht ab, über die sie eine Aussage macht

### MEDIUM-2 — Die repo-weite Sperre in `run()` erreicht auch den Hook-Kanal; dort liegt dasselbe Literal aus zweiter Quelle, kein Sensor hält es, und der Fehlschlag ist jetzt ein blockierender Exit-Code

- **kategorie:** MEDIUM
- **quelle:** [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6
  (**`Accepted`**: *„Er darf einen Lauf niemals blockieren … kein blockierender Exit-Code"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Grenze*)
- **pfad:** `.claude/settings.json:70`, `:82`, `:94` · `cmd/ai-harness-init/main.go:504-527`
  (der `GRENZE`-Absatz, der aufzählt, was vor der Klemme liegt) ·
  `cmd/ai-harness-init/main.go:145-166` (die neue Sperre)
- **befund:** Die drei Hooks dieses Repos rufen den Träger **direkt** und nennen dabei das
  Literal `span-emit` — `grep -c 'ai-harness-init span-emit' .claude/settings.json` → **3**,
  `grep -c 'hooks/span-emit.sh' .claude/settings.json` → **0**, also ohne den Wrapper, den das
  **emittierte** Repo bekommt (`internal/emit/templates/enforce/span-emit.sh:39` fängt den
  Exit-Code mit `|| true` ab). Das ist dieselbe Zweitquellen-Lage, die Runde 4 für den
  `Makefile` fand; der neue Sensor erreicht sie nicht — er liest allein den `Makefile`.
  **Gemessen:** die drei Literale in der Kopie zu `span-emi` geändert; `make comment-claims`
  Exit **0**, `make test-bats` unverändert (nur das `.git`-Artefakt `not ok 127`), und kein
  bats-Fall liest die Datei (`test/span-emit-wrapper.bats` nennt sie nur in einem Kommentar
  über die **emittierte** Fassung). **Die Form des Fehlschlags hat sich mit diesem Commit
  geändert:** derselbe vertippte Name, mit einer Hook-Payload auf stdin gefahren, endet heute
  mit **Exit 2** und der Usage auf stderr (gemessen), erreicht die Exit-Klemme in `spanEmit`
  also nie. Der `GRENZE`-Absatz in `main.go` zählt auf, was vor dieser Klemme liegt — *„der
  `os.Getwd()`-Zweig unten endet mit einer Zeile auf stderr und Exit 1, und an einem Hook wäre
  das ein Beobachter, der über den Lauf mitentscheidet"* — und die Aufzählung führt das mit
  diesem Commit dazugekommene zweite Mitglied nicht.
- **verifizierbar:** ja — `make comment-claims` und `make test-bats` über einem Baum mit
  vertipptem Literal in `.claude/settings.json`; beide heute unverändert. Für die zweite Hälfte:
  `printf '{}' | <dest>/ai-harness-init span-emi; echo $?` → heute 2. Ein Gate-Lauf bestätigt
  den Befund **nicht** — dass keiner ihn bestätigt, ist der Befund.
- **klasse:** Ein Literal an zwei Stellen, der Wächter nur an einer — die ungewächterte Stelle
  ist der Hook-Kanal

### LOW-1 — Der Kommentar nennt die Verzeichnis-Prüfung „die tragende"; unter der einzigen gelisteten Mutation läuft sie nie

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 (Klasse *Zusage*)
- **pfad:** `cmd/ai-harness-init/main_test.go:603-604` (der Kommentar) und `:618-628` (die
  Verzeichnis-Prüfung)
- **befund:** Der Kommentar über `TestInitPfadNimmtKeinPositionsargument` sagt: *„Die
  Verzeichnis-Prüfung ist die tragende: Exit 2 allein bekäme man auch von einem Bootstrap, der
  unterwegs scheitert."* Die Exit-Prüfung davor ist ein `t.Fatalf`. **Gemessen:** mit
  vollständig entfernter Sperre (Sonde 1) fallen alle drei Unterfälle an eben dieser
  Exit-Prüfung — *„Exit 1 für `archive-well`, want 2"* —, der Bootstrap stirbt im Test-Container
  am fehlenden `docker`, und die Verzeichnis-Prüfung wird nie erreicht. Dasselbe gilt für
  `test/mutations/253`, den einzigen gelisteten Fall. Der Test hat damit Zähne; was kein
  Gegenbeispiel hat, ist die **Rangfolge** der zwei Prüfungen, die der Kommentar behauptet.
- **verifizierbar:** ja — `make test-go` nach `test/mutations/253`; das Rot nennt die
  Exit-Zeile, nie die Verzeichnis-Zeile.
- **klasse:** Kommentar rankt zwei Prüfungen; die Rangfolge ist unter keiner Mutation sichtbar

### INFO-1 — `make archive-welle` faltet die drei dokumentierten Exit-Codes des Trägers auf einen

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `Makefile:322` · `cmd/ai-harness-init/archive_welle.go:71-75` (die Exit-Code-Tabelle
  der Usage)
- **befund:** Der Träger unterscheidet **2** (Aufruf-Fehler), **3** (Sperre steht, nichts
  geschrieben) und **1** (Laufzeit-Fehler). Am Bedien-Einstieg kommt davon nichts an: `make
  archive-welle` ohne `WELLE=` liefert `make rc=2`, `make archive-welle WELLE=welle-99` — Träger
  **3** — ebenfalls `make rc=2` (beides gemessen). Die Unterscheidung steht nur im Text auf
  stdout. Ein Aufrufer, der die Ausgabe nicht liest, kann „Sperre" nicht von „Aufruf-Fehler"
  trennen. **Heute existiert kein solcher Aufrufer** — die Notiz steht hier, weil der eine
  Bedien-Einstieg, den [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
  Festlegung 2 vorsieht, weniger unterscheidet als die Fähigkeit dahinter.
- **verifizierbar:** ja — `make archive-welle WELLE=<unbekannt>; echo $?`.
- **klasse:** Der Bedien-Einstieg trägt weniger Unterscheidung als das Unterkommando dahinter

---

## Negativbefunde — geprüft, ohne Befund

- **Der Fund aus Runde 4 ist geschlossen.** Oben ausgeführt: Exit 2 statt Exit 0, null Einträge
  statt elf, am selben Aufruf und am selben gebauten Träger. Dazu die zwei Läufe des echten
  Ziels. Kein Befund.
- **Die Kopplung hält in beide Richtungen.** Sonde 2 (Name im Rezept vertippt) und Sonde 3
  (`case` im Dispatch umbenannt) färben denselben Fall rot, und die Meldung nennt jedes Mal den
  konkreten Namen und den heutigen Dispatch — sie ist lesbar, nicht nur rot
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Kein Befund.
- **Der neue `run()`-Guard bricht keinen bestehenden Aufrufer.** Alle Träger-Aufrufe der beiden
  Smokes übergeben entweder Flags oder `add-lang`; die Zahl ist deckungsgleich
  (`grep -cE '"\$tmpbin/ai-harness-init"' harness/tools/{full-,}smoke.sh` → **15** bzw. **1**,
  dieselbe Zahl mit `… (--|add-lang)` dahinter). Keiner reicht dem Init-Pfad ein
  Positionsargument. Keine Erwartungswerte
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Kein Befund.
- **Die unvalidierte `<welle-id>` ist fail-closed abgefangen, nicht offen.** Der Wert wird ohne
  Formprüfung zu `doneDir + "/" + b.Welle` und geht durch `filepath.Join` in ein `MkdirAll` —
  ein Traversal normalisiert also aus `docs/plan/planning/done/` heraus. **Gemessen** in einem
  eigens gebauten, **sperrenfreien** Fixture-Repo (Kontroll-Lauf: *„Sperren: keine — der
  schreibende Lauf liefe"*): `archive-welle '../../../../AUSBRUCH-ZEUGE'` bricht mit **drei**
  Sperren ab (`[ergebnisnotiz]`, `[kein-plan]`, `[kein-slice]`), und außerhalb des Fixture
  entsteht nichts. Ein Versagen ließe sich nur erzählen, wenn jemand Ergebnisnotiz, Welle-Plan
  und Slice am traversierten Ort anlegte — das ist keine Fehlbedienung, sondern deren Gegenteil.
  Kein Befund.
- **Jeder genannte Sensor existiert.** Die vier in den neuen Kommentaren genannten Test-Namen
  lösen je auf genau einen `func`-Rumpf auf (`git grep -c "func <Name>(" -- '*_test.go'` je
  **1**), und `test/mutations/253`, `254`, `255` liegen. Kein Befund.
- **Der neue bats-Fall läuft in `make gates`.** `record-gates` führt `test`, `test` führt
  `test-bats`, und das Ziel gibt dem Image das ganze `test/`-Verzeichnis — der Fall erscheint im
  Lauf als `ok 211`. Kein Befund.
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2). Der Commit führt kein
  `//nolint`, kein `# shellcheck disable`, kein `d-check:ignore` ein
  (`git diff c410a2e..2b1e5da | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'`
  leer). Kein Befund.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  `git show --name-only --pretty=format: 2b1e5da` trifft weder `AGENTS.md` noch
  `harness/conventions*`, weder `docs/plan/adr/` noch `docs/plan/planning/` noch
  `.claude/commands/`. Kein Befund.
- **Die neuen Kommentare tragen ihre Klasse.** Die Blöcke sind als *ZUSAGE* und *ABGRENZUNG*
  ausgewiesen und stehen im Indikativ. Der Satz *„dahinter legt `bootstrap()` ein Repo im
  Arbeitsverzeichnis an — mit Exit 0"* beschreibt die **Gefahr, gegen die die Sperre steht**,
  nicht eine verworfene Alternative; genau diese Benennung verlangt
  [`AGENTS.md`](../../AGENTS.md) §3.6. Kein Befund.
- **Der Arbeitsbaum ist übergabefähig.** `.git/MERGE_HEAD` existiert nicht mehr, `git status
  --porcelain` ist leer, `make docs-check` über dem echten Baum meldet **587 Datei(en), 0
  Befund(e)**. Damit ist MEDIUM-1 aus Runde 4 geschlossen. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, `make gates` als Ganzes,
`make mutate`, `make full-smoke`, `make lint`, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
erreicht hat.

**Nicht neu geprüft, unverändert delegiert:** MEDIUM-5 aus Runde 1
(`.claude/commands/close-welle.md` nennt Schritt 4 als Handarbeit und das Ziel gar nicht —
**Planner**, [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
MEDIUM-3 (Zähler-Stand in §6/§8 des Slice-Plans) und MEDIUM-4 (`Stand`-Zellen im
Beobachtungs-Register) aus Runde 2 sowie LOW-1 aus Runde 4 (Deckungs-Grenze des Feldes
`schreibend`). Für MEDIUM-5 ist der Stand hier neu gemessen und **schärfer geworden**: die
Start-Bedingung, die der Command nennt, ist eingetreten (`slice-170` liegt in
`docs/plan/planning/done/`), während der schreibende Pfad selbst noch in `in-progress/` steht —
ein Planner, der dem Text heute folgt, findet die Bedingung erfüllt und daneben eine Anleitung
zur Handarbeit, die derselbe Absatz verbietet.

**Nicht gefahren, aus dem Bestand gelesen:** die Stufen 1 bis 7 der Tabelle (`237`, `242`,
`246`, `247`, `249`–`251`). Ihre Fälle stehen und ihre `# expect:`-Namen lösen auf; **ob** sie
heute rot färben, ist in dieser Sitzung nicht gemessen und wird hier nicht behauptet.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 2 | Selbst-Kalibrierung vergleicht zwei verschiedene Zählgrößen · Ein Literal an zwei Stellen, der Wächter nur an einer (Hook-Kanal) |
| **LOW** | 1 | Kommentar rankt zwei Prüfungen; die Rangfolge ist unter keiner Mutation sichtbar |
| **INFO** | 1 | Der Bedien-Einstieg trägt weniger Unterscheidung als das Unterkommando dahinter |

**Geschlossen aus Runde 4:** HIGH-1 (Bedien-Einstieg, hier selbst reproduziert) und MEDIUM-1
(offener Merge, Arbeitsbaum jetzt sauber).

**Warum MEDIUM-1 dieser Runde nicht HIGH ist.** Die HIGH-Anker der Skill-Datei nennen den
*Stillen-Grün-Pfad in einem Gate-Skript*, und der Kalibrierungs-Zweig ist einer. Die Eskalation
unterbleibt aus einem **gemessenen** Grund, nicht aus Milde: der Restschaden ist durch die neue
Sperre in `run()` begrenzt. Ein ungekoppeltes Literal endet im Betrieb mit Exit 2 und schreibt
nichts (oben gemessen); verloren geht allein, was der Fall selbst als seinen Zweck angibt — *„er
fällt im Gate, bevor jemand `make archive-welle` ruft"*. Wer diese Einschätzung nicht teilt,
geht den Konflikt-Pfad aus Modul 8, nicht den Weg über die Kategorie.

**Fünfte Runde, und die Klasse kehrt zurück — eine Ebene höher.** Runde 1 traf den Guard,
Runde 2 die Strecke davor, Runde 3 die Verdrahtung, Runde 4 den Aufruf vor dem Argument. Runde 5
findet **keine weitere Stufe in der Kette** — sondern zweimal dieselbe alte Klasse an ihrem
Rand: einmal in der Bezugsmenge des Sensors, der die Kette schließt (MEDIUM-1), einmal im
zweiten Kanal, den derselbe Sensor nicht sieht (MEDIUM-2). Für die Closure §7 ist es derselbe
Vorgang und dieselbe Kennung `BEO-025`; **ob** der Zähler-Schritt fällt und was er auslöst,
entscheidet die Closure und nicht dieser Report
(`docs/plan/planning/observations.md`).

---

## Verdikt

**Nicht freigegeben für die Verifikation** — knapp, und aus zwei MEDIUM, nicht aus einem HIGH.

- **Die Behebung trägt.** Der Fund aus Runde 4 ist an demselben Aufruf reproduziert, an dem er
  entstand, und kippt von Exit 0 mit elf Einträgen auf Exit 2 mit null. Der echte Bedien-Einstieg
  ist zweimal gefahren und beide Male fail-closed. Die neue Kopplung hat Zähne in **beide**
  Richtungen — Rezept wie Dispatch —, die Sperre in `run()` fällt unter der schärfsten Mutation
  (vollständige Löschung), und der Fall für die leere Kennung trennt tatsächlich das leere
  Argument vom leeren Argument-Feld. Alle vier in dieser Sitzung selbst gemessen.
- **Die Kette hat keine elfte Stufe.** Zum ersten Mal über fünf Runden endet die Suche nach der
  nächsten ungewächterten Stelle ohne Fund: Stufe 0 bis 9 tragen je einen benannten Wächter, und
  die zwei offenen Punkte — der Anweisungssatz davor und das vierte Feld der Verdrahtung — sind
  auf dem Protokoll und im Text als Grenze benannt statt behauptet.
- **Was blockiert, liegt neben der Kette.** Der Sensor, der Stufe 0 schließt, kalibriert sich
  gegen eine Zählung, die nicht seine Bezugsmenge ist — hier gemessen, indem eine zweite
  ungekoppelte Nennung ihn grün ließ. Und der Wirkungsradius der Behebung reicht über den
  `archive-welle`-Kanal hinaus: derselbe vertippte Name endet im Hook-Kanal jetzt mit einem
  Exit-Code, den [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6
  ausschließt, und der `GRENZE`-Absatz, der aufzählt, was vor der Exit-Klemme liegt, führt das
  neue Mitglied nicht.

**Was trägt.** Kein Kommentar trägt Chronik, kein fremdes Rollen-Artefakt ist berührt, keine
Lint-Suppression ist dazugekommen, jeder genannte Sensor existiert, der Arbeitsbaum ist sauber
und `docs-check` grün. Die Deckungs-Aussagen in [`harness/README.md`](../../harness/README.md)
zählen weiter *drei der vier* Felder statt *alle vier* und nennen jetzt zusätzlich die zwei
Sensoren, die das Literal halten — sie beschreiben, was da ist.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation MEDIUM-2 mit dem Argument
bestreiten, der Hook-Kanal gehöre nicht zu diesem Slice, greift der Konflikt-Pfad aus Modul 8
§Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt als Artefakt); die Herabstufung
eines Findings, weil die Implementation widerspricht, ist dort ausdrücklich der vierte, falsche
Pfad. Das Gegenbeispiel zu beiden MEDIUM ist ein Sensor, der rot wird — nicht eine Einschätzung.
