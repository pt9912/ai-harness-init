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

- [ ] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) erfüllt: Singletons → `.md`, wiederkehrende → `.template.md`.
- [ ] Set-Index-README des Template-Sets wird nicht emittiert.
- [ ] Projektname wird in die Singleton-Ziele gestempelt ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)-Detail).
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary-AC: Lauf gegen Repo mit bereits vorhandener Datei **ohne** `--force` → kein Überschreiben (Exit≠0 + Hinweis); **mit** `--force` → Überschreiben. Go-Test deckt beide Fälle.
- [ ] Go-Test: nach Lauf existieren die erwarteten `.md`/`.template.md`-Paare, keine Set-Index-README.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
