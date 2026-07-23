# Slice slice-039: C++ als zweite Sprache (+ Versions-Fädelung generalisiert)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Feature-Slice, bedarfsgetrieben — Nutzer-Anforderung „C++ hinzufügen").

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0003`](../../adr/0003-go-native-binaries.md), [`ADR-0005`](../../adr/0005-ziel-repo-distribution.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

<!--
Was liefert dieser Slice in einem Satz? Liefer-Fokus, kein "wir
machen aufräumen".
-->

`ai-harness-init` bekommt **C++ als zweite Sprache** ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)):
ein deterministisches `gen`-Profil (CMake-Skelett + `Dockerfile` mit build/test/lint-Stages, netzloser
assert-Test, `.clang-tidy`), sein `<pfad>`-aware Code-Gate-Fragment und das `blocked/cpp`-Guard-Fragment —
`add-lang cpp <pfad>` / `--lang cpp` funktionieren wie für go. **Der zweite Sprach-Fall beweist die
sprach-agnostische Abstraktion und glättet dabei das „Versions-Ism":** die Go-geformte `goVersion`-Fädelung
(`SKEL_GO_VERSION`/`DefaultGoVersion`) wird zur generischen Per-Sprache-Version (`SKEL_<LANG>_VERSION` +
`gen.DefaultVersion(lang)`), rückwärtskompatibel für go. Die idiomatische Ziel-Form ist an realen
Harness-C++-Repos (`cmake-xray`, `b-cad`) geeicht: ubuntu-base + apt (build-essential/cmake/clang-tidy),
`cmake --build` / `ctest` / `clang-tidy`.

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [x] `gen.SupportedLangs()` = `["cpp", "go"]`; `add-lang cpp <pfad>` **und** `--lang cpp` erzeugen das
  C++-Modul. Rot gesehen: Mutation 54 entfernt das cpp-Profil aus `profiles()` → `TestGenerate_CppProfile` rot
  (das `fragments()`-Pendant ist über `CodeGateFragment("cpp")`→`UnknownLangError`→`t.Fatalf` mitgefangen)
  ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
- [x] **cpp-Profil** liefert Skelett (`CMakeLists.txt`, `src/main.cpp`, `tests/CMakeLists.txt` +
  `tests/test_main.cpp` [assert-basiert, **netzlos** — kein FetchContent], `Dockerfile` mit
  `build`/`test`/`lint`-Stages, `.clang-tidy`) + Code-Gate-Fragment (`harness/mk/<modul>.mk`, `<pfad>`-aware:
  Root unscoped / Subdir modul-scoped) + `tools/harness/blocked/cpp` (g++/gcc/cmake/clang-tidy).
- [x] **Kein halluziniertes Gate** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
  jedes `docker build --target <stage>` im cpp-Fragment hat eine gleichnamige Dockerfile-Stage
  (`TestCppCodeGateFragment_TargetsMatchStages` deckt cpp Root+Subdir; Mutation 57 rot).
- [x] **Kopplung erzwungen:** `TestBlockedFragment_CoversAllGenProfiles` deckt cpp automatisch (ein
  gen-Profil **ohne** `blocked/`-Eintrag → rot; Mutation 56). **Determinismus** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
  cpp-Profil statisch, byte-identisch (dedizierter `TestGenerate_CppDeterministic` — sauberer als die
  go-Variante zu erweitern).
- [x] **Versions-Fädelung generalisiert:** `goVersion`→`version` (gen); `gen.DefaultVersion(lang)` +
  `SKEL_<LANG>_VERSION`-Env; `DefaultCppVersion`. Go rückwärtskompatibel (`SKEL_GO_VERSION` wirkt weiter,
  `TestRun_SkelGoVersionOverride` grün); `TestRun_SkelCppVersionOverride` faedelt die ubuntu-Version ins cpp-Dockerfile (Mutation 59 rot).
- [x] `make full-smoke`: `add-lang cpp <subdir>` → `make -j gates` grün **inkl. C++-Gates** (cmake build +
  ctest + clang-tidy real in Docker); Guard blockt `g++`/`cmake` (via `blocked/cpp`) + `pip` (Boden).
- [x] `make gates` grün; `make mutate` grün 50/0 (cpp-Wächter 54–59 rot gesehen; refactor-veraltete 19/20/34 reconciled).
- [x] Doku: README (C++ unterstützt) + Usage-Text (`--lang cpp`, `SKEL_CPP_VERSION`); Benutzerhandbuch 1.3 (§6 phasiert).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/cpp.go` | neu | cpp-Profil (`cppProfile`/`cppFragment` + Templates: CMake/Dockerfile/clang-tidy/main/test) + `DefaultCppVersion` + `renderCpp` |
| `internal/gen/gen.go` | refactor | `goVersion`→`version` (Generate/CodeGateFragment/profiles/fragments); `cpp` in beide Maps; neuer `DefaultVersion(lang)`-Dispatcher |
| `internal/gen/golang.go` | refactor | `goVersion`→`version` in go-Signaturen (rein mechanisch, Verhalten unberührt) |
| `internal/emit/enforce.go` | update | `blockedByLang()` um `"cpp"`-Eintrag (g++/gcc/cmake/clang-tidy) |
| `cmd/ai-harness-init/main.go` | refactor | Versions-Auflösung per-Sprache: `SKEL_<LANG>_VERSION` + `gen.DefaultVersion(lang)` statt `SKEL_GO_VERSION`/`DefaultGoVersion`; Usage-Text |
| `internal/gen/*_test.go` + `cmd/**/*_test.go` | update | cpp-Profil/-Fragment-Tests, `SKEL_CPP_VERSION`-Threading, `SupportedLangs`=cpp,go; `add-lang cpp`-CLI-Test; `DefaultVersion`-Test |
| `harness/tools/full-smoke.sh` | update | E2E: `add-lang cpp <subdir>` → `make -j gates` grün inkl. C++-Gates (cmake/ctest/clang-tidy); Guard blockt g++/cmake |
| `README.md` | update | C++ unterstützt; „was noch fehlt" nachziehen |
| `test/mutations` | update | neu: cpp-Profil-Registrierung entfernt · cpp-Fragment-Kontext falsch · cpp-blocked-Kopplung |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

**Start** (`next` → `in-progress`): Nutzer-Anforderung „C++ hinzufügen" (2026-07-23) + reale Referenz-Repos
(`cmake-xray`, `b-cad`) benannt. Der Implementer beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: cpp-Profil + Versions-Generalisierung (8 Touchpoints) + full-smoke (realer
  C++-Docker-Build) + Test-/Mutations-Umbau sprengen eine Session → neu zerlegen (z.B. Versions-Gen als
  eigener Vorlauf-Slice).
- `in-progress` → `open`: blockiert, falls das cpp-Skelett nicht out-of-the-box lint-/test-sauber baut und
  erst ein Folge-ADR die Toolchain-Wahl klärt (Carveout, Modul 7).

## 5. Closure-Trigger

<!--
Wann ist der Slice done?
"DoD vollständig + PR gemerged + Closure-Notiz geschrieben."
-->

DoD vollständig · `make gates` grün · `make full-smoke` (`add-lang cpp <subdir>` → `make -j gates` grün inkl.
C++-Gates + Guard blockt g++/cmake) + `make mutate` grün · Slice per `git mv` nach `done/` · Closure-Notiz.

## 6. Risiken und offene Punkte

<!--
Was könnte schief gehen? Welche Carveouts entstehen ggf.?
-->

- **Das Versions-Ism ist real, die Generalisierung berührt 8 Touchpoints** (`goVersion`/`SKEL_GO_VERSION`/
  `DefaultGoVersion` in `gen` + `cmd` + Tests). Ein übersehener Aufrufer bricht den Build. Rückwärtskompat für
  go ist Pflicht (`SKEL_GO_VERSION` muss weiter wirken) — `TestRun_SkelGoVersionOverride` als Wächter.
- **cpp-Skelett muss out-of-the-box lint-/test-sauber bauen** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
  clang-tidy (`--warnings-as-errors='*'`, minimal `bugprone-*`/`clang-analyzer-*`) darf am trivialen `main.cpp`
  nicht feuern; ctest muss grün sein. Real erst in `make full-smoke` messbar (Docker-Build) — dort verankert.
- **Netzlos** ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)): der Test darf
  **kein** externes Framework fetchen (kein doctest/FetchContent) — assert-basiert. `apt install` im Dockerfile
  ist Bild-Build (kein Host-Toolchain), analog zum go-Image-Pull.
- **Versions-Semantik je Sprache verschieden:** go-Version = Sprachversion (`1.26.x`), cpp-„Version" = ubuntu-
  Base-Tag (`24.04`, bestimmt Compiler/cmake). `DefaultVersion(lang)` kapselt das; kein `majorMinor` für cpp
  (das ist go.mod-spezifisch).
- **full-smoke wird langsamer** (realer C++-Build: apt install cmake/clang-tidy + cmake build + ctest). Bewusst
  — der reale Gate-Lauf ist der Beweis ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** C++ als zweite Zielsprache über die bestehende Mechanik ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)):
`internal/gen/cpp.go` (CMake-Skelett + Dockerfile-Stages build/test/lint + netzloser CTest +
`.clang-tidy`, an cmake-xray/b-cad geeicht), `blockedByLang["cpp"]`, Versions-Generalisierung
`goVersion`→`version` / `gen.DefaultVersion(lang)` / `skelVersion(SKEL_<LANG>_VERSION)`. Sensoren:
`make gates` Exit 0, `make mutate` 50/0 (cpp-Wächter 54–59 rot gesehen), `make full-smoke` Exit 0
(reale C++-Gates in Docker, Guard blockt `cmake`). Review **KONFORM** (0 HIGH/0 MEDIUM,
[Report](../../../reviews/slice-039-review.md)), Verifikation **DoD BESTÄTIGT**.

**Was funktionierte.** Die von [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) versprochene Sprach-Agnostik hielt: die zweite Sprache war
**drei Map-Einträge** (`profiles`/`fragments`/`blockedByLang`) + Tests, **kein** Umbau der Mechanik.
Der einzige substanzielle Aufwand war die Versions-Generalisierung — nicht die Profil-Erweiterung.

**Was anders lief.** Die Marker-Grep-Prüfung im full-smoke-cpp-Block schlug beim ersten Lauf fehl,
obwohl die C++-Gates real grün liefen: mit dem gemischten Mono-Repo fahren **9 Docker-Builds parallel**
(`-j`), und der ~60 s lange apt-Lauf des C++-Bildes flutet BuildKit-`\r`-Progress, der die
make-Recipe-Echo-Zeilen **anderer** Targets zerhackt → der Grep fand die Recipe-Zeile nicht. Fix: `-Otarget`
(Output-Sync pro Target).

**Steering-Loop.**
- **`make -j`-Marker-Greps sind unter parallelem BuildKit fragil.** Ein E2E-Beleg, der eine make-Recipe-
  Zeile aus `make -j`-Output grept, kann durch Cross-Target-`\r`-Interleaving (v.a. bei langsamen apt-
  Stages) leer ausgehen, obwohl der Gate lief. **Regel:** solche Marker-Greps über `-Otarget` (Output-Sync)
  laufen lassen — semantik-neutral, aber deterministische Ausgabe. Neuer operativer Sensor-Gotcha.
- **Beim zweiten Instanz-Auftreten einer Achse ist die versteckte Kopplung der nach der ersten Instanz
  benannte Parameter.** `goVersion` war go-benannt, obwohl „Version" je Sprache etwas anderes heißt
  (Go-Version vs. ubuntu-Tag). Die eigentliche Arbeit war, den **Namen** zu generalisieren (`version` +
  `DefaultVersion(lang)`), nicht einen Zweig hinzuzufügen. **Regel:** bevor die zweite Instanz kommt, das
  Erst-Instanz-benannte Symbol suchen — es ist die Naht, an der der Umbau sitzt.
- **Refactor-Mutations-Reconciliation (verstärkt, slice-034/035-Klasse).** `goVersion`→`version` +
  gofmt-Map-Ausrichtung machten **drei** bestehende Mutations-Seds (19/20/34) stumm — „Patch veraltet",
  von `make mutate` als BEFUND gefangen. Bestätigt: ein Refactor bewachten Codes muss die Mutations-Anker
  **im selben Slice** re-verankern (Wächter = Code + Mutation zusammen bewegen).

**Folge-Punkte (keine Blocker).** INFO-2 des Reviews (zwei **Wurzel**-Sprachen `add-lang go .` +
`add-lang cpp .` kollidierten auf unscoped `test/lint/build`) liegt außerhalb des Mono-Repo-Vertrags
(distinkte Pfade) — kein Slice, nur notiert. Der Architektur-Schalter (`--arch`) + a-check
([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), Meilenstein M4)
folgen ADR-first als eigene Welle (nächster Schritt: `ADR-0008` Proposed). <!-- d-check:ignore (ADR-0008 existiert noch nicht — kommt als naechster Schritt) -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
