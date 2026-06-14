# Slice slice-006: Command-Guard bash+awk + bats-Gate

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

Den in Phase 2 adoptierten **node**-Command-Guard durch eine **bash + awk**-
Implementierung ersetzen (zero neuer Dep, fail-closed bei Parse-Zweifel) und
das **`bats`-Gate** hochziehen — eine Implementierung ist zugleich die
Emissions-Quelle für [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (kein Drift). Erster echter Code-Slice;
self-contained (reines Shell, kein Go nötig).

## 2. Definition of Done

- [ ] `.claude/hooks/pretooluse-command-guard.sh` läuft ohne `node`/`jq`:
      awk-Extraktor zieht `tool_input.command` aus der Hook-stdin-JSON;
      bei Parse-Zweifel → **fail-closed** (block). Erfüllt [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)/[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md).
- [ ] **Verhaltens-Parität** zum node-Guard: blockt Host-Toolchain
      (`go`/`pip`/`npm`/`cargo`/`apt`/`brew`/…), passt `make`/`git`/`docker`;
      Sub-Shell (`bash -c "…"`) rekursiv (Tiefe ≤ 3, darüber fail-closed);
      Zuweisungs-/Wrapper-Präfixe (`sudo`/`env`/…) übersprungen.
- [ ] `bats`-Suite deckt: gültige JSON → korrekter Befehl; malformed JSON →
      block; blockierte vs. erlaubte Kommandos; `bash -c`-Verschachtelung;
      der Heredoc-/Commit-Message-Fall (bekannter False-Positive — dokumentiert).
- [ ] Guard ist **shellcheck-clean**, keine Inline-Suppression (Hard Rule 3.2
      sinngemäß für Shell).
- [ ] `make test` (`bats`) real angelegt und **im selben Commit** ins
      `gates`-Target genommen + in AGENTS.md §4 / harness/README.md §Sensors
      aus „Nicht behauptet" promotet (Promotion-Trigger, Hard Rule 3.1).
- [ ] `make gates` grün auf frischem Checkout (mit `node` *abwesend* probeweise
      verifiziert — der Guard darf node nicht mehr brauchen).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/pretooluse-command-guard.sh` | rewrite | bash + awk statt node; Logik-Parität |
| `tools/harness/` (ggf. awk-Helfer) | neu/update | JSON-Feld-Extraktor, testbar isoliert |
| `test/guard.bats` | neu | Parität-, Parse- und fail-closed-Fälle |
| `Makefile` | update | `test` (bats) anlegen, in `gates` |
| AGENTS.md §4, harness/README.md §Sensors | update | Promotion `test` aus „Nicht behauptet" |

## 4. Trigger

[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) accepted (erfüllt). Sofort startbar; unabhängig vom Go-CLI.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **awk-Extraktor-Korrektheit** (verschachtelte Quotes, `\uXXXX`-Escapes):
  Kernfälle per `bats`; Zweifel → fail-closed (block). Der Guard ist
  Stolperdraht, keine Sandbox — Vollständigkeit ist nicht das Ziel.
- **bats-Verfügbarkeit**: Dev-/CI-Tooling (der Go-Pivot trennt Dev-Toolchain
  vom Runtime-Budget, [`ADR-0003`](../../adr/0003-go-native-binaries.md)). Der Container muss `bats` mitbringen.
- **Shell-Lint-Domäne**: AGENTS §3.2 ist nach dem Go-Pivot auf `golangci-lint`
  formuliert; für Shell-Skripte gilt weiterhin shellcheck — getrennt führen
  (ggf. eigener `shell-lint`-Gate als Folge-Slice).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`tools/harness/` ist als GF deklariert ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); `.claude/hooks/`
teilt dieselbe adoptierte Harness-Mechanik.
