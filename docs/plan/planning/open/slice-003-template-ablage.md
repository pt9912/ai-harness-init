# Slice slice-003: Zweiklassige Template-Ablage

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** `LH-FA-02`.

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`bin/ai-harness-init` legt die Templates zweiklassig ab: Singletons (z. B.
lastenheft, architecture, AGENTS, harness/README, conventions) werden zu
`.md`-Zielen; wiederkehrende Templates (ADR, slice, welle, carveout,
review-report) bleiben co-located als `.template.md`. Die Set-Index-README
wird nie mitkopiert.

## 2. Definition of Done

- [ ] `LH-FA-02` erfüllt: Singletons → `.md`, wiederkehrende → `.template.md`.
- [ ] Set-Index-README des Template-Sets wird nicht emittiert.
- [ ] Projektname wird in die Singleton-Ziele gestempelt.
- [ ] bats-Test: nach Lauf existieren die erwarteten `.md`/`.template.md`-Paare, keine Set-Index-README.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `bin/ai-harness-init` | update | Ablage-Schritt: Klassifizieren Singleton vs. wiederkehrend, stempeln |
| `test/template-ablage.bats` | neu | Paar-Existenz + Set-Index-README-Ausschluss prüfen |

## 4. Trigger

slice-001 done; idealerweise nach slice-002 (gemeinsamer Emit-Pfad).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- Klassifikations-Quelle: Welche Templates sind Singleton vs. wiederkehrend?
  Aus dem Set ableitbar, aber muss eindeutig sein — sonst landet ein
  wiederkehrendes Template als gefülltes `.md` (Drift). Liste fixieren.
- `--force`-Semantik (Überschreiben) berührt diesen Slice (`LH-FA-01` Boundary).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
