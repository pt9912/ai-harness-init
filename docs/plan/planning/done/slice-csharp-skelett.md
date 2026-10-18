# Slice slice-csharp-skelett: C# als Sprachskelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp` — dritter Slice im Reihenfolge-Vorschlag.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit). [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)
(Toolchain, Pins, Gate-Targets, Arch-Unterstützung) ist die Entscheidungsgrundlage.

**Berührte Spec-Stellen:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); `ARC-009`, `ARC-010` (über die ADR, soweit sie Layout und
Arch-Achse berührt).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang csharp` (Layout `flat`) rendert ein C#-Skelett mit Code-Gate-Fragment und
Guard-Set nach der ADR, das im gebootstrappten Ziel `make gates` grün fährt — ohne Host-.NET.

**Vorbedingung — der Architect schreibt zuerst.** [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) (Accepted) legt fest:
Image `mcr.microsoft.com/dotnet/sdk:10.0.402` (Knopf `SKEL_CSHARP_VERSION`, Konstante
`DefaultCsharpVersion`, Make-Variable `DOTNET_TAG`), zwei Projekte `src/App` und `tests/App.Tests` in
klassischer `app.sln`, TFM aus Major.Minor des Tags abgeleitet (Literal in `Directory.Build.props`),
xunit 2.9.3 mit `Microsoft.NET.Test.Sdk` und `xunit.runner.visualstudio`, Lint = SDK-Analyzer und
`dotnet format --verify-no-changes` über `.editorconfig` (gebunden `IDE0005 = error`,
`IDE0130 = error`, `TreatWarningsAsErrors`), Stages `test`/`lint`/`build`, Guard-Set
`dotnet msbuild nuget csc`. Dieser Plan schreibt keine ADR und entscheidet nichts davon.

**Hinweis zur Wiederverwendung — nicht entschieden.** `internal/gen/kotlin.go` zeigt das Muster
(`composeSkeleton`, Image-Tag-Pin mit Knopf `SKEL_<LANG>_VERSION`, `blockedByLang`,
`gen.CodeGateFragment`; Entscheidungsgliederung in
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)). Der Guard führt `pip`,
`pip3` und `pipx` als Boden; das Set der Sprache führt sie nicht (die Union ist die eine Quelle).

**Ausdrücklich NICHT in diesem Slice:**
- `java` und `python` — übernehmen `slice-java-skelett` und `slice-python-skelett`.
- `--arch hexslice` samt a-check-Config (`fixed-root`, Root `src/App`), PascalCase-Pfaden,
  Schreibweisen-Test, Arch-Zahn und Entscheidung von Ports-Ordnern und Kanten-Menge — übernimmt
  `slice-csharp-hexslice-layout` (setzt diesen Slice voraus); bis dahin steht `hexslice` nicht in
  `langArchs()`, und `add-lang csharp … --arch hexslice` endet mit Exit 2 statt mit einem
  Gerüst-only-Skelett.
- `hexagonal` und weitere Layouts — die ADR legt sie nicht fest; ohne ADR eine ungetragene Entscheidung.
- Das Verhalten von `dotnet test --no-restore` bei kaputtem Bau (unter SDK 8.0.426 Exit 0 beobachtet) —
  benannte Lücke der ADR, kein Gegenstand; `build` im selben `GATE_CHECKS` fängt den Fall.
- Ein Freshness-Werkzeug für den C#-Pin — anderer Vorgang (Wartung des Pins, nicht Skelett);
  der Vollständigkeits-Wächter für kuratierte Listen steht als Zeile in *Nächste Wellen* der Roadmap.
- Eine Entscheidung zu [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Change Request oder Digest-Pin im Skelett) — der Slice liefert nur
  den Beleg zur Beobachtung (§6); entschieden wird außerhalb.
- Release, Handbuch-Nachzug — gehören in den Release-Schnitt (§6 der Welle).
- `spec/architecture.md` Layout je Sprache — die Folgepflicht hängt am Layout `hexslice` und liegt bei
  `slice-csharp-hexslice-layout`.

## 2. Definition of Done

- [x] Renderer `csharp` (Layout `flat`) in `internal/gen/` nach der ADR des Architect: Gerüst
      (`app.sln` mit festen GUIDs, beide `.csproj`, `Directory.Build.props`, `.editorconfig`,
      `Program.cs`, ein xunit-Test), Gate-Stages `test`/`lint`/`build`, Image-Pin
      (`mcr.microsoft.com/dotnet/sdk:10.0.402`, eigene Konstante `DefaultCsharpVersion`, Make-Variable
      `DOTNET_TAG`) mit Knopf `SKEL_CSHARP_VERSION` → `gen.DefaultVersion("csharp")`; Test
      Fragment↔Stages nach dem Muster der Kotlin- und C++-Tests, einmal rot gesehen (Stage entfernt);
      `blockedByLang("csharp")` mit Kopplung an `gen.SupportedLangs`, dazu ein Test auf die Guard-Namen
      der ADR Festlegung 6 (`internal/emit/enforce_test.go`, Muster der Java-Namensprüfung;
      `pip`/`pip3`/`pipx` nicht im Set). **Drei Wächter-Zusagen der ADR, je einmal rot gesehen:**
      (a) die TFM-Ableitung — ein Test hält die gerenderte TFM gegen Major.Minor des Tags, Verfälschen
      färbt rot, dazu ein zweiter Fall: ein Knopf-Wert ohne Major.Minor (`latest`, `10`) bricht den
      Generator mit Exit 2 ab ([`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2), einmal rot gesehen (Abbruch entfernt);
      (b) die Bindungen — Text-Wächter je Zeile hält in der emittierten `.editorconfig`
      `IDE0005 = error` und `IDE0130 = error` und in `Directory.Build.props` `TreatWarningsAsErrors`
      und `AnalysisLevel latest-recommended`, jede der vier Zeilen einzeln entfernt färbt rot;
      (c) der Lauf-Zahn im Ziel in derselben Lieferung, denn die Text-Prüfung hält nicht, dass
      `dotnet format` bzw. `build` die Regel am gebootstrappten Ziel meldet (Lehre des
      Python-Lerneintrags): ein Mutations-Fall entfernt die `IDE0005`-Zeile aus der Quelle, und der
      reale `lint`-Lauf der Stufe färbt einen unbenutzten `using` nicht mehr; ein zweiter entfernt
      `AnalysisLevel latest-recommended`, und der reale `build`-Lauf färbt eine nicht-statische
      Methode ohne Instanzzugriff (`CA1822`) nicht mehr
      ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [x] `make full-smoke`: `add-lang csharp` ins Mono-Repo, Skelett-Dateien liegen, `make gates` grün mit
      Beleg, dass das C#-Code-Gate lief, und der Guard blockt die Host-Toolchain;
      `e2e_abdeckung`-Kopfzeile nennt die Sprache und eine Teilmessung an derselben Stelle
      (`--arch hexslice` und Arch-Gate nicht gemessen), `docs/user/e2e-abdeckung.md` neu erzeugt;
      Laufzeit-Zuwachs als Vorher/Nachher `make full-smoke-host` (ein Lauf je Stand, Träger: die Zeile
      `C#-Stufe dauerte <n>s` und die Gesamtdauer) mit Image-Lage und Variante
      ([`MR-089`](../../../../harness/conventions.md#mr-089)); **die Messzahl liegt im Lieferstand
      (Handoff) vor, nicht erst in der Closure** — Lehre aus Java und Python, wo der Plan Kommando und
      Träger nannte und die Zahl im Lieferstand trotzdem fehlte.
- [x] Hilfetext nennt `csharp` und `SKEL_CSHARP_VERSION` (öffentlicher Vertrag), Test in
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
| `internal/gen/gen.go`, `internal/gen/csharp.go` | update / neu | `profiles()`, `langArchs()`, `DefaultVersion`; Gerüst und Fragment |
| `internal/gen/csharp_test.go` | neu | Fragment↔Stages, Gerüst-Inhalt, TFM-Ableitung, Config-Bindungen; Test-Helfer gemeinsam mit Kotlin/Java/Python aus `internal/gen/skeleton_helpers_test.go` von Anfang an, kein Klon (`dupl`) |
| `internal/emit/enforce.go`, `enforce_test.go` | update | `blockedByLang("csharp")`; Namens-Test nach Festlegung 6 |
| `cmd/ai-harness-init/main.go`, `main_test.go` | update | Hilfetext nennt Sprache und Versions-Knopf |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht; Make-Variable `DOTNET_TAG` kollidiert nicht mit `GRADLE_TAG`, `JAVA_GRADLE_TAG`, `PYTHON_TAG`, am gemischten Root gelesen |
| `internal/gen/gen_test.go`, `internal/emit/zeilenenden_test.go` | update | Sprach-Listen um `csharp` |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `welle-sprachprofile-java-python-csharp` eröffnet, die ADR für
C# `Accepted`, WIP-Slot frei. Reihenfolge-Vorschlag: nach `slice-python-skelett` — die Kante ordnet
(dieselben Dateien), sie trägt nicht.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: der flat-Schnitt braucht mehr als die drei Liefer-Punkte (etwa ein weiteres
  Gate-Target der ADR) — zurück zur Zerlegung; Layouts darüber hinaus gehören
  `slice-csharp-hexslice-layout`.
- `in-progress` → `open`: Toolchain oder Lint-Werkzeug der ADR laufen mit dem gepinnten Stand nicht
  grün (Re-Evaluierungs-Trigger der ADR) — Architect.

## 5. Closure-Trigger

DoD vollständig, die C#-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Image-Pull und NuGet-Restore verlängern `make full-smoke` — **Ausgang:** bei der Closure, Form nach
  [`MR-089`](../../../../harness/conventions.md#mr-089) (Image-Lage und Variante der Messung); die
  Zahl selbst liegt schon im Lieferstand (§2).
- Das Image-Muster misst die Reproduzierbarkeit nicht nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): kein Lauf vergleicht zwei Bauten
  desselben Tags — **Ausgang:** bei der Closure. Hier entsteht der **dritte Beleg** zu
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (Belege bisher `slice-java-skelett`
  und `slice-python-skelett`): die Schwelle 3 ist erreicht, und die Closure ist Lese-Schritt mit
  Ausgang verkörpert, geplant oder gestrichen. Ob ein Change Request an
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) oder ein Digest-Pin im
  Skelett die Antwort ist, entscheidet nicht dieser Slice.
- `DOTNET_TAG` oder ein anderer Variablen-Name des Fragments kollidiert im gemischten Root mit dem
  Fragment einer anderen Sprache
  (`BEO-ALL/gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel`, 1×) —
  **Ausgang:** bei der Closure; Namen gegen die Fragmente der anderen Sprachen gelesen.
- Der Test-Code des Skeletts wird von `dupl` als Klon des Kotlin-/Java-/Python-Testcodes gemeldet
  (`BEO-ALL/dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette`, 1×) —
  **Ausgang:** bei der Closure; gemeinsamer Helfer von Anfang an (§3).
- Die Text-Wächter der Bindungen halten nur den Text der emittierten Config, nicht die Wirkung am
  Ziel (ADR: nur am Probe-Gerüst gemessen) — **Ausgang:** bei der Closure; Lauf-Zahn im Ziel ist
  Teil des ersten Liefer-Punkts (§2).
- Der Restore braucht beim `docker build` des Ziels Netz und ein Paket ist ungepinnt transitiv
  (ADR, akzeptiertes Negativ): zwei Bauten desselben Tags können sich unterscheiden —
  **Ausgang:** weiter offen — Register, mit der Reproduzierbarkeits-Beobachtung oben.

## 7. Closure-Notiz

- **Was hat funktioniert:** Das Muster aus Kotlin, Java und Python trug C# ohne Umbau; die Stufe fährt je Ziel
  `test`, `lint` und `build`, den Guard (`dotnet build` geblockt), zwei Lauf-Zähne im Ziel (`IDE0005` an einem
  unbenutzten `using`, `CA1822` an einer nicht-statischen Methode ohne Instanzzugriff, Fälle 716 und 717, je rot und
  nach Rücknahme grün) und zwei Exit-2-Fälle (`--arch hexslice`, `SKEL_CSHARP_VERSION=latest`). Der Lauf-Zahn im Ziel
  in derselben Lieferung wie der Text-Wächter (Lehre aus Python) hielt: der Text-Wächter allein hätte beide Verstöße
  nicht gesehen. Der gemeinsame Test-Helfer von Anfang an ersparte den `dupl`-Befund, `DOTNET_TAG` kollidierte nicht.
- **Was ging anders als geplant:** Nicht in §3 geführt, geliefert: der Sprachlisten-Nachzug in `README.md`
  (öffentlicher Vertrag, [`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 7); der gemeinsame Code `versionValidators()`,
  `InvalidVersionError` und die Erweiterung von `callExitCode` — die erste sprachübergreifende Validierung des
  Versions-Knopfs, die `add-lang` und Bootstrap teilen (Review (a)); Listen-Nachzüge in
  `internal/gen/archgate_test.go` und `cmd/ai-harness-init/kennungen_test.go`; 19 Mutations-Fälle (700 bis 718) statt
  der Mindestliste aus dem Plan. Review INFO-4 und Verifier bestätigen die Zulässigkeit der README-Zeile.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** Kommando `make full-smoke-host`, macOS/arm64
  (Colima), `make -j`, Variante Mono-Repo mit `add-lang` go, cpp, kotlin, java, python (+ csharp). Implementer
  (Handoff, je zwei Läufe je Stand): Vorher 201 s und 218 s, Nachher 181 s und 205 s, Stufe 9 s, 13 s und 14 s; die Lage
  der Handoff-Läufe (Image warm oder kalt) nennt der Handoff nicht. Verifier (ein Lauf je Stand, warm — Image
  `mcr.microsoft.com/dotnet/sdk:10.0.402` und Layer lagen lokal, kein Pull): `C#-Stufe dauerte 10s`. Die Gesamtdauer
  sank trotz der neuen Stufe; die Streuung der Gesamtdauer (bis rund 25 s, unveränderte Nachbarstufen 10 s bis 17 s)
  übersteigt den Zuwachs, belastbar ist allein die Stufenzeit von 9 s bis 14 s. **Ungemessen:** kalter Cache,
  Image-Pull, NuGet-Restore (328 MB Paket-Cache laut ADR); keine Aussage über andere Varianten.
- **Benannte Grenzen (Review INFO-2, Verifier V-3):** `IDE0130 = error` und `TreatWarningsAsErrors` haben nur den
  Text-Wächter, keinen Lauf-Zahn im Ziel; die Abdeckungs-Zeile nennt die Lücke am selben Ort. Der Restore braucht beim
  `docker build` des Ziels Netz, und ein Paket ist transitiv ungepinnt; kein Lauf vergleicht zwei Bauten desselben
  Tags. Pins (Image, xunit) hält kein Wächter gegen die Registry.
- **Verifier V-1 (MEDIUM, Prozess):** Der Plan verlangte die Messzahl im Lieferstand; Commit-Messages und Baum trugen
  keine, die Zahlen standen nur im Handoff. Sie steht jetzt in dieser Notiz, abgeglichen gegen die Messreihe des
  Verifiers (kein Widerspruch: 10 s liegt in 9 s bis 14 s). Dritte Wiederholung nach Java und Python; V-2 und V-3 (INFO)
  sind oben als Ungemessenes und benannte Grenze geführt. Die Verifier-Anregung, die README-Zeile in die Vorlage
  §3 aufzunehmen, ist eine Vorlagen-Schärfung und nicht dieser Slice.
- **Steering-Loop-Eintrag:** benannte Spec-Lücke [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit):
  die Messmethode (*zwei Läufe mit gleichem Tag erzeugen identische Ausgabe*) erfüllt kein Sprach-Skelett, das ein Image
  per Tag pinnt und im Ziel Pakete per Netz holt. Auslöser:
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (`slice-java-skelett`, `slice-python-skelett`,
  `slice-csharp-skelett` — 3×; das C++-Vorkommen bleibt benannt, nicht gezählt). Lese-Schritt: Ausgang *geplant*, auf
  Entscheidung des Nutzers vom 2026-10-18 — ein Change Request an [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), vorbereitet von
  `slice-lh-qa-02-messmethode-bekommt-ihren-change-request`; ein Digest-Pin im Skelett ist verworfen. Zweiter Eintrag,
  gezählt, nicht verkörpert: die Messzahl der DoD fehlt bei der Übergabe im Baum (`slice-java-skelett`,
  `slice-python-skelett`, `slice-csharp-skelett` — 3×, neu angelegt als
  `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum`, Ausgang *geplant*:
  `slice-messzahl-der-dod-liegt-im-lieferstand`); [`MR-089`](../../../../harness/conventions.md#mr-089) trägt die Form der Aussage, nicht den Ort der Zahl.
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-csharp-skelett.md`:
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (3×, Ausgang *geplant*),
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (7×, verkörpert); neu angelegt:
  `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` (3×, je ein Beleg aus Java, Python und C#; Ausgang
  *geplant*) und `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (1×; Java und Python tragen die
  Klasse als benannte Grenze ohne Register-Beleg und sind nicht nachgezählt). Kein Beleg für
  `BEO-ALL/gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel` (Test und Fall 707, Namen gegen die
  Fragmente der anderen Sprachen gelesen) und `BEO-ALL/dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette`
  (gemeinsame Helfer von Anfang an): es gab kein Auftreten.
- **Folge-Slices:** `slice-csharp-hexslice-layout` — ist eine Datei in `open/`;
  `slice-lh-qa-02-messmethode-bekommt-ihren-change-request` — ist eine Datei in `open/`;
  `slice-messzahl-der-dod-liegt-im-lieferstand` — ist eine Datei in `open/`
- **Paarungen (nach dem Move):** Anker-Paarung: kein Eintrag trägt das Feld `liegt in`, nichts zu paaren.
  Folge-Slice-Paarung: `slice-csharp-hexslice-layout`, `slice-lh-qa-02-messmethode-bekommt-ihren-change-request` und
  `slice-messzahl-der-dod-liegt-im-lieferstand` sind Dateien in `open/`. Register-Paarung: jede genannte Beobachtung
  existiert mit nicht leerem `evidence/`; `make register-ausgang` 0 Befund(e).
- **Risiken aus §6:** Risiko 1 (Laufzeit) weiter offen (Register, kalter Wert; die Zahl selbst steht oben),
  Risiko 2 (Messmethode) weiter offen (Register, Ausgang *geplant*), Risiko 3 (`DOTNET_TAG`-Kollision) entfallen
  (Test und Fall 707, kein Auftreten), Risiko 4 (`dupl`) entfallen (gemeinsamer Helfer von Anfang an), Risiko 5
  (Text-Wächter) weiter offen (Register; `IDE0005` und `CA1822` sind durch die Lauf-Zähne 716 und 717 gedeckt,
  `IDE0130` und `TreatWarningsAsErrors` nicht), Risiko 6 (Restore, transitive Pakete) weiter offen (Register, mit
  Risiko 2) — je einmal in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-18):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der C#-Pin steht unter diesem Regime ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 6, verkörpert ([`MR-089`](../../../../harness/conventions.md#mr-089)) ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die neue Stufe erbt es ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — 2, offen; trifft das C#-Image gleich, der
dritte Beleg erreicht die Schwelle 3 (Lese-Schritt der Closure) ·
`gleichnamige-make-variable-zweier-sprach-fragmente-im-selben-ziel` — 1, offen; `DOTNET_TAG` ist daran
zu prüfen (zweiter Beleg bei einem Fund) ·
`dupl-meldet-aehnlichen-testcode-zweier-sprach-skelette` — 1, offen; gemeinsamer Helfer von Anfang an ·
`emittiertes-lint-rezept-uebergibt-die-go-version-nicht` — 1, offen; das C#-Lint-Rezept ist daran zu
prüfen ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; der
Slice fährt den Mono-Repo-Pfad, nicht den gemischten Root; ein Fund dort wäre der zweite Beleg ·
`handbuch-sprachbaum-ohne-sensor-in-full-smoke` — 1, offen; das Handbuch ist Release-Schnitt, der
Slice berührt den Baum nicht.

**Modus:** alle berührten Sub-Areas GF.
