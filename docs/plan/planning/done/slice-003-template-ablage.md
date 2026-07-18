# Slice slice-003: Zweiklassige Template-Ablage

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Projektname-Stempelung, `--force`-Boundary).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`cmd/ai-harness-init` legt die Templates zweiklassig ab: Singletons (z. B.
lastenheft, architecture, AGENTS, harness/README, conventions) werden zu
`.md`-Zielen; wiederkehrende Templates (ADR, slice, welle, carveout,
review-report) bleiben co-located als `.template.md`. Die Set-Index-README
wird nie mitkopiert.

## 2. Definition of Done

- [x] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) erfüllt: Singletons → `.md`, wiederkehrende → `.template.md`.
- [x] Set-Index-README des Template-Sets wird nicht emittiert.
- [x] Projektname wird in die Singleton-Ziele gestempelt ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)-Detail).
- [x] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary-AC: Lauf gegen Repo mit bereits vorhandener Datei **ohne** `--force` → kein Überschreiben (Exit≠0 + Hinweis); **mit** `--force` → Überschreiben. Go-Test deckt beide Fälle.
- [x] Go-Test: nach Lauf existieren die erwarteten `.md`/`.template.md`-Paare, keine Set-Index-README.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Scope (Nutzer-Entscheid): **[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Kern**; fremd-besessene Dateien im Baum
ausgeschlossen — Root-README ([`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)/slice-005), Enforcement-Skills+CLAUDE
([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)), Doc-Gate-Config (slice-002), Makefile
(Gate/Enforcement-Baseline). Design: das Tool bettet den in-scope-Baum unter
`internal/emit/skel/` ein (der Adopter hat den vendored Baum nicht); Singletons werden
zu gefüllten `.md`-Zielen (Template-Hinweis-Block gestrippt, `<Projektname>` gestempelt),
Wiederkehrende bleiben verbatim `.template.md`; die Roadmap landet unter in-progress/
(sonst bräche der Link der emittierten planning-README). Die Set-Index-README des Sets
ist gar nicht eingebettet → wird nie emittiert.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | neu | `Templates` (Pre-Flight → klassifizieren → stempeln/strippen → schreiben) + `StripHintBlock` |
| `internal/emit/skel/` | neu | eingebetteter in-scope Template-Baum (15 `.template.md`, aus der vendored Baseline) |
| `cmd/ai-harness-init` | update | `emit.Templates` in den `--lang`-Erfolgspfad; `--name` erfasst |
| `internal/emit/templates_test.go` | neu | Tier 1 (ohne `.harness`): Layout, Stempeln+Strippen, Verbatim, Force-Boundary |
| `test/skel-drift.bats` | neu | Drift-Wächter `skel/` == vendored Baseline (bats sieht den ganzen Repo-Mount) |

## 4. Trigger

slice-001 done; idealerweise nach slice-002 (gemeinsamer Emit-Pfad).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- Klassifikations-Quelle **fixiert** (`isRecurring`): genau die fünf
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Wiederkehrenden (`NNNN-titel`/`slice`/`welle`/`carveout`/`review-report`)
  → `.template.md`; alles übrige Eingebettete → Singleton. Nicht aus dem Set „abgeleitet"
  (fehleranfällig), sondern eine benannte Liste.
- Drift-Wächter liegt in **bats**, nicht Go: der go-test-Build-Kontext schließt `.harness`
  aus (`.dockerignore`), der bats-Lauf mountet aber den ganzen Repo — nur dort sind `skel/`
  **und** die vendored Baseline gleichzeitig sichtbar. Die Go-Tests bleiben deshalb
  self-contained (kein `.harness`-Zugriff).
- `--force`-Semantik (Überschreiben) berührt diesen Slice ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary):
  `Templates` prüft alle Ziele vor jedem Write (Pre-Flight) → bei Konflikt ohne `--force`
  wird nichts geschrieben. **Rest-Kante:** über beide Emit-Schritte (Doc-Gate + Ablage)
  hinweg gibt es keinen gemeinsamen Pre-Flight — ein Konflikt im zweiten Schritt lässt die
  Dateien des ersten stehen (kein Überschreiben, aber Teil-Emit; wie slice-002 I1).

## 7. Closure-Notiz (nach `done/`)

**Geliefert:** `internal/emit.Templates` legt die Template-Baseline zweiklassig ab —
Singletons → gefüllte `.md` (`StripHintBlock` + `<Projektname>`-Stempel), Wiederkehrende
→ verbatim co-located `.template.md`. Set-Index-README nie (nicht eingebettet). Embed unter
`internal/emit/skel/` (15 in-scope-Templates). Commits: Eintritts-Move `bdb4655` · Inhalt
`dfa31b1` · Review-Fix `733c97e` · Exit-Move.

**Was funktionierte:** Zweiklassige Ablage + roadmap-Sonderfall (`in-progress/`) end-to-end
verifiziert (echter Bootstrap: 10 Singletons gestempelt, 5 Wiederkehrende verbatim, keine
Set-Index). Der bats-Drift-Wächter hält `skel/` == in-scope-Teilmenge der vendored Baseline
über zwei Achsen (Gleichheit + Vollständigkeit).

**Was anders lief:** Der Drift-Wächter musste nach **bats** statt go-test, weil der
go-test-Build-Kontext `.harness` ausschließt (`.dockerignore`) — nur der bats-Mount sieht
`skel/` und die vendored Baseline gleichzeitig.

**Steering-Loop-Einträge:**

1. **Geschärfte Test-Platzierungs-Regel:** Ein Test, der ein **dockerignoriertes** Artefakt
   (`.harness/…`) braucht, kann NICHT in der go-test-Stage laufen (Build-Kontext schließt es aus)
   — er gehört in den **bats-Mount** (`-v CURDIR:/code`, sieht den ganzen Repo). Gilt für jeden
   künftigen Embed-gegen-vendored-Wächter.
2. **Neue Sensor-Achse (Subset-Embed-Drift):** Ein Drift-Wächter über eine **Teilmenge** braucht
   ZWEI Achsen — *Gleichheit* (jedes Embed == Quelle) UND *Vollständigkeit* (jede in-scope-Quelle
   hat ein Embed-Twin) — sonst bleibt ein upstream neu hinzugekommenes Element still unentdeckt
   (Review-L2). Wiederverwendbar für jeden Teilmengen-Embed.

**Folge-Slices:** keine neuen. Forward: die emittierten Singletons tragen noch `<!-- -->`-
Kommentare + Nicht-`<Projektname>`-Platzhalter (Human-Content); ob das emittierte Repo sein
eigenes Doc-Gate grün lässt, ist der Voll-Smoke von [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)/slice-005 (Happy-Path
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).

**Verifikation (Beleg):** Verifier (Modul 11, frischer Kontext): 6/6 DoD CONFIRMED, 0 VIOLATED,
[`ADR-0003`](../../adr/0003-go-native-binaries.md) konform — echter Emit (10 `.md` + 5 `.template.md`, keine Set-Index, roadmap in
`in-progress/`), Force-Boundary real, `make gates` Exit 0. Reviewer (Modul 10): nicht
merge-blockierend (0 HIGH/MEDIUM); L1/L2 in `733c97e` behandelt, INFO I1–I3 als scope-konforme
Grenzen akzeptiert.

**welle-01:** mit slice-003 in `done/` sind alle M1-Slices (001a/001b/002/003) abgeschlossen →
Wellen-Closure-Schritt 1 (Trigger) ist erfüllt; die Closure-Prozedur (Modul 6, fünf Schritte) steht an.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
