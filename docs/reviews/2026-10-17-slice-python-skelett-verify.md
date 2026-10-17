# Verifikation slice-python-skelett (HEAD e8cd97f4)

Rolle Verifier (Modul 11). Frage: bauen wir es richtig, gegen Plan und DoD. Diff `909d9954..HEAD`
(Implementer 791e9bf4, 6ead61c8, 62600796, 8a7d03be; Review-Report e8cd97f4: 0 HIGH/MEDIUM/LOW, 4 INFO).
Bezug: LH-FA-04, ADR-0095. Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`, einzeln, nie parallel,
kein Push nach `mutate/…`. Mutations-Ergebnis nicht ueber den CI-Branch (der Implementer nannte keinen).

## Rot-Beleg nachgetragen und Stichproben

Der Reviewer fuhr 685–699 einzeln, die Gegenprobe der geteilten Tests mit `t.Skip` und 695–697 (je `1 ok`). Selbst gefahren:
- **TID252 an der realen Quelle (Fall 696):** `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=696-python-lint-zahn-tid252-im-ziel make mutate`
  -> `[w1] … OK (60.20 s)`, `ok 696-… -> full-smoke: FEHLER — das Python-Lint bleibt bei einem relativen Import gruen rot`,
  `1 ok, 0 Befund(e)`, Gruen-Vorlauf 183,05 s. Die Meldung ist genau die des Zweigs `pythonrel_rc == 0` im Stufenkoerper (`full-smoke.sh`,
  nur dieser Zweig traegt den Wortlaut „relativen Import“); Ursache: `ban-relative-imports = "all"` aus der Quelle `internal/gen/python.go`
  entfernt, der reale ruff-Lauf der lint-Stage im gebootstrappten Ziel faerbt `from . import main` nicht mehr. Der Gruen-Vorlauf belegt die
  Gegenrichtung: ungemutiert faerbt der reale Lauf mit `TID252 Prefer absolute imports over relative imports` an `src/app/rel.py:3:1`
  (gelesen im `make full-smoke-host`-Protokoll, Zeile `full-smoke:   #12 0.082 TID252 …`). Die Probe nutzt den Import, F401 faerbt nicht mit.
  Damit ist die Wirkung am Ziel (nicht nur der Text der Config) gemessen — das Risiko §6 „Wächter hält nur den Text“ ist am Ziel geschlossen.
- **Text-Waechter 693 / 694:** je `ok … -> TestPythonLintConfig_TraegtTIDUndBanRelativeImports rot` (`TID` aus `select` bzw. `ban-relative-imports`
  entfernt), `1 ok, 0 Befund(e)`; Baum danach sauber.
- **688 (`pip` doppelt im Python-Set):** `ok … -> TestBlockedFragment_PythonTraegtDieNamenDerAdr rot`.
- **Fall 695 (Flake-Frage):** `… MUTATE_CASES=695-python-lint-zahn-f401-im-ziel make mutate` -> `OK (59.70 s)`, `ok … das Python-Lint bleibt bei einem
  unbenutzten Import gruen rot`, `1 ok`, Gruen-Vorlauf 162,41 s. Mit der Wiederholung des Reviewers sind es zwei gruene Laeufe gegen den einen
  BEFUND des Implementers ohne Ursache; die Stufe hat keinen zufallsabhaengigen Zweig im Quelltext, sie haengt an `pip install` (Netz) im
  `docker build` und an gleichnamigen Image-Tags (`apps-python:*`). **Bewertung: Flake wahrscheinlich, nicht bewiesen** (kein Defekt reproduzierbar,
  und ein Netz-/Tag-Fehler im Gruen-Vorlauf faerbt BEFUND, nie ein falsches `ok`) — kein Zusage-Defekt. Ursache bleibt unermittelt (V-2).
- `make gates` auf HEAD: `.harness/state/gates-passed.head` == `git rev-parse HEAD` == `e8cd97f4d38c49e3273619b33e9b46cccf53a289`,
  letzte Zeile `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.

## Verdikte je DoD-Punkt

1. **Renderer `python` (flat), Geruest, Stages, Pin, Knopf, Fragment-Test, `blockedByLang`, TID-Waechter** — **bestaetigt.**
   - `internal/gen/gen.go`: `profiles()`, `langArchs()` (`python: {archFlat}`), `DefaultVersion`, `fragments()`, `fragmentsMixed()` tragen `python`.
   - `python.go`: `DefaultPythonVersion = "3.14.8-slim"`, Variable `PYTHON_TAG` (kommt in keinem anderen Fragment vor; Fall 692), `requirements-dev.txt`
     `pytest==9.1.1 ruff==0.17.1 mypy==2.4.0` (ADR-0095 Messung 1), `pyproject.toml` ohne `[project]`/`[build-system]`, `select = ["E","F","I","B","TID"]`,
     `ban-relative-imports = "all"`, mypy strict, Stages toolchain/build/test/lint, drei Targets `lint build test` und kein viertes — deckt sich mit Festlegung 1–4.
   - `enforce.go`: `python python3 pytest ruff mypy uv uvx poetry`; `pip pip3 pipx` nicht im Set (688 rot gesehen, s. o.). Namens-Test in `enforce_test.go` (+22).
   - TID252-Waechter: Text-Waechter 693/694 rot gesehen (je eine der beiden Zeilen), plus Wirkungs-Waechter 696 an der realen Quelle rot gesehen.
2. **`make full-smoke`-Stufe: Dateien liegen, `make gates` gruen mit Beleg, Guard blockt Host-Toolchain** — **bestaetigt.** Stufenkoerper
   (`full-smoke.sh`, +112 Zeilen): acht Dateien existieren, `make -j gates` rc 0, Marker `--target test|lint|build -t apps-python:… apps/python`,
   `RUN pip install -r requirements-dev.txt` und `RUN ruff check . && ruff format --check . && mypy` im BuildKit-Protokoll (697 faerbt bei fehlendem Lint-Aufruf rot),
   Guard blockt `pytest -q` (nur `blocked/python` fuehrt es; 686/687 koppeln), F401 an `main.py:3:8` und TID252 an `rel.py:3:1` je rot, danach gruen. Der Lauf `make full-smoke-host`
   auf HEAD war rc 0 (`Python-Lint-Zahn F401 belegt`, `… TID252 belegt`).
3. **`e2e_abdeckung`-Kopfzeile nennt Sprache und Teilmessung am selben Ort; `docs/user/e2e-abdeckung.md` neu erzeugt** — **bestaetigt.** Zeile 35 der Datei (Stufe 16):
   „fuenfte Sprache (Python, flat) … realen Gates (compileall, pytest, ruff, mypy strict), roten Lint-Faellen (F401, TID252), gruener Fall, Guard pytest;
   NICHT gemessen: hexslice (… Exit 2, nicht mehr), der Root-Bootstrap mit Gate-Lauf, ein gemischter Root mit Python, die Reproduzierbarkeit zweier Bauten
   (transitive Abhaengigkeiten ungepinnt)“. Zusage und Koerper decken sich; mypy-/Format-/pytest-Rotfall werden **nicht** behauptet (es gibt auch keinen: V-3). „mypy strict“
   unter den *realen Gates* ist getragen durch den Lint-Marker (gruen) plus Go-Test (699), nicht durch einen mypy-Rotfall im Ziel. Die Datei ist byte-gleich zur Deklaration (`make e2e-abdeckung` ist Teil von `make gates`, gruen).
4. **Laufzeit-Zuwachs als Vorher/Nachher (MR-089)** — **bedingt, mit Messung nachgetragen.** Weder Commit-Messages noch Repo tragen den Wert (`git log 909d9954..HEAD` ohne Sekundenwert; wie bei Java V-1: Traeger ist laut §6 die Closure).
   Gemessen von mir, Kommando `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH make full-smoke-host` (ein Lauf je Stand, Variante `artifact-host`, Host darwin/colima, **Image-Lage warm** —
   `python:3.14.8-slim` und Basisbilder waren durch die vorherigen Mutationslaeufe im Daemon-Cache; Netz/PyPI beim `pip install` nicht kalt gemessen):
   - Vorher (Worktree `909d9954`): rc 0, Gesamtdauer **157 s**.
   - Nachher (HEAD `e8cd97f4`): rc 0, Gesamtdauer **162 s**, Zeile `full-smoke: Python-Stufe dauerte 6s (add-lang, make -j gates, Lint-Zaehne, Exit-2-Fall).`
   - Zuwachs rund **+5 s** gesamt, Stufe 6 s, **warm**; die kalte Lage (Image-Pull plus Paketauflösung) ist nicht gemessen — die Zahl traegt nicht fuer einen frischen Runner (Messwert nur einmal je Stand, Rauschen im Bereich einiger Sekunden).
   Der Planner uebernimmt die Zahl in §7 mit Lage und Variante oder misst kalt (CI-Lauf `ci`-Job) nach.
5. **Hilfetext nennt `python` und `SKEL_PYTHON_VERSION`, Test in `main_test.go`** — **bestaetigt.** `main.go` (+3: `SKEL_PYTHON_VERSION = Tag des python-Images (<ver>-slim)`, `gen-Profil: go, cpp, kotlin, java, python`),
   `main_test.go` (+77/−), Fall 689 faerbt den Test (Reviewer rot gesehen; von mir nicht wiederholt, Stichprobe).
6. **`--arch hexslice` -> Exit 2 ohne Artefakt** — **bestaetigt.** Stufe prueft `rc == 2` und dass `apps/pythonhex/pyproject.toml` fehlt; Go-Seite `langArchs()` nur `flat`, Fall 690.
7. **`make gates` gruen** — **bestaetigt** (Stempel == HEAD, s. o.).
8. **Review durchgefuehrt, Report liegt vor, kein Self-Review** — **bestaetigt.** `docs/reviews/2026-10-17-slice-python-skelett.md`, Commit e8cd97f4 (Rolle Reviewer, nur der Report).
9. **Closure-Notiz, Register, Risiko-Ausgaenge, drei Paarungen** — **nicht dran / Planner.** §7 leer, Haken offen, korrekt (§3.10).

## Plan-vs-Code

- Geliefert gleich Plan §3: `gen.go`, `python.go`, `python_test.go`, `skeleton_helpers_test.go` (gemeinsamer Helfer, Plan §3 „kein Klon“), `enforce.go`(+Test), `main.go`/`main_test.go`, `full-smoke.sh`,
  `e2e-abdeckung.md`, `gen_test.go`, `zeilenenden_test.go`, `test/mutations/` 685–699 (ein Fall je Waechter).
- **Gebaut ohne Plan-Zeile (Gegenrichtung):** `README.md` (Sprachliste, „Was heute noch fehlt“), `java_test.go` (−95, Extraktion in den geteilten Helfer), `archgate_test.go` (+3), `kennungen_test.go` (+1).
  Bewertung: README ist oeffentlicher Vertrag (AGENTS.md §6 Schritt 7), Plan §1 schliesst nur das Handbuch aus, Inhalt deckt sich mit `langArchs()`; der Java-Umbau ist die in §3 verlangte Helfer-Extraktion (Reviewer: Java-Faelle 675/677/679/682 danach `1 ok`).
  Beruehrt die Abnahme nicht; Planner nennt den Nachzug in §7 (kein Befund).
- Out-of-Scope eingehalten: `git diff --name-only 909d9954..HEAD` nennt kein `benutzerhandbuch.md`, kein `spec/`, kein hexslice-Renderer (`langArchs` nur flat), kein java/csharp-Code (nur der Test-Umbau), kein Freshness-Werkzeug.
- Keine Aenderung an ADR, `AGENTS.md`, `harness/conventions*`, Lastenheft: `git diff --name-only 909d9954..HEAD | grep -E 'adr/|AGENTS|conventions|lastenheft|spec/'` -> leer.
- Rollen-/Commit-Zuschnitt: vier Implementer-Commits tragen `Rolle Implementer` und Kennung (LH-FA-04, ADR-0095); der Review-Commit beruehrt nur den Report. Kein Implementer-Commit schreibt Closure-Artefakte.

## Befunde

- **V-1 (LOW, Zusage/MR-089):** Laufzeit-Zuwachs vorher/nachher mit Image-Lage und Variante steht im Lieferstand nicht (nur die Ausgabezeile `Python-Stufe dauerte <n>s`). Traeger ist laut §6 die Closure.
  Messung von mir nachgetragen (157 s → 162 s, Stufe 6 s, warm, `artifact-host`); kalte Lage offen.
- **V-2 (INFO, Fall-Flake):** Der erste Lauf von 695 mit BEFUND ohne Ursache liess sich in zwei Wiederholungen (Reviewer, ich) nicht reproduzieren; Flake wahrscheinlich (Netz/Tag-Kollision), nicht bewiesen. Kein Zusage-Defekt.
- **V-3 (INFO, Grenze):** Format-Rotfall (`ruff format --check`), mypy-Rotfall und pytest-Rotfall haben keinen Real-Lauf-Zahn im Ziel; die Lint-Kette ist ueber den Marker im Protokoll und die Go-Tests 697/699 gehalten, nicht ueber einen roten Lauf. Die Abdeckungs-Zeile behauptet sie nicht.
- **V-4 (INFO):** Die F401-Pruefung besteht aus drei unabhaengigen `grep -qF` (Reviewer INFO-2); die Ko-Okkurrenz auf einer Zeile ist gelockert; Fall 695 ist rot gesehen, die Probe ist eindeutig (ein Import).

Negativbefunde: Keine ADR-0095-Abweichung (Pin, Werkzeug-Versionen, Targets, Guard-Menge, nur flat, a-check-frei). Keine Host-Toolchain, keine Lint-Suppression im Diff. Kein Fall faerbt aus falschem Grund (695/696 je mit der behaupteten Meldung; 693/694/688 je mit dem benannten Test).
`PYTHON_TAG` kollidiert nicht mit `GRADLE_TAG`/`JAVA_GRADLE_TAG`.

## Empfehlung fuer die Closure (Planner)

DoD-Punkte 1–3, 5–8 bestaetigt, Punkt 4 bedingt nur wegen der MR-089-Zahl (hier warm nachgemessen). Closure freigabefaehig, wenn der Planner (a) den Laufzeit-Zuwachs mit Kommando, Lage (warm/kalt) und Variante in §7 schreibt (meine Zahl oder kalte Nachmessung),
(b) §6-Risiken mit Ausgang versieht: TID252-Waechter hielt nur den Text — **entfallen/geschlossen**, die Wirkung am Ziel ist per 696 rot gesehen; Guard-Boden vs. Set — **entfallen** (688 + Stufe `pytest` geblockt); `PYTHON_TAG`-Kollision — **entfallen** (gelesen, 692);
`dupl` — **entfallen** (gemeinsamer Helfer, `make gates` gruen); LH-QA-02 (kein Zwei-Bau-Vergleich) und ungepinnte transitive Abhaengigkeiten — **weiter offen** (Register `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`),
(c) den README-Nachzug und den Java-Test-Umbau als nicht in §3 gefuehrte Lieferung nennt. Die drei Paarungen laufen in der Closure der Welle.
