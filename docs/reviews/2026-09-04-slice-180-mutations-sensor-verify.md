# Review slice-180 — Beleg statt Lauf im Mutations-Sensor

**Rolle:** Reviewer (Modul 8, frischer Kontext) · **Datum:** 2026-09-04 ·
**Skill:** `.harness/skills/reviewer.md` 1.6.0 · **Baseline:** `v5.18.0`

**Gegenstand:** unkommittierter Arbeitsbaum gegen `HEAD` (`65b5b3e`) —
`git diff --stat` → 6 Dateien, 372 Einfügungen, 42 Löschungen, dazu
`test/mutations/262-mutate-schluessel-ausnahme-nicht-deklariert.sh` als untrackte Datei.

**Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan):**

- **Diff:** `git diff` über `harness/tools/mutate.sh`, `harness/README.md`,
  `test/mutate-driver.bats`, `test/mutations/74-mutate-kopie-ohne-git.sh`,
  `docs/plan/planning/observations.md`, `docs/plan/planning/in-progress/slice-180-…md`
  plus die neue Fall-Datei 262.
- **Slice-Plan:** [`slice-180`](../plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md)
  (`in-progress/`, Verantwortlich Implementer).
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- **Aktive ADRs:** [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (`Proposed`, vier Festlegungen + Fitness Function),
  [ADR-0003](../plan/adr/0003-go-native-binaries.md) (Docker-only),
  [ADR-0013](../plan/adr/0013-technik-stratum-als-zielort.md) (Zielort, hier ausdrücklich offen).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.1, §3.5, §3.6, §3.7, §3.8, §3.9.
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-09-0*-slice-175-*` (Wächter-
  Verdrahtung), dazu die offenen Registerzeilen `BEO-025`, `BEO-026`, `BEO-028`, `BEO-030`.

**Nicht geprüft (Rollen-Grenze):** DoD-Abhakung und Gate-Lauf-Bestätigung — das ist
Verifier-Arbeit. `make gates` habe ich einmal gefahren, aber **nur**, weil der Stop-Hook
einen Nachweis über dem geänderten Baum verlangt; als DoD-Beleg zählt dieser Lauf nicht.

---

## Findings

### HIGH-1 — Ein Beleg überlebt den Lauf, der ihn widerlegt; vier Zusagen behaupten das Gegenteil

- **kategorie:** HIGH
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4
- **pfad:** `harness/tools/mutate.sh:1633` (Aufrufort von `finalize_belief`) ·
  `harness/tools/mutate.sh:146-153` (`clear_belief`-Kommentar) ·
  `harness/tools/mutate.sh:52-55` (Kopf, Bedingung 6) ·
  `harness/tools/mutate.sh:1467` (Übersprung-Meldung) · `harness/README.md:73`
- **befund:** `finalize_belief` steht als **letzte** Anweisung von `main()`; jeder rote
  Ausgang **davor** verlässt `main()` per `exit`, ohne einen bestehenden Beleg zum
  **gleichen** Schlüssel zu entfernen. Betroffen sind sechs Ausgänge nach der
  Beleg-Prüfung: leerer Fall-Satz (`:1484`), Fingerabdruck nicht berechenbar (`:1491`),
  unbekannter `# verify:`-Modus (`:1524`), `require_isolated` (`:1565`, `:1578`), der
  **Grün-Vorlauf** (`:1580`) und der Signal-Zweig (`on_signal`, `:444`/`:460`/`:469`).
  Der Grün-Vorlauf ist der schwerwiegende: er misst, dass der Baum **vor** jeder Mutation
  grün ist, und genau sein Fehlschlag ist der Docker-Cache-Fall, für den
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 4 `MUTATE_FORCE` als Träger benennt. Die Meldung des Folgelaufs sagt dann
  wörtlich *„seit dem letzten vollstaendig gruenen Lauf unveraendert"*, obwohl der letzte
  Lauf über genau diesem Schlüssel rot endete. Dieselbe Aussage steht in drei weiteren
  stehenden Zusagen: `clear_belief` sagt *„ein Lauf, der trotz uebereinstimmendem
  Schluessel rot wird (moeglich unter MUTATE_FORCE), widerlegt die vorige Zusage, und ein
  spaeterer, nicht erzwungener Lauf darf sie nicht erben"*; Bedingung 6 im Kopf sagt *„ein
  Lauf mit Befund hinterlaesst KEINEN Beleg"*; `harness/README.md:73` sagt *„War der letzte
  Lauf über demselben Prüfgegenstand vollständig grün …"*.
- **verifizierbar:** ja — real reproduziert, nicht abgeleitet. Kopie des Treibers in ein
  Wegwerf-Repo mit einem Fall, dessen `# verify:`-Kopf einen unbekannten Modus nennt (der
  Abbruch bei `:1524`, gewählt weil er ohne Docker auskommt und derselben Klasse angehört):

  ```sh
  FAKE=$(mktemp -d); mkdir -p "$FAKE"/{harness/tools,test/mutations,.harness/state}
  cp harness/tools/mutate.sh "$FAKE/harness/tools/"
  printf '%s\n' '#!/usr/bin/env bash' '# files: datei.txt' '# expect: irgendwas' \
    '# verify: unbekannter-modus' 'set -euo pipefail' 'true' > "$FAKE/test/mutations/01-demo.sh"
  printf 'inhalt\n' > "$FAKE/datei.txt"
  bash -c "source '$FAKE/harness/tools/mutate.sh' 2>/dev/null||true; isolation_key" \
    > "$FAKE/.harness/state/mutate-passed.key"
  MUTATE_FORCE=1 bash "$FAKE/harness/tools/mutate.sh"; echo "exit=$?"   # ABBRUCH, exit=1
  bash "$FAKE/harness/tools/mutate.sh"; echo "exit=$?"                  # Beleg liegt vor, exit=0
  ```

  Ergebnis hier und heute: Lauf 1 endet mit `mutate: ABBRUCH — unbekannter '# verify: …'`,
  Exit 1, und der Beleg liegt danach unverändert; Lauf 2 gibt
  `mutate: Beleg fuer Pruefgegenstand … liegt vor … — seit dem letzten vollstaendig gruenen
  Lauf unveraendert. Kein Fall-Lauf.` aus, Exit 0.
- **klasse:** *Invalidierungs-Punkt liegt hinter Ausgängen, die ihn umgehen — ein Beleg
  überlebt den Lauf, der ihn widerlegt.*

### HIGH-2 — Der Kommentar am Schlüssel-Punkt nennt einen Geltungsbereich und einen Sensor, die 997 von 1054 Pfaden nicht decken

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der
  Code hält"*) · `BEO-025` (`docs/plan/planning/observations.md`, 3×, **geplant** →
  `slice-181`)
- **pfad:** `harness/tools/mutate.sh:1455-1461`
- **befund:** Der Kommentar begründet die einmalige Schlüssel-Berechnung mit *„weil der
  Host-Baum waehrend eines Laufs unveraendert bleibt — erzwungen von der fuenften
  fail-closed-Bedingung, Sensor: test/mutate-driver.bats „driver: run_case meldet einen
  HOST-Treffer und BRICHT AB""*. Die fünfte Bedingung erzwingt das für den Host-Baum nicht:
  ihr Fingerabdruck (`target_fingerprint`, `:243`) deckt ausdrücklich **nur** die
  `# files:`-Ziele, und der Kommentar darüber sagt das selbst — *„BEWUSST NUR die
  Mutations-Ziele, nicht der ganze Baum: sonst roetet jede parallele Arbeit am Repo (Doku,
  Slice-Dateien, Reviews) den Lauf"*. Gemessen sind das **57** Pfade
  (`sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u | wc -l`)
  gegen **1054** Pfade im Schlüssel
  (`bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files | wc -l"`;
  keine Erwartungswerte). Der genannte Sensor sieht den ausgegrenzten Rest also nicht — das
  ist `BEO-025` wörtlich (*„nennt einen Sensor, der den ausgegrenzten Rest nicht sieht"*),
  und dessen Ausgang ist bereits vergeben. Die funktionale Folge ist eng — zwischen der
  Schlüssel-Berechnung (`:1463`) und den Isolationskopien (`:1562-1566`) liegt nur die
  Modus-Zulassung —, aber der Befund ist die Zusage, nicht ihre Breite: §3.6 bindet den
  Text an das, was der Code hält.
- **verifizierbar:** ja — die zwei Kommandos oben; `make comment-claims` bestätigt den
  Befund **nicht**, weil es die Existenz eines genannten Sensors prüft, nicht seinen
  Geltungsbereich (`make comment-claims` → `55 Datei(en) geprueft, 0 Befund(e)`).
- **klasse:** *Zusage nennt einen Geltungsbereich und einen Sensor, die der ausgegrenzte
  Rest nicht trägt* (= `BEO-025`).

### MEDIUM-1 — Fitness-Function-Zeile 3 misst die ausgelagerte Funktion, nicht den Schreibpunkt in `main()`

- **kategorie:** MEDIUM
- **quelle:** [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  §Fitness Function, dritte Zeile · `BEO-028`
- **pfad:** `test/mutate-driver.bats:988-1011` (die zwei `finalize_belief`-Tests) gegen
  `harness/tools/mutate.sh:1633`
- **befund:** Die dritte Fitness-Function-Zeile lautet *„Ein Lauf mit mindestens einem
  Befund hinterlässt keinen Beleg — **der Schreibpunkt liegt hinter der Bedingung, unter
  der `main()` seinen Exit-Status bildet**"*. Beide neuen Tests rufen `finalize_belief`
  direkt mit gesetztem `fail_count` auf; keiner erreicht `main()`. Die zweite Hälfte der
  Zusage — der **Ort** des Aufrufs — steht nur im Test-Kommentar (*„Gemessen ist
  finalize_belief selbst — main() ruft keine andere Funktion an dieser Stelle"*) und ist
  damit behauptet, nicht gemessen. Ein Diff, der `finalize_belief "$belief_key"` aus
  `main()` entfernt oder vor die Fall-Schleife zieht, färbt keinen Wächter rot: in
  `test/mutations/` adressiert kein Fall diese Zeile
  (`grep -rl 'finalize_belief' test/mutations/ | wc -l` → 0), und `make test` fährt `main()`
  nicht.
- **verifizierbar:** ja — `grep -rl 'finalize_belief' test/mutations/`; und ein Probelauf
  von `make mutate` über einem Baum, aus dem die Zeile entfernt wurde, bliebe grün.
- **klasse:** *Zahn misst die ausgelagerte Funktion statt der Verdrahtung, die der Aufrufer
  benutzt* (= `BEO-028`).

### MEDIUM-2 — Der Register-Schluss der Closure-Notiz steht auf einem veralteten Zähler-Stand

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
  (Lese-Schritt) · `BEO-030`
- **pfad:** `docs/plan/planning/in-progress/slice-180-…md:612` und `:644-646` gegen
  `docs/plan/planning/observations.md` (Zeile `BEO-025`)
- **befund:** §8 des Plans führt `BEO-025` als *„(2×, offen)"* und schließt daraus
  *„Keine dieser Zeilen erreicht mit diesem Slice 3× — die zwei Kandidaten (`BEO-025`,
  `BEO-026`) stehen bei 2×"*. Das Register führt `BEO-025` bei **3×** mit drei Belegen und
  dem Ausgang **geplant → `slice-181`**
  (`awk -F'|' '/^\| BEO-025 /{print $5, $6}' docs/plan/planning/observations.md`). Der
  Stand kippte, als `slice-175` schloss (`6b3f61d`, „Lese-Schritt bei 3x"), also **nach**
  dem Plan-Commit `91c9085`. Die Closure-Notiz §7 baut darauf auf und sagt *„Keine
  bestehende Zeile wurde erhöht"*, ohne den Ist-Stand gegen das Register zu halten — HIGH-2
  oben ist ein weiterer Fund derselben Klasse und gehört als Beleg an `BEO-025`, nicht an
  eine neue Kennung. Das ist die Fehlerrichtung, die `BEO-030` beschreibt: *keiner erreicht
  die Schwelle* statt *einer hat sie erreicht*.
- **verifizierbar:** ja — das `awk` oben gegen die zitierte Zahl; `git log --format='%h %ad'
  --date=short 6b3f61d 91c9085` zeigt die Reihenfolge.
- **klasse:** *Sichtungs-Schritt zitiert einen Zähler-Stand, den das Register nicht (mehr)
  trägt* (= `BEO-030`, zweites Auftreten).

### MEDIUM-3 — Der Implementer schreibt in das Beobachtungs-Register; alle 27 rollen-gezeichneten Vorgänger sind Closure-Schritte

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
  (*„Eingetragen wird bei der **Slice-Closure**"*) · `modul-08-agentenrollen.md`
  §Rollen-Sequenz für einen Slice (`P->P: Closure in done/ + Lerneintrag`) ·
  `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln (drei Quellen)
- **pfad:** `docs/plan/planning/observations.md:79-82`
- **befund:** Die vier Zeilen entstehen im Implementer-Lauf, während der Slice in
  `in-progress/` liegt und Review wie Verifikation noch ausstehen. Drei beobachtbare
  Folgen: **(a)** der Beleg `slice-180` benennt einen Vorgang, der nicht abgeschlossen ist
  — `modul-06` verlangt für den Beleg *„die Kennung eines abgeschlossenen **Vorgangs**"*;
  vorgesehen ist das Schreiben vor dem `git mv` (die Lage-Prüfung läuft danach), nicht vor
  dem Review. **(b)** Die dritte der drei Quellen, die den Closure-Eintrag speisen —
  *„wiederkehrende Finding-Klasse aus dem Review dieses Slice"* — kann in einem vor dem
  Review geschriebenen Eintrag nicht enthalten sein; dieser Report liefert sie gerade
  (HIGH-2 → `BEO-025`, MEDIUM-2 → `BEO-030`), und der Satz *„Keine bestehende Zeile wurde
  erhöht"* ist damit schon jetzt überholt. **(c)** Führt der Review zur Rückführung
  `in-progress → next`/`open`, die §4 des Plans ausdrücklich vorsieht, stehen vier
  Registerzeilen mit einem Beleg auf einen nicht geschlossenen Vorgang und mit einem Link
  in ein Verzeichnis, das der Slice verlassen hat. **Keine Quelle dieses Repos benennt die
  schreibende Rolle für `observations.md`** — das ist selbst eine offene Beobachtung
  (`BEO-007`, 4×, geplant → `slice-151`); der Befund stützt sich deshalb auf das
  **Timing** des Regelwerks, nicht auf eine Eigentums-Regel, und liegt darum unter HIGH.
- **verifizierbar:** ja — `git log --follow --format=%s -- docs/plan/planning/observations.md`
  → **61** Commits, davon **17** `Rolle Planner`, **10** `Rolle Architect`, **0**
  `Rolle Implement*`, **0** Reviewer/Verifier; die **11** rollenlosen inhaltlichen Commits
  tragen alle *„Closure"* im Betreff (dieselbe Liste ohne `slice-mv|welle-mv|Link-Abgleich`).
- **klasse:** *Ein stehendes, repo-weites Register wird vor dem Closure-Schritt
  fortgeschrieben, und eine seiner drei Quellen kann darin noch nicht enthalten sein.*

### LOW-1 — Vier unescapte `|` brechen die neue Registerzeile beim Rendern

- **kategorie:** LOW
- **quelle:** Maintainability · Form der Tabelle in
  `docs/plan/planning/observations.md` (Kopf `| Kennung | Beobachtung | Sub-Area | Zähler |
  Belege | Stand |`)
- **pfad:** `docs/plan/planning/observations.md:82` (`BEO-034`)
- **befund:** Die Zelle enthält `` `find … | sed 's|^\./||'` `` mit **rohen** Pipes. In
  GFM trennt ein `|` eine Tabellenzelle auch innerhalb von Backticks; die Zeile zerfällt in
  10 Zellen, von denen der Renderer die überzähligen verwirft — alles ab *„Das im Repo
  bereits etablierte Gegenmittel (`find … "* fällt aus der gerenderten Tabelle heraus,
  einschließlich des Trägers und der 3×-Folge. Die Zeile ist die einzige des Diffs mit
  rohen Pipes; **14** Bestandszeilen enthalten Pipes und escapen sie alle als `\|`.
- **verifizierbar:** ja —
  `awk '/^\| BEO-/{l=$0; e=gsub(/\\\|/,"X",l); r=gsub(/\|/,"|",l); if(r!=7) print substr($0,3,7), e, r}' docs/plan/planning/observations.md`
  → `BEO-009 2 8` (Bestand, außerhalb dieses Diffs) und `BEO-034 0 11`; Soll ist `roh=7`.
  Kein Modul aus `modules:` der `.d-check.yml` prüft Tabellen-Zellgrenzen.
- **klasse:** *Rohe Pipes in einer Markdown-Tabellenzelle verwerfen den Rest der Zelle.*

### LOW-2 — Fitness-Function-Zeile 1 hat keine Untergrenze für ihre Vergleichsmenge

- **kategorie:** LOW
- **quelle:** Maintainability · `BEO-034` (dieselbe Fehlerform: *„die Vergleichsmenge
  bleibt leer statt zu warnen"*) · Hausform im selben Skript
  (`harness/tools/mutate.sh:240-242`, `:335-341`)
- **pfad:** `test/mutate-driver.bats:938-969`
- **befund:** Der Test vergleicht `copy` gegen `key` und meldet jeden Pfad, der in keiner
  von beiden Mengen erklärt ist. Kommt `copy` **leer** zurück — etwa weil
  `prepare_isolation` eine Kopie anlegt, in die nichts geschrieben wurde —, ist `diff` leer,
  die Schleife läuft nie, der Test ist vakuär grün. Eine Untergrenze (`[ -n "$copy" ]`)
  fehlt, während `target_fingerprint` und `isolation_key` im selben Skript genau diese
  Untergrenze fahren und ihre Begründung mitliefern: *„zwei leere Hashes waeren gleich und
  meldeten ‚unveraendert', ohne je gemessen zu haben"*. Der symmetrische Fall ist gedeckt:
  ein leeres `key` färbt rot, ein fehlgeschlagenes `prepare_isolation` bricht am
  `errexit` der Zuweisung ab (nachgeprüft, nicht angenommen — die `cd`-Fehlerform lässt
  die Kommando-Substitution scheitern).
- **verifizierbar:** ja — Testrumpf mit einem `dest`, dessen Kopie leer ist; die Zusicherung
  bleibt grün.
- **klasse:** *Zusicherung ohne Untergrenze für ihre Vergleichsmenge ist über der leeren
  Menge vakuär wahr.*

### LOW-3 — Eine `Stand`-Zelle erzählt die Entstehung des eigenen Textes

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7, *Dieselbe Regel für Zustandsfelder*
- **pfad:** `docs/plan/planning/observations.md:82` (`BEO-034`, Stand-Zelle)
- **befund:** Der Satz *„Das im Repo bereits etablierte Gegenmittel (…) war zum
  **Schreibzeitpunkt** nicht befolgt worden"* beschreibt, wie der Autor den Eintrag verfasst
  hat, im Plusquamperfekt — Chronik der Entstehung statt Zustand mit Beleg. Die
  HIGH-Verankerung des Skills (*Zustandsfeld trägt Chronik*) greift hier bewusst **nicht**:
  Zustand (`offen — Erstauftreten`) und Beleg (Test-Name, Image-Sonde) stehen vollständig
  da; beanstandet ist ein Satz daneben, nicht die Zelle an sich.
- **verifizierbar:** nein — kein Sensor liest Markdown-Zustandsfelder
  (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`).
- **klasse:** *Zustandsfeld trägt Entstehungs-Chronik des eigenen Artefakts.*

### INFO-1 — Der Schlüssel deckt Inhalt, die Kopie trägt zusätzlich Modi

- **kategorie:** INFO
- **quelle:** [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 2 (*Deckung wird gezeigt, nicht angenommen*)
- **pfad:** `harness/tools/mutate.sh:335-341` (`isolation_key`)
- **befund:** `fingerprint_of_list` hasht Datei**inhalte**; `tar` überträgt in die
  Isolationskopie zusätzlich die Datei-Modi. Ein reiner `chmod` bewegt den Schlüssel damit
  nicht, während er die Kopie verändert. **Ich habe keinen Fehlerpfad gefunden** — die
  Fälle laufen über `bash "$case_file"` (`harness/tools/mutate.sh:623`), also
  modus-unabhängig —, und die Zusage nennt die Einschränkung nicht; sie ist der einzige
  Rest der Deckungs-Aussage, der weder in `ISOLATION_KEY_EXEMPT` noch in Festlegung 4 steht.
- **verifizierbar:** nein (Annahme, kein beobachtetes Versagen).
- **klasse:** *Deckungs-Zusage über einem Inhalts-Hash nennt die Metadaten-Grenze nicht.*

---

## Antwort auf die drei Zusatzfragen zum Beobachtungs-Register

**1. Rollen-Grenze?** Ja, aber als **Timing**-Verstoß, nicht als Eigentums-Verstoß — siehe
MEDIUM-3. Die Deckungs-These *„eigene Beobachtung ist eine der drei Quellen"* trägt nicht:
`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln nennt die drei Quellen als
**Speisung des Closure-Eintrags**, nicht als Autorenschaft; und `modul-06-roadmap.md` sagt
zum Zeitpunkt ausdrücklich *„Eingetragen wird bei der Slice-Closure"*. Die eigene
Beobachtung des Implementers hat einen vorgesehenen Träger — §7 des Slice-Plans als
Übergabe-Artefakt, und genau so ist §7 hier auch überschrieben. Der Weg von dort ins
Register ist der Closure-Schritt. Gegen HIGH spricht, dass **keine** Quelle dieses Repos
die schreibende Rolle für `observations.md` benennt: [`AGENTS.md`](../../AGENTS.md) §3.8
deckt nur Hard Rules und den Adaptions-Block,
[ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
nur derivative Register (das Beobachtungs-Register ist Original), und
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nur
Anweisungssätze. Genau diese Lücke ist `BEO-007` (4×, **geplant** → `slice-151`).

**2. Präzedenzfälle?** Keine. `git log --follow --format=%s -- docs/plan/planning/observations.md`
liefert **61** Commits: **17** `Rolle Planner`, **10** `Rolle Architect`, **0**
`Rolle Implement*`, **0** Reviewer/Verifier/Validator, **34** ohne Rollen-Präfix. Von den
34 sind 23 mechanisch (`slice-mv`/`welle-mv`/`Link-Abgleich`); die verbleibenden **11**
tragen alle *„Closure"* oder den Anlege-Vorgang des Registers selbst (`slice-137`) im
Betreff. **Der Architect ist also präzedent, der Implementer nicht** — und die zehn
Architect-Commits sind ausnahmslos Closure-Commits (`slice-145`, `slice-157`, `slice-160`,
`slice-161`, `slice-166`, `slice-167`, `slice-169`, `slice-172`, `slice-179`, `slice-154`),
also ein Rollenwechsel am Closure-Schritt und nicht mitten in der Implementation. Der
Schreibzugriff aus einem laufenden Implementer-Kontext wäre der erste.

**3. Inhaltliche Form?** Überwiegend sauber, mit drei Einschränkungen.
- **Spalten:** alle vier Zeilen tragen die sechs Spalten des Kopfs; `BEO-031`–`BEO-033`
  sind formal korrekt (`roh=7` Pipes), `BEO-034` bricht (LOW-1).
- **Zähler/Stand:** `1×`, Beleg `slice-180`, Stand `offen — Erstauftreten` — richtig als
  Erstauftreten und **nicht** fälschlich als Schwellen-Übertritt markiert; die vier neuen
  Kennungen sind gegen die 30 Bestandszeilen auf Dopplung geprüft und beschreiben je eine
  eigene Klasse mit ausdrücklicher Abgrenzung (`BEO-033` gegen `BEO-026`, `BEO-032` gegen
  `BEO-031`). Der Beleg `slice-180` ist zum Schreibzeitpunkt allerdings kein
  abgeschlossener Vorgang (MEDIUM-3 (a)).
- **`MR-025`:** kein Verstoß. Die einzigen Zahlen in den vier Zellen sind
  `Alpine Linux v3.19` und `tar (busybox) 1.36.1` — **Versionen**, die
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 ausdrücklich nicht bindet (*„Zahlen ohne Messwert-Rolle (Versionen, Daten,
  Aufzählungen im Fließtext) bindet die Setzung nicht"*). Das nebenstehende
  `docker run --entrypoint sh $(BATS_IMAGE) …` liefert die zweite der beiden nicht und ist
  in einer Shell so auch nicht lauffähig (`$(BATS_IMAGE)` ist eine Make-Variable) — als
  Versions-Angabe bleibt das unterhalb der Setzung; ich melde es hier als Beobachtung, nicht
  als Finding.
- **Sub-Area:** alle vier tragen `*` wie alle 30 Bestandszeilen; das ist die als `BEO-004`
  bereits registrierte Eigenschaft dieses Repos und kein neuer Befund.

---

## Negativbefunde (geprüft, ohne Befund)

- **ADR-0035 Festlegung 3, „eine Definition, nicht zwei":** eingehalten.
  `prepare_isolation` (`:307`) und `isolation_key_files` (`:323`) lesen beide
  `ISOLATION_EXCLUDES` (`:274`) über dieselbe Umsetzung `isolation_tar_args` (`:291`);
  `harness/tools/working-tree-hash.sh` steht nicht im Diff (`git diff --stat`) und wird im
  Schlüsselpfad nicht gerufen.
- **Deklarierte Ausnahme:** `ISOLATION_KEY_EXEMPT=(./.git)` (`:285`) steht an derselben
  Stelle wie die Kopier-Definition, mit Grund, und ist Gegenstand der bats-Zusicherung —
  die drei Bedingungen (a)/(b)/(c) aus Festlegung 3 sind erfüllt.
- **Risiko 4 (kein Commit-Vergleich):** bestätigt. Im Schlüsselpfad steht kein `git`-Aufruf;
  `sed -n '323,341p' harness/tools/mutate.sh | grep -c 'git '` → 0.
- **Risiko 9 (Reihenfolge zum Lock):** bestätigt. `mkdir "$LOCK"` (`:1424`), `HAVE_LOCK=1`
  (`:1430`), Beleg-Prüfung ab `:1462` — der Übersprung sitzt hinter dem Mutex, und
  `cleanup` gibt den Lock über den EXIT-Trap wieder frei (im Reproduktions-Lauf zu HIGH-1
  beobachtet: kein liegengebliebenes `mutate.lock`).
- **Laufzustand außerhalb der Bezugsmenge:** `.harness/state` steht in
  `ISOLATION_EXCLUDES` und in `.gitignore:5`; das Schreiben des Belegs bewegt damit weder
  den eigenen Schlüssel noch den `MR-003`-Gate-Hash.
- **Fail-closed bei unberechenbarem Schlüssel:** `isolation_key` (`:335`) gibt über leerer
  Liste **keinen** Hash zurück, und `main()` schaltet in diesem Fall nur den Übersprung ab
  statt den Lauf — der Vorrang stimmt mit den Bedingungen 1–5 überein.
- **Übersprung-Meldung:** nennt Schlüssel, Ablageort, Zeitstempel und den benannten Rest und
  behauptet **keine** Fall-Zahl — die `BEO-026`-Klasse (Zähler-Label ≠ gezählte Einheit) ist
  vermieden.
- **Beide reparierten Mutations-Fälle treffen die reale Stelle:** in einer Wegwerf-Kopie
  angewandt ändert Fall 74 die Zeile `ISOLATION_EXCLUDES=(./.harness/state)` (`:274`) und
  Fall 262 die `tar`-Zeile in `isolation_key_files` (`:327`); beide Anker sitzen auf der
  Definition, die der Lauf benutzt, nicht auf einer Kopie davon. Die Reparatur von
  `-printf` auf `find … | sed 's|^\./||'` folgt dem im Repo etablierten portablen Muster
  (`baseline-verify.bats`, `courseset-fixture.bats`).
- **`MUTATE_FORCE` erreicht das Rezept in beiden Aufrufformen** — gemessen an einer
  Wegwerf-`Makefile`: sowohl `make ziel MUTATE_FORCE=1` als auch `MUTATE_FORCE=1 make ziel`
  legen die Variable in die Rezept-Umgebung. Die Asymmetrie zu `MUTATE_JOBS` (das im Rezept
  explizit durchgereicht wird) ist damit **kein** Befund.
- **CI:** der Übersprung kann dort nicht greifen — `MR-014` fährt auf frischem Klon,
  `.harness/state/` ist gitignored, und `grep -rn 'harness/state\|actions/cache' .github/workflows/`
  ist leer.
- **`AGENTS.md` §3.9 (Docker-only):** der Diff führt keine Host-Toolchain ein; der Schlüssel
  entsteht aus `tar`, `sed`, `grep`, `sort`, `sha256sum` — die Menge, die
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ohnehin voraussetzt.
- **`AGENTS.md` §3.5 (Gate-Lockerung ohne ADR):** kein Verstoß — die Zulässigkeitsfrage ist
  vor dem Code entschieden (ADR-0035 Festlegung 1), und der Slice-Plan trägt sie im Kopf.
- **`AGENTS.md` §3.8:** kein Verstoß — der Diff berührt weder Hard Rules noch
  `harness/conventions*`.
- **`AGENTS.md` §3.2 (Lint-Suppression):** kein `# shellcheck disable` und kein `//nolint`
  im Diff.
- **`make comment-claims`:** `55 Datei(en) geprueft, 0 Befund(e)` — jeder in den neuen
  Kommentaren genannte Sensor existiert (u. a. `„driver: run_case meldet einen HOST-Treffer
  und BRICHT AB"`, `test/mutate-driver.bats:172`). Der Gate sagt nichts über HIGH-2, weil er
  Existenz und nicht Geltungsbereich prüft.
- **`harness/README.md`:** die neue Passage nennt Bezugsmenge, deklarierte Ausnahme und
  benannten Rest, wie DoD (3) verlangt, und ersetzt die abgelöste Aussage, statt sie zu
  ergänzen; die zwei neuen Links (`ADR-0035`, `working-tree-hash.sh`) lösen relativ zu
  `harness/` auf.
- **Zwei vom Implementer berichtete Funde nachvollzogen:** der `-printf`-Defekt ist im Diff
  von `test/mutate-driver.bats` behoben (kein `-printf` mehr in der Datei,
  `grep -c 'printf' test/mutate-driver.bats` trifft nur `printf`-Ausgaben), und der
  veraltete `sed`-Anker in Fall 74 zeigt jetzt auf `ISOLATION_EXCLUDES` — beides am Baum
  geprüft, nicht aus dem Bericht übernommen.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 2 | Invalidierungs-Punkt hinter umgehenden Ausgängen · Zusage nennt Geltungsbereich und Sensor, die der Rest nicht trägt (`BEO-025`) |
| MEDIUM | 3 | Zahn misst Funktion statt Verdrahtung (`BEO-028`) · Sichtungs-Schritt auf veraltetem Zähler (`BEO-030`) · Register vor dem Closure-Schritt fortgeschrieben |
| LOW | 3 | Rohe Pipes in Tabellenzelle · Zusicherung ohne Untergrenze · Zustandsfeld trägt Entstehungs-Chronik |
| INFO | 1 | Deckungs-Zusage nennt die Metadaten-Grenze nicht |

**Wiederkehrende Klassen für den Steering-Loop-Zähler:** `BEO-025` (HIGH-2 — vierter Fund,
Ausgang bereits **geplant** → `slice-181`), `BEO-028` (MEDIUM-1), `BEO-030` (MEDIUM-2,
zweites Auftreten). Nach der Vorgangs-Regel (*„Ein Vorgang zählt einmal"*) ist das je ein
Zähler-Schritt mit Beleg `slice-180`, nicht drei.

## Verdikt

**Blockiert.** Zwei HIGH und drei MEDIUM. HIGH-1 ist der harte Blocker: der Sensor gibt
über einem Baum, dessen letzter Lauf rot endete, Exit 0 und die Aussage *„seit dem letzten
vollstaendig gruenen Lauf unveraendert"* aus — reproduziert, nicht abgeleitet. Das ist der
sechste Weg ins stille Grün, den der Diff schließen wollte, an einer Stelle, die keine der
drei Fitness-Function-Zeilen adressiert. HIGH-2 ist eine Zusage über einen Geltungsbereich,
den der genannte Sensor um 997 von 1054 Pfaden verfehlt.

MEDIUM-3 berührt eine Rollen-Grenze, für die dieses Repo keine geschriebene Quelle hat.
Widerspricht der Implementer, ist der Weg **nicht** die Herabstufung, sondern der
Konflikt-Pfad aus `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz — mit einem
Architect-Verdikt als Artefakt; die Lücke selbst liegt bereits als `BEO-007` (geplant →
`slice-151`).

**Was ich nicht geprüft habe:** die DoD-Abhakung, die Vollständigkeit der berichteten
`make mutate`-Läufe und die Wanduhr-Zahlen aus §7 — das ist Verifier-Arbeit in einem
getrennten Kontext. Die zwei berichteten Funde habe ich am Diff nachvollzogen, ihre
Lauf-Protokolle nicht nachgefahren.
