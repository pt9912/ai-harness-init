# Slice slice-021: d-check-Pin v0.50.0 → v0.51.1 (macht `sources` verfügbar)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-19.

---

## 1. Ziel

Das gepinnte d-check-Image von **v0.50.0 auf v0.51.1** heben — Fortsetzung der
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)-Linie. **Zweck: das opt-in-Modul `sources` verfügbar
machen** (19. Modul, erst ab v0.51.0) — die Vorbedingung für slice-020. Gemessen (`--print-mk` v0.51.1
gegen das aktuelle `d-check.mk`): die einzige inhaltliche Fragment-Differenz ist `--disable sources` in
den fünf fokussierten advisory-Recipes (wie damals `--disable citations` bei v0.46→v0.50). `sources`
ist opt-in/Netz/nie Default → der Bump ist **inert** (Handbuch v0.51.1: „ohne aktives `sources`
byte-identisch"). Dieser Slice **aktiviert `sources` NICHT** — das ist slice-020
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): ein leer aktiviertes Modul wäre ein Phantom-Gate).

## 2. Definition of Done

- [ ] **Pin v0.50.0 → v0.51.1.** `d-check.mk` `DCHECK_IMAGE`/`DCHECK_DIGEST`
      (`sha256:fede3d027b2ebc1dd8534460853e57b67cc7a9a182cad2e2138c8eebf7a2d03c`, **dreifach belegt**:
      lokaler RepoDigest · `imagetools` · d-check-`version.md`/Release), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- [ ] `d-check.mk` frisch aus `--print-mk` (v0.51.1) + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption (`docs-check`, `doc-help`,
      Kopfkommentar); einzige neue inhaltliche Differenz: `--disable sources` in fünf advisory-Recipes
      (verbatim vom Tool).
- [ ] **Emitter-Pin nachgezogen** (Tier-1-Drift): `internal/emit` `DefaultImage`/`DefaultDigest` →
      v0.51.1 (`TestDefault…_MatchesCanonical` liest `d-check.mk`, färbt sonst `make test` rot).
- [ ] `harness/conventions.md` §Baseline d-check → v0.51.1 + neuer MR-Eintrag; historische MR-Bodies
      eingefroren.
- [ ] **Pflicht-Trockenlauf** ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster, netzlos): v0.51.1 gegen unveränderte Config →
      **0-Befund-Differenz** (inert; `sources` nicht aktiviert). Ausgabe im Closure-Beleg.
- [ ] **`sources` NICHT aktiviert** — nur verfügbar gemacht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); die Aktivierung mit
      realem `source-pin` ist slice-020.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk` | update (neu erzeugt) | v0.51.1-Fragment aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption; `DCHECK_DIGEST` neu gepinnt |
| `internal/emit/emit.go` | update | `DefaultImage`/`DefaultDigest` → v0.51.1 (Tier-1-Drift-Kopplung an `d-check.mk`) |
| `harness/conventions.md` | update | §Baseline v0.51.1 + neuer MR-Eintrag |

**Nicht** hier: `.d-check.yml` (`sources` bleibt un-aktiviert — slice-020); kein neuer Gate-Name in [`AGENTS.md`](../../../../AGENTS.md)/[`harness/README.md`](../../../../harness/README.md).

## 4. Trigger

**Erfüllt:** d-check **v0.51.1** ist verfügbar (gemessen — Image gepullt, `--print-config`/`--print-mk`
inspiziert, `sources` in `ValidModules`). Dieser Slice ist die **Vorbedingung für slice-020** (das
darauf blockiert).

- `in-progress → open`: Trockenlauf rot / Schema-Bruch → blockiert (wie [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) den Fall vorsieht).
- `in-progress → next`: unerwarteter Rattenschwanz (z. B. ein weiteres neues Pflicht-Modul) → zurück zur Zerlegung.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation + Closure-Notiz → nach `done/`. **Entsperrt slice-020.**

## 6. Risiken und offene Punkte

- **Zweiter Pin-Bump binnen einer Session** (v0.46→v0.50 in slice-015, jetzt v0.50→v0.51.1). d-check
  bewegt sich schnell; dieser Bump ist **nur durch slice-020 (`sources`) motiviert**, nicht durch
  Eigenbedarf an v0.51 — bewusst, kein Versionschasing.
- **Drei Kopplungspunkte** (slice-015-/[`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)-Lehre): `d-check.mk`, `conventions.md` §Baseline,
  `internal/emit` (Tier-1-Drift-Test) — alle nachziehen, sonst `make test` rot.
- **„Inert" ist zu MESSEN, nicht anzunehmen.** Auch wenn Handbuch v0.51.1 „byte-identisch ohne aktives
  `sources`" sagt: Handbuch/Regelwerk ≠ mein Baum → der Trockenlauf belegt es (0-Befund-Diff).
- **`sources` hier NICHT aktivieren.** Ein leer aktiviertes Netz-Modul wäre ein Phantom-Gate
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); Aktivierung mit realem `source-pin` (+ `unpack`-Entscheidung) ist slice-020.

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

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `d-check.mk`/Gate-Config,
`internal/emit` (Pin-Kopplung) und die Doku teilen die adoptierte Harness-Mechanik ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); GF (Doc führt).
