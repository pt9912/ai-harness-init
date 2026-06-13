# Slice slice-004: Sprachskelett-Picker

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-02-fetch-und-readme (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** `LH-FA-04`, `LH-QA-02`, `ADR-0001`.

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`bin/ai-harness-init --lang <X>` holt das passende Sprachskelett vom
**gepinnten Kurs-Tag** (`ADR-0001`, Variante C) und verdrahtet dessen
Code-Gates — emittiert nur lauffähige Make-Targets.

## 2. Definition of Done

- [ ] `LH-FA-04` erfüllt: Skelett für `--lang` wird vom gepinnten Tag geholt und verdrahtet.
- [ ] `LH-QA-02`: Tag/Pin aus `harness/conventions.md` §Baseline; zwei Läufe mit gleichem Tag → identische Ausgabe.
- [ ] Nur lauffähige Targets emittiert (keine halluzinierten Gates, `LH-QA-01`).
- [ ] Unbekannte Sprache → Exit 2 + Liste verfügbarer Skelette.
- [ ] bats-Test (Netz gemockt/fixiert): Verdrahtung + Reproduzierbarkeit.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `bin/ai-harness-init` | update | Fetch+Picker-Schritt gegen gepinnten Tag |
| `test/picker.bats` | neu | Verdrahtung, Reproduzierbarkeit, Unknown-Lang-Fehlerpfad |

## 4. Trigger

welle-01 done; `bin/ai-harness-init` parst `--lang` und emittiert offline.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz beim Bootstrap nötig** (`ADR-0001` Konsequenz). Air-gapped ist
  Re-Evaluierungs-Trigger von `ADR-0001`, nicht Scope hier.
- Test ohne echtes Netz: Fetch mocken oder Fixture-Tag — sonst flakey/`LH-QA-02`-Verstoß.
- bats = Dev-/CI-Tooling, nicht Runtime-Budget von `LH-QA-03` (`ADR-0002`); gilt fort.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
