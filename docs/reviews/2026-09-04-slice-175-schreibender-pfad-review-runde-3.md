# Review Runde 3 — slice-175, die Kette vom CLI-Argument bis zum Schreibvorgang

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung der Behebungen aus Runde 2 **und** eine eigene Abtastung der ganzen Strecke *Argument → Struct-Feld → Funktionsaufruf → Guard → Schreibvorgang*. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff bc8ab56..7bae326` — drei Behebungs-Commits `8135ff9` (HIGH-1: Seam `archiveWelleMit`/`laufEingang`, zwei neue Tests, `test/mutations/246`, `247`), `1a09c8f` (MEDIUM-1: der Vorlagen-Wächter fragt je Vorlage einzeln, `test/mutations/248`), `7bae326` (drei Deckungs-Aussagen in `harness/README.md`) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Runde 2** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-2.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-2.md) — 1 HIGH, 1 MEDIUM |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**`Accepted`**), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus den eigenen Reports der Runden 1 und 2 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht beim Befund. Wo eine Stufe **nicht** selbst gemessen wurde, steht das ausdrücklich dabei |

**Wie gemessen wurde.** Sieben Sonden in einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git --exclude=.harness/state`, Scratch-Verzeichnis) plus vier
End-to-End-Läufe dort gebauter Träger gegen synthetische git-Repos. Der Arbeitsbaum dieses
Repos wurde zu keinem Zeitpunkt verändert (`git status --porcelain` vor und nach den Sonden
leer). Alle Läufe Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9) — der
PreToolUse-Guard hat während dieses Laufs einmal zugeschlagen und `python3` in der
Befehlsposition abgelehnt; die betroffene Sonde lief danach über `sed`.

**Eine Vorbemerkung zur Kopie, selbst gemessen statt übernommen:** `make test-bats` meldet in
der Kopie genau einen Ausfall — `not ok 127 driver: die Kopie traegt den Sensor-Bedarf
inklusive .git` —, und zwar **auch am unmutierten Stand** (gefahren, nachdem die Kopie per
`cp` auf den Repo-Stand zurückgesetzt war). Er ist Artefakt des fehlenden `.git` und in keiner
Sonde unten ein Signal.

---

## Die Kette, Stufe für Stufe

Der Auftrag dieser Runde ist nicht „sind die zwei Befunde behoben", sondern „ist die **ganze**
Strecke bewacht". Sie hat neun Stufen. Die Spalte *Sonde dieser Sitzung* trennt, was hier
gefahren wurde, von dem, was aus dem Bestand nur gelesen ist:

| # | Stufe | Stelle | Wächter | Sonde dieser Sitzung |
|---|---|---|---|---|
| 1 | Dispatch-Zweig | `cmd/ai-harness-init/main.go:512` | `TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad`, `test/mutations/237` | nicht gefahren (Bestand) |
| 2 | Argument-Schnitt `os.Args[2:]` | `main.go:513` | derselbe Fall | **gefahren → rot** |
| 3 | Wrapper `archiveWelle` → `archiveWelleMit` | `archive_welle.go:70-72` | — | **von keinem Test durchlaufen** |
| 4 | **Verdrahtung `echterEingang()`, vier Struct-Felder** | `archive_welle.go:92-99` | — | **gefahren → grün (die Lücke)** |
| 5 | Parser gewinnt `--vorschau` | `archive_welle.go:209-210` | `TestParseArchiveWelleGewinntDenSchalterAusDemArgument`, `246` | **gefahren → rot** |
| 6 | Weitergabe an den Zweig | `archive_welle.go:132` | `TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig`, `247` | **gefahren → rot** |
| 7 | Guard `if vorschau` | `archive_welle.go:155` | `TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe`, `242` | nicht gefahren (Runde 2) |
| 8 | Sperren-Logik | `internal/archive/clean.go`, `scan.go` | `232`, `233` | nicht gefahren (Bestand) |
| 9 | Schreibvorgang | `internal/archive/anwenden.go` | `243`, `245` | nicht gefahren (Bestand) |

Stufe 3 ist der Grund für Stufe 4: Die zwei Test-Aufrufe von `archiveWelle` stehen in
`archive_welle_test.go:333` und `:345`, und **alle fünf** Argument-Felder dort
(`{}`, `{--vorschau}`, `{--bogus,welle-10}`, `{--vorschau,welle-10,welle-11}`, `{--help}`)
enden **im Parser**, bevor `e.wurzel()` läuft. Damit erreicht kein Test je die Verdrahtung.

---

## Findings

### HIGH-1 — Die Verdrahtung `echterEingang()` ist die verbliebene ungewächterte Stelle der Kette, und **beide** fail-closed-Sperren fallen durch sie nach *offen*

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — *„die Zusage auf das
  einschränken, was der Code hält"*) · [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse
  *Abgrenzung*) · [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
  Abnahme-Kriterium 1 (Hänger) und 2 (untrackter Bestand)
- **pfad:** `cmd/ai-harness-init/archive_welle.go:92-99` (die Verdrahtung) ·
  `:89-91` (die Abgrenzungs-Zusage) · `:70-72` (der Weg dorthin, von keinem Test genommen) ·
  [`harness/README.md`](../../harness/README.md) Zeile 85 (dieselbe Zusage in Prosa)
- **befund:** Die vier Felder von `laufEingang` sind die einzige Stelle, an der der
  Betriebs-Aufruf die Außenwelt bekommt, und sie stehen in keinem Test:
  `git grep -c "echterEingang" -- '*_test.go'` → **0** Dateien, ebenso
  `gitStatusPorcelain`, `gitLsFiles` und `repoWurzel` (je **0**); auch kein bats-Fall fährt
  das Unterkommando (`git grep -c "archive-welle" -- 'test/*.bats'` → **0** Dateien), und
  weder `smoke.sh` noch `full-smoke.sh` nennen es
  (`grep -c "archive-welle" harness/tools/full-smoke.sh harness/tools/smoke.sh` → je **0**).
  Keine Erwartungswerte ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  Zwei **einzeilige, übersetzende** Änderungen an dieser Verdrahtung wurden in dieser Sitzung
  gefahren; beide lassen `make test-go` (alle acht Pakete `ok`) und `make lint` (*0 issues*)
  grün und `make test-bats` unverändert:
  **(a)** `porcelain: gitStatusPorcelain` → `func(root string) (string, error) { _, err := gitStatusPorcelain(root); return "", err }`
  — `git` läuft weiter, seine Antwort wird verworfen. Der daraus gebaute Träger druckt gegen
  ein Repo mit einer **nicht committeten Änderung** *„Sperren: keine — der schreibende Lauf
  liefe."* statt der Sperre `[unsauber]` und archiviert: `rev-list --count HEAD` **1 → 3**,
  Exit **0**. Der unmutierte Träger meldet am selben Baum
  *„[unsauber] Arbeitsbaum nicht sauber (1 Aenderung(en) an getrackten Dateien)"* und Exit
  **3**. Liegt der Schmutz auf einem Slice, den der Lauf bewegt, endet die halbfertige Arbeit
  **im Archiv-Zip**, während der Move-Commit den sauberen Blob trägt
  (`git show HEAD~1:…/slice-100-a.md` ohne die Zeile,
  `unzip -p …/archiv.zip …/slice-100-a.md` mit ihr) — Archiv und Historie sagen verschiedenes,
  und `git status` ist danach leer.
  **(b)** `dateien: gitLsFiles` → derselbe Aufruf, gefiltert auf `docs/`. Damit fällt die
  Sperre `[haenger]`: Der unmutierte Träger bricht mit Exit **3** ab
  (*„ein Review-Report soll verschwinden, auf den noch verwiesen wird"*), der mutierte meldet
  *„Sperren: keine"*, löscht den Report (*„1 Review-Report(s) entfernt"*, Exit **0**) und
  lässt den Verweis in `spec/lastenheft.md` — **Rang 1** der Source Precedence — auf ein
  nicht mehr vorhandenes Ziel zeigen.
  Die zwei Sperren sind je mit einem Mutations-Fall bewacht, aber beide Fälle sitzen in der
  **Logik**: `232` mutiert `internal/archive/clean.go`, `233` mutiert
  `internal/archive/scan.go`. Der Weg aus der Außenwelt in diese Logik ist von keinem
  gedeckt. Daneben sagt `archive_welle.go:89-91` als *ABGRENZUNG*
  *„Was er zusagt, ist damit vom Compiler getragen und von keinem Test"* und
  `harness/README.md:85` denselben Satz in Prosa. Die **Prämisse** stimmt und ist geprüft —
  die vier Feld-Signaturen sind paarweise verschieden, eine Vertauschung übersetzt nicht. Der
  **Schluss** stimmt nicht: die Zusage der Verdrahtung ist, dass die Felder die echten
  Betriebs-Implementierungen tragen, und ein Defekt, der keine Vertauschung ist, übersetzt
  sehr wohl. Die Lücke ist damit benannt, ihre Begründung aber ist die, die das Testen
  entbehrlich erscheinen lässt.
- **verifizierbar:** ja — `make test-go` und `make lint` nach
  `sed -i 's|^\t\tporcelain:  gitStatusPorcelain,$|\t\tporcelain:  func(root string) (string, error) { _, err := gitStatusPorcelain(root); return "", err },|' cmd/ai-harness-init/archive_welle.go`;
  heute beide grün, erwartet rot. Für (b) dieselben zwei Ziele nach der Filter-Fassung von
  `dateien`.
- **klasse:** Sperren-Eingang an der Verdrahtung ungewächtert — Logik und Parameter sind
  gedeckt, die Strecke aus der Außenwelt in beide nicht (`BEO-025`, Sensor-Variante)

---

## Negativbefunde — geprüft, ohne Befund

**Die zwei Befunde der Runde 2 — beide mit ihrem eigenen Gegenbeispiel nachgemessen:**

- **HIGH-1 aus Runde 2 ist geschlossen, auf beiden neuen Stufen.**
  `bash test/mutations/246-…` (der Parser gewinnt den Wert nicht mehr) färbt `make test-go`
  rot: `--- FAIL: TestParseArchiveWelleGewinntDenSchalterAusDemArgument` **und**
  `--- FAIL: TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig`, Paket
  `cmd/ai-harness-init` `FAIL`. `bash test/mutations/247-…` (der geparste Wert erreicht den
  Zweig umgekehrt) färbt rot: `--- FAIL: TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig`
  **und** `--- FAIL: TestArchiveWelleOhneSchalterSchreibtAmSelbenArgumentFeld`. Dass die
  jeweilige Gegenprobe mitfällt, ist die Eigenschaft, die den Fall vor dem wirkungslosen Grün
  schützt. Der Vorschau-Schalter trägt damit alle **drei** Stufen seiner Strecke. Kein Befund.
- **MEDIUM-1 aus Runde 2 ist geschlossen.** `bash test/mutations/248-…` benennt den
  Archiv-Zeiger in **genau einer** der zwei vendored Vorlagen um (danach
  `grep -c "abgelegt/<welle-id>"` → **1** in der Welle-Vorlage, **0** in der Slice-Vorlage).
  `make test-bats` meldet `not ok 19 jeder Platzhalter steht in genau der Vorlage, die sein
  Block fuellt`, während `ok 18` (die Extraktions-Deckung) und `ok 20` stehen bleiben. Die
  Quantifizierung geht jetzt je Datei. Kein Befund.

**Die übrigen Stufen der Kette:**

- **Der Argument-Schnitt im Dispatch ist bewacht.** `os.Args[2:]` → `os.Args[1:]` in
  `main.go:513` färbt `make test-go` rot:
  `--- FAIL: TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad`. Der Fall erwartet
  Exit 2 für ein Argument-Feld ohne Kennung; unter der Mutation wird `archive-welle` selbst
  zur Kennung und der Lauf endet anders. Kein Befund.
- **Stufe 1, 7, 8 und 9 sind aus dem Bestand gelesen, nicht hier gefahren** — `237` (Routing),
  `242` (Guard, in Runde 2 rot gesehen), `232`/`233` (Sperren-Logik), `243`/`245`
  (Schreibvorgang). Ihre `# expect:`-Namen lösen auf, und die Fälle stehen; **ob** sie heute
  rot färben, ist in dieser Sitzung nicht gemessen und wird hier nicht behauptet.

**Was der Behebungs-Diff sonst berührt:**

- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2). Die drei Commits führen
  kein `//nolint`, kein `# shellcheck disable` und kein `d-check:ignore` ein
  (`git diff bc8ab56..7bae326 | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'`
  leer). Kein Befund.
- **Docker-only** ([`AGENTS.md`](../../AGENTS.md) §3.9). Kein neuer Host-Aufruf; die zwei
  neuen Go-Tests laufen über `t.TempDir()`, die Attrappe `gitStumm` und `attrappenEingang` —
  ohne Repo und ohne `git`. Kein Befund.
- **Die Abgrenzung des Datei-Kopfes ist in ihrer eigenen Richtung korrekt.**
  `archive_welle.go:24-29` sagt, die vier **schreibenden** git-Aufrufe liefen in keinem Test;
  das stimmt und ist benannt. Sie ist keine Vollständigkeits-Aussage über die untestete
  Fläche der Datei — die lesende Hälfte nennt der Kommentar an `:89-91` getrennt. Kein Befund
  an der Form; der Befund oben liegt in der *Begründung* dort, nicht in der Nennung.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Die drei
  Commits berühren `AGENTS.md`, `harness/conventions*`, `docs/plan/adr/`,
  `docs/plan/planning/` und `.claude/commands/` nicht
  (`git log --oneline bc8ab56..7bae326 -- AGENTS.md harness/conventions.md harness/conventions/ docs/plan/adr/ docs/plan/planning/ .claude/commands/`
  leer). Kein Befund.

**Weiter offen und korrekt delegiert (unverändert aus Runde 2, hier nicht neu geprüft):**
MEDIUM-3 (Zähler-Stand in §6/§8 des Slice-Plans), MEDIUM-4 (`Stand`-Zellen im
Beobachtungs-Register), MEDIUM-5 (`.claude/commands/close-welle.md`) — alle drei Planner,
vor dem `git mv` nach `done/`.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, der Stand von `make gates`,
`make mutate` und `make full-smoke` über dem echten Baum, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren
Acceptance-Trigger erreicht hat.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Sperren-Eingang an der Verdrahtung ungewächtert — Logik und Parameter gedeckt, die Strecke aus der Außenwelt nicht |
| **MEDIUM** | 0 | — |
| **LOW** | 0 | — |
| **INFO** | 0 | — |

**Behoben aus Runde 2:** HIGH-1 und MEDIUM-1 — je mit dem Gegenbeispiel nachgemessen, das
dort grün blieb, und beide fallen samt ihrer Gegenprobe.

**Dritte Runde, dritte Nachbarschaft derselben Klasse.** `BEO-025` trägt jetzt in diesem
Slice drei Befunde, und sie wandern **die Kette entlang**: Runde 1 traf den Guard, Runde 2 die
Strecke vom Argument zum Guard, Runde 3 die Verdrahtung, aus der die *anderen* Eingänge
desselben Zweigs kommen. Das Muster ist stabil genug, um benannt zu werden: gemessen wird
jeweils dort, wo ein Wert als **Parameter** ankommt, und die Stelle, an der er aus der
**Außenwelt** entsteht, bleibt daneben stehen. Für die Closure §7 ist es derselbe Vorgang und
dieselbe Kennung; **ob** der Zähler-Schritt fällt und was er auslöst, entscheidet die Closure
und nicht dieser Report. Nach
[`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation ist die
dritte Wiederholung derselben Klasse in einer Sitzung ein Steering-Loop-Signal — über drei
Review-Runden hinweg ist es dasselbe Signal, nur langsamer.

---

## Verdikt

**Die Kette ist nicht lückenlos gewächtert, und die Lücke ist gemessen, nicht abgeleitet.**
Acht der neun Stufen tragen einen Wächter; Stufe 4 — die Verdrahtung `echterEingang()` —
trägt keinen, und Stufe 3 ist der Grund, warum kein Test sie erreicht.

- **HIGH-1 blockiert ohne Abweichung.** Zwei einzeilige, **übersetzende** Änderungen an dieser
  Verdrahtung nehmen dem Unterkommando je eine seiner beiden fail-closed-Sperren — die
  Sauberkeits-Prüfung und den Hänger-Schutz —, und beide laufen durch `make test-go`,
  `make lint` und `make test-bats`. Die daraus gebauten Träger drucken *„Sperren: keine — der
  schreibende Lauf liefe."* und schreiben danach zwei Commits in einen versionierten Baum: im
  einen Fall wandert nicht committete Arbeit ins Archiv-Zip, während der Move-Commit den
  sauberen Blob trägt; im anderen verschwindet ein Review-Report, auf den
  `spec/lastenheft.md` noch zeigt. Das ist genau die Form, die
  [`AGENTS.md`](../../AGENTS.md) §3.6 als *„kann unter keiner Mutation rot werden"*
  beschreibt — diesmal nicht am Schalter, sondern an den Sperren daneben.
- **Die Lücke ist benannt — ihre Begründung trägt den Befund.** `archive_welle.go:89-91` und
  `harness/README.md:85` sagen beide, die Verdrahtung sei nicht gemessen; das ist ehrlich und
  richtig. Der Zusatz *„was sie zusagt, trägt der Compiler statt eines Tests"* ist die
  Aussage, die hier fällt: Der Compiler trägt, dass die vier Felder nicht **vertauschbar**
  sind — geprüft und wahr —, nicht, dass sie die echten Betriebs-Implementierungen führen. Ein
  Leser, der die zwei Sätze zusammennimmt, hält eine offene Stelle für geschlossen.

**Was trägt.** Der Vorschau-Schalter ist auf allen drei Stufen seiner Strecke bewacht, und
das ist hier selbst nachgemessen: `246` färbt Parser- **und** Strecken-Fall rot, `247` färbt
Strecken-Fall **und** Gegenprobe rot. Der neue Seam `archiveWelleMit`/`laufEingang` macht die
Strecke ohne Repo prüfbar, ohne eine zweite Fassung der Operation zu erzeugen. Der
Argument-Schnitt im Dispatch ist bewacht, ebenfalls hier gemessen. Der Vorlagen-Wächter fragt
je Vorlage einzeln und fällt an der Umbenennung in genau einer. Die Abgrenzungen des
Datei-Kopfes benennen ihre untestete Fläche, statt sie zu verschweigen.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation HIGH-1 mit dem Argument
bestreiten, die Verdrahtung sei „trivial" oder „vom Compiler gedeckt", greift der
Konflikt-Pfad aus Modul 8 §Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt
als Artefakt); die Herabstufung eines Findings, weil die Implementation widerspricht, ist dort
ausdrücklich der vierte, falsche Pfad. Das Gegenbeispiel zu diesem Befund wäre ein grüner Lauf
**mit** den zwei Sonden und einem Träger, der die Sperren hält — nicht eine Einschätzung.
