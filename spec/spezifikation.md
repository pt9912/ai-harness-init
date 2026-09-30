# Spezifikation — ai-harness-init

**Status:** Aktiv. **Letzte Änderung:** 2026-09-30.

**Bezug zum Lastenheft:** Diese Spezifikation präzisiert die in
[`spec/lastenheft.md`](lastenheft.md) formulierten Anforderungen (`LH-*`-IDs). Bei
Konflikt gewinnt das Lastenheft.

## Aufnahme-Regel

Ein Satz gehört hierher, wenn **alle drei** zutreffen:

1. Er ist eine **technische Festlegung dieses Repos** — ein Wert, ein Feld, eine
   Schranke, eine Regel, eine Fassung, auch das, was ein Werkzeug **nicht** liefert.
   Etwas, gegen das gemessen werden kann.
2. Er ist **ohne Vertragsänderung fortschreibbar**: die Anforderung, die er
   präzisiert, bleibt beim Fortschreiben unberührt. Die Spalte `Präzisiert` nennt sie
   als Anker-Link ins Lastenheft; trägt kein Element die Zeile, steht `Lücke` — ein
   Übergangswert, der die Zeile als Präzisierung ohne Träger sichtbar macht.
3. Er **wächst mit seinem Gegenstand** — die nächste Zeile seiner Tabelle verdrängt
   keinen anderen Text.

Die Form ist die Tabellenzeile: jede Festlegung trägt eine `SPEC-<NNN>` und die Spalte
`Präzisiert` als letzte Spalte; eine Zusicherung ist eine Zeile mit ihrem Wächter in
der Spalte `Sensor` (ein Strich, wo keiner gebunden ist). Eine Zeile über den
**Träger** — Feld, Wert, Schranke, Ableitungs-Regel eines Werts — hat den Bezug oben;
eine Zeile über die Verdrahtung dieses Repos hat ihn nicht und trägt `Lücke`. Die
Feldtabelle trägt nur Felder; eine Festlegung ohne Feld-Charakter steht in einer
eigenen Tabelle mit eigener Kopfzeile.

Nicht hierher gehören: die **Begründung** einer Entscheidung (sie steht in der
Entscheidung und zeigt von dort aufwärts hierher), die **Abweichung** von der
adoptierten Baseline (repo-lokales Konventionsdokument; die Festlegung, an der sie
hängt, bleibt Zeile), die **Messung** (ein Messprotokoll ist datiert und ein
Zeitdokument; hier steht die Festlegung, gegen die gemessen wird), die
**Prozess-Konvention** (wer wann was tut — kein Wert, Feld und keine Schranke), die
**Anforderung** ([`spec/lastenheft.md`](lastenheft.md)) und die **Komponentensicht**.

Drei Formregeln, weil alle drei von außen gelesen werden:

- **Der bindende Text zeigt nicht abwärts, auch die [Historie](#7-historie) nicht.**
  Hier steht keine Entscheidungs- und keine Planungs-Kennung: ein Wert steht für
  sich, das Warum findet man über die aufwärts zeigende Entscheidung — sie nennt
  ihr Ziel in ihrem `Schärft:`-Feld. Gemessen wird
  davon in `.d-check.yml` der **Link, dessen Ziel eine Entscheidungs- oder eine
  Planungs-Datei ist** (`matrix`-Klasse `spec-straten` — rot wird die Klasse des
  Ziels, nicht der Text der Kennung), und die **nackte** Entscheidungs-Kennung
  (`ids`); die Historie nimmt `matrix.exclude-sections` dabei aus, und eine nackte
  Planungs-Kennung wie jede Kennung, deren Link woanders endet,
  trifft kein Muster — dort gilt die Regel ohne Wächter.
- **Abschnittsnummern werden nie neu vergeben.** Ein
  Abschnitt ohne Inhalt lässt seine Nummer frei, und ein hinzukommender bekommt
  seine eigene. Neu zu nummerieren verschöbe die Anker, auf die von außen gezeigt
  wird — und ein Teil dieser Zeiger steht in Dokumenten, die nicht mehr geändert
  werden dürfen.
- **Eine `SPEC-<NNN>` wird nie neu vergeben.** Sie ist eine **Adresse**, keine
  Anforderung: fortlaufend **je Datei** gezählt, nicht je Abschnitt, und eine
  entfallene Zeile lässt ihre Nummer frei. Sie ist das, worauf das `Schärft:`-Feld
  einer Entscheidung zeigen kann, statt nur den ganzen Abschnitt zu nennen — eine
  nachrückende Nummer verschöbe genau diese Adresse. **Ein eigener Anker entsteht
  dabei nicht:** eine Kennung in einer Tabellenzelle ist kein Sprungziel, der Link
  von außen endet weiter am Abschnitt, und kein Sensor bemerkt eine Umbenennung.

---

## 3. Defaults und Konstanten

Werte, die in Code, Konfiguration oder Gate-Schwelle fest sind — je mit der
Begründung ihrer Höhe, nicht nur mit ihrer Höhe.

| ID | Name | Wert | Begründung | Präzisiert |
|---|---|---|---|---|
| `SPEC-001` | `model_version` — Länge | höchstens **64** Byte | `model_version` ist der einzige Rohstring unter den neun Werten, die aus dem Werkzeug-Ergebnis erfasst werden; die übrigen acht sind Zahlen oder das gegen sechs Namen normalisierte Etikett. Was die Schranke nicht erfüllt, wird **verworfen, nicht gekürzt**: 64 Byte eines Geheimnisses sind auch 64 Byte fremden Inhalts, und ein verstümmeltes Präfix ist ein falsches Protokoll, wo „unbekannt" das ehrliche ist (dieselbe fail-closed Linie wie `commandProgram`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-002` | `model_version` — Zeichensatz | geschlossen: Buchstaben, Ziffern, `.`, `_`, `-` und die Klammern `[` `]` | Die Klammern gehören zur Bezeichner-Sprache des Herstellers. **Der Zeichensatz ist eine Entscheidung unter Unsicherheit, und das gehört gesagt:** die Messung erfasste nur Schlüsselnamen und Wertlängen, nie Werte — die Gestalt eines echten `resolvedModel` ist **nicht** gemessen. Der Fehlermodus ist ein **fehlendes** Feld, nicht ein falsches, und er ist am Bestand ablesbar: trägt kein `Agent`-Span mit Zählern ein `model_version`, ist die Schranke zu eng geraten und wird **hier** geweitet, nicht im Code aufgeweicht | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

## 5. Metriken und Tracing-Felder

Die verbindlichen Felder je Span, jedes mit seiner Pflichtigkeit, der Incident-Frage,
die es beantwortet, und dem Wächter, der seine Zusicherung hält; dazu die Regeln der
Erfassung, die keine Feldzeile sind, und die Zusicherungen mit ihren Wächtern. Ein Feld
ohne Incident-Frage wird nicht erfasst.

**Gegenstand** sind die Spans, die das Unterkommando `span-emit` des Trägers je
Tool-Call in den gitignorierten Zustands-Bereich schreibt (Einstiegspunkt in
`cmd/ai-harness-init/span_emit.go`, Logik in `internal/span/`). Der Träger ist das
Produkt-Binär selbst; Schreiber und Auswertung sind seine Unterkommandos, und der Hook
dieses Repos ruft denselben Einstiegspunkt, den ein Zielrepo bekommt.

**Das Schema ist GESCHLOSSEN.** Erfasst wird, was hier steht; jedes andere Feld einer
künftigen Payload wird **nicht** still mitgeschrieben. Wer eines aufnimmt, trägt es hier
ein — mit seiner Incident-Frage, sonst gar nicht (*„Ein Attribut ohne Incident-Frage
fliegt raus"*).
Die Tabelle ändert sich mit jedem neuen Feld — jede Änderung ist ein Eintrag hier, kein
Nebeneffekt im Skript.

**Was die Spalte `Sensor` sagt und was nicht.** Sie nennt den Wächter, der die Zusicherung
der Zeile hält; *Fall N* meint `test/mutations/N-*.sh`. Ein Strich heißt: für diese Zeile
ist kein Wächter namentlich gebunden. Zusicherungen, die keine Zeile dieser Tabelle sind,
stehen in der Tabelle der Zusicherungen am Ende des Abschnitts. **Die Nennung selbst ist
unbewacht:** kein Gate prüft, ob ein hier oder dort genannter Wächter noch existiert oder
noch so heißt — `codepaths` validiert nur Pfade unter seinen `roots` (`spec`, `docs`,
`harness`), ein erfundener Pfad unter `test/` oder `internal/` bleibt still und derselbe
unter `harness/` meldet `codepath-missing`; `make mutate` fährt nur die Fall-Dateien, die
es findet; `make comment-claims` lässt jede Markdown-Datei außen vor. Die Spalte ist damit
**Feedforward**: ihre Alterung fängt niemand mechanisch, und wer eine Zeile ändert, zieht
ihren Wächter von Hand nach.

| ID | Feld | Pflicht | Incident-Frage | Sensor | Präzisiert |
|---|---|---|---|---|---|
| `SPEC-003` | `seq` | Pflicht | *Fehlt ein Span?* — je Strom monoton steigend, damit der **Leser** eine Lücke sieht | `internal/span/span_test.go` · Fall 109 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-004` | `ts` | Pflicht | *Wann geschah es?* | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-005` | `event` | Pflicht | *Erfolg oder Fehlschlag?* (Nach- bzw. Fehlschlag-Ereignis) | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-006` | `tool` | Pflicht | *Welches Werkzeug lief?* | `TestMandatoryFieldsAlwaysPresent` · Fall 130 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-007` | `tool_use_id` | Pflicht | *Welche Ereignisse gehören zu einem Aufruf?* | `TestMandatoryFieldsAlwaysPresent` · Fall 110 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-008` | `session`, `agent` | Pflicht | *Welcher Lauf war es?* — zusammen bilden sie den **Strom** | `internal/span/span_test.go` (Strom-Trennung) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-009` | `agent_type` | Pflicht | *Welche Art Lauf?* — der **Subagent-Typ** der Payload, roh. **Pflicht wie `agent`**: die vier Felder `session`/`agent`/`agent_type`/`agent_role` sind ein Block, und leer ist dort eine Aussage (Haupt-Kontext), kein fehlender Wert | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-010` | `agent_role` | Pflicht | *Welche Rolle verursachte den Zugriff?* — ein Pflichtfeld. Gefüllt, wenn `agent_type` eine Harness-Rolle **nennt** (`planner`, `architect`, `implementer`, `reviewer`, `verifier`, `validator`). **Leer heißt UNBEKANNT, nie „rollenlos"** — s. die Lesevorschrift (`SPEC-044`) | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-011` | `slice` | Pflicht | *Auf wessen Rechnung lief der Zugriff?* — aus dem Lifecycle-Verzeichnis, Liste (kein Slice ⇒ leer und als leer erkennbar) | `internal/span/span_test.go` (Ableitung) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-012` | `requirement` | Pflicht | *Gegen welche Anforderung?* — aus der `Bezug:`-Zeile der Slices, Liste | `internal/span/span_test.go` (Ableitung) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-013` | `adr` | Pflicht | *Auf wessen Entscheidung lief der Zugriff?* — eine Korrelations-Achse, aus demselben `Bezug:`-Block wie `requirement`, Liste | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-014` | `branch`, `commit` | Pflicht | *Zu welcher Änderung gehört der Zugriff?* — eine Korrelations-Achse (*Slice/**PR**/Agent-Rolle*), abgeleitet aus `.git/HEAD`; die PR-Nummer selbst ist nicht erreichbar (Abweichung 2, `SPEC-056`) | `internal/span/span_test.go` (Ableitung von `branch`) · Fall 111 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-015` | `status` | Pflicht | *Ging es gut?* | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-016` | `permission_mode` | Optional | *Unter welcher Berechtigungs-Lage?* | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-017` | `path` | Optional | *Was wurde wohin geschrieben/gelesen?* — nur bei namentlich gelisteten Datei-Werkzeugen | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-018` | `bytes`, `sha256_16` | Optional | *Hat sich etwas geändert?* — aus dem **Dateisystem**, nie aus der Payload | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-019` | `duration_ms` | Optional | *Wie lange dauerte der Aufruf?* — aus der Payload übernommen. Ohne sie ist **Gleichzeitigkeit nicht entscheidbar**: ein Span trägt sonst nur seinen Abschluss, und zwei Ströme lassen sich nicht überlagern | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-020` | `result_bytes` | Optional | *Wie groß war das Ergebnis?* — **nur die Länge, nie der Inhalt**; gemessen wird die **JSON-Kodierung**, wie die Payload sie trägt (samt Anführungszeichen und Escapes), nicht die Zeichenzahl des Ergebnisses. Ohne sie ist nicht entscheidbar, ob ein **einzelner** Aufruf eine Ressourcenspitze erklärt | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-021` | `program`, `argc` | Optional | *Welches Programm lief?* — das erste Wort des ausgeführten Segments (nach übersprungenen Zuweisungs- und Navigations-Segmenten, Regel in der `Bash`-Zeile der Werkzeug-Tabelle) und die Argument-Anzahl **dieses Segments**, nie die Kommandozeile | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-022` | `spawned_role` | Optional | *Welche Rolle lief im Subagenten — auf wessen Rechnung geht sein Verbrauch?* — aus `tool_response.agentType`, gegen die sechs kanonischen Typnamen normalisiert. **Nie** aus `tool_input.subagent_type`: das ist die *Anforderung*, nicht der *Lauf*, und es liegt auf der Argument-Achse. Eigener Feldname, weil `agent_type`/`agent_role` schon den Typ des **laufenden** Agenten führen. **ABWESEND heißt UNBEKANNT, nie „rollenlos"** — dieselbe *Lesart* wie bei `agent_role`, aber ausdrücklich **nicht** dessen Draht-Form: `agent_role` ist **Pflicht** und steht als `""` in jeder Zeile, `spawned_role` ist `omitempty` und **fehlt** bei leerem Wert. Das ist Absicht und keine Nachlässigkeit — ein `"spawned_role":""` in jedem `Bash`-Span behauptete einen Subagenten, den es nicht gab; die Present-and-empty-Regel gilt für den Vierer-Block, den **jeder** Span trägt, nicht für ein Feld, das nur ein Werkzeug erzeugt. **Unterscheidbar bleibt es am Pflichtfeld `tool`:** ein `Agent`-Span **ohne** `spawned_role` ist ein Lauf mit *unbekannter* Rolle und gehört in den Sammelposten — eine Auswertung, die nach `spawned_role: ""` sucht, findet ihn nicht und darf ihn deshalb nicht aus der Bilanz fallen lassen | `TestAgentGetsNoArgumentFields` (Herkunft und Draht-Form) und `TestFailedAgentCallCapturesNothing` (Draht-Form), `TestSpawnedRoleIsNormalised` (Normalisierung) · Fälle 128, 132, 137, 138 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-023` | `input_tokens`, `output_tokens` | Optional | *Wie teuer war dieser Subagenten-Lauf?* — die Verbrauchs-Achse, ohne die eine Token-Bilanz je Rolle eine Summe statt einer Rechnung ist | `TestFailedAgentCallCapturesNothing` · Fälle 134, 136 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-024` | `cache_creation_input_tokens`, `cache_read_input_tokens` | Optional | *Zahlte der Lauf den Cache oder nutzte er ihn?* — der Cache-Status, für Subagenten-Läufe **erfasst** (Abweichung 1, `SPEC-055`) | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-025` | `total_tokens` | Optional | *Wie groß war der Lauf insgesamt?* — die Summe, die das **Werkzeug selbst** ausweist. Am eigenen Bestand nachgerechnet **ist** sie die Addition der vier Zähler, exakt, an jedem geprüften Zähler-Span. Eine Auswertung addiert sie deshalb **nicht** zu den vier, sondern gegen sie. **Hier steht bewusst keine Zahl und keine Stichprobengröße:** der Bestand unter `.harness/state/spans/` ist gitignored, maschinenlokal und wächst mit jedem Subagenten-Lauf — eine eingefrorene Rechnung ist für einen anderen Checkout ohnehin nicht nachvollziehbar. Die Probe gehört **gefahren**, nicht zitiert, und sie bleibt eine Stichprobe | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-026` | `total_duration_ms` | Optional | *Wie lange lief der Subagent wirklich?* — **nicht** `duration_ms`: das misst den Aufruf, wie der Hook ihn sieht. Die Erfassung hängt an `PostToolUse`/`PostToolUseFailure`, der Hook feuert also **nach** dem Aufruf; `duration_ms` ist die Wanduhr des ganzen Werkzeug-Aufrufs und liegt deshalb in einem Vordergrund-Lauf **über** `total_duration_ms`, um Anlauf und Rückgabe. Wer die Reihenfolge umdreht, liest die Differenz als Subagenten-Zeit. **Die Probe gehört gefahren, nicht zitiert** (hier steht darum keine Zahl): jeder `Agent`-Span mit beiden Werten zeigt sie, und ein Span, in dem `duration_ms` **unter** `total_duration_ms` liegt, wäre der Befund. Ein im **Hintergrund** gelaufener Aufruf trägt gar kein `totalDurationMs`; sein `duration_ms` ist klein, weil das Werkzeug für einen Hintergrund-Subagenten sofort nach dem Start zurückgibt. Jede Paarung gehört ihrem Aufruf; zwei Beobachtungen zu einer zu fügen ergäbe eine Messung, die niemand gemacht hat | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-027` | `total_tool_use_count` | Optional | *Wie viele Werkzeug-Aufrufe verursachte der Subagent?* — der Teiler, ohne den „Token je Aufruf" nicht rechenbar ist | — | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-028` | `model_version` | Optional | *Welches Modell verursachte die Kosten?* — das Label `model.version`, aus `tool_response.resolvedModel`, **strukturell begrenzt** (Länge und geschlossener Zeichensatz, [§3](#3-defaults-und-konstanten)). Was die Gestalt eines Bezeichners nicht hat, wird **verworfen, nicht gekürzt** | `TestResolvedModelIsStructurallyBounded` · Fall 129 | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Welches Werkzeug gibt was preis — die namentliche Liste.** Die Feldtabelle oben sagt
*„nur bei namentlich gelisteten Werkzeugen"*; hier stehen die Namen. Ein Werkzeug
aufzunehmen ist eine **Entscheidung** und wird hier eingetragen, nicht im Code
nachgezogen.

| ID | Werkzeug-Name | erfasst zusätzlich zu Name und Status | Präzisiert |
|---|---|---|---|
| `SPEC-029` | `Write`, `Edit`, `MultiEdit`, `NotebookEdit` | `path` (aus `file_path`/`notebook_path`) + `bytes` + `sha256_16` **aus dem Dateisystem** | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-030` | `Read` | `path` — **kein** Fingerabdruck (er wäre auf einem gelesenen Pfad ein Bestätigungs-Orakel ohne Incident-Frage) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-031` | `Bash` | `program` (erstes Wort nach übersprungenen Segmenten ohne Programm — `NAME=WERT`-Zuweisungen und führende Navigations-Segmente `cd`/`set`; Wortgrenzen sind Leerzeichen, Tab und Zeilenende — jedes andere Zeichen, auch ein Unicode-Leerraum, bleibt Teil seines Wortes, und ein einzelner Backslash vor dem Zeilenende setzt die Zeile fort und ist kein Wort; die Zuweisungen bilden ein Segment ohne Programm, ein Operator als eigenes Feld — `&&`, `;`, `\|`, `&` — beendet es, und das Programm ist das erste Wort des nächsten Segments. Ein Navigations-Segment wird nur übersprungen, wenn drei Bedingungen zugleich gelten: die Kommandozeile trägt kein Zeilenende zwischen zwei Wörtern, jedes Wort des Segments ist schlicht — ein Buchstabe, eine Ziffer, eines der Zeichen `$%*+,-./:=>?@[]^_~`, ein `&` unmittelbar hinter `>` oder ein Nicht-ASCII-Zeichen; jedes andere ASCII-Zeichen, darunter `"` `'` `` ` `` `\` `(` `)` `{` `}` `#` `<` `\|` `;` `!` und ein anderes `&`, macht ein Wort unschlicht —, und `&&` oder ein Feld auf `;` trennt es ab, mit einem Feld dahinter: `cd /x && make gates` nennt `make`; `cd /x`, `cd /x &&`, `cd /x \|\| exit 1`, `cd /x \| make`, `cd /x;make`, `cd "a && b" && make`, `cd /x # a; b` und jede mehrzeilige Kommandozeile mit Navigations-Segment nennen `cd` — so wird nie ein Wort eines Kommentars, eines Here-Doc-Körpers oder einer Folgezeile zum Programm. Hinter einem übersprungenen Navigations-Segment nennt das Feld nur ein schlichtes Wort: `cd /x && $TOOL x` nennt den Namen `$TOOL`, nie einen Wert; `cd /x && "a b" x`, `cd /x && 'a b' x`, `cd /x && $(cmd) x`, `cd /x && a\ b` und `cd /x && make; echo z` lassen `program` und `argc` entfallen. Ohne Navigations-Segment nennt das Feld das erste Wort, wie es dasteht: `make;` bei `make; echo x y`, `make&` bei `make& echo x`, `"a` bei `"a b" x`, `my\` bei `my\ tool`, `>f` bei `>f make`, `<<EOF` bei `<<EOF cat`, `#` bei `# note`) + `argc` (die Wörter **nach** dem Programm bis zum Ende seines Segments, nicht bis zum Ende der Kommandozeile: ein Operator als eigenes Feld — `&&`, `\|\|`, `;`, `\|`, `&` — beendet es, ein Feld auf `;` und das Ende der Zeile beenden es und zählen noch mit — `make gates && echo x` hat `argc` 1; schließt das Programm-Feld selbst sein Segment (`make; echo x y`, ein Zeilenende dahinter), ist `argc` 0; ein Operator ohne Leerraum, `a&&b`, ist kein eigenes Feld und beendet nichts). **Nichts** wird erfasst, wenn nach einer Zuweisung kein Programm folgt (`A=b \|\| cmd`, `A=b &&`), wenn der Rand eines Zuweisungs-Werts nicht bestimmbar ist (eines der Zeichen `"` `'` `` ` `` `\` `(` `)` `{` `}` `;` `&` `\|` `<` `>` im Wert) oder wenn das Wort nach einer Zuweisung oder einem übersprungenen Navigations-Segment mit einem Shell-Metazeichen (`\|` `&` `;` `(` `)` `<` `>` `#` `!` `{` `}`) oder einer Ziffernfolge vor `<`/`>` beginnt (`A=b >f cmd`, `A=b 2>&1 cmd`, `A=b #x`) oder wenn das Wort hinter einem übersprungenen Navigations-Segment nicht schlicht ist: der Wert und jedes seiner Bruchstücke bleiben aus dem Span. Bewacht von `TestCommandProgramNamesAProgramNotAnOperator` · Fälle 404, 407, 408, `TestCommandProgramNeverEmitsAssignmentValueFragments` · Fälle 405, 406 und `TestCommandProgramWithholdsProgramForEachUnsureValueChar`, `TestCommandProgramSkipsNavigationSegments` · Fall 476, `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` · Fall 478, `TestCommandProgramKeepsNavigationOnMultilineCommands` · Fall 479, `TestCommandProgramBehindNavigationIsAPlainWord` · Fall 485, `TestCommandWordsSplitAtTab` · Fall 483, `TestCommandBackslashBeforeBlankIsAWord` · Fall 484, die schlichten Zeichen selbst: Fälle 486 und 487, `TestCommandArgcEndsWithItsSegment` · Fälle 477, 480, 481, 482 und `TestCommandProgramFirstWordKeepsItsGluedRest` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-032` | `BashOutput` | **nichts** — seine Eingabe ist eine Shell-Kennung, keine Kommandozeile | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-033` | `Agent` | `spawned_role` + die vier `usage`-Zähler + `total_tokens` + `total_duration_ms` + `total_tool_use_count` + `model_version` — **neun Werte aus sechs Schlüsseln**, alle aus `tool_response` und alle nach der **Positiv-Liste** (`SPEC-036`). **Kein** `path`, `program`, `argc`, `bytes`, `sha256_16`: aus `Agent`s `tool_input` erreicht nichts den Span (dort liegen `subagent_type`, `prompt` und `description`; `ToolInput` in `internal/span/span.go` führt genau drei Felder) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-034` | **jedes andere** | **nichts** — der fail-closed Default | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Regeln der Erfassung — die Festlegungen, die keine Feldzeile sind.** Sie stehen in einer eigenen Tabelle, weil die Feldtabelle nur Felder trägt. Die Spalte `Präzisiert` nennt das Lastenheft-Element, das die Zeile präzisiert; `Lücke` heißt, dass kein Element sie trägt.

| ID | Gegenstand | Festlegung | Präzisiert |
|---|---|---|---|
| `SPEC-035` | Werkzeug-Achse | Die Achse der Erfassung ist der Werkzeug-**Name**, nicht die Gestalt der Antwort: nur `Agent` gibt Werte aus `tool_response` preis, und `Agent` liegt auf **keiner** Gattungszeile — kein `path`, `program`, `argc`, `bytes`, `sha256_16` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-036` | `tool_response` ist eine Positiv-Liste | Erfasst wird ausschließlich, was `responseKeys()` in `internal/span/response.go` namentlich nennt: **sechs** Schlüssel, **neun** Blatt-Werte (die vier `usage`-Zähler einzeln), in sieben Tabellenzeilen geführt (`SPEC-022` bis `SPEC-028`). Alles andere fällt heraus, ohne genannt zu werden: kein Zweig sieht einen ungelisteten Schlüssel an, auch keinen verschachtelten. Keines der vier Freitext-Felder `content`, `prompt`, `description`, `outputFile` erreicht die Zeile; `prompt` steht auf beiden Erfassungs-Flächen eines `Agent`-Aufrufs, in den Argumenten (`tool_input`) und im Ergebnis (`tool_response`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-037` | Fehlschlag eines `Agent`-Aufrufs | Bei einem fehlgeschlagenen `Agent`-Aufruf fehlt `tool_response` ganz; es entsteht ein Span mit Name und Status, kein halber: die neun Werte fehlen, statt anwesend und ungemessen dazustehen | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-038` | `model_version` als Rohstring | `model_version` ist der einzige Rohstring unter den neun Werten (die übrigen acht sind Zahlen oder das gegen sechs Namen normalisierte Etikett) und trägt deshalb die strukturelle Schranke aus [§3](#3-defaults-und-konstanten) (`SPEC-001`, `SPEC-002`); was sie nicht erfüllt, wird verworfen, nicht gekürzt | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-039` | Hintergrund-Lauf ohne Verbrauchs-Achse (Abweichung 5) | Die `tool_response` eines Hintergrund-Laufs trägt keinen der vier `usage`-Zähler, kein `total_tokens`, `total_duration_ms`, `total_tool_use_count` und kein `agentType`; von den neun Werten gelangt höchstens `model_version` in den Span (`resolvedModel` steht auch dort und läuft durch die Schranke). Kein Teilwert erlaubt, einen Zähler abzuleiten; `outputFile` und das Transkript sind keine Quelle. Ein `Agent`-Span ohne Zähler sieht aus wie ein erfasster Lauf und ist keiner: die Erfassung ist insoweit unvollständig, sie erfindet nichts. Die Quelle für Zähler eines Hintergrund-Laufs ist nicht gepinnt, kein Gate prüft sie; die Aussage entfällt, sobald die `tool_response` eines Hintergrund-Laufs Zähler trägt | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-042` | Kanonische Namen der Agenten-Typen | Die kanonischen Namen der Agenten-Typen sind die sechs Rollen-Namen, kleingeschrieben: `planner` · `architect` · `implementer` · `reviewer` · `verifier` · `validator` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-043` | `agent_role` (Abweichung 3) | `agent_role` ist `Pflicht` und wird abgeleitet, nicht geraten: nennt der Agenten-Typ eine Rolle, ist er die Rolle, sonst bleibt das Feld leer — bei `general-purpose` und im Haupt-Strom, der keinen Agenten-Typ trägt. Die Quelle liefert dort keine Rolle, der Wert ist unbekannt, und das Feld steht trotzdem in jedem Span. Ableitbar aus bereits erfassten Feldern sind für den Haupt-Strom zwei Signale: das Feld `slice` und das Schreibziel (`docs/plan/` gegen Code-Pfade) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-044` | Lesevorschrift | Bindend für jede Auswertung: ein leeres `agent_role` heißt **unbekannt**, nie *ohne Rolle* — eine Rolle gibt es immer, jeder Tool-Call wurde von jemandem in einer Rolle verursacht | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-045` | Splitting-Regel | Ein Span ohne Rollen-Tag (Sammelposten) wird **anteilig nach Tool-Calls** auf die realen Rollen verteilt; rollenlose Calls bleiben aus dem Nenner. Der Rest der Ganzzahl-Division wird weitergegeben — absteigend nach Tool-Calls, bei Gleichstand alphabetisch —, damit die Summe der Zuteilungen genau dem Sammelposten entspricht. Ausnahme: trägt keine Rolle Tool-Calls, bleibt der Sammelposten unverteilt; die Ausgabe nennt dann den Betrag, dass er unverteilt ist und dass er nicht in ihrer Summe steht, und führt keinen Prozentsatz. Die Regel verteilt Etiketten auf gemessene Token, sie ist keine Messung | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-046` | Prüfreihenfolge | Ein Span ohne Rollen-Tag wird begründet aufgeteilt, in dieser Reihenfolge: (1) die Splitting-Regel ist angewendet, am Ende liegt jedes Token auf einer realen Rolle, nicht auf *unbekannt*; (2) wie groß der aufgeteilte Anteil war, steht in jedem Ergebnis; (3) falsch ist, den Sammelposten ungeteilt als Rolle zu führen (*„ohne Rolle: 60 %"* als Ergebniszeile) — die Größe zu zeigen ist erlaubt, sie stehenzulassen nicht | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-047` | Berichtsgröße | Der Anteil des Sammelpostens an einer Token-Bilanz steht im Bericht, nie als bestandene Schwelle: gezeigt wird die Größe, entschieden wird an ihr nichts. | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-048` | „Gedeckt" | „Gedeckt" heißt **Span mit Zählern**, nicht Span mit irgendeinem erfassten Wert: ein Span kann `model_version` tragen und trotzdem ein zählerloser Lauf sein (Abweichung 5). Die Festlegung gilt für jede Abdeckungszahl über diesen Bestand | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-049` | Haupt-Kontext ohne Zahl (Abweichung 6) | Der Verbrauch des Haupt-Kontexts steht in keiner **vermessenen** Payload: vermessen sind nur die Schlüsselmengen von `PostToolUse` und `PostToolUseFailure` und die `tool_response` des `Agent`-Werkzeugs; für die Payloads aller übrigen Ereignisse, auch des verdrahteten `Stop`-Hooks, ist die vendored `docs/user/claude-hooks-referenz.md` gelesen statt gemessen — sie nennt ein `usage`-Objekt und ein `totalTokens` nur für die `tool_response` des `Agent`-Werkzeugs, kein Nutzungsfeld für ein anderes Ereignis, und das ist Herkunft, keine Messung. Die vier `usage`-Zähler und die drei `total*`-Werte stehen ausschließlich in der `tool_response` eines `Agent`-Aufrufs, den Haupt-Kontext umschließt kein `Agent`-Aufruf. `result_bytes` und `duration_ms` sind Größen **eines** Aufrufs, keine Token; geschätzt wird nicht, der Wert steht leer und als leer erkennbar da. Jede Token-Bilanz aus diesen Spans ist eine Bilanz über Subagenten-Läufe: ihr Nenner ist nicht der Verbrauch des Laufs, und ein Prozentsatz daraus ist ein Anteil an der erfassten Teilmenge — wer ihn schreibt, schreibt das dazu. Für den Haupt-Strom gilt die Splitting-Pflicht samt der Pflicht, die Größe des Sammelpostens zu zeigen | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-050` | Payload als Quelle | Die Payload ist die Quelle. Nicht erfasst und abgelehnt sind `cwd`, `effort` und `prompt_id` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-051` | Verdrahtete Ereignisse | Verdrahtet sind drei Ereignisse — `PostToolUse`, `PostToolUseFailure` und `SubagentStart` —, je mit leerem Matcher, der **jedes** Werkzeug bzw. **jeden** Agenten-Typ sieht. Die ersten beiden erfassen den abgeschlossenen Aufruf | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), Akzeptanzkriterium *Erfassungs-Umfang* |
| `SPEC-052` | `SubagentStart` | `SubagentStart` erfasst den **Start**, nicht den Abschluss: es feuert je Spawn und ist die einzige Quelle, die einen Lauf zählt, dessen Ergebnis keine Zähler trägt. Seine Schlüsselmenge ist `hook_event_name` · `session_id` · `agent_id` · `agent_type` · `permission_mode`; **kein** `tool_name` und **kein** `tool_use_id` — es ist kein Tool-Call, die Werkzeug-Tabelle greift über den fail-closed Default (`SPEC-034`), der Span trägt weder `path` noch `program`/`argc`. `agent_role` wird wie überall abgeleitet. Ablageort ist der Strom des gestarteten Subagenten (`(session, agent)` mit dessen `agent_id`), nicht der Haupt-Strom: eine Auswertung, die Spawns zählt, liest alle Ströme | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), Akzeptanzkriterium *Erfassungs-Umfang* |
| `SPEC-053` | Nicht erfasst | Ein vom `PreToolUse`-Guard **geblockter** Aufruf hinterlässt keinen Span; `SubagentStop` ist nicht verdrahtet, ein abgebrochener Subagent hinterlässt also einen Start ohne Ende | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), Akzeptanzkriterium *Erfassungs-Umfang* |
| `SPEC-054` | Strom | Der Strom ist `(session, agent)` — die **Felder**, nicht der Dateiname. Eine Auswertung gruppiert nach den Feldern, nie nach dem Dateinamen, und setzt die Eindeutigkeit von `seq` je Datei voraus, nicht je `(session, agent)`; wer die Namensbildung ändert, räumt vorher mit `make span-clean` auf | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-055` | Cache-Status (Abweichung 1) | Der Cache-Status ist `Optional`: die Zähler `cache_creation_input_tokens` und `cache_read_input_tokens` (`SPEC-024`) erscheinen nur, wo die Payload sie trägt. Erfasst werden sie aus dem `usage`-Objekt der `tool_response` eines Vordergrund-`Agent`-Aufrufs, ohne Transkript; der `transcript_path` wird weder erfasst noch gelesen | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-056` | PR-Nummer (Abweichung 2) | Der Span führt keine PR-Angabe. An ihrer Stelle erfasst er `branch` und `commit` (`SPEC-014`), abgeleitet aus `.git/HEAD`; der Emitter geht nicht ins Netz und ruft kein `gh`. Ist die Ableitung nicht möglich, stehen beide Felder leer da statt zu fehlen; ein `.git` als Datei (Worktree, Submodul) wird nicht aufgelöst, dann sind beide leer und als leer erkennbar | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-057` | Altbestände (Abweichung 4) | Altbestände werden beim ersten Span einer Sitzung **nicht** entfernt: der Emitter hängt ausschließlich an. Aufgeräumt wird ausdrücklich mit `make span-clean`, nicht nebenbei; ein Werkzeug, das Sitzungs-Kennungen wiederverwendet, mischt zwei Läufe in einer Datei | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Zusicherungen und ihre Wächter.** Jede Zeile nennt eine Zusicherung und den Wächter, der sie hält; ein Strich heißt, dass kein Wächter gebunden ist. Die Nennung ist wie in der Feldtabelle unbewacht: kein Gate prüft, ob ein genannter Wächter noch existiert oder noch so heißt.

| ID | Zusicherung | Sensor | Präzisiert |
|---|---|---|---|
| `SPEC-058` | Klemme und stumme Ausgabe als Prozess-Eigenschaft: ein kaputter Payload lässt den Emitter nicht scheitern (Exit-Hälfte), und er schreibt nichts auf stdout (stdout-Hälfte; die Klemme allein deckt nur die Exit-Hälfte) | `cmd/ai-harness-init/span_emit_test.go` · `test/mutations/107-span-klemme-entfernt.sh` · `test/mutations/112-span-stdout-geschwaetzig.sh` (`TestClampSurvivesBrokenPayload`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-059` | Das Schema ist geschlossen: ein nicht namentlich geführtes Werkzeug gibt nur Name und Status preis (fail-closed Default an fremden Werkzeug-Namen), und kein Payload-Inhalt erreicht den Span | `internal/span/span_test.go` · `test/mutations/108-span-schema-offen.sh` (`TestUnknownToolStaysSilent`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-060` | `seq` wird vergeben, nicht abgeleitet; dazu Nebenläufigkeit, Modus, Strom-Trennung und die Ableitung von `slice`, `requirement` und `branch` | `internal/span/span_test.go` · `test/mutations/109-span-folgenummer-eingefroren.sh` (`TestSeqIsAssignedNotDerived`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-061` | Ein `Pflicht`-Feld steht auch bei leerem Wert in der Zeile: ein `omitempty` am falschen Feld ließe es lautlos verschwinden — an `tool_use_id`, an `branch` und an `tool` | `TestMandatoryFieldsAlwaysPresent` · `test/mutations/110-span-pflichtfeld-verschwindet.sh` · `test/mutations/111-span-korrelationsfeld-verschwindet.sh` · `test/mutations/130-span-werkzeugfeld-verschwindet.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-062` | Der Emitter ist vorhanden und funktionsfähig, und der Ablageort ist ein gitignorierter Pfad, real `git check-ignore`-geprüft | `make span-check` · `test/mutations/113-span-ablageort-getrackt.sh` (`TestSpansLandInStateDir`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-063` | Ein liegengebliebenes Lock-Verzeichnis legt den Strom nicht lautlos still | `test/mutations/114-span-lock-verzeichnis.sh` (`TestLeftoverLockDirectoryDoesNotBlock`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-064` | Kein Freitext aus dem Ergebnis: für jedes Werkzeug die Länge, darüber hinaus nur die Positiv-Liste bei `Agent` | `test/mutations/115-span-ergebnis-inhalt.sh` (`TestDurationAndResultSize`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-065` | Der Träger arbeitet als Prozess, mit dem Unterkommando als Argument, so wie der Hook ihn ruft; der `span-emit`-Zweig ist nicht auf die Auswertung umgehängt | `TestClampSurvivesBrokenPayload` · `TestEmitWritesSpanFromHook` · `TestSubkommandoRouting_ReportSchreibtBilanz` · `test/mutations/154-unterkommando-routing-vertauscht.sh` (`TestClampSurvivesBrokenPayload`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-066` | Keines der vier Freitext-Felder `content`, `prompt`, `description`, `outputFile` erreicht die Zeile, je mit eigenem Kanarienvogel | `TestNoResponseFreetextReachesSpan` · `test/mutations/123-span-ergebnis-content.sh` · `test/mutations/124-span-ergebnis-prompt.sh` · `test/mutations/125-span-ergebnis-description.sh` · `test/mutations/126-span-ergebnis-outputfile.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-067` | Ein ungelisteter Schlüssel der `tool_response` bleibt draußen, auch ein verschachtelter — die Grenze der Positiv-Liste selbst | `TestUnlistedResponseKeyStaysOut` · `test/mutations/127-span-positivliste-negiert.sh` (der tragende Fall: vier namentliche Fälle unterscheiden eine Positiv-Liste nicht von einer Implementierung, die genau diese vier ausfiltert) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-068` | Die Achse ist der Werkzeug-Name, nicht die Gestalt der Antwort: `Bash`, `Read` und `Write` geben keine Zähler, keine Rolle und kein Modell preis | `TestOnlyAgentToolGetsResponseValues` · `test/mutations/133-span-werkzeugachse-geweitet.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-069` | `spawned_role` kommt aus `tool_response.agentType`, nie aus `tool_input.subagent_type` (B1) | `TestAgentGetsNoArgumentFields` · `test/mutations/132-span-rolle-aus-argument.sh` (bindet die Eigenschaft B1, nicht den `mustNotContain`-Eintrag; den bindet der Fall der Draht-Form in `SPEC-083`) | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-070` | `Agent` liegt auf keiner Gattungszeile: kein `path`, `program`, `argc`, `bytes`, `sha256_16` (B2) | `TestAgentGetsNoArgumentFields` · `test/mutations/135-span-agent-auf-gattungszeile.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-071` | `spawned_role` wird gegen die sechs kanonischen Namen (`SPEC-042`) normalisiert; `general-purpose` steht nie als Rolle im Span | `TestSpawnedRoleIsNormalised` · `test/mutations/128-span-rolle-unnormalisiert.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-072` | Die Schranke um `model_version` verwirft, statt zu kürzen (die feinere der beiden Zusagen; sie impliziert die gröbere) | `TestResolvedModelIsStructurallyBounded` · `test/mutations/129-span-modellschranke-kuerzt.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-073` | Kein halber Span, Eintrag `input_tokens`: er fehlt im fehlgeschlagenen `Agent`-Aufruf, statt anwesend und ungemessen dazustehen | `TestFailedAgentCallCapturesNothing` · `test/mutations/134-span-zaehler-praesent-leer.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-074` | Kein halber Span, Eintrag `output_tokens` | `TestFailedAgentCallCapturesNothing` · `test/mutations/136-span-ausgabezaehler-praesent-leer.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-075` | Kein halber Span, Eintrag `spawned_role` | `TestFailedAgentCallCapturesNothing` · `test/mutations/137-span-rollenfeld-praesent-leer.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-076` | Kein halber Span, Eintrag `cache_creation_input_tokens` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt und ist nicht herstellbar, solange `input_tokens` per Teilstring in derselben `mustNotContain`-Liste steht: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-077` | Kein halber Span, Eintrag `cache_read_input_tokens` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt und ist nicht herstellbar, solange `input_tokens` per Teilstring in derselben `mustNotContain`-Liste steht: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-078` | Kein halber Span, Eintrag `total_tokens` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-079` | Kein halber Span, Eintrag `total_duration_ms` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-080` | Kein halber Span, Eintrag `total_tool_use_count` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-081` | Kein halber Span, Eintrag `model_version` | `TestFailedAgentCallCapturesNothing` prüft den Eintrag; ein Fall, der ihn bindet, fehlt: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-082` | Ein `Agent`-Span ist an der geschriebenen Zeile als solcher erkennbar (`"tool":"Agent"`): die Voraussetzung der Gegenprobe der Zusagen zu `spawned_role` | `TestAgentGetsNoArgumentFields` · `TestFailedAgentCallCapturesNothing` · `test/mutations/131-span-werkzeugname-leer.sh` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| `SPEC-083` | Die Draht-Form von `spawned_role` ist abwesend statt `""`: ein `"spawned_role":""` in jedem `Bash`-Span behauptete einen Subagenten, den es nicht gab; die Lesevorschrift (`SPEC-044`) ruht darauf. Jeder der zwei Wächter trägt dafür seinen eigenen `mustNotContain`-Eintrag | `TestAgentGetsNoArgumentFields` · `test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh`; `TestFailedAgentCallCapturesNothing` · `test/mutations/137-span-rollenfeld-praesent-leer.sh`; die Herkunfts-Achse des zweiten Wächters: `—` | [LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

## 6. Externe Verträge

Schnittstellen zu Systemen, die uns nicht gehören, je mit der Fassung, gegen die
festgelegt ist.

| ID | System | Version | Vertrag-Datei |
|---|---|---|---|

## 7. Historie

| Datum | Änderung |
|---|---|
| 2026-08-01 | Initial |
| 2026-08-02 | §5 nimmt das Span-Schema auf (Feldtabelle mit Sensor-Spalte, Werkzeug-Liste, Positiv-Liste, Start-Konvention, sechs erklärte Abweichungen, Wächter-Bindungen); §3 nimmt die strukturelle Schranke um `model_version` auf |
| 2026-08-28 | §5: Der Absatz über die kanonischen Agenten-Typ-Namen nennt keine Abweichung mehr — der adoptierte Baseline-Stand `v5.12.0` schreibt die dritte Rolle `Implementer` statt `Implementation`, womit die sechs Bezeichner die sechs Rollen-Namen des Moduls in Kleinschreibung sind. Der Wert selbst ist unverändert |
| 2026-09-02 | §3, §5 und §6 tragen die `ID`-Spalte mit fortlaufendem `SPEC-<NNN>`; §7 führt keine `ADR`-Spalte mehr |
| 2026-09-17 | Die Aufnahme-Regel und §5 nennen die Herkunft ihrer Regeln nicht mehr, die Aussagen bleiben. Die Regel zum Sammelposten in §5 steht ohne Zitat und sagt nur noch, dass begründet aufgeteilt wird |
| 2026-09-18 | §5 trägt keine Referenz nach außen mehr: Die Aussagen über Verbrauchs-Achse, Hooks-Referenz, Guard-Bedingungen und Cache-Zähler stehen ohne Verweis auf Carveout, Review-Report, Nutzer-Doku, Briefing und Adaptions-Block. Der Name der gelesenen Quelle `docs/user/claude-hooks-referenz.md` bleibt als Text stehen, weil die Aussage ohne ihn nicht prüfbar ist; die erklärten Abweichungen selbst bleiben unverändert in §5 |
| 2026-09-30 | §3 und §5: Die Tabellen tragen die Spalte `Präzisiert` (Anker-Link ins Lastenheft oder `Lücke`); der Fließtext von §5 steht als Tabellenzeilen `SPEC-035` bis `SPEC-086` (Regeln der Erfassung, Zusicherungen mit Sensor). Begründungen, Messprotokolle und Prozess-Konventionen stehen nicht mehr in der Spezifikation; die Aufnahme-Regel nennt diese Klassen. Die Werte der Zeilen `SPEC-001` bis `SPEC-034` bleiben |
| 2026-09-30 | §5: Jede Zeile mit `Lücke` trägt einen Anker ins Lastenheft; fünf Zeilen (Betriebsart eines Rollen-Laufs, Agent-Guard, Grenze der `mustContain`-Gegenproben, Abweisung ohne Subagent-Typ, Verdrahtung des Guards) stehen nicht mehr hier, weil sie nur dieses Repo betreffen; ihre Zusagen und Grenzen stehen als Kommentar am Guard und am Helfer der Gegenproben. Die Zelle der Berichtsgröße nennt nur noch die Größe |
