# Slice slice-009: Regelwerk-Drift-Check

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor).

**Autor:** Demo. **Datum:** 2026-06-14.

---

## 1. Ziel

Ein **read-only** `make regelwerk-check` meldet **Upstream-Drift** des
Regelwerk-Cache für einen **scheduled/CI-Alarm** — es holt den aktuellen
Upstream-Stand und vergleicht dessen `sha256` mit dem gepinnten
`REGELWERK_SHA256` ([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)), **ohne** den lokalen Cache zu verändern.
Läuft **außerhalb** des per-Session-Hooks und **außerhalb** von `gates`
(netzfrei bleibt grün).

**Abgrenzung:** `make regelwerk-fetch` (existiert bereits, [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor))
*aktualisiert* den Cache und verifiziert dabei den Pin (Drift beim Refresh);
`make regelwerk-check` *überwacht* nur (read-only, keine Mutation) — für CI/cron.
Der ursprüngliche Pin-/Fetch-Teil dieses Slices ist damit bereits erledigt; übrig
bleibt der reine Monitoring-Check + die Scheduling-Verdrahtung.

## 2. Definition of Done

- [ ] `make regelwerk-check` holt die Upstream-URL in eine **temporäre** Datei
      (Cache **unberührt**), bildet `sha256`, vergleicht mit `REGELWERK_SHA256`:
      kein Drift → exit 0; Drift → nonzero + klare Meldung; Fetch-Fehler ≠ Drift
      (eigener Exit/Hinweis, nicht „verändert").
- [ ] Reuse des bestehenden Pins `REGELWERK_SHA256` + `REGELWERK_URL` (Makefile,
      [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)) — **kein** neuer Pin-Speicher. Der Cache ist **verbatim**, also
      `sha256(Cache) == REGELWERK_SHA256`; verglichen wird Upstream-jetzt gegen
      den Pin ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **Nicht** in `gates`, **kein** Sensor-Promotion (Netz-Abhängigkeit bräche
      das offline-grüne Gate-Prinzip, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — Maintenance/CI-Target.
- [ ] Bei Drift: **manuelles** Re-Review + `make regelwerk-fetch` (neu ziehen) +
      `REGELWERK_SHA256` neu pinnen; der Check **mutiert nichts**.
- [ ] (optional) Scheduled CI-Job ruft `make regelwerk-check` und alarmiert bei
      nonzero.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `regelwerk-check` (read-only `curl` → temp → `sha256` vs `REGELWERK_SHA256`), **nicht** in `gates` |
| `harness/conventions.md` ([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)) | update | Check (Überwachung) vs. Fetch (Update) abgrenzen |
| ggf. CI-Workflow | neu | scheduled Drift-Alarm |

## 4. Trigger

Sofort startbar; setzt den Cache + `REGELWERK_SHA256`/`make regelwerk-fetch` aus
[`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) voraus (existiert bereits).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz-Abhängigkeit:** bewusst **nicht** in `gates` (sonst bräche `make gates`
  offline/air-gapped, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Anti-Ziel). Nur Maintenance/CI.
- **Überschneidung mit `make regelwerk-fetch`:** Fetch mutiert + verifiziert beim
  Update, Check ist read-only fürs Monitoring — Doppellogik vermeiden (Check
  nutzt dieselben `REGELWERK_URL`/`REGELWERK_SHA256`).
- **Fetch-Mechanik:** Host-`curl` (wie `regelwerk-fetch`) vs. gepinntes Image
  ([`ADR-0003`](../../adr/0003-go-native-binaries.md)) — konsistent zu `regelwerk-fetch` halten.
- **Pin-Pflege:** `REGELWERK_SHA256` beim Refresh mitpflegen (sonst
  Dauer-Drift-Alarm) — in [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) verankert.
- **Upstream-Verfügbarkeit/Rate-Limit** (`raw.githubusercontent.com`): tolerant —
  Fetch-Fehler klar von „Drift" trennen.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`harness/` / `Makefile` GF (Doc führt); die Mechanik teilt den Adaptions-Block
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).
