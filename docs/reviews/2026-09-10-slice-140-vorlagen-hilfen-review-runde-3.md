# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 3

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `f0d399e9..e0e3832d` — ein Commit, die Behebungs-Runde zu
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md). Umfang exakt zwei Dateien
  (`git show --stat e0e3832d` → `internal/emit/templates.go` 99 Zeilen,
  `internal/emit/templates_test.go` 23 Zeilen).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md)
  (`Accepted`, Slice-Kopf), [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (`Accepted`, für den `mutate`-Beleg unten).
- **Aktive `MR-*`:** [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.9, §3.10; dazu
  §5 (Traceability).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md) (3 HIGH / 1 MEDIUM / 2 LOW / 2 INFO),
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md) (0 HIGH / 2 MEDIUM / 2 LOW /
  1 INFO), sowie [2026-09-08 · slice-201](2026-09-08-slice-201-codepaths-vendored-baum-review.md)
  und [2026-09-06 · slice-190](2026-09-06-slice-190-bootstrap-orte-review.md).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen in `in-progress/`; §2 DoD, §5 und §6
  unverändert — korrekt, der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums vor und nach dem Lauf:** `git status --porcelain` leer.

**Instrumente dieses Laufs.** Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9): `make host-bin`,
`make test-go`, `make comment-claims`. Dazu **zwei reale Emit-Läufe** in frische `git init`-Repos
außerhalb des Arbeitsbaums — einer mit dem Träger aus **diesem** Stand, einer mit dem Träger aus
dem **Vor**-Stand `f0d399e9`. Jede Mutation und jede Sonde lief in einer Kopie außerhalb des
Repos.

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl unten wandert mit dem Vorlagen-Satz.

**Der geprüfte Träger ist der neue, nicht der zwischengespeicherte.** Bevor ich irgendetwas am
emittierten Baum gemessen habe, habe ich das nachgewiesen statt es aus dem Zeitstempel zu
schließen: die Format-Zeichenkette des neuen Platzhalters steht im Binär
(`grep -a -c 'QUOTE-' .harness/state/bin/ai-harness-init` → **1**, Kontext
`^@^AQUOTE-%d^A^@`), im Träger aus `f0d399e9` steht sie nicht (→ **0**). Ohne diesen Schritt hätte
ich einen 42 Minuten alten Träger vermessen und das Ergebnis dem Fix zugeschrieben.

## Sonden-Satz dieses Laufs

Sieben Eingänge durch `emit.StripCommentHints`, gefahren über `make test-go` in **zwei** Kopien
außerhalb des Repos — einmal gegen `e0e3832d`, einmal gegen `f0d399e9`. Der Vergleich ist die
Grundlage jedes Befundes unten; ohne die zweite Spalte wäre nicht zu trennen, was der Fix behoben
und was er verschoben hat.

| Sonde | Eingang (verkürzt) | `f0d399e9` (vor) | `e0e3832d` (nach) |
|---|---|---|---|
| **P1** Öffner-Zitat, fremder Mermaid-Pfeil dahinter | ``Der Oeffner `<!--` leitet ein.\n\nTRAGENDER SATZ A.\n\n```mermaid\nA --> B\n```…`` | Inhalt gelöscht | **unverändert** |
| **P2** zitierter Schließer in echtem Kommentar | ``<!-- Hinweis. Das Token `-->` steht im Text. Danach. -->…`` | Fragment blieb stehen | **korrekt entfernt** |
| **P3** unpaariger Backtick, echte Hilfe auf derselben Zeile | ``Ein einzelner Backtick ` im Text. <!-- BEDIENHINWEIS faellt weg. --> Und `Code` danach.`` | Hilfe fällt | **Hilfe überlebt** |
| **P4** mehrzeilige Zitat-Spanne | ``Ein Zitat `<!--\nzweite Zeile` und dann -->.\n\nTRAGENDER SATZ.`` | Inhalt gelöscht | **Inhalt gelöscht** |
| **P5** Zitat-Literal kommt früher als Nicht-Spanne vor | ``` `a`<!--`b` Text. Spaeter `<!--` und dann --> Ende. ``` | Inhalt gelöscht | **Inhalt gelöscht** (andere Stelle) |
| **P6** echte Hilfe (Kontrolle) | `Vorher.\n<!-- BEDIENHINWEIS faellt weg. -->\nNachher.` | fällt | fällt |
| **P7** vollständiges Zitat (Kontrolle) | ``Eine Regel steht im `<!-- -->`-Block …`` | bleibt | bleibt |

Die Ausgänge im Wortlaut, aus dem Lauf gegen `e0e3832d`:

```text
[GLEICH]     P1  AUSGANG : "Der Oeffner `<!--` leitet ein.\n\nTRAGENDER SATZ A.\n\n```mermaid\nA --> B\n```\n\nTRAGENDER SATZ B.\n"
[GLEICH]     P2  AUSGANG : "\n\n**Inhalt**\n"
[ABWEICHUNG] P3  AUSGANG : "Ein einzelner Backtick ` im Text. <!-- BEDIENHINWEIS faellt weg. --> Und `Code` danach.\n"
[ABWEICHUNG] P4  AUSGANG : "Ein Zitat `.\n\nTRAGENDER SATZ.\n"
[ABWEICHUNG] P5  AUSGANG : "`a`<!--`b` Text. Spaeter ` Ende.\n"
```

## Nachprüfung der Runde-2-Befunde

### MEDIUM-2 — die benannte Form ist behoben, die Klasse ist es nicht

**Behoben, und rot gesehen.** P1 — die wörtliche Sonde aus dem Runde-2-Report — läuft jetzt
unverändert durch; gegen den Vor-Stand löscht derselbe Eingang zwei tragende Sätze und den
Fence-Anfang. Der Zahn dazu existiert und beißt: mit der Maskierung zum No-Op gesetzt
(`spans := []string{}` in einer Kopie außerhalb des Repos) meldet `make test-go`

```text
--- FAIL: TestStripCommentHints (0.00s)
    templates_test.go:596: StripCommentHints entfernte ein Inline-Code-Zitat der Kommentar-Syntax: "eine Regel steht im ``-Block …"
    templates_test.go:601: StripCommentHints liess ein isoliertes Oeffner-Zitat bis zu einem fremden `-->` binden und loeschte Inhalt: "Der Oeffner ` B\n```\n\nTRAGENDER SATZ B.\n"
    templates_test.go:607: StripCommentHints band den echten Kommentar am zitierten Schliesser vorzeitig ab und liess ein Zeilenfragment stehen: "` steht im Text. Hinweis danach. -->\n\n**Inhalt**\n"
```

Alle drei Meldungen nennen den richtigen Grund, und die mittlere reproduziert den
Runde-2-Ausgang wörtlich. **Der gespiegelte Schließer-Fall (P2) ist echte neue Deckung**, nicht
Zierrat: gegen den Vor-Stand bleibt dort ein Zeilenfragment stehen, weil die Regex am zitierten
`-->` abbindet — `isBacktickQuoted` konnte das nicht sehen, weil der Treffer bei Index 0 beginnt
und die Ausnahme `start > 0` verlangt.

**Nicht behoben ist die Klasse.** Die Maskierung ist einzeilig
(``backtickSpanPattern = "`[^`\n]*`"``); eine Zitat-Spanne über einen Zeilenumbruch wird nicht
maskiert, und dann läuft dieselbe Regel wie zuvor bis zum nächsten echten `-->` — P4, in beiden
Ständen identisch falsch. Was der Fix geleistet hat, ist eine **Verengung** der Form, nicht das
Schließen der Klasse; der Doc-Kommentar behauptet aber das Gegenteil (HIGH-1).

### MEDIUM-1 — als Übergabe erfüllt, als DoD offen; beides richtig verteilt

Der Doc-Kommentar trägt die Aussage jetzt, und sie ist **korrekt** — ich habe das Kommando selbst
gefahren, nicht die Zeile gelesen. `make host-bin`, Emit in ein frisches Repo `$P`, dann das
§1-Kommando des Slice-Plans:

```sh
find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 \
  | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' > rest.txt
wc -l    < rest.txt        # 11
grep -c  '/\.claude/' rest.txt   # 10
grep -vc '/\.claude/' rest.txt   # 1
```

Die eine Zeile ist `.harness/skills/reviewer.md:30`, das geschonte `` `<!-- -->` ``-Zitat — genau
das, was der Kommentar nennt. **Die Klasse des Kommentars stimmt auch:** Er sagt, was ein
`<!--`-Zähler *nicht* unterscheidet, und das ist eine **Abgrenzung** nach
[`AGENTS.md`](../../AGENTS.md) §3.7, keine Chronik und keine Befund-Kennung; der Slice, die DoD und
der Review-Report werden dort nicht genannt.

**Die DoD selbst bleibt formal unerfüllt (1 statt 0), und das ist kein Befund gegen diesen
Commit.** [`AGENTS.md`](../../AGENTS.md) §3.10 verbietet der ausführenden Rolle ausdrücklich, ihr
eigenes Abnahmekriterium umzuschreiben, und verlangt statt dessen ein **Übergabe-Artefakt**. Das
liegt jetzt dreifach vor: die Commit-Message benennt die Verschiebung wörtlich, der Doc-Kommentar
trägt die Begründung, dieser Report reicht sie weiter. Was fehlt, kann nur der Planner tun. Ein
Blocker daraus wäre ein Deadlock gegen eine Rollen-Grenze, kein Qualitätsurteil.

### LOW-1, LOW-2, INFO-1 — unangetastet, wie angekündigt

Gemessen statt geglaubt:

```sh
grep -ln 'isBacktickQuoted\|dcheckIgnoreMarkerPattern\|maskQuotedCommentSyntax' test/mutations/*.sh   # leer
grep -n 'strings.Contains(m, "d-check:ignore")' internal/emit/templates_test.go                       # 685
```

LOW-1 ist damit nicht nur offen, sondern um zwei Funktionen gewachsen; LOW-2 steht unverändert.
INFO-1 ist Planner-Sache und korrekt liegen geblieben. Zur Blocker-Frage siehe §Verdikt.

## Findings (neu in dieser Runde)

### HIGH-1 — Der Doc-Kommentar sagt eine geschlossene Grenzen-Menge zu, die die Messung widerlegt

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: ein Doc-Kommentar, der ‚bei jedem
  Fehler bleibt das Ziel unverändert' zusagt, während ein `MkdirAll` davor läuft. Richtig: die
  Zusage auf das einschränken, was der Code hält."*) und §3.7 (Klasse *Grenze*);
  Reviewer-Skill-Anker *Verstoß gegen eine Hard Rule*
- **pfad:** `internal/emit/templates.go:872` (*„Eine Grenze bleibt ungedeckt"*) und `:816-820`
  (*„startet `commentHintPattern` nie innerhalb eines Zitats"*)
- **befund:** Der Kommentar führt nach dem Fix **eine** verbleibende Grenze — die
  Fence-Blindheit — und sagt für die Maskierung zu, `commentHintPattern` starte *„nie innerhalb
  eines Zitats … unabhaengig davon, welches der beiden Zeichen die Spanne traegt"*. Gemessen
  sind **drei** weitere Formen, und zwei davon verändern die Ausgabe still: eine **mehrzeilige**
  Zitat-Spanne wird von der einzeiligen Maske nicht erfasst, die Regel startet dort sehr wohl
  innerhalb des Zitats und löscht bis zum nächsten echten `-->` (P4, Ausgang
  `"Ein Zitat `.\n\nTRAGENDER SATZ.\n"` — ein Textstück und ein schließender Backtick fort);
  ein früher im Text stehendes Vorkommen desselben Zitat-**Literals** verschiebt die Maske auf
  die falsche Stelle und lässt das echte Zitat ungeschützt (P5, MEDIUM-2); und ein unpaariger
  Backtick auf der Zeile einer echten Hilfe maskiert diese mit (P3, MEDIUM-1). Die Zusage ist
  damit weiter als der Code — dieselbe Form, für die Runde 1 HIGH-2 den `make smoke`-Satz
  beanstandet hat, nur an der Grenzen-Aufzählung statt an der Deckungs-Aussage. **Der Ausfall
  ist gate-unsichtbar:** Der Kommentar sagt das über sich selbst, und ich habe es unabhängig
  nachgemessen — von den neun bats-Dateien, die den realen Vorlagen-Satz lesen
  (`grep -rln '\.harness/baseline\|BASELINE_TAG' test/*.bats | wc -l` → 9), nennt **keine** einen
  Kommentar (je Datei `grep -c '<!--\|StripComment'` → 0), und `.dockerignore` hält `.harness`
  aus dem Go-Build-Kontext (`grep -n 'harness' .dockerignore` → Zeile 5). Der nächste
  Re-Baseline tauscht genau den Satz aus, über den die Zusage spricht; wer dann den Kommentar
  liest, prüft die eine genannte Grenze und übersieht die drei ungenannten.
- **verifizierbar:** ja — `emit.StripCommentHints` mit dem P4-Eingang
  ``"Ein Zitat `<!--\nzweite Zeile` und dann -->.\n\nTRAGENDER SATZ.\n"`` über `make test-go` in
  einer Kopie außerhalb des Repos; der Ausgang ist kürzer als der Eingang.
- **klasse:** `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` (drittes Auftreten in diesem
  Slice: Runde 1 MEDIUM-1, Runde 2 MEDIUM-2, jetzt)

### MEDIUM-1 — Die Maskierung schont neuerdings eine echte Kommentar-Hilfe

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §1 (*„Kein emittiertes Dokument aus dem vendored Satz trägt noch eine
  Kommentar-Hilfe"*), [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3);
  Reviewer-Skill-Anker *fehlende Negativtests bei neuem öffentlichen Vertrag*
- **pfad:** `internal/emit/templates.go:810` (`backtickSpanPattern`) und `:821-834`
  (`maskQuotedCommentSyntax`)
- **befund:** Steht auf der Zeile einer echten Kommentar-Hilfe ein **unpaariger** Backtick,
  paart das Muster ihn mit dem nächsten Backtick derselben Zeile; die dazwischenliegende Hilfe
  liegt dann in der maskierten Spanne und überlebt den Emit. Gemessen an P3, in **beide**
  Richtungen: gegen `f0d399e9` fällt die Hilfe
  (`"Ein einzelner Backtick ` im Text.  Und `Code` danach.\n"`), gegen `e0e3832d` bleibt sie
  wörtlich stehen. Das ist keine ererbte Grenze, sondern eine **Regression** dieses Commits, und
  sie trifft die Kern-Zusage des Slice in genau der Richtung, in die kein Sensor sieht (HIGH-1).
  Ausgelöst wird sie heute nicht — im vendored wie im eigenen Vorlagen-Satz trägt **keine** Zeile
  mit ungerader Backtick-Zahl eine Kommentar-Syntax
  (`awk '{c=gsub(/`/,"`"); if (c%2==1 && ($0 ~ /<!--/ || $0 ~ /-->/)) print}'` über beide Sätze →
  leer, bei **16** Zeilen mit ungerader Backtick-Zahl im vendored Satz insgesamt). Die Bedingung
  hängt damit an einem Fremdtext, den [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  diesem Repo entzieht und der bei jedem Re-Baseline vollständig getauscht wird.
- **verifizierbar:** ja — `emit.StripCommentHints` mit dem P3-Eingang über `make test-go`; der
  Ausgang ist gleich dem Eingang, obwohl er eine Kommentar-Hilfe trägt.
- **klasse:** `Vorwaerts-Korrektur-oeffnet-die-Gegenrichtung`

### MEDIUM-2 — Maskiert wird das erste Vorkommen des Literals, nicht die gefundene Fundstelle

- **kategorie:** MEDIUM
- **quelle:** Maintainability; [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (die Ausgabe hängt an der Position eines Literals, nicht an der gemessenen Fundstelle)
- **pfad:** `internal/emit/templates.go:822` (`FindAllString`) und `:831`
  (`strings.Replace(masked, span, placeholder, 1)`)
- **befund:** `FindAllString` liefert die Spannen als **Zeichenketten**, nicht als Offsets;
  ersetzt wird anschließend das erste Vorkommen dieser Zeichenkette im Text. Beide fallen
  auseinander, sobald dasselbe Literal früher an einer Stelle steht, die das Muster **nicht** als
  Spanne geführt hat — die Backtick-Paarung ist links-greedy, und ein Schluss-Backtick der einen
  Spanne bildet mit dem Öffner der nächsten dasselbe Literal. Gemessen an P5:
  Eingang ``` `a`<!--`b` Text. Spaeter `<!--` und dann --> Ende. ```, Ausgang
  ``` `a`<!--`b` Text. Spaeter ` Ende. ``` — maskiert wurde die Stelle bei Index 2, geschützt
  werden sollte die bei Index 26; das echte Zitat blieb ungeschützt, und `` <!--` und dann --> ``
  ist fort. Ein Offset-basierter Aufbau hätte hier nichts zu entscheiden gehabt. Die Form ist
  heute in keinem der beiden Vorlagen-Sätze vorhanden, und sie ist konstruiert — tragend ist
  nicht ihre Wahrscheinlichkeit, sondern dass die Funktion eine Fundstelle ermittelt und sie dann
  nicht benutzt.
- **verifizierbar:** ja — `emit.StripCommentHints` mit dem P5-Eingang über `make test-go`; der
  Ausgang ist kürzer als der Eingang.
- **klasse:** `Ersetzung-per-Literal-statt-per-Fundstelle`

### LOW-1 — Zwei Präzisions-Zusagen im selben Doc-Block sind widerlegt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7
- **pfad:** `internal/emit/templates.go:813` (*„gleich langen Platzhalter"*) und `:861-863`
  (*„traegt genau eine Zeile ein Zitat"*)
- **befund:** Erstens: der Platzhalter ist **nicht** gleich lang. Über eine Sonde im Paket
  gemessen (Kopie außerhalb des Repos, `make test-go`):

  ```text
  Spanne "`<!-- -->`" (10 Bytes) -> Platzhalter "\x00\x01QUOTE-0\x01\x00" (11 Bytes); Laengendelta 1
  Spanne "`<!--`"     ( 6 Bytes) -> derselbe Platzhalter (11 Bytes);                  Laengendelta 5
  Spanne "`-->`"      ( 5 Bytes) -> derselbe Platzhalter (11 Bytes);                  Laengendelta 6
  ```

  Folgenlos ist das heute, weil jeder Offset in `masked` und keiner in `s` gerechnet wird —
  wer aber den Kommentar liest und aus ihm schließt, er dürfe einen Offset aus `masked` in `s`
  zurücktragen, bekommt an der zweiten Spanne einen Versatz von bis zu sechs Byte.
  Zweitens: *„Ueber dem realen vendored Satz traegt genau eine Zeile ein Zitat"* stimmt für den
  **emittierten Baum**, nicht für den vendored Satz — dort sind es **vier**, in drei Dateien
  (`grep -rn '`<!--\|`-->' .harness/baseline/v6.5.0/templates --include='*.md' | wc -l` → 4;
  je Datei `reviewer.template.md` 1, `README.md` 2, `lastenheft.template.md` 1). Die drei
  Übrigen überleben nicht, weil sie **in** Kommentarblöcken liegen, die als Ganzes fallen — ein
  Grund, den der Satz nicht nennt. Wer die Zitat-Behandlung härtet und den Satz zum Maßstab
  nimmt, sucht eine Fundstelle und findet vier.
- **verifizierbar:** ja — beide `grep`-Zeilen oben gegen den Wortlaut der zwei Kommentar-Stellen.
- **klasse:** `Zusage-nennt-eine-andere-Bezugsmenge-als-die-gemessene`

### LOW-2 — Die Commit-Message nennt keine `LH-`/`ADR-`-Kennung

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §5 (*„Requirement- und ADR-IDs in PRs/Commits
  referenzieren"*), [`harness/README.md`](../../harness/README.md) §Traceability
- **pfad:** Commit `e0e3832d` (Message), gleichlautend `7377f9ba`
- **befund:** Die Message nennt `slice-140` und den Report der Runde 2, aber weder eine `LH-*`-
  noch eine `ADR-*`-Kennung (`git show -s --format=%B e0e3832d | grep -coE 'LH-[A-Z]{2}-[0-9]{2}|ADR-[0-9]{4}'`
  → **0**; derselbe Zähler über `fdcb2762` → **1**). Der Slice-Kopf trägt die Bezüge, die
  Message erbt sie nicht, und ein Gate liest keine Commits. **Die Regel ist in ihrer
  Bezugseinheit selbst unscharf** — *„PRs/Commits"* lässt offen, ob der PR genügt —, und im
  Bestand wird sie uneinheitlich gelebt (über die letzten 40 Commits: **21** mit Kennung,
  **19** ohne; kein Erwartungswert). Runde 2 hat dieselbe Auslassung an `7377f9ba` nicht
  gemeldet; sie steht hier nicht als neuer Vorwurf, sondern damit die zwei Commits dieses Slice
  nicht als geprüft gelten, ohne es zu sein.
- **verifizierbar:** ja — das `grep -coE` oben.
- **klasse:** `Commit-Message-ohne-Traceability-Kennung`
  ([`BEO-ALL/commit-message-ohne-traceability-kennung`](../plan/planning/observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md),
  Stand `offen`)

## Negativbefunde (geprüft, ohne Befund)

- **Diff-Umfang.** `git show --stat e0e3832d` nennt genau zwei Dateien, 92 Insertions /
  30 Deletions. Nichts anderes ist hineingerutscht — kein Slice-Plan, keine `AGENTS.md`, kein
  `harness/conventions.md`, keine ADR, keine Datei unter `.harness/baseline/`, kein
  `test/mutations/`-Fall.
- **Der reale Vorlagen-Satz ist unberührt — und das ist diesmal stark belegt.** Ich habe den
  Träger aus `f0d399e9` gebaut, mit ihm in ein zweites frisches Repo emittiert und beide Bäume
  verglichen: `diff -rq --exclude=.git` meldet **genau einen** Unterschied, den mitkopierten
  Träger selbst. Alle **100** Dateien je Baum, jede `.md` darunter, sind byte-gleich. Der Fix ist
  am realen Satz verhaltensneutral; damit trägt die ausführliche Real-Satz-Prüfung der Runde 2
  (unabhängiger awk-Stripper über alle zehn Vorlagen) unverändert weiter, statt dass ich sie
  nachspiele.
- **Das geschonte Zitat ist byte-gleich zur Vorlage.**
  `diff <(grep -n 'Norm nur im Template-Kommentar' -A 3 <vorlage>) <(… <emittiert>)` weicht nur
  in der Zeilennummer ab (42 → 30, weil der Kommentarblock davor fällt); die vier Textzeilen sind
  identisch.
- **Mermaid-Pfeilbilanzen unverändert.** `spec/architecture.md`: Vorlage 5 Öffner / 14 `-->`,
  emittiert **9** Pfeile. `docs/plan/planning/in-progress/roadmap.md`: 3 / 7, emittiert **4**.
  Genau die Differenz, kein Pfeil zu viel oder zu wenig.
- **[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Emit ist
  deterministisch.** Zwei Läufe desselben Trägers in zwei frische Repos: byte-gleich. Das ist
  nicht selbstverständlich, weil `unmaskQuotedCommentSyntax` über eine Go-**Map** iteriert —
  die Ersetzungen laufen auf paarweise verschiedenen Platzhalter-Literalen, deshalb trägt die
  Reihenfolge nicht.
- **Kein Platzhalter-Zusammenstoß.** Der Platzhalter benutzt `\x00\x01`; im vendored wie im
  eigenen Vorlagen-Satz trägt keine Datei ein NUL-Byte (`grep -rlP '\x00'` über beide → leer).
- **Die zwei Ausnahmen überleben, unverändert gegenüber Runde 2.** `d-check:ignore`-Marker in
  **6** Dateien des emittierten Baums (`AGENTS.md`, `.claude/commands/implement-slice.md`, beide
  Skill-Dateien, `docs/plan/planning/README.md`, `harness/README.md`);
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)-`ANPASSEN`-Marker
  in **9** Dateien unter `.claude/`.
- **[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) /
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) —
  der vendored Baum reist unverändert mit.** `diff -rq` zwischen dem mitemittierten
  `templates`-Baum und dem des Repos: identisch.
- **Frühausstieg intakt.** Trägt ein Text nur ein Zitat und keine Hilfe, greift `locs == nil` und
  die Funktion gibt das **Original** `s` zurück, nicht den maskierten Text — P7 belegt es am
  Ausgang.
- **Gate-Stempel.** `cat .harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern denselben Wert (`bd511546…`) — der
  aufgezeichnete `make gates`-Lauf deckt den aktuellen Baum
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
  Damit sind `lint` und `docs-check` für diesen Stand belegt, ohne dass ich sie doppelt fahre.
- **`make mutate`-Beleg — er trägt, selbst nachgerechnet.** `cat .harness/state/mutate-passed.key`
  liefert `e2501f0c…`, und `isolation_key` über dem heutigen Baum liefert denselben Wert
  (`bash -c 'REPO="$PWD"; source harness/tools/mutate.sh; isolation_key'`). Nach
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist die
  Bezugsmenge die Isolationskopie ohne `.git`; der Beleg überlebt den Commit zu Recht. Die
  Fall-Zahl **278** aus der Message trägt der Beleg nicht (er speichert nur den Schlüssel), sie
  deckt sich aber mit `ls test/mutations/*.sh | wc -l` → 278. Den ~28-Minuten-Lauf habe ich
  darum nicht wiederholt. **Was der Beleg nicht sagt:** `make mutate` urteilt nur über
  *gelistete* Wächter — über `maskQuotedCommentSyntax`/`unmaskQuotedCommentSyntax` sagt sein Grün
  nichts (Runde-2-LOW-1).
- **`make comment-claims`.** Grün: `57 Datei(en) geprueft, 0 Befund(e)`. Die im neuen Kommentar
  genannten Sensoren existieren — `TestStripCommentHints` und
  `TestTemplates_KeineKommentarHilfenImEmittiertenSatz`; beide decken die zwei Ausnahmen, die der
  Kommentar ihnen zuschreibt.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Host-Toolchain-Aufruf im Diff; alle
  meine Läufe gingen über `make`-Ziele.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 / §3.10 — keine fremden Rollen-Artefakte.** Der Commit
  berührt weder Norm-Artefakte noch den Slice-Plan; §2, §5, §6 und §7 unverändert, kein
  DoD-Häkchen gesetzt, kein Register-Beleg geschrieben, kein `git mv` nach `done/`.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 — der neue Kommentar-Bestand trägt seine Klassen.** Vier
  neue Blöcke (`backtickSpanPattern`, `maskQuotedCommentSyntax`, `unmaskQuotedCommentSyntax`, der
  erweiterte `StripCommentHints`-Block) — jeder im Indikativ über den Zustand, keiner mit
  Befund-Kennung, Slice-Nummer, Runden-Verweis oder Lauf-Protokoll. Beanstandet ist oben der
  **Inhalt** zweier Zusagen, nicht ihre Form.
- **Arbeitsbaum unberührt.** `git status --porcelain` ist vor **und** nach diesem Lauf leer; jede
  Sonde und jede Mutation lief in einer Kopie außerhalb des Repos.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` |
| MEDIUM | 2 | `Vorwaerts-Korrektur-oeffnet-die-Gegenrichtung` · `Ersetzung-per-Literal-statt-per-Fundstelle` |
| LOW | 2 | `Zusage-nennt-eine-andere-Bezugsmenge-als-die-gemessene` · `Commit-Message-ohne-Traceability-Kennung` |
| INFO | 0 | — |

**Aus Runde 2 unverändert offen** (nicht neu gezählt): LOW-1 (kein `test/mutations/`-Fall für die
Ausnahmen — jetzt um `maskQuotedCommentSyntax`/`unmaskQuotedCommentSyntax` erweitert), LOW-2
(`strings.Contains` als Ausnahme-Klassifikation im Integrations-Wächter), INFO-1 (der
vorformulierte Risiko-Ausgang §6 passt nicht auf den eingetretenen Fall).

**Zwei Klassen für den Zähler — und je *ein* Beleg, nicht mehr.**
`Neue-oeffentliche-Funktion-ohne-benannte-Grenze` erreicht mit HIGH-1 das dritte Auftreten
**innerhalb** von slice-140, `Neuer-Waechter-ohne-Mutations-Fall` das vierte. Beide gehören in
die Closure — aber `modul-06-roadmap.md` §Das Beobachtungs-Register ist an dieser Stelle
eindeutig: *„Zwei Funde im selben Vorgang sind eine Gelegenheit, kein zweites Auftreten"*.
slice-140 liefert also **je einen** Beleg. Für `neuer-waechter-ohne-mutations-fall` hebt der ihn
von **2** auf 3 und damit auf die Schwelle
(`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`
→ 2, kein Erwartungswert). Für die Grenzen-Klasse führt das Register heute kein Verzeichnis; sie
anzulegen ist Closure-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10), nicht Sache dieses Reports.

## Verdikt

**Blockierender Befund: ja — ein HIGH und zwei MEDIUM.**

Was die Behebung geleistet hat, ist real und belegt: Die Runde-2-Sonde läuft unverändert durch,
der gespiegelte Schließer-Fall ist neue Deckung statt Zierrat, beide Zähne habe ich in einer
Kopie außerhalb des Repos rot gesehen, und am realen Vorlagen-Satz ist der Emit gegenüber dem
Vor-Stand **byte-gleich** — 100 Dateien, ein einziger Unterschied, und das ist der mitkopierte
Träger selbst. Auch die zweite Hälfte von MEDIUM-1 der Runde 2 ist erledigt: die Aussage über den
Messwert **1** steht jetzt am Code, ich habe das Kommando selbst gefahren und sie bestätigt, und
sie hat die richtige Kommentar-Klasse.

Blockierend ist, dass der Kommentar mehr zusagt, als der Code hält. Er führt **eine** verbleibende
Grenze; gemessen sind drei weitere, und zwei davon löschen still Text — darunter dieselbe
mehrzeilige Form, die Runde 2 als Klasse benannt hat und die der Fix nur **verengt**, nicht
geschlossen hat. Das ist keine Geschmacksfrage: Die Wirkung dieser Funktion auf den realen Satz
sieht kein Sensor — neun bats-Dateien lesen den Satz, keine nennt einen Kommentar, und der
Go-Build-Kontext schließt ihn aus. Der Kommentar **ist** hier der einzige Träger, und der nächste
Re-Baseline tauscht den Text, über den er spricht. Dazu kommen eine gemessene Regression, die eine
echte Hilfe neuerdings überleben lässt (MEDIUM-1), und eine Maskierung, die eine Fundstelle
ermittelt und dann das erste Vorkommen eines Literals ersetzt (MEDIUM-2).

**Ausdrücklich nicht blockierend**, obwohl es naheläge:

- **Die DoD-Zahl 1 statt 0.** [`AGENTS.md`](../../AGENTS.md) §3.10 reserviert das Umschreiben des
  Abnahmekriteriums dem Planner und verlangt vom ausführenden Lauf nur ein Übergabe-Artefakt.
  Das liegt vor. Darauf zu blockieren hieße, gegen eine Rollen-Grenze zu blockieren.
- **Der fehlende `test/mutations/`-Fall für Maske und Rückübersetzung.** DoD (2) verlangt *einen*
  Fall, der die Regel rot färbt; `291` und `292` leisten das und treffen die reale Verdrahtung.
  [`AGENTS.md`](../../AGENTS.md) §3.6 macht daraus keine Pflicht je Funktion, sondern stellt fest,
  wer keinen Fall hat, sei unbewacht — das ist hier zutreffend benannt und gehört als
  Steering-Loop-Eintrag in die Closure, wo die Klasse ohnehin ihre Schwelle erreicht. Ein
  Blocker daraus wäre eine Verschärfung ohne ADR ([`AGENTS.md`](../../AGENTS.md) §3.5 gilt für
  Senkungen, aber die Schwelle hier zu heben ist eine Steering-Loop-Entscheidung, keine
  Review-Entscheidung).

**Reif für den Verifier: noch nicht.** HIGH-1 liegt am einzigen Träger einer gate-unsichtbaren
Zusage; solange er weiter zusagt als der Code hält, prüfte der Verifier gegen einen Text, den die
Messung schon widerlegt hat.
