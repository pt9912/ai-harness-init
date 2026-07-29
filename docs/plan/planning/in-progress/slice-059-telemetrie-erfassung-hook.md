# Slice slice-059: Telemetrie-Erfassung — Spans per Agenten-Hook

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — erster Slice.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und unumgesetzt),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(die Hook-Mechanik, an die dieser Slice andockt),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der inhaltsbasierte Nachweis, den ein Span im Arbeitsbaum brechen würde),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die Zusage für
die **emittierte** Seite: „Ziel-Repos bleiben make/docker-getrieben"),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** 2026-07-28 — Schema-
Policy, abgeleitete Werte, Ablageort und fail-open-Betrieb sind dort **festgelegt**; dieser
Slice setzt sie um und erfindet sie nicht neu, [`AGENTS.md`](../../../../AGENTS.md) §3.4).
Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Span-/Audit-Attribut-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-28.

---

## 1. Ziel

**Ein Agentenlauf hinterlässt Spuren, die man lesen kann.** Jeder Tool-Call schreibt einen
Span mit dem Pflicht-Minimum aus Modul 15 — erfasst genau dort, wo die Mechanik dieses Repos
ohnehin sitzt: im **Hook**. Ohne diesen Schritt haben die übrigen Modul-15-Blöcke (Token-Bilanz,
Cache-Zähler) keine eigene Datenquelle, sondern nur das Transkript des Werkzeugs — das außerhalb
des Repos liegt, uns nicht gehört und keine Korrelations-IDs trägt.

Kein OTel-SDK, kein Collector, kein Dashboard. **Die Randbedingung ist „nichts, das installiert
werden muss", nicht ein bestimmtes Werkzeug** — welche Mechanik das erfüllt, ist Ergebnis der
Messung unten und nicht Vorgabe dieses Plans. Die Grenze verläuft zwischen der **POSIX-Basis**,
die der Harness ohnehin voraussetzt (`bash`, `awk`, Coreutils, `git`, `docker` — die Linie aus
[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)), und jeder Laufzeit, die ein Adopter
**installieren** müsste. Sie gilt **schon hier** und nicht erst bei der Emission
([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 4; die erste Fassung
dieses Absatzes schob sie auf slice-063 — das war falsch und vom Proposed-Review widerlegt).
Ablageort ist dieselbe Stelle wie beim Gate-Stempel.

## 2. Definition of Done

- [x] **(1) Das Span-Schema steht, bevor der erste Span geschrieben wird — jedes Feld mit
  seiner Incident-Frage.** Modul 15 führt **zwei** Listen, und beide gelten:
  *Mindestfelder eines Tool-Call-Spans* — `tool.name`, `tool.arguments` (redigiert),
  `tool.result.status` **plus Korrelations-IDs zu Slice/PR/Agent-Rolle**; und das
  *Audit-Span-Schema* mit dem **Pflicht-Minimum: Slice-ID, Agent-Rolle, Cache-Status,
  `requirement.id`**. Jedes Feld wird als *Pflicht* oder *Optional* markiert und trägt seine
  Incident-Frage (*„Ein Attribut ohne Incident-Frage fliegt raus"*). **Ableiten schlägt
  deklarieren**
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1.4):
  `slice.id` kommt aus dem Lifecycle-Verzeichnis, `requirement.id` aus der `**Bezug:**`-Zeile
  des Slice — **samt Randfällen** (kein Slice in `in-progress/`: Feld leer und als leer
  erkennbar; mehrere `LH-*`: alle). Offen bleibt genau der **Cache-Status**; ob ein Span mit
  `transcript_path` den Mindestsatz erfüllt oder von ihm abweicht, entscheidet dieser Slice mit
  Beleg — nicht per Vorab-Freistellung.
  **Belegt (Verifikation Runde 2):** Struct und [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) sind **bijektiv** (24 = 24, keine
  Differenz in beide Richtungen), die Pflicht-Spalte deckt sich mit den Struct-Tags (15/15 ohne
  `omitempty`), die Werkzeug-Tabelle ist Name für Name deckungsgleich mit `toolClass`. Beide
  Modul-15-Listen sind abgebildet; die vier nicht erfüllbaren Punkte stehen als **erklärte
  Abweichungen** (Cache-Status, PR-Nummer, `agent_role`, Altbestände) statt zu fehlen.
- [x] **(2) Der Hook schreibt real, die erfasste MENGE ist benannt, und der Gate-Nachweis bleibt
  heil.** An einem echten Lauf belegt: Spans liegen vor, Felder vollständig, Korrelations-IDs
  gefüllt. **Die Abdeckung wird ausgesprochen, nicht suggeriert:** der heutige Hook ist mit
  `"matcher": "Bash"` registriert und sähe damit **keinen** `Write`/`Edit`-Aufruf — genau die
  Schreibzugriffe, nach denen die Incident-Frage zu `slice.id` fragt. Entweder die Erfassung
  deckt sie ab, oder die Zusage wird auf das eingeschränkt, was sie hält (Messung F).
  Ablageort ist `.harness/state/` — **gitignored, wie der Gate-Stempel**: ein Span im getrackten
  Baum ginge in den `working-tree-hash` ein und der Stop-Hook blockierte sich selbst (die
  slice-031-Lehre, hier vorweggenommen statt nachher gelernt).
  **Belegt:** der Emitter läuft seit 2026-07-28 produktiv am echten Hook; live erfasst sind
  `Bash`, `Read`, `Write`, `Edit`, `Agent`, `ToolSearch`, `Monitor` samt getrennter
  Subagenten-Ströme — `matcher: ""` sieht also wirklich auch `Write`/`Edit`. Die Abdeckung ist in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) **ausgesprochen** (zwei Ereignisse, leerer Matcher) samt der gemessenen Lücke: ein vom
  Guard **geblockter** Aufruf erzeugt keinen Span. Der `working-tree-hash` blieb vor und nach
  einem Span byte-identisch (vom Verifier selbst gemessen).
- [x] **(3) Zwei Zähne, rot gesehen.** Ein Span **ohne Pflicht-Feld** und ein Werkzeug, das
  **nicht** in der Tabelle steht und trotzdem Argumente durchlässt — je als
  `test/mutations/`-Fall ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der zweite prüft den
  **fail-closed Default**: erfasst wird, was im geschlossenen Schema steht, für alles andere nur
  Name und Status
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2).
  Werte stehen dabei **abgeleitet** statt roh — Pfad und Länge statt Inhalt, Programm-Token
  statt Kommandozeile; so wandert kein Byte fremden Inhalts ins Log.
  **Belegt:** Zahn 1 über `test/mutations/110` und `111` (`omitempty` an einem Pflichtfeld →
  `TestMandatoryFieldsAlwaysPresent` rot), Zahn 2 über `test/mutations/108` (`classNone` →
  `classCommand` → `TestUnknownToolStaysSilent` rot). Dazu sieben weitere Span-Fälle
  (107, 109, 112–116) — insgesamt **112 ok, 0 Befunde**.
- [x] `make gates` grün, `make mutate` ohne Befund. **Belegt:** `make gates` Exit 0 (d-check 239/0 · comment-claims 36/0 · bats 127 · `span-check` grün) · `make mutate` **112 ok, 0 Befunde**.
- [x] Doku-Update. **Belegt:** [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) (Feldtabelle, Werkzeug→Feld-Tabelle, erfasste Menge, vier erklärte Abweichungen, Lesevorschrift zu `agent_role`, Migrations-Regel zur Strom-Identität, Payload-Messung), die Ausnahme in [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption), sowie `span-emit-build`/`span-check` in den zwei kanonischen Gate-Tabellen ([`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md)).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — §7.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-28, live) — was schon da ist:**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | Die Hook-Mechanik ist **verdrahtet**, in beiden Werkzeugen | `.claude/settings.json` → `PreToolUse` (Guard) + `Stop` (Gate-Nachweis); `.codex/hooks.json` → `SessionStart` |
| 2 | Der Guard **sieht jeden Bash-Tool-Call** samt Argumenten | `.claude/hooks/pretooluse-command-guard.sh` + `harness/tools/extract-command.awk` — die Payload wird bereits geparst, nur nichts davon behalten |
| 3 | Es gibt **kein** Log: der Guard entscheidet und vergisst | `grep -E "log|tee|>>" .claude/hooks/pretooluse-command-guard.sh` → leer |
| 4 | Der gitignored Ablageort **existiert bereits** | `git check-ignore -v .harness/state/gates-passed.diffsha` → `.gitignore:5`. **Achtung, zwei Ebenen:** im Dogfood steht die Regel in der Repo-`.gitignore`; die **emittierte** Fassung bringt eine eigene `.harness/.gitignore` mit (slice-031). Wer das verwechselt, plant gegen die falsche Datei |
| 5 | Die Hooks werden **ins Ziel emittiert** | `internal/emit/templates/enforce/settings.json` — identische Struktur (Dogfood und Ziel teilen die Mechanik) |

**Bereits beantwortet — an der Werkzeug-Doku gemessen am 2026-07-28**
(<https://code.claude.com/docs/de/hooks>). **Die Quelle ist Herkunft, nicht Inhalt:** die
Aussagen stehen unten ausgeschrieben, damit der Plan lesbar bleibt, wenn die Seite sich
ändert. Sie ist — anders als die Kurs-Links — **nicht gepinnt** und wird von keinem Gate
geprüft (`docs-check` läuft netzlos, d-checks `external`-Modul ist aus): ein toter Link
rottet hier still. Ändert das Werkzeug seine Hook-Oberfläche, ist das der
Re-Evaluierungs-Trigger aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md).

| # | Frage | Antwort (Quelle: Hook-Doku) |
|---|---|---|
| A | Welche Events, welche Payload-Felder? | **`PostToolUse` liefert das Tool-Ergebnis** (dokumentiert als `tool_output`/`tool_output_path` — die erste Fassung dieser Zeile schrieb `tool_response`, ein Feldname aus einer zusammenfassenden Abfrage statt aus dem Volltext; der Proposed-Review hat es am Original korrigiert), **`PostToolUseFailure` liefert `error`** — `tool.result.status` ist also in beiden Ausgängen erfüllbar. Jedes Tool-Event trägt zusätzlich `tool_use_id` (dieselbe ID über Pre-/Post-Event: **die Span-Identität**), `session_id`, `prompt_id`, `transcript_path`, `cwd`, `permission_mode`. |
| B | Feuern Hooks **in Subagenten**? | **Ja** — *„When a subagent calls a tool, tool events such as `PreToolUse` and `PostToolUse` fire the same configured hooks as in the main conversation"*, und die Payload trägt `agent_id` + `agent_type`. Die Rückführungs-Kante nach `next` (Rollen-Achse hängt am Transkript) ist damit **abgewendet**. |
| F | Welche Tool-Calls sieht der Hook? | **`"matcher": ""` = match all.** Die heutige Bash-Enge ist eine Registrierungs-Entscheidung, keine Plattform-Grenze; die Abdeckung ist herstellbar, die Zusage muss nicht gekürzt werden. |

**Was daraus NEU folgt und im Schnitt zu berücksichtigen ist:**

- **`agent_type` ist nicht unsere Rolle.** Die Payload liefert den *Subagent-Typ* (bei unseren
  Review-/Verify-Läufen `general-purpose`) — nicht die Harness-Rolle *Reviewer* bzw. *Verifier*.
  Rollen-Attribution braucht also eine **Konvention**, nicht nur ein Feld: entweder wir spawnen
  rollen-benannte Agenten-Typen, oder die Rolle wird beim Start mitgegeben. Das ist eine
  Prozess-Entscheidung, keine Skript-Frage — sie gehört in die `MR`-Fassung des Schemas
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 1).
- **`transcript_path` in der Payload ist die Brücke zu Block 2–3:** er verbindet den Span mit dem
  Transkript, in dem Token- und Cache-Zähler stehen. slice-060 braucht damit keine zweite
  Zuordnungs-Heuristik.
- **`PermissionDenied` existiert als eigenes Event.** Ein *abgelehnter* Tool-Call ist
  audit-relevant („was wurde versucht und geblockt?") — der Guard entscheidet das heute und
  vergisst es. Kandidat für das Schema, mit eigener Incident-Frage.

**Weiterhin offen — vor dem ersten Code zu messen:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| C | Woher kommt `slice.id`? | `ls docs/plan/planning/in-progress/slice-*.md` — der Zustand **ist** das Verzeichnis (Modul 5). Eine Quelle, kein Zustandsfile. |
| D | Wie wird aus `agent_type` unsere **Rolle**? | Die Payload liefert den Subagent-Typ, nicht die Harness-Rolle (s. o.). Zu entscheiden: rollen-benannte Agenten-Typen spawnen, oder die Rolle beim Start mitgeben. Fällt die Zuordnung nicht eindeutig aus, ist der **Sammelposten** zu benennen und aufzuteilen — Modul 15 verlangt genau diese Entscheidung, nicht ihr Weglassen. |
| E | Was kostet der Hook pro Tool-Call? | Ein Audit, das den Lauf spürbar bremst, wird abgeschaltet — dann ist es kein Sensor mehr. Größenordnung dieser Sitzung: **189 Tool-Calls** im Haupt-Kontext, bei Pre+Post also ~380 Hook-Starts; bei den Subagenten kommen 49 und 66 Calls dazu. |
| F | Wie viel kostet die **volle** Abdeckung? | `matcher: ""` erfasst alles — auch `Read`. Ob jeder gelesene Pfad ins Audit gehört, ist eine Schema-Frage (Incident-Frage vorhanden?) und eine Kosten-Frage (Zeile E). Die Abdeckung ist herstellbar; die Auswahl bleibt zu treffen. |
| G | Traegt die Ableitung ihre Randfaelle? | `slice.id` aus `in-progress/` — **heute liegt dort kein Slice**, das Feld muss also leer und als leer erkennbar sein statt geraten. `requirement.id` aus der Bezug-Zeile: bis zu vier `LH-*` je Slice, also eine Liste, nicht ein Wert. Offen bleibt der Cache-Status (Transkript statt Payload). |

**Mechanik-Entscheidung (2026-07-28, nach der Messung — die der Plan sich offengehalten hat):**
**Go**, nicht awk. Begründung, und sie ist gemessen, nicht ästhetisch: der Emitter ist
**fail-open** und hat damit **nicht** die Kompensation, mit der `extract-command.awk` seine
Ungeeignetheit auffängt (*„bei Unsicherheit lieber blocken"* — fail-closed). Der Review hat die
Folge belegt: `error` nur als String erkannt, bei `{"message":…}` meldet der Span `ok` für einen
fehlgeschlagenen Aufruf. Jedes Feld ist ein handgeschriebener Sonderfall, jede Typ-Variante ein
neuer. Dazu 21 externe Aufrufe je Span (gemessen) gegen **einen** Prozess-Start.
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 4 steht dem **nicht**
entgegen: sie schließt Laufzeiten aus, die ein **Adopter** installieren müsste — für die
Dogfood-Seite bindet sie nicht. Ob das Ziel-Repo einen Emitter bekommt, entscheidet **slice-062**
(§4 der Welle), nicht dieser Slice.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/span-emit/main.go` + `internal/span/` | neu | Echter JSON-Parser statt handgeführtem Scanner; ein Prozess statt gemessener 21 externer Aufrufe; von `make lint`/`make test` abgedeckt wie der übrige Go-Code ([`ADR-0003`](../../adr/0003-go-native-binaries.md)) |
| `harness/tools/span-check.sh` (Gate für den Fehlt-Fall) | neu | Ein kompiliertes Artefakt kann **fehlen** — und dann entsteht **gar kein Strom**, was die Folgenummer prinzipiell nicht sieht (sie wurde nie vergeben). Der stille Totalausfall ist schlimmer als der Teilverlust, gegen den die Nummern eingeführt wurden. Ein Gate prüft deshalb: Emitter vorhanden **und** erzeugt für eine synthetische Payload einen Span. Damit wird aus dem stillen Ausfall ein rotes Gate |
| Die bash+awk-Fassung | **abgelöst** (entfernt) | Sie war die **Semantik-Vorlage**: Werkzeug-Name als Achse, Env-Präfix übersprungen, vergebene statt abgeleitete Folgenummer, Sperre, Modus vor dem ersten Byte — belegt in `44b974a` und in der Go-Fassung unverändert weiter gültig. Stehen bleiben durfte sie nicht: zwei Emitter an einem Hook wären zwei Zusagen für dieselbe Erfassung |
| `.claude/settings.json` | update | Event(s) und **Matcher** verdrahten (abhängig von Messung A **und F**) |
| `harness/tools/json-encode.awk` | prüfen, ggf. wiederverwenden | existiert bereits für JSON-**Ausgabe**; ob es auch für die Payload-**Eingabe** trägt, ist Messung A — Encoding und Parsing sind nicht dasselbe Problem |
| `test/` + `test/mutations/` | neu | die zwei Zähne aus DoD (3) |
| `harness/tools/agent-watch.sh` | **neu, außerhalb des Gegenstands** | Speicher-Melder für Subagenten-Läufe. Er gehört **nicht** zur Telemetrie-Erfassung — er entstand, weil die Sensor-Läufe *dieses* Slice die Maschine zweimal zum Absturz brachten. Als stille Beigabe wäre er Scope-Creep; hier steht er benannt, samt seiner Grenze: **kein funktionaler Wächter, kein Makefile-Ziel, kein `MR`-Eintrag** — `shell-lint` und `comment-claims` fassen ihn wie jedes Skript unter `harness/tools/`, aber niemand prüft, ob er *tut*, was er sagt. Seine Einbindung ist Gegenstand von [slice-065](../next/slice-065-testlauf-ressourcendeckel.md) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | das Span-Schema als `MR`-Eintrag — es ist eine Struktur-Regel, kein Implementierungsdetail |

## 4. Trigger

**`open` → `next`:** [welle-09](../welle-09-modul-15-konformitaet.md) ist geschnitten (dieser
Slice ist ihr erster), `in-progress/` ist leer (WIP-Limit 1) — **und
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) ist *Accepted***. Die dritte
Bedingung kam aus dem Plan-Review und war die zuletzt offene: Schema-Policy, Datenfluss und
Sicherheitsfläche sind entschieden, bevor der erste Span geschrieben wird. **Alle drei erfüllt
am 2026-07-28.**

Rückführungen:

- `in-progress` → `next`: falls Messung B ergibt, dass Hooks in Subagenten **nicht** feuern.
  Dann trennt ein Re-Slice die Hook-Erfassung (Haupt-Kontext) von der Rollen-Zuordnung
  (Transkript-Auswertung) — zwei verschiedene Datenquellen, zwei verschiedene Zusagen.
- `in-progress` → `open`: falls Messung A ergibt, dass `tool.result.status` gar nicht erfassbar
  ist. Dann ist zu entscheiden, ob ein **reduziertes** Schema noch der Regel genügt — eine
  Normativ-Frage (`MR`), kein Skript-Detail.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt die
DoD (Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein ungeplantes Artefakt im Slice, ausdrücklich benannt:** `harness/tools/agent-watch.sh`.
  Anlass waren zwei Abstürze am 2026-07-29 — der erste durch eine Prozess-Rekursion in
  einem Test dieses Slice, der zweite ein globaler OOM, bei dem der Kernel-Dump Claude
  Code selbst mit 25,37 GB als größten Verbraucher ausweist (85 % von 29,7 GB; bei 20
  Kernen lag die Last bei ~24 %, CPU war nie das Problem). Der Melder beobachtet und
  meldet; **abbrechen kann er nichts** — Subagenten sind keine eigenen Prozesse. Er hat **keinen funktionalen Wächter**
  (`shell-lint` und `comment-claims` fassen ihn als Skript, prüfen aber nicht seine
  Wirkung) und kein Makefile-Ziel. Das ist keine Nachlässigkeit, sondern die
  Grenze dieses Slice: seine Einbindung (Makefile-Ziel, `MR`-Eintrag, Wächter) gehört zu
  [slice-065](../next/slice-065-testlauf-ressourcendeckel.md), nicht hierher. Ihn
  stillschweigend mitzuliefern wäre die Alternative gewesen — und genau die Klasse, die
  dieser Slice zweimal im Review bezahlt hat.
- **Ein Audit-Log, das Secrets sammelt, ist ein Schaden, kein Sensor.** Die Redaktion ist
  Pflicht-Teil des Schemas und hat ihren eigenen Zahn (DoD 3) — nicht „später härten".
- **Spans dürfen den Gate-Nachweis nicht brechen.** Der `working-tree-hash` deckt getrackte
  **und** untracked Dateien; ein Span-File im Baum machte den Stop-Hook zum Selbstblockierer.
  `.harness/state/` ist gitignored — deshalb dorthin, und deshalb steht es in DoD (2) und nicht
  im Kleingedruckten.
- **Hook-Latenz.** Siehe Messung E. Ein spürbar langsamerer Lauf führt zur Abschaltung, und ein
  abgeschalteter Sensor ist schlechter als ein nie gebauter (er behauptet Abdeckung).
- **Die Tool-Ebene ist nicht Teil dieses Slice, aber Teil dieser Welle** (slice-062 Entscheidung,
  slice-063 Emission). Dieser Slice ist der **Prüfstand**: die Hooks werden ins Ziel emittiert
  (`internal/emit/templates/enforce/settings.json`), ein Span-Emitter wäre also emittierbar —
  aber erst, wenn er hier real gelaufen ist. Wer ihn ungeprüft emittiert, behauptet etwas, das
  nicht läuft. **Folge für den Zuschnitt hier — und sie ist nach der
  Mechanik-Entscheidung anders ausgefallen, als dieser Absatz sie zuerst formulierte:** die
  Sorge war *„keine Form, die einen späteren Umzug in die emittierte Ablage erschwert"*
  (`tools/harness/`, [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)),
  und *„keine Quell-Repo-Identität"* (Lehre aus slice-031/032/033). Beides ist erfüllt —
  aber **nicht** durch eine Ablage unter `harness/tools/`: ein Go-Binary kann dort nicht
  liegen, ohne aus dem Modul zu fallen. Der Emitter liegt in `cmd/span-emit/` +
  `internal/span/`, die Shell-Hälfte (`harness/tools/span-check.sh`) regelkonform dort.
  Das **Umzugs-Hindernis** wäre ein Subkommando von `ai-harness-init` gewesen: es hätte
  slice-062 (bekommt der emittierte Harness einen Emitter?) vorweggenommen. Der Verifier
  hat die zwei Sorgen nachgemessen und
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  als **nicht verletzt** befunden; die Ausnahme steht dort jetzt ausdrücklich.
- **ADR-Bedarf: wahrscheinlich, und VOR diesem Slice zu klären** (Plan-Review-Befund). Ein
  Span-Schema führt eine neue Artefakt-Klasse, einen neuen Datenfluss und eine Sicherheitsfläche
  ein — und die Entscheidungen fallen faktisch **hier**, nicht erst bei der Emission: welche
  Felder, welche Redaktions-Strategie, welcher Ablageort. Genau diese Klasse hat bei slice-058
  zu [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) geführt. Solange das nicht
  entschieden ist, bleibt dieser Slice in `open/` — dieselbe Bedingung, die slice-058 getragen
  hat.
- **Kein Carveout absehbar.**

## 7. Closure-Notiz (nach `done/`)

**Was funktioniert hat.** Der Emitter läuft seit dem 2026-07-28 produktiv und hat in dieser
Sitzung mehr geleistet, als er sollte: mit seinen Daten ließ sich die Vollständigkeit der
Subagenten-Erfassung belegen (48 Spans gegen 48 selbst gemeldete Tool-Calls eines Reviewers),
und dieselben Daten haben eine falsche Ursachen-Erklärung des Implementers **widerlegt**. Ein
Sensor, der den widerlegt, der ihn gebaut hat, ist der Beweis, dass er misst statt zu bestätigen.

**Was anders lief als geplant.** Der Slice brauchte **drei Review- und zwei Verifikationsrunden**
(21 + 14 Befunde). Fast keiner davon lag im Code — sie lagen in der **Deckung zwischen Zusage und
Sensor**: ein Wächter, der 10 von 12 Pflichtfeldern zählte; ein Gate, das 7 von 14 prüfte; ein
Kommentar, der eine Mutation weiter behauptete, als sie reicht; eine Zusage über `flock`, die den
Fall nannte, den sie nicht prüfte. Der Emitter selbst war nach zwei Tagen fertig; teuer war
ausschließlich das Einlösen dessen, was über ihn behauptet wurde.

Dazu zwei Abstürze der Arbeitsmaschine — der erste durch eine **Prozess-Rekursion in einem Test
dieses Slice** (die Kind-Prozess-Abzweigung stand im Test-Rumpf statt in `TestMain`), der zweite
ein globaler OOM. Für den zweiten habe ich nacheinander drei Erklärungen gebaut — „nicht
host-portabel", „parallele Builds", „fremde Umgebung" — und **alle drei waren falsch**; zwei
widerlegte der Auftraggeber, die dritte der Kernel-Dump. Die Ursache ist bis heute nicht
gefunden, nur eingekreist.

**Steering-Loop-Einträge:**

1. **Geschärfte Regel — die Zusage ist so breit wie ihr Sensor, nicht wie ihr Satz.** Drei
   Befundklassen dieses Slice sind dieselbe: ein Wächter zählt eine Teilmenge dessen auf, was
   die Regel fordert, und ist grün, *weil* er die heutige Implementierung abbildet. Betroffen
   waren `TestMandatoryFieldsAlwaysPresent` (10 von 12), `span-check.sh` (7 von 14) und die
   Klemmen-Zusage in `cmd/span-emit/main.go` („beides bewacht 107", während der Panic-Pfad auf
   stderr schreibt). **Anwendung:** wo eine Liste normativ ist, muss der Wächter sie *zählen*,
   nicht *nachbilden*.

2. **Neuer Sensor — `make span-check`**, in `make gates`. Er prüft Vorhandensein, Funktion an
   einer synthetischen Payload und — per `git check-ignore` am realen Repo — dass der
   geschriebene Pfad ignoriert ist. Der Fehlt-Fall ist **rot gesehen**. Dazu zehn neue
   Mutations-Fälle (107–116).

3. **Benannte Spec-Lücke — grün wegen Altbestand.** Der Emitter legte seinen Ablageort mit
   `0700` an; `make docs-check` scheiterte daran. Sichtbar wurde es erst, als `make span-clean`
   das `0755`-Verzeichnis der abgelösten Fassung wegräumte. **Kein Gate misst, ob ein grüner
   Lauf auf einem frischen Zustand grün wäre** — die CI auf frischem Klon ist der einzige Ort,
   an dem das auffällt, und sie lief hier zuletzt vor dem Slice.

4. **Offener Rest ohne Sensor (Review Runde 3, F-1):** die neue Regel *„vor einer Änderung der
   Strom-Namensbildung `make span-clean`"* hat keinen Wächter. Dieselbe Doppelvergabe ist
   **zweimal** entstanden (awk→Go: 16 Duplikate; `sanitizePart`: 58) und wurde beide Male von
   Hand gefunden. Kandidat für den Roadmap-Eintrag *„Regeln ohne Feedback-Quadrant schließen"*.

5. **Prozess-Lehre — bei einem Absturz zuerst den Kernel fragen.** Der OOM-Dump beantwortet in
   einer Zeile, was aus Spans, Zeitachsen und Image-Zeitstempeln nicht rekonstruierbar war. Meine
   drei Fehlversuche davor waren durchweg Korrelation, die als Kausalität auftrat.

**Folge-Slices und offene Reste:**

- **slice-060** (Auswertung) erbt drei Vorarbeiten: die Rollen-Zuordnung über rollen-benannte
  Agenten-Typen (dann füllt sich `agent_role` **ohne** Änderung an der Erfassung), die zwei
  neuen Felder `duration_ms`/`result_bytes`, und die bindende Lesevorschrift zum Sammelposten.
- **slice-065** (`next/`) trägt `harness/tools/agent-watch.sh` als einzubindende Vorarbeit —
  heute ohne funktionalen Wächter, ohne Makefile-Ziel, ohne `MR`-Eintrag.
- **Offen und benannt:** F-1 (kein Sensor für die `span-clean`-Regel), F-5 (`result_bytes` ist
  die Länge der JSON-Kodierung, der Wächter prüft nur `> 0`), sowie die Grenze, dass die
  `git check-ignore`-Prüfung in `span-check.sh` selbst unbewacht bleibt — eine Mutation kann sie
  nicht fangen, weil das *Entfernen* einer Prüfung den Gate grün lässt.


<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt `*`
(gesamtes Repo) als **Greenfield**; die berührte Fläche (Hook-Mechanik, `harness/tools/`) ist in
diesem Repo entstanden und vollständig bekannt. Der Vollblock entfällt damit laut Template.
