# Slice slice-001: CLI-Skeleton + Gate-Promotion

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

Ein lauffähiges `bin/ai-harness-init` mit Arg-Parser und korrekten
Fehlerpfaden — und die dazugehörigen Code-Gates `lint` (shellcheck) und
`test` (bats) real angelegt und aus „Nicht behauptet" in die
Sensors-Tabellen promotet.

## 2. Definition of Done

- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Negative-AC: fehlendes `--lang` → Exit 2 + Usage auf stderr (bats-Test).
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary-Teil: `--help`/`-h` → Exit 0 + Usage auf stdout (bats-Test).
- [ ] `--lang`, `--name`, `--force` werden geparst; unbekanntes Flag → Exit 2 + Usage. Bootstrap-Wirkung folgt in slice-002/003 (hier Stub: Exit 0 mit „noch nicht implementiert").
- [ ] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): shellcheck-clean — `make lint` grün, keine Inline-Suppression (Hard Rule 3.2).
- [ ] bats-Suite grün — `make test`.
- [ ] `lint`/`test`-Targets im Makefile angelegt **und im selben Commit** ins `gates`-Target aufgenommen sowie in AGENTS.md §4 + harness/README.md §Sensors aus „Nicht behauptet" promotet — Promotion erst nach lauffähigem Target, nie davor (Hard Rule 3.1, kein halluziniertes Gate).
- [ ] `make gates` grün auf frischem Checkout.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `bin/ai-harness-init` | neu | Arg-Parser, Usage, Exit-Codes; Bootstrap-Schritte als Stubs |
| `test/cli.bats` | neu | Negative-/Boundary-AC von [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) als Test |
| `Makefile` | update | `lint` (shellcheck bin/), `test` (bats test/), beide in `gates` |
| AGENTS.md §4, harness/README.md §Sensors | update | Promotion `lint`/`test` aus „Nicht behauptet" |

## 4. Trigger

Welle-01 in-progress (erste Slice der Welle, keine Vorbedingung außer Bootstrap done).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz geschrieben → nach `done/`.

## 6. Risiken und offene Punkte

- **bats-Verfügbarkeit:** Entschieden in [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) — bats ist Dev-/CI-Test-Tooling,
  nicht Teil des Runtime-Budgets von [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash+git+docker) und wird nie
  ins Ziel-Repo emittiert. Der Dev-/CI-Container stellt bats + shellcheck bereit.
- shellcheck-Strenge kann frühe Refactors erzwingen (akzeptiert, Ziel von [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example);
neues Repo, Spec führt, Code folgt — entspricht `harness/conventions.md`
§Modus-Deklaration (`*` → Greenfield).
