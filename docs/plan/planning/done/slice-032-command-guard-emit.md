# Slice slice-032: Command-Guard emittieren (BLOCKED-Set je `--lang`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-04-durchsetzung-und-emission](welle-04-durchsetzung-und-emission.md).

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md), [`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Ziel

Der Emit legt den **Command-Guard** ins Zielrepo: `.claude/hooks/pretooluse-command-guard.sh`
(reines bash + awk, kein node/jq — [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) + den awk-Extraktor
`tools/harness/extract-command.awk`, und ergänzt den `PreToolUse`-Guard in die von slice-031
emittierte `.claude/settings.json`. Der Guard blockt fail-closed Host-Toolchains — sein
**BLOCKED-Set ist je `--lang` zusammengesetzt** (universelle Paketmanager + die Sprach-Toolchain,
[`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md): Tool-als-Quelle, je `--lang`). Damit erzwingt das gebootstrappte Repo dieselbe
Docker-only-Disziplin wie das Dogfood ([`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md)). Dritter/letzter Durchsetzungs-Slice
vor den Workflow-Commands (slice-033).

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [x] [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Guard-Teil): der Emit legt ins Ziel — `.claude/hooks/pretooluse-command-guard.sh` (0o755) und `tools/harness/extract-command.awk`; die emittierte `.claude/settings.json` verdrahtet **jetzt auch** `PreToolUse` (Matcher `Bash`) → der Guard. Test belegt: emittiert + verdrahtet.
- [x] **BLOCKED-Set je `--lang`** ([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)): der emittierte Guard trägt für `--lang go` die go-Toolchain (`go gofmt golangci-lint staticcheck`) **plus** die universellen Paketmanager. Die Zusammensetzung ist an `gen.SupportedLangs()` gekoppelt (jedes Profil hat ein BLOCKED-Set — Test gegen stillen Lang-Drift).
- [x] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): der emittierte Guard + Extraktor sind **reines bash + awk** — kein `node`/`jq`/OCI, fail-closed bei Parse-Zweifel (positiver Struktur-Anker `awk -f` + der behaviorale full-smoke-Lauf belegen es; ein bloßer node/jq-Wort-Grep wäre gegen den erklärenden „KEIN node/jq"-Kommentar brüchig).
- [x] **Verhalten real belegt:** `make full-smoke` füttert den emittierten Guard mit Hook-JSON — `go build` wird **geblockt** (`decision: block`), `make test` **durchgelassen** (keine Ausgabe). Belegt BLOCKED-Set + awk-Pfad (`tools/harness/`) + Scan im real gebootstrappten Ziel, nicht nur behauptet.
- [x] `make gates` grün; `make mutate` deckt die neuen Wächter (rot gesehen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/pretooluse-command-guard.sh` | neu | generische Guard-Fassung (aus dem Dogfood): awk-Pfad auf `tools/harness/`, `BLOCKED="@@BLOCKED_SET@@"`-Platzhalter, ai-harness-init/MR-spezifische Refs neutralisiert |
| `internal/emit/templates/enforce/extract-command.awk` | neu | der awk-Extraktor (verbatim, sprach-agnostisch; ID-Refs neutralisiert) |
| `internal/emit/templates/enforce/settings.json` | update | `PreToolUse`-Block (Matcher `Bash` → Guard) neben dem Stop-Hook (slice-031 war Stop-only) |
| `internal/emit/enforce.go` | update | Guard + awk in `enforceFiles`; `blockedSet(lang)` (universell + `blockedByLang`); `Enforce` bekommt `lang`, substituiert `@@BLOCKED_SET@@` im Guard |
| `cmd/ai-harness-init/main.go` | update | `emit.Enforce(targetDir, lang, force)` — `lang` durchreichen |
| `internal/emit/enforce_test.go` | update | Guard/awk emittiert; settings.json **hat jetzt** PreToolUse (Grenze wandert); BLOCKED-Set enthält go-Toolchain; `blockedSet` deckt alle `gen`-Profile; kein node/jq |
| `harness/tools/smoke.sh` | update | Guard/awk-Präsenz + PreToolUse **positiv** (slice-031-Negativprobe umkehren) |
| `harness/tools/full-smoke.sh` | update | Guard-Verhalten real: `go build` geblockt / `make test` durch |
| `test/mutations/32-*.sh` + neu | update/neu | Fall 32 (Stop-only-Grenze) umwidmen → Guard-verdrahtet; neue Fälle für BLOCKED-Set + Guard-Verhalten |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

slice-031 in `done/` (der Stop-Hook + `.claude/settings.json` sind emittiert; der Guard setzt darauf auf). Dritter welle-04-Slice.

Rückführungen: `in-progress → next`, falls der Guard-Emit und die `--lang`-BLOCKED-Set-Mechanik doch getrennte Schnitte tragen. `in-progress → open`, falls blockiert (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt + Closure-Notiz → nach `done/`. Danach ist die Durchsetzungsschicht ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)) komplett emittiert; nur die Workflow-Commands (slice-033, [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) bleiben in welle-04.

## 6. Risiken und offene Punkte

- **settings.json-Grenze wandert (slice-031-Kopplung).** slice-031 emittierte `settings.json` **Stop-only** und testete/smokete „**kein** PreToolUse". slice-032 dreht das um: `PreToolUse` **muss** jetzt da sein. Der slice-031-Test `TestEnforce_SettingsStopOnly`, die smoke.sh-Negativprobe und die Mutation `32` sind **umzuschreiben** (nicht nur zu ergänzen) — sonst widersprechen sie sich (roter Smoke, wie slice-030s Selbstwiderspruch).
- **awk-Abhängigkeit mit-emittieren.** Der Guard referenziert `tools/harness/extract-command.awk`; ohne den mit-emittierten Extraktor läuft der Guard fail-closed (blockt ALLES) im Ziel. Beide gehören in denselben Emit + Pre-Flight. Der emittierte Pfad ist `tools/harness/` ([`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)), nicht das lokale `harness/tools/` — der Guard muss den emittierten Pfad referenzieren.
- **Stiller Lang-Drift.** Bekäme `gen` ein neues Profil ohne BLOCKED-Set-Eintrag, blockte der emittierte Guard nur die universellen Paketmanager (die Sprach-Toolchain liefe ungehindert) — eine stille Lücke. Gegenmaßnahme: Test koppelt `blockedSet` an `gen.SupportedLangs()` (jedes Profil braucht einen Eintrag).
- **Verbatim-Treue der Scan-Logik.** Nur awk-Pfad + BLOCKED-Zeile + ID-Refs ändern sich; die Scan-/Quote-/Sub-Shell-Logik ist im Dogfood (`test/guard.bats`) erprobt und darf **nicht** driften. full-smoke prüft das Verhalten am emittierten Guard (nicht nur Präsenz).
- **Substitution ist neu im Enforce-Emit.** slice-031s Enforce schrieb alles verbatim; der Guard braucht `@@BLOCKED_SET@@`-Ersetzung → `Enforce` bekommt `lang`. Der Platzhalter darf im emittierten Skript **nicht** zurückbleiben (Test: kein `@@` im Ziel).

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen:** 2026-07-22. Review [KONFORM](../../../reviews/2026-07-22-slice-032-review.md)
(0 HIGH/MEDIUM, 2 LOW behoben, 12 Negativbefunde), Verifikation bestätigt die DoD (getrennter
Kontext; `make gates` + `make mutate` **35/35** + `make full-smoke` selbst gefahren, dazu ein
**selbst gebootstrapptes Ziel** inspiziert — kein `@@BLOCKED_SET@@`-Rest, go-Toolchain + universelle
Manager, `tools/harness/`-awk-Pfad, beide Hooks verdrahtet, LOW-Fixes real im Ziel; Guard blockt
`go build`/`sudo pip install`/`staticcheck`, lässt `make test` durch).

**Ergebnis:** Die **Durchsetzungsschicht ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)) ist komplett emittiert** — Gate-Nachweis + Stop-Hook
(slice-031) **und** der Command-Guard (dieser Slice, als **Tool-als-Quelle**, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)):
`.claude/hooks/pretooluse-command-guard.sh` (bash+awk, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) + `tools/harness/extract-command.awk`,
mit `PreToolUse` neben dem Stop-Hook in `.claude/settings.json`. BLOCKED-Set je `--lang`
(`blockedSet`, an `gen.SupportedLangs()` gekoppelt). In welle-04 bleiben nur die
Workflow-Commands (slice-033, [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)).

**Steering-Loop-Einträge:**

- **Eine wandernde Grenze wird umgeschrieben, nicht ergänzt.** slice-031 hatte „settings.json ist
  Stop-only" als Test (`TestEnforce_SettingsStopOnly`), smoke.sh-Negativprobe **und** Mutation `32`
  fixiert. slice-032 dreht die Grenze um (PreToolUse **muss** jetzt da sein) — alle drei wurden
  **umgeschrieben** (Test→`_SettingsWiresBothHooks`, Negativ→Positiv, Mutation `32` gelöscht+umgewidmet),
  nicht danebengestellt. Ein danebengestellter „kein PreToolUse"-Rest hätte den Selbstwiderspruch aus
  slice-030 (roter Smoke) reproduziert. Gegenprobe grün: `make smoke` + `grep -rn SettingsStopOnly`
  leer.
- **Emittierte Artefakte tragen keine Quell-Repo-Identität.** Der Review (L-2) fing im emittierten
  Guard den zurückgebliebenen Werkzeugnamen `ai-harness-init` + eine Emit-Substitutions-Prosa — im
  Ziel toter Text. Merke für jeden Emit-a-script-Slice: den generischen Text gegen Quell-Repo-Namen,
  ADR-/MR-Nummern und Meta-Prosa („wird beim Emit ersetzt") scrubben; das ist dieselbe Klasse wie
  slice-031s MR-Ref-Neutralisierung, nur an einer Stelle durchgerutscht.
- **Gegen erklärende Kommentare ist ein Wort-Grep der falsche Sensor.** Der erste Test für [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  griff nach „node"/„jq" per Substring — und schlug am eigenen „KEIN node/jq"-Kommentar fehl. Ein
  Negativ-Beleg über Abwesenheit eines Wortes ist brüchig, wenn der Text das Wort erklärend nennt;
  der ehrliche Beleg ist positiv (`awk -f` als Parser) plus der **behaviorale** full-smoke-Lauf
  (Guard läuft real mit bash + awk).

**Folge-Slices / benannte `open/`-Kandidaten:** keine neuen aus slice-032. Offen aus slice-031
(git-Repo-Vorbedingung der emittierten `make gates`, INFO I-1) + welle-04 §4-Tabelle-Stale bleiben
für den welle-04-Closure (nach slice-033).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (`internal/emit/`, `cmd/`, `harness/tools/`, `test/` — siehe Kurs
Modul 5 §Worked Mini-Example): adoptierte Emit-Mechanik (auf slice-031 aufsetzend), tool-eigene
Quelle (Guard + Extraktor sind im Dogfood erprobt, `test/guard.bats`), niedriges
Evidenz-/Diskrepanz-Risiko.
