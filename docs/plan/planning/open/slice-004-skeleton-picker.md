# Slice slice-004: Sprachskelett-Picker

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** welle-02-fetch-und-readme (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`bin/ai-harness-init --lang <X>` holt das passende Sprachskelett vom
**gepinnten Kurs-Tag** ([`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md), Variante C) und verdrahtet dessen
Code-Gates — emittiert nur lauffähige Make-Targets.

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) erfüllt: Skelett für `--lang` wird vom gepinnten Tag geholt und verdrahtet.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): Tag/Pin aus `harness/conventions.md` §Baseline; zwei Läufe mit gleichem Tag → identische Ausgabe.
- [ ] Nur lauffähige Targets emittiert (keine halluzinierten Gates, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
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

- **Netz beim Bootstrap nötig** ([`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md) Konsequenz). Air-gapped ist
  Re-Evaluierungs-Trigger von [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md), nicht Scope hier.
- Test ohne echtes Netz: Fetch mocken oder Fixture-Tag — sonst flakey/[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Verstoß.
- bats = Dev-/CI-Tooling, nicht Runtime-Budget von [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md)); gilt fort.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
