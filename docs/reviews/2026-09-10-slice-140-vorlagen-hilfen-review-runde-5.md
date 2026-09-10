# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 5

> Dieser Report spricht über Backtick-Zitate. Jeder Sonden-Eingang und jeder Ausgang steht deshalb
> in einem Code-Block, nie in Inline-Code — sonst zerlegt die eigene Markdown-Syntax den Beleg.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `14732213..f81f4652` — ein Commit, **eine** Datei
  (`git show --stat f81f4652`): `internal/emit/templates.go`, 73 Insertions / 32 Deletions.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) — `Accepted`, normativ.
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) —
  **`Proposed`**, nicht `Accepted`
  (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0035-*.md`, und dieselbe Angabe in
  [`docs/plan/adr/README.md`](../plan/adr/README.md) Zeile 42). Siehe INFO-1.
- **Aktive `MR-*`:**
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.8, §3.9, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md),
  [Runde 2](2026-09-10-slice-140-vorlagen-hilfen-review-runde-2.md),
  [Runde 3](2026-09-10-slice-140-vorlagen-hilfen-review-runde-3.md),
  [Runde 4](2026-09-10-slice-140-vorlagen-hilfen-review-runde-4.md)
  (1 HIGH / 2 MEDIUM / 1 LOW).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen an seinem Lifecycle-Ort
  (`docs/plan/planning/in-progress/`); §2 DoD, §4, §5, §6, §7 unverändert — korrekt, der Abschluss
  ist Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums:** `git status --porcelain` vor diesem Lauf **leer**; `main` zwei Commits vor
`origin/main`.

**Keine Erwartungswerte** — jede Zahl unten steht neben dem Kommando, das sie liefert, und wandert
mit dem Vorlagen-Satz.

## Der Prüfauftrag dieser Runde, und was er ausnimmt

Runde-4-MEDIUM-1 (Doppel-Backtick-Span) und -MEDIUM-2 (zwei Streu-Backticks) sind eine bewusste,
vom Auftraggeber bestätigte Entscheidung und **kein Gegenstand dieses Reports**. Sie werden hier
nicht erneut als Befund geführt. Geprüft ist stattdessen die Frage, die die Entscheidung selbst
aufwirft: *Sind sie ehrlich und auffindbar dokumentiert?* — die Antwort steht in den
Negativbefunden (die Offenheits-Erklärung trägt) und in den zwei Findings (die Deckungs-Zusagen
darüber tragen nicht).

## Findings

### HIGH-1 — Der Fix fügt eine neue, falsche Sensor-Deckungs-Zusage hinzu: drei der vier genannten Beispiel-Fälle haben keinen Testfall

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Ein Test, dessen Name eine Eigenschaft
  behauptet, muss die Eigenschaft messen"* · *„Richtig: die Zusage auf das einschränken, was der
  Code hält"*); Reviewer-Skill-Anker *Verstoß gegen eine Hard Rule*
- **pfad:** `internal/emit/templates.go:971-972`
- **befund:** Der Satz lautet jetzt *„Rot faerbt eine verlorene Wirkung TestStripCommentHints (die
  pure Funktion, inklusive beider Ausnahmen **und der oben genannten Beispiel-Faelle**)"*. Die
  hervorgehobenen sechs Wörter hat **dieser Commit eingefügt** — der Vorstand las
  *„(die pure Funktion, inklusive beider Ausnahmen)"* und war damit richtig
  (`git show f81f4652 -- internal/emit/templates.go | grep -nE '^[+-].*(Beispiel-Faelle|beider Ausnahmen)'`
  → die Zeilen `-176`/`+177`). Der Kommentar nennt `:933-946` **vier** Beispiel-Formen;
  `TestStripCommentHints` (`internal/emit/templates_test.go:578`) trägt zehn Zusicherungen, und
  genau **eine** davon deckt eine dieser vier ab:

  | genannte Beispiel-Form | Zusicherung in `TestStripCommentHints` |
  |---|---|
  | Kommentar über einen Fence mit Mermaid-Pfeil | **keine** — `oeffnerZitat` trägt ein *zitiertes* `` `<!--` ``, keinen echten Kommentar |
  | zeilenübergreifende Zitat-Spanne | `zeilenuebergreifendesZitat` — vorhanden |
  | Backtick-**Lauf** der Länge ≥ 2 um ein Zitat | **keine** |
  | zwei freistehende Backticks um eine echte Hilfe | **keine** — `unpaarigerBacktick` trägt **einen** Streu-Backtick, nicht zwei |

  Die letzten zwei sind Runde-4-MEDIUM-1/-2, also die bewusst **offen gelassenen** Fälle: Der
  Kommentar sagt damit zu, ein Test bewache Verhalten, das dieselbe Runde ausdrücklich ungefixt
  gelassen hat. **Gate-unsichtbar:** `make comment-claims` prüft, ob ein genannter Sensor
  *existiert*, nicht was er deckt ([`harness/README.md`](../../harness/README.md) §Sensors) — der
  Lauf über diesem Baum meldet `57 Datei(en) geprueft, 0 Befund(e)`.
- **verifizierbar:** ja — `awk '/^func TestStripCommentHints/,/^}/' internal/emit/templates_test.go`
  gegen die vier Aufzählungspunkte in `internal/emit/templates.go:933-946`; für drei der vier
  existiert kein Eingang.
- **klasse:** `Zusage-ueber-Sensor-Deckung-weiter-als-der-Sensor` (**fünftes** Auftreten der
  Grenzen-/Deckungs-Zusagen-Klasse in slice-140: Runde 1 MEDIUM-1, Runde 2 MEDIUM-2, Runde 3
  HIGH-1, Runde 4 HIGH-1, jetzt)

### HIGH-2 — Die Proben-Menge deckt zwei der vier genannten Formen nicht, und die Fence-Messung, die es gab, ist von diesem Commit entfernt worden

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  (der Vorlagen-Satz wird beim Re-Baseline vollständig getauscht)
- **pfad:** `internal/emit/templates.go:952-969` (Proben-Block und Re-Baseline-Pflicht); entfernt
  aus `f81f4652^:internal/emit/templates.go:918-920`
- **befund:** `:952-954` sagt, was die Regel gegen den heutigen Satz trage, sei *„eine GEMESSENE
  Abwesenheit **der bekannten Formen** im Text"* — der Rückverweis ist eindeutig, *bekannt* meint
  die vier Aufzählungspunkte `:933-946`. Es folgen **drei** Proben, und ihre Zuordnung ist:
  Doppel-Backtick-Lauf → Proben 1+2; zeilenübergreifende Spanne → Probe 3, aber nur, wo die
  Kommentar-Syntax auf einer Zeile mit **ungerader** Backtick-Zahl landet; **Fence-Blindheit →
  keine Probe**; **zwei Streu-Backticks um eine echte Hilfe → keine Probe** (diese Form ist per
  Konstruktion **gerad**-paarig, Probe 3 meldet die ungeraden). `:963-967` erhebt die drei Proben
  dann zur hinreichenden Bedingung: *„JEDER Re-Baseline … muss sie gegen den NEUEN Satz erneut
  fahren, **bevor diese Regel dem neuen Satz gegenueber als sicher gilt**"*. Ein künftiger Satz,
  in dem ein Kommentar einen Mermaid-Fence überspannt, besteht alle drei Proben und ist **nicht**
  sicher — die Wirkung ist stille Löschung (Runde-4-Sonde F7). **Der Vorstand hatte für genau
  diese Form eine Messung** — *„je Vorlage gemessen per `grep -o '<!--' <datei> | wc -l` gegen
  `grep -o -- '-->' <datei> | wc -l`"* —, und dieser Commit hat sie ersatzlos gestrichen
  (`grep -n "grep -o" internal/emit/templates.go` → keine Fundstelle). Der heutige Satz führt
  Fence-Pfeile in zwei Dateien, die Sicherheit hängt allein an der Reihenfolge Kommentar-vor-Fence
  — also an genau der Eigenschaft, die die gestrichene Messung prüfte.
- **verifizierbar:** ja — die drei Proben im Kommentar gegen die vier Aufzählungspunkte darüber
  halten; zusätzlich der Fence-Bestand:

  ```text
  T=.harness/baseline/v6.5.0/templates
  for f in $(find "$T" -name '*.md') $(find internal/emit/templates -type f); do
    awk -v F="$f" '/^```/{fence=!fence; next} fence && /-->/ {print F":"FNR}' "$f"; done | wc -l
  # 13  Fence-Pfeil-Zeilen in 2 Dateien -- kein Erwartungswert, wandert mit dem Satz
  ```

- **klasse:** `Zusage-ueber-Sensor-Deckung-weiter-als-der-Sensor` (dieselbe Klasse wie HIGH-1;
  siehe Kategorie-Summary zur Zählung)

### INFO-1 — [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf `Proposed` und wird als Autorität zitiert

- **kategorie:** INFO
- **quelle:** Reviewer-Skill-Anker *nur aktive ADRs sind normativ*; [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** Commit-Message `f81f4652`, Absatz 3 (*„der bestehende Beleg (280 Faelle, ADR-0035)
  traegt weiter"*); [Runde-4-Report](2026-09-10-slice-140-vorlagen-hilfen-review-runde-4.md)
  §Eingangs-Kontext führt die ADR als „`Accepted`"
- **befund:** Selbst gelesen ist der Status `Proposed`, in der Datei wie im Index. Operativ folgenlos
  in beide Richtungen: der Übersprung wird in diesem Baum gar nicht in Anspruch genommen (der
  Schlüssel passt nicht, siehe Negativbefunde), und die Fall-Zahl **280** stimmt
  (`ls test/mutations/*.sh | wc -l`). Gemeldet wird die Status-Angabe, nicht die Nutzung —
  dieselbe Angabe reist sonst über die Runden weiter.
- **verifizierbar:** ja — `grep -n '^\*\*Status:\*\*' docs/plan/adr/0035-*.md` → `Proposed`.
- **klasse:** `ADR-Status-in-Rollen-Artefakt-falsch-zitiert`

### INFO-2 — Probe 3 läuft nur über den vendored Satz, Proben 1 und 2 über beide

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `internal/emit/templates.go:956-960`
- **befund:** Probe 1 misst `$T`, Probe 2 misst `internal/emit/templates/` — Probe 3 misst nur `$T`.
  Der eigene Vorlagen-Satz bleibt bei der Paritäts-Achse ungemessen. Selbst nachgefahren ist er
  heute ebenfalls leer, die Asymmetrie ist also folgenlos; benannt, weil ein späterer Leser die
  drei Proben als eine Menge liest.
- **verifizierbar:** ja —
  `find internal/emit/templates -type f -print0 | xargs -0 awk '{ c=gsub(/`/,"`"); if (c%2==1 && ($0 ~ /<!--/ || $0 ~ /-->/)) print FILENAME":"FNR }'`
  → leer.
- **klasse:** `Proben-Menge-ungleich-ueber-die-Bezugsmengen`

## Negativbefunde (geprüft, ohne Befund)

- **Der Diff ist kommentar-only — mit eigenem Filter, nicht nachgelesen.** Zwei unabhängige Wege:
  (1) `git show f81f4652 -- internal/emit/templates.go | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vcE '^[+-]//'`
  → **0** geänderte Nicht-Kommentar-Zeilen. (2) Der Nicht-Kommentar-Rumpf beider Stände ist
  **byte-gleich**: `diff <(git show f81f4652^:internal/emit/templates.go | grep -vE '^\s*//') <(git show f81f4652:internal/emit/templates.go | grep -vE '^\s*//')`
  → leer, Exit 0. (3) Die Gegenprobe zum Raw-String-Einwand: alle vier Hunks liegen zwischen
  Top-Level-Deklarationen (`var backtickSpanPattern`, `func maskQuotedCommentSyntax`,
  `func unmaskQuotedCommentSyntax`), also außerhalb jedes Literals — gelesen, nicht gefolgert.
- **Der Emit ist damit unverändert.** Kein Byte außerhalb von Kommentaren, kein Byte an
  `internal/emit/templates/` oder `.harness/baseline/` — die Byte-Gleichheit des emittierten Baums,
  die Runde 4 an zwei gebauten Trägern gemessen hat, gilt unverändert weiter. Der Slice-Plan §4
  hat damit seine Rücknahme-Bedingung (*„ein entfernter Kommentar hält tragenden Inhalt"*)
  weiterhin nicht erfüllt.
- **Die vier im Kommentar genannten Proben selbst gefahren — alle Ergebnisse stimmen.** Proben
  1, 2, 3 aus `:956-960` und die NUL-Byte-Probe aus `:883-884`: jede leer, wie behauptet. Die
  Zahlen-Aussagen `:911-913` (vier Fundstellen in drei Dateien) sind in Runde 4 nachgemessen und
  von diesem Commit nicht angefasst.
- **Fence-Blindheit ist im heutigen Satz nicht auslösbar — selbst gemessen.** In beiden Dateien mit
  Fence-Pfeilen schließt jeder Kommentar vor dem nächsten Fence:
  `spec/architecture.template.md` (32→38, 73→81, 102→106, 114→117, 134 einzeilig; Fences 40-56 und
  121-130) und `docs/plan/planning/roadmap.template.md` (25→45, 64→73, 116→123; Fence 87-98).
  Die Aussage der **gestrichenen** Messung gilt also heute noch — HIGH-2 beanstandet ihren
  Wegfall, nicht ihr Ergebnis.
- **Die Offenheits-Erklärung selbst trägt.** `:927-931` sagt wörtlich *„die Menge der Faelle …
  ist nicht geschlossen und wird hier nicht als geschlossen behauptet"*, `:930-931` führt die vier
  Formen als *„BEISPIELE, nicht als vollstaendige Liste"*, `:948-950` doppelt nach:
  *„Jede dieser Formen ist ein GEGENBEISPIEL gegen Vollstaendigkeit, kein Katalog"*. Die
  Gegenprobe über den ganzen Block (`sed -n '805,985p' … | grep -nE 'nie |immer |ausschliesslich|einzig|vollstaendig'`)
  findet **keine** verbliebene Vollständigkeits-Zusicherung über die Lücken-Menge; die drei
  Runde-4-Sätze (*„nie innerhalb eines wohlgeformt zitierten Zeichens"*, *„die einzig moegliche
  [Paarung]"*, *„Zwei Grenzen bleiben ungedeckt"*) sind restlos fort. **Das ist die Hälfte, die
  dieser Commit richtig gemacht hat** — beanstandet sind die zwei Deckungs-Sätze **darüber**,
  nicht die Offenheits-Erklärung.
- **Die verbliebene geschlossene Menge im Block ist die richtige.** `:896` *„Ausgenommen bleiben
  zwei Formen"* spricht über die **Ausnahmen des Codes** (`dcheckIgnoreMarkerPattern` und
  `maskQuotedCommentSyntax`), nicht über die Lücken der Näherung — und der Code hält genau diese
  zwei. Kein Finding.
- **Runde-4-LOW-1 ist als Grenze dokumentiert, mit tragendem Beleg.** `:877-885` benennt die
  `ReplaceAll`-Eigenschaft ausdrücklich (*„Getroffen wird jedes Vorkommen der Platzhalter-Byte-Folge
  im Text, nicht nur die von maskQuotedCommentSyntax gesetzte Fundstelle"*), nennt die
  Auslöse-Bedingung (`\x00\x01`-Präfix), gibt das Kommando in
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)-Form
  und markiert es als wandernd (*„kein Erwartungswert, gilt fuer den jeweils aktuellen Satz"*).
  Selbst nachgefahren: leer. Die Klasse des Kommentars ist **Grenze** nach
  [`AGENTS.md`](../../AGENTS.md) §3.7 — Indikativ über den Zustand, keine Befund-Kennung, keine
  Runden-Nummer, kein Lauf-Protokoll. **Erledigt.**
- **Der `mutate`-Beleg-Slot ist entwertet, und das ist die richtige Mechanik.**
  `cat .harness/state/mutate-passed.key` → `2bff167a…`, der Schlüssel über dem heutigen Baum
  (`bash -c 'REPO="$PWD"; source harness/tools/mutate.sh; isolation_key'`) → `59274326…`. Sie
  stimmen **nicht** überein, also fährt der nächste `make mutate` den vollen Satz — fail-closed, wie
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2
  es vorsieht (*„Ohne die Messung, die sie belegt, ist der Default kein Übersprung"*). Die
  Zustandsdatei behauptet nichts Falsches. Die Commit-Message formuliert das eine Spur zu weit
  (*„der bestehende Beleg … traegt weiter, auch wenn der gespeicherte isolation_key … nicht mehr
  zum Baum passt"* — ein Beleg, dessen Schlüssel nicht passt, *trägt* nicht, er wird ignoriert);
  die Sache selbst ist richtig, siehe die zwei Zeilen darunter.
- **Ein Kommentar-Diff kann kein Mutations-Verdikt bewegen — gemessen, nicht angenommen.** **22**
  Fall-Dateien fassen `internal/emit/templates.go` an
  (`grep -l 'internal/emit/templates.go' test/mutations/*.sh | wc -l`, kein Erwartungswert).
  **Keine einzige** adressiert per Zeilennummer; alle arbeiten mit inhaltsbasierten
  `sed`-Mustern auf Code-Zeilen. Die fünf löschenden Muster (`/…/d`) sind einzeln geprüft — jedes
  trifft in der Datei **genau einen** Treffer, und **keiner davon liegt in einer Kommentarzeile**.
  Die 41 Zeilen Verschiebung, die dieser Commit erzeugt, sind damit für jeden Fall folgenlos.
- **Gate-Stempel deckt genau diesen Baum.** `cat .harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern beide `49e772d3…`
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
  `record-gates` führt `comment-claims` in seiner Voraussetzungsliste
  (`grep -n '^record-gates:' Makefile`), der aufgezeichnete Lauf deckt den geänderten
  Kommentar-Block also mit.
- **`make comment-claims` selbst gefahren:** `57 Datei(en) geprueft, 0 Befund(e)`. Das ist kein
  Gegenbeleg zu HIGH-1 — der Gate prüft die **Existenz** eines genannten Sensors, nicht seine
  Deckung; genau deshalb steht HIGH-1 im Report und nicht im Gate.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 eingehalten.** Der Commit berührt **eine** Datei.
  Keine `AGENTS.md`, kein `harness/conventions.md`, keine ADR, kein Slice-Plan, keine
  Closure-Notiz, kein Register-Beleg, keine Datei unter `.harness/baseline/`.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 — Form der neuen Kommentare.** Die eingefügten Blöcke
  stehen im Indikativ über den Zustand und tragen die Klassen *Grenze* und *Zusage*. Keine
  Befund-Kennung, keine Slice-Nummer, kein Runden-Verweis, kein Lauf-Protokoll — auch nicht in dem
  Absatz, der die Re-Baseline-Pflicht ausspricht. Beanstandet ist oben der **Inhalt** zweier
  Zusagen, nicht ihre Form.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Host-Toolchain-Aufruf im Diff. Dieser
  Review hat `make comment-claims` gefahren; alles Übrige ist `git`, `grep`, `awk`, `find`, `sed` —
  keine Sprach-Toolchain, kein Paketmanager. Der Arbeitsbaum ist unberührt geblieben
  (`git status --porcelain` vor **und** nach den Sonden leer).
- **[`AGENTS.md`](../../AGENTS.md) §5 — Traceability der Commit-Message.**
  `git show -s --format=%B f81f4652 | grep -coE 'LH-[A-Z]{2}-[0-9]{2}|ADR-[0-9]{4}'` → **3**.
- **Der Slice-Plan ist unverändert.** DoD-Häkchen leer, §6-Risiken ohne Ausgang, §7 ungeschrieben —
  korrekt für einen laufenden Slice; der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Aus Runde 2/4 unverändert offen** (nicht neu gezählt): die `test/mutations/`-Lücke für
`backtickSpanPattern`, `unmaskQuotedCommentSyntax` und die Marker-Form
(`grep -l 'backtickSpan\|unmaskQuoted\|dcheckIgnoreMarker' test/mutations/*.sh` → leer); die
`strings.Contains`-Klassifikation im Integrations-Wächter; und der vorformulierte Risiko-Ausgang
§6 des Slice-Plans (Planner-Sache).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 2 | `Zusage-ueber-Sensor-Deckung-weiter-als-der-Sensor` (beide) |
| MEDIUM | 0 | — |
| LOW | 0 | — |
| INFO | 2 | `ADR-Status-in-Rollen-Artefakt-falsch-zitiert` · `Proben-Menge-ungleich-ueber-die-Bezugsmengen` |

**Der Zähler bekommt *einen* Beleg, nicht zwei.** HIGH-1 und HIGH-2 sind dieselbe Klasse im selben
Vorgang; `modul-06-roadmap.md` §Das Beobachtungs-Register ist eindeutig: *„Zwei Funde im selben
Vorgang sind eine Gelegenheit, kein zweites Auftreten"*. Registerstand heute:
`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`
→ **2**, für
[`BEO-ALL/commit-message-ohne-traceability-kennung`](../plan/planning/observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
→ **1** (keine Erwartungswerte). Für die Deckungs-Zusagen-Klasse führt das Register kein
Verzeichnis; es anzulegen ist Closure-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Fünf Runden, dieselbe Klasse am selben Ort — der Steering-Loop-Punkt ist überschritten.** Modul 8
§Konflikt-Pfad macht die Sequenz ab dem dritten gleichen Konflikttyp zur Pflicht. Der Lerneintrag
der Closure hat damit einen bezifferten Anlass; er gehört dorthin, nicht in diesen Report.

## Verdikt

**Blockierender Befund: ja — zwei HIGH, beide reine Kommentar-Zusagen, beide in demselben
Doc-Block.**

**Was diese Runde bestätigt.** Der Diff ist **wirklich** kommentar-only, und zwar auf drei
unabhängigen Wegen geprüft, nicht durch Nachlesen der Behauptung. Der Emit ist damit unverändert;
die Rücknahme-Bedingung des Plans bleibt unerfüllt. Alle vier im Kommentar genannten Proben habe
ich selbst gefahren — jede liefert das behauptete Ergebnis. Die **Offenheits-Erklärung ist
gelungen**: die drei Runde-4-Sätze sind restlos fort, die vier Formen stehen erkennbar als
Beispiele, und der Satz *„die Menge … ist nicht geschlossen und wird hier nicht als geschlossen
behauptet"* steht zweimal, einmal als Feststellung und einmal als Nachdruck. Runde-4-LOW-1 ist
sauber als Grenze dokumentiert, mit Kommando und Wander-Vermerk. Die Re-Baseline-Pflicht ist
ausgesprochen. Die Entscheidung, MEDIUM-1 und MEDIUM-2 offen zu lassen, ist ehrlich abgebildet.

**Warum es trotzdem blockiert.** Nicht wegen einer neuen Heuristik-Lücke — ich melde keine. Es
blockiert, weil derselbe Commit, der die Über-Zusage abräumen sollte, **zwei neue eingesetzt hat**,
und beide an der Stelle, an der der Kommentar der einzige Träger ist:

1. `:971-972` sagt neu zu, `TestStripCommentHints` decke *„die oben genannten Beispiel-Faelle"* —
   drei der vier haben keinen Eingang, darunter beide bewusst offen gelassenen. Ein Leser, der
   diesen Satz glaubt, hält zwei ungefixte Fälle für bewacht. Das ist die schärfste Form: eine
   Zusage über einen **Sensor**, an einer Stelle, die `make comment-claims` konstruktionsbedingt
   nicht bewerten kann.
2. `:952-969` erklärt drei Proben zur gemessenen Abwesenheit *„der bekannten Formen"* und macht sie
   zur hinreichenden Bedingung dafür, dass die Regel einem neuen Satz gegenüber *„als sicher
   gilt"*. Zwei der vier Formen hat keine Probe — und für eine davon, die Fence-Blindheit, **hat
   dieser Commit die Messung entfernt, die es gab**. Das erfüllt beide Blockier-Kriterien
   gleichzeitig: eine Zusage, die weiter reicht als der Beleg, **und** eine Regression gegenüber
   dem Vorstand.

**Was das ausdrücklich nicht ist.** Kein Rückfall in das Spiel der Runden 1–4. Beide Befunde sind
mit Kommentar-Text zu erledigen und berühren die Heuristik nicht: HIGH-1 fällt mit dem Streichen
von sechs Wörtern (oder mit Testfällen, die die genannten Formen festhalten — das wäre die
größere, aber nicht verlangte Antwort); HIGH-2 fällt, wenn die gestrichene Fence-Messung als
vierte Probe zurückkehrt oder der Satz auf die Formen eingeschränkt wird, die die Proben wirklich
treffen. Keiner der beiden verlangt, eine weitere Lücke zu schließen.

**Ausdrücklich nicht blockierend:**

- **Runde-4-MEDIUM-1 und -MEDIUM-2.** Bewusste Entscheidung, hier nicht erneut gemeldet. Sie sind
  ehrlich und auffindbar dokumentiert — das war die Frage, und die Antwort ist ja.
- **Die DoD-Zahl 1 statt 0.** Unverändert die Lage aus Runde 3 und 4:
  [`AGENTS.md`](../../AGENTS.md) §3.10 reserviert das Umschreiben des Abnahmekriteriums dem Planner.
- **Der entwertete `mutate`-Schlüssel.** Siehe unten — kein Befund.

**Empfehlung zum `mutate`-Beleg (ausdrücklich gefragt): kein frischer Volllauf nötig, und der
Verifier sollte ihn nicht verlangen.** Zwei Gründe, beide gemessen statt geschlossen. **Erstens**
ist die Auslassung nach [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 2 nicht nur zulässig, sondern das vorgesehene Verhalten: der gespeicherte Schlüssel
passt **nicht** mehr zum Baum, der Beleg wird deshalb gar nicht in Anspruch genommen, und der
nächste Lauf fährt fail-closed den vollen Satz. Die Zustandsdatei behauptet nichts, was sie nicht
hält — die Nebenwirkung ist korrekt benannt, nur in der Commit-Message eine Spur zu freundlich
formuliert (*„traegt weiter"*, wo *„wird verworfen, der nächste Lauf fährt voll"* die Sache trifft).
**Zweitens** kann ein Kommentar-Diff hier kein Verdikt bewegen: alle **22** Fall-Dateien, die diese
Datei anfassen, adressieren inhaltsbasiert statt per Zeilennummer, und keines der fünf löschenden
Muster trifft eine Kommentarzeile. Ein Volllauf kostete rund 280 Fälle und könnte nur bestätigen,
was hier bereits abzählbar ist. Nur eine Bedingung: **wenn HIGH-1 mit neuen Testfällen statt mit
gestrichenen Wörtern beantwortet wird**, ist der Diff nicht mehr kommentar-only, und dann fällt
diese Empfehlung — dann gehört der volle Lauf dazu.

**Reif für den Verifier: noch nicht — aber nach einem Kommentar-Commit ja.** Der Code ist es seit
Runde 4; die Gate-Lage ist es (Stempel deckungsgleich, `comment-claims` grün); der Emit ist es.
Offen ist genau das, was Runde 5 schließen sollte: ein Doc-Block, der zwei Deckungen zusagt, die er
nicht hat. Solange er steht, prüfte der Verifier gegen einen Text, der zwei ungefixte Fälle als
bewacht ausweist — und er ist hier der einzige Träger.
