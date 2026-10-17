# Slice slice-python-skelett: Python als Sprachskelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp` — zweiter Slice im Reihenfolge-Vorschlag.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten). [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md)
(Toolchain, Pins, Gate-Targets, Arch-Unterstützung) ist die Entscheidungsgrundlage.

**Berührte Spec-Stellen:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); `ARC-009`, `ARC-010` (über die ADR, soweit sie Layout und
Arch-Achse berührt).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang python` (Layout `flat`) rendert ein Python-Skelett mit Code-Gate-Fragment und
Guard-Set nach der ADR, das im gebootstrappten Ziel `make gates` grün fährt — ohne Host-Python.

**Vorbedingung — der Architect schreibt zuerst.** [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md) (Accepted) legt fest:
Projekt im `src`-Layout ohne Build-Backend, Image `python:3.14.8-slim` (Knopf `SKEL_PYTHON_VERSION`,
Konstante `DefaultPythonVersion`, Make-Variable `PYTHON_TAG`), `pip` mit `requirements-dev.txt`
(kein `uv`), pytest, ruff (`E,F,I,B,TID`, `ban-relative-imports = "all"`; gebunden `F401`,
`ruff format --check`) und mypy `--strict`, Stages `test`/`lint`/`build` (`compileall`), Guard-Set
`python python3 pytest ruff mypy uv uvx poetry`. Dieser Plan schreibt keine ADR und entscheidet
nichts davon.

**Hinweis zur Wiederverwendung — nicht entschieden.** `internal/gen/kotlin.go` zeigt das Muster
(`composeSkeleton`, Rollen-Renderer, Image-Tag-Pin mit Knopf `SKEL_<LANG>_VERSION`,
`blockedByLang`, `gen.CodeGateFragment`; Entscheidungsgliederung in
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)). Der Guard führt `pip`,
`pip3` und `pipx` schon als Boden jeder `--lang`-Variante; das Guard-Set der Sprache führt sie nicht
(die Union ist die eine Quelle).

**Ausdrücklich NICHT in diesem Slice:**
- `java` und `csharp` — übernehmen `slice-java-skelett` und `slice-csharp-skelett`.
- `--arch hexslice` samt a-check-Config, Rollen-Pfaden, Arch-Zahn und Entscheidung von Ports-Ordnern
  und Kanten-Menge — übernimmt `slice-python-hexslice-layout` (setzt diesen Slice voraus); bis dahin
  steht `hexslice` nicht in `langArchs()`, und `add-lang python … --arch hexslice` endet mit Exit 2
  statt mit einem Gerüst-only-Skelett.
- `hexagonal` und weitere Layouts — die ADR legt sie nicht fest; ohne ADR eine ungetragene Entscheidung.
- Ein Freshness-Werkzeug für den Python-Pin — anderer Vorgang (Wartung des Pins, nicht Skelett);
  der Vollständigkeits-Wächter für kuratierte Listen steht als Zeile in *Nächste Wellen* der Roadmap.
- Release, Handbuch-Nachzug — gehören in den Release-Schnitt (§6 der Welle).
- `spec/architecture.md` Layout je Sprache — die Folgepflicht hängt am Layout `hexslice` und liegt bei
  `slice-python-hexslice-layout`.

## 2. Definition of Done

- [ ] Renderer `python` (Layout `flat`) in `internal/gen/` nach der ADR des Architect: Gerüst inkl.
      `pyproject.toml` (nur Werkzeug-Konfiguration) und `requirements-dev.txt` mit exakten Versionen,
      Gate-Stages `test`/`lint`/`build`, Image-Pin (`python:3.14.8-slim`, eigene Konstante
      `DefaultPythonVersion`, Make-Variable `PYTHON_TAG`) mit Knopf `SKEL_PYTHON_VERSION` →
      `gen.DefaultVersion("python")`; Test Fragment↔Stages nach dem Muster der Kotlin- und C++-Tests,
      einmal rot gesehen (Stage entfernt); `blockedByLang("python")` mit Kopplung an
      `gen.SupportedLangs`, dazu ein Test auf die Guard-Namen der ADR Festlegung 6
      (`internal/emit/enforce_test.go`, Muster der Java-Namensprüfung; `pip`/`pip3`/`pipx` nicht im Set);
      Wächter der `TID252`-Bindung ([`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 3): ein Test oder Mutationsfall hält in der
      emittierten `pyproject.toml` `TID` in `select` und `ban-relative-imports = "all"`, einmal rot
      gesehen (je eine der beiden Zeilen entfernt)
      ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [ ] `make full-smoke`: `add-lang python` ins Mono-Repo, Skelett-Dateien liegen, `make gates` grün mit
      Beleg, dass das Python-Code-Gate lief, und der Guard blockt die Host-Toolchain;
      `e2e_abdeckung`-Kopfzeile nennt die Sprache und eine Teilmessung an derselben Stelle,
      `docs/user/e2e-abdeckung.md` neu erzeugt; Laufzeit-Zuwachs als Vorher/Nachher
      `make full-smoke-host` (ein Lauf je Stand, Träger: die Zeile `Python-Stufe dauerte <n>s` und die
      Gesamtdauer) mit Image-Lage und Variante ([`MR-089`](../../../../harness/conventions.md#mr-089)).
- [ ] Hilfetext nennt `python` und `SKEL_PYTHON_VERSION` (öffentlicher Vertrag), Test in
      `cmd/ai-harness-init/main_test.go`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go`, `internal/gen/python.go` | update / neu | `profiles()`, `langArchs()`, `DefaultVersion`; Gerüst und Fragment |
| `internal/gen/python_test.go` | neu | Fragment↔Stages, Gerüst-Inhalt; Test-Helfer gemeinsam mit Kotlin/Java, kein Klon (`dupl`) |
| `internal/emit/enforce.go`, `enforce_test.go` | update | `blockedByLang("python")`, Anschluss an den Guard-Boden; Namens-Test nach Festlegung 6 |
| `cmd/ai-harness-init/main.go`, `main_test.go` | update | Hilfetext nennt Sprache und Versions-Knopf |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht; Make-Variable `PYTHON_TAG` kollidiert nicht mit `GRADLE_TAG`/`JAVA_GRADLE_TAG`, am gemischten Root gelesen |
| `internal/gen/gen_test.go`, `internal/emit/zeilenenden_test.go` | update | Sprach-Listen um `python` |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `welle-sprachprofile-java-python-csharp` eröffnet, die ADR für
Python `Accepted`, WIP-Slot frei. Reihenfolge-Vorschlag: nach `slice-java-skelett` — die Kante ordnet
(dieselben Dateien), sie trägt nicht.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: der flat-Schnitt braucht mehr als die drei Liefer-Punkte (etwa ein weiteres
  Gate-Target der ADR) — zurück zur Zerlegung; Layouts darüber hinaus gehören
  `slice-python-hexslice-layout`.
- `in-progress` → `open`: Toolchain oder Lint-Werkzeug der ADR laufen mit dem gepinnten Stand nicht
  grün (Re-Evaluierungs-Trigger der ADR) — Architect.

## 5. Closure-Trigger

DoD vollständig, die Python-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Image-Pull und Paket-Auflösung verlängern `make full-smoke` — **Ausgang:** bei der Closure, Form
  nach [`MR-089`](../../../../harness/conventions.md#mr-089) (Image-Lage und Variante der Messung).
- Der Guard-Boden (`pip`) und das Guard-Set der Sprache überlappen oder lassen eine Lücke —
  **Ausgang:** bei der Closure; Gegenbeispiel (Host-Aufruf wird geblockt) rot gesehen.
- Das Image-Muster misst die Reproduzierbarkeit nicht nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): kein Lauf vergleicht zwei Bauten
  desselben Tags (`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`) —
  **Ausgang:** bei der Closure.
- `PYTHON_TAG` oder ein anderer Variablen-Name des Fragments kollidiert im gemischten Root mit dem
  Fragment einer anderen Sprache
  (`BEO-ALL/gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel`, 1×) —
  **Ausgang:** bei der Closure; Namen gegen die Fragmente der anderen Sprachen gelesen.
- Der Test-Code des Skeletts wird von `dupl` als Klon des Kotlin-/Java-Testcodes gemeldet
  (`BEO-ALL/dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette`, 1×) —
  **Ausgang:** bei der Closure; gemeinsamer Helfer von Anfang an (§3).
- Der Wächter der `TID252`-Bindung hält nur den Text der emittierten Config, nicht, dass `lint` am
  gebootstrappten Ziel einen relativen Import tatsächlich rot färbt ([`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md): am Ziel nicht gefahren) —
  **Ausgang:** bei der Closure; Grenze im Wächter benannt, oder die Wirkung rot gesehen (Fall in
  `make full-smoke` oder benannte Lücke).
- Transitive Abhängigkeiten sind ungepinnt (Festlegung 1 der ADR, akzeptiertes Negativ): zwei Bauten
  desselben Tags können sich unterscheiden — **Ausgang:** weiter offen — Register, mit der
  Reproduzierbarkeits-Beobachtung oben.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-17):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der Python-Pin steht unter diesem Regime ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 5, verkörpert ([`MR-089`](../../../../harness/conventions.md#mr-089)) ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die neue Stufe erbt es ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — 1, offen; trifft das Python-Image gleich
(zweiter Beleg, mit ungepinnten transitiven Abhängigkeiten verschärft) ·
`gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel` — 1, offen; `PYTHON_TAG` ist daran
zu prüfen (zweiter Beleg bei einem Fund) ·
`dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette` — 1, offen; gemeinsamer Helfer von Anfang an ·
`emittiertes-lint-rezept-uebergibt-die-go-version-nicht` — 1, offen; das Python-Lint-Rezept ist daran
zu prüfen ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; der
Slice fährt den Mono-Repo-Pfad, nicht den gemischten Root; ein Fund dort wäre der zweite Beleg ·
`handbuch-sprachbaum-ohne-sensor-in-full-smoke` — 1, offen; das Handbuch ist Release-Schnitt, der
Slice berührt den Baum nicht.

**Modus:** alle berührten Sub-Areas GF.
