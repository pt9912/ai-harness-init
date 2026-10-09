# Slice slice-kotlin-freshness: freshness-kotlin meldet einen neueren Gradle-Image-Tag

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-kotlin-skelett`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make freshness-kotlin` meldet, ob für den gepinnten `gradle:<ver>-jdk<NN>`-Tag ein neuerer
existiert — kein Gate, wie `freshness-cpp`.

**Ausdrücklich NICHT in diesem Slice:**

- Den Pin heben — anderer Vorgang; das Werkzeug meldet nur.
- Kotlin-Plugin- und Lint-Version im Gerüst — sie stehen per Version im Gerüst, nicht im Image-Tag;
  ein Sensor dafür wäre ein eigener Schnitt.

## 2. Definition of Done

- [ ] `kotlin-freshness.sh` unter `harness/tools/` + `make freshness-kotlin`; Zeile in `harness/README.md`
      §Werkzeuge mit `kein Gate`.
- [ ] bats-Fall: veralteter Pin → Meldung, aktueller → still; das Rot einmal gesehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `kotlin-freshness.sh` unter `harness/tools/`, `Makefile` | neu / update | Werkzeug und Ziel |
| `harness/README.md` | update | Werkzeug-Zeile |
| `test/kotlin-freshness.bats` | neu | beide Richtungen |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-flaches-skelett` liegt in `done/` (der Pin existiert).

**Rückführungen:**

- `in-progress` → `next`: die Tag-Liste des Image-Registers trennt Gradle- und JDK-Achse nicht — Schnitt
  je Achse.
- `in-progress` → `open`: das Register ist netzlos nicht erreichbar und braucht einen anderen Träger.

## 5. Closure-Trigger

DoD vollständig, bats-Fall grün und einmal rot gesehen, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Das Werkzeug braucht Netz; ein Ausfall des Registers darf keinen Gate-Lauf blockieren — **Ausgang:** *bei Closure*

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
