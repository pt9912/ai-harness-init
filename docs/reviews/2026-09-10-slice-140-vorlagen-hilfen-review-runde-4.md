# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 4

> Dieser Report spricht über Backtick-Zitate. Jeder Sonden-Eingang und jeder Ausgang steht deshalb
> in einem Code-Block, nie in Inline-Code — sonst zerlegt die eigene Markdown-Syntax den Beleg.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `8f558ff4..151e39bf` — ein Commit. Umfang vier Dateien
  (`git show --pretty=format: --name-status 151e39bf`): `internal/emit/templates.go` und
  `internal/emit/templates_test.go` geändert, zwei Mutations-Fälle neu.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md)
  (`Accepted`, Slice-Kopf),
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (`Accepted`, für den `mutate`-Beleg unten).
- **Aktive `MR-*`:**
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.8, §3.9, §3.10;
  dazu §5 (Traceability).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md) (3 HIGH / 1 MEDIUM / 2 LOW / 2 INFO),
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md) (0 HIGH / 2 MEDIUM / 2 LOW /
  1 INFO), [Runde 3](2026-09-10-slice-140-vorlagen-hilfen-review-runde-3.md)
  (1 HIGH / 2 MEDIUM / 2 LOW).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen an seinem Lifecycle-Ort; §2 DoD, §5, §6
  und §7 unverändert — korrekt, der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums:** `git status --porcelain` vor diesem Lauf leer.

**Instrumente** ([`AGENTS.md`](../../AGENTS.md) §3.9, Docker-only): `make artifact`,
`make test-go`, `make comment-claims`, [`harness/tools/working-tree-hash.sh`](../../harness/tools/working-tree-hash.sh),
[`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) (nur `isolation_key`). Jede Sonde, jede
Mutation und jeder Emit-Lauf lief in einer Kopie **außerhalb** des Repos.

**Keine Erwartungswerte** — jede Zahl unten wandert mit dem Vorlagen-Satz und steht neben dem
Kommando, das sie liefert.

### Die Sonden sind unabhängig entworfen, nicht nachgespielt

Der Auftrag dieser Runde war ausdrücklich, die Zusage *„alle grün in einem Lauf"* nicht durch
Wiederholung der Implementer-Testdatei zu prüfen. Gefahren ist deshalb eine **eigene** Testdatei im
Paket `emit_test` (drei Sonden-Runden, 13 + 13 + 6 Eingänge), die die Ausgänge **dumpt** statt sie
gegen erwartete Konstanten zu halten — so fällt auch auf, was gar keine Erwartung hatte. Die fünf
bekannten Fälle sind aus den Reports neu formuliert, nicht aus `templates_test.go` kopiert.

**Der geprüfte Träger ist der aktuelle, nicht der zwischengespeicherte.** `make artifact` fährt
`build` **ohne** `--no-cache-filter`, und die kopierte Datei trug einen Zeitstempel *vor* dem
Commit. Statt daraus zu schließen, habe ich den Bau erzwungen
(`docker build --no-cache-filter build --target build` plus `artifact-copy.sh`) und den sha256
verglichen: `d2d6107e…` gegen `d2d6107e…`, identisch. Der Vor-Stand `8f558ff4` liefert
`9cf03136…`. Ohne diesen Schritt hätte die Byte-Gleichheit unten einen Cache-Treffer belegt.

## Sonden-Satz dieses Laufs

Zwei Spalten, wo die Frage lautet *hat der Fix etwas bewegt*: **`8f558ff4`** (Runde-3-Fassung von
`templates.go`) gegen **`151e39bf`** (dieser Stand), beide über `make test-go` in je einer Kopie
außerhalb des Repos.

### Die fünf bekannten Fälle — in **einem** Lauf, alle korrekt

````text
K1  Oeffner-Zitat, fremder Mermaid-Pfeil dahinter          (Runde 2)
    EIN  "Das Token `<!--` oeffnet einen Kommentar.\n\nTRAGENDER SATZ EINS.\n\n
          ```mermaid\nflowchart LR\n  X --> Y\n```\n\nTRAGENDER SATZ ZWEI.\n"
    AUS  unveraendert                                                          -> korrekt

K2  zitierter Schliesser in echtem mehrzeiligem Kommentar  (Runde 3)
    EIN  "# Titel\n\n<!-- Bedienhinweis.\nDas Token `-->` schliesst.\nEnde. -->\n\n**Rumpf**\n"
    AUS  "# Titel\n\n\n\n**Rumpf**\n"     Kommentar faellt vollstaendig        -> korrekt

K3  unpaariger Backtick + echte Hilfe                      (Runde 3 MEDIUM-1)
    EIN  "Ein Backtick ` steht frei. <!-- HILFE FAELLT. --> Dahinter `Code`.\n"
    AUS  "Ein Backtick ` steht frei.  Dahinter `Code`.\n"                      -> korrekt

K4/G1  mehrfaches identisches Zitat-Literal                (Runde 3 MEDIUM-2)
    EIN  "Zitat `<!--` eins. <!-- HILFE FAELLT. --> Zitat `<!--` zwei.\n"
    AUS  "Zitat `<!--` eins.  Zitat `<!--` zwei.\n"                            -> korrekt

K5  vollstaendiges Syntax-Zitat                            (Runde 1 HIGH-3)
    EIN  "eine Regel steht im `<!-- -->`-Block eines `.template.md` und nirgends sonst\n"
    AUS  unveraendert                                                          -> korrekt
````

**Die Frage nach dem mehrfachen identischen Zitat ist über fünf Stellungen gefahren**, nicht über
eine: Hilfe **zwischen** zwei identischen Zitaten (G1), Hilfe **danach** (G2), Hilfe **davor**
(G3), drei identische Zitate mit zwei Hilfen im Wechsel (G4), und ein identisches Zitat vor und
nach einer **mehrzeiligen** Hilfe (G6). Alle fünf korrekt.

**Die Offset-Ersetzung ist eine messbare Verbesserung, keine Umformulierung.** Sonde F1, beide
Spalten:

````text
EIN            "`x`-->`y` <!-- echter Kommentar mit `-->` Zitat drin. -->\n\n**Rumpf**\n"
AUS 8f558ff4   "`x`-->`y` ` Zitat drin. -->\n\n**Rumpf**\n"      <- Fragment bleibt stehen
AUS 151e39bf   "`x`-->`y` \n\n**Rumpf**\n"                       <- korrekt
````

Das Schluss-Backtick der ersten Spanne bildet mit dem Öffner der zweiten denselben Literal-String
wie das echte, später stehende Zitat. Die Literal-Ersetzung traf die frühere Stelle, die
Offset-Ersetzung trifft die ermittelte. **Runde-3 MEDIUM-2 ist damit wirklich behoben.**

### Was die eigenen Sonden zusätzlich gefunden haben

````text
F4  Doppel-Backtick-Zitat
    EIN  "Das Zitat ``<!-- -->`` steht allein im Text.\n"
    AUS  "Das Zitat ```` steht allein im Text.\n"          Zitat verstuemmelt
    in 8f558ff4 gleich

F5  Doppel-Backtick-Oeffner-Zitat
    EIN  "Das Zitat ``<!--`` steht allein.\n\nTRAGENDER SATZ.\n\nEnde -->\n"
    AUS  "Das Zitat ``\n"                                  ZWEI ABSAETZE FORT
    in 8f558ff4 gleich

F8  zwei Streu-Backticks um eine echte Hilfe
    EIN  "Ein Backtick ` frei, dann <!-- HILFE MUSS FALLEN. --> und noch ein ` frei.\n"
    AUS  unveraendert                                      Hilfe ueberlebt
    in 8f558ff4 gleich

F11 echtes Zitat auf ungerader Zeile
    EIN  "Ein Backtick ` frei, dazu `<!--` als Zitat.\n\nTRAGENDER SATZ.\n\nEnde -->\n"
    AUS  "Ein Backtick ` frei, dazu `\n"                   ZWEI ABSAETZE FORT
    in 8f558ff4 gleich

F2  Platzhalter-Bytes im Eingang
    EIN  "Vorher \x00\x01QUOTE-0\x01\x00 und `<!--` als Zitat. <!-- HILFE FAELLT. -->\n"
    AUS  "Vorher `<!--` und `<!--` als Zitat. \n"          Quelltext ueberschrieben
    in 8f558ff4 gleich

F7  Kommentar ueber einen Fence mit Pfeil       -> benannte Grenze 1, Wirkung bestaetigt
    EIN  "<!-- Hilfe faellt\n```mermaid\nA --> B\n```\nnoch Hilfe -->\n\n**Rumpf**\n"
    AUS  " B\n```\nnoch Hilfe -->\n\n**Rumpf**\n"

F3  Dreifach-Backtick-Zitat                     -> zufaellig gedeckt, unveraendert
F9  vier Streu-Backticks um eine Hilfe          -> Hilfe faellt, korrekt
F10 drei Streu-Backticks um eine Hilfe          -> Hilfe faellt, korrekt
````

**Keine dieser Formen ist eine Regression dieses Commits** — Vor- und Nach-Stand verhalten sich
identisch. Sie waren vorher da und sind in drei Runden nicht gefunden worden; gefunden hat sie diese
Runde, weil die Sonden vom Vertrag her entworfen wurden und nicht von der Fall-Liste des
Implementers.

## Nachprüfung der Runde-3-Befunde

### HIGH-1 (Grenzen-Menge) — die Zahlen-Hälfte ist behoben, die Zusagen-Hälfte nicht

Die Fundstellen-Zahl im Kommentar stimmt jetzt, selbst nachgemessen:

```sh
T=.harness/baseline/v6.5.0/templates
grep -rn -e '`<!--' -e '`-->' "$T" --include='*.md' | wc -l               # 4
grep -rn -e '`<!--' -e '`-->' "$T" --include='*.md' | sed 's/:.*//' | sort -u | wc -l   # 3
```

Drei Dateien, vier Zeilen — `README.md` zweimal, `spec/lastenheft.template.md` und
`.harness/skills/reviewer.template.md` je einmal, genau wie der Kommentar sagt. Über dem
**emittierten** Baum ist es eine (Negativbefunde). Die Klasse des Kommentars ist eine **Grenze**
nach [`AGENTS.md`](../../AGENTS.md) §3.7 — kein Lauf-Protokoll, keine Befund-Kennung, keine
Slice-Nummer. **Nicht behoben ist die Zusagen-Hälfte** — sie ist neu formuliert und wieder zu weit
(HIGH-1 unten).

### MEDIUM-1 (Maskierung schont echte Hilfe) — die benannte Form ist behoben, die Klasse nicht

K3 belegt die Behebung. F8 belegt, dass die Klasse offen ist — dieselbe Wirkung mit **zwei** statt
**einem** Streu-Backtick, in Vor- und Nach-Stand identisch. Siehe MEDIUM-2 unten.

### MEDIUM-2 (Ersetzung per Literal) — behoben, mit Verhaltens-Beleg in beide Richtungen

F1 oben, dazu G1–G4 und G6. Der Zahn dazu ist `294`, und ich habe ihn rot gesehen.

### LOW-1 (zwei Präzisions-Zusagen) — beide Hälften behoben

`grep -n 'gleich lang' internal/emit/templates.go` → leer; die Zusage ist durch *„die (im
Allgemeinen andere) Platzhalter-Laenge"* ersetzt. Die Bezugsmengen-Hälfte ist oben nachgemessen.

### LOW-2 (Commit-Message ohne Kennung) — behoben

`git show -s --format=%B 151e39bf | grep -coE 'LH-[A-Z]{2}-[0-9]{2}|ADR-[0-9]{4}'` → **3**.

## Findings (neu in dieser Runde)

### HIGH-1 — Zwei Zusagen im Doc-Kommentar sind durch Gegenbeispiele widerlegt, und die Grenzen-Menge ist erneut als geschlossen erklärt

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Richtig: die Zusage auf das einschränken, was
  der Code hält"*) und §3.7 (Klasse *Grenze*); Reviewer-Skill-Anker *Verstoß gegen eine Hard Rule*
- **pfad:** `internal/emit/templates.go:817`, `:826`, `:910`
- **befund:** Drei Sätze, drei gemessene Gegenbeispiele. **(a)** `:817` sagt zu, das Muster starte
  *„nie innerhalb eines wohlgeformt zitierten Zeichens: weder ein vollstaendig zitierter Kommentar
  noch ein isoliertes Oeffner- oder Schliesser-Zitat kann die Regex zum naechsten echten
  Gegenstueck ausserhalb des Zitats weiterlaufen lassen"*. Sonde F5 erfüllt die
  Wohlgeformtheits-Bedingung, die derselbe Kommentar `:823-826` operativ definiert (gerade
  Backtick-Zahl — die Zeile trägt vier), ist ein isoliertes Öffner-Zitat, und die Regel läuft
  trotzdem bis zum nächsten echten Schließer außerhalb des Zitats und löscht zwei tragende Absätze;
  F4 tut dasselbe für den vollständig zitierten Kommentar. **(b)** `:826` sagt, bei gerader Zahl
  sei *„die von backtickSpanPattern ermittelte Paarung … die einzig moegliche"*; in F4 sind zwei
  Paarungen möglich, und das Muster wählt eine andere als Markdown. **(c)** `:910` erklärt *„Zwei
  Grenzen bleiben ungedeckt, beide benannt statt stillschweigend bestehend"*; gemessen sind drei
  weitere Formen (F4/F5, F8, F2), von denen zwei still Text löschen und eine still eine Hilfe
  durchlässt — keine davon ist Fence-Blindheit (Grenze 1) oder eine zeilenübergreifende Spanne
  (Grenze 2). **Der Ausfall ist gate-unsichtbar**: kein Gate misst die Wirkung dieser Funktion auf
  den realen Satz — der Kommentar stellt das `:935-943` selbst fest, und ich habe es unabhängig
  bestätigt (Negativbefunde, `make smoke`). Der Kommentar ist damit der einzige Träger, und der
  nächste Re-Baseline tauscht genau den Text aus, über den er spricht.
- **verifizierbar:** ja — die zwei F5-/F4-Eingänge oben durch `emit.StripCommentHints`, gefahren
  über `make test-go` in einer Kopie außerhalb des Repos; beide Ausgänge sind kürzer als ihre
  Eingänge.
- **klasse:** `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` (**viertes** Auftreten in
  slice-140: Runde 1 MEDIUM-1, Runde 2 MEDIUM-2, Runde 3 HIGH-1, jetzt)

### MEDIUM-1 — Ein Zitat im Doppel-Backtick-Code-Span ist ungeschützt und löscht tragenden Text

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §1 (die Regel darf nichts Tragendes entfernen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3);
  Reviewer-Skill-Anker *fehlende Negativtests bei neuem öffentlichen Vertrag*
- **pfad:** `internal/emit/templates.go:810` (`backtickSpanPattern`)
- **befund:** Das Muster paart **einzelne** Backticks von links. Steht die Kommentar-Syntax
  zwischen zwei Backtick-**Läufen der Länge zwei** — der Markdown-üblichen Form, sobald der
  zitierte Text selbst einen Backtick trägt —, paart das Muster lauf-intern (zwei leere Spannen)
  statt über die Läufe hinweg; die Syntax dazwischen bleibt unmaskiert und wird als echter
  Kommentar behandelt. F4 verstümmelt das Zitat auf seine vier Backticks, F5 löscht zusätzlich zwei
  tragende Absätze. **Ein Lauf der Länge drei ist zufällig gedeckt** (F3, unverändert), einer der
  Länge zwei nicht — die Deckung hängt an der Parität der Lauf-Länge, nicht an einer Entscheidung.
  Ausgelöst wird die Form heute nicht: weder der vendored noch der eigene Vorlagen-Satz trägt eine
  Zeile mit Mehrfach-Backtick-Lauf **und** Kommentar-Syntax (Kommando in den Negativbefunden). Die
  Bedingung hängt damit an einem Fremdtext, den
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  diesem Repo entzieht und der bei jedem Re-Baseline vollständig getauscht wird.
- **verifizierbar:** ja — die F4-/F5-Eingänge über `make test-go`; beide Ausgänge sind kürzer als
  ihre Eingänge.
- **klasse:** `Zitat-Form-ausserhalb-der-erfassten-Paarung-loescht-Inhalt`

### MEDIUM-2 — Die Wohlgeformtheits-Probe deckt die Hälfte der Bedingung, die sie selbst nennt

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §2 DoD (1) (*„Kein emittiertes Dokument aus dem vendored Satz trägt noch
  eine Kommentar-Hilfe"*); [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/emit/templates.go:848` (die Paritäts-Bedingung), Begründung `:826-831`
- **befund:** Die Probe begründet sich `:828` damit, ein unpaarig stehender Backtick binde *„den
  naechsten, UNABHAENGIGEN Backtick als Schliesser und [reisse] echten Text — samt einer echten
  Kommentar-Hilfe dazwischen — in die (falsche) Spanne"*. Genau das tun **zwei** Streu-Backticks
  ebenso, und die Probe lässt sie durch, weil ihre Summe gerade ist: F8 lässt die Hilfe wörtlich
  stehen. Daraus folgt eine **Asymmetrie an derselben Struktur**: K3 (drei Backticks) und F8 (zwei
  Backticks) tragen dieselbe Hilfe innerhalb derselben Backtick-Paarung, K3 löscht sie, F8 behält
  sie — entschieden wird das von Backticks **hinter** der Hilfe, nicht von ihrem eigenen Kontext.
  Für den DoD-Zähler aus §1 zählt der stehengebliebene Öffner mit. In Vor- und Nach-Stand
  identisch: die Runde-3-Behebung hat die benannte (ungerade) Hälfte geschlossen und die gerade
  offen gelassen, ohne sie zu benennen.
- **verifizierbar:** ja — der F8-Eingang über `make test-go`; der Ausgang ist gleich dem Eingang,
  obwohl er eine Kommentar-Hilfe trägt.
- **klasse:** `Waechter-deckt-nur-die-haelfte-seiner-eigenen-Bedingung`

### LOW-1 — Die Rückübersetzung ersetzt jedes Vorkommen des Platzhalters, auch ein fremdes

- **kategorie:** LOW
- **quelle:** Maintainability; [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `internal/emit/templates.go:874`
- **befund:** Die Rückübersetzung ersetzt den Platzhalter mit `ReplaceAll` statt an den Stellen,
  die die Maskierung gesetzt hat. Trägt der Quelltext dieselbe Byte-Folge bereits, wird sie mit dem
  Inhalt einer fremden Spanne überschrieben (F2). Das ist dieselbe Klasse wie Runde-3 MEDIUM-2, eine
  Funktion weiter: eine Position wird ermittelt und dann nicht benutzt. Auslösbar ist es nur über
  ein NUL-Byte, und keiner der beiden Vorlagen-Sätze trägt eines
  (`grep -rlP '\x00' .harness/baseline/v6.5.0/templates internal/emit/templates` → leer); tragend
  ist nicht die Wahrscheinlichkeit, sondern dass die Grenze in keinem der zwei benannten Punkte
  steht.
- **verifizierbar:** ja — der F2-Eingang über `make test-go`; die vorhandene Byte-Folge im Ausgang
  ist nicht mehr dieselbe.
- **klasse:** `Rueckuebersetzung-trifft-ein-fremdes-Vorkommen`

## Negativbefunde (geprüft, ohne Befund)

- **Diff-Umfang.** Vier Dateien, 155 Insertions / 44 Deletions (`git show --stat 151e39bf`). Keine
  `AGENTS.md`, kein `harness/conventions.md`, keine ADR, kein Slice-Plan, keine Datei unter
  `.harness/baseline/`, kein Register-Beleg — [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10
  eingehalten.
- **Die fünf bekannten Fälle tragen gleichzeitig.** K1–K5 oben, in **einem** `make test-go`-Lauf,
  über neu formulierte Eingänge statt über die Fall-Liste des Implementers. Die Zusage der
  Commit-Message ist damit unabhängig bestätigt.
- **Der reale vendored Satz ist unberührt — selbst nachgebaut.** Träger aus `151e39bf` und aus
  `8f558ff4` gebaut, mit beiden in je ein frisches `git init`-Repo außerhalb des Arbeitsbaums
  emittiert: `find <baum> -type f -not -path '*/.git/*' | wc -l` → **100** je Baum;
  `diff -rq --exclude=.git <baum-pre> <baum-head>` meldet **genau einen** Unterschied, den
  mitkopierten Träger selbst. Der Fix ist am realen Satz verhaltensneutral.
- **Der geprüfte Träger ist nicht der zwischengespeicherte.** Erzwungener Neubau liefert denselben
  sha256 wie der Cache-Bau (`d2d6107e…`), der Vor-Stand einen anderen (`9cf03136…`). Nebenbei ein
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Beleg: zweimal übersetzt,
  byte-gleich.
- **[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Emit ist
  deterministisch.** Zwei Läufe desselben Trägers in zwei frische Repos: `diff -rq --exclude=.git`
  leer. Das ist nicht selbstverständlich, weil die Rückübersetzung über eine Go-**Map** iteriert;
  die Platzhalter sind paarweise verschieden, deshalb trägt die Reihenfolge nicht. Über alle 32
  Sonden-Eingänge zusätzlich geprüft: zweiter Aufruf gleich dem ersten, und die Funktion ist auf
  ihrem eigenen Ausgang idempotent.
- **Das DoD-(1)-Kommando selbst gefahren**, über den frisch emittierten Baum: `wc -l` → **11**,
  `grep -c '/\.claude/'` → **10**, `grep -vc '/\.claude/'` → **1**. Die eine Zeile ist
  `.harness/skills/reviewer.md:30`, das geschonte Syntax-Zitat — genau die Fundstelle, die der
  Doc-Kommentar nennt.
- **Die zwei Ausnahmen überleben.** `d-check:ignore` in **6** Dateien des emittierten Baums
  (`AGENTS.md`, `.claude/commands/implement-slice.md`, beide Skill-Dateien,
  `docs/plan/planning/README.md`, `harness/README.md`);
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)-`ANPASSEN`
  in **9** Dateien unter `.claude/`.
- **Die zwei benannten Grenzen sind real und richtig benannt.** Fence-Blindheit: F7 zerlegt einen
  Kommentar, der einen Mermaid-Pfeil überspannt — die Wirkung, die Grenze 1 beschreibt.
  Zeilenübergreifende Spanne: der Fall der Implementer-Testdatei reproduziert, Ausgang wie
  dokumentiert.
- **Heute löst keine der drei neuen Formen aus** — gemessen über **beide** Vorlagen-Sätze:

  ```sh
  T=.harness/baseline/v6.5.0/templates
  grep -rn '``' "$T" --include='*.md' | grep -e '<!--' -e '\-\->'   # leer
  grep -rn '``' internal/emit/templates/ | grep -e '<!--' -e '\-\->' # leer
  find "$T" -name '*.md' -print0 | xargs -0 awk \
    '{ c=gsub(/`/,"`"); if (c%2==1 && ($0 ~ /<!--/ || $0 ~ /-->/)) print FILENAME":"FNR }'   # leer
  grep -rlP '\x00' "$T" internal/emit/templates                     # leer
  ```

  Das ist eine Eigenschaft des heutigen Textes, keine des Emitters — dieselbe Lage, die der
  Kommentar für Grenze 1 selbst feststellt.
- **Beide neuen Mutations-Fälle rot gesehen**, je in einer eigenen Kopie außerhalb des Repos, und
  die Meldung passt auf die Mutation:

  ```text
  293 -> templates_test.go:623  StripCommentHints liess eine echte Kommentar-Hilfe auf einer Zeile
                                mit unpaariger Backtick-Zahl ueberleben
  294 -> templates_test.go:637  StripCommentHints maskierte eine zufaellig gleiche, fruehere
                                Zeichenkette statt der ermittelten Fundstelle
  ```

  Beide `sed`-Ausdrücke greifen real (sha256 der Zieldatei vor/nach verschieden); beide tragen
  `# expect: TestStripCommentHints`.
- **`make mutate`-Beleg — selbst nachgerechnet.** `cat .harness/state/mutate-passed.key` →
  `2bff167a…`, und `isolation_key` über dem heutigen Baum liefert denselben Wert
  (`bash -c 'REPO="$PWD"; source harness/tools/mutate.sh; isolation_key'`). Nach
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist die
  Bezugsmenge die Isolationskopie ohne `.git`; der Beleg überlebt den Commit zu Recht. Die
  Fall-Zahl **280** aus der Message trägt der Beleg nicht (er speichert nur den Schlüssel), sie
  deckt sich aber mit `ls test/mutations/*.sh | wc -l` → 280. **Was der Beleg nicht sagt:**
  `make mutate` urteilt nur über *gelistete* Wächter — das Span-Muster, die Rückübersetzung und die
  Marker-Form haben weiterhin keinen Fall
  (`grep -l 'backtickSpan\|unmaskQuoted\|dcheckIgnoreMarker' test/mutations/*.sh` → leer).
- **Gate-Stempel.** `cat .harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern denselben Wert (`3b79dd1c…`) — der
  aufgezeichnete `make gates`-Lauf deckt den Baum vor diesem Report
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
- **`make comment-claims`.** Grün: `57 Datei(en) geprueft, 0 Befund(e)`. Die im Kommentar genannten
  Sensoren existieren — `TestStripCommentHints` (`templates_test.go:578`) und
  `TestTemplates_KeineKommentarHilfenImEmittiertenSatz` (`:668`).
- **Die `make smoke`-Aussage im Kommentar stimmt.** Der emittierte Baum trägt eine `.d-check.yml`
  mit `modules: [links, anchors]` (Zeile 10), und [`harness/tools/smoke.sh`](../../harness/tools/smoke.sh)
  Schritt 4/5 fährt genau dieses `docs-check`. Der Kommentar sagt damit zu Recht, dass kein Gate
  die Wirkung auf den realen Satz misst — der Runde-1-HIGH-2-Gegenstand ist erledigt.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 — der Kommentar-Bestand trägt seine Klassen.** Die neuen
  und geänderten Blöcke stehen im Indikativ über den Zustand; keine Befund-Kennung, keine
  Slice-Nummer, kein Runden-Verweis, kein Lauf-Protokoll. Beanstandet ist oben der **Inhalt** dreier
  Zusagen, nicht ihre Form.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Host-Toolchain-Aufruf im Diff; jeder
  Lauf dieses Reviews ging über `make`-Ziele bzw. `docker build`.
- **Arbeitsbaum unberührt.** `git status --porcelain` war vor diesem Lauf leer; jede Sonde, jede
  Mutation und jeder Emit-Lauf lief außerhalb des Repos.

**Aus Runde 2 unverändert offen** (nicht neu gezählt): die `test/mutations/`-Lücke für Span-Muster,
Rückübersetzung und Marker-Form — die zwei neuen Fälle decken die zwei Entwurfsentscheidungen der
Maskierung, nicht diese drei; die `strings.Contains`-Klassifikation im Integrations-Wächter
(`templates_test.go:716`); und der vorformulierte Risiko-Ausgang §6 des Slice-Plans, der auf den
eingetretenen Fall nicht passt (Planner-Sache).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` |
| MEDIUM | 2 | `Zitat-Form-ausserhalb-der-erfassten-Paarung-loescht-Inhalt` · `Waechter-deckt-nur-die-haelfte-seiner-eigenen-Bedingung` |
| LOW | 1 | `Rueckuebersetzung-trifft-ein-fremdes-Vorkommen` |
| INFO | 0 | — |

**Der Zähler bekommt je *einen* Beleg, nicht mehr.**
`Neue-oeffentliche-Funktion-ohne-benannte-Grenze` erreicht mit HIGH-1 das **vierte** Auftreten
innerhalb von slice-140; `modul-06-roadmap.md` §Das Beobachtungs-Register ist an dieser Stelle
eindeutig: *„Zwei Funde im selben Vorgang sind eine Gelegenheit, kein zweites Auftreten"*. Der
Registerstand ist
`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`
→ **2** und für
[`BEO-ALL/commit-message-ohne-traceability-kennung`](../plan/planning/observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
→ **1** (keine Erwartungswerte, beide wandern). Für die Grenzen-Klasse führt das Register kein
Verzeichnis; sie anzulegen ist Closure-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10), nicht Sache
dieses Reports.

**Vier Runden, dieselbe Klasse am selben Ort — das ist der Steering-Loop-Punkt.** Modul 8
§Konflikt-Pfad macht die Sequenz ab dem **dritten** gleichen Konflikttyp zur Pflicht, und der
Reviewer-Skill nennt die dritte Wiederholung in einer Sitzung ein Signal, Guide oder Sensor
nachzuziehen statt nur zu melden. Das gehört als Lerneintrag in die Closure — nicht in diesen
Report, der eine Lauf-Beobachtung ist.

## Verdikt

**Blockierender Befund: ja — ein HIGH und zwei MEDIUM.**

**Was diese Runde belegt, und zwar mit eigenen Sonden:** Der robuste Ansatz trägt für alles, was die
drei vorigen Runden benannt haben. Alle fünf bekannten Fälle laufen **gleichzeitig** und korrekt —
unabhängig neu formuliert, nicht aus der Implementer-Testdatei wiederholt. Die Offset-Ersetzung ist
keine Umformulierung, sondern eine im Vor/Nach-Vergleich sichtbare Verhaltens-Verbesserung, und sie
hält über fünf Stellungen identischer Zitat-Literale. Die Wohlgeformtheits-Probe behebt die
Runde-3-Regression wirklich. Am realen Vorlagen-Satz ist der Emit **byte-gleich** zum Vor-Stand —
100 Dateien, ein einziger Unterschied, und das ist der mitkopierte Träger; ich habe beide Träger
selbst gebaut, den aktuellen gegen einen erzwungenen Neubau geprüft und beide Bäume selbst
emittiert. Beide neuen Mutations-Fälle habe ich rot gesehen, mit einer Meldung, die auf ihre
Mutation passt. Gate-Stempel und `mutate`-Beleg decken den Baum, selbst nachgerechnet. Drei der
fünf Runde-3-Befunde sind vollständig erledigt.

**Blockierend ist wieder der Kommentar, aber aus einem schärferen Grund als in Runde 3.** Diesmal
ist es nicht eine unvollständige Aufzählung, sondern eine Zusage, die an ihrer **eigenen**
Definition scheitert: `:817` sagt zu, die Regel starte nie innerhalb eines *wohlgeformt* zitierten
Zeichens, `:823-826` definiert *wohlgeformt* als *gerade Backtick-Zahl* — und F5 erfüllt genau diese
Definition, ist ein isoliertes Öffner-Zitat und verliert trotzdem zwei tragende Absätze. Der Satz
*„die einzig moegliche [Paarung]"* ist mit F4 in einer Zeile widerlegt. Und `:910` erklärt die
Grenzen-Menge erneut für geschlossen, während drei weitere Formen messbar danebenstehen, zwei davon
still löschend. Das ist der Fall, den [`AGENTS.md`](../../AGENTS.md) §3.6 wörtlich als *Falsch*
führt — eine Zusage, die weiter reicht als der Code —, an der einzigen Stelle, die diese Eigenschaft
überhaupt trägt: kein Gate misst die Wirkung dieser Funktion auf den realen Satz, und der nächste
Re-Baseline tauscht den Text, über den die Zusage spricht.

Dazu zwei Verhaltens-Lücken, die **keine Regressionen dieses Commits** sind, sondern in drei Runden
nicht gefunden wurden: ein Zitat im Doppel-Backtick-Code-Span löscht tragenden Text (MEDIUM-1), und
die Wohlgeformtheits-Probe deckt nur die ungerade Hälfte der Bedingung, die sie selbst nennt
(MEDIUM-2). Beide sind im heutigen Satz nicht auslösbar — gemessen, nicht angenommen — und gehören
damit in dieselbe Kategorie wie die schon akzeptierte Fence-Blindheit.

**Ausdrücklich nicht blockierend**, obwohl es naheläge:

- **Die DoD-Zahl 1 statt 0.** Unverändert die Lage aus Runde 3:
  [`AGENTS.md`](../../AGENTS.md) §3.10 reserviert das Umschreiben des Abnahmekriteriums dem Planner
  und verlangt vom ausführenden Lauf nur ein Übergabe-Artefakt. Das liegt dreifach vor
  (Commit-Message, Doc-Kommentar, dieser Report). Darauf zu blockieren hieße, gegen eine
  Rollen-Grenze zu blockieren.
- **Die drei Funktionen ohne eigenen `test/mutations/`-Fall.** DoD (2) verlangt *einen* Fall;
  `291`–`294` leisten das und treffen die reale Verdrahtung. Daraus eine Pflicht je Funktion zu
  machen, wäre eine Verschärfung durch Review statt durch Steering Loop.
- **Der Rückzug `in-progress → open`.** Der Slice-Plan §4 bindet ihn an die Bedingung *„ein
  entfernter Kommentar hält tragenden Inhalt, der nirgendwo sonst steht"*. Sie ist nicht
  eingetreten: der reale Satz ist byte-gleich, und alle drei neuen Formen sind in ihm gemessen
  abwesend. Ein Rückzug wäre hier nicht die ehrlichere, sondern die falsche Antwort.

**Reif für den Verifier: noch nicht.** Der Code ist es fast; der Kommentar ist es nicht. Solange er
an seiner eigenen Definition scheitert, prüfte der Verifier gegen einen Text, den die Messung schon
widerlegt hat — und er ist hier der einzige Träger.
