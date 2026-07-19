# ADR-0001: Distribution der Sprachskelette

**Status:** Superseded by [ADR-0005](0005-ziel-repo-distribution.md)

**Datum:** 2026-06-13

**Autor:** Demo

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** [architecture.md §Komponenten](../../../spec/architecture.md) — Fetcher/Picker.

---

## Kontext

[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) verlangt, dass das Tool sprachspezifische Code-Gates aus den
lab/example/<lang>-Skeletten verdrahtet. Diese Skelette liegen im
Kurs-Repo, **nicht** im Templates-ZIP (das ist docs-only). Wie kommt der
Picker reproduzierbar ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) an das richtige Skelett?

## Entscheidung

Wir wählen **Variante C: Fetch vom gepinnten Kurs-Tag**. Der Picker holt
das Sprachskelett aus dem Kurs-Release/Tag, den `harness/conventions.md`
§Baseline als adoptierten Stand notiert.

## Verglichene Alternativen

### Option A — Skelette in den Templates-ZIP bündeln

- Pro: ein Download, offline.
- Contra: ZIP bläht sich um 5 Sprach-Toolchains; der docs-only-Charakter geht verloren.

### Option B — eigener Skelett-ZIP/Tag pro Sprache

- Pro: gezielter Download.
- Contra: zweite Release-Pipeline, zweiter Pin, mehr Drift-Fläche.

### Option C — Fetch vom gepinnten Tag (gewählt)

- Pro: kein ZIP-Bloat; immer der adoptierte Stand; gleiche Pin-Logik wie die Templates.
- Contra: braucht beim Bootstrap einmalig Netz.

## Konsequenzen

- Positiv: Single Source of Truth bleibt lab/example; reproduzierbar über den Tag.
- Negativ: Bootstrap braucht einmalig Netzzugang.
- Folgepflicht: Picker pinnt den Tag; `harness/conventions.md` §Baseline hält ihn fest.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| Smoke-Test | zwei Läufe mit gleichem Tag → identische Ausgabe | `make test` *(folgt)* |

## Re-Evaluierungs-Trigger

Wenn Offline-Bootstrap (air-gapped) zur Pflicht wird → Option A/B neu bewerten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-06-13 | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| 2026-07-19 | Superseded by [ADR-0005](0005-ziel-repo-distribution.md) — Skelett-Fetch → deterministischer Generator; Templates+Regelwerk-Fetch | Lastenheft v0.7.0 |
