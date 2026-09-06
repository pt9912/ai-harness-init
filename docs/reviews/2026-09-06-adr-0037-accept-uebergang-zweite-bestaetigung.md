# Zweite Bestätigungsprüfung — ADR-0037 vor dem `Accepted`-Übergang

**Rolle:** Reviewer · **Datum:** 2026-09-06 · **Skill:** `reviewer.md` 1.7.0
**Art:** Bestätigungsprüfung, **keine** Runde 8 — Prüfgegenstand ist der Nacharbeits-Commit zu den
zwei MEDIUM der Vorrunde und erneut die Frage, ob der Übergang selbst eine Aussage der Datei
umstößt.

## Kopf-Metadaten

- **Prüfgegenstand:** `bb4fdfe0` gegen `f5bcd08b` (`git diff f5bcd08b bb4fdfe0`), Gegenstand
  `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`, Status `Proposed`.
- **Vorrunde:** `2026-09-06-adr-0037-accept-uebergang-selbstbezug-bestaetigung.md`
  (0 HIGH · 2 MEDIUM · 1 LOW · 1 INFO).
- **Auftrag:** M-1 (Katalog raus, Eigenschaft rein — trägt das Kriterium die vier zuvor nicht
  klassifizierten Ziele wirklich, und ist die Fundmenge erschöpft) · M-2 (Fundmenge über das
  Subjekt — erfasst die Definition die gemessene Instanz, und macht sie eine Klasse auf, die sie
  nicht schließt) · L-1 und INFO-1 kurz · die fünf Auflagen als Folgepflicht 5 · die Ziel-Menge
  14 → 16 · der Übergangs-Test erneut · das Verdikt · die offene `Bezug`-Frage zu ADR-0024.
- **Eingangs-Kontext (Skill §Eingangs-Kontext):** Diff/Commit-Range ✓ · Hard Rules
  (AGENTS.md §3.4/§3.5/§3.6/§3.7/§3.9/§3.10/§3.11) ✓ · referenzierte aktive ADRs (ADR-0005,
  ADR-0006, ADR-0007, ADR-0016, ADR-0024, ADR-0027, ADR-0030, ADR-0034) ✓ · `LH-*` (LH-FA-01,
  LH-FA-02, LH-FA-03, LH-QA-01, LH-QA-02) ✓ · `MR-*` (MR-000, MR-025, MR-045, MR-046, MR-051) ✓ ·
  vorherige Findings am gleichen Modul (Runden 1–7, die verengte Nachprüfung, die
  Bestätigungsprüfung) ✓. **Nicht erhalten und hier benannt:** der Slice-Plan `slice-190`; die
  Aussagen der Datei über ihn liegen außerhalb meines Auftrags.
- **Nicht mein Gegenstand:** die inhaltlichen Festlegungen 1–4 (neun Läufe ohne Befund gegen die
  Entscheidung) und die DoD-/Gate-Abhakung (Verifier).
- **Umgebung:** `git`, `grep`, `sed`, `awk` über Kopien **außerhalb** des Arbeitsbaums; keine
  Host-Toolchain (AGENTS.md §3.9). Der Arbeitsbaum blieb während der Messung unangetastet.
  `grep` ist hier `ugrep 7.8.4` — das ist unten an einer Stelle tragend.

## Der Übergangs-Test, erneut gefahren

Aufbau wie in der Vorrunde: Kopie des Ist-Stands außerhalb des Arbeitsbaums,
`**Status:** Proposed` → `Accepted`, und je eine der zwei realen `Accepted`-Zeilen des Bestands
(ADR-0028 bzw. ADR-0036) als letzte Zeile der Geschichte-Tabelle angehängt.

```sh
S=<scratch>; D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
cp "$D" "$S/ist.md"
grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0028-*.md > "$S/acc28.txt"
grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0036-*.md > "$S/acc36.txt"
LAST=$(grep -n '^| 2026-09-06 |' "$S/ist.md" | tail -1 | cut -d: -f1)
for v in 28 36; do
  awk -v acc="$(cat $S/acc$v.txt)" -v L="$LAST" \
      'NR==3{print "**Status:** Accepted"; next} {print} NR==L{print acc}' \
      "$S/ist.md" > "$S/sim$v.md"
done
```

Alle sieben Sonden der Datei über die drei Stände:

| Sonde | ist | + `Accepted` (0028) | + `Accepted` (0036) |
|---|---|---|---|
| Beleg-Form `grep -cE 'Baseline .v6\.0\.0.,'` | 11 | 11 | 11 |
| roher Link-Kopf `grep -oE '[]][(]' \| wc -l` | 127 | 131 | 131 |
| Ziel-Muster zeilenweise `grep -oE '\]\([^)]+\)' \| wc -l` | 127 | 131 | 131 |
| dasselbe umbruch-sicher über `tr '\n' ' '` | 127 | 131 | 131 |
| Ziel-Menge über den **Pfad** (`… \| sort -u`) | 16 | 17 | 18 |
| Ziel-Menge über die **Zeichenkette** (`… \| sort -u`) | 30 | 31 | 32 |
| tag-gepinnte Nennungen (`sed -E 's/\]\([^)]*\)//g' \| grep -oE …`) | 19 | 19 | 19 |

**Keine Erwartungswerte** (MR-025 Setzung 2) — die Werte stehen als Beleg der **Bewegung**, nicht
als Zielwert. Zu keiner der sieben steht in der Datei noch ein eingefrorener Wert; es steht das
Kommando. Die drei Zählungen, deren **Gleichheit** die Zeile als tragend ausweist, sind in jedem
der drei Stände gleich.

**Ergebnis am Text der Datei: keine ihrer Aussagen über sich selbst wird durch den Übergang
falsch.** Die Erschöpfungs-Aussage hält in beiden Varianten — die neu hinzukommenden Ziele sind
`0030-eingefrorene-adresse-auf-den-planning-lifecycle.md` (Variante 0028) sowie
`0018-ziel-fassung-regiert-die-migration.md` und
`0031-regierende-fassung-und-ort-der-zielstand-setzung.md` (Variante 0036), alle drei
ADR-Geschwister, die kein Prozess bewegt.

**Der Test greift jedoch zu kurz, wenn er allein an dieser Datei läuft.** Der annehmende Lauf
schreibt nach Folgepflicht 5 **zwei** Dateien in **einem** Commit. Erst die Simulation, die den
Index-Nachzug mitfährt, trifft den Fall — siehe M-1.

## Findings

### M-1 — Folgepflicht 5 behauptet einen Stand des ADR-Index, den derselbe Commit aufhebt

- **kategorie:** MEDIUM
- **quelle:** AGENTS.md §3.4, MR-025 Setzung 2, ADR-0024
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:727-728`
- **befund:** Der Schlusssatz der neuen Folgepflicht 5 lautet: *„Dazu, außerhalb dieser Datei: Der
  ADR-Index (`README.md`) **führt `Proposed`** und wird beim Übergang nachgezogen — nach ADR-0024
  gehört das derivative Register der Rolle seines Originals, der Nachzug liegt also im selben
  Architect-Commit."* Die erste Hälfte ist eine Präsens-Behauptung über den Stand des ADR-Index;
  die zweite verpflichtet denselben Lauf, genau diesen Stand zu ändern, und zwar **im selben
  Commit**. Der Satz steht in §Konsequenzen, nicht in der Geschichte-Tabelle, und trägt weder
  Datum noch Messung. Im Moment des Einfrierens (AGENTS.md §3.4) ist er falsch.

  ```sh
  I=docs/plan/adr/README.md
  awk -F'|' '/\[ADR-0037\]/{gsub(/^ +| +$/,"",$4); print $4}' "$I"          # Proposed
  # den vorgeschriebenen Nachzug simulieren, an einer Kopie ausserhalb des Baums
  awk -F'|' -v OFS='|' '/\[ADR-0037\]/{sub(/ Proposed /," Accepted ",$4)} {print}' "$I" \
    > "$S/index-nach.md"
  awk -F'|' '/\[ADR-0037\]/{gsub(/^ +| +$/,"",$4); print $4}' "$S/index-nach.md"   # Accepted
  grep -c 'führt `Proposed`' "$S/sim28.md"                                          # 1
  ```

  **Keine Erwartungswerte.** Bestritten ist nicht die Auflage — der Nachzug ist richtig und die
  Rollen-Zuweisung nach ADR-0024 trägt. Bestritten ist die **Zustandsbehauptung** daneben: Sie
  überlebt den Vorgang, den sie anordnet, um genau null Commits.

  Der Wortlaut stammt aus dem Verdikt-Block der Vorrunde (*„`docs/plan/adr/README.md` führt
  `Proposed`"*). Dort trägt er: Ein Review-Report ist Chronik von Beruf und durch sein eigenes
  Datum gebunden. In einem einfrierenden Artefakt trägt er nicht — das ist derselbe Übergang, für
  den die Zeile darüber die Trennlinie *Subjekt = benannter abgeschlossener Vorgang gegen Subjekt =
  laufender Bestand* gerade erst gezogen hat, nur mit einem **fremden** Gegenstand statt der Datei.
- **verifizierbar:** ja für die Messung (der Block oben); **nein** als Gate — kein Modul der
  `.d-check.yml` hält den Status-Satz einer ADR gegen die Statusspalte des Index
  (`grep -n '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans, planning`);
  `matrix` liest die Statusspalte nur, um Verweise auf `superseded`/`deprecated` zu verbieten.
- **klasse:** Aussage über den Stand eines fremden Artefakts, die der eigene Vorgang aufhebt
- **warum blockierend:** Das `Proposed`-Fenster ist die letzte Gelegenheit; nach dem Übergang ist
  der Satz durch AGENTS.md §3.4 unerreichbar und die Korrektur kostet eine Folge-ADR. Es ist
  derselbe Kosten-Grund, mit dem ADR-0016 Festlegung 3 (a) die Beleg-Form vor den Übergang legt,
  und dieselbe Bauform, die M-2 der Vorrunde blockierte — nur eine Ebene weiter, weil der
  Prüfgegenstand jetzt zwei Dateien in einem Commit umfasst.

### L-1 — Auflage 3 nennt zwei Bäume, während die Aussage, die sie schützt, an der Eigenschaft hängt

- **kategorie:** LOW
- **quelle:** AGENTS.md §3.11, ADR-0027 Festlegung 3, MR-045/MR-046
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:720-724`
- **befund:** Auflage 3 lautet *„Kein Markdown-Link in den Planning-Lifecycle und keiner nach
  `docs/reviews`"* und begründet das mit *„Beide Bäume bewegt der Prozess"*. Sie ist damit ein
  Katalog aus zwei Bäumen — dieselbe Bauform, die die Erschöpfungs-Aussage drei Zeilen weiter
  gerade abgelegt hat und die AGENTS.md §3.11 in dem dort zitierten Satz verwirft. Zwei weitere
  bewegliche Bäume fehlen: die **Carveout-Ablage** (`docs/plan/carveouts/` → `done/`), die §3.11
  als **erste** der vier von ihr verallgemeinerten Entscheidungen führt, und die **Eintragsdateien
  des Adaptions-Blocks** (`harness/conventions/` → `conventions/done/`, MR-045/MR-046). Ein
  `Accepted`-Zeilen-Link dorthin hielte Auflage 3 dem Wortlaut nach ein und ließe die Aussage
  *„kein Ziel darin bewegt der Prozess"* trotzdem eingefroren falsch werden. Der Fall ist im
  Bestand realisiert, nicht konstruiert: zwei ADR-`Accepted`-Zeilen verlinken eine Carveout-Datei,
  und eine davon ist bereits tot.

  ```sh
  grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/[0-9]*.md \
    | grep -oE '\]\([^)]*(carveouts|harness/conventions/)[^)]*\)' | sort | uniq -c
  # 1 ](../carveouts/CO-002-token-achse-je-rolle.md)
  # 1 ](../carveouts/CO-005-adaptions-block-datierter-beleg.md)
  ls -d docs/plan/carveouts/done/ harness/conventions/done/
  ls docs/plan/carveouts/done/ | grep -c '^CO-005'                                  # 1
  ```

  **Keine Erwartungswerte.** `CO-005` liegt inzwischen in `done/`; die Adresse in der
  eingefrorenen `Accepted`-Zeile von ADR-0026 ist damit tot und kostet ein namentlich
  geschnittenes `ignore-refs`-Paar mit eigener ADR (`grep -c '^  - in: ' .d-check.yml`).
- **verifizierbar:** ja für die Messung; nein als Gate — kein Modul liest die Reichweite einer
  Prosa-Auflage.
- **klasse:** das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat
- **nicht blockierend:** Die Auflage nennt in **demselben Satz** AGENTS.md §3.11 als ihren Grund,
  und §3.11 bindet als Hard Rule unabhängig von ihr und eigenschaftsbasiert. Anders als bei M-1
  ist hier kein Satz nach dem Übergang falsch, sondern nur eine Erinnerung enger als ihr Grund —
  und sie ist mit dem annehmenden Lauf verbraucht.

### INFO-1 — das Prüfinstrument des Commits ist enger als die Definition, die derselbe Commit einführt

- **kategorie:** INFO
- **quelle:** AGENTS.md §3.6
- **pfad:** Commit-Message `bb4fdfe0`; Wirkung in
  `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:715` und `:791`
- **befund:** Die Commit-Message belegt *„Keine neue selbstbezuegliche Zahl eingefuehrt"* mit
  `git diff --word-diff=plain --unified=0 "$D" | grep -oE '\{\+[^}]*\+\}' | grep -cE '→ \*\*[0-9]'`
  → 0. Das Muster `→ **N**` fängt die Beleg-Form der Rumpf-Blöcke, nicht die Definition, die
  derselbe Commit setzt (*Subjekt statt Zahlwert*, *mit Zahl wie ohne*). Zwei neu eingefügte Sätze
  zählen Bestandteile dieser Datei und passieren das Instrument: *„**Fünf** Auflagen binden den
  Übergang nach `Accepted`"* (Folgepflicht 5) und *„**Die fünf Auflagen** … stehen jetzt in der
  Datei"* (Geschichte-Zeile).

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  sed -n '/Folgepflicht 5 (der annehmende Lauf)/,/^$/p' "$D" \
    | tr '\n' ' ' | tr -s ' ' | grep -oE '\([1-9]\) \*\*' | wc -l                   # 5
  grep -c 'Fünf Auflagen binden den Übergang' "$D"                                  # 1
  ```

  **Keine Erwartungswerte.** Beide Sätze sind **wahr** und nach §3.4 stabil — die Zahl kann nicht
  driften, weil der Block nicht mehr geändert wird —, und die Form ist im Dokument etabliert
  (*„Vier Festlegungen."* im Entscheidungs-Satz steht seit Runde 1). Der Befund gilt dem
  Instrument, nicht den Sätzen: Es belegt eine engere Aussage als die, die daneben behauptet wird.
- **verifizierbar:** nein.
- **klasse:** Beleg-Kommando misst enger als die Aussage, die es stützen soll

### INFO-2 — vier der fünf eingefrorenen Selbstbezugs-Urteile haben eine Auflage, das fünfte nicht

- **kategorie:** INFO
- **quelle:** ADR-0016 Festlegung 1 und 2, LH-QA-01
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:788`
- **befund:** Die Datei behält fünf Urteile, deren Wahrheit am eigenen Bestand hängt: die
  Erschöpfungs-Aussage (Auflage 3), die Gleichheit der drei Zählungen (Auflage 4), die
  Instrument-Freiheit der zwei Sonden (Auflage 5), die Link-Freiheit gegenüber dem vendored Baum
  (Auflage 1) — und als fünftes *„die tag-gepinnten Nennungen … **sind Operanden der Kommandos** …,
  nicht Adressen eines Belegs"*. Für das fünfte steht keine Auflage; eine tag-gepinnte
  Baseline-Pfad-Nennung in **Prosa** wäre kein Markdown-Link und verstieße gegen keine der fünf,
  machte den Satz aber falsch. Gemessen ist die Lage am Ist-Stand und in beiden Simulationen
  unverändert:

  ```sh
  awk '/^[[:space:]]*```/{f=!f; next} {print (f?"IN":"OUT")"\t"$0}' "$D" \
    | grep '\.harness/baseline/v[0-9]' | cut -f1 | sort | uniq -c            # 19 IN
  grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/[0-9]*.md \
    | grep -c '\.harness/baseline'                                           # 2
  ```

  **Keine Erwartungswerte.** Die zwei Vorkommen im Bestand sind selbst Kommando-Operanden in
  Inline-Code, nicht Beleg-Adressen — die Lücke ist benannt, nicht realisiert, und sie wird von
  ADR-0016 Festlegung 2 (*„Nicht dazu gehören der lokale Präfix …"*) unabhängig gedeckt.
- **verifizierbar:** ja für die Messung; nein als Gate.
- **klasse:** eine Zusage ohne Wächter, benannt statt geschlossen

## Negativbefunde

- **M-1 der Vorrunde (Katalog raus, Eigenschaft rein) — behoben, und die Fundmenge ist
  erschöpft.** Die Aussage lautet jetzt *„Über die **Pfad**-Menge läuft die Einzelprüfung, Ziel für
  Ziel, und **kein** Ziel darin bewegt der Prozess … Gefragt wird deshalb je Ziel, ob der Prozess
  seinen Ort bewegt; dafür braucht die Prüfung weder die Mächtigkeit der Menge noch ihre Klassen."*
  Das ist eine All-Aussage über die vom Kommando gelieferte Menge samt geschriebenem
  Auswertungs-Verfahren — die vier zuvor unklassifizierten Ziele (`AGENTS.md`,
  `harness/conventions.md`, `spec/architecture.md`, `spec/lastenheft.md`,
  `docs/user/benutzerhandbuch.md`) sind damit **erfasst**, nicht bloß nicht mehr erwähnt: Es gibt
  keine Klassen-Liste mehr, aus der sie herausfallen könnten. Die Wiederholung eine Zeile später
  ist ebenfalls gezogen; ein drittes Vorkommen gibt es nicht.

  ```sh
  grep -c 'ADR-Geschwister liegen flach' "$D"                                       # 0
  grep -c 'Links in den Planning-Lifecycle und nach `docs/reviews/\*\*` trägt' "$D"  # 0
  grep -oE 'Aufzählung der Ziel-Klassen' "$D" | wc -l                               # 2
  ```

  **Keine Erwartungswerte.** Die zwei verbliebenen Treffer sind die **Verneinungen** (*„nicht von
  einer Aufzählung der Ziel-Klassen"*, *„nicht an einer Aufzählung der Ziel-Klassen"*), nicht der
  Katalog.
- **Die Ziel-Menge 14 → 16 — beide neuen Ziele einzeln gegen die Wander-Frage gehalten, und zwar am
  Werkzeug, nicht am Wortlaut.** Neu sind
  `0024-derivatives-register-gehoert-der-rolle-seines-originals.md` (ADR-Geschwister, flach) und
  `README.md` (der ADR-Index, `docs/plan/adr/README.md`). Kein Werkzeug dieses Repos bewegt etwas
  unter `docs/plan/adr/`: `internal/archive/collect.go` sammelt `docs/plan/planning` und
  `docs/reviews` (`grep -n 'planningDir\|reviewsDir' internal/archive/collect.go`) und liest ADRs
  nur, um in Stubs zu verlinken; `harness/tools/slice-mv.sh` bewegt Slice-Pläne innerhalb des
  Lifecycle. Damit gilt das Urteil für alle 16.
- **M-2 der Vorrunde (Fundmenge über das Subjekt) — die gemessene Instanz ist erfasst.** Die
  Sonden-Aussage trägt jetzt einen benannten abgeschlossenen Vorgang als Subjekt (*„Die
  Bestätigungsprüfung `…-selbstbezug-bestaetigung.md` hat den Übergang an Kopien simuliert … und
  belegt, dass ein Teil der Sonden-Werte dabei wandert und ein Teil stillsteht"*) und lässt offen,
  **welcher** Teil. Gegen die Vorrunde gehalten stimmt der Beleg: dort wanderten fünf der sieben
  Werte, zwei standen still.
- **Die neue Definition macht eine weitere Klasse auf — sie sagt das selbst und schließt sie nicht,
  und keine ihrer Instanzen wird durch den Übergang falsch.** Unter *Subjekt = die Datei* fallen
  neben den gezogenen weiterhin: *„Die Datei trug **einen** Markdown-Link …"* (Perfekt über einen
  abgelösten Stand), *„ein weiteres Vorkommen der Form, die diese Datei durchgängig führt"*,
  *„kein Ziel darin bewegt der Prozess"*, *„Beide Sonden sind so geschrieben, dass ihr eigener
  Abdruck sie nicht trifft"*, *„Sie benennt **vier** Stellen …"* (Festlegung 4). Ich habe jede
  gegen beide Simulationen gehalten; keine kippt. Die Zeile beansprucht dafür auch keine
  Vollständigkeit (*„Ein Vollständigkeits-Anspruch entsteht hier nicht"*) — die Klasse ist offen
  und ehrlich als offen ausgewiesen.
- **L-1 der Vorrunde — behoben.** Der Halbsatz lautet jetzt *„`link-policy: always` macht jede
  Kennung, **für die `.d-check.yml` ein Muster führt**, zum Link — nicht jede Kennung, die die
  Zeile nennt"* und trägt das zählende Kommando. Es reproduziert, und die drei Muster sind
  `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`, `MR-\d{3}` — die Slice-Kennung ist keines, womit mein
  Gegenbeispiel (`slice-145` unverlinkt in der `Accepted`-Zeile von ADR-0028, `docs-check` grün)
  jetzt zur Aussage passt.

  ```sh
  awk '/^ids:/,/^matrix:/' .d-check.yml | grep -c 'link-policy: always'             # 3
  ```

- **INFO-1 der Vorrunde — behoben.** Der Satz über den ersten der zwei MR-025-Wege ist auf *„Für
  eine Aussage über die Datei selbst"* eingeschränkt, und der Gegenfall steht ausdrücklich daneben
  (*„Für einen **fremden** Gegenstand … bleibt er der Weg, den die Setzung gibt"*). Die fünf
  Stellen, die ihn für fremde Gegenstände weiter benutzen, sind damit gedeckt statt implizit für
  defekt erklärt. Beide MR-025-Zitate der Zeile sind umbruch-sicher verbatim gegen
  `harness/conventions/MR-025-…md` geprüft.
- **Die fünf Auflagen — vollständig, nummeriert, auflösbar, und der Übergang kann sie einhalten.**
  Sie decken (1) den Baseline-Link, (2) neue Selbstbezugs-Aussagen, (3) Lifecycle-/Reviews-Links,
  (4) `)` im Ziel und Umbruch-Links, (5) die rohe Link-Kopf-Sequenz im Code-Span, dazu den
  Index-Nachzug. Gegen die zwei realen `Accepted`-Zeilen gemessen hält jede: keine der beiden
  bringt einen Baseline-Link (0 in ist, sim28, sim36), keine einen Lifecycle- oder Reviews-Link
  (0/0/0), beide lassen die drei Zählungen gleich, und der Link-Kopf steht in keinem Code-Fence und
  in keinem Inline-Span.

  ```sh
  for f in ist.md sim28.md sim36.md; do
    printf '%s baselinelinks=%s fences=%s spans=%s\n' "$f" \
      "$(grep -oE '\]\([^)]*\.harness/baseline[^)]*\)' $f | wc -l)" \
      "$(awk '/^[[:space:]]*```/{f=!f; next}  f' $f | grep -oE '\]\(' | wc -l)" \
      "$(awk '/^[[:space:]]*```/{f=!f; next} !f' $f | grep -oE '`[^`]+`' | grep -oE '\]\(' | wc -l)"
  done
  # ist.md baselinelinks=0 fences=0 spans=0
  # sim28.md baselinelinks=0 fences=0 spans=0
  # sim36.md baselinelinks=0 fences=0 spans=0
  ```

- **Eigenkorrektur: das Instrument der Vorrunde lief nicht.** Der Negativbefund *„Selbst erzeugte
  Abdrücke"* der Bestätigungsprüfung druckte `… | grep -c '\]\('` und wies **0** aus. Dieses
  Kommando ist ein **Basic**-Regex mit unbalancierter Gruppe und bricht ab
  (`ugrep: error … mismatched ( )`, Exit 2) — die Null stammt aus einer leeren Ausgabe, nicht aus
  einer Messung (AGENTS.md §3.6, *Rot heißt Meldung lesen*). Die korrigierte ERE-Form
  (`grep -oE '\]\(' | wc -l`) liefert dasselbe Ergebnis **0**, für alle drei Stände; das Urteil der
  Vorrunde bleibt, sein Beleg war defekt. Ich führe das hier, weil ein Nachfolgelauf sonst ein
  Kommando abschriebe, das nicht läuft.
- **Zitattreue.** Das AGENTS.md-§3.11-Zitat der neuen Aussage ist verbatim gegen `AGENTS.md:432`
  geprüft; die weggelassene Kursiv-Auszeichnung um *wandert auf Anweisung* deckt ADR-0016
  Festlegung 2 ausdrücklich (*„der Wortlaut ohne Auszeichnung, Whitespace normalisiert"*).
- **Umfang des Commits.** `git show --pretty=format: --name-only bb4fdfe0` nennt allein die ADR;
  zwei Hunks, 20 Einfügungen / 2 Löschungen. Der Wort-Diff bewegt außerhalb der zwei Klassen und
  der neuen Folgepflicht 5 keinen Satz. Status (`Proposed`, Zeile 3) und ADR-Index sind
  unverändert.
- **ADR-0016 Festlegung 3 (a) — am Ist-Stand weiter erfüllt.** 0 Markdown-Links in den vendored
  Baum; alle 19 tag-gepinnten Nennungen liegen in Code-Fences (Fence-Erkennung mit
  `^[[:space:]]*` gemessen, die naive Form meldet hier 14 falsche „OUT").
- **Nicht geprüft, weil außerhalb des Auftrags:** die Festlegungen 1–4 selbst, die Aussagen der
  Datei über `slice-190`, die Belegform der übrigen Baseline-Aussagen (Runde 7) und die
  DoD-/Gate-Konformität (Verifier).

## Die offene `Bezug`-Frage — entschieden

**Sie hält den Übergang nicht und kann mitreisen.** Drei Gründe, je gemessen.

1. **Keine Quelle verlangt es.** Die vendored ADR-Vorlage führt das Feld als
   *„`[<LH-FA-NN>](…)`, `[<LH-QA-NN>](…)`, `[ADR-<NNNN>](…)` **(optional)**"*; `modul-04-adrs.md`
   §Ziel-Form nennt den Kopf, nicht eine Vollständigkeitspflicht. Kein Modul der `.d-check.yml`
   liest den `Bezug`-Kopf; `matrix` kennt nur die Richtungsregel und das Status-Verbot, und
   ADR-0024 ist `Accepted`.
2. **Es ist die einzige Ausnahme von der Form, die diese Datei sonst durchhält** — deshalb ist der
   Zug sinnvoll, auch wenn er nicht geschuldet ist:

   ```sh
   D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
   awk '/^## Geschichte/{exit} {print}' "$D" | grep -oE '\[ADR-[0-9]{4}\]' | sort -u
   # ADR-0005 ADR-0006 ADR-0007 ADR-0016 ADR-0024 ADR-0034
   awk '/^\*\*Bezug:\*\*/{f=1} f{print} /^\*\*Schärft:\*\*/{exit}' "$D" \
     | grep -oE 'ADR-[0-9]{4}' | sort -u
   # ADR-0005 ADR-0006 ADR-0007 ADR-0016 ADR-0034
   ```

   **Keine Erwartungswerte.** Fünf der sechs außerhalb der Geschichte-Tabelle verlinkten ADRs
   stehen im Kopf; ADR-0024 ist die sechste.
3. **Der Zug ist folgenlos für alles, was der Übergang prüft.** Das Ziel `0024-…md` steht seit
   Folgepflicht 5 ohnehin in der Pfad-Menge; ein weiterer Link erhöht nur die drei Zählungen — und
   zwar alle drei gleich —, führt kein neues Ziel ein und berührt keine Auflage. Der derivative
   Index folgt nach ADR-0024 im selben Architect-Commit, also genau dort, wo Folgepflicht 5 den
   Nachzug ohnehin verortet.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | *Aussage über den Stand eines fremden Artefakts, die der eigene Vorgang aufhebt* (M-1) |
| LOW | 1 | *das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat* (L-1) |
| INFO | 2 | *Beleg-Kommando misst enger als die Aussage* (INFO-1) · *Zusage ohne Wächter, benannt statt geschlossen* (INFO-2) |

**Steering-Loop-Gehalt.** M-1 trägt dieselbe Klasse wie Runde-1-M-4, Runde-4-M-1 und Runde-5-M-1 —
*Aussage über den Stand eines fremden Artefakts* —, diesmal mit einer Verschärfung, die vorher
nicht auftrat: der eigene, in derselben Zeile angeordnete Vorgang hebt sie auf. L-1 trägt die
Klasse, die diese Reihe am häufigsten führt, und sie ist hier **versetzt**: Der Katalog ist aus der
Aussage entfernt und in der Auflage wieder aufgetaucht, die sie schützt. Die Register-Zuordnung
beider Klassen fällt bei der Slice-Closure, nicht hier (AGENTS.md §3.10).

## Verdikt

**Der `Accepted`-Übergang ist noch nicht möglich.** Genau ein Posten blockiert, und er liegt **in
der Wahrheit** — nicht im Argument und nicht im Protokoll.

- **Im Argument** steht nichts offen: Gegen die vier Festlegungen ist in neun Läufen kein Befund
  gefallen, und die zwei blockierenden MEDIUM der Vorrunde sind an ihrer Substanz behoben. Die
  Erschöpfungs-Aussage steht jetzt auf der Eigenschaft und trägt damit auch die vier Ziele, die der
  Katalog übersprang; ihr Ergebnis ist über alle 16 Ziele und am Werkzeug statt am Wortlaut
  geprüft. Der Sweep steht auf dem Subjekt, erfasst die von mir gemessene Instanz und weist die
  Klasse, die er dabei öffnet, ausdrücklich als offen aus — keine ihrer verbliebenen Instanzen
  kippt durch den Übergang.
- **Im Protokoll** steht nichts offen: alle abgedruckten Kommandos reproduzieren, die drei
  Zählungen sind in jedem der drei Stände gleich, kein eingefrorener Selbstbezugs-Wert ist
  geblieben, und die Zitate sind verbatim. Den einen defekten Beleg dieser Reihe habe ich in
  **meinem eigenen** Vorrunden-Report gefunden und oben korrigiert; sein Urteil bleibt.
- **In der Wahrheit** steht der Posten: Folgepflicht 5 behauptet *„Der ADR-Index (`README.md`)
  führt `Proposed`"* und verpflichtet denselben Commit, das zu ändern. Der Satz friert falsch ein.
  Der bisherige Übergangs-Test konnte ihn nicht fangen, weil er allein an dieser Datei lief; er
  fällt erst, wenn man den vorgeschriebenen Index-Nachzug mitsimuliert.

### Auflagen für den annehmenden Lauf

Gültig, sobald M-1 erledigt ist. Ich bestätige die fünf, die jetzt als Folgepflicht 5 in der Datei
stehen — vollständig, nummeriert und vom Übergang einhaltbar, in beiden geprüften Varianten. Dazu:

1. **Auflage 3 gilt für jeden Baum, dessen Ort der Prozess bewegt**, nicht nur für die zwei
   genannten; namentlich auch für `docs/plan/carveouts/` und die Eintragsdateien unter
   `harness/conventions/` (L-1). Getragen ist das von AGENTS.md §3.11, das die Auflage selbst als
   Grund nennt.
2. **Keine tag-gepinnte Baseline-Pfad-Nennung außerhalb eines Kommando-Operanden** (INFO-2) — sonst
   fällt das fünfte der eingefrorenen Selbstbezugs-Urteile, das keine der fünf Auflagen deckt.
3. **Der `Bezug`-Kopf um ADR-0024 und der Index-Nachzug reisen im selben Architect-Commit mit** —
   der Zug ist nicht geschuldet, aber folgenlos und schließt die einzige Ausnahme von der Form, die
   diese Datei sonst durchhält.

**Keine dieser Auflagen hat einen Wächter** — kein Modul der `.d-check.yml` liest sie
(`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt keine Fehlschlag-Form dafür. Träger
ist der Rollen-Wechsel vor dem Übergang.
