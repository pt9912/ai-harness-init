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
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash+awk, keine
neue Abhängigkeit). Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Span-/Audit-Attribut-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-28.

---

## 1. Ziel

**Ein Agentenlauf hinterlässt Spuren, die man lesen kann.** Jeder Tool-Call schreibt einen
Span mit dem Pflicht-Minimum aus Modul 15 — erfasst genau dort, wo die Mechanik dieses Repos
ohnehin sitzt: im **Hook**. Ohne diesen Schritt haben die übrigen Modul-15-Blöcke (Token-Bilanz,
Cache-Zähler) keine eigene Datenquelle, sondern nur das Transkript des Werkzeugs — das außerhalb
des Repos liegt, uns nicht gehört und keine Korrelations-IDs trägt.

Kein OTel-SDK, kein Collector, kein Dashboard: **JSONL, geschrieben von bash+awk**, an derselben
Stelle wie der Gate-Stempel.

## 2. Definition of Done

- [ ] **(1) Das Span-Schema steht, bevor der erste Span geschrieben wird — jedes Feld mit
  seiner Incident-Frage.** Modul 15 verlangt genau das und zieht die Grenze selbst: *„Ein
  Attribut ohne Incident-Frage fliegt raus."* Pflicht-Minimum: `slice.id` („auf wessen Rechnung
  lief der Schreibzugriff?"), `agent.role`, `tool.name`, `tool.arguments` **redigiert** („was
  wurde wohin geschrieben — ohne Secrets im Log?"), `tool.result.status`. Jede Abweichung vom
  Minimum wird **begründet**, nicht weggelassen.
- [ ] **(2) Der Hook schreibt real, und der Gate-Nachweis bleibt heil.** An einem echten Lauf
  belegt: Spans liegen vor, Felder vollständig, Korrelations-IDs gefüllt. Ziel ist
  `.harness/state/` — **gitignored, wie der Gate-Stempel**: ein Span im getrackten Baum ginge in
  den `working-tree-hash` ein und der Stop-Hook blockierte sich selbst (die slice-031-Lehre, hier
  vorweggenommen statt nachher gelernt).
- [ ] **(3) Zwei Zähne, rot gesehen.** Ein Span **ohne Pflicht-Feld** und ein Span mit einem
  **unredigierten Secret** in `tool.arguments` sind Befunde — je als `test/mutations/`-Fall
  hinterlegt ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der zweite ist der wichtigere: ein
  Audit-Log, das Secrets sammelt, ist schlimmer als keines.
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
| 4 | Der gitignored Ablageort **existiert bereits** | `.harness/.gitignore` → `state/`; dort liegt `gates-passed.diffsha` |
| 5 | Die Hooks werden **ins Ziel emittiert** | `internal/emit/templates/enforce/settings.json` — identische Struktur (Dogfood und Ziel teilen die Mechanik) |

**Vor dem ersten Code zu messen (der Slice beginnt mit Messen, nicht mit Schreiben):**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | Welche Hook-Events kennt das Werkzeug, und welche Felder trägt die Payload? | `PreToolUse` sieht **kein Ergebnis** — für `tool.result.status` braucht es ein Nach-Event. Fehlt es, ist das Pflicht-Minimum nicht erfüllbar und Punkt (1) muss die Abweichung begründen. |
| B | Feuern Hooks auch **in Subagenten**? | Wenn nein, fehlen genau die Rollen-Läufe (Reviewer, Verifier) — dann ist `agent.role` über Hooks **nicht** erfassbar und die Rollen-Achse hängt am Transkript. Das ist die Rückführungs-Bedingung nach `next`. |
| C | Woher kommt `slice.id`? | `ls docs/plan/planning/in-progress/slice-*.md` — der Zustand **ist** das Verzeichnis (Modul 5). Eine Quelle, kein Zustandsfile. |
| D | Woher kommt `agent.role`? | Offen. Kandidaten: der laufende Command/Skill, oder der Transkript-Pfad aus der Payload. **Nicht raten** — messen und, falls nicht ermittelbar, den Sammelposten benennen (Modul 15 verlangt genau diese Entscheidung). |
| E | Was kostet der Hook pro Tool-Call? | Ein Audit, das den Lauf spürbar bremst, wird abgeschaltet — dann ist es kein Sensor mehr. |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` (neues Span-Skript) | neu | bash+awk, schreibt JSONL nach `.harness/state/` ([`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption): lokale Tools liegen hier) |
| `.claude/settings.json` | update | das Nach-Event verdrahten (abhängig von Messung A) |
| `harness/tools/json-encode.awk` | update / wiederverwenden | existiert bereits — JSON-Encoding ohne neue Abhängigkeit ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) |
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
- **Die emittierte Ebene ist bewusst NICHT Teil dieses Slice** — aber sie ist eine echte Frage,
  keine erledigte: die Hooks **werden** ins Ziel emittiert
  (`internal/emit/templates/enforce/settings.json`), ein Span-Emitter wäre also emittierbar. Das
  ändert den Adopter-Vertrag und braucht seinen eigenen Beleg (out-of-the-box grün, Lehre aus
  slice-028) — eigener Zuschnitt nach dieser Welle.
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
