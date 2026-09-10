# Review-Report — ADR-0033 auf Konsistenz gegen ADR-0022, ADR-0003, ADR-0007 (Runde 5)

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 5

**Gegenstand:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
(`Proposed`) — Konsistenz-Prüfung, **kein** Code-Diff-Review. Ausgelöst vom Acceptance-Trigger
jener Datei; sie verlangt eine Reviewer-Runde gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md). Dieser Lauf ist die **erneute Runde derselben
prüfenden Rolle**, die [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 nach einem blockierenden Befund als Beleg fordert — verbatim: *„Die Nachmessung durch
den Kontext, der den Befund aufgelöst hat, ist keiner."* Der auflösende Kontext war der
Architect-Lauf `82eb384c`; dieser Lauf ist er nicht.

**Vorgängerinnen:** `2026-09-09-adr-0033-konsistenz-review.md` (Runde 1, blockierend),
`2026-09-10-adr-0033-konsistenz-review-runde-2.md` (Runde 2, blockierend),
`2026-09-10-adr-0033-konsistenz-review-runde-3.md` (Runde 3, blockierend) und
`2026-09-10-adr-0033-konsistenz-review-runde-4.md` (Runde 4, 0 HIGH / 1 MEDIUM / 1 LOW / 4 INFO,
blockierend). Alle vier stehen als **Kennung** und nicht als Pfad-Link: Ein Review-Report ist
eines der Zeitdokumente, die die Operation dieser Entscheidung ins Wellen-Archiv bewegt, und
dieser Report friert mit seinem Abschluss ein ([`AGENTS.md`](../../AGENTS.md) §3.11). **Das ist
hier zugleich eine Mess-Vorsichtsmaßnahme:** die Kennungs-Form hält diesen Report aus der
Bezugsmenge des Zählers heraus, den ADR-0033 `:211` führt (siehe INFO-1).

**Behebung, die geprüft wird:** `82eb384c` („Rolle Architect: ADR-0033 — zwei Ueber-Zusagen
gestrichen (Runde 4)"), **4** Einfügungen und **5** Streichungen in **1** Datei
(`git show --stat 82eb384c`; der Range `5ff3f6fa..82eb384c` trägt daneben `947ce22d`, einen
fremden Vorgang, der allein `docs/reviews/` ergänzt).

**Baum-Stand beim Lauf:** `git status --porcelain` ist **leer**, `git rev-parse --short HEAD` →
`82eb384c`, und der Prüfgegenstand ist seither unangetastet
(`git log --oneline 82eb384c..HEAD -- <adr> | wc -l` → **0**).

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Prüfgegenstand ist eine ADR
statt eines Diffs, also treten die Datei und der Behebungs-Commit an die Stelle von Diff und
Slice-Plan. Betroffene Anforderungen: `LH-FA-08`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
Referenzierte ADRs: 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040 — **alle neun
`Accepted`**, selbst gemessen, keine superseded Referenz:

```sh
grep -oE '\(0[0-9]{3}-[a-z0-9-]+\.md\)' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md \
  | tr -d '()' | sort -u | while read -r x; do grep -m1 '^\*\*Status:\*\*' "docs/plan/adr/$x"; done
```

Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3.4, §3.5, §3.6, §3.7, §3.11. Vorherige Findings am
gleichen Gegenstand: die sechs der Runde 1, die drei der Runde 2, die sechs der Runde 3 und die
sechs der Runde 4.

**Mess-Disziplin.** Jede Zahl unten steht neben dem Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), und bei jeder Zahl der ADR ist geprüft, **ob das danebenstehende Kommando die Größe
misst, die der Satz benennt** — die Frage, die Runde 4 eingeführt hat. Jeder Befund nennt
ausdrücklich **Fundort** oder **gemessene Fundmenge** samt Kommando.

**Die Konsistenz-Prüfung ist in dieser Runde eigenständig gefahren**, nicht aus Runde 3 oder 4
übernommen: die Landkarte der Vorrunde diente als Auswahl der Prüfpunkte, jeder Beleg unten stammt
aus einem Kommando dieses Laufs. Sie ist damit die Prüfung, die der Acceptance-Trigger verlangt.

**Gate-Verifikation — aufgeschoben, und der erlaubte Docker-Lauf ist nicht gebraucht worden.**
`make gates`, `make mutate`, `make full-smoke`, `make test` und jeder `docker build` sind für
diesen Lauf untersagt (ein fremder `make mutate`-Vollauf teilt sich die Docker-Tags); der
Auftraggeber fährt `make gates` selbst. Der eine erlaubte `docker run` gegen den in
[`d-check.mk`](../../d-check.mk) gepinnten Digest ist **nicht** gefahren worden: kein Befund unten
hängt an ihm. Die eine Stelle, an der ein Lauf nötig schien — die **7** `codepath-missing` aus
Folgepflicht 9 —, ist statisch nachgerechnet und **exakt** bestätigt, samt dem Mechanismus, der
sie auf sieben begrenzt (INFO-1, Kommandos dort).

---

## Teil 1 — Die zwei Behebungen aus Runde 4

**Der Diff ist vollständig gelesen, Wort für Wort**
(`git diff --word-diff=porcelain 5ff3f6fa..82eb384c -- <adr>`): **vier** Änderungs-Stellen, keine
fünfte.

### (1) MEDIUM-1, Fundort `:211` — Satz auf die Größe umformuliert, die sein Kommando zählt

Vorher: *„wäre für **106** Report-Dateien blind, die heute **Ziel** eines Links aus einem anderen
Report sind"*. Nachher: *„wäre für **122** Report-Dateien blind, die heute **auf einen** anderen
Report **zeigen**"*. **Beide Größen selbst gemessen, mit beiden Kommandos, am selben Baum:**

```sh
# das Kommando, das in ADR-0033 :212 danebensteht  -> Link-QUELLEN
for r in docs/reviews/*.md; do rb=$(basename "$r"); \
  grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l          # 122
# das ziel-zaehlende Kommando aus harness/README.md -> Link-ZIELE
for r in docs/reviews/*.md; do rb="${r##*/}"; \
  grep -rlF -e "]($rb)" docs/reviews/ | grep -vxF "$r" | sed "s|.*|$rb|"; done | sort -u | wc -l   # 139
ls docs/reviews/*.md | wc -l                                                             # 331
```

**Urteil: Satz und Kommando benennen jetzt dieselbe Menge.** `grep -rlF -e "](…)"` listet die
Dateien, **in denen** der Link steht — die Quellen —, und die Vereinigung über alle Basisnamen ist
genau *„Reports, die auf einen anderen Report zeigen"*. Die Selbst-Referenz fällt je Durchlauf über
`grep -v "^$r$"` heraus, ein Report zählt also nicht, weil er sich selbst verlinkt (Gegenprobe:
**209** Reports sind **nicht** in der Quellmenge, 122 + 209 = 331).

**Und die Größe ist die richtige für das Argument.** Ein Wächter, der `docs/reviews/**` aus seinem
**Suchraum** nähme, liest jene Dateien nicht — blind ist er also für **Quellen**, nicht für Ziele.
Die Zahl untertreibt sogar: sie zählt nur Report→Report-Links, während derselbe Ausschluss auch
Report→Slice-Links verstecken würde. Untertreiben ist die zulässige Richtung.

### (2) MEDIUM-1, Fundort `:377-378` — ersatzlos gestrichen, und das Kriterium trägt ohne sie

Abnahme-Kriterium 1 lautet jetzt vollständig: der Wächter *„schließt `docs/reviews/**` nicht aus"*
plus *„Bricht, wenn: ein Report, der bleibt, einen Report verlinkt, der ins Archiv geht"*. Damit
trägt es genau die zwei Teile, die die Abschnitts-Überschrift verlangt (*„je mit dem Fall, an dem
sie brechen"*), und die §Fitness Function nennt Wächter und rot färbende Mutation dazu. **Der
Wächter existiert** (Fundmenge: alle sechs namentlich genannten, keiner fehlt):

```sh
for t in TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad TestHaengerFindetVerweisAusReviewReport \
         TestUnsauberGrundZaehltUntrackte TestZuStagenNenntNurArchivStubsUndNachgezogene \
         TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach TestAusVorlageFaelltOhneVorlageAus; do
  git grep -l "func $t" -- '*_test.go'; done      # sechs Treffer, kein leerer
```

**Die Streichung hat nichts mitgerissen.** Der Word-Diff zeigt an dieser Stelle genau zwei
entfernte Zeilen und **keine** eingefügte; der Satz davor (*„… sieht es erst nach dem Commit."*)
ist unverändert und schließt den Absatz.

### (3) LOW-1 — Erschöpfungs-Zusage gestrichen, und die verbliebene Zeile trägt

Entfernt ist: *„jeder Satz dieser Datei, der eine Aussage über den heutigen Zustand von Repo, Bau
oder Werkzeug trifft, ist einzeln gegen den Baum gemessen — vier hielten nicht."* Stehen bleibt:
*„Gefegt ist die **Klasse** statt der drei Fundorte."*

**Ist die verbliebene Zeile selbst eine Zusage, die messbar sein müsste?** Sie ist eine Aussage
über den Zuschnitt des Laufs, nicht über die Vollständigkeit einer Menge — und **soweit sie doch
eine Aussage über die Menge trägt, ist sie in dieser Runde eingelöst**: Ich habe **jedes**
Kommando, das in ADR-0033 als Inline-Code neben einer Zahl steht, selbst gefahren; **alle**
liefern die geschriebene Zahl.

| Stelle | Kommando (gekürzt) | geschrieben | gemessen |
|---|---|---|---|
| `:52` | `grep -c 'span-emit\|span-report\|archive-welle' spec/architecture.md` | 0 | 0 |
| `:84` | `grep -c 'ist die Bedingung nicht eingetreten' …/close-welle.md` | 1 | 1 |
| `:86` | `grep -c 'case "archive-welle"' cmd/ai-harness-init/main.go` | 1 | 1 |
| `:102` | `grep -c 'carrierDir = ' internal/emit/enforce.go` | 1 | 1 |
| `:106` | `grep -c 'case "span-' cmd/ai-harness-init/main.go` | 2 | 2 |
| `:175` | `git grep -l 'archive-welle' e28b887e -- 'test/mutations/*.sh' \| wc -l` | 7 | 7 |
| `:180` | `grep -c 'archive-welle' test/mutations/233-…-haenger-suchraum.sh` | 0 | 0 |
| `:185` | `ls test/mutations/*archive-welle*.sh …*archiv-stub-vorlage*.sh \| wc -l` | 24 | 24 |
| `:190` | `grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` | 3 | 3 |
| `:193` | `ls /Development/d-check/tools/archive-wave/*_test.go \| wc -l` | 7 | 7 |
| `:205-206` | `TAG=$(sed …); ls ".harness/baseline/$TAG/…/archiv-stub-"*.template.md \| wc -l` | 2 | 2 |
| `:212` | der Report-Zähler oben | 122 | 122 |
| `:243` | `grep -c '^func Test' cmd/ai-harness-init/archive_welle_echt_test.go` | 3 | 3 |
| `:244` | `grep -c 't.Skip' cmd/ai-harness-init/archive_welle_echt_test.go` | 0 | 0 |
| `:323` | `grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` | 1 | 1 |
| `:360` | `ls internal/emit/templates/docs/plan/adr/` → Exit | 2 | 2 |
| `:417` | `grep -c 'baseline/v[0-9]' <adr>` | 0 | 0 |
| `:487` | `grep -c 'wachstumsSatz' internal/emit/erfassung_test.go` | 4 | 4 |
| `:490` | `grep -c 'archive' harness/tools/full-smoke.sh` | 0 | 0 |
| `:523` | `grep -rln 'archive-welle' internal/emit/ \| wc -l` | 0 | 0 |

Dazu die Zustandsaussagen **ohne** eigenes Kommando, je einzeln nachgemessen: der Shell-Helfer und
sein bats-Satz sind fort (`ls harness/tools/archive-welle.sh test/archive-welle.bats` → beide
Exit ≠ 0, Festlegung 2 eingelöst) · `ARCHIVE_IMAGE` ist fort (`grep -c 'ARCHIVE_IMAGE' Makefile`
→ **0**) · `make archive-welle` zeigt auf den Träger (`grep -n -A2 '^archive-welle:' Makefile` →
`@$(HOST_BIN) archive-welle "$(WELLE)"`) · dieser Dogfood führt **kein** `harness/mk/`
(`ls -d harness/mk` → Exit ≠ 0, wie `:311` sagt) · das Erfassungs-Fragment trägt seinen Kopf-Satz
und genau **zwei** Ziele (`grep -n 'ZWEI KOMMANDOS, KEIN GATE' internal/emit/templates/enforce/erfassung.mk`
→ 1; `grep -nE '^[a-z-]+:' …/erfassung.mk` → `span-report`, `span-clean`) · die §Fitness Function
zählt **5** eingelöste und **2** geschuldete Zeilen, wie ihr Kopf sagt (`grep -c 'Geliefert'` →
5, `grep -c 'Geschuldet, nicht geliefert'` → 2 über den Tabellenzeilen des Abschnitts) · und ihr
`sed -n 's/^# expect: //p'`-Kommando läuft und listet alle sechs oben genannten Wächter.

**Urteil zu LOW-1: behoben, und die verbliebene Zeile ist keine Über-Zusage** — sie beschreibt den
Zuschnitt eines Laufs, und die darin implizierte Deckungs-Aussage hält der Baum in dieser Runde
über **20** Kommandos plus sechs kommandolose Stellen aus. Sie zu streichen wäre falsch, nicht
sicherer: sie sagt einem späteren Lauf, dass die Klasse geprüft wurde — und das stimmt.

---

## Teil 2 — Setzt der Diff neue Fehler ein?

**Der Architect berichtet 3 neue Sätze, alle in der Geschichte-Zeile, außerhalb davon null.
Nachgeprüft: stimmt.** Der Word-Diff kennt außerhalb der §Geschichte genau eine eingefügte
Textstelle — die Umformulierung an `:211` —, und die ist ein umgeschriebener Bestandssatz, kein
neuer. Die neue §Geschichte-Zelle trägt drei Satzenden. Jede ihrer vier Behauptungen ist geprüft:

| Behauptung der neuen Zelle | Beleg dieses Laufs |
|---|---|
| Runde 4, *„Verdikt blockierender Befund"* | `grep -n 'Blockierender Befund' <report-4>` → *„Blockierender Befund: ja."* |
| MEDIUM-1 benannte Ziele, das Kommando zählt Quellen | Teil 1 (1) — beide Kommandos gefahren |
| in Abnahme-Kriterium 1 gestrichen, im Kontext umformuliert | Word-Diff, Teil 1 (1)+(2) |
| INFO-Befunde *„kein Verstoß und nicht nachgezogen"* | alle vier INFO der Runde 4 tragen *„Kein Verstoß"* bzw. *„kein Befund gegen ADR-0033"*; der Diff fasst keine ihrer Stellen an |

**Keine neue Zusage.** Die Zelle nennt **keine** Zahl — das ist die Änderung gegenüber der Zeile,
die LOW-1 traf, und sie ist konsequent durchgehalten. Der Report steht als **Kennung** in
Inline-Code, nicht als Pfad-Link (vier Treffer für ein `grep -o` auf die
backtick-umschlossene Form der Report-Dateinamen; dazu
`grep -c '](.*adr-0033-konsistenz-review' <adr>` → **0**), wie §3.11 und der eigene
Acceptance-Trigger-Abschnitt es verlangen. Die Tabellenform bleibt intakt (alle sieben Zeilen des
Abschnitts tragen 4 Pipes, also 3 Spalten).

---

## Teil 3 — Konsistenz gegen ADR-0022, ADR-0003, ADR-0007 (eigenständig gefahren)

### ADR-0022 — alle sechs Zitate verbatim, alle sechs richtig zugeordnet

Normalisiert nach [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2
(`tr -s ' \n' '  ' | sed 's/\*\*//g'`), je `grep -oF … | wc -l` → **1**:

| ADR-0033 | Zitat | Fundort in ADR-0022 |
|---|---|---|
| `:99-100` | *„Der Träger ist das ausführbare Bild … das Produkt-Binär"* | `:299`, **Festlegung 1** ✓ |
| `:104-105` | *„Schreiber und Auswertung sind Unterkommandos desselben Trägers …"* | `:386`, **Festlegung 2** ✓ |
| `:108-109` | *„Kann der Träger nicht abgelegt werden, wird weder Träger noch Wrapper noch Hook-Eintrag geschrieben …"* | `:464`, **Festlegung 5(a)** ✓ |
| `:110-111` | *„Er liegt gitignored — ein frischer Klon …"* | `:472`, **Festlegung 5(b)** ✓ |
| `:315-317` | *„Das Ziel bekommt das Kommando und den Satz, dass sein Bestand ohne dessen Aufruf unbegrenzt wächst."* | **Festlegung 6**, Stück 2 ✓ |
| `:353-354` | *„Im Ziel wird daraus ein geschriebener Satz"* | **Festlegung 6**, Stück 3 ✓ |

**Die kritische Stelle — ein Fragment, das unabhängig vom Träger entsteht, gegen 5(a) — hält.**
5(a) zählt **drei** Artefakte auf, die mit dem Träger stehen und fallen (Träger, Wrapper,
Hook-Eintrag); ein `.mk`-Fragment ist keines davon. Der gebaute Präzedenzfall sagt genau das,
und zwar im Code statt in einer Vermutung: `internal/emit/erfassung.go:16` trägt *„UNBEDINGT, und
das ist eine Entscheidung: es teilt den Zweig des Traegers NICHT"* mit derselben Drei-Artefakt-
Begründung (`sed -n '14,26p' internal/emit/erfassung.go`).

**Die Abzählungs-Zuordnung `:124` stimmt:** ADR-0022 B (*Quelle + Bauschritt zur Init-Zeit*) und C
(*Quelle mitliefern, Bau im gepinnten Image*) sind *„entsteht im Ziel"*; D (*Release-Asset über das
Netz*) und E (*OCI-Bild + `docker create`/`docker cp`*) sind *„wird geholt"*
(`awk '/^\| [B-E] — /' <adr-0022>`).

**Die Abwägungs-Analogie `:260-262` stimmt:** ADR-0022 wählte **G** (Träger *ist* das
Produkt-Binär) gegen **F** (eigenes Emitter-Binär, eingebettet — *„die kleinste
Fähigkeitsfläche"*, Contra: *„Gleiche Eigenschaften, höherer Preis"*). ADR-0033 A↔G, C↔F, gleicher
Grund. ✓ — **eine Ausnahme davon steht als LOW-1 unten.**

**Keine Festlegung von ADR-0022 wird verletzt.** Insbesondere trägt ADR-0022 **keine** Aussage,
die den Träger auf den gitignorierten Bereich beschränkte; ADR-0033 benennt die vergrößerte
Fähigkeitsfläche stattdessen zweimal ausdrücklich als Preis (`:262-266`, `:329-334`,
§Konsequenzen).

### ADR-0003 — der Verzicht ist wörtlich, und Alternative E fällt genau daran

ADR-0003 §Entscheidung, verbatim: *„Ein eigenes OCI-Image als *Vertriebsmittel* entfällt (das Tool
ruft selbst `docker` → Docker-in-Docker wäre unnötige Reibung; native Binaries sind bereits
plattformübergreifend)."* ADR-0033 `:436` verwirft E mit exakt dieser Qualifikation
(*„als Vertriebsmittel"*) — die Unterscheidung ist tragend, denn dieses Repo **fährt** gepinnte
OCI-Bilder als Gate-Werkzeuge weiter (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**). Kein
Widerspruch: ADR-0033 fügt keinen Vertriebskanal hinzu und **entfernt** einen Bild-Pin.
Alternative C (*zweites Binär*) berührt ADR-0003 an der Plattform-Matrix und benennt den Preis
(zweites Release-Artefakt je `GOOS`/`GOARCH`) — konsistent mit ADR-0003 §Entscheidung.

### ADR-0007 — beide Zuordnungen stimmen, und die Fragment-Emission ist der vorgesehene Weg

- `harness/mk/*.mk` steht in der Idempotenz-Tabelle von **Festlegung 3** unter **konvergent**
  (`docs/plan/adr/0007-bootstrap-phasen.md:100`) ✓ — ADR-0033 `:323-325`.
- `docs/plan/adr/*` steht in derselben Tabelle unter **skip-if-present** (`:101`) ✓ — ADR-0033
  `:358-359`; und dieses Repo emittiert überhaupt keine ADR
  (`ls internal/emit/templates/docs/plan/adr/` → Exit **2**).
- **Die Aufzählung in Festlegung 2 wird nicht gedehnt.** Sie nennt *„Init legt
  `harness/mk/{doc-gate,baseline,enforce}.mk`"* (`:73`), aber ihr tragender Satz ist der
  **Glob-Include** (`include harness/mk/*.mk`), ausdrücklich damit ein weiteres Fragment ein
  *„reiner Fragment-Drop"* ist statt eines In-Place-Edits. Der Emitter legt heute bereits mehr als
  drei ab (`git grep -n 'harness/mk/' -- internal/emit/*.go | grep -v _test` nennt
  `doc-gate`, `baseline`, `enforce`, `erfassung`, `arch-<modul>` sowie `<lang>`). Ein weiteres
  Fragment ist der vorgesehene Fall, keine Dehnung.
- **Der Modul-Weg (Alternative D) scheitert wirklich an ADR-0007:** dessen Festlegung 1 gibt dem
  Ziel eine sprachlose Init mit *„`make gates` ist grün auf reinen Docs"*; ein zweites `go.mod`
  samt Bauschritt im Ziel widerspräche dem. ✓
- **Und das neue Fragment gefährdet jenes Grün nicht:** es hängt nichts an `GATE_CHECKS`
  (Festlegung 4), ist konvergent und damit vom Re-Lauf byte-identisch reproduzierbar — die
  Eigenschaft, die ADR-0007s eigene Fitness-Zeile `make full-smoke` prüft.

### Der Accept-Übergang selbst — ADR-0016 Träger 3(a) ist eingelöst

Träger 3(a) verlangt: *„Bevor der Status eines ADR auf *Accepted* wechselt, werden seine
Baseline-Belege in die Form aus Festlegung 2 gebracht."* Gemessen, gegen den vendored Baum unter
dem Tag aus dem kanonischen Makefile-Pin (`v6.5.0`), Auszeichnung entfernt und Whitespace
normalisiert — **alle drei** Baseline-Zitate der Datei sind verbatim, nennen Tag, Datei und
Abschnitt, und beide Abschnitte existieren:

```sh
TAG=$(sed -n 's/^BASELINE_TAG ?= //p' Makefile)
norm() { sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g' "$1" | tr -d '`*' | tr -s ' \n' '  '; }
norm ".harness/baseline/$TAG/regelwerk/modul-06-roadmap.md" | grep -cF \
  'Ob das Archiv vollständig ist, bezeugt nur der Archivierungs-Commit'          # 1
norm ".harness/baseline/$TAG/regelwerk/modul-06-roadmap.md" | grep -cF \
  'Ziel-Form: archiv-stub-slice.template.md und archiv-stub-welle.template.md'   # 1
norm ".harness/baseline/$TAG/regelwerk/modul-08-agentenrollen.md" | grep -cF \
  'ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz'              # 1
grep -c 'baseline/v[0-9]' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md  # 0
```

---

## Findings

### LOW-1 — Die Contra-Zelle von Alternative C schreibt die Selbst-Kopie den ADR-0022-Alternativen D und E zu; dort steht sie nicht

- **kategorie:** LOW
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  §Verglichene Alternativen (D, E, F, G); [`AGENTS.md`](../../AGENTS.md) §3.4 (was ab `Accepted`
  einfriert)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:434`, dazu `:156`
- **Fundort oder Fundmenge:** **gemessene Fundmenge, und sie ist größer als der eine Fundort.**
  Die **Zuschreibung** auf D und E steht einmal (`grep -c 'Alternativen D und E' <adr>` → **1**,
  Zeile `:434`). Die **Charakterisierung** *„zweite Selbst-Kopie oder zweiter Kanal"* steht
  **zweimal** (`grep -n 'zweite Selbst-Kopie' <adr>` → `:156` und `:434`): einmal in der
  Reichweite-Spalte der Abzählungs-Tabelle, dort **ohne** die Zuschreibung, und einmal in der
  Contra-Zelle mit ihr. Ein drittes Vorkommen (`grep -c 'Selbst-Kopie' <adr>` → **3**) liegt bei
  `:87` und meint den Träger selbst — dort ist die Selbst-Kopie **richtig**, denn das ist der
  Mechanismus von ADR-0022 G. Wer `:434` anfasst, entscheidet damit auch über `:156`. Beide
  Alternativen-Stellen stammen aus der Erst-Fassung, nicht aus einer Korrekturrunde
  (`git log -S 'zweite Selbst-Kopie' --format='%h %ad' --date=short -- <adr>` → nur `e28b887e`,
  2026-09-03).
- **befund:** Die Contra-Zelle von Alternative C sagt: *„ins Ziel käme es nur über eine zweite
  **Selbst-Kopie** oder einen zweiten Kanal, also über genau die Wege, die [ADR-0022] für ihre
  Alternativen **D und E** verworfen hat."* Die Zuschreibung trägt nur für die zweite Hälfte:
  ADR-0022 D ist *„Release-Asset über das Netz holen"*, E ist *„veröffentlichtes,
  digest-gepinntes OCI-Bild + `docker create`/`docker cp`"* — beides zweite **Kanäle**, und in
  keiner der beiden Zeilen kommt das Wort Selbst-Kopie vor
  (`awk '/^\| D — /||/^\| E — /' <adr-0022> | grep -c 'Selbst-Kopie'` → **0**). Die Selbst-Kopie
  ist der Mechanismus von ADR-0022 **G**, also der **gewählten** Alternative; ein *zweites* Binär
  darüber ins Ziel zu bringen ist ADR-0022 **F** (*„eigenes Emitter-Binär, ins Produkt-Binär
  eingebettet"*) — dort verworfen, aber aus einem anderen Grund (*„einen committeten Platzhalter,
  der aussieht wie ein Träger und keiner ist"*), nicht wegen eines zweiten Kanals. ADR-0033
  **kennt** diese Zuordnung an anderer Stelle korrekt: `:260-262` verortet dieselbe Abwägung
  *„wie in ADR-0022 zwischen deren G und F"* und übernimmt sogar deren Schluss-Satz *„Gleiche
  Eigenschaften, höherer Preis"* wörtlich. Die zwei Stellen widersprechen sich nicht in der
  Sache, aber die Zelle schickt den Leser an die falsche Zeile. **Zur Behebungs-Frage:
  umformulieren, nicht streichen** — das Argument (C bezahlt die Reichweite mit einem Weg, den
  ADR-0022 bereits verworfen hat) trägt, sobald die Selbst-Kopie-Hälfte auf **F** und die
  Kanal-Hälfte auf **D und E** zeigt; ein Streichen nähme der Zelle ihren Beleg.
- **Failure-Szenario:** ADR-0033 wird `Accepted` und friert ein. Ein späterer Lauf wägt Alternative
  C neu (der fünfte Re-Evaluierungs-Trigger der Datei ruft sie ausdrücklich auf: *„Alternative C
  steht bereit"*), folgt dem Zeiger auf ADR-0022 D und E, um zu verstehen, warum der Selbst-Kopie-
  Weg ausschied — und findet dort Netz-Fetch und OCI-Copy, keinen Selbst-Kopie-Weg. Er hält
  entweder die Zuordnung für einen Fehler und misstraut den sechs übrigen ADR-0022-Verweisen, die
  alle exakt sind, oder er erfindet eine Lesart. Die Korrektur kostet nach dem Accept eine
  Folge-ADR statt einer Zeile ([`AGENTS.md`](../../AGENTS.md) §3.4).
- **verifizierbar:** ja, **nicht durch einen Gate-Lauf** — kein Modul von `docs-check` prüft, ob
  eine Prosa-Zuschreibung auf die richtige Tabellenzeile eines fremden Dokuments zeigt
  (`grep -n '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans,
  planning`; `links` prüft nur, dass die Ziel**datei** auflöst, und sie tut es). Nachrechenbar mit
  den `awk`- und `grep`-Kommandos oben.
- **klasse:** Querverweis zeigt auf die falsche Alternative des referenzierten ADR

### INFO-1 — Die Sieben aus Folgepflicht 9 hängt an einem zweiten, ungenannten Ventil; zehn weitere Zeitdokumente nennen denselben Pfad

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1; [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:492-504` (Folgepflicht 9)
- **Fundort oder Fundmenge:** **gemessene Fundmenge** —
  `git grep -l -F 'harness/tools/archive-welle.sh' -- ':!.harness/baseline' ':!*.template.md' | wc -l`
  → **14** Dateien; davon `… -- 'docs/reviews' | wc -l` → **10**, drei unter
  `docs/plan/planning/done/`, dazu `.d-check.yml` selbst.
- **befund:** Folgepflicht 9 sagt, *„drei nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefrorene
  Zeitdokumente unter `docs/plan/planning/done/` nennen ihn weiter — ohne die Zeile meldet
  `docs-check` **7** `codepath-missing` und sonst nichts"*. **Die Sieben stimmt exakt**, statisch
  nachgerechnet: die reine Inline-Code-Form kommt in genau diesen drei Dateien 3 + 3 + 1 Mal vor
  (ein `git grep -o -F` auf die backtick-umschlossene Pfad-Form, begrenzt auf `docs/plan/planning/done`
  → **7**). Sie stimmt aber **nur wegen eines zweiten Ventils, das die Folgepflicht nicht nennt**:
  `.d-check.yml` setzt `codepaths.exempt-paths: ["docs/reviews/**"]` (`:206`), und ohne diese Zeile
  kämen die **10** Review-Reports dazu, die denselben Pfad führen — allein in reiner
  Inline-Code-Form **12** weitere Vorkommen (dasselbe Kommando über `-- 'docs/reviews'`), dazu die
  `check-lines`-Formen (`…archive-welle.sh:367-380`). **Kein Verstoß:** Die Zahl ist wahr, das
  Kommando im Absatz beschreibt seinen Lauf, und ein ADR muss nicht jede Konfigurationszeile
  aufzählen, von der eine Messung abhängt. Notiert, weil der Satz *„drei Zeitdokumente nennen ihn
  weiter"* neben *„und sonst nichts"* die Lesart nahelegt, die Referenzmenge sei drei — sie ist
  vierzehn —, und weil eine spätere Änderung an `exempt-paths` die Sieben still verschiebt, während
  die Folgepflicht ab `Accepted` unerreichbar ist.
- **verifizierbar:** ja, ohne Gate — die drei `git grep`-Kommandos oben und
  `sed -n '203,207p' .d-check.yml`.
- **klasse:** Messwert hängt an einer ungenannten zweiten Konfigurations-Bedingung

### INFO-2 — Ob der Preis-Satz aus Festlegung 5 den Zweig des Trägers teilt, bleibt offen (dritte Runde, eigenständig neu hergeleitet)

- **kategorie:** INFO
- **quelle:** [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 5(a) und 7; ADR-0033 Festlegung 4 und 5
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:301-314`, `:345-350`
- **Fundort oder Fundmenge:** **Fundort, einer**; `82eb384c` fasst den Bereich nicht an
  (`git diff 5ff3f6fa..82eb384c -- <adr>` zeigt keinen Hunk zwischen `:301` und `:350`).
- **befund:** Festlegung 4 baut das Fragment *„gebaut wie das der Erfassungsschicht"*, und dessen
  Präzedenz ist im Code **unbedingt** begründet: `internal/emit/erfassung.go:16-25` sagt
  *„es teilt den Zweig des Traegers NICHT"*, weil jenes Fragment *„nichts behauptet"* — und nennt
  im selben Atemzug die Ausnahme: *„Festlegung 7 nimmt die Feldliste dazu, weil sie eine Aussage
  UEBER eine Erfassung waere, die nicht liegt."* Der Kopf-Satz, den ADR-0033 Festlegung 5 verlangt,
  ist eine Aussage darüber, *„was der abgelegte Träger kann"* (`:346-347`). In einem Ziel, dessen
  Träger-Ablage nach 5(a) scheiterte, spräche er über eine Fähigkeit, die nicht liegt — die Klasse,
  die jener Kommentar bedingt macht. **Kein Verstoß:** ADR-0022 Festlegung 7 bindet die
  **Feldliste**, nicht jede Aussage über eine abwesende Fähigkeit; die Verallgemeinerung steht
  allein im Code-Kommentar, und ein Kommentar liegt in keinem Rang der Source Precedence
  ([`AGENTS.md`](../../AGENTS.md) §3.7). ADR-0033 sagt für ihr Fragment ausdrücklich *„fehlt der
  Träger, **sagt** es das und endet erfolgreich"* (`:313`), was es in die `erfassung.mk`-Klasse
  stellt, und die Formulierung des Kopf-Satzes gehört nach Folgepflicht 7 dem Implementer. Zum
  dritten Mal notiert, weil die Datei die Frage weder stellt noch beantwortet und ab `Accepted`
  nicht mehr nachgeschärft werden kann — der Implementer bekommt sie damit ungelöst.
- **verifizierbar:** ja — `sed -n '14,26p' internal/emit/erfassung.go` und die zwei ADR-Stellen.
- **klasse:** dokumentationswürdige, undokumentierte Annahme

### INFO-3 — Der §Geschichte-Anteil steigt in der fünften Runde auf 11,6 %, während der Rumpf schrumpft

- **kategorie:** INFO
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.7 (geprüft, **nicht** verletzt —
  siehe unten); [`harness/README.md`](../../harness/README.md) §`make adr-immutable`
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:547-555`
- **Fundort oder Fundmenge:** **gemessene Fundmenge** — der Verlauf über alle fünf Fassungen der
  Datei:

  ```sh
  f=docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md
  for c in $(git log --format=%h --reverse -- "$f"); do git show "$c:$f" > /tmp/a.md
    t=$(wc -c < /tmp/a.md); g=$(awk '/^## Geschichte/{i=1} i' /tmp/a.md | wc -c)
    awk -v a=$g -v b=$t -v n=$c 'BEGIN{printf "%s gesamt=%d geschichte=%d rumpf=%d %.1f%%\n",n,b,a,b-a,100*a/b}'
  done
  # e28b887e gesamt=34642 geschichte= 872 rumpf=33770   2.5%
  # e201769d gesamt=47080 geschichte=2735 rumpf=44345   5.8%
  # f7dec1f9 gesamt=49653 geschichte=4040 rumpf=45613   8.1%
  # 3472f47a gesamt=52689 geschichte=5614 rumpf=47075  10.7%
  # 82eb384c gesamt=53091 geschichte=6154 rumpf=46937  11.6%
  ```

- **befund:** Der letzte Schritt kostet **+540** Bytes Chronik, um **−138** Bytes Rumpf zu
  streichen; über fünf Fassungen wuchs die §Geschichte um das **7,1-fache**, der Rumpf um das
  1,39-fache. Im Repo-Vergleich ist die Datei damit **Rang 8 von 40** (Schnitt **8,3 %**, Maximum
  **28,1 %** — Kommandos in [`harness/README.md`](../../harness/README.md) §`make adr-immutable`,
  hier über alle `docs/plan/adr/[0-9]*.md` gefahren): kein Ausreißer, aber die einzige Achse dieser
  Datei, die in jeder Runde monoton wächst. **Kein §3.7-Verstoß, und das ist gemessen statt
  angenommen:** §3.7 bindet *„Code, Konfiguration, Skripte und die Zustandsfelder der lebenden
  Register"*; die `## Geschichte` einer ADR ist keines von beiden, sondern der Abschnitt, in dem
  eine ADR ihre Fortschreibung führt — `.d-check.yml` nimmt ihn genau darum als
  `exclude-sections: [Geschichte]` aus dem immutablen Kern (`grep -n 'exclude-sections'
  .d-check.yml`). Notiert, weil derselbe Ausschluss die §Geschichte zur **einzigen** unbewachten
  Fläche der Datei macht: was dort nach `Accepted` falsch steht, hält kein Sensor.
- **verifizierbar:** ja, ohne Gate — die Schleife oben.
- **klasse:** Korrekturrunden-Chronik wächst schneller als der Gegenstand

### INFO-4 — Außerhalb des Prüfgegenstands: die `ignore-refs`-Zählung in AGENTS.md §3.11 steht weiter bei „Vier", das Kommando gibt 7 (unverändert aus Runde 4)

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- **pfad:** `AGENTS.md` §3.11 (**nicht** ADR-0033)
- **Fundort oder Fundmenge:** **Fundort, einer** — `grep -n 'Vier namentlich geschnittene'
  AGENTS.md` → `:440`.
- **befund:** [`AGENTS.md`](../../AGENTS.md) §3.11 begründet sich mit *„Vier namentlich
  geschnittene Referenz-Ventile stehen heute in der Gate-Config"* und stellt
  `grep -c '^  - in: ' .d-check.yml` daneben; dasselbe Kommando gibt heute **7** (selbst gefahren).
  **Kein Befund gegen ADR-0033:** jene Zählung betrifft die Paar-Form unter `links.ignore-refs`,
  Folgepflicht 9 dagegen die blanke Liste unter `codepaths.ignore-refs` — zwei Mechanismen. Runde 4
  hat das gemeldet; die neue §Geschichte-Zelle weist es korrekt als *„nicht nachgezogen"* aus, und
  das ist es auch geblieben. Erneut notiert, damit es beim Abschluss dieser Kette nicht mit ihr
  verschwindet: die Datei gehört nach [`AGENTS.md`](../../AGENTS.md) §3.8 dem **Architect**.
- **verifizierbar:** ja, ohne Gate — `grep -c '^  - in: ' .d-check.yml` → **7**.
- **klasse:** Präsens-Messwert im lebenden Norm-Artefakt

---

## Negativbefunde (geprüft, ohne Befund)

- **Die zwei Behebungen der Runde 4** — beide Fundorte von MEDIUM-1 und LOW-1 sind wie oben
  einzeln nachgemessen; keine Über-Zusage ist stehengeblieben, keine ist durch eine neue ersetzt.
- **Der Diff außerhalb der §Geschichte** — genau eine umgeschriebene Bestandszeile (`:211`) und
  zwei Streichungen; der Word-Diff kennt keine vierte Stelle. Keine neue Zusage.
- **Vollständigkeit der Streichung an `:377-378`** — Abnahme-Kriterium 1 trägt Wächter und
  Bruchfall, die Fitness-Zeile nennt den Test und die rot färbende Mutation, der Test existiert.
- **Alle 20 Inline-Kommandos der Datei** — gefahren, jedes liefert die geschriebene Zahl
  (Tabelle in Teil 1 (3)). Dazu sechs Zustandsaussagen ohne Kommando, einzeln geprüft.
- **Die drei Baseline-Zitate** — verbatim nach ADR-0016 Festlegung 2, mit Tag, Datei und
  Abschnitt; beide genannten Abschnitte existieren im vendored Baum unter `v6.5.0`.
- **Die neun referenzierten ADRs** — alle `Accepted`, keine superseded Referenz; die Datei
  referenziert damit ausschließlich normativen Bestand.
- **ADR-0016 Träger 3(a)** — eingelöst: `grep -c 'baseline/v[0-9]' <adr>` → **0**; kein Beleg der
  Datei trägt einen lokalen Baseline-Pfad mit Tag. Der Accept-Übergang ist von dieser Seite frei.
- **[`AGENTS.md`](../../AGENTS.md) §3.11 an der eigenen Datei** — alle vier Report-Verweise stehen
  als Kennung in Inline-Code, **null** als Pfad-Link
  (`grep -c '](.*adr-0033-konsistenz-review' <adr>` → **0**); ebenso die Slice-Kennungen. Die Datei
  wendet auf sich an, was sie in §Der Acceptance-Trigger verlangt.
- **[`AGENTS.md`](../../AGENTS.md) §3.5 (Gate-Lockerung ohne ADR)** — die Datei senkt keine
  Schwelle. Folgepflicht 9 **erhält** eine bestehende `ignore-refs`-Zeile, statt eine neue zu
  setzen, und begründet sie als Tombstone nach
  [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile); die
  Liste wächst nicht.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)** — die
  §Fitness Function trennt **5** eingelöste von **2** geschuldeten Zeilen und schreibt die zwei
  ausdrücklich als *„Geschuldet, nicht geliefert"* aus, mit dem Kommando, das ihre Abwesenheit
  belegt (`grep -rln 'archive-welle' internal/emit/ | wc -l` → **0**). Kein Target wird als
  laufend behauptet, das nicht läuft.
- **Der Vertrag** — `LH-FA-08` trägt genau **drei** Akzeptanzkriterien (Happy Path · Adaptierbar ·
  Kein aus dem Nichts), keines nennt ein Werkzeug hinter einem Command-Schritt
  (`sed -n '/^### LH-FA-08/,/^### LH-FA-09/p' spec/lastenheft.md`). §Was der Vertrag hier nicht tut
  hält; ein Change Request ist nicht fällig. Das Zitat aus
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (*„Erstklassig auf allen dreien
  ohne WSL2-Zwang"*) steht dort wörtlich.
- **Festlegung 3 im Ziel** — [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) führt Regelwerk
  **und** Doc-Templates als vendored Baseline des Zielrepos; die Quelle der Stub-Vorlagen existiert
  dort, Annahme (b) steht auf realem Boden.
- **Runde-4-INFO-1 (Zitat-Ausschnitt ohne Auslassungszeichen an `:108-110`)** — erneut geprüft,
  unverändert, weiter kein Verstoß: ADR-0016 Festlegung 2 definiert *verbatim* über den Wortlaut,
  und der stimmt (Teil 3, Zeile 5(a)). Nicht als eigener Befund wiederholt.
- **Runde-4-INFO-3 (ungleiche Zeitform im dreiteiligen Preis-Grund)** — erneut geprüft, unverändert:
  Preis-Grund 2 sagt *„der vierte Digest im Makefile verliert seinen Gegenstand"*, während heute
  **3** Pins stehen (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → 3, selbst gefahren) und
  `ARCHIVE_IMAGE` fort ist. **Nicht eskaliert**, und der Grund ist eigenständig geprüft, nicht
  übernommen: die Datei steht auf `Proposed` und weist sich `:393-395` selbst als Architect-Verdikt
  und Constraint des Ports aus; ihre Folgepflichten sind in derselben Zeitform geschrieben
  (Folgepflicht 4, `:472-473`). Sie in die Vergangenheitsform ihrer eigenen Umsetzung umzuschreiben
  hieße, aus der Entscheidung einen Bericht über sie zu machen.
- **Fremde Vorgänge während des Laufs** — `947ce22d` (`slice-073`, Runde-5-Report) berührt allein
  `docs/reviews/`. Er bewegt den Zähler aus `:211` um genau **1** (er verlinkt vier
  Geschwister-Reports und ist damit selbst eine Quelle); alle übrigen Messungen dieses Reports sind
  von ihm unberührt. Dieser Report selbst bleibt aus der Quellmenge heraus, weil er die
  Vorgängerinnen als Kennung führt: er trägt **kein** Link-Ziel auf einen Report —
  ein `grep -o` auf die Markdown-Link-Form eines Report-Dateinamens findet in ihm **null**
  Treffer.
- **Gate-Verifikation** — **aufgeschoben, nicht behauptet.** `make gates`, `make test`,
  `make mutate`, `make full-smoke` und `docker build` sind für diesen Lauf untersagt; der
  Auftraggeber fährt `make gates` selbst. Kein Befund und kein Negativbefund oben stützt sich auf
  einen Gate-Lauf — alle stehen auf `git`, `grep`, `sed` und `awk` über dem Arbeitsbaum. Der eine
  erlaubte `docker run` ist **nicht** verbraucht worden.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 0 | — |
| **LOW** | 1 | Querverweis zeigt auf die falsche Alternative des referenzierten ADR |
| **INFO** | 4 | Messwert hängt an einer ungenannten zweiten Konfigurations-Bedingung · dokumentationswürdige, undokumentierte Annahme · Korrekturrunden-Chronik wächst schneller als der Gegenstand · Präsens-Messwert im lebenden Norm-Artefakt (außerhalb des Gegenstands) |

**Die Klasse aus Runde 4 kehrt nicht wieder.** MEDIUM-1 war *„Zahl benennt eine andere Menge, als
ihr danebenstehendes Kommando zählt"*. Diese Runde hat **jede** Zahl der Datei gegen **beide**
Fragen gehalten — gibt das Kommando dieselbe Ziffer, **und** misst es dieselbe Größe —, und keine
zweite Instanz gefunden. Der einzige verbliebene Report-Zähler an `:211` besteht beide.

**LOW-1 ist eine neue Klasse, keine Wiederkehr.** Sie betrifft nicht eine Zahl, sondern einen
Querverweis, sie stammt aus der Erst-Fassung und ist in vier Runden nicht angefasst worden — die
Vorrunden haben ADR-0022 über seine **Festlegungen** geprüft, diese Runde zusätzlich über seine
**Alternativen-Tabelle**. Ob ein Zähler-Schritt im Beobachtungs-Register fällt, entscheidet die
Closure und nicht dieser Report.

---

## Verdikt

**Blockierender Befund: nein.**

Kein HIGH, kein MEDIUM. Der eine LOW ist eine Präzisierungs-Frage in der Contra-Zelle einer
**verworfenen** Alternative; er widerspricht keiner bindenden Festlegung von ADR-0022, ADR-0003
oder ADR-0007 und bewegt keine Festlegung, kein Abnahme-Kriterium und keine Folgepflicht dieser
Entscheidung. Nach [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage
blockieren HIGH und MEDIUM typischerweise; LOW und INFO tun es nicht, und für eine Abweichung nach
oben gibt es hier keinen Anlass.

**Die Konsistenz-Frage fällt zugunsten der ADR aus, und sie ist in dieser Runde eigenständig
gefahren.** Alle sechs zitierten Festlegungen von ADR-0022 sind verbatim und richtig zugeordnet;
die kritischste Stelle — ein Fragment, das unabhängig vom Träger entsteht, gegen Festlegung 5(a) —
ist durch die Drei-Artefakt-Aufzählung jener Festlegung und den gebauten Präzedenzfall in
`internal/emit/erfassung.go` gedeckt. ADR-0003 verzichtet auf das eigene OCI-Image als
*Vertriebsmittel*, und genau daran verwirft ADR-0033 ihre Alternative E, ohne einen neuen Kanal zu
eröffnen. ADR-0007 führt `harness/mk/*.mk` als konvergent und `docs/plan/adr/*` als
`skip-if-present`; beide Zuordnungen stimmen, und das neue Fragment ist der von Festlegung 2
ausdrücklich vorgesehene Fragment-Drop, keine Dehnung ihrer Aufzählung.

**Der Acceptance-Trigger ist damit erfüllt.** Er verlangt *„eine Reviewer-Runde … gegen ADR-0022,
ADR-0003 und ADR-0007 auf Konsistenz geprüft … und ihr Report ohne blockierenden Befund in
`docs/reviews/`"*; dieser Report ist sie, er liegt dort, und er blockiert nicht. Er ist zugleich
die **erneute Runde derselben prüfenden Rolle**, die
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach
einem blockierenden Befund fordert — gefahren in einem anderen Kontext als dem, der die Befunde
aufgelöst hat. Auch ADR-0016 Träger 3(a) steht dem Übergang nicht entgegen (gemessen, oben).

**Ein Architect-Lauf kann `Accepted` auf dieser Grundlage setzen.** Drei Dinge gehören in denselben
Lauf, keines davon in diesen Report:

1. Die Accept-Zeile der §Geschichte nennt diesen Beleg nach
   [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1
   als **Kennung**, nicht als Pfad-Link — `2026-09-10-adr-0033-konsistenz-review-runde-5.md`.
2. **LOW-1 ist vor dem Statuswechsel billig und danach teuer** ([`AGENTS.md`](../../AGENTS.md)
   §3.4): eine Zeile jetzt, eine Folge-ADR später — und wer `:434` anfasst, entscheidet zugleich
   über `:156`. Er blockiert den Übergang nicht, ist aber der letzte Moment, ihn ohne Folge-ADR zu
   erledigen. Dasselbe gilt für INFO-1 und INFO-2.
3. **Die Gate-Verifikation steht aus.** `make gates` ist in diesem Lauf nicht gefahren; das Grün
   des Baums ist keine Aussage dieses Reports.
