# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 7 (Bestätigungs-Runde)

> Dieser Report spricht über Backtick-Zitate und über HTML-Kommentar-Syntax. Jeder Sonden-Eingang
> und jeder Ausgang steht deshalb in einem Code-Block, nie in Inline-Code — sonst zerlegt die
> eigene Markdown-Syntax den Beleg.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `448db765..a5edef75` — ein Commit, **eine** Datei
  (`git show --pretty=format: --name-only a5edef75` → `internal/emit/templates.go`),
  9 Insertions / 12 Deletions, **zwei** Hunks.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) — `Accepted`, normativ
  (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0005-*.md`). Die Message dieses Commits nennt keine
  ADR-Kennung; das ist zulässig, weil sie zwei `LH-*` führt
  ([`AGENTS.md`](../../AGENTS.md) §5 verlangt *mindestens eine*).
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
  [Runde 5](2026-09-10-slice-140-vorlagen-hilfen-review-runde-5.md),
  [Runde 6](2026-09-10-slice-140-vorlagen-hilfen-review-runde-6.md) (1 HIGH / 2 INFO).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen an seinem Lifecycle-Ort
  (`docs/plan/planning/in-progress/`); unverändert — korrekt, der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums:** `git status --porcelain` vor **und** nach diesem Lauf leer; `main` ist
`voraus 1` gegenüber `origin/main` (`git status -sb`). Gate-Stempel und Arbeitsbaum-Hash sind
deckungsgleich:

```text
cat .harness/state/gates-passed.diffsha   -> 0da4a26714902ad66c9808f4386578727243f8d6a5d5c3f0b17469d803bbd9aa
bash harness/tools/working-tree-hash.sh   -> 0da4a26714902ad66c9808f4386578727243f8d6a5d5c3f0b17469d803bbd9aa
```

**Keine Erwartungswerte** — jede Zahl unten steht neben dem Kommando, das sie liefert.

## Der Prüfauftrag dieser Runde, und was er ausnimmt

Enger Umfang, drei Fragen: (1) Ist der Zähl-Beleg für *Fence-Blindheit* ersatzlos weg? (2) Hat der
Behebungs-Commit **seinerseits** eine Zusage eingesetzt, die nicht hält? (3) Ist der Diff
kommentar-only?

**Ausgenommen und hier nicht erneut geprüft:** die Heuristik-Lücken selbst (Runde-4-MEDIUM-1/-2,
entschieden offen), die `make mutate`-Frage (in Runde 5 geklärt, der Diff ist kommentar-only), und
alles, was Runde 5 und Runde 6 bereits als tragend bestätigt haben.

**Was ich trotzdem selbst gefahren habe, statt es zu erben:** *jedes* Kommando, das im
Doc-Block steht — die drei Proben, den Zähler über dem emittierten Baum — und, als eigene
Messung, die Eigenschaft, um die der Streit ging. Der Grund steht in Runde-6-INFO-2: Die
Formulierung, die dieser Commit einsetzt, ist **wörtlich die vom Review-Strang vorgeschriebene**
(Runde-6-§Verdikt: *„… die ehrliche Feststellung, dass für diese Form keine Messung im Block steht
und die Sicherheit heute an einer von Hand geprüften Reihenfolge hängt"*). Sie ungeprüft
durchzuwinken, weil sie aus dem eigenen Strang stammt, wäre genau die Falle, die Runde 6 als
Steering-Loop-Punkt notiert hat — nur eine Runde später und mit umgekehrtem Vorzeichen.

### Das Messinstrument dieser Runde, und sein rot gesehenes Gegenbeispiel

Die Eigenschaft *„kein Kommentar bindet vorzeitig an einen Pfeil in einem Code-Block"* ist
ordnungsabhängig; eine Zählung entscheidet sie nicht (das war Runde-6-HIGH-1). Ich habe deshalb
einen positionellen Scanner geschrieben, der `(?s)<!--.*?-->` über dem **zeilenweise maskierten**
Text nachbildet (Backtick-Spannen mit Kommentar-Syntax werden ersetzt, wie in
`maskQuotedCommentSyntax`) und den Fence-Zustand mitführt. **Vor** jeder Aussage über einen echten
Baum steht seine Kalibrierung — sonst ist eine 0 nicht von einem stummen Instrument zu
unterscheiden ([`AGENTS.md`](../../AGENTS.md) §3.6):

````text
a-fence.md   Kommentar oeffnet, danach ```mermaid mit "A --> B", dann "Ende -->"
  -> FENCE-BINDUNG  Kommentar Z2 schliesst an Pfeil in Fence Z6
  -> geschlossene Kommentare: 1 ; an Fence-Pfeil gebunden: 1
b-ok.md      Kommentar schliesst VOR dem Fence
  -> geschlossene Kommentare: 1 ; an Fence-Pfeil gebunden: 0
c-maske.md   derselbe Pfeil, aber in Inline-Code (Maskierungs-Kontrolle)
  -> geschlossene Kommentare: 1 ; an Fence-Pfeil gebunden: 0
````

Das Instrument hat also Zähne (a) und färbt nicht auf die zwei benachbarten Formen (b, c).
Über die realen Bäume gefahren:

```text
find .harness/baseline/v6.5.0/templates -name '*.md' -print0 | xargs -0 awk -f fence.awk
  -> geschlossene Kommentare: 91 ; an Fence-Pfeil gebunden: 0 ; offen am Dateiende: 0
find internal/emit/templates -type f -print0 | xargs -0 awk -f fence.awk
  -> geschlossene Kommentare:  9 ; an Fence-Pfeil gebunden: 0 ; offen am Dateiende: 0
(emittierter Baum, *.md ohne .git und .harness/baseline)
  -> geschlossene Kommentare: 14 ; an Fence-Pfeil gebunden: 0 ; offen am Dateiende: 0
```

**Kein Erwartungswert** — die Zahlen wandern mit dem Vorlagen-Satz. Meine Summe der geschlossenen
Kommentare (91 + 9) weicht von der in Runde 6 berichteten (105) ab; die Bezugsmengen sind
verschieden. Tragend ist an beiden Läufen dieselbe Zahl, und sie stimmt überein: **0**
Fence-Bindungen. Der Zustand des Baums ist damit unabhängig zweimal bestätigt.

## Findings

### INFO-1 — „von Hand geprueft" behauptet eine Prüfung, wo eine Eigenschaft gemeint ist

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 — *„Beschrieben wird die Stelle, nicht der
  Vorgang, der sie erzeugt hat"*
- **pfad:** `internal/emit/templates.go:968-970`
- **befund:** Der neue Satz lautet *„Fuer 'Fence-Blindheit' gibt es in diesem Block KEINE Probe —
  die Eigenschaft haengt heute an einer von Hand geprueften Reihenfolge, nicht an einem
  Kommando."* Die erste Hälfte hält (siehe Negativbefunde), die zweite ebenfalls. Das
  Partizip *„von Hand geprueft"* behauptet daneben einen **Vorgang**: dass jemand diese
  Reihenfolge geprüft hat. Dieser Vorgang ist in keinem lebenden Artefakt dieses Repos
  verzeichnet — er steht in Zeitdokumenten (`docs/reviews/**`), die
  [`AGENTS.md`](../../AGENTS.md) §3.7 einem Kommentar ausdrücklich nicht als Quelle gibt. Und
  er ist als *Handarbeit* nicht durchführbar: gemessen sind 91 zu schließende Kommentare über

  ```text
  find .harness/baseline/v6.5.0/templates -name '*.md' | wc -l   -> 48
  ```

  48 Dateien; wer das per Auge gegen die Fence-Positionen hält, prüft nicht, sondern rät. Beide
  Male, die diese Eigenschaft bisher bestimmt wurde (Runde 6 und dieser Lauf), war es ein
  positioneller Scanner, also ein Kommando — nur keines, das im Repo liegt.
- **Warum das kein Blocker ist:** Der **Zustand**, den der Satz beschreibt, ist wahr — ich habe
  ihn oben mit einem rot gesehenen Instrument nachgemessen (0 Bindungen über beide Bäume und über
  den emittierten). Der Satz führt keinen Sensor an, der die Form nicht sieht; er sagt
  ausdrücklich, dass **nichts** deckt. Das ist der von
  [`AGENTS.md`](../../AGENTS.md) §3.6 zugelassene zweite Weg (*„benennen, was wirklich deckt —
  oder dass nichts deckt"*), und damit die Auflösung von Runde-6-HIGH-1. Beanstandet ist eine
  Wortwahl, keine Deckungs-Behauptung: Ein Re-Baseline-Leser wird nicht in Sicherheit gewiegt,
  sondern erfährt nur nicht, **womit** er nachprüfen soll.
- **verifizierbar:** ja — der Kalibrierungs- und Messblock oben; das Fehlen jedes
  Fence-entscheidenden Kommandos im Repo ist unten unter Negativbefunde einzeln belegt.
  `make comment-claims` färbt nicht rot und kann es nicht: er prüft, ob ein genannter Sensor
  *existiert* — hier ist gerade keiner genannt.
- **klasse:** `Kommentar-behauptet-einen-Pruefvorgang-statt-einen-Zustand`

### LOW-1 — Die Deckungs-Bilanz nennt eine von zwei Lücken; die zweite steht zwölf Zeilen später

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.6 (Genauigkeit einer
  Deckungs-Aussage)
- **pfad:** `internal/emit/templates.go:955-959`
- **befund:** Der Satz bilanziert die Deckung so: *„eine GEMESSENE Abwesenheit EINZELNER der vier
  oben genannten Formen — keine der drei folgenden Proben deckt mehr als eine Form, und fuer 'zwei
  freistehende Backticks' gibt es hier gar keine Probe"*. Er nennt **eine** probenlose Form. Nach
  diesem Commit sind es **zwei**: die drei Proben decken zusammen genau zwei der vier Formen,
  weil Probe 1 und Probe 2 laut ihrer eigenen Beschriftung dieselbe Form über zwei Bäume messen
  (`# leer -- "Backtick-Lauf"` und `# leer -- dieselbe Form, zweiter Baum`).

  ```text
  Formen (4):  Fence-Blindheit · zeilenuebergreifendes Zitat · Backtick-Lauf · zwei freistehende Backticks
  Proben (3):  Probe 1+2 -> Backtick-Lauf   Probe 3 -> zeilenuebergreifendes Zitat
  ohne Probe:  zwei freistehende Backticks (hier genannt) UND Fence-Blindheit (erst :968 genannt)
  ```

  Wer nur diesen Satz liest — er ist der Kopf des Proben-Blocks und die Stelle, an der ein
  Re-Baseline-Leser die Bilanz sucht —, bekommt die Auskunft *drei Proben, eine Lücke* und
  unterschätzt den ungedeckten Rest um die Hälfte. Auflösbar ist es im Block (die Beschriftungen
  und der Satz auf `:968` tragen es), aber nur, wenn man beide Stellen zusammenliest.
- **Ausdrücklich kein neuer Defekt dieses Commits.** Der Satz ist über den Tausch byte-gleich —
  die zwei Hunks liegen bei `@@ -933,10 +933,7 @@` und `@@ -968,14 +965,14 @@`, der Satz stand
  vorher auf `958-962` und steht jetzt auf `955-959`, wortgleich. Vorher war er ebenso ungenau
  (auch damals hatte *Fence-Blindheit* keine Probe **in diesem Block**, nur eine Zählung im
  Aufzählungspunkt). Der Commit hat die Lage nicht verschlechtert; er hat sie sichtbar gemacht,
  weil die zweite Lücken-Aussage jetzt ausdrücklich dasteht.
- **verifizierbar:** ja —
  `diff <(git show a5edef75^:internal/emit/templates.go | sed -n '957,963p') <(git show a5edef75:internal/emit/templates.go | sed -n '954,960p')`
  → leer, Exit 0; und `sed -n '954,978p' internal/emit/templates.go`, die zwei Lücken-Sätze
  nebeneinander gelesen.
- **klasse:** `Deckungs-Bilanz-nennt-eine-von-zwei-Luecken`

## Negativbefunde (geprüft, ohne Befund)

- **Frage 1 — der Zähl-Beleg ist ersatzlos weg, ohne lesbaren Rest.** Der Aufzählungspunkt endet
  jetzt nach der Definition der Form und nennt keine Messung mehr. Über die ganze Datei:

  ```text
  grep -nE "Zaehl|Oeffner|Schliesser|grep -o '<!--'|wc -l" internal/emit/templates.go
    -> 799, 808, 834, 842  (Backtick-Token in maskQuotedCommentSyntax, anderer Gegenstand)
    -> 907, 922            (das Argument, dass ein reiner <!---Zaehler Zitat und Hilfe nicht trennt)
  grep -n "Fence" internal/emit/templates.go
    -> 936  (die Definition der Form)      -> 968  (die Feststellung, dass keine Probe existiert)
  ```

  Keine dieser sechs Stellen spricht über Fence-Blindheit; keine kann als deren Beleg gelesen
  werden. Die zwei Fence-Stellen sind Definition und Lücken-Eingeständnis, kein Beleg.
- **Frage 2, Teil A — „KEINE Probe in diesem Block" hält.** Der Block führt genau drei
  Proben-Kommandos (`sed -n '961,965p'`); ich habe alle drei selbst gefahren, jede liefert die
  behauptete leere Ausgabe:

  ```text
  grep -rn '``' "$T" --include='*.md' | grep -e '<!--' -e '-->'        -> 0 Zeilen
  grep -rn '``' internal/emit/templates/ | grep -e '<!--' -e '-->'     -> 0 Zeilen
  find "$T" -name '*.md' -print0 | xargs -0 awk '{ c=gsub(/`/,"`"); ... }'  -> 0 Zeilen
  ```

  Keine davon entscheidet Fence-Blindheit. Die Zahl *drei* im Satz *„Diese drei Proben"* stimmt.
- **Frage 2, Teil B — „nicht an einem Kommando" hält, und das war der Fall, der schiefgehen
  konnte.** `internal/emit/templates_test.go:604` führt eine Mermaid-Fence mit echtem Pfeil; wäre
  das ein Fence-Blindheits-Fall, wäre der Satz falsch. Ist es nicht: die Sonde heißt
  `oeffnerZitat` und trägt einen **zitierten** (also maskierten) Öffner — sie misst, dass ein
  Zitat *nicht* bis zum fremden Pfeil bindet, also die Nachbar-Eigenschaft. Ein **echter**
  Kommentar vor einer Fence kommt in keinem Testfall vor. Dazu:

  ````text
  Fences in der Fixture:  find internal/emit/templates -type f -exec grep -c '^```' ... -> keine Datei mit >0
  test/ und emit-Tests auf 'fence|mermaid':                       nur templates_test.go:564,604 (oeffnerZitat)
  test/mutations/ zu dieser Funktionsfamilie:  24, 94, 95, 291, 292, 293, 294 — keiner zur Fence-Form
  ````

  Da die Fixture überhaupt keine Fence trägt, kann `TestTemplates_KeineKommentarHilfenImEmittiertenSatz`
  die Form konstruktiv nicht erreichen. Kein Kommando dieses Repos entscheidet sie — genau das,
  was der Kommentar sagt.
- **Frage 3 — der Diff ist kommentar-only, mit eigenem Filter, auf vier unabhängigen Wegen.**

  ```text
  (1) geaenderte Nicht-Kommentar-Zeilen                                        -> 0
  (2) diff der Nicht-Kommentar-Rumpfe vorher/nachher                           -> leer, Exit 0
  (3) Hunks: @@ -933,10 +933,7 @@ und @@ -968,14 +965,14 @@, beide verankert
      an func unmaskQuotedCommentSyntax; naechste Top-Level-Deklaration ist
      func StripCommentHints in Zeile 994 -> beide Hunks liegen davor         -> ausserhalb jedes Literals
  (4) beruehrte Dateien insgesamt                                              -> internal/emit/templates.go
  ```

- **Alle übrigen Zusagen des Blocks selbst nachgefahren, keine gebrochen.** Nicht geerbt,
  sondern gemessen — der Block enthält genau ein weiteres Kommando und drei Artefakt-Zusagen:

  ```text
  :917-918 Zaehler ueber dem emittierten Baum   -> 1
           die gezaehlte Zeile ist              -> .harness/skills/reviewer.md:30 (ein Zitat, keine Hilfe)
  :909-913 vier Zitate in drei Dateien des vendored Satzes
           -> README.md:70, README.md:71, spec/lastenheft.template.md:5,
              .harness/skills/reviewer.template.md:42   = 4 Vorkommen / 3 Dateien
  :980-982 genannte Sensoren existieren         -> templates_test.go:578 und :668
  :986-988 emittiertes docs-check sieht keinen Kommentar-Inhalt
           -> grep '^modules:' <emit>/.d-check.yml  ->  modules: [links, anchors]
  :989-991 test/courseset-fixture.bats prueft keine Kommentare
           -> 5 @test, alle zu Dateibestand / Platzhalter-Pfad-Form / isRecurring;
              die drei 'Kommentar'-Treffer sind Go-Doc-Kommentare, keine HTML-Hilfen
  ```

  Der emittierte Baum dafür stammt aus einem frischen Lauf des Trägers
  (`.harness/state/bin/ai-harness-init --name probe`, Exit 0) in einem leeren `git init`-Verzeichnis
  **außerhalb** des Repos; der Arbeitsbaum ist unberührt geblieben.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 — Form der neuen Kommentar-Zeilen.** Keine Befund-Kennung,
  keine Slice-Nummer, kein Runden-Verweis, kein Lauf-Protokoll:
  `git show a5edef75 | grep -E '^\+' | grep -inE 'Review-Befund|slice-[0-9]|Runde [0-9]|HIGH-[0-9]|rot gesehen'`
  → keine Fundstelle. Der Text steht im Indikativ und trägt die Klasse *Grenze*. Beanstandet ist in
  INFO-1 die Zeitform **eines** Partizips, nicht die Klasse des Kommentars.
- **Kein Satz bricht ab.** Die Excision hat kein Fragment hinterlassen: der Aufzählungspunkt endet
  auf `("Fence-Blindheit");` und reiht sich in die Interpunktion der drei übrigen Punkte ein
  (`;`, `;`, `;`, `.`). Der Umbruch nach *„sicher ist.\*\* Ein"* auf `:975` ist ein kurzer
  Zeilenrest, kein abgebrochener Satz — der Satz läuft auf `:976` weiter und ist vollständig.
  (Das ist der HIGH-Anker *„bricht mitten im Satz ab, weil eine Teilersetzung den Rest stehen
  ließ"* aus dem Reviewer-Skill; er greift hier nicht.)
- **Der Amend war eine reine Message-Änderung.** Der Baum beider Fassungen ist byte-gleich:
  `git rev-parse 901ca1de^{tree}` und `git rev-parse a5edef75^{tree}` liefern beide
  `319694d5c25cfedeaaa81f438af82772a4ad9369`; der Message-Diff besteht aus genau den zwei
  nachgetragenen Trailer-Zeilen. Beide Fassungen liegen vor `origin/main` (`voraus 1`), der Amend
  war also pre-push und hat keine veröffentlichte Historie umgeschrieben.
- **Commit-Message formal in Ordnung.** `Rolle Implementer:`-Präfix mit Slice-Bezug in der
  Betreffzeile; zwei Requirement-Kennungen (`LH-FA-02`, `LH-FA-09`,
  [`AGENTS.md`](../../AGENTS.md) §5 verlangt mindestens eine); `Co-Authored-By:` und
  `Claude-Session:` vorhanden. Die Kennungen stehen **bare** statt als Link oder Inline-Code, was
  §5 wörtlich nahelegt — das ist in diesem Slice durchgängig so
  (`151e39bf`, `f81f4652`, `3663888b`, `a5edef75` alle bare) und nicht von diesem Commit
  eingeführt; ich melde es nicht als Finding, sondern nenne es, weil der Auftrag danach fragt.
  Der Message-Rumpf beschreibt die Entscheidung und ihren Grund, nicht die Chronik der Runden —
  dass er die Review-Runde nennt, ist in einer Commit-Message zulässig (§3.7 bindet Kommentare
  und Zustandsfelder, nicht `git`-Historie).
- **[`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 eingehalten.** Der Commit berührt **eine** Datei:
  keine `AGENTS.md`, kein `harness/conventions.md`, keine ADR, kein Slice-Plan, keine
  Closure-Notiz, kein Register-Beleg, nichts unter `.harness/baseline/`. Der Slice-Plan ist
  unverändert — der Abschluss bleibt Planner-Arbeit.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Toolchain-Aufruf im Diff. Dieser
  Review hat `make comment-claims` gefahren (`57 Datei(en) geprueft, 0 Befund(e)`) und den bereits
  von `make host-bin` erzeugten Träger benutzt; alles Übrige ist `git`, `grep`, `awk`, `find`,
  `sed`, `diff`. Keine Go-, `pip`-, `npm`- oder Paketmanager-Aufrufe.
- **[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  — der Gate-Stempel deckt genau diesen Baum** (beide Hashes oben identisch).
- **Der Emit ist unverändert**, und die Rücknahme-Bedingung des Slice-Plans §4 (*„ein entfernter
  Kommentar hält tragenden Inhalt"*) bleibt unerfüllt: über dem frisch emittierten Baum
  0 Fence-Bindungen, und der einzige verbliebene `<!--`-Treffer ist das erwartete Zitat.
- **Runde-6-INFO-1 („notwendige Bedingung") besteht unverändert** und ist nicht neu gezählt: der
  Satz ist über den Tausch erhalten (nur neu umbrochen). Runde-6-INFO-2 ist Closure-Material und
  kein Prüfgegenstand dieser Runde.

**Aus früheren Runden unverändert offen** (nicht neu gezählt): die `test/mutations/`-Lücke für
`backtickSpanPattern`, `unmaskQuotedCommentSyntax` und die Marker-Form; die
`strings.Contains`-Klassifikation im Integrations-Wächter; der vorformulierte Risiko-Ausgang §6 des
Slice-Plans (Planner-Sache); Runde-4-MEDIUM-1/-2 (bewusst offen, entschieden).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 0 | — |
| LOW | 1 | `Deckungs-Bilanz-nennt-eine-von-zwei-Luecken` |
| INFO | 1 | `Kommentar-behauptet-einen-Pruefvorgang-statt-einen-Zustand` |

**Kein Beleg für den Zähler aus dieser Runde.** Beide Befunde sind LOW/INFO und beschreiben keine
nicht haltende Deckungs-Zusage; die Klasse
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
ist mit dieser Runde **nicht** erneut getroffen — der Kommentar nennt an der strittigen Stelle
keinen Sensor mehr, sondern die Abwesenheit eines solchen. Ob `slice-140` insgesamt einen Beleg an
diese Klasse abgibt, entscheidet die Closure aus dem Runde-6-Befund heraus, nicht dieser Report
([`AGENTS.md`](../../AGENTS.md) §3.10); ein Vorgang zählt einmal.

**Eine Falle im Auftrag dieser Runde, benannt wie verlangt.** Der Prüfauftrag nennt den zu
prüfenden Satz und fragt, ob er hält — und dieser Satz stammt wörtlich aus dem Verdikt von
Runde 6. Der Review-Strang prüft hier also seine eigene Vorgabe. Das ist dieselbe Konstellation
wie Runde-6-INFO-2, nur eine Stufe weiter: Dort hatte ein Reviewer eine Reparatur verordnet, deren
Artefakt er nicht gemessen hatte; hier hätte ein Reviewer eine Formulierung bestätigen können,
weil sie von ihm selbst stammt. Der einzige Ausweg ist, die Eigenschaft **unabhängig** zu messen
statt die Formulierung zu vergleichen — das ist der Grund für den kalibrierten Scanner oben, und
er hat mit INFO-1 auch prompt eine Ungenauigkeit in der vorgeschriebenen Formulierung gefunden.
Die zweite Falle im Auftrag ist die Ansage *„wahrscheinlich die letzte"*: Sie ist kein Argument
für ein Grün, und ich habe sie nicht als eines behandelt — die drei Fragen sind einzeln gemessen
worden, jede mit eigenem Kommando.

## Verdikt

**Blockierender Befund: nein.**

**Was diese Runde bestätigt.** Alle drei Auftragsfragen sind mit *ja* beantwortet, jede durch eine
eigene Messung. (1) Der Zähl-Beleg für *Fence-Blindheit* ist ersatzlos verschwunden — im
Aufzählungspunkt wie im Proben-Block —, und keine der sechs verbliebenen `Zaehl`/`Oeffner`/
`Schliesser`-Stellen der Datei kann als sein Rest gelesen werden. (2) Der Commit hat **keine**
nicht haltende Zusage eingesetzt: Die beiden neuen Behauptungen — *keine Probe in diesem Block*
und *nicht an einem Kommando* — halten beide, und die zweite habe ich an der Stelle geprüft, an
der sie hätte brechen können (der Mermaid-Fence in `templates_test.go:604` ist ein
Maskierungs-Fall, kein Fence-Blindheits-Fall; die Fixture trägt überhaupt keine Fence). (3) Der
Diff ist kommentar-only, auf vier unabhängigen Wegen mit eigenem Filter geprüft. Dazu: der Amend
war nachweislich eine reine Message-Änderung an einem byte-gleichen Baum und lag vor dem Push.

**Warum nach sechs blockierenden Runden hier keine siebte folgt.** Die Klasse, die dreimal in
Folge durchgerutscht ist, ist *eine Deckung behaupten, die nicht deckt*. Dieser Commit behauptet
an der strittigen Stelle **gar keine** Deckung mehr, sondern gesteht ihr Fehlen ein — das ist der
Weg, den [`AGENTS.md`](../../AGENTS.md) §3.6 ausdrücklich offen lässt, und er ist damit nicht mehr
auf dieselbe Weise brechbar. Die zwei verbliebenen Befunde sind von anderer Art: INFO-1
beanstandet die **Zeitform** eines Partizips in einem Satz, dessen Inhalt ich unabhängig als wahr
gemessen habe; LOW-1 ist eine **pre-existierende**, byte-gleich durch den Tausch getragene
Ungenauigkeit einer Bilanz-Zeile. Keiner der beiden setzt einen Leser in falsche Sicherheit,
keiner betrifft Code, Gate oder Emit. Nach der Blockier-Schwelle dieses Auftrags — und nach der
Reviewer-Skill-Regel, dass HIGH und MEDIUM *typischerweise* blockieren — sind sie
Closure-Material, kein Merge-Hindernis.

**Reif für den Verifier: ja.** Code, Gate-Lage und Emit sind es seit Runde 4 unverändert; der
Gate-Stempel deckt genau diesen Baum; der Arbeitsbaum ist sauber. Was offen bleibt, sind zwei
Kommentar-Formulierungen, die ein späterer Lauf beim Anfassen dieser Stelle nachziehen kann — und
zwei Steering-Loop-Punkte für die Closure: der aus Runde-6-INFO-2 (eine Reparatur-Vorgabe ohne
Messung ihres Artefakts) und, als sein Gegenstück, die Beobachtung dieser Runde, dass die
vorgeschriebene Ersatz-Formulierung selbst eine Ungenauigkeit trug. Beides gehört in den
Lerneintrag, nicht in einen achten Report.
