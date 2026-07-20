# Re-Review-Report: slice-022b (Embed raus) — 2026-07-20

**Review-Art:** Code — geprüft wird der Delta-Diff gegen **Plan + ADR + Hard
Rules** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung —
das ist die Verifikation (Modul 11, getrennter Kontext).

**Gegenstand:** `f1b9b20..HEAD` — zwei Commits: `cc57ffd` („Review-Findings
F-1..F-4 + Verifier-Blocker aufgeloest") und `c0e9955` („AGENTS: Hard Rule 3.6").
9 Dateien, +685/−35. `f1b9b20` war der Stand des ersten Reviews.

**Skill:** `.harness/skills/reviewer.md` @ 1.2.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-4-8[1m] · **Datum:** 2026-07-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: `docs/plan/planning/in-progress/slice-022b-embed-raus.md` (§3 nachgeführt)
- Aktive ADRs: `ADR-0005` (Ziel-Repo-Distribution, Accepted), berührt `ADR-0004`
- Berührte `LH-*`: `LH-FA-02`, `LH-FA-05`, `LH-FA-06`, `LH-QA-01`, `LH-QA-03`
- Konventionen: `MR-001`, `MR-007`, `MR-008`, `MR-009`
- `AGENTS.md` §3 (Hard Rules 3.1–3.5 **und die neue 3.6**, die selbst
  Gegenstand ist)
- Regelwerk: Modul 9 §Hard Rules (repo-spezifisch) + §AGENTS.md-Regeln,
  Modul 10 §Ziel-Form
- **Vorherige Findings am gleichen Modul:**
  `docs/reviews/2026-07-20-slice-022b-review.md` (F-1 HIGH · F-2/F-3/F-4 MEDIUM ·
  F-5/F-6 LOW · F-7 INFO), davor `-slice-022a-review.md` und
  `-slice-022a-re-review.md`. Die wiederkehrende Klasse: *eine Zusage in
  Kommentar, Test-Name oder Prosa greift weiter als das, was der Sensor misst.*

**Ausgeführte Sensoren (eigener Lauf, nichts übernommen):**

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT=0** — baseline-verify OK · d-check 0 Befunde · golangci-lint 0 issues · bats **67 ok** (64→67: die drei neuen Fixture-Fälle) · go-Tests cmd/emit/fetch ok |
| `make smoke` | **EXIT=0** — 4/4; Ausgabe belegt: Bootstrap-Exit, Skelett, d-check-Config. **Kein** Template wird zugesichert |
| Echter Bootstrap: `docker build --target artifact --output type=local` → Binary in leeres git-Repo, `--lang go --name ReReviewProj` | EXIT=0; emittierter Baum Datei für Datei gegen die 15er-Erwartung und die vendored Baseline verglichen |
| **P1** Mutations-Sonde `inScope` → `return true` (Wegwerf-Kopie, kein Repo-Code geändert) | → **F-1** |
| **P2** Sonde: `len(plan) == 0`-Guard ersatzlos gelöscht, `go test ./...` | → **N-1** |
| **P3** Sonde: `gofmt -w` auf `templates_test.go`, danach `test/courseset-fixture.bats` | → **Negativbefund** |
| **P4/P5** Sonden: Fixture-Eintrag im Inline-Stil `&fstest.MapFile{…}` (in-scope / außer-scope) | → **N-2** |
| **P6** Sonde: sechstes **wiederkehrendes** Upstream-Template in die vendored Baseline gelegt | → **F-4** |
| **P7** Sonde: `checkRoot`-Aufruf entfernt | → **F-2** |
| **P8** Sonde: `emit.Templates(…)`-Aufruf aus `run()` entfernt, `go test ./...` + `bats test/` | → **F-3** |
| **P9** Sonde: `templatesDir` auf einen falschen Namen gebogen | → **F-3** |
| **P10** Sonde: Anker `AGENTS.template.md` upstream umbenannt | → **N-4** |
| **P11** Sonde: Erreichbarkeit des Leer-Guards (Anker als Verzeichnis) | → **N-1** |
| **P12** Sonde: upstream tauscht (ein wiederkehrendes dazu, ein Singleton weg — Zahl bleibt 15) | → **F-4** |

---

## Teil A — Status der Findings aus dem ersten Review

### F-1 (HIGH) — **GESCHLOSSEN**

Der inerte `AusserScopeNichtEmittiert` ist durch
`TestTemplates_EmittierterBestandVollstaendig` ersetzt: Voll-Vergleich des
Ist-Bestands (`emittedTree` walkt das gesamte Zielverzeichnis) gegen eine
15er-Erwartungsliste, Gleichheit statt Abwesenheits-Stichprobe.

**Eigene Mutations-Sonde P1** (Wegwerf-Kopie im gepinnten Image,
`func inScope(rel string) bool { return true }`,
`go test -run 'TestTemplates_' -v ./internal/emit/`):

```
--- FAIL: TestTemplates_EmittierterBestandVollstaendig (0.00s)
    templates_test.go:178: emittierter Bestand weicht ab.
        got: … .d-check.yml.md · .harness/skills/closure-note-reviewer.md ·
             .harness/skills/reviewer.md · Makefile.md · README.md.md ·
             project-readme.md … (21 statt 15)
```

Genau die sechs Dateien, die der erste Review als *nicht* rot-färbbar
nachgewiesen hatte, stehen jetzt in der Fehlermeldung. Weil der Test auf
**Mengengleichheit** prüft, färbt auch jeder **einzelne** weggefallene
`inScope`-Zweig rot — eine Teilmenge weicht ebenso ab wie die Vollmenge.
Der Test misst jetzt die Eigenschaft, nicht ihre Implementierung.

### F-2 (MEDIUM) — **GESCHLOSSEN**

`checkRoot` (`internal/emit/templates.go:37-46`) prüft positiv auf den Anker
und läuft **vor** `planTemplates`, also vor jedem Schreibvorgang.
`TestTemplates_FalscheWurzelung` deckt beide Formen (Vorfahren-Wurzelung mit
`templates/`-Präfix, fremde Quelle) und sichert zusätzlich zu, dass trotz
Fehler **nichts** im Ziel liegt.

**Sonde P7** (`checkRoot`-Aufruf entfernt): `--- FAIL:
TestTemplates_FalscheWurzelung`. Der Sensor ist an die Regel gekoppelt.
Die vom ersten Review beschriebene Verletzung (`templates/project-readme.md`,
`templates/.harness/skills/reviewer.md` als Singletons emittiert) ist damit
fail-closed abgeschnitten.

### F-3 (MEDIUM) — **TEILWEISE GESCHLOSSEN** (siehe **N-3**)

Zwei der vier Teil-Aussagen sind eingelöst:

- *Die Wurzelung ist von keinem Test zugesichert.* → **zu.**
  `TestTemplatesDir_ZeigtAufDieGefetchteQuelle` fährt `run()` mit den netzlosen
  Fixtures, lässt `fetch.Baseline` real ins Ziel schreiben und stat't dann
  `templatesDir(dir, fetch.DefaultTag)/AGENTS.template.md`. **Sonde P9**
  (`"templates"` → `"vorlagen"`): `--- FAIL:
  TestTemplatesDir_ZeigtAufDieGefetchteQuelle`, während alle `TestRun_*` grün
  bleiben — die Kopplung ist neu und wirksam.
- *Die falsche `make smoke`-Zuschreibung im Test-Kommentar.* → **zu.** Der
  Kommentar an `TestTemplates_RecurringVerbatim` benennt jetzt, was wirklich
  deckt (`test/courseset-fixture.bats`), und nennt die alte Zuschreibung
  ausdrücklich falsch. Eigener `make smoke`-Lauf bestätigt: 4/4 Schritte,
  kein Template darunter.

Zwei nicht:

- *„`emit.Templates(...)` aus `run()` auskommentieren und `make gates` fahren:
  heute grün."* → **weiterhin wahr** (Sonde P8, Beleg unter **N-3**).
- *Die Layout-Doppelung zu `internal/fetch`.* → **verschoben, nicht aufgelöst**
  (**N-3**).

### F-4 (MEDIUM) — **GESCHLOSSEN**

Die Behauptung des Implementers wurde durch Simulation geprüft, nicht
geglaubt. **Sonde P6:** ein sechstes **wiederkehrendes** Template
(`docs/plan/planning/experiment.template.md`, Kopie von `slice.template.md`) in
die vendored Baseline gelegt, dann `test/courseset-fixture.bats`:

```
not ok 1 fixture: courseSet() bildet den realen Template-Satz vollstaendig ab
not ok 2 fixture: der reale Satz liefert genau 15 in-scope-Templates
         in-scope-Templates: 16, erwartet 15
```

**Beide** Achsen färben rot. Die Zahl 15 (Fall 2) erkennt tatsächlich das
*sechste wiederkehrende* Template — nicht nur „irgendein zusätzliches" —,
weil `in_scope` genau die Menge filtert, aus der `isRecurring` klassifiziert.

Sie ist aber **nicht** der tragende Sensor: **Sonde P12** (ein wiederkehrendes
Template dazu, ein Singleton weg — die Zahl bleibt 15) lässt Fall 2 grün, Fall 1
(Pfad-Diff gegen die Fixture) wird trotzdem rot. Fall 1 ist der eigentliche
Wächter, Fall 2 das gröbere zweite Netz. Die vom ersten Review verlangte
menschliche Klassen-Entscheidung wird in beiden Szenarien erzwungen; der
Deckungsverlust ist damit ersetzt. Die Einschränkung des Sensors steht als
**N-2**.

### F-6 (LOW) — **GESCHLOSSEN**

`docs/plan/planning/welle-02-fetch-und-readme.md` steht jetzt im
Perfekt („022a **war** additiv", „022b **hat** abgeräumt", „blieb vom damaligen
Drift-Wächter bewacht … der Wächter ist mit seinem Gegenstand entfallen").
Kein Präsens-Bewacher mehr, kein stiller Tombstone — und ohne den von `MR-009`
gerügten `ignore-refs`-Eintrag für etwas, das das Gate gar nicht prüft.

### Nicht beauftragt, der Vollständigkeit halber

- **F-5 (LOW) — geschlossen als Nebenfolge:** Der nicht falsifizierbare Fall
  `{"readme.md", …}` ist mit der Fall-Tabelle verschwunden; die neue Form
  kennt keine geratenen Abwesenheits-Namen mehr.
- **F-7 (INFO) — unverändert offen.** `inScope` hängt weiter an einem einzigen
  `!HasSuffix(".template.md")`, der drei sachlich verschiedene Gründe trägt.
  INFO bleibt INFO; kein neues Verhalten.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

### HIGH

### N-1 — `TestTemplates_LeereQuelle` behauptet im Namen und im Doc-Kommentar die `LH-QA-01`-Guard-Eigenschaft und sichert im Rumpf ihr Gegenteil zu; der Guard selbst ist unerreichbar geworden und von keinem Fall mehr gedeckt

- `kategorie`: **HIGH**
- `quelle`: **Hard Rule 3.6** („Ein Test, dessen Name eine Eigenschaft
  behauptet, muss die Eigenschaft messen") — im selben Diff eingeführt und
  im selben Diff gebrochen · `LH-QA-01` (kein stilles Grün) ·
  Reviewer-Skill §HIGH (Verstoß gegen eine Hard Rule) · vierte Wiederholung
  der 022a/022b-Klasse
- `pfad`: `internal/emit/templates_test.go:254-265` (Name, Kommentar, Rumpf) ·
  `internal/emit/templates.go:99-101` (der Guard) · `:90-92` (`checkRoot`, der
  ihn unerreichbar macht)
- `befund`: Name und Doc-Kommentar sagen zu: „eine korrekt gewurzelte, aber
  inhaltsleere Quelle darf nicht still nichts emittieren und Erfolg melden
  (`LH-QA-01`)". Der Rumpf übergibt `fstest.MapFS{"AGENTS.template.md": …}` —
  eine Quelle, die **nicht** leer ist, weil der Anker selbst ein in-scope
  `*.template.md` ist — und sichert `err == nil` plus einen emittierten
  `AGENTS.md` zu, also **Erfolg** statt Fehler. Damit misst kein Fall mehr die
  benannte Eigenschaft. Der Guard `len(plan) == 0` ist zugleich strukturell
  unerreichbar geworden: `checkRoot` verlangt, dass `AGENTS.template.md` an der
  Wurzel liegt, und `inScope` lässt diese Datei ausnahmslos passieren — nach
  bestandenem `checkRoot` hat `plan` also stets mindestens einen Eintrag. Sonde
  **P11** fand genau einen pathologischen Restweg (Anker als **Verzeichnis**
  angelegt: `fs.Stat` gelingt, `WalkDir` überspringt); im echten Betrieb
  existiert er nicht. Sonde **P2** (Guard samt Fehlermeldung ersatzlos
  gelöscht, `go test ./...` im gepinnten Image) meldet `ok` für alle drei
  Pakete: die einzige `LH-QA-01`-Zusicherung des Emitters gegen „leere Quelle →
  laut abbrechen" lässt sich rückstandslos entfernen, ohne dass ein Gate
  reagiert. Konkretes Versagen: benennt upstream den Anker um — nach **P10** ein
  realistischer Fall —, wird `checkRoot` angepasst oder gelockert; der
  Leer-Pfad kehrt unbewacht zurück, und der Test, der laut Namen und Kommentar
  für ihn steht, bleibt grün.
- `verifizierbar`: **ja** — reproduzierbar: `internal/emit` kopieren, den
  `if len(plan) == 0 {…}`-Block löschen,
  `docker run --rm -v <kopie>:/src -w /src golang:1.26.4 go test ./...`;
  gemessen `ok` für `cmd`, `emit`, `fetch`. Ein Fall, der `Templates` mit einem
  `fs.FS` aufruft, bei dem der Anker existiert und trotzdem kein in-scope
  Template entsteht, wäre nach der Löschung rot; heute existiert keiner.

### MEDIUM

### N-2 — Der neue Fixture-Wächter extrahiert Go-Quelltext nach **Schreibweise** statt nach Struktur: ein Fixture-Eintrag im `&fstest.MapFile{…}`-Stil — der in derselben Datei bereits zweimal vorkommt — wird stillschweigend übergangen

- `kategorie`: **MEDIUM**
- `quelle`: `LH-QA-01` (die Zusage „hält die Fixture ehrlich" trägt nicht so
  weit wie behauptet) · Reviewer-Skill §MEDIUM (Spec-Treue-Lücke einer
  Messmethode) · §Kontext-Eskalation (der Fall sitzt in einem Gate-Skript) ·
  Wiederholung der 022a-Klasse N5 („Fixture divergiert von der Realität, die
  sie nachbildet")
- `pfad`: `test/courseset-fixture.bats` (`fixture_paths`, das awk-Muster
  `/"[^"]+"[ \t]*:[ \t]*f\(/`, und Fall 1, der darauf aufsetzt) ·
  `internal/emit/templates_test.go:215` und `:257` (die beiden Stellen im
  bewachten File, die den nicht-erkannten Stil bereits verwenden)
- `befund`: `fixture_paths` erkennt einen Fixture-Eintrag nur, wenn sein Wert
  wörtlich mit `f(` beginnt. Sonde **P4**: ein Eintrag
  `"spec/glossar.template.md": &fstest.MapFile{Data: []byte(hint + body)},` in
  `courseSet()` — ein Pfad, den der reale Satz **nicht** trägt — lässt alle drei
  bats-Fälle grün (`ok 1`, `ok 2`, `ok 3`), obwohl Fall 1 exakt diese Divergenz
  melden soll. Sonde **P5**: derselbe Stil mit einem **außer-scope**-Pfad
  (`.harness/skills/erfunden.template.md`) ist zusätzlich für die Go-Tests
  unsichtbar (`ok github.com/pt9912/ai-harness-init/internal/emit`) — die
  Fixture behauptet dann eine Upstream-Datei, die es nicht gibt, und der
  gesamte Gate-Lauf bleibt grün. Der Stil ist kein konstruierter Sonderfall: er
  steht in derselben Datei zweimal, und der „AUSSER Scope"-Block von
  `courseSet()` lädt gerade dazu ein, dort Einträge zu ergänzen. Ein Sensor,
  der bei einer Schreibweisen-Wahl im bewachten File falsch-negativ wird, ist
  selbst ein stilles Grün. **Nicht** betroffen: die Richtung „upstream kommt
  etwas dazu / fällt weg / wird umbenannt" — dort ist der reale Baum die Quelle,
  und die Sonden **P6**, **P10** und **P12** färben rot. Deshalb MEDIUM und
  nicht HIGH: der Wächter ist einseitig blind, nicht inert.
- `verifizierbar`: **ja** — reproduzierbar: Repo kopieren, in `courseSet()`
  einen Eintrag im `&fstest.MapFile{…}`-Stil mit einem upstream nicht
  existierenden Pfad ergänzen und den bats-Lauf aus `make test` gegen
  `test/courseset-fixture.bats` fahren; gemessen 3× `ok`.

### N-6 — Hard Rule 3.6 liegt nur in **einem** Quadranten: es gibt weder eine Fitness Function noch einen Haken im Guide, an dem sie greifen müsste

- `kategorie`: **MEDIUM**
- `quelle`: Regelwerk **Modul 9 §AGENTS.md-Regeln** („Jede Hard Rule liegt in
  *zwei* Quadranten: inferential feedforward (steht in AGENTS.md) +
  computational feedback (Fitness Function/Linter-Gate). Hard Rule nur in einem
  Quadranten ist halb durchgesetzt") und Modul 9 §Regeln gegen typische
  Fehlannahmen („Erst mit Fitness Function … ist sie *durchgesetzt*. **Beides
  ist Pflicht.**") · Reviewer-Skill §MEDIUM (Abdeckungslücke) ·
  Steering-Loop-Empfehlung des ersten Reviews
- `pfad`: `AGENTS.md` §3.6 · `AGENTS.md` §4 (Quality Gates — kein Target, das
  3.6 misst) · `.claude/commands/implement-slice.md` (Schritt 15/16 und
  Schritt 18, Pre-completion-Checkliste)
- `befund`: 3.1–3.5 haben je ein computational feedback (`make gates`,
  `golangci-lint`/`shellcheck`, Rename-Detection, d-check/ADR-Index). 3.6 hat
  keines: kein `make`-Target, kein Linter und kein bats-Fall prüft, ob eine
  Zusage einen rot gesehenen Gegenbeweis trägt. Der einzige Ort, an dem die
  Regel operativ greifen müsste, ist die Pre-completion-Checkliste in
  `.claude/commands/implement-slice.md` (Schritt 18); die verlangt heute
  „**Sensor-Belege** anhängen (`make gates`-Ausgabe)", also den *grünen* Lauf —
  nicht die von 3.6 geforderte Angabe, welche Mutation den Sensor rot färbt.
  Der erste Review hatte die Rückkante ausdrücklich „an den Guide" adressiert
  („Sensor-Design: ‚welche Mutation färbt diesen Test rot?' als Pflicht-Frage");
  gelandet ist sie im Briefing. Konkretes Versagen, im selben Diff belegt:
  **N-1** ist eine Instanz genau dieser Klasse, entstanden **nach** dem
  Formulieren von 3.6 und durch `make gates` (EXIT=0) nicht bemerkt.
- `verifizierbar`: **ja** — negativ belegbar: keine Suche über `Makefile`,
  `.d-check.yml` und `test/` findet ein Target oder einen Fall, der 3.6 misst;
  `make gates` läuft EXIT=0 auf einem Stand, der 3.6 in
  `internal/emit/templates_test.go` bricht (**N-1**).

### LOW

### N-3 — F-3-Rest: dass `run()` überhaupt Templates ablegt, beobachtet weiterhin kein Gate; die Layout-Doppelung zu `internal/fetch` ist verschoben, nicht aufgelöst — der Plan §3 sagt „an einer Stelle"

- `kategorie`: **LOW**
- `quelle`: `LH-QA-01` (Prüftiefe) · Reviewer-Skill §LOW (Doku-Drift /
  latente Wartungsfalle) · Slice-Plan §3-Nachführung
- `pfad`: `cmd/ai-harness-init/main.go` (der `emit.Templates`-Aufruf sowie
  `baselineDir`/`templatesDir`) · `internal/fetch/baseline.go`
  (`baselineTrees()` und die Ablage unter `filepath.Join(destDir, tag)`) ·
  `docs/plan/planning/in-progress/slice-022b-embed-raus.md` §3-Nachführung
- `befund`: Sonde **P8** ersetzt den kompletten `emit.Templates(…)`-Aufruf in
  `run()` durch eine Zuweisung ohne Wirkung; gemessen: `ok` für alle drei
  Go-Pakete **und** 67/67 bats. Die im ersten Review als F-3-Nachweis benannte
  Rezeptur reproduziert also unverändert — neu zugesichert ist die *Wurzelung*
  (P9 rot), nicht der *Aufruf*. Zweitens hält `internal/fetch` das Layout
  weiterhin selbst (`baselineTrees()` liefert `regelwerk` und `templates`,
  `Baseline` legt unter `filepath.Join(destDir, tag)` ab) und gibt den
  platzierten Pfad nach wie vor nicht zurück; `templatesDir` in `cmd` setzt den
  String `"templates"` ein zweites Mal zusammen. Die §3-Nachführung des
  Slice-Plans schreibt „das Ziel-Layout liegt jetzt in
  `baselineDir`/`templatesDir` an einer Stelle statt inline" — das gilt
  innerhalb von `cmd`, nicht repo-weit. Mildernd und selbst gemessen: die
  Doppelung ist jetzt **gekoppelt**, weil
  `TestTemplatesDir_ZeigtAufDieGefetchteQuelle` gegen das prüft, was
  `fetch.Baseline` real geschrieben hat (P9 färbt rot).
- `verifizierbar`: **ja** — für die erste Hälfte: den `emit.Templates`-Aufruf in
  `run()` neutralisieren und die go- und bats-Achsen von `make test` fahren;
  gemessen grün. Für die zweite Hälfte: Suche nach dem Literal `"templates"`
  über `internal/fetch` und `cmd`.

### N-4 — `checkRoot` verankert die Wurzelungs-Prüfung an **einem** hart verdrahteten Upstream-Dateinamen — genau die Form, die `inScope` im selben File bewusst vermeidet

- `kategorie`: **LOW**
- `quelle`: Reviewer-Skill §LOW (latente Wartungsfalle, hart verdrahteter
  Wert) · `ADR-0005` (der Kurs ist die eine Quelle; das Tool folgt ihm) ·
  Spannung zum Kommentar an `inScope`
- `pfad`: `internal/emit/templates.go:24-26` (`rootAnchor`) · `:37-46`
  (`checkRoot`) · `:56-60` (der Kommentar „Bewusst als REGEL, nicht als
  aufgezaehlte Allowlist")
- `befund`: `inScope` ist ausdrücklich namensagnostisch gebaut, damit ein
  upstream neu hinzukommendes Template ohne Code-Änderung mitfließt.
  `checkRoot` führt daneben eine gegenläufige Kopplung an genau einen
  Basenamen ein und ist fail-closed: benennt oder verschiebt der Kurs
  `AGENTS.template.md`, bricht der Bootstrap vollständig ab — mit der Meldung
  „quelle ist nicht am templates/-Verzeichnis gewurzelt", die auf eine falsche
  Ursache zeigt, obwohl die Wurzel korrekt ist und 14 gültige Templates
  danebenliegen. Ein legitimer Fall bricht damit heute nicht (der reale Satz
  trägt den Anker an der Wurzel — selbst geprüft), aber der Anker ist die
  schmalste denkbare Basis für eine Prüfung, deren Zweck „liegt der Satz
  wirklich hier?" ist. Deutlich mildernd und selbst gemessen: Sonde **P10**
  (Anker upstream umbenannt) färbt `test/courseset-fixture.bats` Fall 1 rot,
  bevor die Umbenennung einen Adopter erreicht — die Klasse ist also gesehen,
  nur mit einem Sensor in einem anderen Gate-Schritt und einer Fehlermeldung,
  die woanders hinzeigt.
- `verifizierbar`: **ja** — reproduzierbar: in einer Kopie
  `.harness/baseline/*/templates/AGENTS.template.md` umbenennen und den
  bats-Lauf gegen `test/courseset-fixture.bats` fahren; gemessen
  `not ok 1`, `ok 2`, `ok 3`.

### INFO

### N-5 — Die Begründung zu 3.6 trägt selbst eine unfalsifizierbare Universalaussage, während die Regel Falsifizierbarkeit verlangt

- `kategorie`: **INFO**
- `quelle`: Maintainability · Hard Rule 3.6 (auf sich selbst angewandt)
- `pfad`: `AGENTS.md` §3.6, Absatz „Begründung (gemessen, nicht postuliert)"
- `befund`: Die Begründung ist mit „(gemessen, nicht postuliert)" überschrieben
  und enthält den Satz „**Jede Stelle mit Zähne-Beweis hielt, jede ohne rutschte
  durch, ausnahmslos.**" Die beiden Zählungen davor („in slice-022a fünf
  Instanzen … in slice-022b vier") sind über die vier Review-/Verifikations-
  Reports nachvollziehbar; die Universalaussage ist es nicht: nirgends im Repo
  ist die Grundgesamtheit „Stellen mit Zähne-Beweis" aufgezählt, gegen die sich
  ein „ausnahmslos" prüfen ließe. Beobachtbares Versagen heute keines — die
  Regel wirkt unabhängig davon; dokumentationswürdig ist die Asymmetrie, dass
  ausgerechnet die Begründung einer Falsifizierbarkeits-Regel eine nicht
  falsifizierbare Behauptung führt.
- `verifizierbar`: nein — Beleg-Lücke in einer Prosa-Begründung, kein
  Gate-messbares Verhalten.

---

## Teil C — Urteil zur neuen Hard Rule `AGENTS.md` §3.6

**Modul-9-Form:** Modul 9 §Hard Rules verlangt „*Falsch/Richtig*-Beispiele
**und** eine *technische Begründung*". Beides ist vorhanden: drei Beispielpaare
und ein mit Zahlen unterlegter Begründungsabsatz. Formal erfüllt. **Nicht**
erfüllt ist die zweite Modul-9-Anforderung an Hard Rules (zwei Quadranten) —
das ist **N-6**.

**Die drei Beispielpaare — je einzeln geprüft, alle korrekt und nachvollziehbar:**

1. *„ein Test `…AusserScopeNichtEmittiert`, der die Quell-Namen prüft, während
   der Code transformierte Ziel-Namen schreibt — er kann unter keiner Mutation
   rot werden."* **Korrekt.** Eigene Sonde **P1** am Vorgänger-Stand
   reproduziert den inerten Zustand; die „Richtig"-Seite (Voll-Bestand gegen
   Erwartungsliste) ist im selben Diff umgesetzt und färbt unter derselben
   Mutation rot. Der Beleg liegt im Repo, nicht nur in der Prosa.
2. *„‚Byte-Gleichheit belegt `make smoke`', ohne `smoke` gelesen zu haben."*
   **Korrekt.** Der Satz stand wörtlich in
   `internal/emit/templates_test.go` (Vorgänger-Fassung); mein eigener
   `make smoke`-Lauf endet mit „Bootstrap laeuft, Skelett gestaged,
   Doc-Gate-Config valide" — `harness/tools/smoke.sh` fasst kein emittiertes
   Template an.
3. *„ein Doc-Kommentar, der ‚bei jedem Fehler bleibt das Ziel unverändert'
   zusagt, während ein `MkdirAll` davor läuft."* **Korrekt.** In der Historie
   verifiziert: die Fassung von `internal/fetch/baseline.go` unter `8a3355d`
   trägt „Bei jedem Fehler bleibt destDir unveraendert (Temp-Verzeichnis +
   finales Rename)", während `os.MkdirAll(destDir, 0o755)` in derselben
   Funktion vorher läuft. Die „Richtig"-Seite ist ebenfalls im Repo belegbar
   (`7e66fa9` „Doc-Zusage praezisiert"): der heutige Kommentar an
   `fetch.Baseline` schränkt ausdrücklich ein („destDir SELBST wird frueh
   angelegt … und bleibt bei einem Abbruch leer zurueck").

**Begründung „kein ADR, weil Verschärfung" — haltbar.** §3.5 lautet wörtlich
„Jede **Schwellen-Senkung** (Modul-Aktivierung, Strenge) ist ein ADR" — sie
adressiert die Senkung, nicht die Anhebung. `MR-001` §Begründung enthält
wörtlich „Gate-*Anheben* → Steering-Loop, kein ADR nötig" (selbst nachgelesen
in `harness/conventions.md`). Die Zitierung ist korrekt und der Analogieschluss
trägt: 3.6 nimmt nichts weg, sondern verlangt zusätzlich. Kein Finding.

**Keine Duplikation in `.claude/commands/implement-slice.md` — die
Entscheidung als solche ist tragfähig, die Lücke liegt woanders.** Der Command
liest in Schritt 3 ausdrücklich `AGENTS.md`; keine der Regeln 3.1–3.5 ist dort
dupliziert, der MR-Block im Command spiegelt nur *Konventionen* aus
`harness/conventions.md`, keine Hard Rules. Eine Kopie von 3.6 wäre eine zweite
Wahrheit und stünde gegen Modul 9 §Kontext-Verdichtung. **Aber:** die Frage
„ist die Regel dort unsichtbar, wo sie greifen müsste?" ist mit *ja* zu
beantworten — nicht, weil der Regeltext fehlt, sondern weil der Workflow-Schritt
fehlt, der sie operativ macht (Schritt 18 fordert grüne Sensor-Belege, nicht den
rot gesehenen Gegenbeweis). Das ist der Kern von **N-6**; als Duplikations-Frage
allein wäre es kein Finding.

---

## Negativbefunde

<!-- Eine Zeile pro betrachtetem Bereich. -->

- **geprüft, ohne Befund — die 15er-Erwartungsliste gegen den REALEN Satz:**
  Echter Bootstrap (`docker build --target artifact --output type=local,dest=…`,
  Binary in ein frisches `git init`-Repo, `--lang go --name ReReviewProj`).
  Die aus `TestTemplates_EmittierterBestandVollstaendig` extrahierte
  Erwartungsliste und der emittierte Ist-Baum (abzüglich der tool-eigenen
  `.d-check.yml`/`d-check.mk` und des Skeletts) sind **`diff`-identisch, 15 zu
  15**. Alle fünf wiederkehrenden Templates sind byte-gleich zu ihrem Zwilling
  in `.harness/baseline/v3.5.0/templates/`. `README.md`, `project-readme.md`,
  `Makefile.md`, `README.md.md`, `.d-check.yml.md` und `.harness/skills/`
  existieren im Ziel **nicht**. Die Liste ist keine erfundene zweite Wahrheit.
- **geprüft, ohne Befund — ist die 15er-Liste ein *stilles* Drift-Paar neben
  `courseSet()`?** Nein. Sonde **P4** (Fixture bekommt ein zusätzliches
  in-scope-Template) färbt `TestTemplates_EmittierterBestandVollstaendig` rot
  und listet die Abweichung namentlich. Die Kette real → Fixture
  (`test/courseset-fixture.bats` Fall 1) → Erwartungsliste (Go-Test) ist an
  jedem Glied gekoppelt und schlägt laut an; die Drift ist erzwungen sichtbar,
  nicht still. Die *eine* Lücke in dieser Kette steht als **N-2** und liegt im
  ersten Glied, nicht hier.
- **geprüft, ohne Befund — `gofmt`-Robustheit der awk-Extraktion (die konkret
  gestellte Frage):** `internal/emit/templates_test.go` ist heute **nicht**
  gofmt-clean (`gofmt -l` listet es, ebenso `internal/emit/emit.go` und
  `internal/emit/emit_test.go`), und `.golangci.yml` aktiviert **keinen**
  Formatter — ein späteres `gofmt -w` ist also eine realistische, von keinem
  Gate erzwungene Änderung. Sonde **P3** hat sie ausgeführt: `gofmt -w` richtet
  die Map-Literale neu aus (Diff über 21 Zeilen, reine Spaltenbreite), danach
  laufen alle drei Fälle von `test/courseset-fixture.bats` `ok`. Das awk-Muster
  toleriert die Neuausrichtung, weil es beliebigen Leerraum zwischen `:` und
  `f(` erlaubt. Die Reformatierung bricht den Sensor **nicht**.
- **geprüft, ohne Befund — fängt die awk-Extraktion versehentlich andere Zeilen
  der Datei?** Nein. Sie scannt zwar das **ganze** File statt nur den
  `courseSet()`-Rumpf, liefert aber exakt die 21 Fixture-Pfade (Fall 1 ist
  grün und vergleicht 1:1 gegen die 21 realen Pfade). Die beiden anderen
  `fstest.MapFS`-Literale der Datei entgehen ihr, weil ihre Werte nicht mit
  `f(` beginnen — dieselbe Eigenschaft, die als **N-2** die umgekehrte Richtung
  blind macht. Falsch-*positive* gibt es heute keine.
- **geprüft, ohne Befund — Verhalten bei einem Eintrag, dessen Wert nicht
  `f(...)` ist, in der *lauten* Richtung:** Ein realer Upstream-Pfad, der in
  der Fixture im Inline-Stil steht, fehlt in `fixture_paths` und erscheint im
  `diff` als `>`-Zeile — Fall 1 wird **rot**. Der gefährliche Ausgang ist
  ausschließlich der fixture-only-Fall (**N-2**).
- **geprüft, ohne Befund — Fail-closed-Verhalten von
  `test/courseset-fixture.bats` bei fehlender/mehrfacher Baseline:** `setup()`
  löst die Baseline per Glob auf. Ohne Treffer bleibt der Literal-String
  stehen: Fall 1 bricht an der `-d`-Prüfung ab, Fall 2 misst 0 statt 15, Fall 3
  findet keine Datei — alle drei rot. Bei zwei `<tag>`-Verzeichnissen liefert
  die Glob-Auflösung zwei Pfade, die `-d`-Prüfung scheitert ebenfalls. Kein
  stilles Grün auf einem kaputten Checkout.
- **geprüft, ohne Befund — `checkRoot` bricht keinen legitimen Pfad:**
  `checkRoot` ist der erste Aufruf in `Templates` und läuft vor `MkdirAll`,
  `WriteFile` und dem Force-Pre-Flight; im Fehlerfall ist das Ziel unberührt
  (`TestTemplates_FalscheWurzelung` sichert einen leeren Zielbaum zu, selbst im
  Lauf gesehen). `planTemplates` ist unexportiert und ausschließlich aus
  `Templates` erreichbar — der Guard ist nicht umgehbar. Der echte Bootstrap
  passiert ihn (EXIT=0). Das Restrisiko der Anker-Wahl steht als **N-4**.
- **geprüft, ohne Befund — Hermetik und Fixture-Isolation der neuen Tests:**
  `courseSet()` liefert bei jedem Aufruf eine **neue** `fstest.MapFS`; die
  mutierenden Fälle (`TestTemplates_NeuesUpstreamTemplateFliesstMit`,
  `TestTemplates_FalscheWurzelung`) verunreinigen einander nicht. `emittedTree`
  walkt das vollständige `t.TempDir()`, überspringt nur Verzeichnisse, und
  slash-normalisiert — auf jedem Dateisystem vergleichbar. Keine neue
  Modul-Abhängigkeit (`go.mod` unberührt; `sort` ist Stdlib) — `LH-QA-03` hält.
- **geprüft, ohne Befund — `TestTemplatesDir_ZeigtAufDieGefetchteQuelle` ist
  keine Selbst-Bestätigung:** Der Fall lässt `run()` real durchlaufen, bis
  `fetch.Baseline` das Fixture-Bundle (das `templates/AGENTS.template.md`
  trägt) ins Ziel entpackt hat, und stat't erst dann gegen `templatesDir`.
  Er prüft also gegen ein **geschriebenes** Artefakt, nicht gegen eine zweite
  Konstante. Sonde **P9** belegt die Kopplung.
- **geprüft, ohne Befund — Hard Rules 3.1/3.2/3.4/3.5 im Delta:** Kein
  Gate-Name kommt hinzu oder fällt weg (3.1); der bats-Stand steigt 64 auf 67,
  exakt die drei neuen Fixture-Fälle — eine Anhebung, keine Lockerung (3.5).
  Kein `//nolint`, kein `# shellcheck disable` im Diff; `golangci-lint`
  0 issues, `shellcheck` sauber (3.2). Keine ADR im Diff (3.4). Die neue
  `AGENTS.md`-Regel ist additiv (3.6 kommt hinzu, 3.1–3.5 unverändert).
- **geprüft, ohne Befund — Hard Rule 3.3 (`git mv` + Inhalt = zwei Commits):**
  Der Diffstat über `f1b9b20..HEAD` weist keinen Rename aus; beide Commits sind
  reine Inhaltsänderungen an bestehenden Dateien plus eine Neuanlage
  (`test/courseset-fixture.bats`).
- **geprüft, ohne Befund — Commit-Zuschnitt:** Die Regel-Änderung (`c0e9955`,
  nur `AGENTS.md`) ist von den Findings-Fixes (`cc57ffd`) getrennt committet —
  die Verschärfung ist als eigener, rückrollbarer Schritt lesbar.
- **geprüft, ohne Befund — Plan-Nachführung §3 gegen Modul 9 („die Tabelle ist
  ein Protokoll"):** Alle drei im Delta berührten Artefakte
  (`cmd/ai-harness-init/main.go`, `test/courseset-fixture.bats`,
  `internal/emit/templates.go`) sind mit Änderungs-Art und Begründung
  nachgetragen; die aufgegebene `.d-check.yml`-Zeile ist durchgestrichen und
  als „entfällt begründet" mit `MR-009`-Bezug ausgewiesen statt still gelöscht.
  Der einzige Prosa-Überhang steht als **N-3**.
- **geprüft, ohne Befund — `ADR-0005`/`ADR-0004`-Konformität des Deltas:**
  Das Delta führt keinen zweiten Template-Pfad ein, keinen Embed und keine
  neue Herkunftsklasse. Die `LH-FA-05`-/`LH-FA-06`-Grenzen sind im echten
  Bootstrap nachgemessen eingehalten (weder `project-readme.md` noch
  `.harness/skills/` im Ziel).
- **geprüft, ohne Befund — `MR-008` für dieses Artefakt:** Der Report entstand
  per `cp` aus
  `.harness/baseline/v3.5.0/templates/docs/reviews/review-report.template.md`,
  nicht hand-modelliert.
- **geprüft, ohne Befund — kein Produktivcode angefasst:** Alle Sonden liefen
  auf Wegwerf-Kopien unter dem Session-Scratchpad; der Working Tree war vor dem
  Anlegen dieses Reports sauber.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 1 |

**Aus dem ersten Review:** F-1 (HIGH) **zu** · F-2 (MEDIUM) **zu** ·
F-3 (MEDIUM) **teilweise zu** (Rest als N-3, herabgestuft) · F-4 (MEDIUM)
**zu** · F-5/F-6 (LOW) **zu** · F-7 (INFO) unverändert offen.

**Neu:** N-1 (HIGH) inverter Leer-Quellen-Test + unerreichbarer Guard ·
N-2 (MEDIUM) schreibweisen-abhängige Fixture-Extraktion · N-6 (MEDIUM) 3.6 nur
in einem Quadranten · N-3 (LOW) F-3-Rest · N-4 (LOW) Ein-Datei-Anker ·
N-5 (INFO) unfalsifizierbare Begründungs-Aussage.

## Verdikt

**Merge-blockierend: ja** — wegen N-1 (HIGH) und N-2/N-6 (MEDIUM).

Zur Einordnung, damit das Verdikt nicht als Rückschritt gelesen wird: **das
Delta ist ein substanzieller Fortschritt.** Der zentrale HIGH-Befund F-1 ist
sauber und mutations-belegt geschlossen; F-2 und F-4 ebenso, F-4 sogar mit zwei
unabhängigen Achsen, die ich einzeln rot gefahren habe. Die falsche
`make smoke`-Zuschreibung ist korrigiert statt umformuliert. Das Verhalten des
Emitters bleibt am echten Bootstrap gemessen exakt richtig: 15 Dateien, richtige
Klasse, richtige Stelle, byte-identisch wo verbatim gefordert. `make gates`
EXIT=0, `make smoke` EXIT=0.

Blockierend ist, dass die Reparatur an **zwei** Stellen dieselbe Klasse neu
erzeugt, gegen die sie gerichtet war. **N-1:** Ein Test behält Namen und
`LH-QA-01`-Kommentar einer Guard-Eigenschaft und sichert im Rumpf deren
Gegenteil zu, während der Guard selbst unerreichbar geworden ist — der
Lehrbuchfall der Regel, die einen Commit später geschrieben wurde. **N-2:** Der
neue Wächter, der die Fixture ehrlich halten soll, liest Go-Quelltext nach
Schreibweise; ein Eintrag in einem Stil, der in derselben Datei bereits zweimal
vorkommt, macht ihn falsch-negativ.

**Steering-Loop-Signal (Modul 10 §Kontext-Eskalation).** Dies ist die
**vierte** Sitzung in Folge mit derselben Klasse — 022a (M1/N1/N2), 022b-Review
(F-1 bis F-4), jetzt 022b-Re-Review (N-1/N-2). Der erste Review hatte genau das
prognostiziert und die Rückkante an den **Guide** adressiert. Der Implementer
hat sie stattdessen ins **Briefing** gelegt (3.6) — inhaltlich gut gemacht,
formal Modul-9-konform in den Beispielen, aber wirkungslos für den Lauf, der
sie brauchte: **N-1 ist nach dem Formulieren von 3.6 entstanden und von
`make gates` nicht bemerkt worden.** Das ist der empirische Beleg für Modul 9
§AGENTS.md-Regeln („Hard Rule nur in einem Quadranten ist halb durchgesetzt")
und macht **N-6** zum eigentlichen Ergebnis dieses Laufs: nicht noch ein
Findings-Durchgang, sondern der fehlende zweite Quadrant — ein Haken in der
Pre-completion-Checkliste des Guides und/oder ein Sensor, der die Frage
„welche Mutation färbt das rot?" mechanisch stellt.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
