# ADR-0004: Durchsetzungsschicht-Emission + Guard in bash/awk

**Status:** Accepted

**Datum:** 2026-06-13

**Autor:** Demo

**Bezug:** [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)

**Schärft:** [architecture.md §1/§2 Komponenten und Schichten](../../../spec/architecture.md) — neuer *Durchsetzungs-Emitter*.

---

## Kontext

Phase 2 hat die Durchsetzungsschicht (Stop-Hook, Command-Guard, Gate-Nachweis,
`CLAUDE.md`, Reviewer-Skill) für *dieses* Repo adoptiert — den Command-Guard
zunächst in **node** (aus d-check/b-cad übernommen). [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) verlangt, dass
der Bootstrap diese Schicht **ins Zielrepo emittiert**: ein „echter" Harness ist
nicht nur Guides + Sensors, sondern auch Durchsetzung.

Der Guard muss die Hook-stdin-JSON (`tool_input.command`) sicher parsen. node
ist fail-closed ohne `node` und widerspräche dem Minimal-Dep-Anspruch
([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) für emittierte Repos. Der Guard läuft zudem vor **jedem** Bash-Call
— Latenz ist kritisch.

## Entscheidung

1. **Emission ins Zielrepo: ja.** Quelle ist das **gepinnte Kurs-Template-Set**
   (`lab/templates/.claude/`, `tools/harness/`, `CLAUDE.md`, `.harness/skills/`) —
   Picker, kein Generator (konsistent mit `ADR-0001`). <!-- d-check:ignore (Lineage-Verweis auf die superseded Skelett-Distributions-ADR; die Picker-Stanz dieser ADR gilt der Durchsetzungsschicht und bleibt unberührt) -->
2. **Command-Guard in bash + awk.** `awk` ist POSIX-Basis (überall vorhanden, wo
   die bash-Hooks laufen) — **kein neuer Dep**, kein Per-Call-Container. Der
   awk-Extraktor zieht nur das eine Feld `tool_input.command`; bei Parse-Zweifel
   **fail-closed** (block). Damit ist der Guard **immer** mitemittierbar.
3. **BLOCKED-Set pro `--lang`/Build-Model** parametrisiert (Go-Ziel blockt `go`,
   Python-Ziel `pip`, …) — gekoppelt an das Sprachskelett.

Folge: der in Phase 2 adoptierte **node-Guard wird auf bash + awk umgestellt** —
eine Implementierung ist zugleich die Emissions-Quelle (kein Drift).

## Verglichene Alternativen

### Option A — Host-`node`/`jq` als Guard-Parser

- Pro: robustes Parsing ohne Eigenbau.
- Contra: neuer Host-Dep im Zielrepo, verletzt den Minimal-Anspruch ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

### Option B — Guard als OCI-Image (Parser im Container)

- Pro: kein neuer Host-Dep (docker ist Pflicht), reproduzierbar.
- Contra: `docker run` pro Bash-Call (~300–700 ms Kaltstart) — der Hook feuert
  ständig; interaktiv zu zäh. Parser-Wahl im Image ändert die Latenz nicht.

### Option C — bash + awk (gewählt)

- Pro: zero neuer Dep, schnell (lokal), überall lauffähig → immer emittierbar.
- Contra: wir pflegen einen kleinen JSON-Feld-Extraktor selbst — abgesichert
  durch `bats`-Tests und fail-closed bei Zweifel (Guard ist Stolperdraht, keine Sandbox).

## Konsequenzen

- Positiv: emittierter Ziel-Harness bleibt auf `bash + git + docker` (awk
  POSIX-Basis); Durchsetzung „immer dabei", konsistente Familie.
- Negativ: eigener awk-Extraktor (Test-Pflicht); BLOCKED-Set braucht
  Sprach-Tabellen.
- Folge-Slices: (1) Guard hier auf bash + awk umstellen (`bats`); (2)
  Durchsetzungsschicht-Emission im Picker ([`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| Smoke | emittiertes Repo: `make gates` grün **ohne** node/jq; Guard blockt Ziel-Toolchain | `make test` *(folgt)* |
| bats | awk-Extraktor: gültige/ungültige JSON-Eingaben, Zweifel → block | `make test` *(folgt)* |

## Re-Evaluierungs-Trigger

Wenn ein Ziel-Skelett selbst `node`/`jq` als Runtime mitbringt (Parser dann
„gratis") → Guard-Implementierung neu bewerten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-06-13 | Accepted | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Lastenheft v0.3.0) |
