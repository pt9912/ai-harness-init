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

- [x] **Pin v0.50.0 → v0.51.1.** `d-check.mk` `DCHECK_IMAGE`/`DCHECK_DIGEST`
      (`sha256:fede3d027b2ebc1dd8534460853e57b67cc7a9a182cad2e2138c8eebf7a2d03c`, **dreifach belegt**:
      lokaler RepoDigest · `imagetools` · d-check-`version.md`/Release), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- [x] `d-check.mk` frisch aus `--print-mk` (v0.51.1) + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption (`docs-check`, `doc-help`,
      Kopfkommentar); einzige neue inhaltliche Differenz: `--disable sources` in fünf advisory-Recipes
      (verbatim vom Tool).
- [x] **Emitter-Pin nachgezogen** (Tier-1-Drift): `internal/emit` `DefaultImage`/`DefaultDigest` →
      v0.51.1 (`TestDefault…_MatchesCanonical` liest `d-check.mk`, färbt sonst `make test` rot).
- [x] `harness/conventions.md` §Baseline d-check → v0.51.1 + neuer MR-Eintrag; historische MR-Bodies
      eingefroren.
- [x] **Pflicht-Trockenlauf** ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster, netzlos): v0.51.1 gegen unveränderte Config →
      **0-Befund-Differenz** (inert; `sources` nicht aktiviert). Ausgabe im Closure-Beleg.
- [x] **`sources` NICHT aktiviert** — nur verfügbar gemacht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); die Aktivierung mit
      realem `source-pin` ist slice-020.
- [x] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

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

**Geliefert (2026-07-19).** d-check-Pin **v0.50.0 → v0.51.1** (Digest `sha256:fede3d02…`, dreifach
belegt), `d-check.mk` frisch aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption, `internal/emit`-Pin nachgezogen,
`conventions.md` §Baseline + neuer [`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar). **`sources` verfügbar gemacht, nicht aktiviert**
(Phantom-Gate-Vermeidung, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Trockenlauf netzlos: v0.51.1 == v0.50.0 == 0 Befunde (**inert gemessen**).

**Rollenkette (Modul 8, je frischer Kontext).** Reviewer (Modul 10): nicht merge-blockierend, **0
Findings** (`docs/reviews/2026-07-19-slice-021-review.md`). Verifier (Modul 11): **7/7 DoD CONFIRMED,
0 VIOLATED** (`docs/reviews/2026-07-19-slice-021-verify.md`), inkl. eigenem `make gates` (Exit 0) +
imagetools-Digest. Beide bestätigten Digest, faithful Regeneration und Inert-Eigenschaft unabhängig.

**Steering-Loop-Lerneintrag (geschärfte Regel — bestätigtes Muster).** „Regelwerk-Uhr ≠ Tool-Uhr" ist
jetzt belegt: die v3.5.0-Baseline (Modul 2) nennt `sources`, aber der gepinnte d-check v0.50.0 hatte es
**nicht** (erst v0.51.0). Eine **DoD-Vorbedingung „Modul-Verfügbarkeit im gepinnten Tool messen"** fing
die Lücke, bevor eine Config auf ein nicht existentes Modul zeigte. **Regel für jede
Regelwerk-erwähnte Tool-Fähigkeit:** gegen die **gepinnte** Version messen, nicht aus dem (derivativen)
Regelwerk-Text annehmen — grundiert in [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) (eigene Release-Uhr), nicht in einer Regelwerk-Zeile.

**Prozedur bewährt (3. Pin-Bump der Session).** Der 3-Kopplungspunkte-Ablauf (`d-check.mk` ·
`conventions.md` §Baseline · `internal/emit`, Tier-1-Drift-gekoppelt) + Trockenlauf + dreifacher Digest
hielt zum dritten Mal (v0.10→v0.46 slice-016, v0.46→v0.50 slice-015, v0.50→v0.51.1 hier). Auch ein
„offensichtlich inerter" Bump durchlief die volle Rollenkette — der Prozess prüft, nicht die Intuition.

**Entsperrt slice-020** (`sources`-Adoption; ersetzt den Eigenbau `regelwerk-check`).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `d-check.mk`/Gate-Config,
`internal/emit` (Pin-Kopplung) und die Doku teilen die adoptierte Harness-Mechanik ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); GF (Doc führt).
