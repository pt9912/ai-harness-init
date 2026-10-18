# Slice slice-csharp-skelett: C# als Sprachskelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp` — dritter Slice im Reihenfolge-Vorschlag.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit). Die ADR des Architect (Proposed)
für C# (Toolchain, Pins, Gate-Targets, Arch-Unterstützung) ist die Entscheidungsgrundlage; ihre Kennung
steht hier, sobald sie `Accepted` ist.

**Berührte Spec-Stellen:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); `ARC-009`, `ARC-010` (über die ADR, soweit sie Layout und
Arch-Achse berührt).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang csharp` (Layout `flat`) rendert ein C#-Skelett mit Code-Gate-Fragment und
Guard-Set nach der ADR, das im gebootstrappten Ziel `make gates` grün fährt — ohne Host-.NET.

**Vorbedingung — der Architect schreibt zuerst.** Die ADR des Architect (Proposed) legt fest:
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

- [ ] Renderer `csharp` (Layout `flat`) in `internal/gen/` nach der ADR des Architect: Gerüst
      (`app.sln` mit festen GUIDs, beide `.csproj`, `Directory.Build.props`, `.editorconfig`,
      `Program.cs`, ein xunit-Test), Gate-Stages `test`/`lint`/`build`, Image-Pin
      (`mcr.microsoft.com/dotnet/sdk:10.0.402`, eigene Konstante `DefaultCsharpVersion`, Make-Variable
      `DOTNET_TAG`) mit Knopf `SKEL_CSHARP_VERSION` → `gen.DefaultVersion("csharp")`; Test
      Fragment↔Stages nach dem Muster der Kotlin- und C++-Tests, einmal rot gesehen (Stage entfernt);
      `blockedByLang("csharp")` mit Kopplung an `gen.SupportedLangs`, dazu ein Test auf die Guard-Namen
      der ADR Festlegung 6 (`internal/emit/enforce_test.go`, Muster der Java-Namensprüfung;
      `pip`/`pip3`/`pipx` nicht im Set). **Drei Wächter-Zusagen der ADR, je einmal rot gesehen:**
      (a) die TFM-Ableitung — ein Test hält die gerenderte TFM gegen Major.Minor des Tags, Verfälschen
      färbt rot; (b) die Bindungen — Text-Wächter je Zeile hält in der emittierten `.editorconfig`
      `IDE0005 = error` und `IDE0130 = error` und in `Directory.Build.props` `TreatWarningsAsErrors`,
      jede der drei Zeilen einzeln entfernt färbt rot; (c) der Lauf-Zahn im Ziel in derselben
      Lieferung, denn die Text-Prüfung hält nicht, dass `dotnet format` die Regel am gebootstrappten
      Ziel meldet (Lehre des Python-Lerneintrags): ein Mutations-Fall entfernt die `IDE0005`-Zeile aus
      der Quelle, und der reale `lint`-Lauf der Stufe färbt einen unbenutzten `using` nicht mehr
      ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [ ] `make full-smoke`: `add-lang csharp` ins Mono-Repo, Skelett-Dateien liegen, `make gates` grün mit
      Beleg, dass das C#-Code-Gate lief, und der Guard blockt die Host-Toolchain;
      `e2e_abdeckung`-Kopfzeile nennt die Sprache und eine Teilmessung an derselben Stelle
      (`--arch hexslice` und Arch-Gate nicht gemessen), `docs/user/e2e-abdeckung.md` neu erzeugt;
      Laufzeit-Zuwachs als Vorher/Nachher `make full-smoke-host` (ein Lauf je Stand, Träger: die Zeile
      `C#-Stufe dauerte <n>s` und die Gesamtdauer) mit Image-Lage und Variante
      ([`MR-089`](../../../../harness/conventions.md#mr-089)); **die Messzahl liegt im Lieferstand
      (Handoff) vor, nicht erst in der Closure** — Lehre aus Java und Python, wo der Plan Kommando und
      Träger nannte und die Zahl im Lieferstand trotzdem fehlte.
- [ ] Hilfetext nennt `csharp` und `SKEL_CSHARP_VERSION` (öffentlicher Vertrag), Test in
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

<!-- Erst bei der Closure füllen. -->

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
