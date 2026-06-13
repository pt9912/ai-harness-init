# ADR-0002: Test-Tooling-Grenze (bats) gegenüber LH-QA-03

**Status:** Superseded by [ADR-0003](0003-go-native-binaries.md)

**Datum:** 2026-06-13

**Autor:** Demo

**Bezug:** [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** [architecture.md §3 Externe Abhängigkeiten](../../../spec/architecture.md) — klassifiziert Runtime- vs. Dev-/CI-Abhängigkeiten.

---

## Kontext

Der Plan-Review vom 2026-06-13 (`docs/reviews/2026-06-13-plan-review-slices.md`,
Finding F-4) deckte eine Spannung auf: Die Slices `slice-001`..`slice-005`
nutzen **bats** als verpflichtendes Test-Tooling, und `slice-001` promotet
`test` (bats) ins `gates`-Target. [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) begrenzt die Abhängigkeiten
jedoch auf „bash + git + docker; sonst nichts". Ohne Entscheidung würde die
Plan-Schicht eine Abweichung von einer abnahmebindenden NFA still setzen.

Schlüsselbeobachtung: [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) nennt in seiner **eigenen Messmethode**
bereits „shellcheck-clean". shellcheck ist damit von Anfang an als
Verifikations-Tooling gemeint, nicht als Runtime-Abhängigkeit — die
Minimal-Dep-Aussage betrifft die **Laufzeit** des Tools und die in
Ziel-Repos **emittierten** Gates, nicht die Entwicklungs-/CI-Toolchain
dieses Repos.

## Entscheidung

Wir trennen zwei Ebenen:

1. **Tool-Runtime + emittierte Ziel-Gates** — gebunden durch [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten):
   `bash + git + docker`. Ein per `ai-harness-init` gebootstrapptes
   Ziel-Repo hängt **nicht** von bats ab.
2. **Entwicklungs-/CI-Verifikations-Toolchain dieses Repos** — `shellcheck`
   (lint) und `bats` (test). Diese sind **Dev-/CI-Tooling**, nicht Teil des
   Runtime-Dependency-Budgets von [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), und werden im Dev-/CI-Container
   bereitgestellt.

bats ist damit zulässig für die Tests von `ai-harness-init` selbst und darf
ins `gates`-Target dieses Repos; es wird nie in ein Ziel-Repo emittiert.

## Verglichene Alternativen

### Option A — bats als Runtime-Dep akzeptieren / [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) per Change Request erweitern

- Pro: keine Interpretations-Frage, Dep explizit im Lastenheft.
- Contra: dehnt das vertragliche Minimal-Dep-Versprechen, obwohl bats die
  Ziel-Repos nie berührt; eine ADR darf das Lastenheft ohnehin nicht schärfen.

### Option B — bats vermeiden, Tests in reinem bash

- Pro: gar keine zusätzliche Abhängigkeit.
- Contra: reimplementiert ein Test-Harness schlecht; `AGENTS.md` §4 und
  `harness/README.md` §Sensors nennen `test` (bats) bereits als geplanten Gate.

### Option C — Dev/CI-Toolchain von Runtime trennen (gewählt)

- Pro: [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bleibt unangetastet; emittierte Ziel-Repos bleiben
  bats-frei; deckt sich mit der shellcheck-Nennung in der [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)-Messmethode.
- Contra: Dev-/CI-Umgebung muss bats (und shellcheck) bereitstellen.

## Konsequenzen

- Positiv: Kein Lastenheft-Schärfen; die emittierten Ziel-Gates bleiben auf
  `bash + git + docker`; [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (grünes Ziel-Repo out-of-the-box) bleibt
  ohne bats erfüllbar.
- Negativ: Der Dev-/CI-Container muss bats + shellcheck mitbringen.
- Folgepflicht: `slice-001`..`slice-005` referenzieren `ADR-0002` für die <!-- d-check:ignore (Selbstverweis im superseded ADR, Lineage) -->
  bats-Nutzung; der [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke darf kein bats-Target ins Ziel-Repo schreiben.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| Smoke | emittiertes Ziel-Repo enthält kein bats/`test`-Target; dessen `make gates` läuft ohne bats | `make test` *(folgt)* |

## Re-Evaluierungs-Trigger

Wenn `ai-harness-init` selbst bats-basierte Test-Skelette in Ziel-Repos
emittieren soll (bats würde dann Ziel-Runtime-relevant) → Grenze neu bewerten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-06-13 | Accepted | `slice-001` (F-4, Plan-Review 2026-06-13) |
| 2026-06-13 | Superseded by [ADR-0003](0003-go-native-binaries.md) | Go-Pivot (bash→Go-Toolchain) |
