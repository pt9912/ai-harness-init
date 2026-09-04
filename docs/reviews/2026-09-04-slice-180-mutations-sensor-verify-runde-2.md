# Review slice-180 — Runde 2: Nachprüfung der Runde-1-Findings

**Rolle:** Reviewer (Modul 8, frischer Kontext) · **Datum:** 2026-09-04 ·
**Skill:** `.harness/skills/reviewer.md` 1.6.0 · **Baseline:** `v5.18.0`

**Gegenstand:** schmale Nachprüfungs-Runde, kein Voll-Review. Geprüft wird der unkommittierte
Arbeitsbaum gegen `HEAD` (`8ae359b`) — `git diff HEAD --stat` → 6 Dateien, 459 Einfügungen,
52 Löschungen, dazu `test/mutations/262-mutate-schluessel-ausnahme-nicht-deklariert.sh` und
`test/mutations/263-mutate-beleg-ueberlebt-abbruch.sh` als untrackte Dateien.

**Bezugs-Report:** [`2026-09-04-slice-180-mutations-sensor-verify.md`](2026-09-04-slice-180-mutations-sensor-verify.md)
(2 HIGH, 3 MEDIUM, 3 LOW, 1 INFO, blockiert).

**Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan):** unverändert gegenüber Runde 1 —
[`slice-180`](../plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md),
[`AGENTS.md`](../../AGENTS.md) §3.1/§3.5/§3.6/§3.7/§3.8/§3.9 — plus als *vorherige Findings am
gleichen Modul* der Bezugs-Report oben.

**Methode:** jede behauptete Behebung ist mit einer **eigenen Sonde** gemessen, nicht aus der
Behauptung übernommen. Die Sonden liegen als Wegwerf-Bäume unter `mktemp -d` und benutzen nur
`bash`, `sed`, `grep`, `find`, `tar`, `comm` — keine Host-Toolchain
([`AGENTS.md`](../../AGENTS.md) §3.9).

**Nicht geprüft (Rollen-Grenze):** die DoD-Abhakung (jetzt fünf von sechs `[x]`) und die
Wanduhr-Zahlen aus §7 — das ist Verifier-Arbeit in getrenntem Kontext.

---

## A. Nachprüfung der Runde-1-Findings

| Runde-1 | Status | Womit gemessen |
|---|---|---|
| **HIGH-1** Beleg überlebt widerlegenden Lauf | **behoben** | Runde-1-Sonde wiederholt; Fall 263 unabhängig rot-dann-grün gefahren |
| **HIGH-2** falsche Sensor-Zuschreibung | **behoben** | Kommentar `harness/tools/mutate.sh:1455-1466` gelesen, Zahlen nachgemessen |
| **MEDIUM-1** FF-Zeile 3 misst nur die Funktion | **überwiegend behoben** | vier Treiber-Varianten gegen den neuen `main()`-Test gefahren |
| **MEDIUM-2** veralteter Zähler-Stand §8 | **behoben** | §8 gegen `observations.md` gehalten |
| **MEDIUM-3** Register-Timing | **unverändert offen**, dazu neuer Widerspruch | siehe N-3 |
| **LOW-1** unescapte Pipes | **behoben** | Zellgrenzen-`awk` über alle `BEO-`-Zeilen |
| **LOW-2** fehlende Untergrenze | **behoben** | `[ -n "$copy" ]` steht in `test/mutate-driver.bats` |
| **LOW-3** Chronik in `Stand`-Zelle | **behoben** | Zelle `BEO-034` gelesen |
| **INFO-1** Metadaten-Grenze | unverändert (war INFO, nicht adressiert) | — |

### HIGH-1 — behoben, mit eigener Sonde bestätigt

`clear_belief` steht als unbedingter Aufruf in `harness/tools/mutate.sh:1490`, **vor** allen sechs
in Runde 1 benannten Ausgängen und direkt hinter der Übersprung-Entscheidung. Meine Runde-1-Sonde,
unverändert gegen den jetzigen Code gefahren:

```
== Beleg vorher: 7c5a126c…
== Lauf 1 (MUTATE_FORCE=1) ==  mutate: ABBRUCH — unbekannter '# verify: …'   exit=1
== Beleg nachher: [FEHLT]
== Lauf 2 (unerzwungen) ==     mutate: ABBRUCH — unbekannter '# verify: …'   exit=1
```

Der Folgelauf fährt wieder voll und meldet **nicht** *„unveraendert"*. Runde 1 sah hier
`exit=0` und die Übersprung-Meldung.

**Fall 263 ist unabhängig geprüft, nicht geglaubt.** Sein `sed`-Anker `/^  clear_belief$/d` trifft
in einer Wegwerf-Kopie **genau** die Zeile 1490 und nichts sonst (`diff` gegen das Original → eine
gelöschte Zeile); die Definition (`clear_belief()`, Zeile 151) und der Aufruf in `finalize_belief`
(Zeile 164, vier Leerzeichen Einzug) bleiben unberührt. Der Rumpf des zugehörigen bats-Tests,
als Skript nachgefahren: unmutiert `GRUEN`, mit der Mutation aus Fall 263 `ROT: Beleg ueberlebt`
an genau der Zusicherung `[ ! -f "$fake/.harness/state/mutate-passed.key" ]`. Rot-dann-grün ist
damit gemessen.

**Ergänzend geprüft — die drei Ausgänge *vor* `clear_belief` sind kein Loch:** `MUTATE_JOBS`
(`:1436`), `MUTATE_STALL_SECONDS` (`:1446`) und fehlendes `test/mutations/` (`:1453`) verlassen
`main()`, ohne einen bestehenden Beleg anzufassen. Alle drei sind Aufruf-Fehler *vor* jeder
Messung — sie widerlegen den Beleg nicht, und ihn dort zu löschen wäre eine andere Regel.

### HIGH-2 — behoben

`harness/tools/mutate.sh:1455-1466` behauptet keine Deckung mehr. Der Kommentar sagt jetzt
*„UNGEDECKT: dass der Host-Baum zwischen dieser Zeile und dem Schreiben des Belegs unveraendert
bleibt, erzwingt hier NICHTS"*, benennt `target_fingerprint` als Träger **nur** der
`# files:`-Zielpfade und verweist auf `BEO-025` mit dem Vermerk, dass dessen Ausgang geplant ist.
Das ist die Zusage, die der Code hält. Nachgemessen:
`sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u | wc -l`
→ **57**;
`bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files | wc -l"` →
**1056** (keine Erwartungswerte, beide wandern mit dem Baum). Zur im Text stehenden Zahl `1055`
siehe N-5.

Der Verweis auf `BEO-025` ist **kein** Verstoß gegen die Quellen-Klausel von
[`AGENTS.md`](../../AGENTS.md) §3.7: `BEO-025` löst nach
[`docs/plan/planning/observations.md`](../plan/planning/observations.md) auf — ein **lebendes**
Register, das §3.7 selbst als solches führt —, nicht nach einem Zeitdokument.

### MEDIUM-1 — überwiegend behoben; die Rest-Lücke ist gemessen

Der neue Test (`test/mutate-driver.bats:1030`) startet `mutate.sh` **zweimal als eigenen Prozess**
und trifft damit die reale `main()`-Verdrahtung, nicht die isolierte Funktion. Ich habe seinen
Rumpf gegen vier Treiber-Varianten gefahren:

| Variante | Ergebnis |
|---|---|
| unverändert | `GRUEN` |
| `clear_belief` aus `main()` entfernt (= Fall 263) | **ROT** (`Beleg ueberlebt`) |
| `finalize_belief "$belief_key"` **vor** die Fall-Schleife gezogen | **ROT** (`Beleg ueberlebt`) |
| `MUTATE_FORCE`-Bedingung aus der Übersprung-Zeile entfernt | **ROT** (`status=0` statt 1) |
| `finalize_belief "$belief_key"` **ganz entfernt** | `GRUEN` |

Die Zusage der dritten Fitness-Function-Zeile — *„der Schreibpunkt liegt hinter der Bedingung,
unter der `main()` seinen Exit-Status bildet"* — ist damit gegen **Verschiebung** gedeckt, was der
Wortlaut verlangt. Die letzte Zeile der Tabelle ist die Rest-Lücke und geht in N-1 ein: sie ist
keine Verschiebung des Schreibpunkts, sondern sein Wegfall.

### MEDIUM-2 — behoben

`docs/plan/planning/in-progress/slice-180-…md:621` führt `BEO-025` jetzt als **3×**, **geplant** →
`slice-181`, und der Schluss darunter (`:656-663`) sagt ausdrücklich, dass die Zeile **nicht** durch
diesen Slice über die Schwelle ging, sondern durch den `slice-175`-Lese-Schritt. Das deckt sich mit
dem Register:
`awk -F'|' '/^\| BEO-025 /{print $5, $6}' docs/plan/planning/observations.md` →
`3×  slice-170, slice-173, slice-175`.

### LOW-1 / LOW-2 / LOW-3 — behoben

- **LOW-1:** `awk '/^\| BEO-/{l=$0; e=gsub(/\\\|/,"X",l); r=gsub(/\|/,"|",l); if(r!=7) print substr($0,3,7), e, r}' docs/plan/planning/observations.md`
  meldet nur noch `BEO-009 2 8` — die Bestandszeile außerhalb dieses Diffs. `BEO-034` trägt jetzt
  `roh=7` und rendert vollständig.
- **LOW-2:** `[ -n "$copy" ]` steht im Test, mit einer Begründung, die die Hausform aus
  `target_fingerprint`/`isolation_key` zitiert. Meine Nachbildung des Testrumpfs schlägt über
  leerer Kopie jetzt mit `ROT: Untergrenze - Kopie leer` an.
- **LOW-3:** Der Plusquamperfekt-Satz über den Schreibzeitpunkt ist weg; die Zelle nennt Zustand
  (`offen — Erstauftreten`), Beleg und die geltende Lage (*„trägt jetzt auch die betroffene
  Zusicherung"*).

---

## B. Neue Findings dieser Runde

### N-1 — Der einzige Zweig, der Exit 0 ohne jede Messung liefert, wird von keinem Wächter gehalten

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„erst fertig, wenn benannt ist, was passieren
  müsste, damit sie bricht, und das einmal rot gesehen wurde"*) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  §Fitness Function / §*Was kein Wächter hält*
- **pfad:** `harness/tools/mutate.sh:1471` (Schlüssel-Vergleich) gegen `:52-55` (Bedingung 6 im
  Kopf) · `test/mutate-driver.bats:1030` · `test/mutations/`
- **befund:** Die Übersprung-Bedingung besteht aus drei Teilen; zwei sind bewacht, der dritte nicht.
  Entferne ich den Vergleich `[ "$(cat "$BELIEF" 2>/dev/null)" = "$belief_key" ]`, überspringt der
  Treiber über einem Baum, zu dem der hinterlegte Beleg **nicht** gehört, und meldet
  `Beleg fuer Pruefgegenstand … liegt vor … seit dem letzten vollstaendig gruenen Lauf unveraendert.
  Kein Fall-Lauf.`, Exit 0 — real gefahren mit einem Beleg-Inhalt `VOELLIG-FALSCHER-SCHLUESSEL`.
  Kein Wächter färbt sich dabei rot: der neue `main()`-Test läuft in seinem zweiten Aufruf ohne
  Beleg-Datei und erreicht den Zweig nie (Sonde: `GRUEN`), kein anderer bats-Test startet den
  Treiber mit einem vorliegenden Beleg
  (`grep -n 'bash "\$fake\|run env MUTATE' test/mutate-driver.bats` → die Zeilen 828/835/839 brechen
  vor dem Beleg-Block ab, 1042/1046 sind der neue Test), und kein Mutations-Fall adressiert die
  Zeile (`grep -rln 'belief_key\|BELIEF\|Uebersprung' test/mutations/` → nur `263`, das
  `clear_belief` trifft). **In CI kann der Zweig nicht einmal laufen**: `MR-014` fährt auf frischem
  Klon, und `.harness/state/` ist gitignored — es gibt dort nie einen Beleg. Bedingung 6 im Kopf
  sagt *„Ein Beleg-Uebersprung greift NUR bei exaktem Schluessel-Treffer"*; für dieses *NUR* ist
  kein Gegenbeispiel rot gesehen worden. Die ADR zählt unter *Was kein Wächter hält* drei Lücken
  auf — diese ist keine davon.
- **verifizierbar:** ja — der Vergleich in einer Wegwerf-Kopie entfernt, Beleg-Datei mit beliebigem
  Inhalt hinterlegt, Treiber aufgerufen: Exit 0 und Übersprung-Meldung über nicht passendem Baum;
  derselbe Treiber gegen den Rumpf des `main()`-Tests: `GRUEN`.
- **klasse:** *Der eine Zweig, der ohne Messung Exit 0 liefert, ist in einer als vollständig
  geführten Aufzählung der Wege ins stille Grün nicht enthalten und von keinem Fall adressiert.*

### N-2 — Ein neuer Kommentar nennt eine Review-Befund-Kennung als Grund und eine Zeilennummer, die nicht mehr stimmt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Beschrieben wird die Stelle, nicht der Vorgang,
  der sie erzeugt hat*; Falsch-Beispiel: *„… Review-Befund slice-022b N-4"* — eine Befund-Kennung
  als Grund, sie löst nach `docs/reviews/**` auf, einem Zeitdokument in keinem Rang)
- **pfad:** `test/mutate-driver.bats:991` und `:993` · gespiegelt in `test/mutate-driver.bats:1030`
  und `test/mutations/263-mutate-beleg-ueberlebt-abbruch.sh:3`
- **befund:** Zeile 993 schließt einen sonst korrekten Grenz-Satz mit *„prueft dieser Test-Block
  nicht (Review-Fund MEDIUM-1)"*. Die Kennung nennt nicht einmal ihren Report und löst deshalb
  nirgends auf; sie ist genau die Form, die §3.7 seit dem 2026-08-30 ausschließt, und der Kommentar
  ist in diesem Diff **neu geschrieben**, fällt also unter den Cutoff. Zeile 991 nennt daneben
  *„Zeile ~1633, letzte Anweisung"* als Aufrufort von `finalize_belief`; der Aufruf steht bei
  **1653** (`grep -n 'finalize_belief "\$belief_key"' harness/tools/mutate.sh`) — 1633 war der Ort
  in der Fassung, die Runde 1 vorfand, der Kommentar beschreibt also eine Stelle des abgelösten
  Stands. Dieselbe Runden-Kennung steht als `HIGH-1` im **Testnamen** (`:1030`) und wortgleich in
  der `# expect:`-Zeile von Fall 263; die zwei sind über `make mutate` aneinander gebunden, das
  Label ist damit dauerhaft und maschinell verkettet. Kein Gate fängt das: der Prüfbereich von
  `make comment-claims` führt `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`,
  `.claude/hooks/*.sh` — keine `*.bats`-Datei und kein `test/mutations/`-Fall.
- **verifizierbar:** nein — kein Sensor liest diese Dateien auf Kommentar-Klassen; der Befund ist am
  Text und an der Zeilennummer belegt.
- **klasse:** *Ein Kommentar nennt die Herkunft seiner Änderung statt der Stelle — Befund-Kennung
  als Grund, plus eine Zeilennummer aus der abgelösten Fassung.*

### N-3 — Der Plan erklärt Register-Einträge zur Sache der Closure, während derselbe Baum vier davon vornimmt

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register (*„Eingetragen
  wird bei der **Slice-Closure**"*) · [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage und Ist-Stand)
- **pfad:** `docs/plan/planning/in-progress/slice-180-…md:661-663` gegen
  `docs/plan/planning/observations.md:79-82`, `…slice-180-…md:540` (§7) und `:162` (DoD-Häkchen)
- **befund:** §8 schließt mit dem Satz *„Eintragungen in `../observations.md` sind Sache der
  Slice-Closure, nicht dieses Implementer-Laufs"*. Im selben Arbeitsbaum legt derselbe
  Implementer-Lauf **vier** Registerzeilen an (`BEO-031`–`BEO-034`, `git diff HEAD --
  docs/plan/planning/observations.md` → 4 Einfügungen), §7 zählt sie als geleistet auf, und das
  DoD-Häkchen *„Beobachtungs-Register fortgeschrieben"* steht auf `[x]`. Das Artefakt spricht die
  Regel aus und bricht sie auf derselben Fläche; ein Leser kann aus dem Plan nicht mehr entnehmen,
  welche der beiden Aussagen gilt. Das ist MEDIUM-3 aus Runde 1 in verschärfter Form: dort war die
  Rollen-Frage nur ungeschrieben, jetzt ist sie geschrieben **und** anders ausgeführt. Die
  Rollen-Frage selbst bleibt, was sie war — `BEO-007` (4×, geplant → `slice-151`), keine Quelle
  dieses Repos benennt die schreibende Rolle für `observations.md`.
- **verifizierbar:** ja — die zwei Textstellen nebeneinander und `git diff HEAD --
  docs/plan/planning/observations.md`.
- **klasse:** *Ein Artefakt formuliert eine Regel und verletzt sie im selben Diff.*

### N-4 — Zwei stehende Zusagen stellen den Übersprung als hinreichend dar; es gibt nur einen Beleg-Slot

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*) · `BEO-025` (`docs/plan/planning/observations.md`, 3×, geplant → `slice-181`)
- **pfad:** `harness/tools/mutate.sh:57-61` (Absatz *BELEG STATT LAUF*) · `harness/README.md:73`
- **befund:** Beide Texte sagen sinngemäß *„War der letzte Lauf über demselben Prüfgegenstand
  vollständig grün, gibt dieser Lauf diesen Beleg aus"* — eine hinreichende Bedingung. Der Code
  führt **einen** Slot (`BELIEF`), und `clear_belief` (`:1490`) räumt ihn bei jedem nicht
  übersprungenen Lauf. Gemessen, nicht abgeleitet: Beleg über Baum `K` grün → Baum auf `K2` ändern
  → Lauf über `K2` bricht ab → Baum zurück auf `K` → **kein** Übersprung, der Treiber fährt wieder
  voll, die Beleg-Datei ist weg. Der letzte Lauf über `K` war grün, die Zusage trifft trotzdem
  nicht zu. Nur der Kommentar an `clear_belief` (`:1485`) nennt die Ein-Slot-Eigenschaft; die zwei
  Zusagen, die DoD (3) zum Gegenstand hat, nennen sie nicht.
- **verifizierbar:** ja — die vierschrittige Sonde oben; sie braucht kein Docker.
- **klasse:** *Zusage nennt eine hinreichende Bedingung, der Code hält nur die notwendige*
  (= `BEO-025`-Klasse, konservative Richtung).

### N-5 — Eine mitwandernde Zahl steht zweimal im Plan ohne ihr Kommando und ist bereits überholt

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und 2 (Geltungsbereich: die **lebenden** repo-eigenen Markdown-Artefakte; ausgenommen
  sind nur `docs/reviews/**`, `docs/plan/planning/done/**`, `.harness/baseline/**` und Vorlagen)
- **pfad:** `docs/plan/planning/in-progress/slice-180-…md:530` und `:627` (dazu, außerhalb des
  MR-Geltungsbereichs, `harness/tools/mutate.sh:1462`)
- **befund:** Beide Stellen schreiben *„57 von 1055 (Schlüssel-)Pfaden"* als Beleg — ohne das
  Kommando, das die Zahl liefert, und ohne die Kennzeichnung als *kein Erwartungswert*. Die Zahl
  misst den Baum und wandert mit ihm: heute
  `bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files | wc -l"` →
  **1056**, und ohne die zwei untrackten Fall-Dateien **1054** (dieselbe Liste durch
  `grep -vc 'test/mutations/26[23]'`). Sie ist damit im selben Dokument schon überholt, das die Nicht-Erwartungswert-Marke an zehn Stellen mitführt
  (`grep -c 'Erwartungswert' docs/plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md` → **10**).
- **verifizierbar:** ja — das Kommando oben gegen die zitierte Zahl. Kein Modul aus `modules:` der
  `.d-check.yml` prüft Zahlen gegen Kommandos.
- **klasse:** *Mitwandernde Messzahl ohne ihr Kommando und ohne Nicht-Erwartungswert-Marke.*

---

## Negativbefunde (geprüft, ohne Befund)

- **Fall 263 trifft die reale Stelle, nicht eine Attrappe:** der `sed`-Anker löscht in einer
  Wegwerf-Kopie exakt `harness/tools/mutate.sh:1490` und nichts sonst; die zwei anderen Vorkommen
  von `clear_belief` (Definition `:151`, Aufruf in `finalize_belief` `:164`) sind durch Einzug und
  Klammern vom Anker ausgeschlossen — nachgerechnet mit `grep -n … | cat -A`.
- **Fall 262 färbt seinen Wächter rot:** Rumpf des Tests *„driver: jeder von prepare_isolation
  kopierte Pfad geht in den Schluessel ein oder steht in der Ausnahmeliste"* gegen ein Mini-Repo
  gefahren — unmutiert `GRUEN`, mit der Mutation aus Fall 262 `ROT: unerklaerter Pfad:
  harness/tools/mutate.sh`. Beide Mengen kommen aus den echten Funktionen.
- **Fall 74 trifft die neue Definition:** sein Anker ersetzt in einer Wegwerf-Kopie
  `ISOLATION_EXCLUDES=(./.harness/state)` durch die Fassung mit `./.git` — die Stelle, die
  `prepare_isolation` benutzt.
- **`make gates` selbst gefahren, EXIT 0.** Darin `d-check: 597 Datei(en) geprüft, 0 Befund(e)`
  (deckt die vom Implementer berichtete `docs-check`-Zahl), `comment-claims: 55 Datei(en) geprueft,
  0 Befund(e)`, bats bis `ok 217` und `grep -c '^not ok'` → 0, `baseline-verify: v5.18.0 OK`,
  `span-check` grün. Zweiter Lauf nach dem Schreiben dieses Reports ebenfalls EXIT 0, dann
  `d-check: 598 Datei(en) geprüft, 0 Befund(e)` — die Zahl wandert mit dem Bestand und ist kein
  Erwartungswert ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
- **`make mutate`-Beleg — geprüft, passt *nicht* zum aktuellen Baum, und das ist erklärbar:**
  `.harness/state/mutate-passed.key` trägt `0676269c…` (geschrieben 15:27:55), der Schlüssel des
  jetzigen Baums ist `e682e753…`. Einzige Datei, die nach dem Beleg-Lauf noch bewegt wurde:
  `docs/plan/planning/in-progress/slice-180-…md` (15:29:37) — der Lauf kann sein eigenes Ergebnis
  nicht in eine Datei schreiben, die in seinem Schlüssel liegt. Kein Mutations-Fall adressiert
  `docs/` (`sed -n 's/^# files: //p' test/mutations/*.sh | … | grep -c '^docs/'` → 0), das Verdikt
  `249 ok` bleibt in der Sache unberührt. Die Fall-Zahl stimmt: `ls test/mutations/*.sh | wc -l`
  → **249**.
- **Der Positiv-Pfad funktioniert überhaupt:** über passendem Beleg meldet der Treiber den
  Übersprung und endet mit Exit 0 — gemessen, damit N-1 nicht mit „der Zweig ist tot" verwechselt
  wird.
- **Die Reihenfolge zum Lock ist unverändert korrekt:** `mkdir "$LOCK"` (`:1424`), `HAVE_LOCK=1`
  (`:1430`), Beleg-Block ab `:1467` — der Übersprung sitzt hinter dem Mutex.
- **`finalize_belief` steht weiter am Ende von `main()`** (`:1653`), unmittelbar vor dem
  Status-Ausdruck `[ "$fail_count" -eq 0 ]`; `fail_count` ist dort endgültig.
- **`harness/README.md`:** die neue Passage nennt Bezugsmenge, deklarierte Ausnahme und benannten
  Rest; ihre zwei neuen Links lösen relativ zu `harness/` auf (`make docs-check` innerhalb von
  `make gates` grün). Die Einschränkung aus N-4 betrifft ihren Wortlaut, nicht ihre Verweise.
- **Register-Form der vier neuen Zeilen:** alle tragen die sechs Spalten, Zähler `1×`, Beleg
  `slice-180`, Stand `offen — Erstauftreten`; die Abgrenzungen zu `BEO-026`/`BEO-031` stehen. Nach
  LOW-1 rendert auch `BEO-034` vollständig.
- **Datei-Modi der neuen Fälle** (`664`/`775`) liegen im Bestandsspektrum
  (`stat -c '%a' test/mutations/*.sh | sort | uniq -c` → vier Modus-Klassen); die Fälle laufen über
  `bash "$case_file"`, der Modus trägt nichts.
- **`AGENTS.md` §3.2/§3.5/§3.8/§3.9:** unverändert kein Verstoß — keine Inline-Suppression, keine
  Gate-Lockerung ohne ADR, keine Hard-Rule-/Konventions-Datei im Diff, keine Host-Toolchain.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Exit-0-Zweig ohne Wächter, nicht in der Lücken-Aufzählung der ADR (N-1) |
| MEDIUM | 3 | Befund-Kennung + überholte Zeilennummer im Kommentar (N-2) · Artefakt bricht die Regel, die es ausspricht (N-3) · Zusage hinreichend, Code notwendig (N-4) |
| LOW | 1 | Mitwandernde Zahl ohne Kommando (N-5) |
| INFO | 0 | — |

**Erledigt aus Runde 1:** 2 HIGH, 2 MEDIUM (eines mit gemessener Rest-Lücke, die in N-1 aufgeht),
3 LOW. **Offen aus Runde 1:** MEDIUM-3 (Register-Timing) — unverändert, jetzt zusätzlich als
Selbstwiderspruch sichtbar (N-3); INFO-1 unverändert.

**Wiederkehrende Klassen für den Steering-Loop-Zähler:** `BEO-025` (N-4 — die Zusage-weiter-als-der-
Code-Klasse, in diesem Slice zum zweiten Mal, Ausgang bereits **geplant** → `slice-181`).
Nach der Vorgangs-Regel (*„Ein Vorgang zählt einmal"*) ist das **kein** zusätzlicher Zählerschritt
gegenüber Runde 1: `slice-180` ist derselbe Vorgang. N-1, N-2, N-3 und N-5 tragen keine bestehende
Kennung; ob sie eine bekommen, entscheidet der Closure-Schritt, nicht dieser Report.

## Verdikt

**Erneut blockiert — aber deutlich enger als Runde 1.** Beide HIGH aus Runde 1 sind behoben und
mit eigenen Sonden bestätigt; die Fixes sind sauber verdrahtet und Fall 263 hat echte Zähne.

Blockierend ist **N-1**: der Slice führt einen Zweig ein, der Exit 0 liefert, ohne einen einzigen
Fall gefahren zu haben, und die Bedingung, die diesen Zweig eng hält, ist die einzige der drei, für
die kein Gegenbeispiel rot gesehen wurde. Ich habe das stille Grün mit einer Ein-Zeichen-Mutation
real erzeugt und gleichzeitig gemessen, dass kein bats-Test und kein Mutations-Fall dabei rot wird —
in CI läuft der Zweig strukturell nie. Das ist dieselbe Fehlerklasse wie HIGH-1 aus Runde 1, nur
eine Bedingung weiter rechts, und die ADR führt sie unter *Was kein Wächter hält* nicht auf. Nach
[`AGENTS.md`](../../AGENTS.md) §3.6 ist die Zusage „Bedingung 6" damit nicht fertig.

**N-2, N-4 und N-5 sind Text-Befunde an neu geschriebenen Zusagen** — kleine Eingriffe, aber §3.7
und `MR-025` sind Repo-Norm und der Cutoff greift für neu geschriebenen Text.

**N-3 gehört nicht dem Implementer.** Die Rollen-Frage *wer schreibt `observations.md`* hat in
diesem Repo keine geschriebene Quelle (`BEO-007`, geplant → `slice-151`); was hier neu ist, ist der
Widerspruch **innerhalb** des Plans. Widerspricht der Implementer der Einordnung, ist der Weg
nicht die Herabstufung, sondern der Konflikt-Pfad aus `modul-08-agentenrollen.md` §Konflikt-Pfad
als Rollen-Sequenz — mit einem Architect-Verdikt als Artefakt.

**Was ich nicht geprüft habe:** die DoD-Abhakung, die Vollständigkeit und die Wanduhr-Zahlen der
berichteten `make mutate`-Läufe und die Closure-Notiz als Verifikations-Gegenstand. Den
`make mutate`-Beleg habe ich nur auf Passung zum Baum geprüft (siehe Negativbefunde), keinen
Neu-Lauf gefahren.
