# Slice slice-amend-haelt-den-index-pfadrein: Ein Träger hält `--amend` gegen fremde Index-Einträge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** Beobachtungs-Register
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege — Konsistenz-Review 2026-09-15, `slice-174-archivierung-emittieren`,
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`; 3× am
2026-09-27 erreicht, Ausgang `geplant`), [`AGENTS.md`](../../../../AGENTS.md) §3.10 (Rollentrennung
bei parallel laufenden Rollen im selben Klon).

**Berührte Spec-Stellen:** —

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** `git commit --amend` committet den **Index**, nicht die Pfade des eigenen Vorgangs — läuft
zwischen dem letzten eigenen Commit und dem Amend ein paralleler Vorgang und hinterlässt Dateien im
Index, reißt der Amend sie mit. Dieser Slice baut den Träger, der das verhindert: entweder eine
Disziplin (`git commit --only <pfad>` statt `--amend`/`-A`, verankert in den Rollen-Anweisungssätzen,
die selbst committen) oder ein `pre-commit`-Hook, der den Index vor dem Commit gegen die vom
aufrufenden Lauf erwarteten Pfade hält.

Beleg:
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege: Konsistenz-Review 2026-09-15, `slice-174-archivierung-emittieren`,
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`).

**Ausdrücklich NICHT in diesem Slice:**

- **Ein genereller Index-Wächter, der jeden Commit prüft.** *Anderer Vorgang:* Träger ist hier
  ausdrücklich der `--amend`-Fall, nicht jede Commit-Form.
- **Die Behebung bereits geschehener, gepushter Fälle.** *Bestand bleibt bewusst stehen:* Alle drei
  Belege sind bereits selbstheilend repariert (Reflog-Reset vor dem Push); es gibt nichts mehr zu
  korrigieren.

## 2. Definition of Done

- [ ] Ein Träger (Disziplin-Satz in den committenden Rollen-Anweisungssätzen oder ein
      `pre-commit`-Hook) hält `--amend` gegen fremde Index-Einträge ab. *(Rot-Kommando: zwei
      parallele Vorgänge simulieren — ein eigener Commit, danach ein fremder Datei-Stage, dann
      `--amend` — ohne Träger reißt der Amend den fremden Stand mit; mit Träger schlägt er an oder
      verhindert das Mitreißen.)*
- [ ] Zielort und schreibende Rolle bestätigt der Architect (§3.8).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Rollen-Anweisungssätze (`.claude/commands/*.md`) oder `.githooks/pre-commit` (neu) | update/neu | Träger der Disziplin bzw. des Hooks |
| [`harness/README.md`](../../../../harness/README.md) §Sensors/Werkzeuge | update, falls neues Target entsteht | Doku-Pflicht bei neuem Werkzeug |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn der Hook-Weg eine neue Wächter-Klasse in der
  Durchsetzungsschicht braucht, die über einen einzelnen Slice hinausgeht.
- `in-progress` → `open` (blockiert): wenn kein Träger ohne Gate-Senkung baubar ist.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Der Hook-Weg wirkt nur, wo `make hooks-install` gelaufen ist (dieselbe Grenze wie beim
  `commit-msg`-Träger, [`harness/README.md`](../../../../harness/README.md) §Traceability).
  **Ausgang:** weiter offen → Register.
- Die Disziplin-Form wirkt nur, wo der Rollen-Anweisungssatz gelesen wird. **Ausgang:** weiter offen
  → Register.

## 7. Closure-Notiz

<!-- wird bei der Closure gefüllt — nicht Teil dieser Planung. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:**
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege, Stand `geplant`, dieser Slice) ist der Auslöser selbst.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
