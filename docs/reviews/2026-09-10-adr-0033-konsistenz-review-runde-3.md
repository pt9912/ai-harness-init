# Review-Report — ADR-0033 auf Konsistenz gegen ADR-0022, ADR-0003, ADR-0007 (Runde 3)

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 3

**Gegenstand:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
(`Proposed`) — Konsistenz-Prüfung, **kein** Code-Diff-Review. Ausgelöst vom Acceptance-Trigger
jener Datei; sie verlangt eine Reviewer-Runde gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md). Diese Runde ist der Beleg, den
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach
einem blockierenden Befund fordert: eine **erneute** Runde derselben prüfenden Rolle, nicht die
Nachmessung des auflösenden Kontexts.

**Vorgängerinnen:** `2026-09-09-adr-0033-konsistenz-review.md` (Runde 1, 1 HIGH / 3 MEDIUM /
2 LOW / 2 INFO, blockierend) und `2026-09-10-adr-0033-konsistenz-review-runde-2.md` (Runde 2,
1 HIGH / 2 MEDIUM / 2 INFO, blockierend). Beide werden als **Kennung** genannt und nicht als
Pfad-Link: Ein Review-Report ist eines der Zeitdokumente, die die Operation dieser Entscheidung ins
Wellen-Archiv bewegt, und dieser Report friert mit seinem Abschluss ein
([`AGENTS.md`](../../AGENTS.md) §3.11, dieselbe Form, die ADR-0033 §Der Acceptance-Trigger für ihre
eigene Accept-Zeile verlangt).

**Behebung, die geprüft wird:** `f7dec1f9` („Rolle Architect: ADR-0033 — Review-Befunde der Runde 2
im Proposed-Fenster behoben"), **37** eingefügte und **22** entfernte Zeilen in **1** Datei
(`git show --stat f7dec1f9`).

**Baum-Stand beim Lauf:** `git log --format='%h %s' -1` →
`f7dec1f9 Rolle Architect: ADR-0033 -- Review-Befunde der Runde 2 im Proposed-Fenster behoben`.
`git status --porcelain` ist **nicht** leer: `internal/emit/emit.go` und
`internal/emit/templates/d-check.yml` tragen die unfertige Arbeit eines **fremden** Vorgangs
(`slice-073`). Keine der beiden ist Gegenstand dieses Reviews; jede Messung, die eine von ihnen
berührt, ist zusätzlich gegen den committeten Stand gehalten (namentlich
`grep -rln 'archive-welle' internal/emit/ | wc -l` → **0** und
`git grep -l 'archive-welle' HEAD -- internal/emit/ | wc -l` → **0**).

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Prüfgegenstand ist eine ADR
statt eines Diffs, also treten die Datei und der Behebungs-Commit an die Stelle von Diff und
Slice-Plan. Betroffene Anforderungen: `LH-FA-08`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
Referenzierte aktive ADRs: 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040 — **alle
`Accepted`**, je Datei über `grep -m1 '^\*\*Status:\*\*'` gemessen; keine superseded Referenz. Hard
Rules: [`AGENTS.md`](../../AGENTS.md) §3.4, §3.5, §3.6, §3.7, §3.9, §3.11. Vorherige Findings am
gleichen Gegenstand: die sechs der Runde 1 und die drei der Runde 2, jeder unten einzeln gegen
`f7dec1f9` gehalten.

**Mess-Disziplin:** Jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein
Erwartungswert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Belege aus dem Regelwerk tragen Tag, Datei, Abschnitt und Zitat und **nicht** den
lokalen Vendoring-Präfix ([ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
Festlegung 2).

**Gate-Verifikation — aufgeschoben, mit einer Ausnahme, und der Umfang ist benannt.** `make gates`,
`make mutate`, `make full-smoke`, `make test` und jeder `docker build` sind für diesen Lauf
untersagt (fremder Docker-Lauf, Speicherdruck); der Auftraggeber fährt `make gates` selbst.
**Was das kostet, ist unten bei HIGH-1 ausdrücklich benannt** und ändert dessen Ausgang nicht — der
Befund ist als **erschöpfende Fallunterscheidung** geführt, deren beide Zweige blockieren. Von den
übrigen Zielen in `make gates` hat allein `docs-check` eine Markdown-Datei in seinem Prüfbereich
(`comment-claims` bildet ihn aus vier Pfad-Mustern ohne Markdown,
[`AGENTS.md`](../../AGENTS.md) §4; `test`/`lint`/`build` sind Go, `shell-lint` Shell, `ci-lint`
Workflows, `baseline-verify` der vendored Baum, `span-check` der Träger). `docs-check` **ist**
gefahren, in der erlaubten Form — ein einzelner `docker run` gegen den in
[`d-check.mk`](../../d-check.mk) gepinnten Digest, `--network none`, Mount `:ro`, gegen eine
`git archive HEAD`-Kopie außerhalb des Repos:

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --config /repo/.d-check.yml
# d-check: 1067 Datei(en) geprüft, 0 Befund(e)   EXIT 0
```

**Keiner der drei Befunde unten wird von einem Gate-Lauf bestätigt**, und das steht bei jedem in
seiner `verifizierbar`-Zeile: `docs-check` prüft Adress-Auflösung, nicht Widerspruchsfreiheit und
nicht die Deckung einer Prosa-Aussage durch den Baum.

---

## Teil 1 — Tragen die Behebungen der Runde 2?

Jeder der drei Befunde einzeln gegen `f7dec1f9` gehalten. **Einer trägt vollständig, zwei tragen an
ihrem Gegenstand und setzen dabei je einen neuen Befund.**

| Befund Runde 2 | Ausgang | Nachmessung |
|---|---|---|
| **HIGH-1** — zwei von vier Vorkommen der Gegenaussage zum *Emissions-Schritt* stehengeblieben | **behoben, vollständig** | Der Begriff steht heute **3×** (`grep -c 'Emissions-Schritt' <adr>`, vorher **4** über `git show f7dec1f9^:<adr>`), und keine der drei verneint ihn: Zeile 470 ist Folgepflicht 6 (*„wird gebaut"*), 537 und 538 sind §Geschichte-Einträge über die Runden. Die zwei widersprechenden Stellen sind ersetzt. **Die Aussage ist auch ohne den Begriff einig** — alle vier Kosten-Passagen sagen heute dasselbe: Preis-Grund 3 (`:243`), Festlegung 4 (`:319`), Pro-Zelle A (`:425`), §Konsequenzen (`:438`); `grep -n 'kostet nichts' <adr>` und `grep -n 'ohne Emissions\|kein Emissions\|keinen Emissions' <adr>` liefern **je 0 Treffer**. Auch die fünf als *gegengeprüft* geführten Stellen halten (heute `:152`, `:318-320`, `:436-441`, `:470`, `:537`) |
| **MEDIUM-1** — „dieselbe Zählung trifft heute die Go-Fassung" | **am Gegenstand behoben, setzt MEDIUM-1 unten** | Die Sieben steht bei ihrer Mess-Basis und ihr Kommando ist dorthin gepinnt: `git grep -l 'archive-welle' e28b887e -- 'test/mutations/*.sh' \| wc -l` → **7**. Die Bezugsmenge der Go-Fassung wird über die Namen gezogen: `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh \| wc -l` → **24**, dieselbe Menge, die §Fitness Function und [`harness/README.md`](../../harness/README.md) adressieren. Der Ausreißer stimmt: `grep -c 'archive-welle' test/mutations/233-archive-welle-go-haenger-suchraum.sh` → **0**. **Eine Bezugsmenge, nicht zwei** — hält. Die Pinnung macht jedoch den Absatz-Kopf darüber falsch (MEDIUM-1 unten) |
| **MEDIUM-2** — Shell-Weg im Präsens | **an fünf Stellen behoben, die Fundmenge war sechs** | Die fünf vom Architect gemessenen Stellen stehen im Präteritum bzw. bei der Mess-Basis (`:74`, `:150`, `:239`, `:426`, `:461`); `ls harness/tools/ \| grep -c 'archive'` → **0** und `grep -n -A2 '^archive-welle:' Makefile` → `@$(HOST_BIN) archive-welle "$(WELLE)"` stehen als Beleg daneben. Was er als Festlegung stehen ließ, ist richtig stehen geblieben: Festlegung 2 (`:261`), *„werden retiriert"* (`:445`, `:457`, `:483`) und Zeile 20 sind Norm bzw. zeitlose Eigenschafts-Vergleiche, keine Zustandssätze. **Sein Suchmuster erreichte eine sechste Stelle nicht** — Zeile 85 nennt den Shell-Weg nicht und trägt denselben Defekt (MEDIUM-2 unten) |

---

## Findings

### HIGH-1 — Die Entscheidung nennt dreimal eine Grenze, die es nicht gibt: der `git`-berührende Teil liegt im Test-Bild

- **kategorie:** HIGH
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  in der Lesart, die ADR-0033 **selbst** anlegt (`:265-267`: *„ein Target, das die eine fährt,
  während die Doku die andere beschreibt, ist `LH-QA-01` eine Ebene tiefer"*);
  [`AGENTS.md`](../../AGENTS.md) §3.4 (was ab `Accepted` einfriert)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:238`, `:425` und `:453`
- **befund:** Die Datei sagt an drei Stellen, der `git`-berührende Teil der Operation bleibe
  **außerhalb des Test-Bildes** — als dritter Halbsatz des ersten Preis-Grunds (`:238`, *„Was dabei
  nicht wandert, gehört genannt"*), als **Contra**-Posten der gewählten Alternative A in der
  Abwägungstabelle (`:425`) und als eigene **Grenze** in §Konsequenzen (`:453`, *„Der Prüfbereich
  wächst um die vier reinen Gegenstände; er wird nicht vollständig"*). Der Baum sagt das Gegenteil:
  `cmd/ai-harness-init/archive_welle_echt_test.go` führt **3** Fälle
  (`grep -c '^func Test' cmd/ai-harness-init/archive_welle_echt_test.go`), die `git` als **Prozess**
  in einem Scratch-Repo starten (`git init`, `config`, `add`, `commit`, `rev-list`, `status`), ohne
  Build-Tag und ohne Skip-Guard (`grep -c 't.Skip' <datei>` → **0**); die Datei liegt in
  `cmd/ai-harness-init` und damit im `./...` der Dockerfile-`test`-Stage
  (`grep -n -A2 'FROM warm AS test' Dockerfile` → `RUN CGO_ENABLED=0 go test -count=1 ./...`), die
  `make test-go` als Ziel baut (`grep -n -A1 '^test-go:' Makefile`). **Vier** Mutations-Fälle hängen
  daran und nennen genau diese Testnamen (`sed -n '2,4p' test/mutations/24[9]-*.sh
  test/mutations/25[0-2]-*.sh` → `verify: test-go`, `expect: TestArchiveWelleEcht…`).
  [`harness/README.md`](../../harness/README.md)`:388` beschreibt denselben Sachverhalt
  ausdrücklich als `make test`-Deckung: *„Daneben steht ein Lauf gegen ein echtes Repo
  (`cmd/ai-harness-init/archive_welle_echt_test.go`): der Träger startet als Prozess in einem
  Scratch-Repo"*. **Die Aussage war an der Mess-Basis eine Prognose und ist seit dem Folgetag
  widerlegt:** `git show e28b887e:cmd/ai-harness-init/main.go | grep -n '^\s*case "'` nennt nur
  `span-emit`/`span-report`, und die Datei entstand in
  `git log --diff-filter=A --format='%h %ad' --date=short -- cmd/ai-harness-init/archive_welle_echt_test.go`
  → `94f25525 2026-09-04`, fünf Tage vor Runde 1. Die ADR nennt sie nirgends
  (`grep -c 'ArchiveWelleEcht' <adr>` → **0**), und die **6** namentlich geführten Wächter ihrer
  §Fitness Function liegen sämtlich in synthetischen Sätzen (`internal/archive/*_test.go`,
  `cmd/ai-harness-init/archive_welle_test.go`, je `grep -rl "func <name>"`).
  **Die Fallunterscheidung ist erschöpfend und der aufgeschobene Gate-Lauf ändert sie nicht:**
  Entweder das gepinnte Test-Bild führt `git` — dann sind die drei Sätze falsch. Oder es führt
  keines — dann fallen die drei Fälle in jedem `make test` (`gitLauf` bricht mit `t.Fatalf` ab),
  `make test` wäre dauerhaft rot, und vier Mutations-Fälle wären Zusagen ohne Wächter. Die
  Unterscheidung ist nur für die **Klasse** des Befundes offen, nicht für sein Bestehen.
- **Failure-Szenario:** ADR-0033 wird `Accepted`, §3.4 friert sie ein. Ein späterer Lauf, der vor
  der ersten realen Archivierung entscheidet, ob der schreibende Pfad ausreichend bewacht ist,
  liest in der eingefrorenen Entscheidung eine ausdrücklich benannte **Grenze** und in der
  Contra-Spalte der gewählten Alternative denselben Satz. Er schneidet entweder einen Slice für
  Deckung, die seit dem 2026-09-04 existiert, oder er hält den `git`-Pfad für unbewacht und räumt
  die vier Fälle `249`–`252` als vermeintlich wirkungslos ab — dann verschwindet die Deckung
  wirklich. Beides läuft gegen eine Quelle in **Rang 4**, die einer Aussage in **Rang 9**
  ([`harness/README.md`](../../harness/README.md)) widerspricht, und die höhere sticht.
- **verifizierbar:** ja, **nicht durch einen Gate-Lauf** — `docs-check` ist über dem committeten
  Stand grün (**1067** Dateien, **0** Befunde, Kommando im Kopf), weil kein Modul eine
  Prosa-Aussage gegen den Testbaum hält. Nachrechenbar mit den sechs `grep`/`git log`-Kommandos
  oben; der Ausgang der Fallunterscheidung — nicht ihr Bestehen — wäre durch `make test` zu
  entscheiden.
- **klasse:** Eingefrorene Grenz-Aussage, die der gelieferte Bau widerlegt

### MEDIUM-1 — Die Behebung von MEDIUM-1 hat den Kopf ihres eigenen Abschnitts falsch gemacht

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1; ADR-0033 Bezug-Block (*„jede Zahl unten steht neben dem Kommando, das sie liefert"*)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:160-162`
  (gegen `:171` und `:173`)
- **befund:** Der Kopf von §Was heute gemessen ist teilt den Abschnitt in zwei Mess-Stände und sagt
  über die erste Hälfte: *„Die ersten zwei Punkte messen den Zustand, den diese Entscheidung
  **vorfand** — Mess-Basis `e28b887e`; … und wer ihre Kommandos heute fährt, misst dessen
  Nachfolger."* Der Absatz stammt aus `e201769d` und war damals wahr: das Zähl-Kommando des ersten
  Punktes lautete `grep -l 'archive-welle' test/mutations/*.sh | wc -l` → **8**, war also ungepinnt
  und maß den heutigen Baum (`git show e201769d:<adr>`). `f7dec1f9` hat es auf die Mess-Basis
  gepinnt — `git grep -l 'archive-welle' e28b887e -- 'test/mutations/*.sh' | wc -l` → **7**, heute
  wie an jedem Tag —, und **elf Zeilen unter dem Kopf steht jetzt dessen Gegenteil in Fettschrift**:
  *„**Dieses Kommando misst die Nachfolge-Menge nicht**"* (`:173`). Die zweite Hälfte des Kopfsatzes
  bricht mit: Punkt 1 trägt seit `f7dec1f9` **zwei** Kommandos am heutigen Baum
  (`grep -c 'archive-welle' test/mutations/233-…` → **0** und
  `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | wc -l` → **24**),
  deren Gegenstand die Go-Fassung ist — also weder *„der Zustand, den diese Entscheidung vorfand"*
  noch einer der *„übrigen drei"*, die der Kopf dem heutigen Baum zuweist. Die Zweiteilung, die der
  Abschnitt über sich selbst behauptet, deckt ihren eigenen Inhalt nicht mehr.
- **Failure-Szenario:** Ein Lauf, der die Abdeckungslage der Operation aus der eingefrorenen
  Entscheidung ableiten will, liest den Kopf, fährt das erste Kommando des ersten Punktes und
  bekommt **7**. Der Kopf sagt ihm, das sei die Nachfolge-Menge; der Punkt selbst sagt drei Sätze
  weiter, sie sei es nicht, und nennt **24**. Er hat zwei einander widersprechende Anleitungen aus
  derselben Datei und muss entscheiden, welche gilt — genau die Lage, die Runde 2 als HIGH-1 für die
  Kosten-Aussage beschrieben hat, hier eine Ebene über der Messung statt neben ihr.
- **verifizierbar:** ja, ohne Gate — die drei Kommandos oben (`7`, `0`, `24`) und
  `git show e201769d:<adr>` für die Vorfassung.
- **klasse:** Korrektur an einem Teil der Fundmenge, Rest widerspricht der neuen Fassung

### MEDIUM-2 — „und kein Ziel hat es" ist seit dem Tag der Mess-Basis falsch und widerspricht Festlegung 4

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4; ADR-0033 Festlegung 4 gegen ADR-0033
  §Was die Entscheidung auslöst
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:85`
  (gegen `:293-303`)
- **befund:** §Was die Entscheidung auslöst schließt mit *„— und kein Ziel hat **es**"*, wobei
  *es* das im zitierten Anweisungssatz genannte **Werkzeug** ist. An der Mess-Basis war das wahr:
  `git show e28b887e:cmd/ai-harness-init/main.go | grep -n '^\s*case "'` nennt nur `span-emit` und
  `span-report`. Seit `83a00cbc` (2026-09-03, `git log -S'case "archive-welle"' -- cmd/ai-harness-init/main.go`)
  führt der Dispatch `case "archive-welle"` (`grep -n '^\s*case "' cmd/ai-harness-init/main.go` →
  vier Fälle), und der Träger ist die **Selbst-Kopie des laufenden Bildes**
  (`grep -n 'os.Executable' internal/emit/enforce.go` → **1**, Ablage
  `grep -c 'carrierDir = ' internal/emit/enforce.go` → **1**). Jedes mit einem aktuellen Bau
  gebootstrappte Ziel **hat** die Fähigkeit damit; was ihm fehlt, ist die Adresse. Genau diese
  Unterscheidung trifft die Datei **selbst** in Festlegung 4: *„Eine Fähigkeit ohne Adresse im Ziel
  ist eine Zusage, die der Adopter nicht einlösen kann. Nennt sein Repo das Unterkommando nirgends,
  liest er … und trägt das als Feststellung ein, **während der Träger danebenliegt**"* (`:300-303`).
  Zeile 85 und Zeile 302 sagen über denselben Zeitpunkt Gegenteiliges. Die Stelle liegt **außerhalb**
  des Suchmusters, mit dem `f7dec1f9` seine Fundmenge zog (`Shell-Helfer|Shell-Weg|Shell-Fassung|
  Skript-Weg`, Commit-Message) — sie nennt den Shell-Weg nicht.
- **Failure-Szenario:** Der Satz untertreibt genau das Risiko, für dessen Offenlegung Festlegung 5
  existiert. Ein Lauf nach dem Accept liest, kein Ziel habe das Werkzeug, und behandelt den
  Preis-Satz aus Festlegung 5 als **Vorsorge** für einen künftigen Zustand — während in jedem seit
  dem 2026-09-03 gebootstrappten Ziel bereits ein Binär liegt, das auf Zuruf im versionierten
  Planning-Baum bewegt, löscht und committet, **ohne** dass irgendwo der Satz steht, den
  Festlegung 5 verlangt. Die Dringlichkeit von Folgepflicht 6 und 7 wird damit aus der eingefrorenen
  Datei heraus falsch eingeschätzt.
- **verifizierbar:** ja, ohne Gate — die vier Kommandos oben; `docs-check` bleibt grün, weil kein
  Modul einen Zustandssatz gegen den Dispatch hält.
- **klasse:** Präsens-Zustandssatz im einfrierenden Artefakt, neben einer datierten Nachbarsektion

### INFO-1 — „kostet ein Textfragment und sonst nichts" — die Rest-Liste ist wahr, das „sonst nichts" ist enger gemeint als geschrieben

- **kategorie:** INFO
- **quelle:** Maintainability; ADR-0033 §Konsequenzen Folgepflichten 6, 7, 8
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:243-249`
- **befund:** Die neu formulierte Kopfzeile des dritten Preis-Grunds sagt, die Reichweite ins Ziel
  koste *„ein Textfragment und sonst nichts"*, und zählt als Rest auf: *„kein Vertriebskanal, kein
  Bauschritt und keine zweite Plattform-Matrix"*. **Die Liste ist vollständig und wahr für die
  Achsen, auf denen die Abwägung läuft** — sie ist deckungsgleich mit der Aufzählung in Festlegung 4
  (`:318-320`, dort zusätzlich *„keine neue Artefakt-Klasse"*, die die Kopfzeile als *„eine
  Artefakt-Klasse, die das Ziel schon führt"* ausdrückt), mit §Konsequenzen (`:437-439`) und mit der
  Pro-Zelle A (`:425`); jede Achse ist gemessen: der Aggregator bindet die Klasse bereits per Glob
  (`grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` → **1**), der Emitter legt heute
  Fragmente derselben Klasse ab (`ls internal/emit/templates/enforce/` nennt `enforce.mk` und
  `erfassung.mk`), und [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) führt `harness/mk/*.mk` als
  **konvergent** (`:100`). **Was das „sonst nichts" nicht deckt**, steht drei Absätze weiter in
  derselben Datei: Folgepflicht 6 (Emitter), 7 (Emissions-Test) und 8 (`full-smoke`-Strecke) sind
  Arbeit dieses Repos, nicht des Ziels. **Kein Verstoß:** Die Kopfzeile spricht über die
  *Reichweite ins Ziel*, und der Preis dort ist tatsächlich die eine Datei; die drei Folgepflichten
  sind benannt und nicht verschwiegen. Notiert, weil ein absolutes *„und sonst nichts"* in einem
  einfrierenden Artefakt beim Vergleich A gegen C leicht als Gesamtbilanz gelesen wird.
- **verifizierbar:** ja — die vier `grep` oben und `grep -n 'Folgepflicht [678]' <adr>`.
- **klasse:** Absolutformulierung enger gemeint als geschrieben

### INFO-2 — Ob der Preis-Satz aus Festlegung 5 den Zweig des Trägers teilt, ist offen

- **kategorie:** INFO
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 5(a) und 7; ADR-0033 Festlegung 4 und 5
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:293-312`, `:338-342`
- **befund:** Festlegung 4 baut das Fragment *„wie das der Erfassungsschicht"*, und dessen
  Präzedenz ist ausdrücklich **unbedingt**: `internal/emit/erfassung.go:16` schreibt *„UNBEDINGT,
  und das ist eine Entscheidung: es teilt den Zweig des Traegers NICHT"* und begründet es mit
  [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a).
  Derselbe Kommentar nennt aber eine Ausnahme: *„Festlegung 7 nimmt die Feldliste dazu, weil sie
  eine Aussage UEBER eine Erfassung waere, die nicht liegt."* Der Kopf-Satz, den ADR-0033
  Festlegung 5 verlangt, ist eine Aussage über das, *„was der abgelegte Träger kann"* (`:338-339`)
  — in einem Ziel, dessen Träger-Ablage nach 5(a) scheiterte, läge er also über eine Fähigkeit, die
  nicht da ist. **Kein Verstoß und keine Kollision:** Die ADR sagt für ihr Fragment ausdrücklich
  *„fehlt der Träger, **sagt** es das und endet erfolgreich"* (`:306`), was es in die
  `erfassung.mk`-Klasse stellt, und die Formulierung des Kopf-Satzes gehört dem Implementer.
  Notiert, weil die Datei die Frage weder stellt noch beantwortet, und Folgepflicht 7 sie beim Bau
  entscheiden muss.
- **verifizierbar:** ja — `sed -n '14,26p' internal/emit/erfassung.go` und die zwei ADR-Stellen.
- **klasse:** dokumentationswürdige, undokumentierte Annahme

### INFO-3 — Der Report-Zähler steht weiter bei 106 und ist heute 120 (unverändert aus Runde 2)

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:207`, `:369`
- **befund:** Beide Stellen führen **106**; dasselbe Kommando gibt heute **120**
  (`for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l`).
  **Kein Verstoß, und Runde 2 hat das bereits so entschieden:** Die Datei erklärt im Bezug-Block
  jede Zahl zum Nicht-Erwartungswert, das Kommando steht daneben bzw. wird als *„Kommando im
  Kontext"* referenziert, und das Argument (*„der Suchraum ist nicht theoretisch"*) trägt bei 120
  stärker als bei 106. `f7dec1f9` hat die Stellen nicht angefasst, was der Vorrunde entspricht.
  Erneuert nur als geprüft ausgewiesen; es ist die **vierte** Berührung der Klasse über drei Runden
  ([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation).
- **verifizierbar:** ja — das Kommando oben.
- **klasse:** Präsens-Messwert im einfrierenden Artefakt

---

## Negativbefunde (geprüft, ohne Befund)

- **Die eigentliche Konsistenz-Frage ist beantwortet: ADR-0033 widerspricht in ihrer heutigen
  Fassung keiner bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007.** Alle drei Befunde
  oben sind innere Widersprüche bzw. Zustandsaussagen der Datei gegen den eigenen Baum, keine
  Kollisionen mit den Bezugs-Entscheidungen. Die Einzelprüfung steht in den vier folgenden Punkten
  und ist **eigenständig gefahren**, nicht aus Runde 2 übernommen — `f7dec1f9` hat den
  Preis-Grund und die Pro-Zelle genau in diesem Bereich angefasst.
- **Gegen ADR-0022 — die Auflösung der kritischsten Stelle trägt weiter.** Die naheliegende
  Kollision wäre Festlegung 5(a) (*„Kann der Träger nicht abgelegt werden, wird weder Träger noch
  Wrapper noch Hook-Eintrag geschrieben, der Bootstrap nennt den Grund und endet erfolgreich"*):
  ein Fragment, das unabhängig vom Träger entsteht, könnte ihr widersprechen. Sie tut es nicht — die
  Aufzählung ist auf **drei** Hook-Artefakte geschnitten, und der gebaute Präzedenzfall entscheidet
  dieselbe Frage bereits gleich (`internal/emit/erfassung.go:16`, Zitat unter INFO-2). Ebenso trägt
  5(c): Ein ziel-seitiger Anwesenheits-Wächter ist dort ausgeschlossen, und ADR-0033 Festlegung 4
  schließt ihn mit derselben Begründung aus (`:322-325`). Die zitierten Festlegungen **1, 2, 5(a),
  5(b), 6 und 7** sind je **1×** wortgleich nachgewiesen — normalisiert nach
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (*„der Wortlaut ohne
  Auszeichnung, Whitespace normalisiert"*), `tr -s ' \n' '  ' | sed 's/\*\*//g' | grep -oF <zitat> | wc -l`,
  sechs von sechs.
- **Alle Eigenschaften, die Festlegung 4 dem Vorbild zuschreibt, halten am gebauten Fragment.**
  Gegen `internal/emit/templates/enforce/erfassung.mk`: der Kopf trägt *„ZWEI KOMMANDOS, KEIN
  GATE"*; das Fragment setzt `GATE_CHECKS` nicht; ein Kommando des Trägers wird über `make`
  erreichbar und ein zweites steht daneben; beim fehlenden Träger meldet das Ziel das und endet
  erfolgreich. Die Mechanik-Aussagen daneben sind gemessen:
  `grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` → **1**,
  `grep -c 'wachstumsSatz' internal/emit/erfassung_test.go` → **4**, und der Dogfood führt die
  Klasse selbst nicht (`ls -d harness/mk` → Exit 2), wie `:304` sagt.
- **Gegen ADR-0007 — keine Kollision, und die zwei zitierten Zuordnungen stimmen wörtlich.**
  `harness/mk/*.mk` steht in der Idempotenz-Tabelle jener **Festlegung 3**
  (`grep -nE '^[0-9]\. \*\*' docs/plan/adr/0007-bootstrap-phasen.md` → *„3. Idempotenz über eine
  Artefakt-Klassifikation"* bei `:87`) als **konvergent** (`:100`), `docs/plan/adr/*` als
  **skip-if-present** (`:101`) — beides genau so, wie ADR-0033 Festlegung 4 und 5 es zitieren. Das
  Fragment ist reiner Text und verlangt im Ziel keinen Bauschritt und keine Toolchain; die
  Inversion, gegen die ADR-0007 steht, entsteht nicht. Die Ablehnung von Alternative D bleibt
  Anwendung statt Berufung, und ihre Zuordnung zu
  [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Alternative C
  (`:429`) trifft: jene C ist *„Quelle mitliefern, Bau im gepinnten Image zur Bootstrap-Zeit"*
  (`:209`), also Quellbaum plus Bauschritt im Ziel.
- **Gegen ADR-0003 — keine Kollision.** Die Entscheidung wählt ein Unterkommando des nativ
  ausgelieferten Produkt-Binärs; Alternative E wird mit der Begründung verworfen, die dort steht
  (`grep -n 'Vertriebsmittel' docs/plan/adr/0003-go-native-binaries.md` → `:35`). Der Wegfall des
  vierten Bild-Pins arbeitet der Docker-only-Disziplin zu und ist real: an der Mess-Basis führte das
  Makefile **4** Pins (`git show e28b887e:Makefile | grep -cE '^[A-Z_]+_IMAGE \?='`), darunter
  `ARCHIVE_IMAGE`, heute **3** (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile`), und der einzige
  ausführende Aufrufer jenes Pins war der entfallene Shell-Helfer
  (`git grep -ln 'ARCHIVE_IMAGE' e28b887e` nennt daneben nur Makefile, `harness/README.md` und zwei
  Review-Reports).
- **Die Abzählungs-Kopplung an ADR-0022 stimmt.** Jene Entscheidung führt **vier** Klassen
  (`:192`, *„das Bild liegt schon vor, es entsteht im Ziel, es wird geholt, oder es gibt keines"*),
  und die von ADR-0033 `:121-122` behauptete Zuordnung trifft: deren B und C stehen unter *entsteht
  im Ziel* (`:208-209`), D und E unter *wird geholt* (`:210-211`). Die eigene Abzählung ist
  vollständig ausgezeichnet — **8** Ausgänge A bis G plus B′ in der Kontext-Tabelle, und die
  Alternativen-Tabelle führt dieselben acht in **10** Zeilen (Kopf und Trenner mitgezählt).
- **Kein Vertrags-Stratum berührt.** Die Akzeptanzkriterien von
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) zählen die
  drei `.claude/commands/…`-Dateien auf und kein `.mk`-Fragment; das Lastenheft nennt `harness/mk`
  überhaupt nicht (`grep -c 'harness/mk' spec/lastenheft.md` → **0**), die Komponenten-Sicht dagegen
  führt den Glob-Include (`spec/architecture.md:159`). Die Selbstaussage *„Die Aufzählung aus
  `LH-FA-08` wächst nicht"* hält; ein Change Request ist nach
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  nicht fällig. Die §Schärft-Aussage hält ebenfalls:
  `grep -c 'span-emit\|span-report\|archive-welle' spec/architecture.md` → **0**.
- **Jedes Inline-Kommando der Datei ist gefahren und liefert die Zahl, die daneben steht.**
  `spec/architecture.md` → **0** · `close-welle.md` → **1** · `carrierDir` → **1** ·
  `case "span-` → **2** · `e28b887e`-Mutations-Menge → **7** · `233`er Inhalts-`grep` → **0** ·
  Namens-Menge → **24** · Bild-Pins → **3** · `d-check`-Vorbild → **7** · Stub-Vorlagen über
  `TAG=$(sed -n 's/^BASELINE_TAG ?= //p' Makefile)` → **2** · Glob-Include → **1** ·
  emittierte ADR-Vorlagen → **Exit 2** · `baseline/v[0-9]` → **0** · `wachstumsSatz` → **4** ·
  `full-smoke` → **0** · `harness/tools/` → **0** · `internal/emit/` → **0**. **Einzige
  Abweichung** ist der Report-Zähler (INFO-3). Das Auflistungs-Kommando der §Fitness Function läuft
  und gibt **22** verschiedene `expect:`-Werte über den 24 Fällen.
- **Die Fitness-Function-Tabelle behauptet keine Deckung, die es nicht gibt.**
  `grep -c '\*\*Geliefert\*\*'` → **5**, `grep -c 'Geschuldet, nicht geliefert'` → **2**; alle **6**
  namentlich genannten Wächter existieren (je `grep -rl "func <name>" --include='*_test.go' .` →
  **1**), und die Zeilen nennen ausschließlich existierende Targets. Die zwei `Geschuldet`-Zeilen
  sind heute **korrekt und nicht überholt**: `grep -rln 'archive-welle' internal/emit/ | wc -l` →
  **0** (in beiden Ständen) und `grep -c 'archive' harness/tools/full-smoke.sh` → **0**. Was die
  Tabelle **nicht** nennt, ist Gegenstand von HIGH-1.
- **Die Realitätslage der übrigen Aussagen stimmt.** Der Shell-Helfer ist fort
  (`git ls-tree --name-only e28b887e harness/tools/ | grep archive` → `archive-welle.sh`, heute
  `ls harness/tools/ | grep -c 'archive'` → **0**), sein bats-Satz ebenso
  (`git ls-tree --name-only e28b887e test/ | grep -i archiv` → `test/archive-welle.bats`), die
  sieben Fälle `225`–`231` existieren nicht mehr (`ls test/mutations/22[5-9]* test/mutations/23[01]*`
  → Exit 2), das Target zeigt auf den Träger, und *„zweimal reviewt"* trifft
  (`2026-09-03-slice-170-impl-review.md` und `…-runde-2.md`). Dass **vier** Folgepflichten (1–4)
  bereits eingelöst sind, während die Datei `Proposed` steht, ist **kein** Befund: die Datei sagt
  selbst, sie sei bis zum Accept *„ein Architect-Verdikt und als solches das Übergabe-Artefakt, das
  der Port als Constraint liest"* (`:387-388`), und die Fitness-Tabelle weist geliefert und
  geschuldet getrennt aus.
- **Keine Referenz auf eine superseded ADR.** Alle **9** referenzierten ADRs stehen auf `Accepted`
  (je `grep -m1 '^\*\*Status:\*\*'` über 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040).
- **Die §Geschichte bläht sich nicht, und die neue Zeile trägt Zustand.** Ihr Anteil liegt bei
  **8,1 %** (`t=$(wc -c < <adr>); g=$(awk '/^## Geschichte/{i=1} i' <adr> | wc -c)`), gegenüber
  **5,8 %** vor `f7dec1f9` (dieselbe Rechnung über `git show f7dec1f9^:<adr>`) — der vom Architect
  berichtete Wert stimmt. Er liegt **exakt auf dem Repo-Durchschnitt von 8,1 %** (die Schleife aus
  [`harness/README.md`](../../harness/README.md) über `docs/plan/adr/[0-9]*.md`) und weit unter dem
  höchsten Einzelwert von **28,1 %** (`docs/plan/adr/0012-…`, dieselbe Schleife je Datei). Der
  Eintrag nennt je Befund den **Ausgang** und die neue Aussage der Datei, nicht den Verlauf des
  Laufs; die `## Geschichte`-Tabelle einer ADR ist zudem nicht die `Stand`-/`Status`-Zelle eines
  lebenden Registers, auf die [`AGENTS.md`](../../AGENTS.md) §3.7 zielt, sondern der Abschnitt, in
  dem eine ADR ihre Fortschreibung führt (`exclude-sections: [Geschichte]` in
  [`.d-check.yml`](../../.d-check.yml), begründet in
  [`harness/README.md`](../../harness/README.md)). **Kein §3.7-Verstoß.**
- **Die Selbstaussage über bewegliche Adressen hält über beide Adress-Formen.** Inline-Code mit
  gate-sichtbarem Präfix: `docs/plan/adr/*`, `docs/plan/planning/`, `docs/reviews/`,
  `docs/reviews/**`, `harness/mk/*.mk`, `harness/README.md`, `harness/tools/`, `../<datei>.md` —
  Globs, ortsfeste Verzeichnisse oder Layout-Muster, kein Planning-Lifecycle-Pfad und kein
  Tag-Literal (`grep -c 'baseline/v[0-9]' <adr>` → **0**). Alle Markdown-Link-Ziele zeigen auf
  ortsfeste Artefakte (ADRs, `AGENTS.md`, `.d-check.yml`, `harness/conventions.md`,
  `harness/README.md`, `spec/lastenheft.md`); der Doku-Gate-Lauf bestätigt die Link-Form mit **0**
  Befunden.
- **Der Beleg-Weg des Accept-Übergangs ist korrekt vorbereitet und unverändert.** §Der
  Acceptance-Trigger gibt [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 richtig wieder (Zitat gegen `:131-137` gehalten) und benennt für die künftige
  Accept-Zeile die Kennungs-Form aus Festlegung 1. Das Baseline-Zitat des Triggers ist verbatim:
  `modul-08-agentenrollen.md` §Rollen-Regeln, `v6.5.0`, **1** Treffer normalisiert; ebenso das
  auslösende Zitat aus `modul-06-roadmap.md` §Wellen-Closure-Prozedur (**1**) und der
  Stub-Vorlagen-Beleg nach Link-Strip (**1**).

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Eingefrorene Grenz-Aussage, die der gelieferte Bau widerlegt |
| **MEDIUM** | 2 | Korrektur an einem Teil der Fundmenge, Rest widerspricht der neuen Fassung · Präsens-Zustandssatz im einfrierenden Artefakt, neben einer datierten Nachbarsektion |
| **LOW** | 0 | — |
| **INFO** | 3 | Absolutformulierung enger gemeint als geschrieben · dokumentationswürdige, undokumentierte Annahme · Präsens-Messwert im einfrierenden Artefakt |

**Die zwei MEDIUM sind dieselben zwei Klassen wie in Runde 2 — an neuen Fundorten.** MEDIUM-1
trägt die Klasse *Korrektur an einem Teil der Fundmenge* zum **dritten** Mal (Runde 2 HIGH-1,
Runde 2 MEDIUM-2, hier), diesmal nicht neben der korrigierten Stelle, sondern in der Überschrift
darüber. MEDIUM-2 trägt die Klasse *Präsens-Zustandssatz* zum **zweiten** Mal und zeigt dieselbe
Ursache wie Runde 2: Der behebende Lauf hat seine Fundmenge über ein Wortmuster gezogen, und die
Aussage reicht weiter als das Wort. Beides zusammen ist ein Steering-Loop-Kandidat
([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation); ob ein
Zähler-Schritt fällt, entscheidet die Closure und nicht dieser Report.

**HIGH-1 ist keine Regression der Behebung**, sondern eine Aussage, die seit dem 2026-09-04
unwahr ist und die drei Runden übersehen haben — Runde 1 und 2 eingeschlossen. Sie ist der teuerste
Befund dieser Kette, weil sie in der Contra-Spalte der gewählten Alternative und als benannte
Grenze in §Konsequenzen steht.

---

## Verdikt

**Blockierender Befund: ja.**

**Der Acceptance-Trigger ist damit nicht erfüllt.** Er verlangt einen Report *„ohne blockierenden
Befund"*; dieser trägt einen HIGH und zwei MEDIUM, und nach
[`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage blockieren beide
Kategorien typischerweise. Ein Architect-Lauf kann `Accepted` auf dieser Grundlage **nicht**
setzen.

**Die Konsistenz-Frage selbst fällt zugunsten der ADR aus, und sie ist in dieser Runde eigenständig
gefahren.** ADR-0033 widerspricht keiner bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007.
Die kritischste Stelle — ein Fragment, das unabhängig vom Träger entsteht, gegen ADR-0022
Festlegung 5(a) — ist nach wie vor durch den gebauten Präzedenzfall in `internal/emit/erfassung.go`
gedeckt; `f7dec1f9` hat diesen Bereich zwar angefasst, aber nur die **Kosten**-Formulierung, nicht
die Konstruktion. Alle sechs zitierten Festlegungen von ADR-0022 und die zwei Zuordnungen aus
ADR-0007 sind wortgleich nachgewiesen.

**Die Behebung der Runde 2 trägt an ihren drei Gegenständen.** Der *Emissions-Schritt* ist über
alle vier Kosten-Passagen einig, und auch die fünf als *gegengeprüft* geführten Stellen halten; die
Mutations-Zählung steht bei ihrer Mess-Basis und führt genau eine Bezugsmenge; der Shell-Weg steht
an den fünf gemessenen Stellen im Präteritum, und was als Festlegung stehen blieb, ist zu Recht
stehen geblieben.

**Blockierend ist zweierlei.** Erstens eine Aussage, die keine der drei Runden gemessen hat:
Die Datei nennt dreimal eine Grenze — der `git`-berührende Teil liege außerhalb des Test-Bildes —,
die der gelieferte Bau widerlegt; drei Go-Fälle starten `git` als Prozess in der Test-Stage, vier
Mutations-Fälle hängen daran, und `harness/README.md` beschreibt genau das als `make test`-Deckung.
Zweitens zweimal dieselbe Klasse, die schon Runde 1 → Runde 2 gekostet hat: eine Korrektur, deren
Fundmenge einen Fundort zu klein war. Bei MEDIUM-1 ist dieser Fundort die Überschrift des
korrigierten Absatzes, bei MEDIUM-2 ein Satz, der den gesuchten Begriff nicht enthält.

**Alle drei sind behebbar, solange die Datei `Proposed` steht** — und nur solange: Nach dem Accept
kostet jede eine Folge-ADR statt weniger Zeilen ([`AGENTS.md`](../../AGENTS.md) §3.4). Lösungswege
stehen bewusst nicht in den Befunden (Skill §Anti-Pattern); die Übergabe geht an den Architect, dem
die Datei gehört.

**Für den Wiedervorlage-Weg gilt weiter
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2:**
Da auch diese Runde blockiert, ist der Beleg für den Accept-Übergang eine **vierte** Runde
derselben prüfenden Rolle — nicht die Nachmessung durch den Kontext, der diese Befunde auflöst.

**Vorbehalt zur Gate-Verifikation.** `make gates`, `make mutate`, `make full-smoke`, `make test`
und jeder `docker build` sind für diesen Lauf untersagt; der Auftraggeber fährt `make gates` selbst.
Für die Befunde dieses Reports ist der Vorbehalt gegenstandslos: Alle drei sind mit `git` und
`grep` nachrechenbar, jedes Kommando steht neben seiner Zahl, und keiner wäre von einem Gate-Ziel
bestätigt worden. Bei HIGH-1 ist der aufgeschobene `make test`-Lauf ausdrücklich mitgedacht — er
entscheidet, **welcher** der zwei Zweige der Fallunterscheidung zutrifft, nicht **ob** ein Befund
vorliegt. `docs-check` ist in der erlaubten Form gefahren und grün (**1067** Dateien, **0**
Befunde).
