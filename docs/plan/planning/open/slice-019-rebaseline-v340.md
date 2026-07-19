# Slice slice-019: Re-Baseline v3.1.0 → v3.4.0 (Kurs-Welle 31)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-19.

---

## 1. Ziel

Die committet vendored Baseline vom gepinnten Kurs-Tag **v3.1.0 auf v3.4.0** heben —
eine bewusste [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Operation. Es ist ein **Content-Bump, kein reiner Pin-Bump**: der
Baum wächst von 42 auf **54 Dateien** (regelwerk 21→22, templates 21→32; Regelwerks-Stand
**Kurs-Welle 26 · 2026-07-17 → Kurs-Welle 31 · 2026-07-19**). Der Baum bleibt netzlos auf
jedem Checkout präsent; `make baseline-verify` und `make gates` bleiben grün
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)/[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

Ausgelöst durch `make baseline-freshness` (slice-018), das den neueren Upstream-Tag real
alarmiert hat.

## 2. Definition of Done

- [ ] **Vendored Baum ersetzt.** `.harness/baseline/v3.4.0/{regelwerk,templates}/` aus dem
      v3.4.0-`lab-regelwerk.zip` entpackt (54 Dateien), `SHA256SUMS` neu erzeugt
      ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2: `sha256sum` über **alle** Dateien, Pfade relativ zu `<tag>/`,
      `LC_ALL=C`-sortiert, Datei selbst ausgenommen). Das alte `.harness/baseline/v3.1.0/`
      **entfernt** (Setzung 4: ein Tag zur Zeit). Der ZIP-sha256 ist **vor** dem Entpacken
      gegen den Pin verifiziert.
- [ ] **Provenienz + Integrität gepinnt** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1). `Makefile`
      `BASELINE_TAG` → `v3.4.0`, `BASELINE_ZIP_SHA256` → `58fb40678ce0a507d893ac5c3f45e7c6449e1f3a6fa63badb532c19ed102378c`
      (sha256 des Release-Assets, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **Kopplungspunkt Fetch.** `internal/fetch/fetch.go` `DefaultTag` → `v3.4.0` — per
      `TestDefaultTag_MatchesBaseline` an `BASELINE_TAG` gekoppelt (färbt sonst `make test` rot,
      [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)/[`ADR-0001`](../../adr/0001-skelett-distribution.md)).
- [ ] **Kopplungspunkt Doku.** `harness/conventions.md` §Baseline: vendored Tag + kanonische
      Kurs-URL + „Regelwerks-Stand" (Welle 31 · 2026-07-19). Historische Einträge (MR-Bodies)
      bleiben eingefroren.
- [ ] **Kopplungspunkt Emit-Embed (Content-Bump-Risiko).** Falls `internal/emit`s eingebettete
      Template-Teilmenge (`internal/emit/skel/`) durch die geänderten v3.4.0-Templates driftet
      (Gleichheit-/Vollständigkeit-Wächter aus slice-003), das Embed re-syncen — drift-test-gesteuert,
      kein Blind-Sync.
- [ ] `make gates` grün (inkl. `baseline-verify`: Integrität **und** Vollständigkeit netzlos).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.1.0/` → `…/v3.4.0/{regelwerk,templates}/` + `SHA256SUMS` | replace | Baum neu vendoren; alter Tag raus (Setzung 4) |
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | Tag + Provenienz-Pin |
| `internal/fetch/fetch.go` (`DefaultTag`) | update | Fetch-Pin gekoppelt (Tier-1-Drift-Test) |
| `harness/conventions.md` §Baseline | update | Tag + Kurs-URL + Regelwerks-Stand (Welle 31) |
| `internal/emit/skel/` | ggf. update | Embed re-sync, **nur** wenn Drift-Wächter rot (slice-003) |

**Nicht** blind: `AGENTS.md`/`CLAUDE.md` nutzen `<tag>` generisch (Glob/Variable) — kein Grep-Bump
nötig ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4). Historische MR-Bodies bleiben Zeitbezug.

## 4. Trigger

**Erfüllt:** v3.4.0 ist upstream publiziert (Asset `lab-regelwerk.zip` HTTP 200, kein
Draft/Prerelease; `make baseline-freshness` alarmierte den neueren Tag). Vorher (Asset 404)
**blockiert** — ein Fetch gegen ein nicht existentes Release scheitert.

- `in-progress → next`: falls zu groß (z. B. Emit-Embed-Rattenschwanz sprengt den Schnitt) →
  zurück zur Zerlegung.
- `in-progress → open`: falls das Release zurückgezogen/defekt ist → blockiert.

## 5. Closure-Trigger

DoD vollständig + Review konform (Integrität/Provenienz bestätigt) + Verifikation + Closure-Notiz
→ nach `done/`.

## 6. Risiken und offene Punkte

- **Content-Bump, nicht Pin-Bump — Emit-Embed ist die Kern-Unsicherheit.** Die Templates wachsen
  21→32; `internal/emit` bettet eine Teilmenge ein (`internal/emit/skel/`, slice-003) mit einem
  Gleichheit-**und**-Vollständigkeit-Drift-Wächter. Ändert v3.4.0 eine eingebettete Datei, färbt
  der Wächter rot — dann ist das Embed drift-test-gesteuert nachzuziehen (analog dem Emit-Pin in
  slice-015). Blind-Sync ohne roten Test wäre falsch.
- **Provenienz ≠ Integrität** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1). `SHA256SUMS` (selbst erzeugt) beweist nur,
  dass der Baum sich seit dem Vendoring nicht bewegt; die **Herkunft** hängt allein an
  `BASELINE_ZIP_SHA256` (gegen das Release-Asset). Beide sind zu führen.
- **Re-Review des Fremd-Blobs.** Der vendored Baum ist ein ~250-KB-Fremd-Blob; die Rolle
  Reviewer/Verifier bestätigt Integrität (SHA256SUMS `-c` grün + Vollständigkeit) und Provenienz
  (ZIP-sha256 == Pin), nicht Zeile-für-Zeile-Inhalt.
- **Kurs-Anker-Drift.** Regelwerk und Kurs sind zwei divergente Bäume; interne Verweise des
  vendored Baums lösen lokal auf (Geschwister-Templates). Bei Welle-31-Umbau könnten Ziel-Form-Pfade
  gewandert sein — `baseline-verify` prüft Integrität/Vollständigkeit, **nicht** die internen Links
  des Fremd-Baums (der ist `scan.ignore`).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.harness/baseline/`
(vendored Baum), `Makefile`/Gate-Config, `internal/fetch`+`internal/emit` (Pin-/Embed-Kopplung)
und die Doku teilen die adoptierte Harness-Mechanik ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)); GF (Doc führt).
