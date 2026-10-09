# Slice slice-kotlin-flaches-skelett: Kotlin als flaches Skelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](../welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) · [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** `ARC-009`, `ARC-010` (über [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang kotlin` rendert ein JVM-Gradle-Einzelmodul (Layout `flat`) mit Code-Gate-Fragment
in drei Fassungen und Guard-Set, das im gebootstrappten Ziel `make gates` grün fährt.

**Ausdrücklich NICHT in diesem Slice:**

- `hexslice` und Arch-Gate — übernimmt `slice-kotlin-hexslice-mit-arch-gate`.
- `--lang kotlin` am Root — übernimmt `slice-kotlin-root-bootstrap`.
- `freshness-kotlin` — übernimmt `slice-kotlin-freshness`.
- `hexagonal`, Gradle-Multi-Modul, KMP/Android — [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) legt sie nicht fest; Folge-ADR bzw. CR.
- `spec/architecture.md` — Folgepflicht aus [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) im hexslice-Slice.

## 2. Definition of Done

- [ ] Renderer `kotlin`/`flat` in `internal/gen/` nach [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 1–3:
      `settings.gradle.kts` ohne `include`, `build.gradle.kts`, `Dockerfile` mit Stages
      `test`/`lint`/`build`, Lint-Config, `src/main/kotlin/app/Main.kt`, `src/test/kotlin/…`; Image
      `gradle:<ver>-jdk<NN>` per Tag, `SKEL_KOTLIN_VERSION` → `gen.DefaultVersion("kotlin")`, kein Wrapper.
      Lint-Zweig per Sonde belegt (`detekt`, sonst `ktlint`); Sonden-Lauf in §7.
- [ ] Eigener Kotlin-Test Fragment↔Stages nach dem Muster `TestCppCodeGateFragment_TargetsMatchStages`,
      einmal rot gesehen (Stage entfernt); `blockedByLang("kotlin")` mit Kopplung an `gen.SupportedLangs`
      ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [ ] `make full-smoke`: `add-lang kotlin` ins Mono-Repo und gemischter Root go+cpp+kotlin, je mit
      `e2e_abdeckung`-Kopfzeile, `docs/user/e2e-abdeckung.md` neu erzeugt; Laufzeit-Zuwachs von
      `make full-smoke` vorher/nachher gemessen, in §7.
- [ ] Hilfetext nennt `kotlin` und `SKEL_KOTLIN_VERSION` (öffentlicher Vertrag).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go`, `internal/gen/kotlin.go` | update / neu | `profiles()`, `langArchs()`, `DefaultVersion`; Gerüst + Fragment |
| `internal/gen/kotlin_test.go` | neu | Fragment↔Stages, Gerüst-Inhalt |
| `internal/emit/enforce.go` (+ Test) | update | `blockedByLang("kotlin")` |
| `cmd/ai-harness-init/main.go` | update | Hilfetext |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | zwei Stufen, erzeugte Sicht |
| `cmd/ai-harness-init/main_test.go` | update | Hilfetext nennt jede Sprache und ihren `SKEL_<LANG>_VERSION` |
| `docs/user/benutzerhandbuch.md` | update | Zeile `SKEL_KOTLIN_VERSION` (öffentlicher Vertrag) |
| `internal/gen/gen_test.go`, `internal/emit/zeilenenden_test.go` | update | Sprach-Listen um `kotlin` |
| `test/mutations/` | neu / update | Fälle 618–622; 54 und 56 an die gofmt-Ausrichtung der Map-Zeilen ([MR-071](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `welle-kotlin-skelett` eröffnet, WIP-Slot frei.

**Rückführungen:**

- `in-progress` → `next`: Gerüst und Lint-Sonde füllen allein einen Lauf — full-smoke-Stufen in einen
  eigenen Slice.
- `in-progress` → `open`: weder `detekt` noch `ktlint` laufen grün mit der gepinnten Kotlin-Version
  (Re-Evaluierungs-Trigger 2 von [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)) — Architect.

## 5. Closure-Trigger

DoD vollständig, beide Kotlin-Stufen in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- JVM/Gradle verlängern `make full-smoke` je Stufe um einen `docker build` mit
  Dependency-Auflösung — **Ausgang:** *bei Closure*
- `detekt` hängt der Kotlin-Version nach; der Fallback `ktlint` ist nur Stil-Check —
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
