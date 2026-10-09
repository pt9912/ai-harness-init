# Slice slice-kotlin-hexslice-mit-arch-gate: Kotlin-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](../welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang kotlin --arch hexslice` rendert die Rollen-Pakete aus [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 4 samt
`.a-check.yml`, und ein Import aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot.

**Ausdrücklich NICHT in diesem Slice:**

- `--lang kotlin` am Root — übernimmt `slice-kotlin-root-bootstrap`; zusammen mit ihm hätte dieser
  Slice vier Liefer-Punkte.
- `hexagonal` und dessen Zähne — [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) legt das Layout nicht fest (Trigger 3, Folge-ADR).
- Eine Anforderung an a-check — nur, wenn eine Config, die Importe auflöst, grün bleibt
  (Re-Evaluierungs-Trigger 1); dann Rückführung.

## 2. Definition of Done

- [ ] hexslice-Renderer mit den Pfaden aus [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 4, Paket == Verzeichnis;
      `archGateConfigs()` mit `resolution: kotlin: {mode: fixed-root, roots: ["src/main/kotlin/app"], package_base: "app"}`;
      im gebootstrappten Ziel meldet a-check keinen Hinweis „0 von N Import-Symbolen lösen auf".
- [ ] `make full-smoke`: `add-lang kotlin <pfad> --arch hexslice` grün; mit Import aus
      `app.hexagon.domain` nach `app.adapters` rot mit `core-impurity` (Meldung gelesen); Stufe mit
      `e2e_abdeckung`-Kopfzeile; Laufzeit-Zuwachs gemessen, in §7
      ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).
- [ ] `spec/architecture.md` Layout je Sprache um Kotlin nachgezogen (Folgepflicht [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/kotlin.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()` |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe + Arch-Zahn, erzeugte Sicht |
| `spec/architecture.md` | update | Layout je Sprache |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-flaches-skelett` liegt in `done/`.

**Rückführungen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt.
- `in-progress` → `open`: eine auflösende Config bleibt grün ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Trigger 1) — Anforderung an
  a-check über den Auftraggeber.

## 5. Closure-Trigger

DoD vollständig, Arch-Zahn rot und Gegenprobe grün in `make full-smoke`, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- JVM/Gradle verlängern `make full-smoke` je Stufe um einen `docker build` mit
  Dependency-Auflösung — **Ausgang:** *bei Closure*
- Ein Paket außerhalb seines Verzeichnisses entgeht der Auflösung ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) §Konsequenzen) —
  **Ausgang:** *bei Closure*

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
