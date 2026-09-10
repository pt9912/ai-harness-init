# Review-Report — ADR-0033 auf Konsistenz gegen ADR-0022, ADR-0003, ADR-0007 (Runde 2)

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 2

**Gegenstand:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
(`Proposed`) — Konsistenz-Prüfung, **kein** Code-Diff-Review. Ausgelöst vom Acceptance-Trigger
jener Datei; sie verlangt eine Reviewer-Runde gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md). Diese Runde ist der Beleg, den
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach
einem blockierenden Befund fordert: eine **erneute** Runde derselben prüfenden Rolle, nicht die
Nachmessung des auflösenden Kontexts.

**Vorgängerin:** `2026-09-09-adr-0033-konsistenz-review.md` (Runde 1, 1 HIGH / 3 MEDIUM / 2 LOW /
2 INFO, blockierend). Sie wird hier als **Kennung** genannt und nicht als Pfad-Link: Ein
Review-Report ist eines der Zeitdokumente, die die Operation dieser Entscheidung ins Wellen-Archiv
bewegt, und dieser Report friert mit seinem Abschluss ein
([`AGENTS.md`](../../AGENTS.md) §3.11, dieselbe Form, die ADR-0033 §Der Acceptance-Trigger für ihre
eigene Accept-Zeile verlangt).

**Behebung, die geprüft wird:** `e201769d` („Rolle Architect: ADR-0033 — Review-Befunde im
Proposed-Fenster behoben"), 223 geänderte Zeilen in zwei Dateien
(`git show --stat e201769d`).

**Baum-Stand beim Lauf:** `git log --format='%h %s' -1` →
`4fea35cf Rolle Reviewer: slice-073 -- Runde 3: 1 HIGH / 2 MEDIUM / 2 INFO, blockierend`.
`git status --porcelain` ist **nicht** leer: `internal/emit/emit.go` und
`internal/emit/templates/d-check.yml` tragen die unfertige Arbeit eines **fremden** Vorgangs
(`slice-073`). Keine der beiden Dateien ist Gegenstand dieses Reviews; jede Messung unten ist
zusätzlich gegen den committeten Stand gehalten, wo sie eine der beiden berührt (namentlich
`grep -rln 'archive-welle' internal/emit/` → **0** in beiden Ständen).

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Prüfgegenstand ist eine ADR
statt eines Diffs, also treten die Datei und der Behebungs-Commit an die Stelle von Diff und
Slice-Plan. Betroffene Anforderungen: `LH-FA-08`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
Referenzierte aktive ADRs: 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040 — **alle
`Accepted`**, je Datei über `grep -m1 '^\*\*Status:\*\*'` gemessen; keine superseded Referenz.
Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3.4, §3.5, §3.6, §3.7, §3.9, §3.11. Vorherige Findings
am gleichen Gegenstand: die sechs der Runde 1, jeder unten einzeln gegen `e201769d` gehalten.

**Mess-Disziplin:** Jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein
Erwartungswert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Belege aus dem Regelwerk tragen Tag, Datei, Abschnitt und Zitat und **nicht** den
lokalen Vendoring-Präfix ([ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
Festlegung 2).

**Gate-Verifikation — aufgeschoben, mit einer Ausnahme, und der Umfang ist benannt.** Während
dieses Laufs fährt ein `make mutate`-Lauf eines fremden Vorgangs (`slice-073`); die Ziele
`gates`, `mutate`, `test`, `lint`, `build`, `smoke` und jeder `docker build` bauen dieselben
Docker-Tags wie dessen Worker und würden deren Urteil verfälschen. Sie sind deshalb **nicht**
gefahren. **Das kostet für diesen Prüfgegenstand nichts**, und das ist keine Annahme: Von den
Zielen in `make gates` hat allein `docs-check` eine Markdown-Datei in seinem Prüfbereich —
`comment-claims` bildet ihn aus vier Pfad-Mustern ohne Markdown
([`AGENTS.md`](../../AGENTS.md) §4), `test`/`lint`/`build` sind Go, `shell-lint` Shell, `ci-lint`
Workflows, `baseline-verify` der vendored Baum, `span-check` der Träger. Und `docs-check` **ist**
gefahren, in der erlaubten Form: ein einzelner `docker run` gegen den in
[`d-check.mk`](../../d-check.mk) gepinnten Digest, `--network none`, Mount `:ro`, gegen eine
`git archive HEAD`-Kopie außerhalb des Repos —

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --config /repo/.d-check.yml
# d-check: 1066 Datei(en) geprüft, 0 Befund(e)
```

**Keiner der drei Befunde unten wird von einem Gate-Lauf bestätigt**, und das steht bei jedem in
seiner `verifizierbar`-Zeile: `docs-check` prüft Adress-Auflösung, nicht Widerspruchsfreiheit.

---

## Teil 1 — Tragen die Behebungen der Runde 1?

Jeder der sechs Befunde einzeln gegen `e201769d` gehalten. **Fünf tragen, einer ist bewusst und
korrekt an eine andere Rolle abgegeben.**

| Befund Runde 1 | Ausgang | Nachmessung |
|---|---|---|
| **HIGH-1** — toter Baseline-Beleg mit lokalem Vendoring-Präfix | **behoben** | `grep -c 'baseline/v[0-9]' <adr>` → **0**. Der Beleg holt den Tag jetzt aus dem kanonischen Pin (`BASELINE_TAG ?= v6.5.0`, `grep -n '^BASELINE_TAG' Makefile`), und das zitierte Kommando läuft: `TAG=$(sed -n 's/^BASELINE_TAG ?= //p' Makefile); ls ".harness/baseline/$TAG/templates/docs/plan/planning/archiv-stub-"*.template.md \| wc -l` → **2**, wie im Text. Die zweite Hälfte trägt ebenfalls: die Selbstaussage *„Sie nennt **keine** bewegliche Pfad-Adresse"* ist heute wahr — die vier verbliebenen `.harness/`-Nennungen sind der gitignorierte Laufzeit-Ort `.harness/state/bin`, die `$TAG`-Form, die tag-lose Layout-Beschreibung `.harness/baseline/<tag>/…` und der Präfix `.harness/baseline/` als Gegenstand der Sensor-Lücke (`grep -n '\.harness/' <adr>`) |
| **MEDIUM-1** — Regelwerks-Beleg ohne Tag | **behoben** | Der Acceptance-Trigger nennt jetzt `v6.5.0`; das Zitat ist verbatim: `modul-08-agentenrollen.md` §Rollen-Regeln, **1** Treffer nach Whitespace-Normalisierung |
| **MEDIUM-2** — Festlegung 4 widerlegte eine nicht angebotene Konstruktion | **inhaltlich behoben, setzt aber HIGH-1 unten** | Die Festlegung sieht jetzt das Nicht-Gate-Fragment vor. Alle Eigenschaften, die sie dem Vorbild `harness/mk/erfassung.mk` zuschreibt, halten (Negativbefunde) — die Behebung hat jedoch zwei von vier Vorkommen ihrer eigenen Gegenaussage stehen lassen |
| **MEDIUM-3** — der Preis stand nicht im Ziel | **behoben** | Festlegung 5 ist neu und verlangt den Satz im Kopf des Fragments; das Zitat aus [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6 (*„Im Ziel wird daraus ein **geschriebener** Satz"*) ist verbatim, **1** Treffer normalisiert |
| **LOW-1** — Fitness-Tabelle sechsmal *geschuldet* | **behoben** | `grep -c '\*\*Geliefert\*\*' <adr>` → **5**, `grep -c 'Geschuldet, nicht geliefert' <adr>` → **2**; alle **6** namentlich genannten Wächter existieren (je `grep -rl "func <name>" --include='*_test.go' .` → **1**) |
| **LOW-2** — vier gewanderte Messwerte | **drei behoben, einer siehe MEDIUM-1 unten** | `grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3** ✓ · `ls /Development/d-check/tools/archive-wave/*_test.go \| wc -l` → **7** ✓ · das `for`-Kommando über `docs/reviews/` → heute **120** statt der eingetragenen 106 (INFO-1) · die Mutations-Zählung siehe MEDIUM-1 |
| **INFO-2** — verwaiste `ignore-refs`-Zeile | **korrekt abgegeben** | Die Zeile steht weiter (`grep -n 'archive-welle' .d-check.yml` → `242: - harness/tools/archive-welle.sh`, unter `codepaths:` ab Zeile 195), und die ADR führt sie als **Folgepflicht 9** an den Implementer. Die Gate-Config ist kein Architect-Artefakt ([`AGENTS.md`](../../AGENTS.md) §3.8) — die Abgabe ist die richtige Behandlung, kein Rest |

---

## Findings

### HIGH-1 — Die Behebung von MEDIUM-2 hat Festlegung 4 umgedreht und zwei von vier Vorkommen ihrer Gegenaussage stehen lassen

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (was ab `Accepted` einfriert) und §3.6 (eine
  Zusage hält, was sie sagt); ADR-0033 Festlegung 4 gegen ADR-0033 Festlegung 1 und
  §Verglichene Alternativen
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:232` und `:411`
  (gegen `:279-281` und `:456`)
- **befund:** Vor der Behebung führte die Datei den Begriff *Emissions-Schritt* an **vier**
  Stellen, und alle vier sagten dasselbe: es entsteht keiner
  (`git show e201769d^:<adr> | grep -c 'Emissions-Schritt'` → **4**). Die Behebung hat
  Festlegung 4 umgedreht — aus *„ein eigener Emissions-Schritt entsteht nicht"* wurde
  *„erreichbar wird sie über ein emittiertes Nicht-Gate-Fragment"* — und die neue
  **Folgepflicht 6** benennt diese Konstruktion selbst als *„der Emissions-Schritt aus
  Festlegung 4 wird gebaut"*. Nachgezogen wurden zwei der vier Stellen: die Kontext-Tabelle
  (Zeile 149) und der Positiv-Punkt der Konsequenzen (Zeile 422–424, der den Begriff streicht und
  stattdessen *„was sie kostet, ist ein Textfragment"* schreibt). **Zwei stehen unverändert und
  sagen jetzt das Gegenteil der Entscheidung:** Zeile 232, der dritte der *drei* tragenden
  Preis-Gründe für Alternative A — *„Die Reichweite ins Ziel kostet nichts. … ohne dass ein
  Emissions-Schritt, ein Vertriebskanal oder eine zweite Plattform-Matrix entsteht"* — und
  Zeile 411, die Pro-Zelle der gewählten Alternative — *„die Reichweite ins Ziel entsteht ohne
  Emissions-Schritt, ohne Kanal und ohne zweite Plattform-Matrix"*. Der Zähler steht nach der
  Behebung wieder bei vier (`grep -c 'Emissions-Schritt' <adr>` → **4**), aber die vier sind
  nicht mehr einer Meinung. **Keine wohlwollende Lesart trägt:** Folgepflicht 6 nennt Festlegung 4
  mit demselben Wort, das Festlegung 1 verneint — die Datei verwendet den Begriff an beiden
  Stellen für denselben Gegenstand.
- **Failure-Szenario:** ADR-0033 wird `Accepted`, §3.4 friert sie ein. Der Implementer liest
  Folgepflicht 6 und baut das Fragment. Ein späterer Lauf, der prüft, **warum** A gegenüber C, D
  und E gewählt wurde, liest in der Abwägungstabelle als Vorteil von A, dass kein Emissions-Schritt
  entsteht — und in Festlegung 1, dass die Reichweite ins Ziel nichts kostet. Er kann daraus
  entweder schließen, dass das gebaute Fragment der Entscheidung widerspricht, oder dass die
  Abwägung gegen C (ein zweites Release-Artefakt) auf einer Kostendifferenz beruhte, die es nicht
  gibt. Beides ist falsch, und die Korrektur kostet ab dem Accept eine Folge-ADR statt zweier
  Zeilen — genau der Kostensprung, den ADR-0016 Träger 3(a) und HIGH-1 der Runde 1 für die
  Adress-Form benannt haben, hier für die Aussage.
- **verifizierbar:** ja, **nicht durch einen Gate-Lauf** — `docs-check` ist über dem committeten
  Stand grün (**1066** Dateien, **0** Befunde, Kommando im Kopf), weil kein Modul zwei Aussagen
  derselben Datei gegeneinander hält. Bestätigt durch
  `grep -n 'Emissions-Schritt' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md` →
  vier Zeilen (232, 411, 456, 523), gelesen gegen
  `git show e201769d^:<adr> | grep -n 'Emissions-Schritt'` → ebenfalls vier (206, 254, 315, 328).
- **klasse:** Korrektur an einem Teil der Fundmenge, Rest widerspricht der neuen Fassung

### MEDIUM-1 — „Dieselbe Zählung trifft heute die Go-Fassung" — die Zählung trifft ihren Gegenstand nicht

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„ein ungefähr passendes Kommando danebenzustellen ist der Fehler, nicht die Lücke"*);
  ADR-0033 Bezug-Block (*„jede Zahl unten steht neben dem Kommando, das sie liefert"*)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:169-170`
  (nachrangig `:412`, dieselbe Formel in der Alternativen-Tabelle)
- **befund:** Die Behebung von LOW-2 hat der Mutations-Zahl den Satz *„**Dieselbe Zählung trifft
  heute die Go-Fassung**, die Festlegung 2 an ihre Stelle setzt"* mit
  `grep -l 'archive-welle' test/mutations/*.sh | wc -l` → **8** beigegeben. Die Zahl stimmt, die
  Aussage über sie nicht. An der genannten Mess-Basis war die Zählung mit ihrem Gegenstand
  deckungsgleich — `git grep -l 'archive-welle' e28b887e -- 'test/mutations/*.sh' | wc -l` → **7**,
  und das sind genau die sieben Shell-Fälle `225`–`231`, alle mit `archive-welle` im Namen. Heute
  ist sie es nicht mehr, in **beide** Richtungen: von den **24** Fällen, die die Datei in ihrer
  eigenen Fitness-Function-Zeile adressiert
  (`ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | wc -l`),
  trifft das Kommando **5**; und **3** seiner acht Treffer sind keine Archivierungs-Fälle, sondern
  Kopplungs-Fälle mit dem `expect:`-Satz *„jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch
  von main()"* (`256-hostbin-…`, `259-hostbin-…`, `261-dispatch-marke-nur-im-kommentar.sh`; je
  `sed -n '3p'`). Nicht getroffen wird unter anderem
  `233-archive-welle-go-haenger-suchraum.sh` — der Fall, der das **eigene Abnahme-Kriterium 1**
  dieser ADR bewacht und den ihre Fitness-Tabelle namentlich führt; er enthält die Zeichenkette
  nicht (`grep -c 'archive-welle' test/mutations/233-archive-welle-go-haenger-suchraum.sh` → **0**).
  Die Datei führt damit **zwei** Bezugsmengen für „die Mutations-Fälle dieser Operation" — 8 in
  §Was heute gemessen ist, 24 in §Fitness Function — ohne zu sagen, dass es zwei sind.
- **Failure-Szenario:** Ein Lauf, der vor der ersten realen Archivierung entscheidet, ob die
  Operation ausreichend bewacht ist, liest die einzige Abdeckungszahl der eingefrorenen
  Entscheidung: 8, gegen 7 beim Shell-Weg. Er schließt, der Port habe einen einzigen zusätzlichen
  Zahn gebracht, und schneidet einen Slice für Wächter, die es gibt — oder er verwirft die
  Zahlenprüfung ganz, weil sie ihm dreimal daneben liegt. Das ist der Schaden, den `MR-025` selbst
  als den teureren benennt: nicht die falsche Ziffer, sondern die Gewohnheit, ausgewiesene
  Messungen nicht mehr nachzuzählen.
- **verifizierbar:** ja, ohne Gate — die vier Kommandos oben (`8`, `7` an `e28b887e`, `24`, `0`).
- **klasse:** Messkommando misst nicht den Gegenstand, den sein Satz benennt

### MEDIUM-2 — Der Kontext beschreibt den abgelösten Shell-Weg an drei Stellen im Präsens als heutigen Stand

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (eine benannte Sache läuft und fährt das, was daneben steht — hier eine Ebene tiefer);
  [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:72-73`, `:147`, `:412`
- **befund:** §Was die Entscheidung auslöst sagt im Präsens: *„Zwei Antworten liegen **heute**
  nebeneinander. Dieses Repo **fährt** die Operation als **Shell-Helfer** unter
  `harness/tools/`, hinter dem Target `make archive-welle`."* Das ist heute falsch:
  `ls harness/tools/ | grep -c 'archive'` → **0**, und das Rezept lautet
  `archive-welle: host-bin` / `@$(HOST_BIN) archive-welle "$(WELLE)"`
  (`grep -n -A2 '^archive-welle:' Makefile`). Dieselbe Aussage steht zweimal weiter: die
  Ausgangs-Spalte der Kontext-Tabelle führt Alternative B als *„der heutige Stand"* (Zeile 147),
  und die Alternativen-Tabelle betitelt sie *„B — Shell-Helfer je Dogfood-Repo (Status quo)"*
  (Zeile 412). **Tragend ist nicht die MADR-Konvention, sondern die Ungleichbehandlung innerhalb
  derselben Datei:** derselbe Commit hat die Nachbarsektion ausdrücklich datiert — *„Zwei
  Mess-Stände stehen hier, und beide sind genannt … Mess-Basis `e28b887e`"* — und ihre Verben ins
  Präteritum gesetzt (*„Der Shell-Weg **war** … unbewacht"*, *„trug"*). Ein Leser kann damit nicht
  entscheiden, welche Abschnitte auf den 2026-09-03 datiert sind und welche den heutigen Baum
  behaupten; die Datei setzt an einer Stelle einen Maßstab, den sie drei Absätze weiter nicht hält.
  Die Pro-Zelle von B ist die dritte Variante: sie **weiß**, dass der Shell-Weg fort ist
  (*„und nicht mehr diese Option"*), während ihre eigene Überschrift *Status quo* sagt.
- **Failure-Szenario:** Ein Lauf sucht nach dem Accept die zweite Fassung der Operation, weil die
  eingefrorene Entscheidung sagt, zwei lägen nebeneinander, und weil Festlegung 2 den Rückbau nur
  *zusagt*. Er findet unter `harness/tools/` nichts und kann nicht unterscheiden, ob der Rückbau
  vollzogen wurde oder ob er an der falschen Stelle sucht — dieselbe Ununterscheidbarkeit, die
  HIGH-1 der Runde 1 für die tote Adresse beschrieben hat, hier für den Zustandssatz.
- **verifizierbar:** ja, ohne Gate — `docs-check` bleibt grün, weil `harness/tools/` als
  Verzeichnis existiert und `codepaths` die Existenz prüft, nicht den Satz daneben. Bestätigt durch
  die zwei Kommandos oben.
- **klasse:** Präsens-Zustandssatz im einfrierenden Artefakt, neben einer datierten Nachbarsektion

### INFO-1 — Der neu erhobene Report-Zähler ist innerhalb eines Tages weitergewandert

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:195-197`, `:356`
- **befund:** Die Behebung von LOW-2 hat die Report-Zahl von 68 auf **106** nachgezogen. Dasselbe
  Kommando gibt heute **120**
  (`for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l`),
  einen Tag später. **Kein Verstoß:** Die Datei kennzeichnet die Zahl ausdrücklich als keinen
  Erwartungswert, und das Argument, das sie trägt (*„der Suchraum ist nicht theoretisch"*), trägt
  bei 120 stärker als bei 106. Notiert, weil ein Nachziehen dieser Klasse den Zähler nur neu
  startet: die Zahl wandert mit jedem Review-Report, auch mit diesem, und die zwei Fundstellen
  nennen — anders als die zwei Punkte darüber — keine Mess-Basis, gegen die ein späterer Lauf sie
  halten könnte. Es ist die dritte Berührung derselben Klasse über beide Runden
  ([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation); ob
  daraus ein Zähler-Schritt folgt, entscheidet die Closure und nicht dieser Report.
- **verifizierbar:** ja — das Kommando oben.
- **klasse:** Präsens-Messwert im einfrierenden Artefakt

### INFO-2 — Die Gate-Zugehörigkeit bleibt unausgesprochen (unverändert aus Runde 1)

- **kategorie:** INFO
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md` (gesamte Datei)
- **befund:** Die Entscheidung sagt weiterhin an keiner Stelle, dass das autorisierte Kommando
  außerhalb von `make gates` steht
  (`grep -c 'NICHT in gates\|nicht in gates\|kein Gate' <adr>` → **0**, unverändert gegenüber
  Runde 1). **Kein Verstoß, und die Behandlung ist richtig:** Die Klassifikation ist an Rang 9
  geführt und begründet, das Rezept trägt sie im Hilfetext
  (`grep -n '^archive-welle:' Makefile` zeigt *„— NICHT in gates"*), und die ADR **behauptet** kein
  Gate. Der Architect hat den Punkt in `e201769d` ausdrücklich als nicht änderungsbedürftig
  vermerkt; das ist eine tragfähige Antwort auf einen INFO-Befund und wird hier nicht erneuert,
  sondern nur als geprüft ausgewiesen.
- **verifizierbar:** ja — die zwei `grep` oben.
- **klasse:** geerbte Klassifikation ohne eigene Aussage

---

## Negativbefunde (geprüft, ohne Befund)

- **Die eigentliche Konsistenz-Frage ist beantwortet: ADR-0033 widerspricht in ihrer heutigen
  Fassung keiner bindenden Festlegung von ADR-0022, ADR-0003 oder ADR-0007.** Alle drei Befunde
  oben sind **innere** Widersprüche und Zustandsaussagen der Datei, keine Kollisionen mit den
  Bezugs-Entscheidungen. Die Prüfung im Einzelnen steht in den vier folgenden Punkten.
- **Gegen ADR-0022 — die neue Festlegung 4 ist mit der Präzedenz vereinbar, und die kritische
  Stelle ist die unbedingte Emission.** Die naheliegende Kollision wäre ADR-0022 Festlegung 5(a)
  (*„Kann der Träger nicht abgelegt werden, wird weder Träger noch Wrapper noch Hook-Eintrag
  geschrieben"*): ein Fragment, das unabhängig vom Träger entsteht, könnte ihr widersprechen. Sie
  tut es nicht — die Aufzählung ist auf die drei Hook-Artefakte geschnitten, und der gebaute
  Präzedenzfall entscheidet dieselbe Frage bereits gleich: `internal/emit/erfassung.go` schreibt im
  Kopf *„UNBEDINGT, und das ist eine Entscheidung: es teilt den Zweig des Traegers NICHT"* und
  begründet es mit derselben 5(a). Ebenso trägt ADR-0022 Festlegung 5(c): Ein ziel-seitiger
  Anwesenheits-Wächter ist dort ausgeschlossen, und ADR-0033 Festlegung 4 schließt ihn mit
  derselben Begründung aus. Die zitierten Festlegungen 1, 2, 5(a), 5(b), 6 und 7 sind je **1×**
  wortgleich nachgewiesen (Whitespace- und Auszeichnungs-normalisiert; die Auszeichnung `**…**`
  ist in den Zitaten aufgelöst, kein Wort weicht ab).
- **Alle Eigenschaften, die Festlegung 4 dem Vorbild zuschreibt, halten am gebauten Fragment.**
  Gegen `internal/emit/templates/enforce/erfassung.mk`: der Kopf trägt *„ZWEI KOMMANDOS, KEIN
  GATE"* wörtlich (Zeile 2); nichts hängt an `GATE_CHECKS` (Zeile 4–5 sagen es aus, und die Datei
  setzt die Variable nicht); ein Kommando des Trägers wird über `make` erreichbar (`span-report`,
  Zeile 19–25), ein zweites steht daneben (`span-clean`, Zeile 36–37); und beim fehlenden Träger
  **sagt** das Ziel das in drei Zeilen und endet erfolgreich (Zeile 23–25). Die Mechanik-Aussagen
  daneben sind ebenfalls gemessen:
  `grep -c 'include harness/mk/\*\.mk' internal/emit/makefile.go` → **1**,
  `grep -c 'wachstumsSatz' internal/emit/erfassung_test.go` → **4**.
- **Gegen ADR-0007 — keine Kollision, und die zwei zitierten Zuordnungen stimmen wörtlich.**
  `harness/mk/*.mk` steht in der Idempotenz-Tabelle jener Entscheidung als **konvergent**
  (`docs/plan/adr/0007-bootstrap-phasen.md:100`), `docs/plan/adr/*` als **skip-if-present**
  (ebenda `:101`) — beides genau so, wie ADR-0033 Festlegung 4 und 5 es zitieren. Das neue
  Fragment ist reiner Text und verlangt im Ziel **keinen** Bauschritt und keine Toolchain; die
  Inversion, gegen die ADR-0007 steht, entsteht nicht. Die Ablehnung von Alternative D bleibt
  korrekte Anwendung statt Berufung.
- **Gegen ADR-0003 — keine Kollision.** Die Entscheidung wählt ein Unterkommando des nativ
  ausgelieferten Produkt-Binärs; Alternative E wird mit der Begründung verworfen, die dort steht
  (`grep -n 'Vertriebsmittel' docs/plan/adr/0003-go-native-binaries.md` → Zeile 35). Der Wegfall
  des vierten Bild-Pins arbeitet der Docker-only-Disziplin zu; keine Festlegung verlangt eine
  Host-Toolchain oder einen zweiten Vertriebskanal. Das neue Fragment ist kein Vertriebskanal,
  sondern eine Datei in einer Artefakt-Klasse, die das Ziel schon führt.
- **Kein Vertrags-Stratum berührt, auch nicht durch die neue Emissions-Pflicht.** Die
  Akzeptanzkriterien von
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) zählen die
  drei `.claude/commands/…`-Dateien auf und kein `.mk`-Fragment; das Lastenheft nennt
  `harness/mk` überhaupt nicht (`grep -n 'harness/mk' spec/lastenheft.md` leer, Exit 1), die
  Komponenten-Sicht dagegen führt den Glob-Include seit je (`spec/architecture.md:159`). Die
  Selbstaussage *„Die Aufzählung aus `LH-FA-08` wächst nicht"* hält, und ein Change Request ist
  nach [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  nicht fällig.
- **Die §Schärft-Aussage hält weiter.**
  `grep -c 'span-emit\|span-report\|archive-welle' spec/architecture.md` → **0**.
- **Die Realitätslage ist korrekt beschrieben, wo sie beschrieben wird — mit der Ausnahme in
  MEDIUM-2.** Das Werkzeug ist gebaut und ausgeliefert: der Dispatch führt den Zweig
  (`grep -n 'case "' cmd/ai-harness-init/main.go` → `span-emit`, `span-report`, `archive-welle`,
  `vendor-baseline`), der Hilfetext dokumentiert ihn (`cmd/ai-harness-init/main.go:41` und `:75`),
  und das Makefile-Ziel zeigt auf den Träger. **Die zwei `Geschuldet`-Zeilen der Fitness-Tabelle
  sind heute korrekt** und nicht überholt: `grep -rln 'archive-welle' internal/emit/ | wc -l` →
  **0** und `grep -c 'archive' harness/tools/full-smoke.sh` → **0** — die emittierte Ebene hat die
  Fähigkeit wirklich noch nicht. Die Entscheidung ist an dieser Stelle also **nicht** von der
  Wirklichkeit überholt; sie beschreibt eine offene Schuld als offen.
- **Die Fitness-Function-Tabelle behauptet keine Deckung, die es nicht gibt.** Alle sechs
  namentlich genannten Wächter existieren (je **1** Treffer), das Auflistungs-Kommando der Tabelle
  läuft und gibt **22** verschiedene `expect:`-Werte
  (`sed -n 's/^# expect: //p' test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | sort -u | wc -l`),
  und die Zeilen nennen ausschließlich existierende Targets (`make test`, `make mutate`,
  `make full-smoke`). **Was daran nicht geprüft ist:** ob die Fälle real rot färben — das ist ein
  `make mutate`-Lauf und Sache der Verifikation, nicht dieser Rolle; er ist für diesen Lauf
  ausdrücklich untersagt (Kopf).
- **Keine Referenz auf eine superseded ADR.** Alle **9** referenzierten ADRs stehen auf `Accepted`
  (je `grep -m1 '^\*\*Status:\*\*'` über 0003, 0004, 0005, 0007, 0016, 0022, 0028, 0030, 0040).
  Der ADR-Index ist derivativ nachgezogen — seine Zeile führt die zwei neu aufgenommenen 0016 und
  0040 (`grep -n '0033' docs/plan/adr/README.md`).
- **Die §Geschichte bläht sich nicht.** Ihr Anteil an der Datei liegt bei **5,8 %**
  (`t=$(wc -c < <adr>); g=$(awk '/^## Geschichte/{i=1} i' <adr> | wc -c)`), unter dem Durchschnitt
  von **8,0 %** über alle ADRs (die Schleife aus [`harness/README.md`](../../harness/README.md));
  der Eintrag zum 2026-09-09 nennt Zustand und Befund-Ausgänge, nicht die Chronik des Laufs
  ([`AGENTS.md`](../../AGENTS.md) §3.7).
- **Die Selbstaussage über bewegliche Adressen hält über beide Adress-Formen.** Jeder Inline-Pfad
  mit gate-sichtbarem Präfix existiert oder ist ein Glob (Schleife über die Inline-Code-Spannen
  der Datei, gefiltert auf den Präfix `spec/`, `docs/` oder `harness/`: `harness/README.md`,
  `harness/tools/`, `docs/reviews/`, `docs/plan/planning/` existieren; `docs/plan/adr/*`,
  `docs/reviews/**`, `harness/mk/*.mk` sind Globs), und der Lauf des Doku-Gates bestätigt es für
  die Link-Form mit **0** Befunden.
- **Der Beleg-Weg des Accept-Übergangs ist korrekt vorbereitet.** Der neue Absatz in §Der
  Acceptance-Trigger gibt [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 richtig wieder und benennt für die künftige Accept-Zeile die Kennungs-Form aus
  Festlegung 1 — mit einer Begründung aus dem eigenen Gegenstand, die trägt: Ein Review-Report ist
  eines der Zeitdokumente, die diese Operation bewegt.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Korrektur an einem Teil der Fundmenge, Rest widerspricht der neuen Fassung |
| **MEDIUM** | 2 | Messkommando misst nicht den Gegenstand, den sein Satz benennt · Präsens-Zustandssatz im einfrierenden Artefakt, neben einer datierten Nachbarsektion |
| **LOW** | 0 | — |
| **INFO** | 2 | Präsens-Messwert im einfrierenden Artefakt · geerbte Klassifikation ohne eigene Aussage |

**Eine Klasse trägt zwei der drei Befunde, und sie ist die Klasse der Behebung selbst.** HIGH-1 und
MEDIUM-2 sind derselbe Vorgang: Eine Aussage wurde an einem Fundort korrigiert und an den übrigen
stehen gelassen — beim Emissions-Schritt an zwei von vier Stellen, beim Zustand des Shell-Wegs an
einer von vier. Beide Male hat der behebende Lauf die richtige Korrektur gefunden und ihre
Fundmenge nicht gemessen. Zusammen mit INFO-1, das über beide Runden die dritte Berührung der
Messwert-Klasse ist, sind das zwei Steering-Loop-Kandidaten
([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Kontext-Eskalation); ob ein
Zähler-Schritt fällt, entscheidet die Closure und nicht dieser Report.

---

## Verdikt

**Blockierender Befund: ja.**

**Der Acceptance-Trigger ist damit nicht erfüllt.** Er verlangt einen Report *„ohne blockierenden
Befund"*; dieser trägt einen HIGH und zwei MEDIUM, und nach
[`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage blockieren beide
Kategorien typischerweise. Ein Architect-Lauf kann `Accepted` auf dieser Grundlage **nicht**
setzen.

**Was blockiert, ist nicht die Richtung der Entscheidung.** Die eigentliche Konsistenz-Frage ist
beantwortet und fällt zugunsten der ADR aus: Sie widerspricht keiner bindenden Festlegung von
ADR-0022, ADR-0003 oder ADR-0007 — auch nicht mit der neu eingesetzten Festlegung 4, deren
kritischste Stelle (ein Fragment, das unabhängig vom Träger entsteht) durch den gebauten
Präzedenzfall in `internal/emit/erfassung.go` gedeckt ist. Die drei Behebungen der Runde 1, die
inhaltlich gemessen werden konnten, tragen; die abgegebene INFO ist an der richtigen Rolle.

**Blockierend ist, was die Behebung eingesetzt hat.** HIGH-1 ist eine Regression im Wortsinn: Vor
`e201769d` war die Datei über den Emissions-Schritt mit sich einig und in einem Punkt schlecht
begründet; danach ist sie gut begründet und mit sich uneins — die Entscheidung fordert in
Festlegung 4 und Folgepflicht 6, was Festlegung 1 und die Abwägungstabelle als Vorteil der
gewählten Alternative verneinen. Genau diese Aussage trägt einen der drei Preis-Gründe, mit denen
die Datei ihre Wahl begründet, und sie steht in der Tabelle, die die Abwägung für später
festhält. MEDIUM-1 und MEDIUM-2 sind kleiner, aber von derselben Art: eine Zahl, die ihren
Gegenstand nicht mehr misst, und ein Zustandssatz, der im Präsens etwas behauptet, das der
Rückbau entfernt hat.

**Alle drei sind behebbar, solange die Datei `Proposed` steht** — und nur solange: Nach dem Accept
kostet jede von ihnen eine Folge-ADR statt weniger Zeilen
([`AGENTS.md`](../../AGENTS.md) §3.4). Lösungswege stehen bewusst nicht in den Befunden
(Skill §Anti-Pattern); die Übergabe geht an den Architect, dem die Datei gehört.

**Für den Wiedervorlage-Weg gilt weiter
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2:**
Da auch diese Runde blockiert, ist der Beleg für den Accept-Übergang eine **dritte** Runde
derselben prüfenden Rolle — nicht die Nachmessung durch den Kontext, der diese Befunde auflöst.

**Vorbehalt zur Gate-Verifikation.** Die Ziele `gates`, `mutate`, `test`, `lint`, `build` und
`smoke` sind für diesen Lauf untersagt, solange der fremde `make mutate`-Lauf läuft (Kopf). Für
den Prüfgegenstand dieses Reports ist der Vorbehalt gegenstandslos: Von den Zielen in `make gates`
erreicht allein `docs-check` eine Markdown-Datei, und der ist über dem committeten Stand gefahren
und grün (**1066** Dateien, **0** Befunde). Keiner der drei Befunde wäre von einem der übrigen
Ziele bestätigt worden; alle drei sind mit `git` und `grep` nachrechenbar, und jedes Kommando steht
neben seiner Zahl.
