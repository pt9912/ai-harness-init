# Review slice-java-skelett — d10447d6..0de13e8f

Rolle: Reviewer (`.harness/skills/reviewer.md`). Gegen Plan `slice-java-skelett`, ADR-0094, ADR-0088, ADR-0060 und AGENTS.md §3. Keine DoD-Prüfung (Verifier).

## Zusammenfassung

0 HIGH · 0 MEDIUM · 0 LOW · 4 INFO. Nichts blockiert.

## Findings

**INFO-1**
- kategorie: INFO · quelle: AGENTS.md §3.6 · pfad: `test/mutations/683-java-lint-zahn-im-ziel.sh`, `684-java-lint-stage-ohne-checkstyle.sh`, `harness/tools/full-smoke.sh` (Stufe `add-lang java`)
- befund: Die zwei Fälle mit `# verify: full-smoke` und die Java-Stufe selbst (Lint-Zahn `Main.java:4:8 … [UnusedImports]`, Marker `RUN gradle --no-daemon checkstyleMain checkstyleTest` im BuildKit-Protokoll) habe ich in diesem Lauf weder gefahren noch an der realen Quelle rot gesehen (Netz, Laufzeit; ein Versuch, das Ziel real zu bootstrappen und `docker build --target lint` zu fahren, wurde durch die Berechtigungsprüfung abgebrochen). Ob der Marker im BuildKit-Protokoll bei Cache-Treffern und im verwendeten Progress-Modus tatsächlich steht, ist damit Lesung, nicht Messung.
- verifizierbar: ja (`SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=683-… make mutate`, Verifier/CI) · klasse: Wächter-Beleg an realer Quelle nicht gefahren

**INFO-2**
- kategorie: INFO · quelle: ADR-0094 §Konsequenzen, AGENTS.md §3.6 · pfad: `internal/gen/java.go:12` (`DefaultJavaVersion`)
- befund: Der Pin `9.8.1-jdk21` (ebenso checkstyle 14.3.0, junit-bom 6.1.3) deckt sich mit den Messungen 1 bis 3 der ADR; kein Wächter hält ihn gegen die Registry (von der ADR als akzeptiertes Negativ benannt, Beobachtung `pin-digest-ohne-waechter`). Fall 679 bindet die Form `<ver>-jdk<NN>`, nicht die Existenz des Tags.
- verifizierbar: nein · klasse: Pin ohne Registry-Wächter

**INFO-3**
- kategorie: INFO · quelle: LH-QA-01, AGENTS.md §3.6 · pfad: `internal/gen/java.go` (`javaMixedMkFragmentTmpl`), `docs/user/e2e-abdeckung.md`
- befund: Die gemischte Root-Fassung des Java-Fragments ist nur textuell gekoppelt (`TargetsMatchStages`, `EigeneTagVariable`); kein E2E fährt Java am gemischten Root. Die Kurzbeschreibung der Stufe nennt das ausdrücklich unter NICHT gemessen (hexslice nur als Exit 2, Root-Bootstrap mit Gate-Lauf, gemischter Root mit Java) und deckt sich damit mit dem Stufenkörper.
- verifizierbar: nein · klasse: Teilmessung benannt

**INFO-4**
- kategorie: INFO · quelle: AGENTS.md §6 Schritt 7, Plan §3 · pfad: `README.md:42`, `README.md:82`
- befund: Die README-Änderung (Sprachliste, „nur das flache Layout") steht nicht in Plan §3; sie ist ein öffentlicher Vertrag (LH-FA-04 nennt Java) und nach Workflow-Schritt 7 zulässig, nicht der im Plan §1 ausgeschlossene Handbuch-Nachzug. Inhaltlich stimmt sie mit `langArchs()` überein.
- verifizierbar: nein · klasse: Doku-Nachzug außerhalb Plan-Tabelle

## Geprüft, ohne Befund

- **Mutations-Fälle 674–682:** einzeln über `make mutate` mit GNU-sed gefahren; alle neun „1 ok, 0 Befund(e)", Baum danach sauber. Jeder sed-Anker greift am realen Quelltext (`internal/gen/java.go`, `enforce.go`, `main.go`, `gen.go`), der benannte Test färbt rot. Die Exklusivitäts-Gegenprobe (`t.Skip` je Test) habe ich nicht gefahren; die Köpfe behaupten keine Exklusivität.
- **Fälle 680/681/683:** 680 und 683 löschen dieselbe Zeile (Text-Wächter vs. realer Lauf), 681 `maxWarnings`; Aufteilung nachvollziehbar, die Wächter benennen den behaupteten Grund.
- **`JAVA_GRADLE_TAG` vs. Kotlin:** Kotlin-Fragmente setzen `GRADLE_TAG ?=` (`internal/gen/kotlin.go:195,222,248`), alle drei Java-Fassungen `JAVA_GRADLE_TAG`; das `--build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG)` stimmt mit dem Dockerfile-`ARG` überein; Test und Fall 682 binden das.
- **Checkstyle/`maxWarnings`:** Config am Default-Pfad ohne `config`-Zeile, `UnusedImports` im TreeWalker, `maxWarnings = 0`, Severity error; entspricht ADR-0094 Festlegung 3; `TestJavaLintConfig_…` entfernt Kommentare vor der Modulprüfung (keine Kommentar-Treffer).
- **`blockedByLang("java")`:** Menge identisch zu ADR-0094 Festlegung 5; `mvn` steht in keinem anderen Profil (`grep mvn internal/emit/enforce.go` → eine Zeile); Kopplungstest über alle gen-Profile und Fall 675/676 grün.
- **`langArchs` nur flat / Exit 2:** `TestGenerateArch_JavaNurFlat` prüft `Available == [flat]` und leeres Zielverzeichnis für hexslice und hexagonal; die full-smoke-Stufe prüft rc 2 und Artefaktlosigkeit. Deckt Plan §1 (hexslice bleibt dem Folge-Slice).
- **Hard Rules:** keine Lint-Suppression (3.2), keine Host-Toolchain-Aufrufe im Diff (3.9), keine Schwellen-Senkung oder Gate-Lockerung (3.5); Kommentare (3.7) tragen Zusage/Kopplung/Abgrenzung, Fall-Köpfe nennen Sensoren, keine Befund-Kennungen als Grund.
- **Pins:** keine neuen Pins außerhalb der in ADR-0094 gemessenen Werte.
- **Gate:** `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH make gates` → Exit 0 (letzte Zeile `span-check: … git-ignoriert`). Ohne GNU-sed im PATH färbt `mutate-greift` auf macOS rot (663 Befunde, BSD-sed) — Umgebung, nicht Diff.
