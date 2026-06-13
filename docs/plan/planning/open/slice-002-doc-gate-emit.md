# Slice slice-002: Doc-Gate-Baseline emittieren

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** `LH-FA-03`, `LH-QA-01`.

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`bin/ai-harness-init` schreibt die Doc-Gate-Baseline ins Zielrepo:
`.d-check.yml` (Suffix-Ignore) und `harness.mk` (d-check per Digest
gepinnt) — `ids`/`codepaths` nur mit existierenden Targets/roots aktiviert.

## 2. Definition of Done

- [ ] `LH-FA-03` erfüllt: `.d-check.yml` + `harness.mk` werden emittiert.
- [ ] `LH-QA-01`: emittierter `make docs-check` läuft im Zielrepo grün — keine halluzinierten Gates; `ids`/`codepaths` nur mit vorhandenen Targets.
- [ ] Digest des d-check-Image aus einer Pin-Quelle, nicht floating (`LH-QA-02`-Anschluss).
- [ ] bats-Test: nach Emit ist `docs-check` im tmp-Repo Exit 0.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `bin/ai-harness-init` | update | Emit-Schritt für `.d-check.yml` + `harness.mk` (Stub aus slice-001 füllen) |
| `test/emit-gate.bats` | neu | Emit + `docs-check`-Grünlauf im tmp-Repo prüfen |

## 4. Trigger

slice-001 done (Arg-Parser/Skeleton vorhanden).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- Gate-Config wächst mit den Artefakten: `ids`/`codepaths` dürfen im
  emittierten Zielrepo nur aktiv sein, wo Targets existieren — sonst
  bricht `docs-check` im frischen Repo (Anti-Ziel von `LH-QA-01`).
- docker muss im Zielrepo-Kontext verfügbar sein (Annahme `LH-QA-03`).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
