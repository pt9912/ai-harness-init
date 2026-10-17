# Slice slice-java-skelett: Java als Sprachskelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp` — erster Slice im Reihenfolge-Vorschlag.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit). [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)
(Toolchain, Pins, Gate-Targets, Arch-Unterstützung) ist die Entscheidungsgrundlage.

**Berührte Spec-Stellen:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); `ARC-009`, `ARC-010` (über die ADR, soweit sie Layout und
Arch-Achse berührt).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang java` (Layout `flat`) rendert ein Java-Skelett mit Code-Gate-Fragment und Guard-Set
nach [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md), das im gebootstrappten Ziel `make gates` grün fährt.

**Vorbedingung — der Architect schreibt zuerst.** [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md) (Accepted) legt Toolchain
(Gradle, JDK 21, Knopf `SKEL_JAVA_VERSION`), Checkstyle mit eigener Config
`config/checkstyle/checkstyle.xml`, Gate-Targets und Layouts fest. Dieser Plan entscheidet nichts davon. Der Renderer legt zusätzlich `build.gradle.kts` mit gepinnten Versionen an;
`blockedByLang("java")` führt `mvn`/`mvnw` zusätzlich zur Kotlin-Menge.

**Hinweis zur Wiederverwendung — nicht entschieden.** `internal/gen/kotlin.go` zeigt das Muster:
`composeSkeleton(scaffolding, role, version, arch)`, die Rollen-Renderer, `DefaultKotlinVersion`
(Image-Tag, Knopf `SKEL_KOTLIN_VERSION`), `blockedByLang`, `gen.CodeGateFragment`. Java läuft wie
Kotlin auf der JVM; ob das Gradle-Gerüst und das Image-Muster von
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) tragen, beantwortet
[`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md) (Festlegung 1: ja, unverändert). Dort steht auch die Auflösung `fixed-root` mit `package_base` für a-check (Paket gleich
Verzeichnis) als gemessener Fall für Kotlin.

**Ausdrücklich NICHT in diesem Slice:**
- `python` und `csharp` — übernehmen `slice-python-skelett` und `slice-csharp-skelett`.
- `--arch hexslice` samt a-check-Config und Arch-Zahn — übernimmt `slice-java-hexslice-layout`
  (setzt diesen Slice voraus); bis dahin steht `hexslice` nicht in `langArchs()`, und
  `add-lang java … --arch hexslice` endet mit Exit 2 statt mit einem Gerüst-only-Skelett.
- `hexagonal` und weitere Layouts — die ADR legt sie nicht fest; ohne ADR eine ungetragene Entscheidung.
- Ein Freshness-Werkzeug für den Java-Pin — anderer Vorgang (Wartung des Pins, nicht Skelett);
  der Vollständigkeits-Wächter für kuratierte Listen steht als Zeile in *Nächste Wellen* der Roadmap.
- Release, Handbuch-Nachzug — gehören in den Release-Schnitt (§6 der Welle).
- `spec/architecture.md` Layout je Sprache — die Folgepflicht hängt am Layout `hexslice` und liegt bei
  `slice-java-hexslice-layout`.

## 2. Definition of Done

- [x] Renderer `java` (Layout `flat`) in `internal/gen/` nach [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md): Gerüst inkl. `build.gradle.kts`
      und `config/checkstyle/checkstyle.xml`, Gate-Stages `test`/`lint`/`build`,
      Image-Pin (`gradle:9.8.1-jdk21`, eigene Konstante) mit Knopf `SKEL_JAVA_VERSION` → `gen.DefaultVersion("java")`; Test Fragment↔Stages
      nach dem Muster der Kotlin- und C++-Tests, einmal rot gesehen (Stage entfernt);
      `blockedByLang("java")` inkl. `mvn`/`mvnw` mit Kopplung an `gen.SupportedLangs` (Kopplungstest
      geprüft)
      ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [x] `make full-smoke`: `add-lang java` ins Mono-Repo, Skelett-Dateien liegen, `make gates` grün mit
      Beleg, dass das Java-Code-Gate lief, und der Guard blockt die Host-Toolchain; `e2e_abdeckung`-Kopfzeile
      nennt die Sprache und eine Teilmessung an derselben Stelle, `docs/user/e2e-abdeckung.md` neu
      erzeugt; Laufzeit-Zuwachs vorher/nachher mit Image-Lage und Variante
      ([`MR-089`](../../../../harness/conventions.md#mr-089)).
- [x] Hilfetext nennt `java` und `SKEL_JAVA_VERSION` (öffentlicher Vertrag), Test in
      `cmd/ai-harness-init/main_test.go`.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go`, `internal/gen/java.go` | update / neu | `profiles()`, `langArchs()`, `DefaultVersion`; Gerüst und Fragment |
| `internal/gen/java_test.go` | neu | Fragment↔Stages, Gerüst-Inhalt |
| `internal/emit/enforce.go` (+ Test) | update | `blockedByLang("java")` |
| `cmd/ai-harness-init/main.go`, `main_test.go` | update | Hilfetext nennt Sprache und Versions-Knopf |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht |
| `internal/gen/gen_test.go`, `internal/emit/zeilenenden_test.go` | update | Sprach-Listen um `java` |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `welle-sprachprofile-java-python-csharp` eröffnet, [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)
`Accepted`, WIP-Slot frei.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: der flat-Schnitt braucht mehr als die drei Liefer-Punkte (etwa ein weiteres
  Gate-Target der ADR) — zurück zur Zerlegung; Layouts darüber hinaus gehören
  `slice-java-hexslice-layout`.
- `in-progress` → `open`: Toolchain oder Lint-Werkzeug der ADR laufen mit dem gepinnten Stand nicht
  grün (Re-Evaluierungs-Trigger der ADR) — Architect.

## 5. Closure-Trigger

DoD vollständig, die Java-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Image-Pull und Dependency-Auflösung verlängern `make full-smoke` — **Ausgang:** weiter offen — der
  Zuwachs ist gemessen (§7), der Image-Pull auf frischem Host nicht: `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`.
- Das Image-Muster misst die Reproduzierbarkeit nicht nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): kein Lauf vergleicht zwei Bauten
  desselben Tags (`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`) —
  **Ausgang:** weiter offen — `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`.
- Checkstyle mit eigener Config läuft mit dem gepinnten Image nicht rot/grün wie die ADR misst —
  **Ausgang:** entfallen — Lint rot und grün am gebootstrappten Ziel gesehen, Fälle 683 und 684 färben mit der behaupteten Meldung.

## 7. Closure-Notiz

- **Was hat funktioniert:** Das Kotlin-Muster (`composeSkeleton`, Fragment, Stufe) trug Java ohne
  Umbau; die Java-Stufe fährt Gradle-Gates, Lint rot und grün und den Guard im Mono-Repo.
- **Was ging anders als geplant:** Nicht geplant geliefert: der Sprachlisten-Nachzug in `README.md`
  (öffentlicher Vertrag, [`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 7; bleibt, Reviewer und Verifier
  bestätigen die Zulässigkeit) sowie Listen-Nachzüge in `cmd/ai-harness-init/kennungen_test.go` und
  `internal/gen/archgate_test.go`. Der `dupl`-Befund zwischen Kotlin- und Java-Testcode wurde durch
  einen gemeinsamen Helfer behoben.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** `make full-smoke-host`, macOS/arm64
  (Colima), warm (Image `gradle:9.8.1-jdk21` und Layer lokal vorhanden, kein Pull), Variante Mono-Repo mit
  `add-lang` go, cpp, kotlin (+ java): Stand `d10447d6` 132 s, Stand `fb5840c2` 145 s (+13 s); die
  Java-Stufe allein 14 s (`Java-Stufe dauerte 14s`). Je ein Lauf je Stand. **Ungemessen:** kalter
  Cache und Image-Pull; keine Aussage über andere Varianten.
- **Benannte Grenzen (Verifier V-2, V-3):** `maxWarnings = 0` der Checkstyle-Config hat nur einen
  Text-Wächter (Fall 681), keinen Lauf-Zahn im Ziel; die Stufe prüft einen error-Befund
  (`UnusedImports`). Die Fassung des Java-Fragments am gemischten Root und `assemble` als eigener Marker
  sind nicht real gemessen; die Abdeckungs-Zeile nennt den gemischten Root als nicht gemessen.
- **Steering-Loop-Eintrag:** geschärfte Regel (Vorschlag, nicht verkörpert): ein Slice-Plan, dessen DoD
  eine Messzahl der Closure verlangt, nennt Kommando und Träger der Messung im Plan; V-1 des Verifiers
  führte den Punkt als unbelegt, weil nur §6 „bei der Closure" sagte. Der Eintrag ist gezählt, nicht
  verkörpert.
- **Beobachtungs-Register (`../observations/`):** neu angelegt, je Beleg `evidence/slice-java-skelett.md`:
  `BEO-ALL/gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel`,
  `BEO-ALL/dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette`,
  `BEO-ALL/commit-message-datei-im-scratchpad-ist-fuer-den-docker-daemon-unsichtbar` (je 1×);
  ergänzt: `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (5×, verkörpert) und
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (1×, offen; erster Beleg). Kein
  Eintrag erreicht mit diesem Slice neu 3×.
- **Folge-Slices:** `slice-java-hexslice-layout` — ist eine Datei in `open/`
- **Risiken aus §6:** Risiko 1 weiter offen (Register), Risiko 2 weiter offen (Register), Risiko 3
  entfallen — je einmal in §6.


## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-17):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der Java-Pin steht unter diesem Regime ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 4, verkörpert ([`MR-089`](../../../../harness/conventions.md#mr-089)) ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die neue Stufe erbt es ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen, ohne Beleg-Verzeichnis; trifft das
Java-Image gleich ·
`emittiertes-lint-rezept-uebergibt-die-go-version-nicht` — 1, offen; das Java-Lint-Rezept ist daran zu
prüfen ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; der
Slice fährt den Mono-Repo-Pfad, nicht den gemischten Root; ein Fund dort wäre der zweite Beleg ·
`handbuch-sprachbaum-ohne-sensor-in-full-smoke` — 1, offen; das Handbuch ist Release-Schnitt, der
Slice berührt den Baum nicht.

**Modus:** alle berührten Sub-Areas GF.
