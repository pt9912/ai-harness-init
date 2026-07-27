# Review-Report: slice-053 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-053 (`cppRole` rendert die hexSlice-Schichten), Commit `bf7e0ec`
(8 Dateien, +680/−42) sowie die Auflösung `f3de87e`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Grenze dieses Laufs — benannt, nicht kaschiert:** Modul 8 verlangt für den Reviewer
**frischen Kontext** (Subagent oder geleerter Kontext). Dieser Lauf fand im **selben**
Kontext statt, der den Code schrieb; ein Subagent war für diese Sitzung ausgeschlossen.
Der bekannte Effekt ist ein geteilter blinder Fleck — die Findings unten sind
entsprechend **gemessen** statt erinnert (jedes trägt sein Kommando). Das ersetzt die
Kontext-Trennung nicht, adressiert aber die Klasse „ich halte meinen eigenen Kommentar
für wahr".

**Eingangs-Kontext:**

- Slice-Plan: `docs/plan/planning/in-progress/slice-053-cpp-hexslice-renderer.md` (§2 DoD drei Punkte, §3 Ist-Messung, §6 Risiken) — Klartext-Pfad, der `done/`-Move bricht sonst
- Welle: `docs/plan/planning/welle-08-cpp-hexslice.md` §3 Closure-Trigger
- Berührte `LH-*`-IDs: [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- Aktive ADRs: [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md) (HexSlice-Realisierung), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- [`AGENTS.md`](../../AGENTS.md) §3 Hard Rules — insbesondere §3.6
- Vorherige Findings am gleichen Modul: die slice-045a/046-Reports (Klasse „Config/Skelett-Drift"), slice-032 L-2 (Quell-Identität in emittierten Artefakten)

---

## Findings

### F-1 — Der Kommentar behauptete Lint-Abdeckung, die der Header-Filter verhinderte

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage ohne rot gesehenes Gegenbeispiel) · slice-053 DoD (2) („Code-Gates **über dem Schichten-Code**")
- `pfad`: `internal/gen/cpp.go` (`cppRole`-Doc-Kommentar; `cppClangTidy`)
- `befund`: Der Doc-Kommentar sagte, die header-only Schichten würden „von clang-tidy (HeaderFilterRegex `'^src/'`) mitgelintet". Gemessen am real generierten Modul: ein `bugprone-branch-clone` im Domain-Header ließ `docker build --target lint` **grün** (Exit 0) — das am Zeilenanfang verankerte Muster trifft den absoluten Container-Pfad `/src/src/hexagon/…` nie. Das Layout wäre gebaut, aber ungelintet, während der Gate Erfolg meldet.
- `verifizierbar`: ja — Verstoß in eine Schicht-Datei setzen und die `lint`-Stage fahren; mit `'(^|/)src/'` Exit 1 (`bugprone-branch-clone`), mit `'^src/'` Exit 0.
- **Status:** aufgelöst in `f3de87e` (Regex unverankert + zweiter `full-smoke`-Zahn, der genau diesen Fall rot fährt).

### F-2 — Normative Regeln lebten nur in Go-Kommentaren

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence: `spec/architecture.md` steht über Code) · Nutzer-Hinweis 2026-07-27 („Kommentare sind nicht normativ")
- `pfad`: `internal/gen/cpp.go` (Block-Kommentar über den Schicht-Konstanten; `cppRole`)
- `befund`: Zwei Regeln mit Architektur-Charakter standen ausschließlich in Kommentaren: (a) Referenzen zwischen Schicht-Dateien müssen modul-root-relativ sein, weil das Arch-Gate nur diese Form auflöst; (b) die `adapters→ports`-Kante ist sprach-abhängig (Vererbung vs. strukturelle Erfüllung). Ein Kommentar bindet niemanden und wird beim nächsten Sprach-Renderer nicht gelesen — F-1 ist der Beleg, dass er nicht einmal sich selbst bindet.
- `verifizierbar`: nein — kein Gate prüft, wo eine Regel wohnt; der Effekt zeigt sich erst am nächsten Renderer.
- **Status:** aufgelöst in `f3de87e` (beide Regeln in [`spec/architecture.md`](../../spec/architecture.md) §5; die Kommentare zeigen nur noch dorthin und auf die Sensoren).

### F-3 — Anforderungs-IDs im emittierten Inhalt

- `kategorie`: LOW
- `quelle`: slice-032 L-2 (emittierte Artefakte tragen keine Quell-Repo-Identität)
- `pfad`: `internal/gen/cpp.go` (`cppHexArchConfig`, `cppCMakeLists`)
- `befund`: Die emittierte `.a-check.yml` und die `CMakeLists.txt` trugen `LH-QA-01` bzw. `LH-FA-04-AC` in ihren Kommentaren — Kennungen, die es im Ziel-Repo nicht gibt.
- `verifizierbar`: ja — `grep -nE "LH-[A-Z]+-[0-9]+" internal/gen/cpp.go` auf den emittierten Konstanten.
- **Status:** aufgelöst in `f3de87e`.

### F-4 — Drei vorbestehende ID-Leaks derselben Klasse bleiben stehen

- `kategorie`: INFO
- `quelle`: slice-032 L-2
- `pfad`: `internal/gen/cpp.go` (`cppDockerfileTmpl`, `cppMkFragmentTmpl`, `cppScopedMkFragmentTmpl`)
- `befund`: Dieselbe Klasse existiert seit slice-039 an drei Stellen (`LH-QA-02`, zweimal `ADR-0003`). Sie **nicht** mitzufixen ist bewusst: es sind Bytes des **flachen** Skeletts, und die frisch beschlossene [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)-AC lässt `flat` nur um das Include-Pfad-Minimum abweichen.
- `verifizierbar`: ja — derselbe `grep`; Folge-Punkt für einen Wartungs-Slice.

### F-5 — `--lang cpp --arch hexslice` als Root-One-Shot ist ungetestet

- `kategorie`: INFO
- `quelle`: [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (One-Shot-Kurzform)
- `pfad`: `harness/tools/full-smoke.sh`
- `befund`: `full-smoke` deckt cpp+hexslice als **Subdir-Modul** und den go-Fall am **Root**; die Kombination cpp+hexslice **am Root** (`<pfad>=.`, `CMAKE_SOURCE_DIR` = Repo-Root) fährt kein Sensor. Der Pfad ist plausibel korrekt, aber unbelegt.
- `verifizierbar`: ja — ein weiterer Bootstrap im `full-smoke`; Kandidat für slice-054.

### F-6 — Die sprach-spezifische Arch-Validierung ist unerreichbar geworden

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `internal/gen/gen.go` (`GenerateArch`, zweite Stufe)
- `befund`: Seit beide Sprachen beide Architekturen tragen, kann keine Eingabe die zweite Validierungsstufe erreichen, ohne dass die erste zuerst greift — sie ist unbewacht. Der Code benennt das ausdrücklich, und Mutation 63 nimmt deshalb die **Eigenschaft** (beide Stufen) weg statt einer Stufe.
- `verifizierbar`: ja — eine Ein-Stufen-Mutation bliebe grün; genau deshalb mutiert Fall 63 beide.

## Negativbefunde

- geprüft, ohne Befund: **Plan-Treue** — der Diff liefert genau die drei DoD-Punkte; kein Doku-Update an Handbuch/README (in der DoD ausdrücklich ausgeschlossen), kein Eingriff in `internal/gen/arch.go` jenseits des `archGateConfigs`-Eintrags (Rollen-Vokabular, `archLayout`, `archLayered` unberührt).
- geprüft, ohne Befund: **wandernde Zusage vollständig umgeschrieben** — `grep -rn "AddLangCppHexsliceRejected"` über `*.go`/`*.sh` liefert **keinen** Treffer; Test, `full-smoke`-Block und Mutation 63 zeigen auf die neue Grenze (unbekannte Architektur).
- geprüft, ohne Befund: **`--arch flat` unverändert bis auf das CR-gedeckte Minimum** — `TestGenerate_CppProfile` (exakter Datei-Satz) grün; die einzigen Inhalts-Abweichungen der flachen Gerüstung sind Include-Pfad-Zeile und Header-Filter, beide von CR 0.16.0 gedeckt und für ein flaches Layout wirkungslos.
- geprüft, ohne Befund: **Docker-only** ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)) — der neue `full-smoke`-Block ruft ausschließlich `make`/`docker`; der zwischenzeitlich verwendete `python3`-Heredoc wurde vor dem Commit durch `sed` ersetzt ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- geprüft, ohne Befund: **Lint-Suppression** ([`AGENTS.md`](../../AGENTS.md) §3.2) — kein `//nolint`, kein `# shellcheck disable`; `make shell-lint` Exit 0.
- geprüft, ohne Befund: **emittierte Idempotenz-Klassen** — `.a-check.yml` bleibt skip-if-present, `a-check.mk` und Fragmente konvergent; der Idempotenz-Block im `full-smoke` läuft unverändert grün.
- geprüft, ohne Befund: **Determinismus** ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — die Schicht-Inhalte sind statische Konstanten, der Generator schreibt sortiert; zwei Läufe erzeugen denselben Baum.
- geprüft, ohne Befund: **kein halluziniertes Gate** ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — jedes Target des cpp-Fragments referenziert eine gleichnamige Dockerfile-Stage; das Arch-Gate wird nur bei schichten-tragendem Layout emittiert, und `full-smoke` prüft beide Richtungen.
- geprüft, ohne Befund: **Mutations-Abdeckung der neuen Wächter** — drei neue Fälle (91 Rollen-Abdeckung, 92 Include-Form, 93 Arch-Gate-Config), alle rot gesehen.
- geprüft, ohne Befund: **Schicht-Semantik gegen [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md)** — vier Schichten + Composition Root, inward-only; die zusätzliche `adapters→ports`-Kante ist keine Lockerung der Richtung, sondern die sprach-bedingte Form derselben Beziehung (jetzt in `architecture.md` §5 verankert).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 3 |

## Verdikt

**Merge-blockierend:** nein — **nach Auflösung**. F-1 und F-2 waren blockierend und sind
in `f3de87e` aufgelöst (gemessen und mit Zahn bzw. normativ verankert), F-3 ebenfalls.
F-4 bis F-6 sind INFO und erwarten keine Aktion in diesem Slice; F-5 ist der konkreteste
Kandidat für slice-054.

**Der wertvollste Befund kam nicht aus dem Diff, sondern aus einem Lauf:** F-1 war im
Code nicht sichtbar — der Kommentar las sich korrekt, der Regex ebenso. Sichtbar wurde
er erst, als der Verstoß real in eine Schicht-Datei gesetzt und der Gate gefahren wurde.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
