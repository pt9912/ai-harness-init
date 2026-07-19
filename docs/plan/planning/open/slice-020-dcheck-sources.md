# Slice slice-020: d-check `sources`-Modul für Baseline-Asset-Freshness adoptieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-19.

---

## 1. Ziel

Enhancement-Kandidat aus Modul 2 (v3.5.0): das d-check **`sources`-Modul** (`source-pin` auf den
sha256 einer http(s)-Quelle, `source-drift` bei Inhaltsabweichung) adoptieren, um die
**Asset-Integritäts-Prüfung** der committet vendored Baseline zu automatisieren — heute leistet das
der Eigenbau `make regelwerk-check` (curl + `sha256sum`). Es deckt die **Integritäts-Hälfte** ab und
**ersetzt nicht** `make baseline-freshness` (die Release-Listen-/Tag-Achse, [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

**Kandidat, nicht committed:** `regelwerk-check` funktioniert. Adoptiert wird nur, wenn (a) das
`sources`-Modul im gepinnten d-check verfügbar ist und (b) ein klarer Vorteil gegenüber dem
funktionierenden Eigenbau besteht (tool-gepflegt statt Bash) — sonst YAGNI ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 2. Definition of Done

- [ ] **Vorbedingung — `sources`-Verfügbarkeit gemessen** (nicht aus dem Regelwerk-Text
      angenommen): im gepinnten d-check (v0.50.0) via `d-check --print-config` / Modul-Liste belegt.
      Fehlt es dort, ist der Slice blockiert (ein Pin-Sprung wäre ein eigener Zug).
- [ ] `.d-check.yml` `sources` konfiguriert: `source-pin` auf das Baseline-Asset
      (`BASELINE_URL` @ `BASELINE_ZIP_SHA256`), gegen das echte Release gemessen ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **Netz-Grenze geklärt** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): `source-drift` fetcht die Quelle → **Netz** →
      **nicht** in die netzlosen `make gates`; als Maintenance/CI-Target geführt (wie
      `regelwerk-check`/`baseline-freshness`). Offline-grün bleibt unberührt.
- [ ] **Verhältnis zu `regelwerk-check` entschieden:** ersetzen (Eigenbau raus, weniger Bash) oder
      ergänzen. `sources` deckt nur die **Asset-Achse**; `baseline-freshness` (Tag/Release-Liste)
      bleibt unverändert nötig.
- [ ] `make gates` grün; MR-Eintrag; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` | update | `sources`-Modul + `source-pin` auf das Baseline-Asset |
| `Makefile` bzw. `d-check.mk` | update | Maintenance-Target (Netz) für die `sources`-Prüfung; ggf. `regelwerk-check` ersetzen |
| `harness/conventions.md` | update | MR-Eintrag (`sources`-Adoption); §Baseline ggf. |

**Nicht** hier: ein neuer *Gate*-Name in [`AGENTS.md`](../../../../AGENTS.md) §4 / [`harness/README.md`](../../../../harness/README.md) §Sensors — `source-drift` ist Netz, gehört nie in `gates` ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 4. Trigger

`sources`-Modul im gepinnten d-check **verfügbar** (gemessen) **und** eine bewusste
„lohnt-sich"-Entscheidung — der Eigenbau `regelwerk-check` funktioniert, Adoption nur bei klarem
Vorteil. Bis dahin **Kandidat in `open/`**.

- `in-progress → next`: falls die Adoption mehr Konfig/Migration erfordert als gedacht → zurück zur Zerlegung.
- `in-progress → open`: `sources` im Pin nicht verfügbar **oder** kein Vorteil ggü. `regelwerk-check` → verworfen/blockiert.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **`regelwerk-check` funktioniert — YAGNI ist das Haupt-Risiko.** Einen funktionierenden
  Eigenbau-Sensor durch eine Tool-Abhängigkeit zu ersetzen braucht Rechtfertigung; deshalb
  `open/`-Kandidat, kein committed `next/`.
- **Verfügbarkeit unbelegt (behauptet-statt-gemessen-Klasse).** Modul 2 (v3.5.0, **derivativ**) nennt
  `sources`; ob es im gepinnten d-check **v0.50.0** ist, ist zu **messen**, nicht aus dem
  Regelwerk-Text zu übernehmen.
- **Netz-Grenze:** `source-drift` braucht Netz → kann nicht in die netzlosen `gates`; bleibt
  Maintenance/CI. Der Gewinn ist **tool-gepflegt-statt-Bash**, keine neue Gate-Fähigkeit
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Nur die Asset-Achse.** `sources` ersetzt **nicht** `baseline-freshness` (Tag/Release-Liste, die
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Lücke, slice-018). Beide Achsen bleiben nötig.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.d-check.yml`/`d-check.mk`
(Gate-Config) und die Doku teilen die adoptierte Harness-Mechanik ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); GF (Doc führt).
