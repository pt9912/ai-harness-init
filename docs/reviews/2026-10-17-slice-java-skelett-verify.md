# Verifikation slice-java-skelett (HEAD 90e3b03b)

Rolle Verifier (Modul 11). Frage: bauen wir es richtig, gegen Plan und DoD. Diff `d10447d6..HEAD`
(Implementer 81fb9b16, bdd12096, 2adf0b62, 0de13e8f; Review-Report 90e3b03b: 0 HIGH/MEDIUM/LOW, 4 INFO).
Bezug: LH-FA-04, ADR-0094. Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`, einzeln, nie parallel,
kein Push nach `mutate/…`. Mutations-Ergebnis nicht ueber den CI-Branch (der Implementer nannte keinen).

## Rot-Beleg nachgetragen (Reviewer INFO-1)

Beide Faelle laufen ueber die reale Stufe `add-lang java apps/java` in `harness/tools/full-smoke.sh` (Netz, Docker, gradle-Image).
- `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=683-java-lint-zahn-im-ziel make mutate` -> `[w1] 683-java-lint-zahn-im-ziel OK (43.29 s)`,
  `ok 683-java-lint-zahn-im-ziel -> full-smoke: FEHLER — das Java-Lint bleibt bei einem unbenutzten Import gruen rot`,
  `1 ok, 0 Befund(e)`. Die Meldung ist genau die erwartete (`# expect:`): `UnusedImports` aus der Config der realen Quelle
  `internal/gen/java.go` entfernt, der reale Checkstyle-Lauf im Ziel faerbt den unbenutzten Import nicht mehr. Gruen-Vorlauf 154,24 s.
- `… MUTATE_CASES=684-java-lint-stage-ohne-checkstyle make mutate` -> `OK (41.36 s)`,
  `ok 684-… -> full-smoke: FEHLER — make gates nach add-lang java ohne Beleg fuer rot`, `1 ok, 0 Befund(e)`.
  Die Meldung ist java-spezifisch (`full-smoke.sh:2848`; die Praefixe der neun Nachbarstufen sind verschieden), die Ursache ist die
  behauptete: `make gates` bleibt gruen, der Marker `RUN gradle --no-daemon checkstyleMain checkstyleTest` fehlt im BuildKit-Protokoll.
- Damit ist auch gemessen, was der Reviewer als Lesung markierte: der Marker steht im Protokoll des gruenen Vorlaufs (sonst waere der
  Gruen-Vorlauf beider Faelle rot gewesen).
- Grenze: Die Fehlermeldungen stehen im Lauf-Protokoll nur als gekuerzte Zeile des Treibers; den vollen Stufen-Output habe ich nicht
  gelesen. Die Fall-Ursache ist durch die Eindeutigkeit der Meldung getragen, nicht durch den Volltext.

## Verdikte je DoD-Punkt

1. **Renderer `java` (flat), Gerueest, Stages, Pin, Knopf, Fragment-Test, `blockedByLang`** — **bestaetigt.**
   - `internal/gen/gen.go`: `profiles()`, `langArchs()` (`java: {archFlat}`), `DefaultVersion`, `fragments()`, `fragmentsMixed()` tragen `java`.
   - Pin `gradle:9.8.1-jdk21` als eigene Konstante `DefaultJavaVersion`, eigene Variable `JAVA_GRADLE_TAG` (Fall 682), Config
     `config/checkstyle/checkstyle.xml`, `build.gradle.kts` mit `maxWarnings = 0` (`java.go:109`), `UnusedImports` (`java.go:132`).
   - `blockedByLang("java")` = `gradle gradlew java javac jar jshell checkstyle mvn mvnw` (`enforce.go:248`) — ADR-0094 Festlegung 5.
   - Rot-Belege der Fragment-/Stage-, Kopplungs-, Pin-Form-, Hilfe- und Config-Wächter: Fälle 674–682 (Reviewer fuhr alle neun
     einzeln, je `1 ok, 0 Befund(e)`); von mir nicht wiederholt (Stichprobe: der Reviewer las vollstaendig). 683/684 siehe oben.
2. **ADR-0094-Schaerfung (UnusedImports + maxWarnings = 0, roter Lint-Fall im Beleg)** — **bestaetigt mit Rot-Beleg nachgetragen.**
   Der rote Lint-Fall laeuft real in der Stufe (`Main.java:4:8: Unused import - java.util.List. [UnusedImports]`, Ursache an
   Datei und Regel gepruefft, danach Ruecknahme und gruener Lint, `full-smoke.sh` Stufenkoerper); 683 faerbt die Stufe rot, wenn die
   Regel fehlt. `maxWarnings = 0` hat keinen eigenen Real-Lauf-Zahn: Fall 681 deckt es als Text-Wächter (Go-Test), nicht ueber den
   Lauf — **Grenze, kein Befund**: ein Lint-Befund mit Severity warning wuerde im Ziel nicht real geprueft; die Config setzt Severity
   error, und der Zahn der Stufe prueft einen error-Befund.
3. **`--arch hexslice` -> Exit 2 ohne Artefakt** — **bestaetigt.** Stufe prueft `rc == 2` und dass `apps/javahex/build.gradle.kts`
   fehlt (nur in der full-smoke-Stufe real); Go-Seite: `TestGenerateArch_JavaNurFlat`, Fall 678 (`java: {archFlat}` ohne Renderer).
4. **Guard mit mvn/mvnw** — **bestaetigt.** Stufe fuettert `mvn clean package` an `$guard_doc`, erwartet `"decision": "block"`;
   `mvn`/`mvnw` stehen nur im java-Profil (Fälle 675/676, Kopplung an `gen.SupportedLangs`).
5. **`make full-smoke`-Stufe, Beleg Java-Gate lief, `e2e-abdeckung`-Zusage, Laufzeit-Zuwachs (MR-089)** — **bedingt.**
   - Stufenkoerper (Dateien liegen, `make -j gates` gruen, drei Recipe-Marker + checkstyle-Marker, Guard, Lint rot/gruen, Exit 2) ist
     real und per 683/684 rot gesehen; gruen belegt in den beiden Gruen-Vorlaeufen (154 s, 2 Laeufe).
   - `docs/user/e2e-abdeckung.md:34` (erzeugt aus `e2e_abdeckung` am Stufenkopf): nennt `Java, flat`, `assemble, test, checkstyle`,
     roten/gruenen Lint-Fall, Guard `mvn`, und am selben Ort `NICHT gemessen: hexslice (…Exit 2…), der Root-Bootstrap mit
     Gate-Lauf, ein gemischter Root mit Java`. Zusage und Koerper decken sich; die Teilmessung steht am selben Ort. Die erzeugte
     Datei ist byte-gleich zur Deklaration (`make e2e-abdeckung` ist Teil der Gates, gruen). Einschraenkung: die Zusage „assemble"
     ist ueber den Recipe-Marker `--target build` getragen, nicht ueber einen eigenen assemble-Marker (INFO, kein Befund).
   - **Offen:** Der DoD-Punkt verlangt den Laufzeit-Zuwachs vorher/nachher **mit Image-Lage und Variante** (MR-089). Die Stufe gibt
     `Java-Stufe dauerte <n>s` aus (`full-smoke.sh`), aber im Diff steht kein Vorher/Nachher-Wert mit Image-Lage/Variante; er ist
     auch kein Plan-Artefakt (§6 Ausgang 1: „bei der Closure"). Mein Vorlauf-Wert (154 s = ganze mutierte Kopie bis zur Java-Stufe,
     Host-Variante `artifact-host`, Image-Lage warm) ist **nicht** der Zuwachs und wird nicht als solcher gemeldet. Die Messung
     faellt dem Planner in der Closure zu (Zahl mit Kommando, Image-Lage, Variante).
6. **Hilfetext nennt `java` und `SKEL_JAVA_VERSION`, Test in `main_test.go`** — **bestaetigt** (Stichprobe): `main.go` Hilfe
   (`SKEL_JAVA_VERSION = Tag des gradle-Images`, `gen-Profil: go, cpp, kotlin, java`); `main_test.go` +47 Zeilen; Fall 677 faerbt
   den Test. `make gates` gruen.
7. **`make gates` gruen** — **bestaetigt.** `make gates` auf HEAD `90e3b03b`, Exit 0, letzte Zeile
   `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`;
   `.harness/state/gates-passed.head` == `git rev-parse HEAD` == `90e3b03b79d0a38fe03ad439eb107263ddcde553`.
8. **Review durchgefuehrt, Report liegt vor, kein Self-Review** — **bestaetigt.** `docs/reviews/2026-10-17-slice-java-skelett.md`
   (Commit 90e3b03b, Rolle Reviewer in der Message, eigener Commit nur mit dem Report).
9. **Closure-Notiz, Register, Risiko-Ausgaenge, drei Paarungen** — **nicht dran / Planner.** §7 ist leer (`<!-- Erst bei der
   Closure füllen. -->`), Haken stehen offen: korrekt, der Implementer hat sie nicht geschrieben (§3.10). Offene Risiken §6 ohne
   Ausgang bis zur Closure; siehe Empfehlung.

## Plan-vs-Code

- Geliefert gleich Plan §3: `gen.go`, `java.go`, `java_test.go`, `enforce.go`(+Test), `main.go`/`main_test.go`, `full-smoke.sh`,
  `e2e-abdeckung.md`, `gen_test.go`, `zeilenenden_test.go`, `test/mutations/` (674–684, ein Fall je Wächter).
- **Gebaut ohne Plan-Zeile (Plan-vs-Code, Gegenrichtung):** `README.md` (Sprachliste, zwei Stellen), `cmd/ai-harness-init/kennungen_test.go`
  (+1), `internal/gen/archgate_test.go` (+3). Bewertung: README ist oeffentlicher Vertrag (AGENTS.md §6 Schritt 7, Plan §1 schliesst
  nur das **Handbuch** aus; Inhalt stimmt mit `langArchs()` und der Zusage „nur flach"). Die zwei Test-Dateien ziehen
  Sprach-Listen nach (Fall-Aufzaehlung, ADR-0094-Kopplung); sie sind kein neuer Gegenstand. **Berührt die Abnahme nicht**, zulaessig;
  Planner moege sie in §7 als Nachzug nennen (kein Befund).
- Out-of-Scope eingehalten: kein Handbuch-Nachzug (`git diff --name-only` ohne `benutzerhandbuch.md`), kein hexslice-Renderer,
  kein python/csharp, kein Freshness-Werkzeug, keine `spec/architecture.md`-Aenderung.
- Keine Aenderung an ADR, `AGENTS.md`, `harness/conventions*`: `git diff --name-only d10447d6..HEAD | grep -E 'adr/|AGENTS|conventions'` -> leer.
- Rollen-/Commit-Zuschnitt: vier Implementer-Commits tragen `Rolle Implementer` und Kennung (LH-FA-04, ADR-0094); der Review-Commit
  beruehrt nur den Report. Kein Implementer-Commit schreibt Closure-Artefakte.

## Befunde

- **V-1 (LOW, Zusage/MR-089):** DoD-Punkt „Laufzeit-Zuwachs vorher/nachher mit Image-Lage und Variante" ist im Lieferstand
  unbelegt (nur der Stufen-Ausgabezeile `Java-Stufe dauerte <n>s`, kein Vorher/Nachher). Traeger ist laut §6 die Closure.
  Beleg: `grep -n 'Java-Stufe dauerte' harness/tools/full-smoke.sh`; kein Wert in Commit-Messages oder Doku.
- **V-2 (INFO, Grenze):** `maxWarnings = 0` hat nur einen Text-Waechter (Fall 681), keinen Lauf-Zahn im Ziel; die Stufe prueft einen
  error-Befund (siehe Punkt 2).
- **V-3 (INFO):** Die Gemischte-Root-Fassung des Java-Fragments und `assemble` als eigener Marker sind nicht real gemessen; die
  Abdeckungs-Zeile benennt den gemischten Root korrekt als NICHT gemessen.

Negativbefunde: Keine ADR-0094-Abweichung (Pin, Checkstyle, Targets, Guard-Menge, nur flat). Keine Host-Toolchain, keine
Lint-Suppression im Diff. Kein Fall faerbt aus falschem Grund (683/684 je mit der behaupteten Meldung).

## Empfehlung fuer die Closure (Planner)

DoD-Liefer-Punkte 1–4, 6–8 bestaetigt, Punkt 5 bedingt nur wegen der MR-089-Zahl. Closure freigabefaehig, wenn der Planner (a) den
Laufzeit-Zuwachs mit Kommando, Image-Lage und Variante misst und in §7 schreibt, (b) §6-Risiken mit Ausgang versieht — Risiko 3
(Checkstyle laeuft rot/gruen im Ziel) ist durch 683/684 belegt und kann *entfallen*; Risiko 2 (LH-QA-02, kein Zwei-Bau-Vergleich)
bleibt *weiter offen* (Register `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`), (c) README-Nachzug als nicht
geplante Lieferung nennt. Die drei Paarungen laufen in der Closure der Welle.
