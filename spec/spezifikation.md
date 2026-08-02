# Spezifikation — ai-harness-init

**Status:** Aktiv. **Letzte Änderung:** 2026-08-02.

**Bezug zum Lastenheft:** Diese Spezifikation präzisiert die in
[`spec/lastenheft.md`](lastenheft.md) formulierten Anforderungen (`LH-*`-IDs). Bei
Konflikt gewinnt das Lastenheft.

## Aufnahme-Regel

Ein Satz gehört hierher, wenn **alle drei** zutreffen:

1. Er ist eine **technische Festlegung dieses Repos** — ein Wert, ein Feld, eine
   Schranke, eine Fassung. Etwas, gegen das gemessen werden kann.
2. Er ist **ohne Vertragsänderung fortschreibbar**: die Anforderung, die er
   präzisiert, bleibt beim Fortschreiben unberührt.
3. Er **wächst mit seinem Gegenstand** — die nächste Zeile seiner Tabelle verdrängt
   keinen anderen Text.

Nicht hierher gehören: die **Begründung** einer Entscheidung (sie steht in der
Entscheidung und zeigt von dort aufwärts hierher), die **Abweichung** von der
adoptierten Baseline (repo-lokales Konventionsdokument), die **Anforderung**
([`spec/lastenheft.md`](lastenheft.md)) und die **Komponentensicht**.

Zwei Formregeln, weil beide von außen gelesen werden:

- **Der bindende Text zeigt nicht abwärts.** Außerhalb der [Historie](#7-historie)
  steht hier keine Entscheidungs- und keine Planungs-Kennung: ein Wert steht für
  sich, das Warum findet man über die aufwärts zeigende Entscheidung. Gemessen wird
  davon in `.d-check.yml` der **Link, dessen Ziel eine Entscheidungs- oder eine
  Planungs-Datei ist** (`matrix`-Klasse `spec-straten` — rot wird die Klasse des
  Ziels, nicht der Text der Kennung), und die **nackte** Entscheidungs-Kennung
  (`ids`); eine nackte Planungs-Kennung und jede Kennung, deren Link woanders endet,
  trifft kein Muster — dort gilt die Regel ohne Wächter.
- **Abschnittsnummern werden nie neu vergeben.** Sie sind die der vendored Vorlage
  `.harness/baseline/v3.5.2/templates/spec/spezifikation.template.md`; ein
  Abschnitt ohne Inhalt lässt seine Nummer frei, und ein hinzukommender bekommt
  seine eigene. Neu zu nummerieren verschöbe die Anker, auf die von außen gezeigt
  wird — und ein Teil dieser Zeiger steht in Dokumenten, die nicht mehr geändert
  werden dürfen.

---

## 3. Defaults und Konstanten

Werte, die in Code, Konfiguration oder Gate-Schwelle fest sind — je mit der
Begründung ihrer Höhe, nicht nur mit ihrer Höhe.

| Name | Wert | Begründung |
|---|---|---|
| `model_version` — Länge | höchstens **64** Byte | `model_version` ist der einzige Rohstring unter den neun Werten, die aus dem Werkzeug-Ergebnis erfasst werden; die übrigen acht sind Zahlen oder das gegen sechs Namen normalisierte Etikett. Was die Schranke nicht erfüllt, wird **verworfen, nicht gekürzt**: 64 Byte eines Geheimnisses sind auch 64 Byte fremden Inhalts, und ein verstümmeltes Präfix ist ein falsches Protokoll, wo „unbekannt" das ehrliche ist (dieselbe fail-closed Linie wie `commandProgram`) |
| `model_version` — Zeichensatz | geschlossen: Buchstaben, Ziffern, `.`, `_`, `-` und die Klammern `[` `]` | Die Klammern gehören zur Bezeichner-Sprache des Herstellers. **Der Zeichensatz ist eine Entscheidung unter Unsicherheit, und das gehört gesagt:** die Messung erfasste nur Schlüsselnamen und Wertlängen, nie Werte — die Gestalt eines echten `resolvedModel` ist **nicht** gemessen. Der Fehlermodus ist ein **fehlendes** Feld, nicht ein falsches, und er ist am Bestand ablesbar: trägt kein `Agent`-Span mit Zählern ein `model_version`, ist die Schranke zu eng geraten und wird **hier** geweitet, nicht im Code aufgeweicht |

## 5. Metriken und Tracing-Felder

Die verbindlichen Felder je Span, jedes mit seiner Pflichtigkeit, der Incident-Frage,
die es beantwortet, und dem Wächter, der seine Zusicherung hält; dazu je erklärter
Abweichung vom Pflicht-Minimum eine Begründung. Ein Feld ohne Incident-Frage wird
nicht erfasst.

**Gegenstand** sind die Spans, die `cmd/span-emit` je Tool-Call in den gitignorierten
Zustands-Bereich schreibt (Logik in `internal/span/`).

**Das Schema ist GESCHLOSSEN.** Erfasst wird, was hier steht; jedes andere Feld einer
künftigen Payload wird **nicht** still mitgeschrieben. Wer eines aufnimmt, trägt es hier
ein — mit seiner Incident-Frage, sonst gar nicht (*„Ein Attribut ohne Incident-Frage
fliegt raus"*,
[Modul 15 §Span-/Audit-Attribut-Regeln](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)).
Die Tabelle ändert sich mit jedem neuen Feld — jede Änderung ist ein Eintrag hier, kein
Nebeneffekt im Skript.

**Was die vierte Spalte sagt und was nicht.** Sie nennt den Wächter, der die Zusicherung
der Zeile hält; *Fall N* meint `test/mutations/N-*.sh`. Ein Strich heißt: für diese Zeile
ist kein Wächter namentlich gebunden. Zusicherungen, die keine Zeile dieser Tabelle sind,
stehen im Punkt **Bewacht** am Ende des Abschnitts. **Die Nennung selbst ist unbewacht:**
kein Gate prüft, ob ein hier oder unter **Bewacht** genannter Wächter noch existiert oder
noch so heißt — `codepaths` validiert nur Pfade unter seinen `roots` (`spec`, `docs`,
`harness`), ein erfundener Pfad unter `test/` oder `internal/` bleibt still und derselbe
unter `harness/` meldet `codepath-missing` (gemessen); `make mutate` fährt nur die
Fall-Dateien, die es findet; `make comment-claims` lässt jede Markdown-Datei außen vor.
Die Spalte ist damit **Feedforward**: ihre Alterung fängt niemand mechanisch, und wer eine
Zeile ändert, zieht ihren Wächter von Hand nach (Sonden und Gegenproben in
[`MR-021`](../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)).

| Feld | Pflicht | Incident-Frage | Sensor |
|---|---|---|---|
| `seq` | Pflicht | *Fehlt ein Span?* — je Strom monoton steigend, damit der **Leser** eine Lücke sieht | `internal/span/span_test.go` · Fall 109 |
| `ts` | Pflicht | *Wann geschah es?* | — |
| `event` | Pflicht | *Erfolg oder Fehlschlag?* (Nach- bzw. Fehlschlag-Ereignis) | — |
| `tool` | Pflicht | *Welches Werkzeug lief?* | `TestMandatoryFieldsAlwaysPresent` · Fall 130 |
| `tool_use_id` | Pflicht | *Welche Ereignisse gehören zu einem Aufruf?* | `TestMandatoryFieldsAlwaysPresent` · Fall 110 |
| `session`, `agent` | Pflicht | *Welcher Lauf war es?* — zusammen bilden sie den **Strom** | `internal/span/span_test.go` (Strom-Trennung) |
| `agent_type` | Pflicht | *Welche Art Lauf?* — der **Subagent-Typ** der Payload, roh. **Pflicht wie `agent`**: die vier Felder `session`/`agent`/`agent_type`/`agent_role` sind ein Block, und leer ist dort eine Aussage (Haupt-Kontext), kein fehlender Wert | — |
| `agent_role` | Pflicht | *Welche Rolle verursachte den Zugriff?* — das Pflichtfeld aus [Modul 15](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln). Gefüllt, wenn `agent_type` eine Harness-Rolle **nennt** (`planner`, `architect`, `implementer`, `reviewer`, `verifier`, `validator`). **Leer heißt UNBEKANNT, nie „rollenlos"** — s. die Lesevorschrift unten | — |
| `slice` | Pflicht | *Auf wessen Rechnung lief der Zugriff?* — aus dem Lifecycle-Verzeichnis, Liste (kein Slice ⇒ leer und als leer erkennbar) | `internal/span/span_test.go` (Ableitung) |
| `requirement` | Pflicht | *Gegen welche Anforderung?* — aus der `Bezug:`-Zeile der Slices, Liste | `internal/span/span_test.go` (Ableitung) |
| `adr` | Pflicht | *Auf wessen Entscheidung lief der Zugriff?* — die dritte Korrelations-Achse aus [Modul 15 §Kernidee](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#kernidee-modul-15), aus demselben `Bezug:`-Block wie `requirement`, Liste | — |
| `branch`, `commit` | Pflicht | *Zu welcher Änderung gehört der Zugriff?* — die dritte Korrelations-Achse aus [Modul 15](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln) (*Slice/**PR**/Agent-Rolle*), abgeleitet aus `.git/HEAD`; die PR-Nummer selbst ist nicht erreichbar, s. Abweichung 2 | `internal/span/span_test.go` (Ableitung von `branch`) · Fall 111 |
| `status` | Pflicht | *Ging es gut?* | — |
| `permission_mode` | Optional | *Unter welcher Berechtigungs-Lage?* | — |
| `path` | Optional | *Was wurde wohin geschrieben/gelesen?* — nur bei namentlich gelisteten Datei-Werkzeugen | — |
| `bytes`, `sha256_16` | Optional | *Hat sich etwas geändert?* — aus dem **Dateisystem**, nie aus der Payload | — |
| `duration_ms` | Optional | *Wie lange dauerte der Aufruf?* — aus der Payload übernommen. Ohne sie ist **Gleichzeitigkeit nicht entscheidbar**: ein Span trägt sonst nur seinen Abschluss, und zwei Ströme lassen sich nicht überlagern | — |
| `result_bytes` | Optional | *Wie groß war das Ergebnis?* — **nur die Länge, nie der Inhalt**; gemessen wird die **JSON-Kodierung**, wie die Payload sie trägt (samt Anführungszeichen und Escapes), nicht die Zeichenzahl des Ergebnisses. Ohne sie ist nicht entscheidbar, ob ein **einzelner** Aufruf eine Ressourcenspitze erklärt | — |
| `program`, `argc` | Optional | *Welches Programm lief?* — erstes Token und Argument-Anzahl, nie die Kommandozeile | — |
| `spawned_role` | Optional | *Welche Rolle lief im Subagenten — auf wessen Rechnung geht sein Verbrauch?* — aus `tool_response.agentType`, gegen die sechs kanonischen Typnamen normalisiert. **Nie** aus `tool_input.subagent_type`: das ist die *Anforderung*, nicht der *Lauf*, und es liegt auf der Argument-Achse. Eigener Feldname, weil `agent_type`/`agent_role` schon den Typ des **laufenden** Agenten führen. **ABWESEND heißt UNBEKANNT, nie „rollenlos"** — dieselbe *Lesart* wie bei `agent_role`, aber ausdrücklich **nicht** dessen Draht-Form: `agent_role` ist **Pflicht** und steht als `""` in jeder Zeile, `spawned_role` ist `omitempty` und **fehlt** bei leerem Wert. Das ist Absicht und keine Nachlässigkeit — ein `"spawned_role":""` in jedem `Bash`-Span behauptete einen Subagenten, den es nicht gab; die Present-and-empty-Regel gilt für den Vierer-Block, den **jeder** Span trägt, nicht für ein Feld, das nur ein Werkzeug erzeugt. **Unterscheidbar bleibt es am Pflichtfeld `tool`:** ein `Agent`-Span **ohne** `spawned_role` ist ein Lauf mit *unbekannter* Rolle und gehört in den Sammelposten — eine Auswertung, die nach `spawned_role: ""` sucht, findet ihn nicht und darf ihn deshalb nicht aus der Bilanz fallen lassen | `TestAgentGetsNoArgumentFields` (Herkunft und Draht-Form) und `TestFailedAgentCallCapturesNothing` (Draht-Form), `TestSpawnedRoleIsNormalised` (Normalisierung) · Fälle 128, 132, 137, 138 |
| `input_tokens`, `output_tokens` | Optional | *Wie teuer war dieser Subagenten-Lauf?* — die Verbrauchs-Achse, ohne die eine Token-Bilanz je Rolle eine Summe statt einer Rechnung ist | `TestFailedAgentCallCapturesNothing` · Fälle 134, 136 |
| `cache_creation_input_tokens`, `cache_read_input_tokens` | Optional | *Zahlte der Lauf den Cache oder nutzte er ihn?* — der Cache-Status, für Subagenten-Läufe **erfasst** (Abweichung 1 unten, dort auf den Rest-Zustand zurückgeschnitten) | — |
| `total_tokens` | Optional | *Wie groß war der Lauf insgesamt?* — die Summe, die das **Werkzeug selbst** ausweist. Am eigenen Bestand nachgerechnet **ist** sie die Addition der vier Zähler, exakt, an jedem geprüften Zähler-Span. Eine Auswertung addiert sie deshalb **nicht** zu den vier, sondern gegen sie. **Hier steht bewusst keine Zahl und keine Stichprobengröße:** der Bestand unter `.harness/state/spans/` ist gitignored, maschinenlokal und wächst mit jedem Subagenten-Lauf — eine eingefrorene Rechnung ist für einen anderen Checkout ohnehin nicht nachvollziehbar. Die Probe gehört **gefahren**, nicht zitiert, und sie bleibt eine Stichprobe | — |
| `total_duration_ms` | Optional | *Wie lange lief der Subagent wirklich?* — **nicht** `duration_ms`: das misst den Aufruf, wie der Hook ihn sieht. Die Erfassung hängt an `PostToolUse`/`PostToolUseFailure`, der Hook feuert also **nach** dem Aufruf; `duration_ms` ist die Wanduhr des ganzen Werkzeug-Aufrufs und liegt deshalb in einem Vordergrund-Lauf **über** `total_duration_ms`, um Anlauf und Rückgabe. Wer die Reihenfolge umdreht, liest die Differenz als Subagenten-Zeit. **Die Probe gehört gefahren, nicht zitiert** (hier steht darum keine Zahl): jeder `Agent`-Span mit beiden Werten zeigt sie, und ein Span, in dem `duration_ms` **unter** `total_duration_ms` liegt, wäre der Befund. Ein im **Hintergrund** gelaufener Aufruf trägt gar kein `totalDurationMs`; sein `duration_ms` ist klein, weil das Werkzeug für einen Hintergrund-Subagenten sofort nach dem Start zurückgibt. Jede Paarung gehört ihrem Aufruf; zwei Beobachtungen zu einer zu fügen ergäbe eine Messung, die niemand gemacht hat | — |
| `total_tool_use_count` | Optional | *Wie viele Werkzeug-Aufrufe verursachte der Subagent?* — der Teiler, ohne den „Token je Aufruf" nicht rechenbar ist | — |
| `model_version` | Optional | *Welches Modell verursachte die Kosten?* — das Label `model.version` aus [Modul 15 §Cache-Counter-Regeln](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#cache-counter-regeln), aus `tool_response.resolvedModel`, **strukturell begrenzt** (Länge und geschlossener Zeichensatz, [§3](#3-defaults-und-konstanten)). Was die Gestalt eines Bezeichners nicht hat, wird **verworfen, nicht gekürzt** | `TestResolvedModelIsStructurallyBounded` · Fall 129 |

**Welches Werkzeug gibt was preis — die namentliche Liste.** Die Feldtabelle oben sagt
*„nur bei namentlich gelisteten Werkzeugen"*; hier stehen die Namen. Ein Werkzeug
aufzunehmen ist eine **Entscheidung** und wird hier eingetragen, nicht im Code
nachgezogen.

| Werkzeug-Name | erfasst zusätzlich zu Name und Status |
|---|---|
| `Write`, `Edit`, `MultiEdit`, `NotebookEdit` | `path` (aus `file_path`/`notebook_path`) + `bytes` + `sha256_16` **aus dem Dateisystem** |
| `Read` | `path` — **kein** Fingerabdruck (er wäre auf einem gelesenen Pfad ein Bestätigungs-Orakel ohne Incident-Frage) |
| `Bash` | `program` (erstes Token nach übersprungenen `NAME=WERT`-Präfixen) + `argc` |
| `BashOutput` | **nichts** — seine Eingabe ist eine Shell-Kennung, keine Kommandozeile |
| `Agent` | `spawned_role` + die vier `usage`-Zähler + `total_tokens` + `total_duration_ms` + `total_tool_use_count` + `model_version` — **neun Werte aus sechs Schlüsseln**, alle aus `tool_response` und alle nach der **Positiv-Liste** (nächster Punkt). **Kein** `path`, `program`, `argc`, `bytes`, `sha256_16`: aus `Agent`s `tool_input` erreicht nichts den Span (dort liegen `subagent_type`, `prompt`, `description`, `run_in_background`; `ToolInput` in `internal/span/span.go` führt genau drei Felder) |
| **jedes andere** | **nichts** — der fail-closed Default |

Die Werkzeug-Achse ist der Werkzeug-**Name**, nicht die Gestalt der Antwort; bewacht von
`TestOnlyAgentToolGetsResponseValues` · Fall 133, und die `Agent`-Zeile zusätzlich von
`TestAgentGetsNoArgumentFields` · Fall 135 (`Agent` liegt auf **keiner** Gattungszeile).

**Die Erfassung aus `tool_response` ist eine POSITIV-Liste, und die Form ist tragend.**
`tool_response` trägt vier gemessene Freitext-Felder — `content` (der vollständige Bericht
des Subagenten, der größte Freitext-Block des ganzen Aufrufs), `prompt`, `description`,
`outputFile` — und `prompt` ist genau das Feld, das nie ins Log darf. Es steht auf **beiden**
Erfassungs-Flächen eines `Agent`-Aufrufs — in den **Argumenten** (`tool_input`) und im
**Ergebnis** (`tool_response`) —, und das Ergebnis ist nicht die harmlosere der beiden.
Daraus fünf Festlegungen:

1. **Erfasst wird ausschließlich, was `responseKeys()` in `internal/span/response.go`
   namentlich nennt** — sechs Schlüssel, **neun** Blatt-Werte (die vier `usage`-Zähler
   einzeln), oben in **sieben** Tabellenzeilen geführt. Wer die drei Zahlen verwechselt,
   zählt Rolle und Modell nicht mit — genau die zwei Werte, an denen die Grenzen des
   Erfassungs-Umfangs hängen. Alles andere fällt heraus, **ohne genannt zu werden**: es
   gibt keinen Zweig, der einen ungelisteten Schlüssel überhaupt ansieht. Das ist der
   konstruktive Ausschluss, den das geschlossene Schema verlangt.
2. **Positiv und nicht negativ.** Vier gemessene Aufrufe zeigten **fünf** undokumentierte
   Schlüssel; die Fläche wächst erkennbar weiter. Eine Negativ-Liste altert mit jedem neuen
   Antwortfeld, eine Positiv-Liste hält auch beim fünften Freitext-Feld.
3. **Der Fehlschlag braucht keine Sonderregel.** Bei einem fehlgeschlagenen Agenten-Aufruf
   fehlt `tool_response` **ganz** (gemessen — nicht leer, sondern nicht vorhanden); es
   existiert also nichts Gelistetes. Es entsteht ein Span mit Name und Status, kein halber.
4. **`model_version` ist der einzige Rohstring** unter den neun Werten — die übrigen acht
   sind Zahlen oder das gegen sechs Namen normalisierte Etikett. Er trägt deshalb eine
   **strukturelle** Schranke; Wert und Begründung stehen in
   [§3](#3-defaults-und-konstanten). Was sie nicht erfüllt, wird **verworfen, nicht
   gekürzt**.
5. **Die Zähler kommen nur im Vordergrund an.** Ein Hintergrund-Lauf liefert weder Zähler
   noch `agentType`, dafür u. a. `agentId`, `isAsync`, `outputFile` und `canReadOutputFile`
   (gemessen); die Erfassung ist insoweit konstruktiv unvollständig. Den Vordergrund
   **herstellt** hier ein `PreToolUse`-Hook, der den Start **verweigert**: der Guard
   `.claude/hooks/pretooluse-agent-guard.sh`, und er tut es für **Rollen**-Typen. **Dass das
   der einzige Weg wäre, steht hier nicht** — die vendored Hooks-Referenz
   [`docs/user/claude-hooks-referenz.md`](../docs/user/claude-hooks-referenz.md) führt für
   dasselbe Ereignis ein `updatedInput`, das die Tool-Argumente **vor** der Ausführung
   ersetzt und sich ausdrücklich mit `"allow"` kombinieren lässt; ein Hook könnte den
   Schalter also **umschreiben** statt abzulehnen. **Gemessen ist dieser zweite Weg nicht:**
   ob das Agenten-Werkzeug ein umgeschriebenes `run_in_background` befolgt, hat niemand
   geprüft. Er steht hier als benannte, ungeprüfte Alternative — wer abwägt, ob die
   Telemetrie den Preis der Vordergrund-Bedingung wert ist (sie kostet Parallelität), soll
   nicht zwischen „verweigern" und „aufgeben" wählen müssen, weil ein dritter Weg ungenannt
   blieb. Die **Regel** dazu — wie ein Rollen-Lauf zu starten ist — steht als
   **Start-Konvention** im nächsten Punkt; hier steht nur ihre Folge für die Erfassung. Was
   der Guard nicht herstellt, steht als **Abweichung 5** unten.

Die Positiv-Liste selbst ist bewacht: `TestNoResponseFreetextReachesSpan` (keines der vier
Freitext-Felder erreicht die Zeile, je mit eigenem Kanarienvogel) · Fälle 123, 124, 125, 126;
`TestUnlistedResponseKeyStaysOut` (die **Grenze** selbst — ein ungelisteter Schlüssel bleibt
draußen, auch ein verschachtelter) · Fall 127; `TestFailedAgentCallCapturesNothing` (**kein
halber Span**: die neun Werte fehlen, statt anwesend-und-ungemessen dazustehen).

**Die START-KONVENTION für Rollen-Läufe — zwei Bedingungen, zwei BELEGKLASSEN.** Die
Erfassung oben setzt einen so gestarteten Lauf voraus; die Regel gehört deshalb hierher und
nicht in ein Gedächtnis. Wer Rollen-Arbeit an einen Subagenten gibt, startet ihn

1. **unter seinem Rollen-Typ, per @-Erwähnung** — das entscheidet, **WELCHE** Rolle läuft.
   **Belegklasse: fremde Doku, im Repo NICHT vorliegend.** Die Subagenten-Seite der
   Herstellerseite (`/docs/de/sub-agents`) nennt die @-Erwähnung als den Weg, der die
   Ausführung *garantiert*, während natürliche Sprache die Delegation dem Modell überlässt.
   Die vendored Hooks-Referenz
   [`docs/user/claude-hooks-referenz.md`](../docs/user/claude-hooks-referenz.md)
   **verweist** in ihrem `Agent`-Eintrag nur auf diese Seite und trägt den Satz nicht. Er
   steht hier als **fremde Zusage**, nicht als Repo-Beleg — wer ihn nachprüfen will, findet
   im Repo nichts, woran.
2. **im VORDERGRUND** — `run_in_background: false`; das entscheidet, **WIE** er läuft.
   **Belegklasse: gemessen, und zusätzlich repo-lokal dokumentiert.** Gemessen ist, dass ein
   Hintergrund-Lauf keine Verbrauchs-Achse trägt — im Einzelnen in **Abweichung 5**, hier
   nicht wiederholt. Dokumentiert ist dasselbe in der Hooks-Referenz: ihr `Agent`-Eintrag
   führt den Hintergrund als **Standard** und sagt, die Antwort eines
   Hintergrund-Subagenten trage keine Nutzungsfelder, sondern `status: "async_launched"`,
   `agentId`, `description`, `prompt`, `outputFile` und `resolvedModel`. Zwei unabhängige
   Belege für dieselbe Bedingung — und der einzige Punkt dieser Konvention, für den das
   gilt.

**Die zwei Bedingungen sind UNABHÄNGIG — gemessen, nicht angenommen.** Ein per @-Erwähnung
angeforderter Lauf **ohne** ausdrücklichen Schalter lief im **Hintergrund**. Der Hook feuert
**nach** dem Aufruf (`PostToolUse`); eine kleine Dauer ist also die Dauer des **Aufrufs** —
das Werkzeug gab sofort nach dem Start zurück, wie es die Hooks-Referenz für
Hintergrund-Subagenten beschreibt. Genau darum trägt die Beobachtung etwas: feuerte der Hook
beim Start, stünden bei jedem Lauf drei Millisekunden da und sie wäre leer. Die @-Erwähnung
wählt den **Typ**, nicht die **Betriebsart**. Wer nur Bedingung 1 einhält, bekommt **keine
Zahl** — und je nach Typ auch keinen Span: bei einem **Rollen**-Typ verweigert der Guard den
Start, sobald der Aufruf ihn mit diesem Typ erreicht, und ein geblockter Aufruf hinterlässt
keinen Span; bei jedem anderen Typ läuft der Aufruf durch, und seine Antwort trägt weder
Zähler noch `agentType`, also auch kein `spawned_role`. „Die Rolle und keine Zahl" trifft
damit keinen der beiden Fälle: die Rolle kommt aus `agentType`, und das fehlt im
Hintergrund.

**Was diese Konvention ERZWINGT und was sie nur behauptet** — beides gehört in denselben
Punkt, sonst liest sich die Regel breiter als ihr Sensor
([`AGENTS.md`](../AGENTS.md) §3.6):

- **Für Bedingung 2 gibt es einen Wächter, und seine Zusage reicht genau so weit wie seine
  Entscheidung: der `PreToolUse`-Guard `.claude/hooks/pretooluse-agent-guard.sh` lehnt einen
  Aufruf ab, den er mit erkennbarem Rollen-Typ und ohne `run_in_background: false` sieht.**
  **Was damit NICHT zugesagt ist — und der Unterschied ist der ganze Punkt:** dass jeder
  Rollen-Lauf am Ende Zähler trägt. Der Guard entscheidet über die **Aufrufform**, die ihm
  der Hook vor dem Start vorlegt; über den Ausgang des Laufs entscheidet er nicht mit, und
  der Bestand dieses Repos trägt einen `Agent`-Span eines **Rollen**-Typs, der von den neun
  Werten nur `model_version` führt. Ableitung der Rollen-Liste, fail-closed-Politik bei
  fehlendem Schalter und fehlendem Typ, Dauer-Sensoren und **Grenzen** stehen in
  **Abweichung 5**; kurz: er greift nur für Typen mit einer Datei in `.claude/agents/`, er
  sieht nur den Start, und er kann fehlen oder abgeschaltet sein.
- **Bedingung 1 ist NICHT durchgesetzt — und der Grund trägt nur für einen Teil der
  Payload.** `tool_input` trägt die Schlüssel `subagent_type`, `prompt`, `description` und
  `run_in_background`; das dokumentierte Eingabe-Schema in der Hooks-Referenz nennt darüber
  hinaus nur `model`. Für die **typisierten** Schlüssel — `subagent_type`,
  `run_in_background`, `model` — ist die Sache entschieden: sie führen den Typ und die
  Betriebsart, nicht den Weg der Anforderung; ein per @-Erwähnung angeforderter Rollen-Typ
  und ein sprachlich delegierter kommen **in ihnen** identisch an. Für `prompt` und
  `description` ist sie es **nicht**: das sind Freitext-Felder des Aufrufers, und dieselbe
  Messung erfasste ausdrücklich **nur Feldnamen und Wertlängen, nie Werte**. Ob sich eine
  @-Erwähnung im `prompt` niederschlägt, ist damit in **keine** Richtung gemessen — die
  Ableitung aus Schlüssel*namen* reicht über Felder, deren *Inhalt* niemand angesehen hat,
  nicht hinaus. **Kein Sensor dieses Repos prüft Bedingung 1**, und der Grund ist
  zweigeteilt: für die typisierten Felder, weil dort nichts steht, worauf er prüfen könnte;
  für die zwei Freitext-Felder, weil niemand nachgesehen hat. Ein Sensor dort wäre keine
  ausgeschlossene, sondern eine **ungetroffene** Entscheidung — der bestehende `Bash`-Guard
  liest die volle Kommandozeile, ohne sie zu protokollieren; die Trennung zwischen *lesen*
  und *schreiben* ist in diesem Repo etabliert. Was es entschiede, ist benannt: eine
  Werte-Sonde auf `tool_input.prompt` bei einem @-erwähnten Aufruf. Sie ist nicht gefahren.
  Hier **benannt**, nicht mitgezählt. Wer die Rolle nicht anfordert, bekommt
  `general-purpose`: nach der Lesevorschrift zu `agent_role` ein ehrliches „unbekannt", aber
  eben keine Rolle, und der Lauf fällt in den Sammelposten samt Splitting-Pflicht
  (Abweichung 3).

**DASS Rollen-Arbeit als Rolle läuft — die Regel, und warum sie keinen Wächter trägt.** Oben
steht **WIE** ein Rollen-Lauf startet, wenn einer startet; hier steht, **DASS** einer startet:
Arbeit, die einer Harness-Rolle zugeordnet ist, läuft **unter dem Rollen-Typ**; der
Haupt-Kontext orchestriert und ist der **Sammelposten**. **Mechanisch durchsetzbar ist das
nicht** — nicht aus Aufwand, sondern konstruktiv: ob eine Handlung im Haupt-Kontext
„Planner-Arbeit" war, kann niemand maschinell entscheiden; die Payload trägt Werkzeug,
Argumente und Ergebnis, nicht die Zuordnung der Absicht dahinter. Ein Wächter wie der für
Bedingung 2 entscheidet über eine **Aufrufform**, die ihm vor dem Start vorliegt — hier
unterbleibt gerade der Aufruf, den er sähe. **Diese Regel trägt deshalb keinen Wächter**, und
was das für sie heißt, gehört in denselben Satz: sie kann gebrochen werden, ohne dass
irgendetwas rot wird. Sichtbar wird der Bruch allein an der Berichtsgröße im nächsten Punkt;
verhindert wird er von nichts.

**Die BERICHTSGRÖSSE dieser Regel — und die Falle, die sie wertlos machte.** Ablesbar ist die
Regel an der Größe, die Abweichung 3 ohnehin verlangt: dem **Anteil des Sammelpostens** an
einer Token-Bilanz über diesen Bestand. Groß heißt „nicht gelebt". Zwei Festlegungen gehören
dazu:

1. **Der Anteil steht im BERICHT, nie als bestandene Schwelle.** Eine Kennzahl mit Grenze
   erzeugt den Anreiz, Arbeit zu verlagern, damit die Zahl stimmt — statt weil die
   Rollen-Trennung trägt. Gezeigt wird die Größe; entschieden wird an ihr nichts.
2. **„Gedeckt" heißt „Span mit ZÄHLERN", nicht „Span mit irgendeinem erfassten Wert".** Die
   Antwort eines Hintergrund-Laufs trägt von den neun Werten genau `resolvedModel` und keinen
   der acht übrigen — keine Zähler, kein `agentType` (gemessen, Abweichung 5). Ob daraus im
   Span ein `model_version` wird, entscheidet die strukturelle Schranke aus
   [§3](#3-defaults-und-konstanten), und an einem Span aus einem Hintergrund-Lauf ist das
   **nicht beobachtet** (Abweichung 5 (a): abgeleitet, nicht beobachtet). Die Festlegung
   braucht die Beobachtung nicht, weil **beide Ausgänge dasselbe sagen**: kommt der Wert an,
   zählt eine Zahl über „irgendeinen erfassten Wert" genau die Läufe als gedeckt, deren Fehlen
   sie zeigen soll; kommt er nicht an, ruht dieselbe Zahl auf einer Schranke, die niemand
   vermessen hat.

**Die Payload ist die Quelle, die Doku ist Herkunft.** Was aus ihr **nicht erfasst und damit
ausdrücklich abgelehnt** ist: `cwd` (steht implizit im Pfad), `effort` (keine
Incident-Frage), `prompt_id` — letzteres ist ein ernsthafter Kandidat (*„welche Aufrufe
gehören zu einer Nutzer-Anweisung?"*), aber ein neues Feld ist eine Entscheidung und keine
Gelegenheit.

**Die erfasste MENGE, ausgesprochen statt suggeriert.** Verdrahtet sind **zwei** Ereignisse
— `PostToolUse` und `PostToolUseFailure` — je mit leerem Matcher, der **jedes** Werkzeug
sieht (belegt: live liegen Spans für `Bash`, `Read`, `Write`, `Edit`, `Agent`, `ToolSearch`,
`Monitor` vor, auch aus Subagenten-Strömen). Erfasst wird damit der **abgeschlossene**
Aufruf. **Nicht erfasst und nicht behauptet:** ein vom PreToolUse-Guard **geblockter** Aufruf
hinterlässt keinen Span — die Frage *„was wurde versucht und geblockt?"* beantwortet dieses
Schema nicht (`PermissionDenied` ist als eigenes Ereignis Kandidat, aber keine Zusage).

**Der Strom ist `(session, agent)` — die FELDER, nicht der Dateiname.** Der Dateiname ist
eine Ableitung davon und darf sich ändern; die Identität nicht. Eine Doppelvergabe von `seq`
erzeugt keine Lücke; der Leser sieht Vollständigkeit, wo zwei Läufe stehen — genau das
Fehlerbild, gegen das es die Nummern gibt. **Daraus zwei bindende Regeln:** (1) eine
Auswertung gruppiert nach den **Feldern**, nie nach dem Dateinamen, und setzt die
Eindeutigkeit von `seq` **je Datei** voraus, nicht je `(session, agent)`; (2) wer die
Namensbildung ändert, räumt vorher mit `make span-clean` auf — sonst wandert der Bruch in
den Bestand statt in die Änderung.

**Sechs erklärte Abweichungen — sie kommen aus drei Regelblöcken des Observability-Moduls, und
eine weicht von keinem ab.** Das Modul verlangt, jede Abweichung zu benennen statt sie
wegzulassen; von welcher Regel sie abweicht, gehört dazu:

- Vom **Pflicht-Minimum** eines Audit-Span-Schemas — Slice-ID · Agent-Rolle · Cache-Status ·
  `requirement.id`
  ([§Span-/Audit-Attribut-Regeln](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln))
  — weichen **1** (Cache-Status) und **3** (`agent_role`) ab: zwei seiner vier Posten.
- **2** (PR-Nummer) weicht von den **Mindestfeldern eines Tool-Call-Spans** ab
  (*„Korrelations-IDs zu Slice/PR/Agent-Rolle"*, dieselbe
  [Regelgruppe](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln),
  eine andere Liste).
- **5** (Hintergrund-Lauf ohne Verbrauchs-Achse) und **6** (Haupt-Kontext ohne Zahl) weichen von
  den
  [**Token-Attributions-Regeln**](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#token-attributions-regeln)
  ab.
- **4** (Altbestände) weicht von **keiner** Modul-Regel ab. Ihre Quelle ist eine Entscheidung
  dieses Repos über die **Aufbewahrung**, nicht über das Schema; sie steht hier, weil sie
  denselben Gegenstand betrifft.

1. **Cache-Status ist für Subagenten-Läufe im Vordergrund erfasst — für den Haupt-Kontext
   und für Hintergrund-Läufe bleibt er unerreichbar.** Das ist der Rest-Zustand; die
   Abweichung ist **verkleinert, nicht aufgehoben**. **Erfasst** sind
   `cache_creation_input_tokens` und `cache_read_input_tokens` aus dem `usage`-Objekt der
   `tool_response` eines Vordergrund-`Agent`-Aufrufs — ohne Transkript und ohne Zugriff
   außerhalb des Repos. Eine Auswertung, die die Cache-Hit-Rate aus
   [Modul 15 §Cache-Counter-Regeln](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#cache-counter-regeln)
   rechnet, findet für Subagenten-Läufe die **Zähler** vor — Erzeugung und Lesung getrennt,
   wie das Modul es fordert (*„Eine einzelne Metrik `cache.hit_ratio` reicht nicht"*) — und
   darf die Größe **nicht** als unerreichbar führen. **Vollständig ist die Rechnung damit
   nicht, und das gehört in denselben Satz:** das Modul verlangt zu den Zählern die Labels
   `slice.id`, `agent.role` und `model.version`; das Rollen-Label liegt nur vor, wenn
   `spawned_role` gefüllt ist — bei einem `general-purpose`-Subagenten fehlt es, und der
   Lauf gehört in den Sammelposten samt seiner Splitting-Pflicht (Abweichung 3 unten).
   **Unerreichbar bleibt zweierlei, und das ist die fortbestehende Abweichung:** der
   **Hintergrund-Lauf** und der **Haupt-Kontext**. Beiden fehlt nicht nur der Cache-Status,
   sondern die **ganze** Verbrauchs-Achse; sie stehen deshalb als **Abweichung 5 und 6**
   unten. Hier sind sie nur benannt: derselbe Ausfall zweimal beschrieben wäre zwei Stellen,
   die auseinanderdriften. **Warum nicht über das Transkript:** es liegt **außerhalb des
   Repos**, in fremdem Besitz, und trägt den vollen Gesprächsinhalt. Ein Zeiger darauf legt
   eine Auflösung nahe, die niemand genehmigt hat; der `transcript_path` wird deshalb weder
   erfasst noch gelesen.
2. **Die PR-NUMMER steht nicht im Span, ihr Anker schon.**
   [Modul 15](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
   verlangt die Korrelation zu *Slice/PR/Agent-Rolle*. Eine PR-Nummer lebt bei der Forge;
   der Emitter geht nicht ins Netz und ruft kein `gh` (er läuft je Tool-Call). Erfasst werden
   deshalb `branch` und `commit` — die Größen, über die eine Auswertung den PR nachschlägt.
   Das ist eine Ableitung, keine Erfüllung: liegt kein PR zum Branch vor, bleibt die Frage
   offen. Die Felder sind **Pflicht**: ist die Ableitung nicht möglich, stehen sie leer da
   statt zu fehlen — der Unterschied zwischen „unbekannt" und „nicht vorhanden". Ein `.git`
   als Datei (Worktree, Submodul) wird nicht aufgelöst; dann sind beide Felder leer und als
   leer erkennbar.
3. **`agent_role` ist heute durchweg leer, und das ist der Befund — nicht das Feld.** Die
   Payload liefert `agent_type`; dort steht bei Review- **und** Verify-Läufen derselbe Wert
   (`general-purpose`), die beiden Rollen sind in den Daten also ununterscheidbar.
   `agent_role` wird deshalb **abgeleitet, nicht geraten**: nennt der Agenten-Typ eine Rolle,
   ist er die Rolle; sonst bleibt das Feld leer. Es ist trotzdem **Pflicht** — dieselbe
   Begründung wie bei `branch`/`commit`: die Lücke gehört in **jeden** Span, nicht nur in
   diesen Absatz, sonst kann ein Auswerter „unbekannt" nicht von „nicht vorhanden"
   unterscheiden. Aufgelöst wird sie durch rollen-benannte Agenten-Typen — eine
   **Prozess**-Entscheidung, nach der sich das Feld **ohne** Änderung an der Erfassung füllt.

   **Die kanonischen Namen der Agenten-Typen:** `planner` · `architect` · `implementer` ·
   `reviewer` · `verifier` · `validator`.
   [Modul 8](../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice)
   nennt die dritte Rolle *Implementation*; als **Bezeichner** gilt `implementer` — kurz,
   gleichförmig mit den übrigen fünf und bereits im Code. Die Abweichung ist eine
   Schreibweise, keine Rollen-Änderung, und sie steht hier, damit sie nicht im Code lebt.

   **Was auch dann nicht abgedeckt ist:** der Haupt-Strom trägt keinen Agenten-Typ (`agent`
   und `agent_type` sind dort strukturell leer) und wechselt innerhalb einer Sitzung
   zwischen Planer und Implementation. Für ihn ist die Splitting-Regel des Sammelpostens zu
   entscheiden (das Modul verlangt sie begründet, nicht perfekt); ableitbar aus bereits
   erfassten Feldern sind zwei Signale — das `slice`-Feld (Lifecycle-Verzeichnis, WIP-Limit
   1) und das Schreibziel (`docs/plan/` gegen Code-Pfade).

   **Lesevorschrift, bindend für jede Auswertung:** eine Rolle gibt es **immer** — jeder
   Tool-Call wurde von jemandem in einer Rolle verursacht. Ein leeres `agent_role` ist
   deshalb eine Aussage über **unser Wissen**, nicht über den Lauf: es heißt *unbekannt*,
   niemals *ohne Rolle*.

   [Modul 15 §Token-Attributions-Regeln](../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md#token-attributions-regeln)
   verlangt an dieser Stelle wörtlich: *„Wo ein Span keinen Rollen-Tag trägt (Sammelposten),
   entscheide begründet, wie du ihn aufteilst (anteilig nach Tool-Calls? dem auslösenden
   Slice zugeschlagen?)"*. Daraus folgt genau dreierlei, und die Reihenfolge ist die
   Prüfreihenfolge:
   1. **Pflicht:** eine begründete Splitting-Regel, angewendet — am Ende liegt jedes Token
      auf einer der realen Rollen, nicht auf *unbekannt*.
   2. **Ebenfalls Pflicht, weil dieses Repo Annahmen benennt:** wie **groß** der aufgeteilte
      Anteil war. Ohne diese Zahl kann der Leser nicht beurteilen, wie viel des Ergebnisses
      auf der Regel ruht statt auf Messung.
   3. **Falsch ist nur das eine:** den Sammelposten **ungeteilt** als Rolle führen (*„ohne
      Rolle: 60 %"* als Ergebniszeile) — das erfindet eine Kostenstelle, die es nicht gibt.
      Die Größe zu **zeigen** ist erlaubt und erwünscht; sie **stehenzulassen** ist es nicht.

   Nicht gemessen und deshalb offen: ob ein vom **Nutzer** direkt abgesetzter Aufruf einen
   Span erzeugt — dessen Verursacher wäre der Nutzer und keine der sechs Rollen, also eine
   eigene Kostenstelle.
4. **Altbestände werden beim ersten Span einer Sitzung NICHT entfernt.** Ein Entfernen ist
   vorgesehen; der Emitter hängt ausschließlich an. Praktisch folgenlos, solange die
   Sitzungs-Kennung eine UUID ist — aber ein Werkzeug, das Kennungen wiederverwendet, mischt
   zwei Läufe in einer Datei. Aufgeräumt wird ausdrücklich (`make span-clean`), nicht
   nebenbei.
5. **Ein Hintergrund-Lauf trägt keine Verbrauchs-Achse — der Guard verkleinert die Lücke, er
   schließt sie nicht.** *Erst die Prüfung, dann die Abweichung*, und in dieser Reihenfolge,
   weil die deklarierte Abweichung die billige Hälfte ist (*„billiger zu schreiben als eine
   Lösung und deshalb verdächtig"*).
   1. **Ableitbar? Nein — und das ist gemessen, nicht angenommen.** Die `tool_response` eines
      Hintergrund-Laufs trägt `agentId`, `isAsync`, `outputFile`, `canReadOutputFile`,
      `resolvedModel`, `status`, `prompt` und `description`; **keinen** der vier
      `usage`-Zähler, kein `totalTokens`/`totalDurationMs`/`totalToolUseCount`, kein
      `agentType`. Es gibt keinen Teilwert, aus dem ein Zähler folgte. Der einzige Zeiger auf
      mehr — `outputFile` — führt auf einen Freitext-Bestand außerhalb der Payload und ist
      aus demselben Grund ausgeschlossen wie das Transkript in Abweichung 1.
   2. **Vermeidbar? Für die Aufrufform, die der Guard sieht, ja — und nur für sie.** Der
      `PreToolUse`-Guard `.claude/hooks/pretooluse-agent-guard.sh` lehnt einen Agenten-Typ,
      für den `.claude/agents/<name>.md` existiert, im Hintergrund ab; ein **fehlender**
      Schalter gilt dabei als Hintergrund, weil die Abwesenheit der gemessene Normalfall ist,
      und ein **fehlender Typ** als unlesbarer Aufruf, weil der Hook an `"matcher": "Agent"`
      hängt und deshalb keinen Nicht-Agenten-Aufruf sieht: ohne Typ ist nicht entscheidbar,
      ob eine Rolle startet. Beide Antworten sind dieselbe — verweigern —, und das ist keine
      Selbstverständlichkeit, sondern die Stelle, an der ein Guard still durchlässig wird.
      Bewacht von `test/agent-guard.bats` (in `make test`) und den Fällen 117, 118, 119
      und 139.
   3. **Was er nicht deckt — und erst das ist die Abweichung.** (a) Ein Typ **ohne** Datei in
      `.claude/agents/` ist keine Rolle: `general-purpose`, `Explore` und die übrigen
      eingebauten Typen laufen im Hintergrund durch, **absichtlich** — sie tragen ohnehin
      keine Rolle in den Span. In ihre `Agent`-Spans gelangt von den neun Werten
      **höchstens einer**: `resolvedModel` steht auch in der Hintergrund-Antwort (gemessen),
      läuft aber durch die strukturelle Schranke aus [§3](#3-defaults-und-konstanten) — hat
      der Wert deren Gestalt nicht, fehlt `model_version` ganz (das Feld ist `omitempty`).
      Die **acht** Werte an `usage`/`total*`/`agentType` fehlen in jedem Fall. **Die Zeile
      selbst ist abgeleitet, nicht beobachtet:** sie folgt aus der Payload-Messung und aus
      dem Code — was sie entschiede, ist ein `Agent`-Span aus einem Hintergrund-Lauf eines
      Typs **ohne** Datei in `.claude/agents/`, und ein solcher liegt nicht vor. Ihre
      **Gestalt** liegt inzwischen im Bestand: ein `Agent`-Span, der von den neun Werten
      genau `model_version` trägt und keinen der acht. Er stammt von einem **Rollen**-Typ und
      gehört damit zu (c); die Zeile hier — über einen Typ **ohne** Datei in
      `.claude/agents/` — bleibt abgeleitet. Wer die Zeile zur Definition einer
      Abdeckungszahl heranzieht, hängt sie an die **Zähler** und nicht an „irgendein
      erfasster Wert": jener Span trägt einen erfassten Wert und ist trotzdem ein zählerloser
      Lauf. (b) Der Guard ist eine Verdrahtung in `.claude/settings.json`; er kann fehlen,
      abgeschaltet oder umgangen sein, und **kein Sensor dieses Repos prüft, dass er
      verdrahtet ist**. Über `test/`, `Makefile`, `harness/tools/` und die Go-Tests berühren
      die `settings.json` **fünf** Prüfstellen in **drei** Dateien: **zwei Prüfungen ihrer
      Verdrahtung** — der `PreToolUse`-Test in `harness/tools/smoke.sh` und
      `TestEnforce_SettingsWiresBothHooks` in `internal/emit/enforce_test.go` —, **zwei
      Prüfungen ihres bloßen Vorhandenseins** — die Existenz-Schleife über die
      Durchsetzungsschicht in derselben `harness/tools/smoke.sh` und
      `TestEnforce_EmitsAllMechanicFiles` in derselben Go-Datei, beide fordern den Pfad im
      Ziel-Layout, ohne den Inhalt anzusehen — und der **Dauer-Sensor** der zweiten
      Verdrahtungs-Prüfung, Fall 32. `Makefile` steuert nichts bei. **Die Zählregel, weil hier
      zwei Bezugsgrößen zusammenlaufen:** *vier* gilt für benannte Einheiten (die
      Existenz-Schleife trägt keinen Namen), *fünf* für eigenständige Zusicherungen über die
      Datei; unter *„die Verdrahtung prüfen"* sind es drei. **Alle fünf** gelten dem
      **emittierten** Repo und dessen Command-Guard; für die Verdrahtung **dieses** Repos
      prüft keine etwas. Ein Vorbild samt rot gesehener Mutation gibt es also, einen Sensor
      nicht. (c) **Er entscheidet über den Start, nicht
      über den Ausgang.** Der Guard sieht die `tool_input`-Payload, bevor der Aufruf läuft;
      ob dessen Antwort am Ende Zähler trägt, entscheidet er nicht mit. Der Bestand trägt
      dafür einen Fall: ein `Agent`-Span eines **Rollen**-Typs — `.claude/agents/architect.md`
      existiert, der Unterstrom führt den Typ in jeder Zeile —, dessen erfasster Wert-Satz
      aus genau `model_version` besteht: kein `spawned_role`, keiner der vier `usage`-Zähler,
      kein `total*`. Der Unterstrom des Subagenten schrieb **nach** dem Zeitstempel dieses
      Spans weiter, und der Haupt-Strom lief in derselben Zeit weiter — der Aufruf hat den
      Subagenten nicht bis zu dessen Ende festgehalten. **Welche Aufrufform das war, ist aus
      dem Repo nicht entscheidbar:** die `PreToolUse`-Payload wird nirgends protokolliert.
      Ein Hintergrund-Start im Sinne des Schalters passt nicht zu der Dauer, die der Span
      trägt — für einen Hintergrund-Subagenten gibt das Werkzeug sofort nach dem Start
      zurück, dieser Span trägt die Größenordnung des ganzen Laufs. Für den Guard gilt, was
      er entscheidet, und nicht, was am Ende im Span steht.

   **Die Abweichung:** ein `Agent`-Span **ohne Zähler** sieht aus wie ein erfasster Lauf und
   ist keiner. Beim Hintergrund-Lauf ist das konstruktiv (Prüfschritt 1); dass es **nicht
   nur** dort eintritt, steht in (c). Die Erfassung ist insoweit **konstruktiv
   unvollständig** — sie erfindet nichts, sie fehlt. **Sie entfällt ersatzlos, sobald die
   `tool_response` eines Hintergrund-Laufs Zähler trägt.** Die Quelle dafür ist **nicht
   gepinnt** und wird von **keinem Gate** geprüft: die Bedingung wirkt nur, wenn sie jemand
   nachsieht.
6. **Der Haupt-Kontext hat keine Zahl — die härtere Hälfte.** Abweichung 3 oben benennt seine
   fehlende **Rolle**; hier steht seine fehlende **Zahl**. Die zwei sind verschieden, und die
   Reihenfolge der Härte ist die umgekehrte der Bequemlichkeit: selbst eine gelöste
   Rollen-Ableitung gäbe dem Haupt-Kontext ein Etikett, aber keinen Zähler. Auch hier zuerst
   die Prüfung:
   1. **Woher die Zähler kommen — gemessen.** Die vier `usage`-Zähler und die drei
      `total*`-Werte stehen ausschließlich in der `tool_response` eines `Agent`-Aufrufs. Den
      Haupt-Kontext umschließt **kein** `Agent`-Aufruf; es gibt also kein Ereignis, an dem
      seine Token anfielen, und keine Payload, die sie trüge.
   2. **Aus den erfassten Feldern ableitbar? Nein.** Ein Span trägt `result_bytes` und
      `duration_ms` — Größen **eines** Aufrufs, keine Token. Eine Umrechnung wäre eine
      Schätzung, und geschätzt wird hier nicht: ein Wert steht leer und als leer erkennbar
      da, statt geraten zu werden.
   3. **Eine zweite Quelle? Zwei geprüft, beide zu — und eine Fläche ist ungeprüft.** Das
      Transkript ist als Quelle ausgeschlossen (Abweichung 1: fremder Besitz, außerhalb des
      Repos, voller Gesprächsinhalt). `SubagentStart` zählt Spawns und trägt keine Token.
      **Was hier NICHT gemessen ist, gehört in denselben Punkt, sonst reicht der Satz weiter
      als seine Prüfung:** vermessen sind die Schlüsselmengen von
      `PostToolUse`/`PostToolUseFailure` und die `tool_response` des `Agent`-Werkzeugs —
      sonst nichts. Die Payloads der übrigen Ereignisse hat hier niemand angesehen, auch die
      des verdrahteten `Stop`-Hooks nicht: der greift genau ein Feld heraus und protokolliert
      nichts. Für sie ist **gelesen** statt gemessen, und zwar die vendored
      [`docs/user/claude-hooks-referenz.md`](../docs/user/claude-hooks-referenz.md): über
      ihre ganze Länge nennt sie ein `usage`-Objekt und ein `totalTokens` ausschließlich für
      die `tool_response` des `Agent`-Werkzeugs, für kein anderes Ereignis ein Nutzungsfeld.
      Das ist Herkunft, keine Messung — die Regel lautet *„die Payload ist die Quelle"*.

   **Die Abweichung:** der Verbrauch des Haupt-Kontexts steht in keiner Payload. Jede
   Token-Bilanz aus diesen Spans ist damit eine Bilanz über **Subagenten-Läufe**; ihr Nenner
   ist nicht der Verbrauch des Laufs, und ein Prozentsatz daraus ist ein Anteil an der
   erfassten Teilmenge. Wer ihn schreibt, schreibt das dazu. Für den Haupt-Strom selbst gilt
   unverändert die Splitting-Pflicht aus Abweichung 3 samt der Pflicht, die Größe des
   Sammelpostens zu **zeigen**.

**Bewacht — die Zusicherungen, die keine Zeile der Feldtabelle sind.** Die Liste nennt,
**was** ein Zahn bindet; sie nennt die Wächter deshalb mehrfach, wo sie mehreres zusagen.

- **Die Eigenschaften des Emitters als Prozess:** `internal/span/span_test.go` und
  `cmd/span-emit/main_test.go` (Klemme und stumme Ausgabe als Prozess-Eigenschaft,
  fail-closed Default an fremden Werkzeug-Namen, kein Payload-Inhalt im Span, vergebene statt
  abgeleitete Folgenummer, Nebenläufigkeit, Modus, Strom-Trennung, Ableitung von
  `slice`/`requirement`/`branch`), `make span-check` (Emitter vorhanden **und**
  funktionsfähig, Ablageort real `git check-ignore`-geprüft) sowie
  `test/mutations/107-span-klemme-entfernt.sh`, `test/mutations/108-span-schema-offen.sh`,
  `test/mutations/109-span-folgenummer-eingefroren.sh`,
  `test/mutations/110-span-pflichtfeld-verschwindet.sh` (die Pflicht-Spalte oben: ein
  `omitempty` am falschen Feld ließe es bei leerem Wert lautlos verschwinden),
  `test/mutations/111-span-korrelationsfeld-verschwindet.sh` (dieselbe Mechanik an `branch` —
  dem Feld, an dem der Wächter zuerst vorbeisah),
  `test/mutations/112-span-stdout-geschwaetzig.sh` (die **stdout**-Hälfte der stummen
  Ausgabe; Fall 107 deckt nur die Exit-Hälfte, weil der Panic-Pfad auf stderr schreibt),
  `test/mutations/113-span-ablageort-getrackt.sh` (Ablageort auf einen getrackten Pfad),
  `test/mutations/114-span-lock-verzeichnis.sh` (ein liegengebliebenes Lock-**Verzeichnis**
  der Vorgänger-Fassung legte den Strom lautlos still) und
  `test/mutations/115-span-ergebnis-inhalt.sh` (**kein Freitext** aus dem Ergebnis — für
  jedes Werkzeug die Länge, darüber hinaus nur die Positiv-Liste bei `Agent`).
- **Die Erfassung aus `tool_response`, Zusicherung für Zusicherung:**
  1. `TestNoResponseFreetextReachesSpan` — **keines der vier gemessenen Freitext-Felder
     erreicht die Zeile**, je mit eigenem Kanarienvogel. Zähne:
     `test/mutations/123-span-ergebnis-content.sh`,
     `test/mutations/124-span-ergebnis-prompt.sh`,
     `test/mutations/125-span-ergebnis-description.sh`,
     `test/mutations/126-span-ergebnis-outputfile.sh` (je ein Freitext-Feld in die
     Positiv-Liste aufgenommen).
  2. `TestUnlistedResponseKeyStaysOut` — die **Grenze** selbst: ein ungelisteter Schlüssel
     bleibt draußen, auch ein verschachtelter. Zahn:
     `test/mutations/127-span-positivliste-negiert.sh` (die Liste **negiert**: alles außer
     den vier wandert durch). **127 ist der tragende:** vier namentliche Fälle unterscheiden
     eine Positiv-Liste **nicht** von einer Implementierung, die genau diese vier ausfiltert.
  3. `TestOnlyAgentToolGetsResponseValues` — die Achse ist der Werkzeug-**Name**, nicht die
     Gestalt der Antwort. Zahn: `test/mutations/133-span-werkzeugachse-geweitet.sh` (die
     Achse auf **jedes** klassifizierte Werkzeug geweitet; `Bash`, `Read` und `Write` geben
     dann Zähler, Rolle und Modell preis).
  4. `TestAgentGetsNoArgumentFields` — **B1**: `spawned_role` kommt aus
     `tool_response.agentType`, **nie** aus `tool_input.subagent_type`. Zahn:
     `test/mutations/132-span-rolle-aus-argument.sh` (der Rückfall auf das Argument, wenn das
     Ergebnis keine Rolle lieferte). Er bindet die **Eigenschaft** B1, nicht den
     `mustNotContain`-Eintrag — den bindet 138.
  5. `TestAgentGetsNoArgumentFields` — **B2**: `Agent` liegt auf **keiner** Gattungszeile
     (kein `path`, `program`, `argc`, `bytes`, `sha256_16`). Zahn:
     `test/mutations/135-span-agent-auf-gattungszeile.sh` (`Agent` als Kommando-Werkzeug
     abgeleitet).
  6. `TestSpawnedRoleIsNormalised` — der Wert aus dem Ergebnis wird gegen die sechs
     kanonischen Namen normalisiert. Zahn:
     `test/mutations/128-span-rolle-unnormalisiert.sh` (die Normalisierung entfernt — danach
     steht `general-purpose` als Rolle im Span, die erfundene Kostenstelle, die die
     Lesevorschrift verbietet).
  7. `TestResolvedModelIsStructurallyBounded` — die Schranke um `model_version` **verwirft,
     statt zu kürzen**. Zahn: `test/mutations/129-span-modellschranke-kuerzt.sh` (die feinere
     der beiden Zusagen; sie impliziert die gröbere).
  8. `TestFailedAgentCallCapturesNothing` — **kein halber Span**: die neun Werte fehlen,
     statt anwesend-und-ungemessen dazustehen. Seine `mustNotContain`-Liste nennt sie **alle
     neun** namentlich. Zähne:
     `test/mutations/134-span-zaehler-praesent-leer.sh` (`omitempty` von `input_tokens`
     genommen — der Zähler steht danach als `null` in **jeder** Zeile),
     `test/mutations/136-span-ausgabezaehler-praesent-leer.sh` (dasselbe an `output_tokens`)
     und `test/mutations/137-span-rollenfeld-praesent-leer.sh` (dasselbe an `spawned_role`).
     **Was diese drei NICHT binden, und darum hier steht:** sie binden **drei** der neun
     Listen-Einträge. **Der Prüfstein dafür ist das Kippen, nicht das Rot:** ein Zahn bindet
     einen Eintrag genau dann, wenn das **Streichen dieses Eintrags** den Fall von „ok" auf
     **Befund** kippt. Dass seine Mutation genau diesen Namen in die Fehlschlag-Zeile
     schreibt, ist dafür **notwendig, nicht hinreichend** — `mustNotContain` prüft per
     `strings.Contains` und bricht beim **ersten** Treffer ab. Ein Fall an
     `cache_read_input_tokens` schriebe den Namen und bliebe trotzdem ungebunden: streicht
     man den Eintrag, greift weiterhin `"input_tokens"` als Teilstring, der Wächter bleibt
     rot, `make mutate` meldet „ok". Die übrigen **sechs** Einträge (die zwei Cache-Zähler,
     `total_tokens`, `total_duration_ms`, `total_tool_use_count`, `model_version`) prüft der
     Wächter, aber **kein Fall des heutigen Sets schreibt einen von ihnen in diese Zeile** —
     wer einen aus der Liste streicht, bekommt von `make mutate` keinen Befund. Sechs weitere
     `omitempty`-Kopien wären möglich und sind bewusst **nicht** geschnitten (sie kosten je
     einen vollen Sensor-Lauf und binden je einen Namen); wer sie will, schneidet sie — und
     misst dann das **Kippen**, denn für die zwei Cache-Zähler ist es aus dem
     Teilstring-Grund oben **nicht** zu haben, solange `"input_tokens"` in derselben Liste
     steht.
  9. `TestAgentGetsNoArgumentFields` **und** `TestFailedAgentCallCapturesNothing` — die
     Gegenprobe `"tool":"Agent"`: ein `Agent`-Span ist an der geschriebenen Zeile als solcher
     erkennbar. Zahn: `test/mutations/131-span-werkzeugname-leer.sh`.
- **Die Draht-Form von `spawned_role`** — abwesend statt `""`, und damit die Lesevorschrift,
  die darauf ruht — bewachen `TestAgentGetsNoArgumentFields` und
  `TestFailedAgentCallCapturesNothing` an der geschriebenen Zeile, **jeder mit einem EIGENEN
  `mustNotContain`-Eintrag**. Zwei Einträge brauchen **zwei** Zähne, denn der Treiber sucht
  je Fall genau **einen** Namen in der Fehlschlag-Ausgabe — ein Fall kann höchstens einen
  Eintrag binden, auch wenn seine Mutation beide Wächter rot färbt. Die zwei Zähne tragen
  darum **dieselbe** Mutation (das `omitempty` an `json:"spawned_role"` genommen: danach
  steht `"spawned_role":""` in jeder Zeile und behauptet in jedem `Bash`-Span einen
  Subagenten, den es nicht gab) und unterscheiden sich nur in ihrer `# expect:`-Zeile:
  `test/mutations/137-span-rollenfeld-praesent-leer.sh` bindet den Eintrag im
  **Fehlschlag**-Wächter, `test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh`
  den im **ersten**. **Die Strukt-Prüfung `s.SpawnedRole != ""` im ersten Wächter deckt das
  nicht ab** und darum ist dessen Eintrag tragend: das Feld ist in **beiden** Draht-Formen
  `""`, über An- oder Abwesenheit entscheidet allein das JSON-Tag. **Die Herkunfts-Achse des
  zweiten Wächters hat keinen Zahn** — und zwar bewusst: ein *roher* Rückfall färbte ihn mit,
  und „132 rot" hieße dann nicht mehr eindeutig „B1 greift im ERSTEN Wächter". Hier
  **benannt**, nicht mitgezählt.
- **Die Voraussetzung der Gegenprobe hat zwei Hälften:**
  1. **`tool` bleibt Pflicht** — es steht auch bei leerem Wert in der Zeile. Wächter:
     `TestMandatoryFieldsAlwaysPresent` (die Listen-Zeile). Dauer-Zahn:
     `test/mutations/130-span-werkzeugfeld-verschwindet.sh` (`omitempty` an `json:"tool"`).
  2. **Ein `Agent`-Span ist an der Zeile als solcher erkennbar** (`"tool":"Agent"`). Wächter:
     `TestAgentGetsNoArgumentFields` und `TestFailedAgentCallCapturesNothing`. Dauer-Zahn:
     `test/mutations/131-span-werkzeugname-leer.sh` (der Werkzeug-Name erreicht die Zeile
     nicht mehr). **Hälfte 1 trägt Hälfte 2 nicht:** `"Agent"` ist ein nicht-leerer Wert, den
     ein `omitempty` nicht verschwinden lässt — die zwei Zähne sind darum zwei und nicht
     einer.
- **Was hier KEINEN Zahn hat, und darum benannt ist:** die `mustContain`-**Gegenproben** —
  die Zeilen, die diese Wächter davor bewahren, eine Erfassung von *nichts* für grün zu
  halten. Macht man `mustContain` wirkungslos, bleibt `make test-go` grün, und die Fälle 123
  und 127 melden weiter „ok" — sie färben ihre Wächter über die `mustNotContain`-Hälfte und
  merken vom Verlust der anderen nichts. Unbewacht ist damit **nicht die Eigenschaft** (eine
  ganz ausfallende Erfassung bräche die Gegenproben und damit `make test`), sondern **der
  Wächter dieser Eigenschaft**: er darf seine Zähne verlieren, ohne dass `make mutate` es
  meldet. Ein Fall dafür ist **möglich** (eine Mutation, die die Erfassung abschaltet),
  färbte aber mehrere Wächter dieser Liste auf einmal. Hier ist die Lücke **benannt**, nicht
  mitgezählt.

## 6. Externe Verträge

Schnittstellen zu Systemen, die uns nicht gehören, je mit der Fassung, gegen die
festgelegt ist.

| System | Version | Vertrag-Datei |
|---|---|---|

## 7. Historie

| Datum | Änderung | ADR |
|---|---|---|
| 2026-08-01 | Initial | — |
| 2026-08-02 | §5 nimmt das Span-Schema auf (Feldtabelle mit Sensor-Spalte, Werkzeug-Liste, Positiv-Liste, Start-Konvention, sechs erklärte Abweichungen, Wächter-Bindungen); §3 nimmt die strukturelle Schranke um `model_version` auf | [`ADR-0013`](../docs/plan/adr/0013-technik-stratum-als-zielort.md) |
