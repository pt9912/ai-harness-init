# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 6

> Dieser Report spricht über Backtick-Zitate und über HTML-Kommentar-Syntax. Jeder Sonden-Eingang
> und jeder Ausgang steht deshalb in einem Code-Block, nie in Inline-Code — sonst zerlegt die
> eigene Markdown-Syntax den Beleg.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `ce6106b4..3663888b` — ein Commit, **eine** Datei
  (`git show --pretty=format: --name-only 3663888b` → `internal/emit/templates.go`),
  33 Insertions / 21 Deletions, **ein** Hunk.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) — `Accepted`, normativ.
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) —
  **`Proposed`** (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0035-*.md`). Die Commit-Message zitiert
  den Status diesmal korrekt und ausdrücklich; INFO-1 aus Runde 5 ist damit erledigt.
- **Aktive `MR-*`:**
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.8, §3.9, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md),
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md),
  [Runde 3](2026-09-10-slice-140-vorlagen-hilfen-review-runde-3.md),
  [Runde 4](2026-09-10-slice-140-vorlagen-hilfen-review-runde-4.md),
  [Runde 5](2026-09-10-slice-140-vorlagen-hilfen-review-runde-5.md) (2 HIGH / 2 INFO).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen an seinem Lifecycle-Ort
  (`docs/plan/planning/in-progress/`); unverändert — korrekt, der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums:** `git status --porcelain` vor **und** nach diesem Lauf leer; `main` vier
Commits vor `origin/main`. Gate-Stempel und Arbeitsbaum-Hash sind deckungsgleich
(`69dd2722…`).

**Keine Erwartungswerte** — jede Zahl unten steht neben dem Kommando, das sie liefert.

## Der Prüfauftrag dieser Runde, und was er ausnimmt

Enger Umfang, drei Fragen: (1) Sind die zwei Über-Zusagen aus Runde 5 weg? (2) Hat der
Behebungs-Commit **seinerseits** eine Zusage eingesetzt, die nicht hält? (3) Ist der Diff
kommentar-only?

**Ausgenommen und hier nicht erneut geprüft:** die Heuristik-Lücken selbst (Runde-4-MEDIUM-1/-2
sind eine bestätigte Entscheidung des Auftraggebers und bleiben bewusst offen), die Frage nach
einem frischen `make mutate`-Lauf (in Runde 5 gemessen und verneint), und alles, was Runde 5
bereits als tragend bestätigt hat.

## Findings

### HIGH-1 — Die wiederhergestellte Fence-Messung entscheidet die Eigenschaft nicht, die sie belegen soll — und fällt über dem heutigen Satz ungleich aus

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 — wörtlich der dort ausgeschriebene Fehlfall
  *„Falsch: ‚Byte-Gleichheit belegt `make smoke`', ohne `smoke` gelesen zu haben. Richtig:
  benennen, was wirklich deckt — oder dass nichts deckt."*; Reviewer-Skill-Anker *Verstoß gegen
  eine Hard Rule*
- **pfad:** `internal/emit/templates.go:936-939` (der Aufzählungspunkt) und `:971-974` (der Satz,
  der ihn zum alleinigen Träger erklärt)
- **befund:** Der Aufzählungspunkt sagt *„Im heutigen Vorlagen-Satz schliesst jeder Kommentar vor
  dem naechsten Pfeil (je Vorlage gemessen per …)"* und nennt als Messung eine Gegenüberstellung
  zweier Zählungen. `:971-974` — **von diesem Commit neu eingesetzt** — erklärt genau diese
  Zählung zum einzigen Beleg der Form: *„‚Fence-Blindheit' hat KEINE eigene leer-Probe in diesem
  Block — nur die Oeffner-/Schliesser-Zaehlung im zugehoerigen Aufzaehlungspunkt oben, von Hand
  gegen die Fence-Position zu halten."* Die benannte Zählung kann die benannte Eigenschaft in
  **keiner** Richtung entscheiden, weil sie ordnungsblind ist:

  **Richtung 1 — sie schlägt heute an, obwohl nichts kaputt ist.** Als Kommando ausgeführt, je
  Datei, über beide Bäume:

  ```text
  T=.harness/baseline/v6.5.0/templates
  for f in $(find "$T" -name '*.md') $(find internal/emit/templates -type f); do
    o=$(grep -o '<!--' "$f" | wc -l); s=$(grep -o -- '-->' "$f" | wc -l)
    [ "$o" != "$s" ] && printf '%s  %s %s\n' "$f" "$o" "$s"; done
  # spec/architecture.template.md            5 14
  # docs/plan/planning/roadmap.template.md   3  7
  # 2 von 48 Dateien ungleich -- kein Erwartungswert, wandert mit dem Satz
  ```

  Ungleich, und zwar in genau den zwei Dateien, um die es geht — die Mermaid-Pfeile zählen als
  Schließer mit. Der Kommentar sagt an keiner Stelle, dass diese Ungleichheit erwartet ist; wer
  dem Zeiger folgt, liest ein Dementi der Aussage darüber.

  **Richtung 2 — sie besteht, wo die Eigenschaft bricht.** Eine Vorlage mit **gleicher**
  Öffner-/Schließer-Zahl, in der der non-greedy Abschluss trotzdem an einen Fence-Pfeil bindet:

  ```text
  # Datei: Kommentar "<!-- Hinweis" ... Fence mit "X --> Y" ... "Ende -->" ...
  #        plus ein zitierter Oeffner im Text (wie er im heutigen Satz real vorkommt)
  Oeffner: 2   Schliesser: 2   ->  GLEICH -- die benannte Pruefung besteht
  FENCE-BINDUNG: Kommentar Z3 schliesst an Pfeil IN Fence Z7
  ```

  Die Zählung gibt Entwarnung, während der Kommentar-Block als Ganzes vorzeitig geschlossen wird —
  das ist der stille Grün-Pfad, und er liegt an der Stelle, die der Kommentar selbst als einzigen
  Schutz vor Datenverlust beim Re-Baseline ausweist.

  **Die Schlussfolgerung selbst stimmt** — sie ist nur anders gemessen, als der Kommentar angibt.
  Positionell über beide Bäume:

  ```text
  # je Datei Fence-Zustand mitfuehren, Tokens in Reihenfolge lesen,
  # bei offenem Kommentar pruefen, ob der bindende Pfeil in einem Fence liegt
  Kommentare regulaer geschlossen: 105 ; vorzeitig an Fence-Pfeil gebunden: 0
  ```

  Der Emit ist heute also unbeschädigt. Beanstandet ist der Zeiger, nicht der Zustand: Der
  Kommentar ist hier der **einzige** Träger (`:988` sagt selbst, dass kein Gate die reale Wirkung
  misst), und er benennt als Deckung etwas, das nicht deckt.
- **verifizierbar:** ja — die beiden Kommandoblöcke oben; das erste liefert zwei ungleiche Paare,
  das zweite ein bestandenes Zähl-Paar auf einer Datei mit realer Fence-Bindung.
  `make comment-claims` färbt **nicht** rot und kann es nicht: er prüft, ob ein genannter Sensor
  *existiert*, nicht, ob eine genannte Messung ihre Eigenschaft trifft
  ([`harness/README.md`](../../harness/README.md) §Sensors) — der Lauf über diesem Baum meldet
  `57 Datei(en) geprueft, 0 Befund(e)`.
- **klasse:** `zusage-nennt-sensor-der-form-nicht-sieht` — das Register führt diese Klasse bereits
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  Stand `geplant`, Träger `slice-181`), Belegstand
  `ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence/*.md | wc -l`
  → **10** (kein Erwartungswert). Ihr Wortlaut trifft diesen Fall wörtlich: *„eine Zusage … nennt
  einen Sensor, der den ausgegrenzten Rest auffangen soll, und der Sensor sieht genau diese Form
  nicht."* `slice-140` führt dort noch keinen Beleg; ihn anzulegen ist Closure-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

### INFO-1 — „notwendige Bedingung" steht in Spannung zum übernächsten Satz

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `internal/emit/templates.go:977-981`
- **befund:** Neu eingesetzt ist *„sie sind eine NOTWENDIGE, keine hinreichende Bedingung dafuer,
  dass die Regel dem neuen Satz gegenueber sicher ist"*. Als logischer Term gelesen heißt
  *notwendig*: nicht leer ⇒ nicht sicher. Zwei Sätze später steht *„Ein nicht-leeres Ergebnis
  heisst nicht zwingend Datenverlust — es heisst, dass eine der oben genannten Formen jetzt
  vorkommt und von Hand geprueft werden muss."* Eine kohärente Lesart existiert (*nicht sicher* =
  *nicht als sicher erwiesen*), und die Handlungsanweisung ist in beiden Sätzen dieselbe — deshalb
  INFO und kein Befund. Die Korrektur, um die es Runde 5 ging (die Proben sind **nicht**
  hinreichend), ist damit sachlich angekommen.
- **verifizierbar:** ja — `sed -n '974,981p' internal/emit/templates.go`, die zwei Sätze
  nebeneinander gelesen.
- **klasse:** `Logischer-Term-praeziser-als-die-Aussage-dahinter`

### INFO-2 — Zwei Ungenauigkeiten in der Berichterstattung, beide ohne Wirkung auf den Baum

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** Bericht des Implementers zu `3663888b`; [Runde-5-Report](2026-09-10-slice-140-vorlagen-hilfen-review-runde-5.md) §Verdikt
- **befund:** (1) Die Angabe, `test/mutations/292-strip-comment-hints-readme-nicht-verdrahtet.sh`
  sei untracked und älter als dieser Vorgang, trifft nicht zu: die Datei ist seit `7377f9ba`
  getrackt (`git log --oneline --diff-filter=A -- test/mutations/292-*.sh`), also aus **diesem**
  Slice, und der Arbeitsbaum ist sauber. (2) Ursächlich für HIGH-1 ist eine Vorgabe **dieses
  Review-Strangs**: Runde 5 hat die Rückkehr der Fence-Messung ausdrücklich als Erledigungsweg
  benannt (*„HIGH-2 fällt, wenn die gestrichene Fence-Messung als vierte Probe zurückkehrt"*), ohne
  zu prüfen, ob diese Messung ihre Eigenschaft trifft. Der Implementer hat sie wortgleich aus
  `151e39bf` zurückgeholt — das war die verlangte Handlung. Der Befund gehört damit nicht ihm
  allein; er gehört dem Umstand, dass ein Reviewer eine Reparatur vorgeschrieben hat, deren
  Artefakt er nicht gemessen hatte.
- **verifizierbar:** ja — `git log --oneline --diff-filter=A -- test/mutations/292-*.sh` →
  `7377f9ba`; `git show 151e39bf:internal/emit/templates.go | grep -n "grep -o '<!--'"` zeigt den
  wortgleichen Vorstand.
- **klasse:** `Reparatur-Vorgabe-ohne-Messung-des-vorgeschriebenen-Artefakts`

## Negativbefunde (geprüft, ohne Befund)

- **Runde-5-HIGH-1 ist erledigt.** Der Zusatz *„und der oben genannten Beispiel-Faelle"* ist fort
  (`grep -n 'Beispiel-Faelle' internal/emit/templates.go` → keine Fundstelle). Der Satz lautet
  jetzt *„TestStripCommentHints (die pure Funktion, inklusive beider Ausnahmen)"* — und diese
  engere Zusage **hält**: beide Ausnahmen haben einen Eingang im Test, der d-check-Marker
  (`ignore := "vor <!-- d-check:ignore (Grund) --> nach"`) und die zitierte Syntax
  (`zitat`, `oeffnerZitat`, `schliesserZitat`). Beide genannten Sensoren existieren
  (`internal/emit/templates_test.go:578` und `:668`).
- **Runde-5-HIGH-2 ist in drei seiner vier Teile erledigt.** Die Proben tragen jetzt je ihren
  Formnamen (`# leer -- "Backtick-Lauf"`, `# leer -- dieselbe Form, zweiter Baum`,
  `# leer -- "zeilenuebergreifendes Zitat", nur auf Zeilen mit ungerader Backtick-Zahl`); der
  Block sagt ausdrücklich, dass für *zwei freistehende Backticks* **keine** Probe existiert; und
  die Re-Baseline-Bedingung ist von *hinreichend* auf *notwendig, nicht hinreichend*
  zurückgestutzt. Der vierte Teil — die wiederhergestellte Fence-Messung — ist HIGH-1.
- **Die drei Proben selbst gefahren — alle drei leer, wie behauptet.** Probe 1 (`$T`), Probe 2
  (`internal/emit/templates/`), Probe 3 (Paritäts-`awk` über `$T`): je **0** Zeilen.
- **Die Zusage über die Reichweite der Proben hält.** *„keine der drei folgenden Proben deckt mehr
  als eine Form"* — geprüft gegen die vier **genannten** Formen, auf die der Satz sich bezieht:
  Probe 1/2 treffen nur den Backtick-Lauf, Probe 3 nur das zeilenübergreifende Zitat; Fence-Blindheit
  und zwei freistehende Backticks fallen aus allen dreien. Ebenso hält *„die Form ist per
  Konstruktion gerade-paarig und faellt aus jeder Paritaets-Pruefung heraus"* — gemessen an einem
  Sonden-Paar: eine Zeile mit vier Backticks und echter Hilfe liefert **0** Probe-3-Treffer, dieselbe
  Zeile mit einem Backtick **1**.
- **Der Diff ist kommentar-only — mit eigenem Filter, drei unabhängige Wege.** (1) Geänderte
  Nicht-Kommentar-Zeilen:
  `git show 3663888b -- internal/emit/templates.go | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vcE '^[+-][[:space:]]*//'`
  → **0**. (2) Der Nicht-Kommentar-Rumpf beider Stände ist byte-gleich:
  `diff <(git show 3663888b^:… | grep -vE '^[[:space:]]*//') <(git show 3663888b:… | grep -vE '^[[:space:]]*//')`
  → leer, Exit 0. (3) Der Commit hat **einen** Hunk (`@@ -933,43 +933,55 @@`), verankert an
  `func unmaskQuotedCommentSyntax` und endend vor `func StripCommentHints` — also zwischen zwei
  Top-Level-Deklarationen und außerhalb jedes Literals; gelesen, nicht gefolgert.
- **Der Emit ist damit unverändert**, und die Rücknahme-Bedingung des Slice-Plans §4 (*„ein
  entfernter Kommentar hält tragenden Inhalt"*) bleibt unerfüllt — die reale Fence-Eigenschaft ist
  oben positionell mit **0** Bindungen gemessen.
- **Gate-Stempel deckt genau diesen Baum.** `cat .harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern beide `69dd2722…`
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
- **`make comment-claims` selbst gefahren:** `57 Datei(en) geprueft, 0 Befund(e)`. Kein Gegenbeleg
  zu HIGH-1, aus dem in HIGH-1 genannten Grund.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 — Form der neuen Kommentare.** Die eingefügten Zeilen
  tragen keine Befund-Kennung, keine Slice-Nummer, keinen Runden-Verweis und kein Lauf-Protokoll
  (`git show 3663888b | grep -E '^\+' | grep -inE 'Review-Befund|slice-[0-9]|Runde [0-9]|HIGH-[0-9]|rot gesehen'`
  → keine Fundstelle). Indikativ über den Zustand, Klassen *Grenze* und *Zusage*. Beanstandet ist
  oben der **Inhalt** einer Zusage, nicht ihre Form.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 eingehalten.** Der Commit berührt **eine** Datei;
  keine `AGENTS.md`, kein `harness/conventions.md`, keine ADR, kein Slice-Plan, keine
  Closure-Notiz, kein Register-Beleg, nichts unter `.harness/baseline/`.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Toolchain-Aufruf im Diff. Dieser
  Review hat `make comment-claims` gefahren; alles Übrige ist `git`, `grep`, `awk`, `find`, `sed`.
  Der Arbeitsbaum ist unberührt geblieben; die Sonden liegen im Scratchpad außerhalb des Repos.
- **[`AGENTS.md`](../../AGENTS.md) §5 — Traceability der Commit-Message.**
  `git show -s --format=%B 3663888b | grep -coE 'LH-[A-Z]{2}-[0-9]{2}|ADR-[0-9]{4}'` → **4**.
  Runde-5-INFO-1 ist erledigt: die Message nennt den `Proposed`-Status von ADR-0035 ausdrücklich
  und zitiert das Review-Verdikt als Verdikt, nicht als bindende Autorität.
- **Runde-5-INFO-2 (Probe 3 misst nur `$T`) besteht unverändert** und ist weiterhin folgenlos: der
  emittierte Satz ist auf der Paritäts-Achse ebenfalls leer. Nicht neu gezählt.

**Aus früheren Runden unverändert offen** (nicht neu gezählt): die `test/mutations/`-Lücke für
`backtickSpanPattern`, `unmaskQuotedCommentSyntax` und die Marker-Form; die
`strings.Contains`-Klassifikation im Integrations-Wächter; der vorformulierte Risiko-Ausgang §6 des
Slice-Plans (Planner-Sache); Runde-4-MEDIUM-1/-2 (bewusst offen, entschieden).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | `zusage-nennt-sensor-der-form-nicht-sieht` |
| MEDIUM | 0 | — |
| LOW | 0 | — |
| INFO | 2 | `Logischer-Term-praeziser-als-die-Aussage-dahinter` · `Reparatur-Vorgabe-ohne-Messung-des-vorgeschriebenen-Artefakts` |

**Der Zähler bekommt einen Beleg, nicht zwei.** HIGH-1 ist ein Fund in **einem** Vorgang;
`modul-06-roadmap.md` §Das Beobachtungs-Register ist eindeutig — *„Zwei Funde im selben Vorgang
sind eine Gelegenheit, kein zweites Auftreten"*. Der Beleg gehört an
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
(Stand `geplant`, Träger `slice-181`, Belegstand **10**); ihn anzulegen ist Closure-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.10).

**Sechs Runden, dieselbe Familie am selben Ort.** Modul 8 §Konflikt-Pfad macht die Sequenz ab dem
dritten gleichen Konflikttyp zur Pflicht; die Schwelle ist längst überschritten. Der eigentliche
Steering-Loop-Befund dieser Runde ist aber ein anderer und liegt bei der **Review-Rolle selbst**
(INFO-2): Eine Reparatur-Vorgabe, deren vorgeschriebenes Artefakt der Reviewer nicht gemessen hat,
verlängert die Schleife, statt sie zu schließen. Das gehört in den Lerneintrag der Closure, nicht
in diesen Report.

## Verdikt

**Blockierender Befund: ja — ein HIGH, eine reine Kommentar-Aussage.**

**Was diese Runde bestätigt.** Der Auftrag von Runde 6 ist zum größten Teil erfüllt, und zwar auf
dem verlangten Weg — **durch Streichen und Präzisieren, ohne einen einzigen neuen Testfall**. Der
Diff ist wirklich kommentar-only, auf drei unabhängigen Wegen mit eigenem Filter geprüft: null
geänderte Nicht-Kommentar-Zeilen, byte-gleicher Rumpf, ein Hunk zwischen zwei
Top-Level-Deklarationen. Der Emit ist unverändert. Runde-5-HIGH-1 ist restlos erledigt, und die an
seine Stelle getretene engere Zusage hält — beide Ausnahmen haben einen Eingang im genannten Test.
Von Runde-5-HIGH-2 sind drei der vier Teile erledigt: die Proben tragen ihre Formnamen, die fehlende
Probe ist ausdrücklich als fehlend benannt, die Re-Baseline-Bedingung ist abgeschwächt. Beide
Runde-5-INFO sind adressiert oder folgenlos. Alle drei Proben habe ich selbst gefahren; jede liefert
das behauptete Ergebnis. Die bewusst offen gelassenen Formen sind ehrlich als offen ausgewiesen.

**Warum es trotzdem blockiert.** Der vierte Teil von HIGH-2 — die Rückkehr der Fence-Messung — hat
eine Aussage in den Baum gebracht, die **messbar nicht hält**, und der Commit hat sie mit einem
neuen Satz zusätzlich zum alleinigen Träger der Form erklärt. Die benannte Zählung ist
ordnungsblind: sie fällt heute in beiden betroffenen Dateien ungleich aus (5 gegen 14, 3 gegen 7),
obwohl nichts kaputt ist, **und** sie besteht auf einer Datei, in der der Kommentar-Block real
vorzeitig schließt (2 gegen 2). Ein Re-Baseline-Leser bekommt damit entweder einen Fehlalarm oder
eine falsche Entwarnung — und der Kommentar ist an dieser Stelle der einzige Träger, wie er zwei
Absätze später selbst feststellt. Das ist wörtlich der Fehlfall, den
[`AGENTS.md`](../../AGENTS.md) §3.6 ausschreibt: eine Deckung benennen, ohne gelesen zu haben, ob
sie deckt.

**Was das ausdrücklich nicht ist.** Kein neuer Befund über die Heuristik — ich melde keinen. Keine
Forderung nach einem Testfall. Kein Zweifel am Zustand des Emits: die Eigenschaft, um die es geht,
habe ich positionell nachgemessen, sie hält heute (105 regulär geschlossene Kommentare, 0
Fence-Bindungen). Beanstandet ist ausschließlich, dass der Kommentar als Beleg ein Kommando nennt,
das diesen Beleg nicht liefert. Der Befund fällt mit Kommentar-Text — entweder durch Nennen der
Messung, die die Eigenschaft wirklich entscheidet, oder durch die ehrliche Feststellung, dass für
diese Form **keine** Messung im Block steht und die Sicherheit heute an einer von Hand geprüften
Reihenfolge hängt. Beides bleibt kommentar-only; die `make mutate`-Empfehlung aus Runde 5 bleibt
damit gültig.

**Reif für den Verifier: noch nicht — aber nach einem Kommentar-Commit ja.** Code, Gate-Lage und
Emit sind es seit Runde 4 und sind es unverändert. Offen ist eine einzige Aussage in einem
Doc-Block, der sein eigener einziger Träger ist.
