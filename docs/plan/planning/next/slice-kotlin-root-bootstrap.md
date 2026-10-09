# Slice slice-kotlin-root-bootstrap: Kotlin als One-Shot am Root

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](../welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `ai-harness-init --lang kotlin [--arch hexslice]` bootstrappt ein Repo am Root in einem
Schritt, wie die cpp-Form.

**Ausdrücklich NICHT in diesem Slice:**

- Renderer und Arch-Gate — liefern `slice-kotlin-flaches-skelett` und
  `slice-kotlin-hexslice-mit-arch-gate`; dieser Slice verdrahtet nur den Root-Pfad.
- Handbuch-Nachzug — gehört in den Release-Schnitt.

## 2. Definition of Done

- [ ] `--lang kotlin` und `--lang kotlin --arch hexslice` am Root, mit Unit-Tests
      ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [ ] `make full-smoke`: Root-Bootstrap `--lang kotlin --arch hexslice`, im Ziel `make gates` grün
      einschließlich Arch-Gate; Stufe mit `e2e_abdeckung`-Kopfzeile; Laufzeit-Zuwachs gemessen, in §7.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/`, `internal/gen/` (+ Tests) | update | Root-Pfad für `kotlin` |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-hexslice-mit-arch-gate` liegt in `done/`.

**Rückführungen:**

- `in-progress` → `next`: der Root-Pfad verlangt sprach-spezifische Verzweigung außerhalb von
  `internal/gen/` — eigener Schnitt.
- `in-progress` → `open`: das Ziel fährt `make gates` am Root nicht grün, ohne dass der Renderer geändert
  wird — zurück an den Renderer-Slice.

## 5. Closure-Trigger

DoD vollständig, Root-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- JVM/Gradle verlängern `make full-smoke` je Stufe um einen `docker build` mit
  Dependency-Auflösung — **Ausgang:** *bei Closure*

## 7. Closure-Notiz

- **Was hat funktioniert:** *bei Closure*
- **Was ging anders als geplant:** *bei Closure*
- **Steering-Loop-Eintrag:** *bei Closure*
- **Beobachtungs-Register (`../observations/`):** *bei Closure*
- **Folge-Slices:** *bei Closure*
- **Risiken aus §6:** *bei Closure*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-09):
`neuer-waechter-ohne-mutations-fall` — 19, geplant; jeder neue Kotlin-Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 4, geplant; Kotlin pinnt per Tag ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2) ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen; trifft das Kotlin-Image gleich ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 2, offen; neue full-smoke-Stufen erben ihn.

**Modus:** alle berührten Sub-Areas GF.
