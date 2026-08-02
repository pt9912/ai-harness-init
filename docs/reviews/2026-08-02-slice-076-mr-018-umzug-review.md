# Review slice-076 — MR-018 zieht ins Technik-Stratum

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10), frischer Kontext |
| **Datum** | 2026-08-02 |
| **Diff** | `9156acb..5da0db3` — fünf Commits: `80867dc` Inventar · `a8058c2` Umzug · `3f7908a` Aufhebung · `fc79a67` Entfernung · `5da0db3` Korrektur |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-076-mr-018-umzug-technik-stratum.md` |
| **Referenzierte aktive ADRs** | ADR-0011 (Accepted, Zielort-Setzungen der Folgepflichten 1/2 teil-revidiert) · ADR-0012 (Proposed) · ADR-0013 (Accepted) · ADR-0014 (Accepted) |
| **Betroffene LH-IDs** | LH-FA-01, LH-FA-03, LH-QA-01, LH-QA-02 |
| **Hard Rules** | AGENTS.md §3.1 · §3.3 · §3.4 · §3.5 · §3.6 |
| **MR-IDs** | MR-000, MR-007, MR-008, MR-016, MR-018, MR-019, MR-020, MR-021 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md` (B1–B5, Z1–Z5) · `docs/reviews/2026-07-30-slice-060-dod2-review*.md` · `docs/reviews/2026-07-31-slice-060-dod3-review*.md` · `docs/reviews/2026-08-02-slice-060-closure-review*.md` |
| **Push-Stand** | `origin/main` = `3df35f3`; HEAD ist **8 Commits voraus, 0 zurück** (`git rev-list --left-right --count @{u}...HEAD` → `0 8`). Nichts gepusht. |
| **Nicht Gegenstand** | DoD-Abhakung und Gate-Lauf-Bestätigung (Modul 11, eigener Kontext) |

**Verdikt: nicht merge-fertig.** Zwei MEDIUM sind vor dem Merge zu klären. Der Umzug
selbst — Aufhebung, Entfernung, Anker, Append-only, Kennungs-Freiheit des Zielorts —
ist vollständig und regelkonform; die zwei MEDIUM liegen an seinen Rändern: an dem, was
er stehen ließ (Code-Kommentare) und an dem, was er wörtlich mitnahm, ohne es zu
benennen.

## Findings

### MEDIUM-1 — 30 Nennungen behaupten Inhalt in einem Eintrag, der keinen mehr hat; vier nennen ihn die bindende Fassung; nichts im Repo benennt das als offen

- **kategorie:** MEDIUM
- **quelle:** ADR-0013 Festlegung 1 · MR-021 (*„Kein Satz seines Rumpfs bindet noch von dort"*) · AGENTS.md §3.6 (*„die Zusage auf das einschränken, was der Code hält"*)
- **pfad:** `internal/span/emit.go:40` · `internal/span/response.go:23` · `internal/span/response.go:104` · `internal/span/response_test.go:322` (die vier Normativitäts-Aussagen) sowie 26 weitere in 23 Nicht-Markdown-Dateien
- **befund:** Seit `fc79a67` trägt `MR-018` fünf Zeilen ohne Rumpf. 30 der 41
  `MR-018`-Nennungen in Nicht-Markdown-Dateien treffen eine Aussage im Präsens über den
  **Inhalt** jenes Eintrags — *„Die Feldtabelle samt Incident-Fragen steht in
  harness/conventions.md MR-018"*, *„Die bindende Fassung steht in MR-018"*, *„Die VOLLE
  Pflicht-Spalte aus MR-018"*, *„Derive bildet die MR-018-Tabelle ab"* —, davon vier
  ausdrücklich als *normative* bzw. *bindende Fassung*; genau das bestreitet MR-021.
  Kein Sensor sieht es (s. Messung 6), und weder Plan §6, noch *„Nicht in diesem
  Slice"*, noch eine der fünf Commit-Messages nennt den Posten als offen.
- **verifizierbar:** nein — kein Gate-Lauf bestätigt ihn. `make comment-claims` ist
  strukturell blind (Messung 6), `make docs-check` scannt nur die 282 Markdown-Dateien.
  Bestätigen lässt sich der Befund nur über die Trefferliste unten.

### MEDIUM-2 — zwei Zeilen der Feldtabelle nennen beide „die dritte Korrelations-Achse aus Modul 15", eine davon falsch; benannt ist es nirgends

- **kategorie:** MEDIUM
- **quelle:** ADR-0013 Folgepflicht 1 (*„was dabei als falsch auffällt, wird benannt und getrennt behoben"*) · Plan §3 Schritt 2 · MR-019 (Rang 2)
- **pfad:** `spec/spezifikation.md:89` und `spec/spezifikation.md:90`
- **befund:** Zeile 89 nennt `adr` *„die dritte Korrelations-Achse aus Modul 15
  §Kernidee"* — dort steht `slice.id`, `requirement.id`, `adr.id`, `agent.role`, `adr.id`
  ist die dritte, das trifft zu. Zeile 90 nennt `branch`/`commit` mit derselben Formel
  *„die dritte Korrelations-Achse aus Modul 15 (Slice/**PR**/Agent-Rolle)"* — in dieser
  Liste ist PR die **zweite**. Der Wortlaut ist wörtlich mitgezogen, was der Plan
  erlaubt; die dann fällige Benennung fehlt in Plan, Zeitdokument, MR-021 und allen fünf
  Commit-Messages. Der Fehler steht damit unbenannt im Rang-2-Dokument, an einem Link,
  der zum Gegenbeweis führt.
- **verifizierbar:** nein — `anchors` prüft, dass der Link auflöst, nicht was am Ziel
  steht.

### LOW-1 — der Kopf von MR-018 nennt drei von sechs Posten-Arten

- **kategorie:** LOW
- **quelle:** ADR-0014 Festlegung 1 · MR-020 (*„eine Zeile mit dem aufhebenden Eintrag und den Zielorten je Posten-Art"*)
- **pfad:** `harness/conventions.md:838`
- **befund:** Die Zeiger-Zeile nennt Zielorte für technische Festlegung (§5), Schranke
  (§3) und datierte Messung (Zeitdokument). Die drei übrigen Posten-Arten, die MR-021
  führt — nacherzählter Regelwerks-Inhalt, Prozess-Zustand (→ Plan), Abweichung von der
  Baseline —, stehen dort nicht; der Leser, der bei MR-018 ankommt, braucht einen Hop zu
  MR-021. Die von ADR-0014 zugesagte *„Reichweite am Ort des Lesens"* ist damit
  teilweise. **Nicht** Gegenstand dieses Befunds ist die Länge: *„eine Zeile"* hält
  wörtlich (`wc -l` → 1) wie als Listen-Element.
- **verifizierbar:** nein.

### LOW-2 — der Plan widerspricht sich in der Zeile, die ADR-0014 Bedingung (b) trägt

- **kategorie:** LOW
- **quelle:** ADR-0014 Bedingung (b) · Maintainability
- **pfad:** `docs/plan/planning/in-progress/slice-076-mr-018-umzug-technik-stratum.md:337` gegen `:443`
- **befund:** Nachmessung 4 sagt *„**Zwei** Posten stehen andernorts bindend und
  entfallen deshalb (Zeilen **R-41 und R-43** der Tabelle)"*. Die Zusammenfassung
  desselben Abschnitts sagt *„R-02, R-40, R-41 und **R-43a** … **Drei** davon stehen
  andernorts bindend"*. R-43 ist in der Tabelle keine ersatzlose Zeile, sondern zieht
  nach §5 um. Zahl und Zeilen-ID gehen auseinander.
- **verifizierbar:** nein.

### LOW-3 — die Commit-Message der Entfernung nennt drei Zahlen, die am eigenen Commit nicht messbar sind

- **kategorie:** LOW
- **quelle:** AGENTS.md §3.6 (Commit-Message ist ausdrücklich eine Zusage) · LH-QA-02
- **pfad:** Commit `fc79a67`, Message
- **befund:** Die Message sagt *„127 Vorkommen des Ankers in **25** Dateien"* — an
  `fc79a67` sind es 127 in **23** Dateien (AGENTS.md und harness/README.md haben ihre
  Verweise in `3f7908a` verloren, also einen Commit früher). Und *„Die Datei geht von
  1.850 Zeilen / **152.929** Bytes auf 1.030 / **82.280**"* — gemessen 152.950 → 82.301.
  Beide Byte-Werte liegen um exakt 21 daneben; Zeilenzahl und Delta stimmen.
- **verifizierbar:** nein.

### LOW-4 — B1/B2 sind importierte Verdikt-Kennungen im bindenden Text; das Muster der ersatzlos-Klasse war enger als die Klasse

- **kategorie:** LOW
- **quelle:** Plan §1 (*ersatzlos* geht die Entstehungs-Erzählung) · MR-021 Posten 5
- **pfad:** `spec/spezifikation.md:526`, `:529`, `:531`, `:585`
- **befund:** `B1` und `B2` stammen aus `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md`
  §6 (Bedingungen B1–B5) und stehen ohne Herkunft im Rang-2-Dokument; Zeile 585
  (*„,132 rot' hieße dann nicht mehr eindeutig ,B1 greift im ERSTEN Wächter'"*) ist ohne
  die Definition an Zeile 526 nicht lesbar. Jede `Review-Befund`-/`Verifier-Befund`-Stelle
  ist gestrichen — der Filter des Plans (`grep -cE '(Review|Verifier)-Befund'`) trifft
  Verdikt-Kennungen aus einem Architect-Lauf aber nicht.
- **verifizierbar:** nein — `ids.patterns` führt kein Muster für `B\d`.

### INFO-1 — MR-019 zählt weiter „zwei Abweichungen von der Vorlagen-Form"

- **kategorie:** INFO
- **quelle:** MR-020 (append-only) · ADR-0014 Festlegung 3
- **pfad:** `harness/conventions.md:862`
- **befund:** Die Zahl ist seit der Sensor-Spalte überholt. MR-021 hält das fest, MR-019
  bleibt byte-identisch und trägt keinen Vorwärts-Zeiger. Das ist die von MR-020
  vorgeschriebene Behandlung und im Plan als Kosten benannt — hier verzeichnet, damit ein
  späterer Leser die Differenz nicht für Drift hält.
- **verifizierbar:** nein.

### INFO-2 — die datierten Messungen liegen jetzt im `codepaths`-Ausnahmebereich

- **kategorie:** INFO
- **quelle:** `.d-check.yml` `codepaths.exempt-paths: ["docs/reviews/**"]`
- **pfad:** `docs/reviews/2026-08-02-span-schema-messreihen.md`
- **befund:** Der Bestand kam aus `harness/conventions.md`, das in `codepaths.roots`
  liegt und nicht ausgenommen ist. Betroffen sind 6 Referenzen auf `spec/`, `harness/`,
  `docs/`; eine davon (`harness/tools/999-gibt-es-nicht.sh`) existiert absichtlich nicht
  und ist als Gegenprobe dokumentiert — außerhalb der Ausnahme wäre sie ein
  `codepath-missing`. Die Ausnahme ist damit tragend und nicht nur bequem.
- **verifizierbar:** ja — die Datei aus `codepaths.exempt-paths` nehmen färbt
  `make docs-check` rot.

## Was ich selbst gemessen habe

Alle Läufe am Stand `5da0db3`, sauberer Baum, gepinntes Image, `--network none`.

### 1. Die vier Kennzahlen der Vorlage

```
$ git show 9156acb:harness/conventions.md | awk 'NR>=835&&NR<=1658' | wc -l -c
    824   70727
$ awk 'NR>=835&&NR<=839' harness/conventions.md | wc -l          #  MR-018 heute
      5
$ git show 9156acb:harness/conventions.md | wc -l -c ; wc -l -c harness/conventions.md
   1769  145716
   1030   82301
$ git show 9156acb:spec/spezifikation.md | wc -l ; wc -l spec/spezifikation.md
     73
    621
```

Alle vier bestätigt: MR-018 824 → 5 Zeilen, `harness/conventions.md` 1.769 → 1.030 Z /
145.716 → 82.301 B, `spec/spezifikation.md` 73 → 621 Z. Das Zeitdokument misst 250 Z /
16.019 B.

### 2. ADR-0014 Bedingung (a) — Vollständigkeit des Inventars

Die 79 Rumpf-Spannen aus der Plan-Tabelle extrahiert, Union gebildet, gegen 838–1657 des
Standes `9156acb` gelaufen:

```
$ awk -f coverage.awk spans.txt conv-9156acb.md
ungedeckte Zeilen: 23, davon leer: 23
```

54 Hauptspannen (`^\| R-[0-9]{2} \|`) + 25 Teil-Posten (`^\| R-[0-9]{2}[a-z] \|`) + 2
Kopf-Posten = 81. **Bestätigt, keine Differenz.**

### 3. ADR-0014 Bedingung (b) — Wächter und Zähne

```
$ awk 'NR>=835&&NR<=1658' conv-9156acb.md | grep -oE 'Test[A-Z][A-Za-z0-9_]+' | sort -u   # 10
$ comm -23 alt-tests.txt neu-tests.txt   # nur alt  -> leer
$ comm -13 alt-tests.txt neu-tests.txt   # nur neu  -> leer
```

**10/10, keine Differenz.** Jede der zehn Funktionen existiert (`git grep -l "func <T>("`).

Bei den Mutations-Fällen habe ich mich zuerst selbst verzählt und nenne es, weil die
Zahl sonst falsch im Umlauf bliebe: mein erstes Muster `test/mutations/[0-9]+` fand nur
**25 von 30** im Stratum und meldete 32/117/118/119/139 als fehlend. Das Muster war
enger als die Frage — §5 führt die Kurzform *„Fall N"*, in Zeile 73 ausdrücklich
definiert, und *„den Fällen 117, 118, 119 / und 139"* läuft über einen Zeilenumbruch.
Über beide Schreibweisen und zeilenübergreifend:

```
$ tr '\n' ' ' < spec/spezifikation.md | tr -s ' ' > spec-flat.txt
$ { grep -oE 'test/mutations/[0-9]+' spec-flat.txt | grep -oE '[0-9]+';
    grep -oE 'F(all|älle|ällen) [0-9]+((,| und) [0-9]+)*' spec-flat.txt | grep -oE '[0-9]+'; } \
    | sort -n -u > neu-n.txt
$ comm -23 alt-n.txt neu-n.txt   # leer
$ comm -13 alt-n.txt neu-n.txt   # leer
```

**30/30, keine Differenz.** Alle 30 Dateien existieren (`ls test/mutations/<n>-*.sh`, 0
fehlend).

### 4. ADR-0014 Bedingung (c) — zwei Commits, der zweite löscht nur

```
$ git show --numstat --format='' 3f7908a
1	1	AGENTS.md
2	2	harness/README.md
81	0	harness/conventions.md
$ git show --numstat --format='' fc79a67
0	820	harness/conventions.md
```

**Bestätigt:** Aufhebung und Entfernung sind zwei Commits, unmittelbar aufeinander, und
der Entfernungs-Commit hat 0 Insertions und berührt genau eine Datei.

### 5. Der Anker — Gegenprobe reproduziert

```
$ grep -n '^### MR-018' harness/conventions.md
835:### MR-018 — Span-Schema der Telemetrie-Erfassung
$ git show 9156acb:harness/conventions.md | grep -n '^### MR-018'
835:### MR-018 — Span-Schema der Telemetrie-Erfassung
```

Überschrift byte-gleich. Verweise **jetzt**: 127 Vorkommen in **23** Dateien
(`grep -rho …` / `grep -rl …`, `--include='*.md'`); am Stand `9156acb`: 127 in **25**
(AGENTS.md und harness/README.md sind seit `3f7908a` raus). Die Vorlage nennt „127 in 25"
— das gilt für `9156acb`, nicht für HEAD.

Gegenprobe in isolierter Kopie (`git archive HEAD`), Überschrift umbenannt:

```
$ make -C <kopie> docs-check ; echo $?
d-check: 282 Datei(en) geprüft, 125 Befund(e)
make: *** [d-check.mk:29: docs-check] Fehler 1
2
```

**125 `anchor-missing` über 22 Dateien, alle 125 auf
`#mr-018--span-schema-der-telemetrie-erfassung`, Exit 2 — exakt reproduziert.** Vor der
Umbenennung: `282 Datei(en), 0 Befund(e)`, Exit 0. Der d-check-Prozess selbst gibt Exit
**1** zurück; die 2 ist `make`.

### 6. Die 41 Nennungen in Nicht-Markdown — Klassifikation und Sensor-Lage

```
$ git grep -l 'MR-018' -- ':!*.md' | wc -l      # 23
$ git grep -o 'MR-018' -- ':!*.md' | wc -l      # 41
```

Klassifiziert nach der Frage *„trifft die Zeile eine Aussage über den Inhalt oder nennt
sie bloß eine Adresse?"*: **historisch** = Vergangenheitsform über einen früheren Stand
(`sagte|schrieb|berief sich|zuschrieb|zaehlte|machte`); **Adresse** = Klammer-/Listen-Zitat
(`\((… , )?MR-018(, …)?\)`, `MR-018/LOW-7`); **Inhalt** = Rest.

```
gesamt: 41  | historisch: 4 | adresse: 7 | INHALT: 30
```

Zwei der 30 sind bei Handkontrolle ebenfalls Vergangenheitsform (`internal/span/emit.go:178`
*„machte die Luecke nur in MR-018 sichtbar"*, `test/mutations/111-…:10` *„zaehlte 10 der
12 Pflicht-Zeilen aus MR-018 auf"*), die mein Ausdruck nicht griff. **Damit 30
mechanisch, 28 nach Handkorrektur.** Die schärfsten vier:

```
internal/span/emit.go:40        // harness/conventions.md MR-018 — sie ist die normative Fassung
internal/span/response.go:23    // die normative Fassung (ADR-0011 Folgepflicht 1: …)
internal/span/response.go:104   // Die bindende Fassung steht in MR-018.
internal/span/response_test.go:322  // normative Fassung dieser Auszaehlung steht in … MR-018
```

Warum `comment-claims` schweigt — gemessen, nicht angenommen:

```
$ git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' | grep -v '_test[.]go' \
  ; git ls-files 'harness/tools/*.sh' '.claude/hooks/*.sh'          # 38 Dateien
$ comm -12 <(git grep -l 'MR-018' -- ':!*.md' | sort) <(sort cc-files.txt)
.claude/hooks/pretooluse-agent-guard.sh
harness/tools/span-check.sh
internal/span/emit.go
internal/span/response.go
internal/span/span.go
$ git grep -n 'MR-018' -- ':!*.md' | grep -cE 'garantiert|stellt sicher|bewacht|belegt|sorgt dafuer|sorgt dafür|verhindert'
0
```

**Zwei Gründe, beide strukturell.** (1) Von den 23 Dateien liegen **5** im Prüfbereich,
**18** dauerhaft außerhalb (`_test.go` ausgenommen, `test/` nicht unter den vier
Pfad-Mustern). (2) Auch für die 5 trifft der `CLAIM`-Ausdruck des Werkzeugs **0** der 41
Zeilen: es fragt *„nennt eine Abdeckungs-Behauptung ihren Sensor?"*, nicht *„ist das
genannte Dokument noch das bindende?"*. Das Werkzeug sagt es im eigenen Kopf: *„Was er
weiterhin NICHT kann … pruefen, ob der genannte Sensor die Behauptung inhaltlich
TRAEGT."* Und `d-check` sieht die Dateien gar nicht: 282 geprüfte Dateien = genau die
Zahl der `*.md` außerhalb der `scan.ignore`-Globs.

### 7. MR-020 „eine Zeile"

```
$ awk 'NR==838' harness/conventions.md | wc -l -c -m
      1     542     547
```

**Eine** physische Zeile, 542 Zeichen / 547 Bytes. Beide Lesarten — physische Zeile und
Listen-Element — halten; die Auslegung des Implementers ist nicht nötig, sie trägt aber
auch nichts Falsches. Die Vorlage nennt *„383 Zeichen"* — gemessen sind es 542; die Zahl
stimmt in keiner der beiden Lesarten und ist zu korrigieren. Der Befund an dieser Zeile
liegt nicht bei der Länge, sondern bei den drei fehlenden Posten-Arten (LOW-1).

### 8. Append-only an MR-019 und MR-020

```
$ diff <(git show 9156acb:harness/conventions.md | awk '/^### MR-019/,/^## Modus-Deklaration/' | head -n -1) \
       <(awk '/^### MR-019/,/^### MR-021/' harness/conventions.md | head -n -1)
$ echo $?
0
```

**Byte-identisch, 96 gegen 96 Zeilen.** MR-019 ist unangetastet; seine überholte Zahl
steht in MR-021 (INFO-1).

### 9. Der Zielort trägt keine Entscheidungs- und keine Planungs-Kennung

```
$ grep -n 'ADR-[0-9]' spec/spezifikation.md
621:| 2026-08-02 | §5 nimmt das Span-Schema auf … | [`ADR-0013`](../docs/plan/adr/0013-…) |
$ grep -n 'slice-[0-9]' spec/spezifikation.md        # leer
$ grep -n 'MR-[0-9]'    spec/spezifikation.md        # leer
$ grep -n 'docs/plan'   spec/spezifikation.md
348:   1) und das Schreibziel (`docs/plan/` gegen Code-Pfade).
621:| … | [`ADR-0013`](../docs/plan/adr/0013-technik-stratum-als-zielort.md) |
```

Die einzige Entscheidungs-Kennung und der einzige Link auf eine Entscheidungs-Datei
stehen in Abschnitt 7 Historie — von `matrix.exclude-sections` ausgenommen und von
ADR-0013 Festlegung 3 ausdrücklich erlaubt. **Nackte `slice-`-Kennungen, die kein Muster
träfen: null.** Der Rest, den laut ADR-0013 „der Mensch trägt", ist damit gemessen und
nicht angenommen.

### 10. Entstehungs-Erzählung und datierte Messung im bindenden Text

```
$ grep -nE 'bis (zum )?20[0-9]{2}-[0-9]{2}-[0-9]{2}|[Ff]rühere Fassung|Vorgänger|hier stand|stand hier|(Review|Verifier)-Befund|Runde [0-9]|R[0-9]-(HIGH|MEDIUM|LOW)|V-[0-9]' spec/spezifikation.md
506:  der Vorgänger-Fassung legte den Strom lautlos still) und
$ grep -nE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' spec/spezifikation.md
3:**Status:** Aktiv. **Letzte Änderung:** 2026-08-02.
620:| 2026-08-01 | Initial | — |
621:| 2026-08-02 | §5 nimmt das Span-Schema auf …
```

**Kein Datums-Stempel außerhalb Kopf und Historie, keine Befund-Herkunft, keine
Runden-Verweise.** Der eine Treffer an Zeile 506 beschreibt die *Vorgänger-Fassung des
Emitters* (warum es den Mutations-Fall 114 gibt) und nicht die Entstehung des Textes —
kein Befund. Die vier `B1`/`B2`-Stellen fängt kein Ausdruck dieser Familie: LOW-4.

### 11. Commit 5 löst genau die zwei Wortlaute auf, und die Korrektur stimmt

`git show 5da0db3` berührt nur `spec/spezifikation.md` (32 ins / 12 del) und ändert genau
zwei Stellen: die Überschrift des Abweichungs-Blocks (a) und die Zählung der
`settings.json`-Prüfstellen (c). Beide nachgemessen:

- **(a)** Modul 15 §Kernidee und §Span-/Audit-Attribut-Regeln gelesen: Pflicht-Minimum =
  Slice-ID · Agent-Rolle · Cache-Status · `requirement.id` → Abweichung 1 und 3;
  Mindestfelder = *„Korrelations-IDs zu Slice/PR/Agent-Rolle"* → Abweichung 2;
  Token-Attributions-Regeln → 5 und 6; 4 weicht von keiner ab. **Die neue Fassung trifft
  zu.**
- **(c)**
  ```
  $ git grep -n 'settings\.json' -- test/ Makefile harness/tools/ ':(glob)**/*_test.go'
  harness/tools/smoke.sh:76        (Existenz-Schleife Durchsetzungsschicht)
  harness/tools/smoke.sh:85,86     (grep auf PreToolUse — Verdrahtung)
  internal/emit/enforce_test.go:37 (TestEnforce_EmitsAllMechanicFiles — Vorhandensein)
  internal/emit/enforce_test.go:83,88,94 (TestEnforce_SettingsWiresBothHooks — Verdrahtung)
  test/mutations/32-enforce-settings-wires-guard.sh
  ```
  **Fünf Prüfstellen in drei Dateien, `Makefile` steuert nichts bei — die neue Fassung
  trifft zu.** Posten (d) ist wie angekündigt nicht richtiggestellt, sondern entfallen:
  die Sonde auf die *Schlüsselnamen* von `tool_input` steht nirgends mehr in §5 (die dort
  verbliebene *Werte*-Sonde auf `tool_input.prompt` ist ein anderer Posten) und ist in
  MR-021 als ersatzlos mit Grund verzeichnet.

### 12. Weitere Zahlen des Zielorts

Feldtabelle 26 Zeilen · Werkzeug-Tabelle 6 Zeilen · 9 Modul-Nennungen in
`spec/spezifikation.md`, **alle** mit auflösendem Link auf
`.harness/baseline/v3.5.2/regelwerk/modul-NN-*.md`; ebenso in MR-021. Die sechs
Modul-7-Nennungen des alten Rumpfs sind mit dem Prozess-Zustand in Plan §6 gegangen.
Die sechs kanonischen Rollen-Namen decken sich mit `.claude/agents/` (6 Dateien) und mit
`internal/span/emit.go:184`.

### 13. `make gates`

```
$ make gates ; echo "GATES-EXIT=$?"
baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 282 Datei(en) geprüft, 0 Befund(e)
1..150
ok 150 sources-url in .d-check.yml traegt den aktuellen BASELINE_TAG (Kopplung, MR-013)
comment-claims: 38 Datei(en) geprueft, 0 Befund(e)
span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert
GATES-EXIT=0
```

Deckt sich mit der Ausgangslage der Vorlage (d-check 282/0 · comment-claims 38/0 · 150
bats). `make mutate` habe ich nicht gefahren — Vorgabe der Vorlage.

## Negativbefunde — geprüft, ohne Befund

| Bereich | geprüft | Ergebnis |
|---|---|---|
| ADR-0014 Bedingung (a) | Inventar-Abdeckung 838–1657, 81 Posten | 23 ungedeckte Zeilen, alle leer — ohne Befund |
| ADR-0014 Bedingung (b), Wächter | `comm` über 10 Test-Funktionen, Existenz je Funktion | 10/10, keine Differenz — ohne Befund |
| ADR-0014 Bedingung (b), Zähne | `comm` über 30 Mutations-Fälle, beide Schreibweisen, zeilenübergreifend; `ls` je Fall | 30/30, keine Differenz, 0 fehlende Dateien — ohne Befund |
| ADR-0014 Bedingung (c) | `numstat` je Commit | zwei Commits, `0 820`, eine Datei, unmittelbar aufeinander — ohne Befund |
| Anker-Erhalt | Überschrift byte-gleich; Gegenprobe in isolierter Kopie | 125 `anchor-missing` / 22 Dateien / Exit 2 reproduziert — ohne Befund |
| Append-only (MR-000, MR-019, MR-020) | `diff` der Blöcke alt/neu | byte-identisch — ohne Befund |
| ADR-0013 Festlegung 3 (Kennungs-Freiheit) | `ADR-`/`slice-`/`MR-`/`docs/plan`-Scan über `spec/spezifikation.md` | nur Historie-Zeile; **null** nackte `slice-`-Kennungen — ohne Befund |
| MR-019 Form-Regel (Abschnittsnummern nie neu vergeben) | `## `-Überschriften in `spec/spezifikation.md` | 3 · 5 · 6 · 7 plus die nicht nummerierte Aufnahme-Regel — unverändert, ohne Befund |
| Linkpflicht auf Regelwerks-Module | Modul-Nennungen ohne `regelwerk/modul-NN` | 0 in `spec/spezifikation.md`, 0 in MR-021 — ohne Befund |
| Entstehungs-Erzählung / datierte Messung im Zielort | Muster-Scan über `spec/spezifikation.md` | keine, außer dem Emitter-Vorgänger an Zeile 506 (kein Befund) — LOW-4 betrifft eine andere Familie |
| Commit-Folge (AGENTS.md §3.3 in der Sache) | fünf Commits, `numstat` je Commit | Verschieben, Aufheben, Entfernen, Korrigieren sind getrennt — ohne Befund |
| Commit 5 Reichweite | vollständiger Diff | genau (a) und (c), sonst nichts — ohne Befund |
| Korrektur (a) sachlich | Modul-15-Regelblöcke gelesen | trifft zu — ohne Befund |
| Korrektur (c) sachlich | `git grep 'settings.json'` über den deklarierten Umfang | fünf Prüfstellen / drei Dateien — ohne Befund |
| Posten (d) ersatzlos | Suche nach der Schlüsselnamen-Sonde in §5 | entfallen, in MR-021 mit Grund verzeichnet — ohne Befund |
| Sensor-Spalte: existieren die genannten Wächter? | 10 Funktionen + 30 Fälle | alle vorhanden — kein halluzinierter Sensor (LH-QA-01), ohne Befund |
| Sensor-Spalte: Grenze deklariert? | MR-021 Punkt *Sensor, und seine Grenze* | *„einen Namen und keinen Sensor"*, mit Sonden-Messung — ohne Befund |
| Zeitdokument | Inhalt, Rollen-Kopf, Referenzen auf `codepaths`-roots | Festlegungen sind nicht dorthin abgewandert; 6 Referenzen, INFO-2 — ohne Befund |
| Gate-Tabellen-Nachzug | `AGENTS.md:128`, `harness/README.md:51` und `:62` | zeigen auf `spec/spezifikation.md` §5, Anker löst auf — ohne Befund |
| Feldtabelle: Zuordnung Wächter ↔ Feld | Stichprobe `tool`→130, `tool_use_id`→110, `branch`→111, `seq`→109 | die frühere Fehlzuordnung (110 statt 130) ist nicht mitgezogen — ohne Befund |
| Wörtlichkeit des Umzugs | Stichprobe `total_tokens`, `total_duration_ms` alt/neu | nur die angekündigten Streichungen, Regel-Substanz erhalten — ohne Befund |
| Hard Rule §3.4 (ADR-Immutabilität) | Diff über `docs/plan/adr/` | keine ADR berührt — ohne Befund |
| Hard Rule §3.5 (Gate-Lockerung) | Diff über `.d-check.yml`, `Makefile`, `harness/tools/` | keine Gate-Config berührt — ohne Befund |
| Hard Rule §3.1 (halluzinierte Gates) | `make gates` real gefahren | Exit 0, jede genannte Zahl aus echter Ausgabe — ohne Befund |
| Emittierte Ebene | Diff über `internal/emit/` | unberührt (ADR-0013/0014 Folgepflicht 3) — ohne Befund |

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 2 |

## Fehler in der Review-Vorlage (gemeldet, nicht still repariert)

1. *„127 Verweise in 25 Dateien"* gilt für `9156acb`, nicht für HEAD. Am geprüften Stand
   sind es **127 Vorkommen in 23 Dateien**; AGENTS.md und harness/README.md haben ihre
   Verweise in `3f7908a` verloren.
2. *„ein Listen-Element über 383 Zeichen"* — gemessen **542 Zeichen / 547 Bytes / 1
   Zeile**.
3. *„Ein **benannter**, nicht behobener Widerspruch"* — der Widerspruch ist **nicht**
   benannt: weder im Plan, noch im Zeitdokument, noch in MR-021, noch in einer der fünf
   Commit-Messages. Genau das ist MEDIUM-2.

## Verdikt

**Der Umzug ist in seinem Kern vollständig und regelkonform, das Ergebnis aber nicht
merge-fertig.**

Vollständig und regelkonform: die drei Bedingungen aus ADR-0014 Festlegung 2 sind einzeln
nachgemessen und halten — (a) das Inventar deckt jede nicht-leere Zeile des Rumpfs, (b)
10/10 Wächter und 30/30 Zähne stehen am Zielort, ohne Differenz, (c) Aufhebung und
Entfernung sind zwei aufeinanderfolgende Commits, und der zweite fügt nichts ein. Der
Anker steht byte-gleich und seine Gegenprobe reproduziert exakt. MR-000, MR-019 und
MR-020 sind byte-identisch geblieben. Der Zielort trägt weder Entscheidungs- noch
Planungs-Kennung — auch keine, die kein Gate fängt. Die Sensor-Spalte nennt nur
existierende Wächter und deklariert ihre eigene Grenze. `make gates` ist grün, Exit 0.

Nicht merge-fertig aus zwei Gründen, und beide liegen an der Grenze des Umzugs, nicht in
ihm: **MEDIUM-1** — 28 bis 30 Präsens-Aussagen über den Inhalt von MR-018 stehen weiter
im Code, vier davon nennen den geleerten Eintrag die normative bzw. bindende Fassung des
Schemas, kein Gate kann es sehen, und kein Artefakt des Repos führt den Posten als offen.
**MEDIUM-2** — der Zielort trägt eine falsche Aussage über das Modul, das er verlinkt,
und die von ADR-0013 Folgepflicht 1 an dieser Stelle geschuldete Benennung fehlt.
