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

**Motivation entschieden (2026-07-19):** „Tools verteilen statt Skripte pflegen" — `regelwerk-check`
ist ein hand-gepflegtes Bash-Skript, `sources` das tool-gelieferte Äquivalent **derselben Achse**;
nach der Adoption ist `regelwerk-check` **redundant und wird entfernt** (nicht ergänzt). **Verbleibende
Vorbedingung: der Pin.** `sources` ist erst ab d-check **v0.51.0** verfügbar (gemessen; v0.50.0 hat es
nicht) → dieser Slice hängt an **slice-021** (Pin-Sprung v0.50.0→v0.51.1). Kein YAGNI mehr, sondern
pin-blockiert ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): eine Achse, ein Sensor — keine Doppelung).

## 2. Definition of Done

- [ ] **Vorbedingung erfüllt: d-check ⩾ v0.51.0 gepinnt.** `sources` ist **gemessen** erst ab
      **v0.51.0** (d-check-slice-080, 19. Modul; v0.50.0 kennt es **nicht** — `--print-config` /
      `ValidModules`). Diese Vorbedingung liefert **slice-021** (Pin-Sprung v0.50.0→v0.51.1); ohne sie
      bleibt dieser Slice blockiert.
- [ ] `.d-check.yml` `sources`-Block: Eintrag `{url: BASELINE_URL, sha256: …, unpack: …}` für das
      Baseline-ZIP (Marker-Weg entfällt — die URL steht im `Makefile`, nicht als Markdown-Link).
      **`unpack`-Gotcha (Handbuch v0.51.1):** `unpack: zip` hasht ein pfad-sortiertes **Content-Manifest**,
      **nicht** die Roh-Bytes — `BASELINE_ZIP_SHA256` (Roh-Bytes) passt dort **nicht**. Entscheidung +
      Messung: `unpack: none` (Roh-Bytes → matcht den bestehenden Pin) **oder** `unpack: zip` (Manifest →
      robuster, **neuer** Hash frisch zu messen). Hash **pro Modus gegen das echte Release gemessen**
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), `BASELINE_ZIP_SHA256` nicht blind übernommen.
- [ ] **Netz-Grenze geklärt** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): `source-drift` fetcht die Quelle → **Netz** →
      **nicht** in die netzlosen `make gates`; als Maintenance/CI-Target geführt (wie
      `regelwerk-check`/`baseline-freshness`). Offline-grün bleibt unberührt.
- [ ] **`regelwerk-check` ersetzt (nicht ergänzt):** das Bash-Target wird **entfernt** (`Makefile` +
      `.PHONY`/Doku-Nennungen), `sources` übernimmt dieselbe Asset-Content-Drift-Achse — ein Sensor pro
      Achse, keine Doppelung. `baseline-freshness` (Tag/Release-Liste) und `baseline-verify` (lokale
      Kopie, in `gates`) bleiben unverändert nötig (andere Achsen).
- [ ] `make gates` grün; MR-Eintrag; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` | update | `sources`-Modul + `source-pin` auf das Baseline-Asset |
| `Makefile` | update | Maintenance-Target (Netz) für die `sources`-Prüfung **neu**; `regelwerk-check` **entfernen** (redundant) |
| `harness/conventions.md` | update | MR-Eintrag (`sources`-Adoption); §Baseline ggf. |

**Nicht** hier: ein neuer *Gate*-Name in [`AGENTS.md`](../../../../AGENTS.md) §4 / [`harness/README.md`](../../../../harness/README.md) §Sensors — `source-drift` ist Netz, gehört nie in `gates` ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 4. Trigger

**slice-021 done** (d-check-Pin ⩾ v0.51.0, `sources` verfügbar). Die „lohnt-sich"-Frage ist
**entschieden** (Tools-statt-Skripte, `regelwerk-check` redundant) — der einzige verbleibende Blocker
ist der Pin. Bis slice-021 done ist, **blockiert in `open/`**.

- `in-progress → next`: falls die `unpack`-/Config-Migration mehr ist als gedacht → zurück zur Zerlegung.
- `in-progress → open`: falls slice-021 den Pin doch nicht liefert (Trockenlauf rot o. Ä.) → blockiert.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **`regelwerk-check` funktioniert — YAGNI ist das Haupt-Risiko.** Einen funktionierenden
  Eigenbau-Sensor durch eine Tool-Abhängigkeit zu ersetzen braucht Rechtfertigung; deshalb
  `open/`-Kandidat, kein committed `next/`.
- **Verfügbarkeit GEMESSEN (Klasse gefangen).** Modul 2 (v3.5.0, **derivativ**) nennt `sources`, aber
  der gepinnte d-check **v0.50.0** hat es **nicht** — es kam erst mit **v0.51.0** (gemessen an
  `ValidModules`/`--print-config`/CHANGELOG). Genau die „Regelwerk-Uhr ≠ Tool-Uhr"-Lücke
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)): eine Regelwerk-Erwähnung ist **kein** Beleg für den Pin. → Vorbedingung slice-021.
- **`unpack`-Hash-Semantik (Handbuch v0.51.1).** `unpack: zip` = Content-Manifest-Hash (reihenfolge-
  invariant), `unpack: none` = Roh-Byte-Hash. `BASELINE_ZIP_SHA256` ist ein Roh-Byte-Hash → nur mit
  `unpack: none` ein Drop-in; für `unpack: zip` ist der Hash **neu** zu messen. „Pin wiederverwenden"
  ohne Modus-Prüfung wäre wieder behauptet-statt-gemessen.
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
