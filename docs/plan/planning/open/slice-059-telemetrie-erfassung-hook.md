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
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Proposed** — solange nicht
angenommen, bleibt dieser Slice in `open/`). Regelwerk-Quelle:
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

- [ ] **(1) Das Span-Schema steht, bevor der erste Span geschrieben wird — jedes Feld mit
  seiner Incident-Frage.** Modul 15 führt **zwei** Listen, und beide gelten:
  *Mindestfelder eines Tool-Call-Spans* — `tool.name`, `tool.arguments` (redigiert),
  `tool.result.status` **plus Korrelations-IDs zu Slice/PR/Agent-Rolle`; und das
  *Audit-Span-Schema* mit dem **Pflicht-Minimum: Slice-ID, Agent-Rolle, Cache-Status,
  `requirement.id`**. Jedes Feld wird als *Pflicht* oder *Optional* markiert und trägt seine
  Incident-Frage (*„Ein Attribut ohne Incident-Frage fliegt raus"*). **Jede Abweichung vom
  Pflicht-Minimum wird begründet** — insbesondere `requirement.id` und `Cache-Status`, für die
  heute keine offensichtliche Quelle im Hook existiert: sie werden **nicht stillschweigend
  weggelassen**, sondern entweder erschlossen oder als begründete Abweichung dokumentiert.
- [ ] **(2) Der Hook schreibt real, die erfasste MENGE ist benannt, und der Gate-Nachweis bleibt
  heil.** An einem echten Lauf belegt: Spans liegen vor, Felder vollständig, Korrelations-IDs
  gefüllt. **Die Abdeckung wird ausgesprochen, nicht suggeriert:** der heutige Hook ist mit
  `"matcher": "Bash"` registriert und sähe damit **keinen** `Write`/`Edit`-Aufruf — genau die
  Schreibzugriffe, nach denen die Incident-Frage zu `slice.id` fragt. Entweder die Erfassung
  deckt sie ab, oder die Zusage wird auf das eingeschränkt, was sie hält (Messung F).
  Ablageort ist `.harness/state/` — **gitignored, wie der Gate-Stempel**: ein Span im getrackten
  Baum ginge in den `working-tree-hash` ein und der Stop-Hook blockierte sich selbst (die
  slice-031-Lehre, hier vorweggenommen statt nachher gelernt).
- [ ] **(3) Zwei Zähne, rot gesehen.** Ein Span **ohne Pflicht-Feld** und ein Span, der ein
  Secret durchlässt — je als `test/mutations/`-Fall hinterlegt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der zweite ist der wichtigere und muss als
  **Allowlist** gebaut sein: nur bekannte, unkritische Felder gehen durch, alles andere wird
  redigiert. Eine Denylist prüft nur die Muster, die der Implementierung schon eingefallen sind,
  und kann unter keiner **realen** Lücke rot werden — ein Audit-Log, das Secrets sammelt, ist
  schlimmer als keines.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
| G | Woher kommen `requirement.id` und `Cache-Status`? | Beide stehen im Pflicht-Minimum des Audit-Schemas. Für `requirement.id` ist der Slice-Plan die einzige Quelle (§Bezug); der Cache-Status liegt im Transkript, nicht in der Hook-Payload. Wenn eines nicht erschließbar ist, ist das eine **begründete Abweichung** nach Modul 15 — kein stilles Weglassen. |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` (neuer Span-Emitter) | neu | Ablage nach [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) (lokale Tools liegen hier). **Die Mechanik ist offen** — Randbedingung „keine neue Abhängigkeit", Auswahl nach den Messungen A–G, nicht vorab festgelegt |
| `.claude/settings.json` | update | Event(s) und **Matcher** verdrahten (abhängig von Messung A **und F**) |
| `harness/tools/json-encode.awk` | prüfen, ggf. wiederverwenden | existiert bereits für JSON-**Ausgabe**; ob es auch für die Payload-**Eingabe** trägt, ist Messung A — Encoding und Parsing sind nicht dasselbe Problem |
| `test/` + `test/mutations/` | neu | die zwei Zähne aus DoD (3) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | das Span-Schema als `MR`-Eintrag — es ist eine Struktur-Regel, kein Implementierungsdetail |

## 4. Trigger

**`open` → `next`:** [welle-09](../welle-09-modul-15-konformitaet.md) ist geschnitten (dieser
Slice ist ihr erster), `in-progress/` ist leer (WIP-Limit 1).

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
  nicht läuft. **Folge für den Zuschnitt hier:** das Span-Skript gehört nach
  `harness/tools/` und nicht in eine Form, die einen späteren Umzug in die emittierte Ablage
  (`tools/harness/`, [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption))
  erschwert — und es trägt **keine** Quell-Repo-Identität (Lehre aus slice-031/032/033).
- **ADR-Bedarf: wahrscheinlich, und VOR diesem Slice zu klären** (Plan-Review-Befund). Ein
  Span-Schema führt eine neue Artefakt-Klasse, einen neuen Datenfluss und eine Sicherheitsfläche
  ein — und die Entscheidungen fallen faktisch **hier**, nicht erst bei der Emission: welche
  Felder, welche Redaktions-Strategie, welcher Ablageort. Genau diese Klasse hat bei slice-058
  zu [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) geführt. Solange das nicht
  entschieden ist, bleibt dieser Slice in `open/` — dieselbe Bedingung, die slice-058 getragen
  hat.
- **Kein Carveout absehbar.**

## 7. Closure-Notiz (nach `done/`)

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
