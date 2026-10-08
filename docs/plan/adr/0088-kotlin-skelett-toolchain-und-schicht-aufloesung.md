# ADR-0088: Kotlin-Skelett — Toolchain und Schicht-Auflösung

**Status:** Proposed

**Datum:** 2026-10-08

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0005](0005-ziel-repo-distribution.md), [ADR-0008](0008-arch-achse-emittiertes-skelett.md),
[ADR-0009](0009-hexslice-arch-realisierung.md),
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md); Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung` (E1–E4 vom Auftraggeber am 2026-10-08 angenommen)

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Generator und Verdrahtung für die Sprache `kotlin`).

**Verfeinert (nicht supersedet):** [ADR-0005](0005-ziel-repo-distribution.md),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md)
— deren Mechanik gilt unverändert; hier steht nur, was für Kotlin offen war.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) führt Kotlin bereits (`grep -n 'Unterstützte Sprachen' spec/lastenheft.md` →
`` 121:**Unterstützte Sprachen:** `go`, `python`, `kotlin`, `java`, `csharp`, `cpp`. ``); ein
Change Request ist nicht nötig. Anders als bei `cpp` gibt es für Kotlin Alternativen mit Folgen
(Modul-Schnitt, Lint-Werkzeug, Layout-Menge, Zielplattform). [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) AC *Arch-Achse* verlangt eine
**arch-invariante** Bau-Gerüstung ([ADR-0008](0008-arch-achse-emittiertes-skelett.md)). Der
gepinnte a-check (`grep -n 'DefaultArchImage  =' internal/emit/archgate.go` → `v0.23.0`) führt laut
seinem Changelog ein Kotlin-Backend mit `fixed-root`/`package_base`; bestätigt wird das erst durch
die Sonde im hexslice-Slice.

## Entscheidung

Wir wählen **ein JVM-Gradle-Einzelmodul mit Paketen als Schichten, `detekt` als Lint, Layouts
`flat` und `hexslice`**.

**1. Modul-Schnitt (E1).** Ein Gradle-Modul (`settings.gradle.kts` ohne `include`); die Schichten
sind Pakete. Die Gerüstung (`settings.gradle.kts`, `build.gradle.kts`, `Dockerfile`, Lint-Config)
ist damit arch-invariant; die Schicht-Grenze erzwingt a-check, nicht der Compiler.

**2. Toolchain und Pins (E4, [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** Nur JVM. Image `gradle:<ver>-jdk<NN>`, per **Tag**
gepinnt, Knopf `SKEL_KOTLIN_VERSION` → `gen.DefaultVersion("kotlin")`; Kotlin-Plugin- und
Lint-Version stehen per Version im Gerüst. Kein Gradle-Wrapper (`gradlew` und sein Binär-JAR
entfallen). Netz beim `docker build` des Ziels wie bei `cpp` — keine neue Senkung. Die konkreten
Werte setzt der erste Kotlin-Slice; sie wandern mit dem Pin und stehen darum nicht hier.

**3. Gate-Stages und Lint (E2).** `test`/`lint`/`build` als Dockerfile-Stages, gekoppelt an das
Code-Gate-Fragment wie bei go/cpp. Test über `kotlin("test")`. Lint ist **`detekt`**; läuft die
Sonde mit der gepinnten Kotlin-Version nicht grün, ist es **`ktlint`** — der Slice nennt, welcher
Zweig gilt, und belegt ihn mit dem Sonden-Lauf. Ein dritter Weg braucht eine Folge-ADR.

**4. Layouts und Schicht-Auflösung (E3).** `kotlin` rendert `flat` und `hexslice`; `hexagonal`
erst bei Bedarf (Folge-Slice, keine neue ADR, solange Festlegung 1 trägt). Pfade
`src/main/kotlin/app/hexagon/{domain,application}/…`, `src/main/kotlin/app/adapters/{driving,driven}/…`,
Composition Root `src/main/kotlin/app/Main.kt` (Rollen-Namen aus
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)). a-check-Auflösung
`resolution: kotlin: {mode: fixed-root, roots: ["src/main/kotlin"], package_base: "app"}`;
**Paket == Verzeichnis** ist Skelett-Pflicht, weil die Auflösung über den Pfad geht.

**5. Guard.** `blockedByLang("kotlin")` nimmt die Host-Toolchain auf (Gradle, Kotlin-Compiler,
JDK-Werkzeuge, Lint-Binär); die genaue Liste koppelt der bestehende Test an `gen.SupportedLangs`.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Kotlin bleibt ungerendert) | kein Aufwand | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt Kotlin; die Welle hätte keinen Gegenstand |
| B — Gradle-Multi-Modul je Schicht | Compiler erzwingt die Grenze | Gerüstung arch-abhängig (`settings.gradle.kts` je Layout verschieden) → bricht [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) AC *Arch-Achse*, nur mit CR |
| C — Einzelmodul, `ktlint` als Standard-Lint | ktlint folgt Kotlin-Versionen schneller | reiner Stil-Check; keine Analyse wie golangci/clang-tidy |
| **D — Einzelmodul, `detekt` (Fallback `ktlint`), flat+hexslice, JVM** | arch-invariant; Analyse-Lint analog go/cpp; kleinster Layout-Umfang mit Arch-Gate | Schicht-Grenze nur über a-check; detekt hängt der Kotlin-Version nach (darum der Fallback) |
| E — zusätzlich `hexagonal` und KMP/Android | volle Achse | zwei Zähne mehr, Android-SDK im Image; kein Bedarf benannt |

## Konsequenzen

- Positiv: Kotlin dockt an die sprach-agnostischen Stellen an (`internal/gen/arch.go`,
  Arch-Gate-Bedingung); keine Anforderung an a-check oder d-check, solange die Sonde grün ist.
- Negativ (akzeptiert): je Kotlin-Stufe ein `docker build` mit Dependency-Auflösung verlängert
  `make full-smoke`; der Zuwachs wird je Slice gemessen, nicht hier geschätzt.
- Negativ (akzeptiert): ein Paket, das nicht in seinem Verzeichnis liegt, entgeht der Auflösung —
  das Skelett hält die Form ein, ein Adopter kann sie brechen; a-check sieht dann den Pfad, nicht
  das Paket.
- Folgepflicht: `spec/architecture.md` (Layout je Sprache) im hexslice-Slice nachziehen.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) über dem Kotlin-`hexslice`-Ziel | ein Import aus `app.hexagon.domain` nach `app.adapters` färbt a-check rot mit `core-impurity` (oder `wrong-direction`) — derselbe Zahn wie für go/cpp, am gebootstrappten Ziel | `make full-smoke` (kein Gate) |
| Code-Gate-Fragment ↔ Dockerfile | jedes Ziel `test`/`lint`/`build` hat seine Stage | `make test` (`TestCodeGateFragment_TargetsMatchStages`) |

Rot zu sehen ist der erste Zahn im hexslice-Slice; bis dahin trägt ihn diese Zeile als Zusage,
nicht als Beleg (`AGENTS.md` §3.6).

## Re-Evaluierungs-Trigger

- Die Sonde zeigt, dass a-check `v0.23.0` die Kotlin-Auflösung nicht trägt → Anforderung an
  a-check, Festlegung 4 neu prüfen.
- Weder `detekt` noch `ktlint` laufen mit der gepinnten Kotlin-Version grün → Festlegung 3.
- Ein Adopter verlangt `hexagonal`, Multi-Modul oder KMP/Android → E3, E1 (mit CR an [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4))
  bzw. E4.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-08 | Proposed | Vorklärung `2026-10-08-kotlin-welle-architect-vorklaerung` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0088` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
