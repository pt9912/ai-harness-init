# Slice slice-009: Regelwerk-Drift-Check

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) (ergänzt [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).

**Autor:** Demo. **Datum:** 2026-06-14.

---

## 1. Ziel

Ein **read-only** `make regelwerk-check` meldet **Upstream-Drift** des
Regelwerk-Cache für einen **scheduled/CI-Alarm** — es holt den aktuellen
Upstream-Stand und vergleicht dessen `sha256` mit dem gepinnten
`REGELWERK_SHA256` ([`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)), **ohne** den lokalen Cache zu verändern.
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
      [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis), ergänzt [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)) — **kein** neuer Pin-Speicher. Der Pin liegt auf
      dem **ZIP**; verglichen wird `sha256(Upstream-ZIP)` gegen `REGELWERK_SHA256`
      (das entpackte Cache-Verzeichnis ist ein **abgeleitetes Artefakt**, nicht der
      Vergleichsgegenstand — [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
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
| `harness/conventions.md` ([`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)) | update | Check (Überwachung) vs. Fetch (Update) abgrenzen |
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
- **Upstream-Verfügbarkeit/Rate-Limit** (GitHub Release-Asset,
  `github.com/…/releases/download/…`, seit [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)): tolerant —
  Fetch-Fehler klar von „Drift" trennen.
- **Invariante nach slice-010 ([`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)) — in diesem Slice erledigt:** Der Cache ist
  ein **Split-Modul-Verzeichnis**, der Pin liegt auf dem **ZIP**. Der Check
  vergleicht `sha256(Upstream-ZIP)` gegen `REGELWERK_SHA256` (entpacktes
  Verzeichnis = abgeleitetes Artefakt); die DoD oben ist entsprechend umgestellt.

## 7. Closure-Notiz (nach `done/`)

**Abschluss:** 2026-06-16. DoD vollständig (außer optionalem CI-Job); Gates grün.

**End-Stand:** `make regelwerk-check` ist ein **read-only** Drift-Monitor:
`curl REGELWERK_URL` (ZIP) → temp → `sha256` → Vergleich mit `REGELWERK_SHA256`,
**ohne** Cache-Mutation/Entpacken. `make`-Exit 0 = kein Drift, ≠0 = Alarm; ob
Drift oder Fetch-Fehler sagt die echo-Meldung. Reuse der bestehenden Pins
([`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)), **nicht** in `gates` ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) offline-grün).

**Invariante umgestellt (Kern):** Vergleichsgegenstand ist `sha256(Upstream-ZIP)`
gegen den Pin statt `sha256(Cache-Datei)`; der entpackte Split-Modul-Cache ist ein
abgeleitetes Artefakt.

**Nachweise (empirisch — Netz-Maintenance, kein bats wie bei `regelwerk-fetch`):**

- `make regelwerk-check` → „Kein Drift", Exit 0 (Pin == v1.2.0-Upstream).
- falscher Pin → „DRIFT" + gepinnt-vs-upstream (Cache unberührt; Recipe-Exit 1).
- unerreichbare URL → „FETCH-FEHLER" (≠ Drift; Recipe-Exit 2).
- `make gates` grün (docs-check 29/0, bats 37/37, shell-lint).

**Review (unabhängig, Modul 10):** `code-reviewer` auf den Diff → **APPROVE-WITH-NITS**
(POSIX-korrekt, read-only, Temp-Cleanup vollständig, Fetch≠Drift sauber getrennt,
kein zweiter Pin-Speicher). Behobene Nits: Quell-Host `raw.githubusercontent.com`
→ Release-Asset; Bezug/§1 auf [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) als maßgebliche Invarianten-Quelle ergänzt;
Makefile-Kommentar auf die robuste echo-Meldung umgestellt. **Review-Korrektur:**
Der Reviewer nahm „make druckt immer Error 2" an — empirisch zeigt `make` aber
„Fehler 1" (Drift) vs. „Fehler 2" (Fetch); die Zeile ist nur locale-/stderr-fragil,
daher trotzdem die echo-Meldung als kanonisches Signal.

**Steering-Loop-Lerneintrag:**

1. `regelwerk-fetch` *aktualisiert*, `regelwerk-check` *überwacht* — gemeinsamer
   Pin, keine Doppellogik; Fetch-Fehler nie als „verändert" dargestellt.
2. Grenze ehrlich benannt: `make` kollabiert Recipe-Fehler auf Exit 2; die
   Drift/Fetch-Unterscheidung trägt die Meldung, nicht der Exit-Code.

**Folge-Slices / offen:**

- **Scheduled CI-Job** (`make regelwerk-check` + Alarm bei nonzero): laut DoD
  optional, hier **nicht** angelegt — eigener Folgepunkt.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`harness/` / `Makefile` GF (Doc führt); die Mechanik teilt den Adaptions-Block
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).
