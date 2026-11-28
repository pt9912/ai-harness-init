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
nach der Adoption wird `regelwerk-check`s **Bash-Körper durch `docker run … --enable sources`
ersetzt** — der **Target-Name bleibt** (kein Rename: frozen MR-Historie + ~15 Referenzen churnen
sonst; „Skript raus, Tool rein", Interface stabil). **Verbleibende Vorbedingung: der Pin.** `sources` ist erst ab d-check **v0.51.0** verfügbar (gemessen; v0.50.0 hat es
nicht) → dieser Slice hängt an **slice-021** (Pin-Sprung v0.50.0→v0.51.1). Kein YAGNI mehr, sondern
pin-blockiert ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): eine Achse, ein Sensor — keine Doppelung).

## 2. Definition of Done

- [x] **Vorbedingung erfüllt: d-check ⩾ v0.51.0 gepinnt.** `sources` ist **gemessen** erst ab
      **v0.51.0** (d-check-slice-080, 19. Modul; v0.50.0 kennt es **nicht** — `--print-config` /
      `ValidModules`). Diese Vorbedingung liefert **slice-021** (Pin-Sprung v0.50.0→v0.51.1); ohne sie
      bleibt dieser Slice blockiert.
- [x] `.d-check.yml` `sources`-Block: `{url: <Release-ZIP @ BASELINE_TAG>, sha256: BASELINE_ZIP_SHA256,
      unpack: none}`; **`unpack: none` entschieden + gemessen** (Roh-Byte-Hash → matcht den bestehenden
      `BASELINE_ZIP_SHA256`, **0 Drift**; Gegenprobe `unpack: zip` mit demselben Hash → `source-drift`,
      da Content-Manifest, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). **NICHT** in `modules:` (sources ist Netz — bräche den
      netzlosen `docs-check`; nur via `make regelwerk-check` aktiviert).
- [x] **Netz-Grenze geklärt** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): `source-drift` fetcht die Quelle → **Netz** →
      **nicht** in die netzlosen `make gates`; als Maintenance/CI-Target geführt (wie
      `regelwerk-check`/`baseline-freshness`). Offline-grün bleibt unberührt.
- [x] **`regelwerk-check`-Körper ersetzt (Bash raus, Name/Interface bleiben):** `docker run …
      --enable sources` (auf `sources` isoliert) statt `curl`+`sha256sum` — dieselbe
      Asset-Content-Drift-Achse, tool-geliefert. **Zwei-Pin-Kopplung:** `test/sources-pin.bats` koppelt
      den `.d-check.yml`-`sources`-Pin **fail-closed in `gates`** (netzlos) an `Makefile`
      `BASELINE_ZIP_SHA256`/`BASELINE_TAG` — Re-Baseline muss beide bewegen. `baseline-freshness`
      (Tag-Achse) und `baseline-verify` (lokale Kopie) bleiben unverändert (andere Achsen).
- [x] `make gates` grün (netzlos, inkl. Kopplungstest); `make regelwerk-check` (Netz) grün gegen das
      echte Asset; [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript); Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` | update | `sources:`-Block (unpack: none), **nicht** in `modules:` (netzlos gates bleibt) |
| `Makefile` | update | `regelwerk-check`-Körper: Bash → `docker run … --enable sources` (Name bleibt) |
| `test/sources-pin.bats` | neu | koppelt `.d-check.yml`-`sources`-Pin an `Makefile` `BASELINE_ZIP_SHA256` (fail-closed, in gates) |
| `harness/conventions.md` | update | neuer [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) |

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

**Geliefert (2026-07-19).** `make regelwerk-check` (Baseline-Asset-Content-Drift) vom Eigenbau-Bash
(`curl`+`sha256sum`) auf das d-check-Modul `sources` umgestellt — „Tools verteilen statt Skripte pflegen".
`.d-check.yml`-`sources:`-Block (`unpack: none` = Roh-Byte-Hash = `BASELINE_ZIP_SHA256`, gemessen 0
Drift; `unpack: zip` mit demselben Hash → `source-drift`), **nicht** in `modules:` (netzlose `gates`
bleiben). `test/sources-pin.bats` koppelt den `.d-check.yml`-Pin fail-closed in `gates` an den
kanonischen Makefile-Pin. Neuer [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript). Target-Name `regelwerk-check` behalten (kein Rename).

**Rollenkette (Modul 8, je frischer Kontext).** Reviewer (Modul 10): nicht merge-blockierend, **0
Findings**; **Kopplungstest-Zähne per Fehlinjektion belegt** (`docs/reviews/2026-07-19-slice-020-review.md`).
Verifier (Modul 11): **alle DoD CONFIRMED, 0 VIOLATED** (`docs/reviews/2026-07-19-slice-020-verify.md`),
inkl. eigenem `make gates` (Exit 0) + eigener Zahn-Prüfung (Test 54 rot bei verfälschtem Pin).

**Steering-Loop-Lerneintrag (geschärfte Regel — Tool-Adoption mit Pin-Duplikation braucht einen
Kopplungs-Sensor).** Ein Tool (d-check `sources`) übernimmt einen Eigenbau-Sensor, aber der gepinnte
Wert (Baseline-Asset-`sha256`) muss in **zwei** Formaten leben: kanonisch im `Makefile`
(`BASELINE_ZIP_SHA256`, [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache); die Re-Baseline nutzt ihn) **und** dupliziert in der Tool-Config
(`.d-check.yml`, d-check liest nur seine Config). Eine Duplikation ohne Kopplung driftet still —
deshalb `test/sources-pin.bats` **fail-closed in `gates`** (netzlos). **Regel:** Wer einen gepinnten
Wert in eine zweite (Tool-)Config dupliziert, koppelt beide mit einem Gate-Test — sonst ist „Single
Source of Truth" nur behauptet (dieselbe Tier-1-Drift-Klasse wie `DefaultTag==BASELINE_TAG`, hier
config↔config statt code↔config).

**Zwei Design-Entscheidungen gemessen, nicht geraten:** (a) `unpack: none` (beide Modi gegen das echte
Asset getestet — none=0 Drift, zip=Drift); (b) Target-Name behalten statt Rename (Rename-Scope
gemessen: ~15 Refs inkl. frozen MR-Historie → unverhältnismäßig für kosmetischen Gewinn).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.d-check.yml`/`d-check.mk`
(Gate-Config) und die Doku teilen die adoptierte Harness-Mechanik ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); GF (Doc führt).
