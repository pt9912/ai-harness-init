# Architect-Vorklärung: Kotlin-Welle — 2026-10-08

**Rolle:** Architect (Modul 8, Planner→Architect vor der Planung) · **Modell:** claude-opus-5-5

**Gegenstand:** Auftrag des Auftraggebers „Kotlin als eigene Welle" (2026-10-08). Kein Plan, keine
ADR — Übergabe an den Planner.

> **Zitier-Form:** Dieser Report friert ein. Slices und Wellen stehen mit **Kennung**, Code-Stellen
> als Pfad in Inline-Code (Stand `1642a029`).

## 1. Lastenheft-Deckung — kein Change Request nötig

- `LH-FA-04` führt Kotlin bereits: `grep -n 'Unterstützte Sprachen' spec/lastenheft.md` →
  `` `go`, `python`, `kotlin`, `java`, `csharp`, `cpp` ``. Die Architektur-Achse (`flat`,
  `hexslice`, `hexagonal`) ist sprach-agnostisch formuliert.
- Die Sprach-Skelette tragen: `LH-FA-04` (Generator, `add-lang`, `--arch`), `LH-FA-01`
  (`--lang` als One-Shot), `LH-FA-06` (Guard-BLOCKED-Set je `--lang`), `LH-FA-07` (Arch-Gate über
  schichten-tragendem Layout), `LH-QA-01`/`LH-QA-02`/`LH-QA-03` (keine halluzinierten Gates,
  Pins, nur git+docker). Sprachlos: `LH-FA-01` Happy Path *Init, sprachlos*.
- **Grenze, die eine Option sperrt:** `LH-FA-04` AC *Arch-Achse* verlangt eine
  **arch-invariante** Bau-Gerüstung. Ein Gradle-**Multi-Modul** je Schicht (`settings.gradle.kts`
  listet je Layout andere Module) wäre arch-abhängige Gerüstung → nur mit CR. Ein **Einzelmodul**
  mit Schichten als Pakete ist gedeckt. Deshalb unten Entscheidung E1.
- **Akzeptiertes Negativ:** der überholte Satz „`cpp` … folgt" unter `LH-FA-04` bleibt stehen;
  er blockiert nichts, und ein CR nur dafür kostet mehr, als er bringt.

## 2. Nötige ADR — eine

**ADR „Kotlin-Skelett: Toolchain und Schicht-Auflösung"** (Architect schreibt sie vor dem ersten
Slice; `Schärft:` `ADR-0005`, `ADR-0008`, `ADR-0009`). Präzedenz: `cpp` kam ohne eigene ADR
(slice-039/053/054 über `ADR-0007`/`ADR-0008`/`ADR-0009`); für Kotlin gibt es aber echte
Alternativen mit Folgen, darum eine ADR. Inhalt:

1. **Toolchain-Image:** `gradle:<ver>-jdk<NN>` tag-gepinnt (Knopf `SKEL_KOTLIN_VERSION` →
   `gen.DefaultVersion`), kein Wrapper (`gradlew` + Binär-JAR entfallen); Kotlin-Plugin-Version im
   Gerüst gepinnt. Netz beim `docker build` des Ziels wie bei `cpp` (apt) — Präzedenz, keine neue
   Senkung. Beide Kotlin-Repos des Auftraggebers fahren dieselbe Form (gelesen, nicht zitiert).
2. **Gate-Stages** `test`/`lint`/`build` im Dockerfile, gekoppelt an das Fragment wie bei go/cpp
   (`TestCodeGateFragment_TargetsMatchStages`). Lint-Werkzeug: E2. Test: `kotlin("test")`.
3. **Schicht-Auflösung im Arch-Gate:** a-check `resolution: kotlin: {mode: fixed-root, roots:
   ["src/main/kotlin"], package_base: "app"}`; Grenze Paket == Verzeichnis wird zur
   Skelett-Pflicht. Pfade `src/main/kotlin/app/hexagon/{domain,application}/…`,
   `…/app/adapters/{driving,driven}/…`, Composition Root `…/app/Main.kt` (Rollen-Namen aus
   `ADR-0060`).
4. **Fitness Function:** derselbe Zahn wie bei go/cpp — Domain→Adapter-Import färbt a-check rot
   mit `core-impurity`, in `make full-smoke` am gebootstrappten Ziel.

Weitere ADRs braucht es nicht: Layout-Namen, Kompositions-Seam (`internal/gen/arch.go`) und
Arch-Gate-Bedingung (`archLayered`) sind sprach-agnostisch entschieden.

## 3. Offene Entscheidungen des Auftraggebers

| | Option | Empfehlung |
|---|---|---|
| E1 | Einzelmodul mit Paket-Schichten (a-check erzwingt) · Gradle-Multi-Modul (Compiler erzwingt, CR an `LH-FA-04`) | Einzelmodul |
| E2 | `detekt` (Gradle-Plugin, Analyse wie golangci/clang-tidy) · `ktlint` (Stil) | `detekt`, falls die ADR-Sonde es mit der gepinnten Kotlin-Version grün fährt; sonst `ktlint` |
| E3 | Layouts `flat`+`hexslice` (wie cpp) · zusätzlich `hexagonal` (wie go) | `flat`+`hexslice`; `hexagonal` erst mit Bedarf |
| E4 | nur JVM · auch KMP/Android | nur JVM |

Bedingt: Slice K4 entsteht nur bei E3 = mit `hexagonal`; bei E1 = Multi-Modul geht zuerst ein CR.

## 4. Anforderungen an Nachbar-Repos

- **a-check:** keine. Der gepinnte `v0.23.0` (`internal/emit/archgate.go` `DefaultArchImage`)
  führt das Kotlin-Backend, `fixed-root` mit `package_base` (seit 0.5.0) und den
  `shapes`-Dialekt `kotlin` (seit 0.21.0) — gelesen in `/Development/a-check/CHANGELOG.md`.
  Bestätigt wird das erst durch die Sonde in K2; bricht sie, entsteht die Anforderung dann.
- **d-check:** keine. Das emittierte Doku-Gate ist sprach-unabhängig; die Stufe
  `kennungs_form_im_ziel` liest die Sprachliste aus der Fehlermeldung des Trägers und nimmt
  Kotlin von selbst auf.

## 5. Heutiges go/cpp-Skelett — die Andockstellen

Je Sprache berührt ein neuer Renderer genau diese Stellen (`grep -rln cpp internal cmd harness/tools`):

| Stelle | go / cpp heute | Kotlin |
|---|---|---|
| `internal/gen/gen.go` `profiles()`, `langArchs()`, `DefaultVersion` | `go`, `cpp` | Eintrag + Default |
| `internal/gen/<lang>.go` Gerüst + `Role` + Fragment (unscoped/scoped/mixed) | go: `go.mod`, `Dockerfile`, `.golangci.yml`; cpp: `CMakeLists.txt`, `.clang-tidy`, `Dockerfile` (+ `src/main.cpp`, `tests/` bei flat) | `settings.gradle.kts`, `build.gradle.kts`, `Dockerfile`, Lint-Config (+ `src/main/kotlin/app/Main.kt`, `src/test/kotlin/…` bei flat) |
| `internal/gen/arch.go` `archGateConfigs()` | go: hexslice+hexagonal; cpp: hexslice | hexslice |
| `internal/emit/enforce.go` `blockedByLang()` (Test koppelt an `gen.SupportedLangs`) | `go gofmt golangci-lint staticcheck` · `g++ gcc cmake clang-tidy clang clang++` | z. B. `gradle gradlew kotlin kotlinc java javac jar detekt ktlint mvn` |
| `cmd/ai-harness-init/main.go` Hilfetext `SKEL_<LANG>_VERSION` | `SKEL_GO_VERSION`, `SKEL_CPP_VERSION` | `SKEL_KOTLIN_VERSION` |
| `harness/tools/<lang>-freshness.sh` + `make freshness-<lang>` | `freshness-go`, `freshness-cpp` | optional (K5) |
| `harness/tools/full-smoke.sh` | `add-lang cpp apps/engine` (Mono-Repo), gemischter Root, `add-lang cpp apps/cpphex --arch hexslice` + Arch-Zahn, Root-Bootstrap `--lang cpp --arch hexslice` | dieselben vier Stufen |
| `spec/architecture.md` (Layout je Sprache, um Z. 170–225) | go, C++ | Kotlin-Zeilen |

## 6. Schnittvorschlag (nach Lieferwert, je ≤ 3 Liefer-Punkte)

Vorbedingung der Welle: die ADR aus §2 `Accepted`; E1–E4 entschieden.

1. **K1 `slice-kotlin-flaches-skelett`** — Renderer `flat` + Code-Gate-Fragment (drei Fassungen) +
   `blocked/kotlin`; full-smoke: `add-lang kotlin` ins Mono-Repo und gemischter Root mit go+cpp+kotlin.
   `LH-FA-04`, `LH-FA-06`, `LH-QA-01`.
2. **K2 `slice-kotlin-hexslice-mit-arch-gate`** — Rollen-Renderer `hexslice` + `.a-check.yml`
   (Sonde der `resolution`) + Zahn `core-impurity` rot; `spec/architecture.md` nachgezogen.
   `LH-FA-04`, `LH-FA-07`.
3. **K3 `slice-kotlin-root-bootstrap`** — `--lang kotlin [--arch hexslice]` als One-Shot am Root
   (analog slice-054). `LH-FA-01`. Darf in K2 aufgehen, wenn K2 dann ≤ 3 Liefer-Punkte bleibt.
4. **K4 `slice-kotlin-hexagonal`** — nur bei E3 mit `hexagonal`: Layout + Zähne `app-impurity`,
   `lateral-adapter`. `LH-FA-07`.
5. **K5 `slice-kotlin-freshness`** — `freshness-kotlin` für den Gradle-Image-Tag; kein Gate,
   auch wellenlos lieferbar.

**Closure-Mehr der Welle:** `make gates` und `make full-smoke` grün mit allen Kotlin-Stufen —
das liegt in keiner einzelnen DoD.

**Risiko für den Planner:** JVM/Gradle verlängern `full-smoke` (je Kotlin-Stufe ein
`docker build` mit Dependency-Auflösung); der Laufzeit-Zuwachs gehört je Slice gemessen.
