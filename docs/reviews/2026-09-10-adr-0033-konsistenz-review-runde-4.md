# Review-Report — ADR-0033 auf Konsistenz gegen ADR-0022, ADR-0003, ADR-0007 (Runde 4)

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 4

**Gegenstand:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
(`Proposed`) — Konsistenz-Prüfung, **kein** Code-Diff-Review. Ausgelöst vom Acceptance-Trigger
jener Datei; sie verlangt eine Reviewer-Runde gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md). Diese Runde ist der Beleg, den
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach
einem blockierenden Befund fordert: eine **erneute** Runde derselben prüfenden Rolle, nicht die
Nachmessung des auflösenden Kontexts. Dieser Lauf ist jener Kontext nicht.

**Vorgängerinnen:** `2026-09-09-adr-0033-konsistenz-review.md` (Runde 1, blockierend),
`2026-09-10-adr-0033-konsistenz-review-runde-2.md` (Runde 2, blockierend) und
`2026-09-10-adr-0033-konsistenz-review-runde-3.md` (Runde 3, 1 HIGH / 2 MEDIUM / 3 INFO,
blockierend). Alle drei stehen als **Kennung** und nicht als Pfad-Link: Ein Review-Report ist
eines der Zeitdokumente, die die Operation dieser Entscheidung ins Wellen-Archiv bewegt, und
dieser Report friert mit seinem Abschluss ein ([`AGENTS.md`](../../AGENTS.md) §3.11).

**Behebung, die geprüft wird:** `3472f47a` („Rolle Architect: ADR-0033 — die Klasse gefegt statt
der drei Fundorte (Runde 3)"), **37** eingefügte und **19** entfernte Zeilen in **1** Datei
(`git show --stat 3472f47a`).

**Baum-Stand beim Lauf:** `git status --porcelain` ist **leer**; `git log --format='%h %s' -1` →
`71f3fd9b Rolle Implementer: slice-073 -- Runde 5 …`. Ein **fremder** Vorgang (`slice-073`) hat
während dieses Laufs `internal/emit/`, `internal/emit/templates/` und `test/mutations/` berührt
(`git show --stat 71f3fd9b`). Keiner dieser Pfade ist Gegenstand dieses Reviews; jede Messung, die
einen davon berührt, ist **nach** jenem Commit wiederholt worden und unverändert (unten im
Negativbefund-Block namentlich). Der Prüfgegenstand selbst ist seit `3472f47a` unangetastet:
`git log --oneline 3472f47a..HEAD -- <adr> | wc -l` → **0**.

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Prüfgegenstand ist eine ADR
statt eines Diffs, also treten die Datei und der Behebungs-Commit an die Stelle von Diff und
Slice-Plan. Betroffene Anforderungen: `LH-FA-08`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
Referenzierte aktive ADRs: 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040 — **alle
`Accepted`**, je Datei über `grep -m1 '^\*\*Status:\*\*'` selbst gemessen; keine superseded
Referenz. Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3.4, §3.5, §3.6, §3.7, §3.11. Vorherige
Findings am gleichen Gegenstand: die sechs der Runde 1, die drei der Runde 2 und die sechs der
Runde 3.

**Mess-Disziplin, und diese Runde verschärft sie an einer Stelle.** Jede Zahl unten steht neben dem
Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Zusätzlich ist bei jeder Zahl der Vorrunden geprüft, ob das danebenstehende Kommando
die Größe misst, die der Satz benennt** — nicht nur, ob es dieselbe Ziffer ausgibt. Genau diese
zweite Frage hat drei Runden lang niemand gestellt, und sie trägt MEDIUM-1. Jeder Befund unten
nennt ausdrücklich, ob er einen **Fundort** oder eine **gemessene Fundmenge** meldet, und mit
welchem Kommando.

**Gate-Verifikation — aufgeschoben, und der erlaubte Docker-Lauf ist nicht gebraucht worden.**
`make gates`, `make mutate`, `make full-smoke`, `make test` und jeder `docker build` sind für
diesen Lauf untersagt (fremder Docker-Lauf, OOM-Druck); der Auftraggeber fährt `make gates` selbst.
Der eine erlaubte `docker run` gegen den in [`d-check.mk`](../../d-check.mk) gepinnten Digest ist
**nicht** gefahren worden: keiner der Befunde unten hängt an ihm, und die eine Stelle, an der ein
Lauf nötig schien — die **7** `codepath-missing` der neuen Folgepflicht 9 —, ist **statisch
nachgerechnet** und exakt bestätigt (Kommando im Negativbefund-Block). Damit bleibt der
Docker-Vorrat dieses Laufs ungenutzt statt für eine Messung ausgegeben, die `grep` liefert.
**Offenlegung zum Vorlauf:** Der behebende Architect-Lauf hat den erlaubten `docker run` zweimal
gefahren und den zweiten selbst als nicht ausdrücklich gedeckt benannt. Das ist zur Kenntnis
genommen; es berührt keinen Befund dieses Reports, weil keine seiner Zahlen aus jenen Läufen
übernommen ist.

---

## Teil 1 — Trägt der Fege-Lauf? Die Menge, unabhängig gebildet

Der behebende Lauf hat nicht die drei gemeldeten Zeilen gezogen, sondern die **Klasse** gebildet:
jede Aussage der Datei über den heutigen Zustand von Repo, Bau oder Werkzeug, einzeln gemessen.
Seine Prüfliste liegt **nicht im Repo** — sie steht allein in seinem Übergabe-Bericht
(`git show --stat 3472f47a` nennt genau eine geänderte Datei, die ADR selbst). Ein Vergleich Zeile
gegen Zeile war damit unmöglich; die Menge ist hier **von Grund auf neu gebildet** und gemessen.

**Wie sie gebildet wurde.** Zwei Achsen, beide mechanisch, danach von Hand gelesen:

```sh
ADR=docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md
grep -noE '`[^`]*(grep|ls|sed|git|awk|wc|find)[^`]*`' "$ADR"   # jede Inline-Kommando-Zusage
grep -n 'heute\|bereits\|erprobt\|etabliert\|gebaute' "$ADR"   # Praesens-Zustandsaussagen ohne Kommando
grep -o '`[^` ]*/[^` ]*`' "$ADR" | tr -d '`' | sort -u          # jeder genannte Pfad
grep -o '](\([^)]*\))' "$ADR" | sed 's/^](//; s/)$//' | sort -u  # jedes Link-Ziel
```

Dazu, weil kein Muster sie trifft, von Hand: der **Bezug-Block** (jede Charakterisierung einer
fremden ADR bzw. `LH-*`-Anforderung), die **§Schärft**-Aussage, jedes **verbatim**-Zitat, die
Aussagen über das **Nachbar-Repo** und die Aussagen über die **Mess-Basis** `e28b887e`.

**Ergebnis: der Fege-Lauf trägt in der Breite, und er trägt nicht in der Tiefe.**

| Achse | Ausgang |
|---|---|
| **Die vier geänderten Aussagen** (`:85`, `:160-164`, `:238`/`:425`/`:453`, `:483-489`) | **alle vier tragen, einzeln nachgemessen** — Teil 2 |
| **Jedes Inline-Kommando der Datei** (**20** mit Zahl-Zusage, unten einzeln aufgezählt) | **19 liefern die Zahl, die daneben steht.** Die eine Abweichung ist der Report-Zähler `106` gegen heute `121` — bewusst stehengelassen |
| **Jede Präsens-Zustandsaussage ohne Kommando** (u. a. `:87`, `:103`, `:171-173`, `:178-182`, `:190`, `:191-194`, `:244`, `:313`, `:318-320`, `:324-325`, `:433`, `:437`) | **alle tragen** — Negativbefund-Block |
| **Jede Charakterisierung einer fremden Quelle** (9 ADRs, 5 `LH-*`, 3 Baseline-Zitate, 6 ADR-0022-Zitate) | **alle tragen** — Negativbefund-Block |
| **Ob das Kommando die Größe misst, die der Satz benennt** | **einmal nicht** — **MEDIUM-1**. Der Fege-Lauf hat die *Ziffer* der einen stehengelassenen Zahl gemessen (`120`), nicht die *Größe*, die ihr Satz benennt. Der Satz nennt Link-**Ziele**, das Kommando zählt Link-**Quellen**, und beide Zahlen sind verschieden |

**Die Methode hat damit einen benannten Boden, keinen Riss.** Sie hat die Klasse *Zustandsaussage,
die der Baum widerlegt* über die hier unabhängig gebildete Menge erschöpfend abgetragen — was blieb, ist eine Ebene tiefer:
nicht *stimmt die Ziffer*, sondern *zählt das Kommando dasselbe wie der Satz*. Das ist die Frage,
die [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 mit *„ein ungefähr passendes Kommando danebenzustellen ist der Fehler, nicht die Lücke"*
ausdrücklich stellt und die keine der vier Runden gestellt hat.

---

## Teil 2 — Tragen die vier Änderungen aus `3472f47a`?

Jede einzeln gegen den Baum, keine aus dem Übergabe-Bericht übernommen.

| Änderung | Ausgang | Nachmessung |
|---|---|---|
| **`:85`** — *„und kein Ziel hat es"* → dem Ziel fehlt die **Adresse**, nicht die Fähigkeit | **trägt** | `grep -c 'case "archive-welle"' cmd/ai-harness-init/main.go` → **1**; die Ablage ist die Selbst-Kopie des laufenden Bildes (`grep -n 'os.Executable' internal/emit/enforce.go` → 1 Treffer, `grep -c 'carrierDir = ' internal/emit/enforce.go` → **1**, Wert `.harness/state/bin`). Der Satz sagt jetzt dasselbe wie Festlegung 4 `:308-311`, der Widerspruch aus Runde 3 MEDIUM-2 ist fort |
| **`:160-164`** — Kopf trennt **je Kommando** statt je Punkt | **trägt** | Der Kopf sagt *„Die Trennung läuft je Kommando, nicht je Punkt: Der erste Punkt trägt beide"*, und Punkt 1 trägt real beide Bezugsmengen: gepinnt `git grep -l 'archive-welle' e28b887e -- 'test/mutations/*.sh' \| wc -l` → **7**, ungepinnt `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh \| wc -l` → **24**. Das Gegenteil in Fettschrift elf Zeilen darunter (`:177`) widerspricht dem Kopf nicht mehr, es erklärt ihn. Runde 3 MEDIUM-1 ist fort |
| **`:238`, `:425`, `:453`** — die Grenze *„der `git`-berührende Teil bleibt außerhalb des Test-Bildes"* aufgelöst; Zugewinn in Preis-Grund 1, Grenze in der **Körnung** | **trägt, beide neuen Zusagen einzeln gemessen** | **Zugewinn:** `grep -c '^func Test' cmd/ai-harness-init/archive_welle_echt_test.go` → **3**, `grep -c 't.Skip' <dieselbe>` → **0**, kein Build-Tag (die Datei beginnt mit `package main`), und sie liegt im `./...` der Test-Stufe (`Dockerfile:46-48` → `FROM warm AS test` / `RUN CGO_ENABLED=0 go test -count=1 ./...`, gebaut von `Makefile:56-57` `test-go`). Die Test-Stufe erbt von `golang:${GO_VERSION}` (`Dockerfile:14`) — der Zweig der Runde-3-Fallunterscheidung, in dem `git` im Bild liegt, ist der eingetretene; vier Fälle `249`–`252` hängen daran (`verify: test-go`, `expect: TestArchiveWelleEcht…`). **Körnung:** `git` startet in **genau einer** Nicht-Test-Datei (`git grep -n '"git"' -- '*.go' \| grep -v _test` → 2 Treffer, beide `cmd/ai-harness-init/archive_welle.go`; `internal/emit/emit.go` startet `docker`, nicht `git`). Vier schreibende Aufrufe (`Mv`, `Rm`, `Add`, `Commit`, `archive_welle.go:191-201`), und nur der erste trägt einen eigenen Fall (`test/mutations/252-archive-welle-go-mv-ohne-git.sh`); `245` mutiert `internal/archive/anwenden.go` und trifft die Reihenfolge, nicht die Verdrahtung. **Und die Aussage steht nirgends mehr:** `grep -n 'außerhalb des Test-Bildes' <adr>` → kein Treffer |
| **`:483-489`** — Folgepflicht 9 **umgekehrt**: die Referenz-Ausnahme bleibt stehen | **trägt, und die Sonde ist exakt** | **Statisch nachgerechnet statt nachgefahren:** `codepaths.exempt-paths` nimmt `docs/reviews/**` datei-weit aus (`.d-check.yml:206`), `codepaths.roots` sind `[spec, docs, harness]` (`:196`). Im verbleibenden Prüfbereich nennen **genau drei** Dateien den Pfad (`git grep -l 'harness/tools/archive-welle\.sh' -- spec docs harness \| grep -v '^docs/reviews/'`), alle unter `docs/plan/planning/done/`. Inline-Code-Vorkommen dort: **9** (`grep -o '\`[^\`]*harness/tools/archive-welle\.sh[^\`]*\`' docs/plan/planning/done/*.md \| wc -l`), davon **2** in `awk`-Kommandos mit Leerzeichen, die kein `codepaths`-Kandidat sind — bleiben **7** blanke Pfad-Spans in `slice-170` (1), `slice-173` (3) und `slice-175` (3). Die Sonde des Architect trifft die Zahl **und** die Zusammensetzung. Die Einordnung als Tombstone stimmt: [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) führt `codepaths.ignore-refs` genau dafür und ist **permanent** (*„`ignore-refs` wächst nur mit weiteren bewusst entfernten Artefakten"*). Die alte Fassung war eine Anweisung, `make gates` rot zu färben; die Umkehrung ist richtig |

---

## Findings

### MEDIUM-1 — Die eine stehengelassene Zahl misst nicht die Größe, die ihr Satz benennt: das Kommando zählt Link-Quellen, der Satz nennt Link-Ziele

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„trägt im selben Absatz das Kommando, das **genau sie** ausgibt … ein ungefähr
  passendes Kommando danebenzustellen ist der Fehler, nicht die Lücke"*); ADR-0033 Bezug-Block
  `:47-48` (*„jede Zahl unten steht neben dem Kommando, das sie liefert"*);
  [`AGENTS.md`](../../AGENTS.md) §3.4 (was ab `Accepted` einfriert)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:211` und `:377-378`
- **Fundort oder Fundmenge:** **gemessene Fundmenge, 2 Fundorte** —
  `grep -n 'Ziel eines' <adr>` → `:211`, `:378`; `grep -n '106' <adr>` → `:211`, `:377`. Die
  Fundmenge ist erschöpfend: beide Stellen tragen dieselbe Charakterisierung, es gibt keine dritte.
- **befund:** Beide Stellen sagen, **106** Report-Dateien seien *„heute **Ziel** eines Links aus
  einem anderen Report"*, und `:213` stellt das Kommando daneben:
  `for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l`.
  Dieses Kommando zählt **nicht** die Ziele. `grep -rlF -e "]($rb)"` listet die Dateien, **in
  denen** ein Link auf `$rb` steht — die *Quellen*; die Vereinigung über alle `$rb` ist damit die
  Menge der Reports, die auf irgendeinen anderen Report **zeigen**. Heute sind das **121**
  (Kommando oben, gefahren). Die Größe, die der Satz benennt — Reports, die **Ziel** eines solchen
  Links sind —, liefert das Kommando aus [`harness/README.md`](../../harness/README.md)`:390`
  (dasselbe `grep`, aber `| sed "s|.*|$rb|"` statt der Trefferliste) und steht heute bei **138**.
  Drei verschiedene Zahlen für zwei verschiedene Mengen: `106` (geschrieben), `121` (was das
  Kommando ausgibt), `138` (was der Satz behauptet). **Der Satz hat die Formulierung aus
  `harness/README.md` übernommen und ein anderes Kommando daneben gestellt** — dort steht
  *„83 Report-Dateien sind Ziel eines solchen Links"* neben dem ziel-zählenden Kommando, und dort
  passen Satz und Kommando zusammen. **Die Ausrede *„kein Erwartungswert"* deckt das nicht:**
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 erlaubt einer *mitwandernden* Zahl, als Nicht-Erwartungswert gekennzeichnet zu werden —
  sie erlaubt keiner Zahl, eine andere Menge zu benennen als die, die ihr Kommando zählt. Egal wie
  der Baum wächst, dieses Kommando wird die genannte Größe nie ausgeben. Der zweite Fundort
  (`:377-378`) liegt in **Abnahme-Kriterium 1**, also in einem normativen Teil der Entscheidung.
  **Zur Behebungs-Frage:** Das ist eine **Über-Zusage**, und sie gehört an `:377-378` **gestrichen**
  statt umformuliert — das Abnahme-Kriterium trägt seine Bindung aus dem Wächter und dem Fall, an
  dem er bricht, nicht aus einer Größenangabe; *„Der Suchraum ist nicht theoretisch"* ist bereits
  dadurch belegt, dass der Wächter existiert und die drei `done/`-Dateien ihn auslösen. An `:211`
  ist die Größenangabe dagegen das Argument selbst; dort muss der Satz benennen, was sein Kommando
  zählt, oder das ziel-zählende Kommando tragen — nur nicht beides vermischt weiterführen.
- **Failure-Szenario:** ADR-0033 wird `Accepted`, §3.4 friert sie ein. Ein späterer Lauf steht vor
  der ersten realen Archivierung — nach [`harness/README.md`](../../harness/README.md)`:390` hält
  heute genau die `haenger`-Sperre sie auf — und will den Umfang des Hänger-Suchraums abschätzen.
  Er liest im **Abnahme-Kriterium** der eingefrorenen Entscheidung *„106 Report-Dateien sind Ziel
  eines solchen Links"*, fährt das danebenstehende Kommando, bekommt `121` und hat keine Möglichkeit
  zu erkennen, dass die Zahl gar nicht die Ziele zählt. Rechnet er die Ziele selbst nach, findet er
  `138` und eine dritte Zahl. Er entscheidet über eine Sperre, die den ganzen Altbestand blockiert,
  auf einer Größe, die um ein Drittel danebenliegt — und die Korrektur kostet nach dem Accept eine
  Folge-ADR statt zweier Zeilen ([`AGENTS.md`](../../AGENTS.md) §3.4).
- **verifizierbar:** ja, **nicht durch einen Gate-Lauf** — kein Modul von `docs-check` hält eine
  Prosa-Größe gegen das Kommando daneben; `codepaths.check-lines` bindet Zeilen-Referenzen, nicht
  Mengen-Bezeichnungen. Nachrechenbar mit den drei Kommandos oben (`121` und `138`)
  und dem Kommando aus `harness/README.md:390`.
- **klasse:** Zahl benennt eine andere Menge, als ihr danebenstehendes Kommando zählt

### LOW-1 — Der §Geschichte-Eintrag friert eine Erschöpfungs-Zusage ein, die eine Ebene tiefer nicht gilt

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.4; ADR-0033 §Geschichte gegen
  ADR-0033 `:211`/`:377`
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:556`
- **Fundort oder Fundmenge:** **Fundort, einer** — die Zeile, die `3472f47a` an die §Geschichte
  anfügt (`git show 3472f47a -- <adr> | grep -c '^+|'` → **2** Tabellenzeilen, davon diese die §Geschichte-Zeile).
- **befund:** Der neue Eintrag sagt: *„jeder Satz dieser Datei, der eine Aussage über den heutigen
  Zustand von Repo, Bau oder Werkzeug trifft, ist einzeln gegen den Baum gemessen — vier hielten
  nicht."* Die erste Hälfte ist in der **Breite** eingelöst (Teil 1 oben bestätigt sie über einer
  unabhängig gebildeten Menge). Die zweite Hälfte zählt einen zu wenig: Eine fünfte Aussage wurde
  gemessen und hielt ebenfalls nicht — der Report-Zähler, den der Übergabe-Bericht selbst mit
  *„gemessen (heute 120), abweichend"* führt und der nach MEDIUM-1 nicht nur in der Ziffer, sondern
  in der benannten **Größe** danebenliegt. Der Eintrag erwähnt sie nur mittelbar
  (*„Die drei INFO weist der Report als kein Verstoß aus"*) und nennt sie nicht als gemessene
  Abweichung. Ab `Accepted` liest ein späterer Lauf daraus eine **Garantie**, dass jede
  Präsens-Zustandsaussage der Datei geprüft ist, und zählt die eine, die es nicht ist, nicht mehr
  nach — genau die Wirkung, die
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Was der Schaden ist als die teurere von zweien benennt (*„die Gewohnheit, ausgewiesene Messungen
  gar nicht erst nachzuzählen"*). **Kein §3.7-Verstoß:** Die `## Geschichte`-Tabelle einer ADR ist
  nicht die `Stand`-/`Status`-Zelle eines lebenden Registers, sondern der Abschnitt, in dem eine ADR
  ihre Fortschreibung führt — `exclude-sections: [Geschichte]` in
  [`.d-check.yml`](../../.d-check.yml)`:194`, begründet in
  [`harness/README.md`](../../harness/README.md). **Zur Behebungs-Frage:** eine Über-Zusage, aber
  eine, die durch **Streichen** der Erschöpfungs-Behauptung besser wird als durch Nachzählen — was
  der Eintrag trägt, sind die vier Ausgänge; *dass* die Menge vollständig war, ist eine Aussage über
  einen Lauf und in einer §Geschichte-Zelle ohnehin die schwächste Form.
- **Failure-Szenario:** Siehe MEDIUM-1 — dieser Eintrag ist der Grund, aus dem der dortige Lauf gar
  nicht erst nachrechnet.
- **verifizierbar:** ja, ohne Gate — der Eintrag selbst gegen die zwei Kommandos aus MEDIUM-1.
- **klasse:** Erschöpfungs-Zusage über eine selbst gebildete Menge, in einem einfrierenden Artefakt

### INFO-1 — Das ADR-0022-Zitat 5(a) ist im Wortlaut verbatim, schließt als Ausschnitt aber mit Punkt statt Semikolon

- **kategorie:** INFO
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:108-110`
- **Fundort oder Fundmenge:** **Fundort, einer** — vom behebenden Lauf selbst offengelegt.
- **befund:** Das Zitat *„Kann der Träger nicht abgelegt werden, wird weder Träger noch Wrapper noch
  Hook-Eintrag geschrieben, der Bootstrap nennt den Grund und endet erfolgreich."* ist im Wortlaut
  deckungsgleich — normalisiert nach ADR-0016 Festlegung 2
  (`tr -s ' \n' '  ' | sed 's/\*\*//g' | grep -oF <zitat ohne Schlusszeichen> | wc -l` → **1**). Das
  Original (`docs/plan/adr/0022-…:464-466`) setzt an dieser Stelle ein **Semikolon** und fährt fort:
  *„; das Ziel ist ohne Erfassung vollständig und sein `make gates` grün."* Der Ausschnitt ersetzt es
  durch einen Punkt und zeigt keine Auslassung an. **Kein Verstoß:** ADR-0016 Festlegung 2 bindet die
  Form eines **Regelwerks**-Belegs, nicht die eines ADR-internen Zitats, und definiert *verbatim* als
  *„der Wortlaut ohne Auszeichnung, Whitespace normalisiert"* — der Wortlaut stimmt. Die weggelassene
  Hälfte **stützt** die Verwendung zusätzlich (das Ziel ist ohne die Fähigkeit vollständig), sie
  schwächt sie nicht; eine Sinn-Verschiebung gibt es nicht. Notiert, weil ein Ausschnitt ohne
  Auslassungszeichen in einem einfrierenden Artefakt als vollständiger Satz weitergereicht wird.
- **verifizierbar:** ja — das Normalisierungs-Kommando oben und `sed -n '462,472p' docs/plan/adr/0022-*.md`.
- **klasse:** Zitat-Ausschnitt ohne Auslassungszeichen

### INFO-2 — Ob der Preis-Satz aus Festlegung 5 den Zweig des Trägers teilt, ist weiter offen (unverändert aus Runde 3)

- **kategorie:** INFO
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 5(a) und 7; ADR-0033 Festlegung 4 und 5
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:301-314`, `:346-350`
- **Fundort oder Fundmenge:** **Fundort, einer**; `3472f47a` hat den Bereich nicht angefasst
  (`git show 3472f47a -- <adr>` zeigt keinen Hunk zwischen `:301` und `:350`).
- **befund:** Festlegung 4 baut das Fragment *„wie das der Erfassungsschicht"*, und dessen Präzedenz
  ist ausdrücklich **unbedingt**: `internal/emit/erfassung.go:16` schreibt *„UNBEDINGT, und das ist
  eine Entscheidung: es teilt den Zweig des Traegers NICHT"* und begründet es damit, dass jenes
  Fragment *„nichts behauptet"*. Derselbe Kommentar nennt die Ausnahme: *„Festlegung 7 nimmt die
  Feldliste dazu, weil sie eine Aussage UEBER eine Erfassung waere, die nicht liegt."* Der Kopf-Satz,
  den ADR-0033 Festlegung 5 verlangt, ist eine Aussage darüber, *„was der abgelegte Träger kann"*
  (`:347`) — in einem Ziel, dessen Träger-Ablage nach 5(a) scheiterte, läge er über eine Fähigkeit,
  die nicht da ist, und fiele damit in die Klasse, die Festlegung 7 bedingt macht. **Kein Verstoß:**
  ADR-0033 sagt für ihr Fragment ausdrücklich *„fehlt der Träger, **sagt** es das und endet
  erfolgreich"* (`:314`), was es in die `erfassung.mk`-Klasse stellt, und die Formulierung des
  Kopf-Satzes gehört dem Implementer (Folgepflicht 7). Erneut notiert, weil die Datei die Frage
  weder stellt noch beantwortet und ab `Accepted` nicht mehr nachgeschärft werden kann.
- **verifizierbar:** ja — `sed -n '14,26p' internal/emit/erfassung.go` und die zwei ADR-Stellen.
- **klasse:** dokumentationswürdige, undokumentierte Annahme

### INFO-3 — Der Fege-Lauf hat die Zeitform innerhalb des dreiteiligen Preis-Grunds ungleich gemacht

- **kategorie:** INFO
- **quelle:** Maintainability; ADR-0033 `:189-190` gegen `:248-250`
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:248-250`
- **Fundort oder Fundmenge:** **Fundort, einer** — der zweite von drei Preis-Gründen.
- **befund:** `3472f47a` hat Preis-Grund 1 in den **Indikativ Präsens über den heutigen Bau**
  gezogen (*„der `git`-berührende Teil wandert mit"*, *„wird gegen ein echtes Scratch-Repo
  gemessen"*). Preis-Grund 2 daneben steht weiter auf der Entscheidungs-Warte: *„der vierte Digest im
  Makefile verliert seinen Gegenstand"* — während §Was heute gemessen ist elf Zeilen darüber misst,
  dass das Makefile **3** Bild-Pins führt (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**, selbst
  gefahren; `ARCHIVE_IMAGE` ist fort). Es gibt heute keinen vierten Digest, der etwas verlieren
  könnte. **Kein Verstoß, und ausdrücklich keine Neuauflage:** Runde 3 hat entschieden, dass vier
  bereits eingelöste Folgepflichten in einer `Proposed`-Datei kein Befund sind, weil die Datei sich
  selbst als Verdikt und Constraint des Ports ausweist (`:395-396`) — Preis-Grund 2 und Folgepflicht 4
  (`:474-475`) sagen dasselbe in derselben Zeitform und fallen unter dieselbe Entscheidung. Notiert,
  weil der Fege-Lauf die drei Gründe **auseinandergezogen** hat: Grund 1 beschreibt jetzt heute,
  Grund 2 den Entscheidungs-Zeitpunkt, und ein späterer Leser muss das aus dem Inhalt erschließen.
- **verifizierbar:** ja, ohne Gate — die zwei Stellen und das Pin-Kommando.
- **klasse:** ungleiche Zeitform innerhalb einer Aufzählung nach Teil-Korrektur

### INFO-4 — Außerhalb des Prüfgegenstands: die `ignore-refs`-Zählung in AGENTS.md §3.11 ist überholt

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- **pfad:** `AGENTS.md` §3.11 (nicht ADR-0033)
- **Fundort oder Fundmenge:** **Fundort, einer** — beim Prüfen von Folgepflicht 9 mitgemessen.
- **befund:** [`AGENTS.md`](../../AGENTS.md) §3.11 begründet sich mit *„Vier namentlich geschnittene
  Referenz-Ventile stehen heute in der Gate-Config"* und stellt `grep -c '^  - in: ' .d-check.yml`
  → **4** daneben. Dasselbe Kommando gibt heute **7** (selbst gefahren). **Nicht Gegenstand dieses
  Reviews** und **kein** Befund gegen ADR-0033: Jene Zählung betrifft die Paar-Form unter
  `links.ignore-refs` (`.d-check.yml:80 ff.`), Folgepflicht 9 dagegen die blanke Liste unter
  `codepaths.ignore-refs` (`:236 ff.`) — zwei verschiedene Mechanismen. Notiert, weil ein Leser von
  Folgepflicht 9 die beiden Listen leicht zusammenzieht und dann eine Hard Rule zitiert, die eine
  andere Liste zählt. Die Datei gehört nach [`AGENTS.md`](../../AGENTS.md) §3.8 dem **Architect**.
- **verifizierbar:** ja, ohne Gate — `grep -c '^  - in: ' .d-check.yml` → **7**.
- **klasse:** Präsens-Messwert im lebenden Norm-Artefakt

---

## Negativbefunde (geprüft, ohne Befund)

- **Die eigentliche Konsistenz-Frage ist beantwortet, und sie ist in dieser Runde eigenständig
  gefahren, nicht aus Runde 3 übernommen.** ADR-0033 widerspricht in ihrer heutigen Fassung keiner
  bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007. `3472f47a` hat mit Preis-Grund 1 und
  Folgepflicht 9 genau zwei Bereiche angefasst, die an diese drei grenzen; beide sind unten einzeln
  gehalten. MEDIUM-1 und LOW-1 sind Mess- bzw. Selbstaussage-Defekte der Datei, keine Kollisionen.
- **Gegen ADR-0022 — die kritischste Stelle trägt weiter, und der neue Text hat sie nicht bewegt.**
  Die naheliegende Kollision wäre Festlegung 5(a): ein Fragment, das unabhängig vom Träger entsteht.
  Sie tritt nicht ein — die Aufzählung dort ist auf **drei** Hook-Artefakte geschnitten (Träger,
  Wrapper, Hook-Eintrag), und der gebaute Präzedenzfall entscheidet dieselbe Frage bereits gleich und
  begründet sie (`internal/emit/erfassung.go:16-25`). Die **sechs** zitierten Festlegungen **1, 2,
  5(a), 5(b), 6, 7** sind je **1×** wortgleich nachgewiesen, normalisiert nach ADR-0016 Festlegung 2
  (`tr -s ' \n' '  ' | sed 's/\*\*//g' | grep -oF <zitat> | wc -l`, sechs von sechs; 5(a) mit der
  in INFO-1 benannten Schlusszeichen-Abweichung).
- **Alle Eigenschaften, die Festlegung 4 dem Vorbild zuschreibt, halten am gebauten Fragment.** Gegen
  `internal/emit/templates/enforce/erfassung.mk`, selbst gelesen: der Kopf trägt *„ZWEI KOMMANDOS,
  KEIN GATE"* wörtlich; `GATE_CHECKS` kommt in der Datei nicht vor; `span-report` macht ein Kommando
  des Trägers über `make` erreichbar und `span-clean` steht daneben; fehlt der Träger, sagt
  `span-report` das und endet erfolgreich. Mechanik daneben:
  `grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` → **1**,
  `grep -c 'wachstumsSatz' internal/emit/erfassung_test.go` → **4**,
  `ls internal/emit/templates/enforce/` nennt `enforce.mk` und `erfassung.mk` (*„der Emitter legt
  heute mehrere ab"*), und der Dogfood führt die Klasse selbst nicht (`ls -d harness/mk` → Exit 2).
  **Alle vier nach dem Fremd-Commit `71f3fd9b` wiederholt.**
- **Gegen ADR-0007 — keine Kollision, und die zwei zitierten Zuordnungen stimmen wörtlich.**
  `harness/mk/*.mk` steht in der Idempotenz-Tabelle jener Festlegung 3 als **konvergent**
  (`docs/plan/adr/0007-bootstrap-phasen.md:100`), `docs/plan/adr/*` als **skip-if-present** (`:101`)
  — beides genau so, wie ADR-0033 Festlegung 4 und 5 es zitieren. Das Fragment ist reiner Text und
  verlangt im Ziel keinen Bauschritt und keine Toolchain; die Inversion, gegen die ADR-0007 steht,
  entsteht nicht. Die Ablehnung von Alternative D bleibt Anwendung statt Berufung.
- **Gegen ADR-0003 — keine Kollision, auch nach der Änderung an Preis-Grund 1.** Die Entscheidung
  wählt ein Unterkommando des nativ ausgelieferten Produkt-Binärs; Alternative E wird mit der
  Begründung verworfen, die dort steht (`grep -n 'Vertriebsmittel' docs/plan/adr/0003-*.md` → `:35`).
  Der neue Zugewinn-Satz in Preis-Grund 1 bewegt nichts an dieser Achse: er spricht über den
  **Prüfbereich** im gepinnten Go-Bild, nicht über ein Vertriebsmittel. Der Wegfall des vierten
  Bild-Pins ist real (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**: `BATS_IMAGE`,
  `SHELLCHECK_IMAGE`, `ACTIONLINT_IMAGE` — keiner packt ein Archiv), und das Zip kommt aus der
  Standardbibliothek (`grep -rn '"archive/zip"' internal/archive/` → `anwenden.go:4`).
- **Jedes Inline-Kommando der Datei ist selbst gefahren und liefert die Zahl, die daneben steht —
  mit der einen Ausnahme aus MEDIUM-1.** `spec/architecture.md` → **0** · `close-welle.md` → **1** ·
  `case "archive-welle"` → **1** · `carrierDir` → **1** · `case "span-` → **2** ·
  `e28b887e`-Mutations-Menge → **7** · `233`er Inhalts-`grep` → **0** · Namens-Menge → **24** ·
  Bild-Pins → **3** · `d-check`-Vorbild → **7** · Stub-Vorlagen über
  `TAG=$(sed -n 's/^BASELINE_TAG ?= //p' Makefile)` → **2** · `^func Test` im echt-Test → **3** ·
  `t.Skip` → **0** · Glob-Include → **1** · emittierte ADR-Vorlagen → **Exit 2** ·
  `baseline/v[0-9]` → **0** · `wachstumsSatz` → **4** · `full-smoke` `archive` → **0** ·
  `internal/emit/` `archive-welle` → **0**. **Die letzten beiden und die Namens-Menge sind nach
  `71f3fd9b` wiederholt** und unverändert. Das Auflistungs-Kommando der §Fitness Function läuft und
  gibt **22** verschiedene `expect:`-Werte über den 24 Fällen.
- **Die Präsens-Zustandsaussagen ohne Kommando tragen — alle, die die Menge oben ausweist.**
  `:87` Selbst-Kopie des laufenden Bildes (`os.Executable` in `internal/emit/enforce.go:274`) ·
  `:103` Ablageort `.harness/state/bin` (`enforce.go:73`) · `:171-173` der bats-Satz sprach im Kopf
  selbst aus, dass er den Hauptpfad auslässt — **wörtlich** bestätigt
  (`git show e28b887e:test/archive-welle.bats | sed -n '4,8p'`: *„Alle Faelle sourcen das Skript …
  und rufen die reinen Funktionen ueber synthetischen Proben auf. main() selbst braucht ein echtes
  `git`-Repo UND Docker"*) · `:178-182` an der Mess-Basis fielen Inhalts- und Namens-Treffer
  zusammen, heute nicht mehr — **exakt** bestätigt: an `e28b887e` liefern beide Achsen dieselben
  sieben Dateien `225`–`231`, heute liefert der Inhalts-`grep` **8** und die Namens-Achse **24**, und
  die Differenz Inhalt-minus-Name sind genau drei Fälle der Dispatch-Kopplung
  (`256-hostbin-zweite-nennung…`, `259-hostbin-name-mit-ziffer`, `261-dispatch-marke-nur-im-kommentar`)
  · `:191-194` die Zerlegung des Vorbilds in vier Gegenstände plus Einstiegspunkt plus zwei
  Modus-Dateien deckt die **7** Testdateien restlos ab (`collect`, `rewrite`, `stub`, `archive`,
  `main`, `review_mode`, `slice_mode`) · `:313` der Dogfood führt `harness/mk` nicht (Exit 2) ·
  `:433` ein Einstiegspunkt (`ls -d cmd/*/` → genau `cmd/ai-harness-init/`), eine Lint-Config
  (`.golangci.yml`), ein Test-Runner (ein `go.mod`) · `:437` das Vorbild ist portabel per
  Konstruktion (`module archive-wave`, nur Standardbibliothek in den Nicht-Test-Importen).
- **Jede Charakterisierung einer fremden Quelle im Bezug-Block trägt.**
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1
  (Kennung statt Pfad-Link über beide Adress-Formen) und Festlegung 2 (erneute Runde derselben
  prüfenden Rolle; die Nachmessung des auflösenden Kontexts ist keiner) stehen wörtlich so da
  (`:123-136`) · [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  Festlegung 3 (`:249-255`) · [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) liefert
  Regelwerk **und** Doc-Templates als vendored Baseline ins Ziel (`:45`) ·
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) hat genau
  **drei** Akzeptanzkriterien, keines nennt ein Werkzeug hinter einem Schritt (der ganze Abschnitt
  gegen `grep -i 'archiv\|werkzeug\|harness/mk'` → kein Treffer) · der zitierte Anweisungssatz steht
  in Schritt 4 von `close-welle.md` (`:87-91`, gefolgt von *„Schritt 5"* in `:95`) ·
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) *„Erstklassig auf allen dreien
  ohne WSL2-Zwang"* → **1** normalisiert · `bash + git + docker` steht in
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (`lastenheft.md:156`).
- **Die drei Baseline-Zitate sind verbatim, tag-genannt und ohne lokalen Vendoring-Präfix.**
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur *„gehört die Operation in ein Werkzeug und nicht in
  Handarbeit"* → **1** · dieselbe Datei *„Ziel-Form: archiv-stub-slice.template.md und
  archiv-stub-welle.template.md"* → **1** nach Link- und Backtick-Strip ·
  `modul-08-agentenrollen.md` §Rollen-Regeln *„ADR-Änderung: Architect schreibt; Reviewer prüft auf
  Konsistenz; Implementer liest als Constraint"* → **1**. Alle drei über `v6.5.0`, dem Stand aus
  `BASELINE_TAG`.
- **Die §Schärft-Aussage hält, beide Hälften.** `grep -c 'span-emit\|span-report\|archive-welle'
  spec/architecture.md` → **0**, und das Technik-Stratum nennt Unterkommandos ausschließlich in
  seinem Telemetrie-Abschnitt: die drei Treffer in `spec/spezifikation.md` (`:70`, `:634`, `:637`)
  liegen sämtlich unter `## 5. Metriken und Tracing-Felder` (je über
  `awk 'NR<=N && /^#{1,3} /{h=$0} NR==N{print h}'` bestimmt).
- **Die Fitness-Function-Tabelle behauptet keine Deckung, die es nicht gibt.**
  `grep -c '\*\*Geliefert\*\*'` → **5**, `grep -c 'Geschuldet, nicht geliefert'` → **2** — deckt den
  Kopfsatz *„Fünf Zeilen sind eingelöst, zwei sind offen"*. Alle **6** namentlich genannten Wächter
  existieren (je `grep -rl "func <name>" --include='*_test.go' .` → **1**), und die Zeilen nennen
  ausschließlich existierende Targets. Die zwei `Geschuldet`-Zeilen sind heute korrekt und nicht
  überholt (beide Kommandos → **0**, nach `71f3fd9b` wiederholt). Dass die Tabelle die drei
  echt-Repo-Fälle nicht als eigene Zeile führt, ist **kein** Befund: sie bilden keine Regel der
  Entscheidung ab, sondern den Prüfbereich, und der steht seit `3472f47a` in Preis-Grund 1 und als
  Körnungs-Grenze in §Konsequenzen.
- **Die Selbstaussage über bewegliche Adressen hält, auch für die zwei neu eingeführten Pfade.**
  Vollständig ausgezählt über beide Adress-Formen (Kommandos im Methoden-Block oben): Inline-Code
  führt `./...`, `cmd/ai-harness-init/archive_welle.go`, `../<datei>.md`, `docs/plan/adr/*`,
  `docs/plan/planning/`, `docs/plan/planning/done/`, `docs/reviews/`, `docs/reviews/**`,
  `.harness/baseline/`, `.harness/baseline/<tag>/templates/docs/plan/planning/`, `harness/mk/*.mk`,
  `harness/README.md`, `.harness/state/bin`, `harness/tools/` — Globs, ortsfeste Verzeichnisse,
  tag-lose Layout-Beschreibungen oder ortsfeste Dateien; kein Planning-Lifecycle-**Artefakt**, kein
  Tag-Literal (`grep -c 'baseline/v[0-9]' <adr>` → **0**). Die zwei neuen sind
  `cmd/ai-harness-init/archive_welle.go` (Quelldatei, vom Prozess nicht bewegt) und
  `docs/plan/planning/done/` (Verzeichnis — nach [`AGENTS.md`](../../AGENTS.md) §3.11 ausdrücklich
  ortsfest). **Und die neue Folgepflicht 9 nennt den Pfad des abgeschafften Shell-Helfers nicht**,
  sondern umschreibt ihn — genau das, was `:410-411` zusagt. Alle Markdown-Link-Ziele zeigen auf
  ortsfeste Artefakte; kein Review-Report ist als Link genannt.
- **Die §3.4-Nennung an `:498` folgt der Kurzform, die die Hard Rule selbst führt.** Der Satz nennt
  drei Zeitdokumente unter `docs/plan/planning/done/` als *„nach `AGENTS.md` §3.4 eingefroren"*,
  obwohl §3.4 dem Wortlaut nach nur ADRs bindet. **Kein Befund:**
  [`AGENTS.md`](../../AGENTS.md) §3.11 definiert die einfrierende Klasse selbst und setzt genau
  dort *„(§3.4)"* als Zeiger (*„jedes Artefakt, das nach Abschluss nicht mehr angefasst wird
  (§3.4)"*); [`harness/README.md`](../../harness/README.md)`:390` benutzt dieselbe Kurzform. Die ADR
  verwendet §3.11 an `:406` daneben korrekt, kennt die Unterscheidung also.
- **Kein Vertrags-Stratum berührt, kein Change Request fällig.** `grep -c 'harness/mk'
  spec/lastenheft.md` → **0**; die Akzeptanzkriterien von `LH-FA-08` zählen die drei
  `.claude/commands/…`-Dateien auf und kein `.mk`-Fragment. Die Selbstaussage *„Die Aufzählung aus
  `LH-FA-08` wächst nicht"* hält.
- **Keine Referenz auf eine superseded ADR.** Alle **9** referenzierten ADRs stehen auf `Accepted`
  (je `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/<n>-*.md`, selbst gefahren).
- **Der §Geschichte-Anteil ist gemessen und liegt im Rahmen — der Befund dazu ist inhaltlich, nicht
  volumetrisch.** **10,7 %** heute gegen **8,1 %** vor `3472f47a` (je
  `t=$(wc -c < <adr>); g=$(awk '/^## Geschichte/{i=1} i' <adr> | wc -c)`), gegen einen Repo-Schnitt
  von **8,3 %** und ein Maximum von **28,1 %** (`docs/plan/adr/0012-…`, dieselbe Schleife über
  `docs/plan/adr/[0-9]*.md`). Alle vier Werte des Übergabe-Berichts sind damit bestätigt. Der neue
  Eintrag nennt je Befund den **Ausgang** und die neue Aussage der Datei, nicht den Verlauf des
  Laufs; die Vorrunden-Zeilen sind unangetastet. Was an ihm zu beanstanden ist, steht in LOW-1 und
  betrifft eine Erschöpfungs-Zusage, nicht die Länge.
- **Der Beleg-Weg des Accept-Übergangs ist korrekt vorbereitet und unverändert.** §Der
  Acceptance-Trigger gibt ADR-0040 Festlegung 2 richtig wieder und benennt für die künftige
  Accept-Zeile die Kennungs-Form aus Festlegung 1. Diese Runde ist die von Festlegung 2 verlangte
  **vierte**, gefahren in einem Kontext, der `3472f47a` nicht geschrieben hat.
- **Realitätslage im Übrigen.** Der Shell-Helfer ist fort (`ls harness/tools/ | grep -c 'archive'` →
  **0**), sein bats-Satz ebenso, die sieben Fälle `225`–`231` existieren nicht mehr, und
  `make archive-welle` zeigt auf den Träger (`grep -n -A2 '^archive-welle:' Makefile` →
  `@$(HOST_BIN) archive-welle "$(WELLE)"`). Die vier Gegenstände der Operation liegen als
  `collect.go`, `refs.go`, `stub.go` und die Zip-Hälfte in `anwenden.go` unter `internal/archive/`.
  Dass vier Folgepflichten eingelöst sind, während die Datei `Proposed` steht, ist wie in Runde 3
  **kein** Befund.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 1 | Zahl benennt eine andere Menge, als ihr danebenstehendes Kommando zählt |
| **LOW** | 1 | Erschöpfungs-Zusage über eine selbst gebildete Menge, in einem einfrierenden Artefakt |
| **INFO** | 4 | Zitat-Ausschnitt ohne Auslassungszeichen · dokumentationswürdige, undokumentierte Annahme · ungleiche Zeitform innerhalb einer Aufzählung nach Teil-Korrektur · Präsens-Messwert im lebenden Norm-Artefakt (außerhalb des Gegenstands) |

**Der Fege-Lauf hat gewirkt, und das ist die tragende Aussage dieser Runde.** Drei Runden lang fiel
in jeder eine Aussage über den heutigen Zustand von Repo, Bau oder Werkzeug — an immer neuen
Stellen, weil jeder Behebungs-Lauf seine Fundmenge über ein Wortmuster zog. Diese Runde hat die
Menge **unabhängig neu gebildet**, über zwei mechanische Achsen plus die vier Klassen, die kein
Muster trifft, und **keine einzige** dieser Aussagen widerlegt. Die Klasse
*Zustandsaussage, die der Baum widerlegt* ist damit erledigt.

**MEDIUM-1 ist keine Wiederkehr dieser Klasse, sondern die Ebene darunter.** Er entsteht nicht,
weil eine Aussage ungemessen blieb, sondern weil drei Runden lang dieselbe **falsche Frage**
gestellt wurde: *gibt das Kommando dieselbe Ziffer?* statt *zählt das Kommando dasselbe wie der
Satz?* Genau diese Unterscheidung nennt
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 beim Namen. Es ist die **fünfte** Berührung des Report-Zählers über vier Runden — und die
erste, die seine Größe statt seines Werts misst
([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation: die dritte
Wiederholung derselben Klasse ist ein Steering-Loop-Signal, *Guide/Sensor nachziehen statt nur
melden*). Ob ein Zähler-Schritt im Beobachtungs-Register fällt, entscheidet die Closure und nicht
dieser Report; die Klasse ist eine andere als die der Vorrunden und beginnt bei 1.

**LOW-1 ist die Spiegelung von MEDIUM-1 im einfrierenden Artefakt** und fällt mit ihm.

---

## Verdikt

**Blockierender Befund: ja.**

**Der Acceptance-Trigger ist damit nicht erfüllt.** Er verlangt einen Report *„ohne blockierenden
Befund"*; dieser trägt einen MEDIUM, und nach
[`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage blockieren HIGH und
MEDIUM typischerweise. **Ein Architect-Lauf kann `Accepted` auf dieser Grundlage nicht setzen.**

**Die Abweichung zur Vorrunde ist begründet, nicht stillschweigend.** Runde 2 und Runde 3 haben den
Report-Zähler je als INFO geführt und *„kein Verstoß"* ausgewiesen. Diese Runde stuft ihn hoch, und
zwar nicht wegen der gewachsenen Differenz, sondern weil beide Vorrunden eine andere Eigenschaft
geprüft haben: sie haben die **Ziffer** gegen das Kommando gehalten und es dabei belassen, dass die
Datei sie als Nicht-Erwartungswert kennzeichnet. Gemessen ist jetzt die **Menge**: das Kommando
zählt Link-Quellen (**121**), der Satz benennt Link-Ziele (**138**), geschrieben steht **106**. Für
diese Lage gibt es keine Setzung-2-Ausnahme — sie greift für eine Zahl, die *mitwandert*, nicht für
eine, die eine andere Größe benennt als ihr Kommando misst.

**Die Konsistenz-Frage selbst fällt zugunsten der ADR aus, und sie ist in dieser Runde eigenständig
gefahren.** ADR-0033 widerspricht keiner bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007.
Alle sechs zitierten Festlegungen von ADR-0022 und die zwei Zuordnungen aus ADR-0007 sind wortgleich
nachgewiesen; die kritischste Stelle — ein Fragment, das unabhängig vom Träger entsteht, gegen
ADR-0022 Festlegung 5(a) — bleibt durch den gebauten Präzedenzfall gedeckt, und `3472f47a` hat an
dieser Konstruktion nichts bewegt.

**Alle vier Änderungen aus `3472f47a` tragen, jede einzeln nachgemessen** — einschließlich der
beiden **neuen** Zusagen (der Zugewinn im Prüfbereich und die Körnungs-Grenze über den vier
schreibenden `git`-Aufrufen) und einschließlich der Umkehrung von Folgepflicht 9, deren Sonde hier
statisch nachgerechnet und in Zahl **und** Zusammensetzung exakt bestätigt ist: **7** blanke
Inline-Code-Spans in **drei** Dateien unter `docs/plan/planning/done/`. Die alte Fassung war eine
Anweisung, `make gates` rot zu färben; die Umkehrung ist richtig und nach
[`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) korrekt
eingeordnet.

**Der Befund ist behebbar, solange die Datei `Proposed` steht** — und nur solange: Nach dem Accept
kostet er eine Folge-ADR statt zweier Zeilen ([`AGENTS.md`](../../AGENTS.md) §3.4). Lösungswege
stehen bewusst nicht im Finding-Feld ([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md)
§Anti-Pattern); die vom Auftrag verlangte Einschätzung *streichen statt reparieren* steht in MEDIUM-1
und LOW-1 je in einem eigenen Absatz. Die Übergabe geht an den Architect, dem die Datei gehört.

**Für den Wiedervorlage-Weg gilt weiter
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2:** Da
auch diese Runde blockiert, ist der Beleg für den Accept-Übergang eine **fünfte** Runde derselben
prüfenden Rolle — nicht die Nachmessung durch den Kontext, der diesen Befund auflöst.

**Vorbehalt zur Gate-Verifikation.** `make gates`, `make mutate`, `make full-smoke`, `make test` und
jeder `docker build` sind für diesen Lauf untersagt; der Auftraggeber fährt `make gates` selbst. Für
die Befunde dieses Reports ist der Vorbehalt gegenstandslos: MEDIUM-1 und LOW-1 sind mit `grep`,
`for` und `wc` nachrechenbar, jedes Kommando steht neben seiner Zahl, und kein Gate-Ziel würde einen
von beiden bestätigen — `docs-check` prüft Adress-Auflösung, nicht ob eine Prosa-Größe zu ihrem
Kommando passt. **Der eine erlaubte `docker run` ist nicht verbraucht worden**, weil die einzige
Messung, die ihn nahegelegt hätte, statisch exakt zu führen war; damit ist auch die
Link-Auflösung **dieses** Reports ungeprüft und fällt dem nächsten `make docs-check` des
Auftraggebers zu.
