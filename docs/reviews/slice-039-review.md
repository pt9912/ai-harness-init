# Code-Review: slice-039 — C++ als zweite Sprache (+ Versions-Fädelung generalisiert)

**Rolle:** Unabhängiger Code-Reviewer (Harness Modul 10) — Diff gegen Plan + ADR + Hard Rules
(nicht DoD; das ist Verifier-Rolle).

**Datum:** 2026-07-23 · **Reviewer:** Claude (frischer Durchgang, Code nicht selbst geschrieben).

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `a884686..HEAD` (21 Dateien: `internal/gen/{cpp.go,cpp_test.go,gen.go,gen_test.go,golang.go}`,
  `internal/emit/enforce.go`, `cmd/ai-harness-init/main.go` + `main_test.go`, `harness/tools/full-smoke.sh`,
  `test/mutations/{19,20,34,54–59}`, README/Benutzerhandbuch, Slice-Plan).
- **LH-*:** [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Sprachskelett-Generator,
  wiederholbar/Mono-Repo), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- **Aktive ADRs:** [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only),
  [`ADR-0005`](../plan/adr/0005-ziel-repo-distribution.md) (Tool-als-Quelle/deterministisch),
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) (Sprach-Achse, Idempotenz-Klassen).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 (v.a. §3.1 keine halluzinierten Gates, §3.6 rot-gesehene Mutation).
- **Vorherige Findings am Modul:** welle-05-Steering (Batch-Emitter je Datei gegen ADR-Tabelle; additive
  Erweiterung/Byte-Identität schützt Sensoren; entfernte Mutation = entfernte Deckung; re-verankern breiter seds).
- **Slice-Plan:** `docs/plan/planning/in-progress/slice-039-cpp-zweite-sprache.md`.

---

## Findings

Keine HIGH. Keine MEDIUM.

### INFO-1 — Quell-Repo-IDs (`ADR-0003`, `LH-QA-02`) in emittierten cpp-Artefakten

- **Quelle:** Maintainability / Steering (slice-032: „emittierte Artefakte tragen keine Quell-Repo-Identität")
- **Pfad:** `internal/gen/cpp.go:150` (`cppDockerfileTmpl` „LH-QA-02"), `:171`/`:189` (`cppMkFragmentTmpl`/
  `cppScopedMkFragmentTmpl` „Docker-only, ADR-0003")
- **Befund:** Die emittierten cpp-`.mk`-Fragmente und das Dockerfile tragen in Kommentaren die eigenen
  ADR-/Requirement-IDs von ai-harness-init (`ADR-0003`, `LH-QA-02`), die im gebootstrappten Zielrepo ins Leere
  zeigen. **Identisches Muster besteht bereits im go-Profil** (`golang.go`: `goDockerfileTmpl` „LH-QA-02",
  `goMkFragmentTmpl`/`goScopedMkFragmentTmpl` „Docker-only, ADR-0003") — cpp ist also konsistent zum Bestand,
  kein durch slice-039 eingeführter Regress. Kein Gate-Bruch: `.mk`/`Dockerfile` sind nicht-Markdown, d-check
  scannt sie nicht.
- **Verifizierbar:** nein (kein Gate; reine Kommentar-Referenz).

### INFO-2 — Zwei Wurzel-Sprachen kollidieren auf unscoped `test`/`lint`/`build`

- **Quelle:** Maintainability (Design-Grenze, nicht Slice-Vertrag)
- **Pfad:** `internal/gen/cpp.go:171` (`cppMkFragmentTmpl`, `.PHONY: test lint build`) analog `golang.go` (`goMkFragmentTmpl`)
- **Befund:** `add-lang go .` gefolgt von `add-lang cpp .` (beide am Root) droppte `harness/mk/go.mk` **und**
  `harness/mk/cpp.mk`, beide mit unscoped `test:`/`lint:`/`build:` — der Glob-Include ergäbe eine
  make-Recipe-Override-Warnung. Das ist eine **vorbestehende Eigenschaft der Root-unscoped-Fassung** (gölte für
  go+go am Root gleichermaßen) und liegt außerhalb des LH-FA-04-Mono-Repo-Vertrags (distinkte `<pfad>`, dort
  greift die modul-scoped Fassung kollisionsfrei). Kein durch cpp eingeführter Defekt.
- **Verifizierbar:** nein (Edge-Case außerhalb der getesteten Pfade).

### LOW-1 — DoD nennt `TestGenerate_Deterministic deckt cpp`, real deckt eine dedizierte cpp-Variante

- **Quelle:** Maintainability (Doku-/Zusage-Präzision; Abdeckung selbst vorhanden)
- **Pfad:** `docs/plan/planning/in-progress/slice-039-cpp-zweite-sprache.md` DoD-Punkt 4 vs.
  `internal/gen/gen_test.go:50` (`TestGenerate_Deterministic` nutzt `genGo(t)`, nur go)
- **Befund:** Der Determinismus-Wächter `TestGenerate_Deterministic` iteriert **nicht** über die Sprachen,
  sondern testet nur go; cpp-Determinismus (LH-QA-02) deckt statt seiner die neue, dedizierte
  `TestGenerate_CppDeterministic` (`cpp_test.go`). Die Eigenschaft **ist** also gedeckt — die DoD-Formulierung
  „`TestGenerate_Deterministic` deckt cpp" ist ungenau. (Ob das die DoD erfüllt, entscheidet der Verifier;
  hier nur als präzisierbare Zusage notiert.)
- **Verifizierbar:** ja (`make test` — `TestGenerate_CppDeterministic` grün belegt die cpp-Deckung).

---

## Negativbefunde (geprüft, ohne Befund)

- **cpp-Skelett-Generierung (`internal/gen/cpp.go`):** Profil ist statisch (Konstanten + ein
  `{{CXX_VERSION}}`-Replace), `cppProfile`/`cppFragment` sauber getrennt (Skelett ortsunabhängig, Fragment
  `<pfad>`-aware). Root-`context == "."` → unscoped, Subdir → modul-scoped über `renderCppScoped` — spiegelt die
  go-Mechanik. Kein Zeitstempel/keine Map-Iteration im Inhalt (LH-QA-02). **Ohne Befund.**
- **LH-QA-01 (kein halluziniertes Gate):** Jedes `docker build --target <X>` im cpp-Fragment (`test`/`lint`/
  `build`) hat eine gleichnamige Dockerfile-Stage `AS <X>`; die `toolchain`-Stage ist Build-Zwischenstufe, kein
  Target. `TestCppCodeGateFragment_TargetsMatchStages` prüft Root + Subdir; Mutation 57 (`AS test`→`AS testx`)
  färbt sie rot. **Ohne Befund.**
- **LH-QA-03 (Netzlosigkeit des cpp-Tests):** `tests/test_main.cpp` ist assert-frei mit Exit-Code (greift unter
  NDEBUG), zieht kein Framework; `tests/CMakeLists.txt` ohne `FetchContent`/`find_package`/`ExternalProject`.
  `TestGenerate_CppTestNetzlos` + Mutation 58 (`#include <gtest/gtest.h>`) decken es. Der `apt`-Toolchain-Zug im
  Dockerfile ist Bild-Build (analog go-Image-Pull, plan-konform). **Ohne Befund.**
- **Versions-Generalisierung (`goVersion`→`version`, `skelVersion`, `DefaultVersion`):** rein mechanische
  Umbenennung in `gen.go`/`golang.go`/`cpp.go`/`main.go` (Verhalten für go unberührt); `DefaultVersion(lang)`
  dispatcht go→`DefaultGoVersion`, cpp→`DefaultCppVersion`, unbekannt→`""` (Generate fängt es separat via
  `UnknownLangError`). `skelVersion` bildet `SKEL_<LANG>_VERSION` korrekt je Sprache, sprachlos→`""`.
  `TestDefaultVersion`, `TestRun_SkelGoVersionOverride` (Rückwärtskompat), `TestRun_SkelCppVersionOverride`
  decken es; Mutationen 19/20/59 rot. **Ohne Befund.**
- **`blockedByLang`-Kopplung (`internal/emit/enforce.go`):** cpp-Eintrag (`g++ gcc cmake clang-tidy clang
  clang++`) additiv; an `gen.SupportedLangs()` gekoppelt über `TestBlockedFragment_CoversAllGenProfiles` (iteriert
  die Profile → cpp automatisch mit). Mutation 56 (cpp-Zeile gelöscht) rot. Das erweiterte Token-Set (`clang`/
  `clang++` über die DoD-Liste hinaus) blockt nur zusätzliche cpp-Toolchain, keine legitimen Befehle. **Ohne Befund.**
- **ADR-0003 (Docker-only):** cpp-Gates sind ausschließlich Dockerfile-Stages (`docker build --target …`); keine
  Host-`cmake`/`clang-tidy`-Aufrufe im Fragment. **Ohne Befund.**
- **ADR-0005 (Tool-als-Quelle/deterministisch):** cpp-Skelett wird generiert, nicht gefetcht; byte-identisch bei
  gleicher Version. **Ohne Befund.**
- **ADR-0007 (Idempotenz-Klassen):** `blocked/cpp` + `harness/mk/<modul>.mk` sind konvergent/skip-if-present
  gemäß Tabelle; `add-lang cpp` folgt derselben Klassen-Mechanik wie go (slice-037/038, unverändert). full-smoke
  ergänzt cpp-Fragmente in die kein-Prune-Prüfung des sprachlosen Re-Laufs. **Ohne Befund.**
- **Hard Rule §3.6 (rot-gesehene Mutation je Wächter):** Neue Wächter 54–59 tragen je eine passende Mutation;
  reconcilte 19/20 an die neuen `version`-Signaturen re-verankert, 34 an die durch gofmt breiter gewordene
  Map-Ausrichtung (`"go":.*"go gofmt`). Alle sed-Muster gegen den Ist-Quelltext eindeutig geprüft (Datei-scoped,
  je genau ein Treffer; 20 trifft `render`+`renderScoped` — beide brechen die Zusage, konsistent zum Alt-Stand).
  **Ohne Befund.**
- **Über-/Unter-Genericisierung, tote Referenzen:** cpp-Templates identifizieren nur den Generator
  („generiert von ai-harness-init"), keine Slice-Nummern/internen Pfade im Emittat (die `slice-039`/`cmake-xray`/
  `b-cad`-Nennungen stehen ausschließlich in Go-Quell-Kommentaren, nicht in Template-Strings). **Ohne Befund**
  (bis auf INFO-1: ADR-/QA-IDs in Kommentaren, bestandskonform).
- **Doku (README, Benutzerhandbuch):** konsistent nachgezogen (`go`+`cpp`, `SKEL_CPP_VERSION`, Phasen-Tree,
  Fehlermeldung `verfuegbar: cpp, go` in Sortier-Reihenfolge). **Ohne Befund.**

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

## Verdikt

**KONFORM — kein HIGH, kein MEDIUM.** Der Slice setzt die zweite Sprache mustertreu zur bestehenden
go-Mechanik um: deterministisches, netzloses cpp-Profil (ADR-0005/LH-QA-02/LH-QA-03), Gates ausschließlich als
Dockerfile-Stages mit Stage↔Target-Kopplung (ADR-0003/LH-QA-01), `blockedByLang` an `gen.SupportedLangs()`
gekoppelt, und eine saubere `goVersion`→`version`-Generalisierung mit go-Rückwärtskompatibilität. Jeder neue/
geänderte Wächter trägt eine rot-färbende Mutation (§3.6); die drei reconcilten Mutationen (19/20/34) sind korrekt
an den neuen Ist-Code re-verankert. Die drei nicht-blockierenden Notizen (2× INFO bestands-/design-bedingt,
1× LOW DoD-Formulierungspräzision) sind optional. Merge aus Modul-10-Sicht nicht blockiert; DoD-Abnahme +
grüner Gate-/mutate-/full-smoke-Lauf bleiben Sache des Verifiers.
