# Review-Report — ADR-0033 auf Konsistenz gegen ADR-0022, ADR-0003, ADR-0007

**Rolle:** Reviewer · **Datum:** 2026-09-09 · **Runde:** 1

**Gegenstand:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
(`Proposed`) — Konsistenz-Prüfung, **kein** Code-Diff-Review. Ausgelöst vom Acceptance-Trigger
jener Datei, der eine Reviewer-Runde gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md) verlangt.

**Baum-Stand beim Lauf:** `git status --porcelain` leer; `git log --format='%h %s' -1` →
`c230d961 Rolle Implementer: slice-129 -- test/mutations/273 haelt den Zahn nach der
closure-Erweiterung`.

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Prüfgegenstand ist eine
ADR statt eines Diffs, also tritt die Datei selbst an die Stelle von Diff und Slice-Plan.
Betroffene Anforderungen: `LH-FA-08`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
Referenzierte aktive ADRs: 0003, 0004, 0005, 0007, 0022, 0028, 0030 — **alle `Accepted`**,
gemessen je Datei über `grep -m1 '^\*\*Status:\*\*'`; keine superseded Referenz. Hard Rules:
[`AGENTS.md`](../../AGENTS.md) §3.4, §3.5, §3.6, §3.9, §3.11. Vorherige Findings am gleichen
Gegenstand: die drei Runden zu `slice-175` (Ablösung des Shell-Helfers), deren stehende Klasse
*„Sperren-Eingang an der Verdrahtung ungewächtert"* war — heute gedeckt
(`grep -c '^func Test' cmd/ai-harness-init/archive_welle_echt_test.go`).

**Mess-Disziplin:** Jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein
Erwartungswert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Belege aus dem Regelwerk tragen Tag, Datei, Abschnitt und Zitat und **nicht** den
lokalen Vendoring-Präfix ([ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
Festlegung 2) — dieser Report wird mit seinem Abschluss unveränderlich.

---

## Findings

### HIGH-1 — Der Accept-Übergang friert einen Baseline-Beleg in der verbotenen Adress-Form ein, und die Adresse ist bereits tot

- **kategorie:** HIGH
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und
  Träger 3(a) (`Accepted`, aktiv); [`AGENTS.md`](../../AGENTS.md) §3.4, §3.11
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:166`
- **befund:** Die Zeile belegt die Präsens-Aussage *„Die Stub-Vorlagen liegen im vendored Baum,
  an beiden Ebenen"* mit `ls .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l`
  → **2**. Der Beleg trägt den lokalen Vendoring-Präfix samt konkretem Tag — genau die Form, die
  ADR-0016 Festlegung 2 ausschließt (*„**Nicht** dazu gehören der lokale Präfix
  `.harness/baseline/<tag>/` und die Zeilennummer als alleiniger Locator"*), und der Tag macht sie
  zum **Beleg** statt zur erlaubten tag-losen Layout-Beschreibung (dieselbe Festlegung: *„ein Beleg
  nennt einen konkreten Tag, sonst belegt er nichts; eine Layout-Beschreibung nennt keinen"*). Die
  Adresse löst heute nicht mehr auf — der Baum steht auf `v6.5.0`
  (`ls -d .harness/baseline/*/` → ein Verzeichnis), das zitierte `ls` endet mit **Exit 2** und gibt
  nichts aus. Träger 3(a) bindet genau diesen Übergang: *„Bevor der Status eines ADR auf
  *Accepted* wechselt, werden seine Baseline-Belege in die Form aus Festlegung 2 gebracht"*, und
  dieselbe Festlegung entscheidet den Fall ausdrücklich — *„Ein Proposed-Artefakt ist **kein
  Bestand**, sondern wird geschrieben … Sein Beleg wird vor der Annahme in die Form gebracht, und
  zwar aus einem Kosten-Grund: nach der Annahme ist derselbe Satz durch §3.4 unerreichbar, und der
  Preis steigt von einer Zeile auf eine Folge-ADR."* Erschwerend: Die Datei behauptet in
  §Was diese Entscheidung an sich selbst anwendet das Gegenteil — *„Sie nennt **keine** bewegliche
  Pfad-Adresse"*. **Kein Sensor fängt das:** die Adresse steht als Inline-Code unter `.harness/`,
  und `codepaths.roots` führt `[spec, docs, harness]` — ein Pfad unter `.harness/baseline/`
  beginnt mit `.harness` und liegt außerhalb (die in
  [`harness/README.md`](../../harness/README.md) benannte Lücke). Schließt ein späterer Lauf diese
  Lücke, hat `docs/plan/adr/**` kein Referenz-Ventil: die drei baum-weiten `ignore-refs`-Paare
  decken `docs/reviews/**`, `docs/plan/planning/done/**` und
  `docs/plan/planning/observations/**` (`grep -c '^  - in: ' .d-check.yml` → **7**, davon die drei
  mit `refs: [".harness/baseline/**"]`), und
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 3 erklärt
  sie extensional geschlossen — ein vierter Baum ist eine Senkung nach §3.5 mit eigener ADR.
- **Failure-Szenario:** ADR-0033 wird `Accepted`; §3.4 friert die Zeile ein. Ein späterer Lauf,
  der die Stub-Quelle der Operation nachschlagen will, fährt das zitierte Kommando, bekommt
  Exit 2 und leere Ausgabe und kann nicht unterscheiden, ob die Vorlagen fehlen oder die Adresse
  tot ist. Die Reparatur kostet ab dann eine Folge-ADR statt einer Zeile — der Preis, den
  ADR-0016 Träger 3(a) ausdrücklich vermeiden soll.
- **verifizierbar:** ja, aber **nicht durch einen Gate-Lauf** — `make docs-check` bleibt grün, weil
  `codepaths` den Pfad nicht erreicht. Bestätigt durch:
  `ls .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-*.template.md; echo $?`
  → Exit **2**, und
  `grep -c '\.harness/baseline/v[0-9]' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **1**. Die Gegenprobe zum selben Kommando unter dem heutigen Tag gibt **2** Dateien.
- **klasse:** Baseline-Beleg mit lokalem Vendoring-Präfix friert am Accept-Übergang ein

### MEDIUM-1 — Ein tragender Regelwerks-Beleg nennt keinen Tag

- **kategorie:** MEDIUM
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2, Träger 3(a)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:295` (nachrangig: `:238`)
- **befund:** Der Acceptance-Trigger selbst stützt sich auf ein Verbatim-Zitat — *„ADR-Änderung:
  Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"* — und nennt
  dazu Regelwerks-Datei und Abschnitt, aber **keinen Tag**. Festlegung 2 verlangt drei Teile
  (Tag · Datei und Abschnitt · Zitat verbatim); hier sind es zwei. Dieselbe Datei führt die
  vollständige Form an anderer Stelle vor (Zeile 60 nennt den Tag), die Datei ist darin also mit
  sich selbst uneins. Zeile 238 verweist ebenfalls tag-los auf `modul-06-roadmap.md`
  §Wellen-Closure-Prozedur, dort allerdings ohne Zitat und damit als Zeiger statt als Beleg —
  nachrangig. Das Zitat ist inhaltlich korrekt: gegen den heutigen Stand `v6.5.0`,
  `modul-08-agentenrollen.md` §Rollen-Regeln, gemessen **1** Treffer.
- **Failure-Szenario:** Der Trigger, der den Accept-Übergang dieser Datei regiert, beruft sich auf
  eine Regelwerks-Stelle ohne Reproduzierbarkeits-Klammer. Ändert der Kurs den Satz in einem
  späteren Tag, ist an der eingefrorenen Datei nicht mehr ablesbar, gegen welchen Stand ihr eigener
  Annahme-Grund gemessen war — genau der Verlust, gegen den Festlegung 2 den Tag verlangt.
- **verifizierbar:** ja, ohne Gate:
  `sed -n '294,296p' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md` zeigt Datei und
  Abschnitt ohne Tag; die Gegenprobe zum Inhalt ist
  `grep -c 'ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz' .harness/baseline/v6.5.0/regelwerk/modul-08-agentenrollen.md`
  → **1**.
- **klasse:** Regelwerks-Beleg ohne Tag im einfrierenden Artefakt

### MEDIUM-2 — Festlegung 4 schließt den Emissions-Schritt mit einem Argument aus, das eine andere Konstruktion widerlegt — die Präzedenz führt genau die passende

- **kategorie:** MEDIUM
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  (die berufene Präzedenz); [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:253-265` (Festlegung 4)
  und `:369` (ihre Fitness-Zeile)
- **befund:** Festlegung 4 setzt *„ein eigener Emissions-Schritt entsteht nicht"* und begründet den
  Verzicht im Absatz darunter mit der Erfassungs-Antwort auf den fehlenden Träger: *„Dort schweigt
  ein Wrapper und endet erfolgreich … Ein ziel-seitiger Wächter über der Anwesenheit ist aus
  demselben Grund ausgeschlossen wie dort."* Beide widerlegten Konstruktionen — der schweigende
  Hook-Wrapper und der Anwesenheits-Wächter — sind für die Archivierung nicht im Angebot. Die
  Konstruktion, die im Angebot **ist**, führt dieselbe Präzedenz bereits aus: `harness/mk/erfassung.mk`
  ist ein emittiertes Fragment, das die **Nicht-Gate**-Unterkommandos des Trägers über `make`
  erreichbar macht, nichts an `GATE_CHECKS` hängt (im Kopf ausgeschrieben: *„ZWEI KOMMANDOS, KEIN
  GATE"*) und beim fehlenden Träger **laut** wird statt zu schweigen — also genau die Semantik, die
  Festlegung 4 fordert (*„Fehlt der Träger, **sagt** das Kommando es und färbt nichts rot"*). Der
  Mechanismus ist etabliert und billig: der Aggregator bindet die Fragmente per Glob
  (`grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` → **1**), und der Emitter legt
  heute mehrere ab (`grep -c 'harness/mk/' internal/emit/*.go | grep -v _test:0` — die Konstanten
  stehen in `emit.go`, `baseline.go`, `erfassung.go`, `enforce.go`, `archgate.go`). §Trägt die
  Präzedenz prüft die Berufung auf ADR-0022 in drei Teilen und lässt diesen vierten aus. Die Folge
  ist gemessen: der emittierte Baum nennt weder das Unterkommando noch eine Aufruf-Form —
  `grep -rln 'archive-welle' internal/emit/ | wc -l` → **0**,
  `grep -rln 'host-bin' internal/emit/ | wc -l` → **0**, und
  `grep -c 'harness/state/bin\|ai-harness-init' internal/emit/templates/commands/close-welle.md`
  → **0**. Die Fitness-Zeile, die Festlegung 4 selbst stellt (*„ein frisch gebootstrapptes Ziel
  erreicht das Unterkommando"*, Target `make full-smoke`), ist als einzige der sechs real noch
  offen: `grep -c 'archive' harness/tools/full-smoke.sh` → **0**.
- **Failure-Szenario:** Ein Adopter schließt eine Welle nach dem emittierten Anweisungssatz. Sein
  Repo trägt den Träger und damit die Fähigkeit, aber nichts in seinem Repo nennt sie: Der
  Anweisungssatz sagt ihm für den Werkzeug-Fall keine Aufruf-Form, kein `make`-Ziel existiert, und
  die einzige Stelle, an der die Erreichbarkeit behauptet wird, ist eine ADR, die er nicht bekommt.
  Er liest *„Hat dein Repo das Werkzeug nicht, ist die Bedingung nicht eingetreten"* und trägt das
  als Feststellung in seine Results-Notiz — obwohl das Werkzeug da ist. Die Zusage *„Die Fähigkeit
  geht ins Ziel"* ist dann formal wahr und praktisch nicht eingelöst, und kein Sensor sagt es:
  `make full-smoke` fährt die Strecke nicht.
- **verifizierbar:** ja — `make full-smoke` bestätigt den Befund heute **nicht**, weil es die
  Strecke nicht enthält; genau das ist die Lücke. Bestätigt durch die vier `grep`-Zählungen oben,
  je **0**.
- **klasse:** Begründung widerlegt eine andere Konstruktion als die ausgeschlossene

### MEDIUM-3 — Der Preis der Fähigkeit steht nur dort, wo der Adopter ihn nicht liest

- **kategorie:** MEDIUM
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 6 Punkt 3 und Festlegung 7 (`Accepted`, aktiv)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:213-218` (Festlegung 1,
  Preis-Absatz) und `:253-265` (Festlegung 4)
- **befund:** Festlegung 1 spricht den Preis aus: *„Wer den Träger startet, hat ab dieser
  Entscheidung ein Kommando, das ein fremdes Planning-Verzeichnis umschreibt. Das ist der Preis,
  und er steht hier statt in einem Kommentar."* Festlegung 4 legt diese Fähigkeit in jedes Ziel,
  das den Träger führt. Die berufene Präzedenz hat für dieselbe Lage — eine Fähigkeit wandert in
  ein fremdes Repo — ausdrücklich einen **geschriebenen Satz im Ziel** verlangt: ADR-0022
  Festlegung 6 Punkt 3 macht aus der Nicht-Zusage über den Span-Bestand *„einen **geschriebenen**
  Satz"* im Zielrepo, und Festlegung 7 stellt die Feldliste als tool-generiertes Dokument in den
  geprüften Doku-Bereich des Ziels. ADR-0033 übernimmt Träger, Unterkommando und Reichweite aus
  jener Entscheidung, nicht aber diesen Teil — und die einzige Stelle, an der der Preis steht, ist
  eine ADR dieses Repos. Ein Ziel bekommt keine:
  `ls internal/emit/templates/docs/plan/adr/` endet mit **Exit 2**, das Verzeichnis existiert
  nicht; nach ADR-0007 Festlegung 3 ist `docs/plan/adr/*` im Ziel `skip-if-present`. Keine der
  fünf Folgepflichten deckt die Lücke: Folgepflicht 5 verlangt nur, dass der Anweisungssatz
  *„erst auf das Kommando zeigt, wenn es läuft"*, und verweist für den Text auf
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), deren drei
  Festlegungen das **Eigentum** an einem Anweisungssatz regeln, nicht eine Offenlegungs-Pflicht.
- **Failure-Szenario:** Ein Adopter hat nach dem Bootstrap ein Binär im gitignorierten
  Zustands-Bereich, das er als Telemetrie-Schreiber kennengelernt hat. Dasselbe Binär löscht und
  committet auf Zuruf in seinem versionierten Planning-Baum. Nichts in seinem Repo sagt ihm das —
  weder der Anweisungssatz noch ein `.mk`-Fragment noch ein generiertes Dokument. Fährt er das
  Unterkommando versehentlich oder auf fremden Rat, ist der Schaden ein Commit in seinem Baum,
  und die Zusage, die ihn gewarnt hätte, steht in einer Datei, die er nie erhalten hat.
- **verifizierbar:** ja, ohne Gate — `ls internal/emit/templates/docs/plan/adr/; echo $?` → Exit
  **2**, und `grep -rln 'archive-welle' internal/emit/ | wc -l` → **0**. Kein Gate-Lauf bestätigt
  ihn, weil kein Sensor die Adopter-Sicht auf die Fähigkeitsfläche prüft.
- **klasse:** Fähigkeit ins Ziel ohne die Offenlegung, die die Präzedenz dafür verlangt

### LOW-1 — Die Fitness-Function-Tabelle friert einen Stand ein, der in beide Richtungen falsch ist

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:364-369`
- **befund:** Sechs Zeilen der Tabelle tragen den Vermerk **Geschuldet, nicht geliefert**
  (`grep -c 'Geschuldet, nicht geliefert' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **6**). Fünf davon sind geliefert: die drei Abnahme-Kriterien und die Vorlagen-Kopplung tragen
  heute Mutations-Fälle mit passenden `expect:`-Tests, und der Routing-Zahn ebenso — nachgemessen
  in den Negativbefunden unten. Genau eine ist real offen (Festlegung 4, `make full-smoke`, siehe
  MEDIUM-2). Mit dem Accept friert die Tabelle beides falsch ein: fünf Zeilen unterschätzen den
  Stand, eine trifft ihn. Präzedenz für den eingefrorenen Vermerk besteht — ADR-0020 und ADR-0022
  tragen ihn auf `Accepted` (dieselbe `grep`-Zählung, **3** bzw. **6**) —, dort allerdings vor der
  Arbeit; hier läge die Annahme danach.
- **Failure-Szenario:** Ein späterer Lauf sucht offene Wächter-Schulden und liest die Tabelle als
  Liste. Er baut fünf vorhandene Zähne ein zweites Mal oder schneidet einen Slice über bereits
  geschlossene Arbeit — und übersieht die eine Zeile, die wirklich offen ist, weil sie zwischen
  fünf falschen steht.
- **verifizierbar:** ja, ohne Gate — die sechs Zeilen gegen
  `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | wc -l` gehalten.
- **klasse:** geänderte Ableitung, stehengebliebene Zusage

### LOW-2 — Drei Messwerte sind gewandert; zwei davon, weil die Entscheidung inzwischen umgesetzt ist

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:155`, `:158`, `:162`, `:169`
- **befund:** Vier zitierte Zahlen geben heute andere Werte. **„Von vier Pins des Makefile"**
  (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile`) → heute **3**: Folgepflicht 4 ist eingelöst, der
  vierte Pin hat das Makefile mit seinem Gegenstand verlassen. **„sieben Mutations-Fälle"**
  (`grep -l 'archive-welle' test/mutations/*.sh | wc -l`) → heute **8**, und die Menge ist eine
  andere: die sieben Shell-Fälle sind fort, gezählt werden die Go-Fälle, die Festlegung 2 an ihre
  Stelle gesetzt hat. **„68 Report-Dateien"** (das `for`-Kommando im Kontext) → heute **106**.
  **„fünf Testdateien"** (`ls /Development/d-check/tools/archive-wave/*_test.go | wc -l`) → heute
  **7**. Keine der vier kippt ein Argument: die Pin-Zahl trug *„ein gepinntes Bild entfällt"* und
  ist damit erfüllt statt widerlegt; die 68 trugen *„der Suchraum ist nicht theoretisch"* und
  tragen es bei 106 stärker; die fünf trugen *„ein eigener Test je Gegenstand"* und tragen es bei
  sieben ebenso; die sieben Fälle trugen den Verlust-Posten, den Festlegung 2 ausdrücklich
  benennt. Die Datei erklärt im Bezug-Block ausdrücklich, dass keine Zahl ein Erwartungswert ist.
- **Failure-Szenario:** Ein späterer Lauf fährt eines der zitierten Kommandos zur Kontrolle, sieht
  eine andere Zahl und muss aus dem eingefrorenen Text erschließen, ob sich der Bestand bewegt hat
  oder die Aussage falsch war. Bei der Pin-Zahl ist die Verwechslungsgefahr am größten, weil der
  Satz im Präsens steht (*„existiert einer allein für das Packen des Archivs"*), während der Pin
  bereits fort ist.
- **verifizierbar:** ja, ohne Gate — die vier Kommandos oben.
- **klasse:** Präsens-Messwert im einfrierenden Artefakt

### INFO-1 — Die Gate-Zugehörigkeit des Ziels wird nirgends in der Entscheidung ausgesprochen

- **kategorie:** INFO
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  [`harness/README.md`](../../harness/README.md)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md` (gesamte Datei)
- **befund:** Die Entscheidung autorisiert einen Träger, der laut eigenem Wortlaut *„ein Kommando
  [bekommt], das ein fremdes Planning-Verzeichnis umschreibt"*, sagt aber an keiner Stelle, dass
  dieses Kommando außerhalb von `make gates` steht:
  `grep -c 'NICHT in gates\|nicht in gates\|kein Gate' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **0**. **Kein Verstoß:** Die Klassifikation ist an Rang 9 geführt und begründet —
  `grep -c 'kein Gate und in keiner Prerequisite-Kette' harness/README.md` → **3**, für dieses
  Ziel mit dem Satz *„es archiviert, es prüft nicht"* —, sie gilt gleichlautend für **26** Vorkommen im Makefile
  (`grep -c 'NICHT in gates' Makefile`), und die ADR **behauptet** kein Gate, berührt
  `LH-QA-01` also nicht. Notiert, weil eine Entscheidung, die reale Löschungen im versionierten
  Baum auslöst, ihre Nicht-Aufnahme in die Gate-Kette selbst tragen könnte, statt sie zu erben —
  dieselbe Datei spricht ihren übrigen Preis ausdrücklich aus.
- **verifizierbar:** ja — die drei `grep`-Zählungen oben.
- **klasse:** geerbte Klassifikation ohne eigene Aussage

### INFO-2 — Verwaiste Ausnahme-Zeile aus der Ablösung des Shell-Wegs

- **kategorie:** INFO
- **quelle:** Maintainability; ADR-0033 Festlegung 2
- **pfad:** `.d-check.yml:241`
- **befund:** Die `ignore-refs`-Liste des `codepaths`-Moduls führt `harness/tools/archive-welle.sh`.
  Die Datei ist mit der Ablösung des Shell-Wegs entfallen —
  `ls harness/tools/ | grep -c 'archive'` → **0** —, die Ausnahme hat damit keinen Gegenstand. Sie
  verdeckt heute nichts: kein lebendes Artefakt nennt den Pfad
  (`git grep -l 'harness/tools/archive-welle' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'`
  liefert allein `.d-check.yml` selbst). Es ist ein Implementer-Artefakt, kein Mangel der
  Entscheidung; notiert, weil Festlegung 2 den vollständigen Rückbau zusagt.
- **verifizierbar:** ja — `make docs-check` bleibt grün, die Zeile ist an den zwei `grep` oben
  ablesbar.
- **klasse:** verwaiste Gate-Ausnahme nach Rückbau

---

## Negativbefunde (geprüft, ohne Befund)

- **Gegen ADR-0003 — keine Kollision.** Die Entscheidung wählt ein Unterkommando des in Go
  geschriebenen, nativ ausgelieferten Produkt-Binärs; das ist die Vertriebsform, die ADR-0003
  §Entscheidung setzt. Ihre Alternative E wird mit derselben Begründung verworfen, die dort steht
  (*„Ein eigenes OCI-Image als *Vertriebsmittel* entfällt"*), und der Wegfall des vierten
  Bild-Pins arbeitet der Docker-only-Build-Disziplin zu statt gegen sie. Keine Festlegung von
  ADR-0033 verlangt eine Host-Toolchain oder einen zweiten Vertriebskanal.
- **Gegen ADR-0007 — keine Kollision, und die Anwendung ist korrekt.** Die Ablehnung von
  Alternative D (eigenständiges Go-Modul) trifft ADR-0007 in der Sache: ein Ziel bekäme fremden
  Quellbaum, `go.mod`, Bild und Makefile, also Bauschritt und Toolchain **vor** seinem eigenen
  Sprach-ADR — die *„code führt"-Inversion*, die jene Entscheidung ausschließt und deren
  Fitness-Zeile *„nach `init` (ohne Sprache) läuft `make gates` grün … **ohne** Skelett"* verlangt.
  Festlegung 3 von ADR-0033 schöpft aus dem vendored Baseline-Baum, den ADR-0007 Festlegung 3 der
  Klasse **konvergent** zuordnet — im Ziel also vorhanden. Die Annahme (b) der ADR benennt genau
  diese Abhängigkeit.
- **Gegen ADR-0022 — die drei geprüften Teile der Berufung tragen wirklich, verbatim
  nachgemessen.** Festlegung 1 und Festlegung 2 sind wortgleich zitiert (je **1** Treffer nach
  Whitespace-Normalisierung), und beide sind umgesetzt:
  `grep -c 'carrierDir = ' internal/emit/enforce.go` → **1** (der Ablageort `.harness/state/bin`;
  die Konstante liegt in `internal/emit`, nicht in `internal/archive` — die Datei-Angabe der ADR
  ist richtig) und `grep -c 'case "span-' cmd/ai-harness-init/main.go` → **2**. Auch die Korrektur
  des dritten Teils trägt: Festlegung 5(a) und 5(b) von ADR-0022 sind wortgleich zitiert (je **1**
  Treffer normalisiert) und sagen tatsächlich, was die ortsgebundene Fassung daraus macht. Die
  Zuordnung der eigenen Abzählung zu jener (deren B und C für *„entsteht im Ziel"*, D und E für
  *„wird geholt"*) stimmt mit der dortigen Alternativen-Tabelle überein.
- **Der tragende Baseline-Satz gilt am heutigen Stand weiter.** Gegen `v6.5.0`,
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur (Modul 6): *„Ob das Archiv vollständig ist,
  bezeugt nur der Archivierungs-Commit — deshalb gehört die Operation in ein Werkzeug und nicht in
  Handarbeit."* — **1** Treffer nach Whitespace-Normalisierung. Der Ausschluss von Alternative G
  ist also nicht durch den Baseline-Sprung veraltet. (Die naive, zeilenweise Suche gibt hier **0**,
  weil der Satz im Original umbricht; das ist ein Mess-Artefakt und kein Befund.)
- **Die drei Abnahme-Kriterien sind real bewacht, nicht nur behauptet.** Zu jedem existiert ein
  Mutations-Fall, der die ADR namentlich nennt, dessen `sed`-Muster im heutigen Quellstand **genau
  einmal** greift und dessen `expect:`-Test existiert: Kriterium 1 →
  `233-archive-welle-go-haenger-suchraum.sh` / `TestHaengerFindetVerweisAusReviewReport`;
  Kriterium 2 in beiden Hälften → `232-archive-welle-go-untrackt.sh` /
  `TestUnsauberGrundZaehltUntrackte` und `241-archive-welle-go-staging-explizit.sh` /
  `TestZuStagenNenntNurArchivStubsUndNachgezogene`; Kriterium 3 →
  `240-archive-welle-go-aufsteigender-verweis.sh` /
  `TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach`. Vier Muster, vier Treffer, vier Tests
  gefunden. **Was daran nicht geprüft ist:** ob die Fälle real rot färben — das ist ein
  `make mutate`-Lauf und Sache der Verifikation, nicht dieser Rolle. Der Satz der ADR, die
  Kriterien seien *„am Shell-Weg rot gesehen"*, ist am heutigen Baum nicht mehr nachvollziehbar,
  weil der Shell-Weg fort ist; nachvollziehbar ist die Go-Fassung.
- **Der Vorlauf der Implementation vor dem Accept ist kein Befund.** Der Shell-Helfer ist entfernt
  (`ls harness/tools/ | grep -c 'archive'` → **0**) und `make archive-welle` zeigt auf den Träger,
  obwohl die Datei `Proposed` steht. Die ADR entscheidet diesen Fall selbst: *„Bis dahin ist sie
  ein Architect-Verdikt und als solches das Übergabe-Artefakt, das der Port als Constraint liest;
  sie ist nicht eingefroren."* Das deckt sich mit `v6.5.0`, `modul-08-agentenrollen.md`
  §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer
  liest als Constraint"* — und [`AGENTS.md`](../../AGENTS.md) §3.4 bindet ab `Accepted`. Kein
  Verstoß.
- **Festlegung 2 ist vollständig vollzogen, bis auf die in INFO-2 genannte Zeile.** Kein
  Shell-Skript, kein bats-Satz (`ls test/ | grep -c 'archive'` → **0**), ein Träger hinter dem
  Target. Folgepflicht 3 ist ebenfalls eingelöst: die Target-Beschreibung in
  [`harness/README.md`](../../harness/README.md) beschreibt den Go-Träger und nicht mehr den
  Shell-Weg.
- **Die Abzählung der Wege ist auf ihrem eigenen Kriterium erschöpfend.** Herkunft des
  ausführenden Artefakts, aufgeteilt in *kein Artefakt · kein Bau · bestehendes Vertriebsstück ·
  neues Vertriebsstück · fremder Bau* — eine echte Partition; jedes Mitglied der Tabelle fällt in
  genau eine Klasse. Die Alternativen-Tabelle nennt für jede Option Pro **und** Contra, auch für
  die gewählte, und der Gegenposten von Alternative C (kleinste Fähigkeitsfläche) steht dort
  ungeschönt.
- **Die §Schärft-Aussage hält.** `grep -c 'span-emit\|span-report\|archive-welle' spec/architecture.md`
  → **0**; die Komponenten-Sicht führt keine Unterkommandos, ein drittes bewegt also keine
  `ARC-*`-Zeile.
- **Keine Gate-Lockerung ohne ADR** (§3.5) und **kein halluziniertes Gate** (`LH-QA-01`): Die
  Fitness-Function-Tabelle nennt ausschließlich existierende Targets (`make test`, `make mutate`,
  `make full-smoke`) und markiert die noch nicht gedeckten Zeilen als geschuldet, statt Deckung zu
  behaupten.
- **Keine Referenz auf eine superseded ADR:** alle sieben referenzierten ADRs stehen auf
  `Accepted`.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Baseline-Beleg mit lokalem Vendoring-Präfix friert am Accept-Übergang ein |
| **MEDIUM** | 3 | Regelwerks-Beleg ohne Tag im einfrierenden Artefakt · Begründung widerlegt eine andere Konstruktion als die ausgeschlossene · Fähigkeit ins Ziel ohne die Offenlegung, die die Präzedenz dafür verlangt |
| **LOW** | 2 | geänderte Ableitung, stehengebliebene Zusage · Präsens-Messwert im einfrierenden Artefakt |
| **INFO** | 2 | geerbte Klassifikation ohne eigene Aussage · verwaiste Gate-Ausnahme nach Rückbau |

**Zwei Adress-/Beleg-Befunde derselben Wurzel** (HIGH-1, MEDIUM-1) treffen dieselbe Regel —
ADR-0016 Festlegung 2 — an derselben Datei und am selben Übergang. Zusammen mit LOW-2, das
denselben Sprung an den Messwerten trifft, ist das die dritte Ausprägung eines Musters in diesem
Lauf: **eine noch änderbare Datei hat den Baseline-Sprung nicht mitgemacht und steht kurz davor,
den Rückstand einzufrieren.** Nach [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md)
§Kontext-Eskalation ist die dritte Wiederholung derselben Klasse ein Steering-Loop-Signal; ob der
Zähler-Schritt fällt und was er auslöst, entscheidet die Closure und nicht dieser Report.

---

## Verdikt

**Blockierender Befund: ja.**

**Was blockiert, ist HIGH-1** — und zwar den `Accepted`-Übergang, nicht die Entscheidung. Die
Richtung von ADR-0033 ist gegen alle drei genannten Vorgänger konsistent: Sie widerspricht keiner
bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007, ihre Selbstprüfung der Präzedenz hält
der Nachmessung stand (beide zitierten `grep`-Werte bestätigt, beide Zitate verbatim), und ihre
Ablehnung von D und E ist eine korrekte Anwendung jener Entscheidungen statt einer Berufung auf
sie. Blockierend ist die **Form**, in der die Datei eingefroren würde: Zeile 166 trägt einen
Baseline-Beleg mit lokalem Vendoring-Präfix und konkretem Tag, der heute ins Leere zeigt. ADR-0016
Träger 3(a) bindet genau diesen Übergang und nennt den Grund, aus dem er vorher greifen muss —
nach dem Accept kostet dieselbe Korrektur eine Folge-ADR statt einer Zeile, und `docs/plan/adr/**`
hat kein Referenz-Ventil, das den Befund später auffangen könnte.

**Die drei MEDIUM blockieren nach der Regel dieses Repos ebenfalls** (Skill §Ablage: *„HIGH und
MEDIUM blockieren typischerweise"*), und sie sind nicht formal: MEDIUM-1 trifft den Beleg des
Acceptance-Triggers selbst; MEDIUM-2 und MEDIUM-3 treffen Festlegung 4 — die einzige Festlegung,
deren Zusage heute weder eingelöst noch gemessen ist, und die ihren Emissions-Verzicht mit einem
Argument trägt, das die im Angebot stehende Konstruktion nicht berührt.

**Alle sechs blockierenden und nicht blockierenden Befunde sind behebbar, solange die Datei
`Proposed` steht.** Lösungswege stehen bewusst nicht in den Befunden (Skill §Anti-Pattern); die
Übergabe geht an den Architect, dem die Datei gehört.

**Für den Wiedervorlage-Weg gilt
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2:**
Da diese Runde einen blockierenden Befund meldet, ist der Beleg für den Accept-Übergang eine
**erneute Runde derselben prüfenden Rolle** — nicht die Nachmessung durch den Kontext, der die
Befunde auflöst.
