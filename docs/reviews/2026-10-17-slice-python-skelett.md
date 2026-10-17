# Review slice-python-skelett — 909d9954..8a7d03be

Rolle: Reviewer (`.harness/skills/reviewer.md`). Gegen Plan `slice-python-skelett`, ADR-0095, ADR-0094, ADR-0088, ADR-0060 und AGENTS.md §3. Keine DoD-Prüfung (Verifier).

## Zusammenfassung

0 HIGH · 0 MEDIUM · 0 LOW · 4 INFO. Nichts blockiert.

## Findings

**INFO-1**
- kategorie: INFO · quelle: AGENTS.md §3.6 · pfad: `test/mutations/695-python-lint-zahn-f401-im-ziel.sh`, `harness/tools/full-smoke.sh` (Stufe `add-lang python`)
- befund: Der vom Implementer berichtete erste Lauf von Fall 695 mit `BEFUND worker-1 … Status 1` ist ohne ermittelte Ursache. Meine Wiederholung: `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=695-python-lint-zahn-f401-im-ziel make mutate` → `1 ok, 0 Befund(e)` (Grün-Vorlauf 162,8 s, Fall 63,8 s); 696 und 697 ebenso `1 ok`. Die Stufe hängt an der Paket-Installation der toolchain-Stage im `docker build` (Netz, PyPI) und an gleichnamigen Image-Tags (`apps-python:lint`) im Docker-Daemon; ein Netzfehler im Grün-Vorlauf färbt den Fall als BEFUND, nie als falsches `ok`. Ob Flake oder Defekt, ist damit nicht entschieden; ein Zusage-Defekt (grünes Gate über ungeprüftem Ausschnitt) ist nicht erkennbar.
- verifizierbar: nein (nicht reproduziert) · klasse: Fall-Flake ohne Ursache

**INFO-2**
- kategorie: INFO · quelle: AGENTS.md §3.6, §3.2 · pfad: `harness/tools/full-smoke.sh` (F401-Prüfung der Python-Stufe, Commit 8a7d03be)
- befund: Die SC2016-Behebung ist keine Suppression (kein `# shellcheck disable`, `make gates` grün). Die F401-Prüfung besteht jetzt aus drei unabhängigen `grep -qF` (`F401 [*]`, `imported but unused`, `src/app/main.py:3:8`) statt einer Zeile; die drei Teile können aus verschiedenen Zeilen der Ausgabe stammen. Bei der einen Probe (unbenutzter Import `os`) fällt das nicht ins Gewicht; Fall 695 ist gefahren und rot gesehen.
- verifizierbar: ja · klasse: Marker-Aufspaltung lockert Ko-Okkurrenz

**INFO-3**
- kategorie: INFO · quelle: ADR-0095 §Konsequenzen, AGENTS.md §3.6 · pfad: `internal/gen/python.go:12` (`DefaultPythonVersion`), `pythonRequirements`
- befund: Pins `3.14.8-slim`, pytest 9.1.1, ruff 0.17.1, mypy 2.4.0 decken sich mit der ADR; kein Wächter hält sie gegen die Registry (akzeptiertes Negativ der ADR). Fall 691 bindet die Form `<ver>-slim`, nicht die Existenz.
- verifizierbar: nein · klasse: Pin ohne Registry-Wächter

**INFO-4**
- kategorie: INFO · quelle: AGENTS.md §6 Schritt 7, Plan §3 · pfad: `README.md:42`, `README.md:82`
- befund: Die README-Änderung (Sprachliste, „nur das flache Layout“, „Was heute noch fehlt“) steht nicht in Plan §3; sie ist öffentlicher Vertrag (LH-FA-04) und nach Workflow-Schritt 7 zulässig; inhaltlich deckt sie sich mit `langArchs()`.
- verifizierbar: nein · klasse: Doku-Nachzug außerhalb Plan-Tabelle

## Geprüft, ohne Befund

- **Mutations-Fälle 685–694, 698, 699 einzeln** (`MUTATE_CASES=<Fall> make mutate`, GNU-sed, nie parallel): jeweils `1 ok, 0 Befund(e)`, Baum danach sauber; jeder sed-Anker greift am realen Quelltext (`python.go`, `enforce.go`, `main.go`, `gen.go`).
- **Gegenprobe der geteilten Tests** (Mutation angewandt, `t.Skip` ausschließlich im benannten Test, `make test-go`): 693, 694, 698 mit übersprungenem `TestPythonLintConfig_TraegtTIDUndBanRelativeImports` → Suite grün, der Test bindet jede der drei Mutationen allein; 688 mit übersprungenem `TestBlockedFragment_PythonTraegtDieNamenDerAdr` → grün (bindet allein); 687 → rot bleibt über `TestRun_AddLangPython` (struktureller Nebeneffekt: der Test nennt `uv` und `poetry`; der Fall-Kopf behauptet keine Exklusivität); 685 mit übersprungenem `…TargetsMatchStages` → grün. 688 und 687 färben denselben Test über verschiedene Zweige (Boden-Schleife `pip`/`pip3`/`pipx` bzw. Namensschleife), 693/694/698 über verschiedene Teile (`select`-Regel `TID`, `ban-relative-imports`, `F`).
- **Full-smoke-Fälle 695, 696, 697** mit `SMOKE_ARTIFACT_TARGET=artifact-host`: je `1 ok`; die zwei Lint-Zähne (F401 an `main.py:3:8`, TID252 an `rel.py:3:1`; die TID252-Probe nutzt den Import, damit F401 nicht mitfärbt und rot allein von `ban-relative-imports = "all"` kommt), der Marker der lint-Stage im BuildKit-Protokoll und der Exit-2-Fall sind an der realen Quelle (gebootstrapptes Ziel, realer ruff-Lauf) rot gesehen, nicht nur an der Fixture.
- **Java-Umbau (`skeleton_helpers_test.go`, `java_test.go`, `main_test.go`):** Helfer sind inhaltsgleiche Extraktionen (Root-/Subdir-/gemischte Erwartung, Stage-Kopplung, `assertNurFlat`, `assertTagVariable`, `assertAddLang…`); Stichprobe Java-Fälle 675, 677, 679, 682 nach dem Umbau je `1 ok` — keine Zähne verloren.
- **`PYTHON_TAG`:** kommt nur im Python-Fragment vor und kollidiert nicht mit `GRADLE_TAG` (Kotlin) und `JAVA_GRADLE_TAG`; Fall 692 (Umbenennung auf `JAVA_GRADLE_TAG`) färbt `…EigeneTagVariable`.
- **Python-Skelett gegen ADR-0095 Festlegung 1–3:** kein `[project]`/`[build-system]` (Test prüft Abschnittskopf am Zeilenanfang, nicht Kommentar), `select = ["E","F","I","B","TID"]`, `ban-relative-imports = "all"`, mypy strict, drei Pins exakt, Stages toolchain/build/test/lint, drei Targets und kein viertes; Datei-Satz exakt gebunden.
- **`blockedByLang("python")`:** `python python3 pytest ruff mypy uv uvx poetry`, `pip pip3 pipx` nicht doppelt (Fall 688 rot gesehen); `pytest` steht in keinem anderen Profil, die Full-smoke-Stufe belegt den Guard-Block real.
- **`langArchs` nur `flat`:** `--arch hexslice` und `hexagonal` → `UnknownArchError`, kein Artefakt (Go-Test, Fall 690, Full-smoke-Exit-2-Fall).
- **e2e-Kurzbeschreibung:** nennt Gemessenes (Gates, zwei rote Lint-Fälle, grüner Fall, Guard) und NICHT Gemessenes (hexslice, Root-Bootstrap, gemischter Root, Reproduzierbarkeit) am selben Ort; mypy- und Format-Rotfall werden nicht behauptet.
- **Hard Rules:** keine Lint-Suppression (3.2), keine Host-Toolchain-Aufrufe im Diff (3.9; Paket-Installation und Linter laufen nur in Dockerfile-Stages), keine Schwellen-Senkung (3.5); Kommentare (3.7) tragen Zusage, Kopplung oder Abgrenzung, keine Befund-Kennungen als Grund.
- **Gate:** `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH make gates` → rc=0 (letzte Zeile `span-check: … git-ignoriert`).
