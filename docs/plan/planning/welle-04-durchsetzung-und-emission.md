# Welle welle-04-durchsetzung-und-emission: Durchsetzung & Emission

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein formaler Meilenstein-Bezug (trägt zu einem künftigen
„vollständiger Harness inkl. Durchsetzung"-Zustand bei; die Meilenstein-Tabelle
kennt bisher M1/M2).

**Verantwortlich:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Welle-Ziel

Der Bootstrap emittiert die **Durchsetzungsschicht** und die **Workflow-Commands** ins
Zielrepo — **Tool-als-Quelle**, je `--lang` parametriert ([`ADR-0006`](../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)).
Der Adopter erhält damit nicht nur Gerüste + Sensors, sondern auch die **Durchsetzung**
(Stop-Hook, Command-Guard, Gate-Nachweis, `CLAUDE.md` — [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren))
und die **Prozess-Anleitung** (`.claude/commands/` — [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)).
Belegt via `make full-smoke`: das emittierte Repo fährt `make gates` grün, der Guard blockt
die Ziel-Toolchain, kein node/jq ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 2. Trigger (Welle startet)

- welle-03 in `done/` (erfüllt — M2 erreicht).
- [`ADR-0006`](../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) **accepted** (erfüllt — nach unabhängigem
  Review-Pass angenommen). Picker → Tool-als-Quelle entsperrt die Emission **ohne** Kurs-Upstream-Warten.
  **Beobachtbar**: ohne die angenommene ADR fehlte die Quelle.

## 3. Closure-Trigger (Welle schließt)

Beobachtbare Bedingungen (kein Kalendertag):

- slice-030, slice-031, slice-032, slice-033 in `done/`.
- `make gates` grün.
- **`make full-smoke` grün:** das emittierte Repo trägt Durchsetzung + Commands; `make gates`
  dort out-of-the-box grün; der emittierte Guard blockt die Ziel-Toolchain; kein node/jq
  (nur `bash + git + docker`, awk POSIX-Basis) — mit echter Ausgabe belegt ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **`make mutate` grün** (die neuen Wächter rot gesehen).
- Carveout-Audit ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-07-carveouts.md)): 0 offen oder dokumentiert.
- Closure-Notiz in `done/welle-04-results.md` (Steering-Loop-Lerneintrag).

## 4. Slices in dieser Welle

Empfohlene Reihenfolge: erst den Emit-Pfad de-risken (Skills, Quelle vorhanden), dann die
Tool-als-Quelle-Mechanik, dann Guard + Commands.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-030](done/slice-030-durchsetzung-skills-emit.md) | Reviewer-/Closure-Skill emittieren (`.harness/skills/`, Fetch — Emit-Pfad de-risken) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| slice-031 | Durchsetzungs-Mechanik als Tool-Quelle emittieren (Stop-Hook, `record-gates`, `CLAUDE.md`, `.claude/settings.json`) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| slice-032 | Command-Guard emittieren + BLOCKED-Set je `--lang` (bash + awk, Tool-als-Quelle) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| slice-033 | Workflow-Commands emittieren (`.claude/commands/`, Tool-als-Quelle) | [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) |

Nur slice-030 ist bereits geschnitten (`open/`); 031–033 bekommen ihre Plandateien per `cp`,
sobald sie an der Reihe sind (kein Vorab-Schnitt — Muster wie in welle-03).

## 5. Abhängigkeiten

- Wird blockiert von: **keine** — [`ADR-0006`](../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)
  entsperrte die Quelle (Tool-als-Quelle), welle-03 liegt in `done/`.
- Blockiert: keine geplante Folge-Welle.
- Intern empfohlen sequenziell: slice-030 → slice-031 → slice-032 → slice-033 (jeder Schritt
  vom vorigen Emit-Pfad getragen).

## 6. Out-of-Scope für diese Welle

- **Arch-Gate-Emit / a-check ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)):** hängt an hexagonalen
  Schichten (weder Dogfood noch Skelett tragen `domain/ports/adapters`) — separater, späterer
  Slice, **kein** Quellmodell-Thema wie diese Welle.
- **Kurs-Upstream-Ergänzung der Durchsetzungs-/Command-Templates:** durch
  [`ADR-0006`](../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) (Tool-als-Quelle) nicht mehr nötig.
- **Weitere Sprach-BLOCKED-Sets über `go` hinaus** ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
  nennt sechs) — der Guard bleibt sprach-agnostisch, Profile folgen als eigene Slices.
- **`architecture.md`-Nachzug** (Emitter-Herkunftsklassen: Skelett Generator, Enforce Tool-als-Quelle) —
  eigene Doku-Reconciliation (bekannter Backlog-Punkt), nicht Scope hier.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-<NN>-results.md. -->
