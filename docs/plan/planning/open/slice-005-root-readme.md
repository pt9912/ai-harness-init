# Slice slice-005: Root-README emittieren

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-02-fetch-und-readme (geplant, siehe
[roadmap](../in-progress/roadmap.md)).

**Bezug:** `LH-FA-05`, `LH-FA-01`.

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`bin/ai-harness-init` emittiert die Root-`README.md` aus der
project-readme-Vorlage; der Pointer-/Trust-Abschnitt steht als
**gate-sichere Vorwärts-Verweise**, bis die Ziele existieren.

## 2. Definition of Done

- [ ] `LH-FA-05` erfüllt: Root-README aus Vorlage, Projektname gestempelt.
- [ ] Vorwärts-Verweise gate-sicher: kein Markdown-Link auf noch fehlende Ziele (Inline-Code/Plain-Text), `make docs-check` im Zielrepo grün.
- [ ] Happy-Path-Smoke (`LH-FA-01`/`LH-QA-01`): Bootstrap in tmp-Repo → `make gates` grün out-of-the-box.
- [ ] bats-Test: README vorhanden, gestempelt, `docs-check` grün.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `bin/ai-harness-init` | update | README-Emit-Schritt + Stempelung |
| `test/readme-emit.bats` | neu | Existenz, Stempelung, gate-sichere Verweise |

## 4. Trigger

welle-02 in-progress; nach slice-004 (gemeinsamer Emit-/Fetch-Pfad).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.
Schließt zusammen mit slice-004 die welle-02 (voller `LH-QA-01`-Smoke).

## 6. Risiken und offene Punkte

- Gate-Sicherheit der Vorwärts-Verweise ist der kritische Punkt: ein
  versehentlicher Link auf ein noch fehlendes Ziel bricht `docs-check`
  im frischen Repo (Anti-Ziel `LH-QA-01`).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
