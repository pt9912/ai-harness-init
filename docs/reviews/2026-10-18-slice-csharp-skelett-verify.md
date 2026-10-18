# Verifikation slice-csharp-skelett — DoD und ADR-0096 gegen `fbdbc6ce..d1fd72fc`

* Rolle: Verifier (Modul 11), frischer Kontext. Frage: Bauen wir es richtig — gegen Plan, DoD und ADR-0096.
* Gegenstand: `docs/plan/planning/in-progress/slice-csharp-skelett.md`; Implementer-Commits `535e7392`,
  `63c08d0a`, `8f12f0a0`, `d1fd72fc`; Review-Report `docs/reviews/2026-10-18-slice-csharp-skelett.md`
  (Commit `02e35096`).
* Ergebnis: **alle prüfbaren DoD-Punkte bestätigt, kein Befund über LOW.** Die zwei Closure-Punkte der
  Laufzeit-Messzahl (Handoff) und die offenen Closure-Pflichten des Planners stehen unten. Den Slice
  schließt der Planner (`AGENTS.md` §3.10).

## Was der Reviewer real gefahren hat, und was ich nachgetragen habe

Der Report führt: `make mutate-greift` (704/704), serielle Läufe 700–715, 716/717/718 mit
`SMOKE_ARTIFACT_TARGET=artifact-host` rot aus dem behaupteten Grund, `t.Skip`-Gegenprobe für 700–715,
Stichproben Java 675/677 und Python 686/690, `make gates`. Nicht gefahren hat er: den Bootstrap-Pfad
`--lang csharp` (INFO-3, nur gelesen), die Laufzeit-Zahlen (INFO-1). Von mir selbst gefahren, einzeln und
seriell, mit gelesener Meldung:

| Fall | Kommando | Ausgabe (Auszug) |
|---|---|---|
| 716 `IDE0005` an der realen Quelle `internal/gen/csharp.go` | `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=716-csharp-lint-zahn-ide0005-im-ziel make mutate` | `mutate: ok 716-… -> full-smoke: FEHLER — das C#-Lint bleibt bei einem unbenutzten using gruen rot`, `1 ok, 0 Befund(e)`, rc=0 |
| 717 `CA1822`/`AnalysisLevel` | dasselbe mit `717-csharp-build-zahn-ca1822-im-ziel` | `mutate: ok 717-… -> full-smoke: FEHLER — der C#-Build bleibt bei einer nicht-statischen Methode ohne Instanzzugriff gruen rot`, rc=0 |
| 709 Versions-Prüfung ausgeschaltet | `MUTATE_JOBS=1 MUTATE_CASES=709-csharp-tag-ohne-abbruch make mutate` | `ok … -> TestGenerateCsharp_TagOhneMajorMinorBrichtAb rot`, `1 ok, 0 Befund(e)` |
| 710 Exit-Klasse | dasselbe mit `710-csharp-exit-klasse` | `ok … -> TestRun_AddLangCsharpTagOhneMajorMinorIstExit2 rot`, `1 ok, 0 Befund(e)` |

Die Meldung der Lauf-Zähne nennt die behauptete Ursache: die Stufe prüft nach dem Rot den Fundort
(`src/App/Program.cs(1,1): error IDE0005` bzw. `error CA1822` an `Program.cs(`), nicht nur den roten Exit
(`full-smoke.sh` Stufe 17 gelesen). Die Quelle der Mutation ist die reale `csharp.go` (Zeile
`dotnet_diagnostic.IDE0005.severity = error` bzw. `<AnalysisLevel>…`), nicht ein injizierter Stellvertreter.
Nach den Läufen: `git status --short` leer.

## Verdikt je DoD-Punkt

### DoD 1 — Renderer `csharp` (flat), Wächter, drei Wächter-Zusagen: **bestätigt**

* Gerüst: `csharp.go` rendert `app.sln` (zwei feste, verschiedene Projekt-GUIDs, Typ-GUID `FAE04EC0-…`),
  beide `.csproj`, `Directory.Build.props`, `.editorconfig`, `Program.cs`, `ProgramTests.cs`, `Dockerfile`;
  Stages `toolchain`/`build`/`test`/`lint` mit den Kommandos der ADR (`dotnet restore` einmal,
  `build|test --no-restore`, `dotnet format --verify-no-changes --no-restore`). Pins `10.0.402`, xunit
  `2.9.3`, `Microsoft.NET.Test.Sdk 17.14.1`, `xunit.runner.visualstudio 3.1.4` gleich ADR-Messungen.
  Konstante `DefaultCsharpVersion`, Make-Variable `DOTNET_TAG` (`TestCsharpCodeGateFragment_EigeneTagVariable`,
  Fall 707), `gen.DefaultVersion("csharp")` im Switch, Knopf `SKEL_CSHARP_VERSION` über `skelVersion`.
* Fragment↔Stages: `TestCsharpCodeGateFragment_TargetsMatchStages`, Fall 700 (Stage-Kopplung) und 715
  (lint ohne `dotnet format`) rot gesehen vom Reviewer, stichprobenweise bestätigt durch `mutate-greift`
  (alle Anker greifen, im Gate-Lauf grün).
* `blockedByLang("csharp")` = `dotnet msbuild nuget csc` (`enforce.go`), Kopplung an `gen.SupportedLangs`
  (Fall 701), Namens-Test `TestBlockedFragment_CsharpTraegtDieNamenDerAdr` hält Wortmenge genau 4 und
  `pip pip3 pipx` nicht darin (Fall 702 msbuild, 703 Boden-Doppelung).
* (a) TFM-Ableitung: `csharpTFM` (`^(\d+)\.(\d+)(?:[.-].*)?$`), Test `TestCsharpTFM_FolgtMajorMinorDesTags`
  und Fall 708 (feste TFM); Abbruch für `latest`/`10`: `versionValidators` in `GenerateArch` vor dem ersten
  Schreiben; Fall 709 und 710 von mir rot gesehen (Tabelle oben). **Am Aufruf, nicht nur im Go-Test:**
  `SKEL_CSHARP_VERSION=latest` und `=10` mit dem frisch gebauten Host-Binär, `ai-harness-init --lang csharp .`
  im leeren Git-Verzeichnis: beide `rc=2`, Meldung `Fehler: ungueltige Toolchain-Version "latest" fuer
  csharp: Major.Minor ist nicht ableitbar …`, das Verzeichnis trägt danach nur `.git` (kein Skelett, kein
  `.harness`, kein Baseline-Fetch). Damit ist INFO-3 (Bootstrap-Pfad) real gefahren, nicht nur gelesen. Der
  `add-lang`-Pfad läuft in der Stufe (`csharptag_rc` = 2, kein `Directory.Build.props`) und war im
  `make full-smoke-host`-Lauf unten grün (rc=0).
* (b) Bindungen: `TestCsharpConfig_TraegtDieGebundenenZeilen` ankert `^dotnet_diagnostic\.IDE0005\.severity =
  error$` im Abschnitt `[*.cs]` und die zwei `props`-Zeilen nach Entfernen der XML-Kommentare; vier Fälle
  711–714 je Zeile, vom Reviewer rot gesehen, alle Anker greifen (`make mutate-greift`).
* (c) Lauf-Zähne im Ziel: 716 und 717 von mir an der realen Quelle rot gesehen (Tabelle). 718 (lint-Stage ohne
  `dotnet format`) vom Reviewer gefahren, nicht von mir wiederholt.

### DoD 2 — `make full-smoke`, Abdeckungs-Sicht, Laufzeit-Zuwachs: **bestätigt, Messzahl liegt mir im Lieferstand nicht vor (siehe Befund V-1)**

* `make full-smoke-host` am Lieferstand `d1fd72fc`: `rc=0`. Stufe 17 belegt je Ziel die Recipe-Zeilen
  (`--target test|lint|build`), `RUN dotnet restore` und `RUN dotnet format --verify-no-changes --no-restore`
  im Protokoll, den Guard (`dotnet build` → `"decision": "block"`), beide Zähne, den grünen Fall nach
  Rücknahme, `--arch hexslice` → Exit 2 ohne `app.sln`, `SKEL_CSHARP_VERSION=latest` → Exit 2 ohne
  `Directory.Build.props`.
* Die `e2e_abdeckung`-Kopfzeile nennt Sprache, Gemessenes und — am selben Ort — das Nicht-Gemessene (hexslice/
  Arch-Gate, IDE0130 und `TreatWarningsAsErrors` am Ziel, Root-Bootstrap mit Gate-Lauf, gemischter Root mit C#,
  Reproduzierbarkeit). Stufenkörper deckt jeden genannten Teil: Gates (Marker), Zähne, Guard, Exit-2-Fälle; die
  Teilmessung ist so geschnitten, dass keine Zusage weiter reicht als der Lauf. Ein Detail: die Kopfzeile sagt
  „Abbruch mit Exit 2 fuer einen SDK-Tag ohne Major.Minor" und die Stufe misst nur den `add-lang`-Aufruf mit
  `latest` (nicht `10`, nicht den Bootstrap-Aufruf) — die Aussage ist nicht breiter als `add-lang`/`latest`
  gelesen, aber nicht auf den Wertebereich der Go-Tests und nicht auf `--lang` ausgedehnt; **kein Befund**,
  weil beide Pfade durch dieselbe Funktion `callExitCode` laufen (Fall 710 bindet beide).
  `docs/user/e2e-abdeckung.md` Zeile 36 trägt dieselbe Zusage (erzeugt, `make e2e-abdeckung`; der
  Byte-Gleichheitsfall läuft in `make gates`).
* Der Plan-Satz „(`--arch hexslice` und Arch-Gate nicht gemessen)" ist erfüllt.
* Laufzeit-Zuwachs, selbst gemessen (ein Lauf je Stand, `make full-smoke-host`, macOS/colima, arm64-Daemon,
  `make -j`, Image-Lage: **warm** — `mcr.microsoft.com/dotnet/sdk:10.0.402` und Layer lagen vor beiden Läufen
  im Daemon, weil vorher vier C#-Mutationsläufe sie gezogen haben; Kaltlauf mit Image-Pull und NuGet-Restore
  **nicht gemessen**):
  * Nachher (HEAD): `full-smoke: C#-Stufe dauerte 10s`; benachbarte Stufen im selben Lauf: Python 8 s,
    Kotlin-hexSlice 17 s, Kotlin-Root 5 s.
  * Vorher (Worktree `fbdbc6ce`): keine C#-Stufe (die Zeile fehlt erwartungsgemäß); Python 11 s,
    Kotlin-hexSlice 10 s, Kotlin-Root 5 s.
  * Tragend ist die Stufenzeit: **warm 10 s** für sechs Sprachen-Gates je C#-Modul. Die Gesamtdauer druckt der
    Lauf nicht; die Streuung benachbarter, unveränderter Stufen (Kotlin-hexSlice 10 s ↔ 17 s) liegt in der
    Größenordnung der Stufenzeit, eine Differenz-Zahl trüge also keinen Zuwachs (wie INFO-1 des Reviews).
  * Zahl im Lieferstand: die Commit-Messages von `535e7392`/`63c08d0a`/`8f12f0a0`/`d1fd72fc` und der Baum
    tragen keine Messzahl; sie steht laut Auftrag im Handoff, das mir nicht vorlag — der Planner prüft dort
    Kommando, Lage und Variante gegen die Tabelle oben. Fehlt sie im Handoff, ist meine Messreihe die einzige
    Quelle für die Closure.

### DoD 3 — Hilfetext nennt `csharp` und `SKEL_CSHARP_VERSION`: **bestätigt**

`main.go` führt beide Stellen (Umgebungs-Liste und `add-lang`-Argumente). Der Test ist der generische in
`main_test.go` (Zeile ~1303: jeder Knopf `SKEL_<LANG>_VERSION` je `gen.SupportedLangs` in der Haupthilfe);
Fall 704 (Knopf-Zeile entfernt) bindet ihn. Der Plan nennt „Test in `main_test.go`"; ein csharp-eigener Test
entstand nicht, der generische deckt ihn — Abweichung ohne Folge.

### DoD 4 — `make gates` grün: **bestätigt**

`make gates` (GNU sed im PATH) → `rc=0`, letzte Zeile `span-check: Traeger vorhanden, span-emit hat einen
Span geschrieben, Ablageort git-ignoriert`. `make comment-claims` → `94 Datei(en) geprueft, 0 Befund(e)`.

### DoD 5 — Review durchgeführt, Report liegt vor: **bestätigt, mit Nachprüfung der LOW-Behebung**

Report `docs/reviews/2026-10-18-slice-csharp-skelett.md` liegt vor (Rolle Reviewer, Commit `02e35096`, anderer
Autor-Kontext als der Implementer). Die zwei LOW sind in `d1fd72fc` behoben, am Diff gelesen: `csharpTFM`-
Kommentar steht im Indikativ („liefert *InvalidVersionError und keine TFM; der Aufrufer bricht mit Exit 2 ab
und schreibt kein Artefakt"), der Kopf von `skeleton_helpers_test.go` nennt keine Sprachliste mehr. Der Commit
berührt nur diese zwei Dateien (vier Zeilen). Nicht behoben und nicht Gegenstand: INFO-1…4 (siehe unten).

### DoD 6–9 — Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: **nicht Gegenstand dieser Verifikation**

§7 ist leer (`<!-- Erst bei der Closure füllen. -->`) und die Häkchen stehen offen: korrekt, das ist
Planner-Arbeit (§3.10). Der Implementer hat §7, DoD und Register nicht angefasst
(`git diff --name-only fbdbc6ce..HEAD` nennt unter `docs/plan/planning/` nichts).

## Prüfung gegen ADR-0096

| Festlegung | Beleg | Verdikt |
|---|---|---|
| 1 Projekt-Form (zwei Projekte, klassische `.sln`, feste GUIDs) | `csharpSolution`, beide `.csproj`; full-smoke prüft die Dateien | bestätigt |
| 2 Image, Pin, TFM (Tag-Pin ohne Digest, Knopf, `DOTNET_TAG`, TFM-Literal, Exit 2) | Konstante, Fälle 706/707/708/709/710, Bootstrap- und `add-lang`-Aufruf Exit 2 | bestätigt |
| 3 Test/Lint/Bindungen (vier Zeilen, `EnforceCodeStyleInBuild`/`GenerateDocumentationFile` nicht im Gerüst) | Text-Wächter, 711–714, Test hält die zwei Fremd-Namen heraus; Lauf-Zähne 716/717 | bestätigt |
| 4 Gate-Targets und Fragment-Form (Root unscoped, Subdir scoped, gemischt) | drei Fassungen, `GATE_CHECKS`-Reihenfolgen wie Python | bestätigt |
| 5 Layouts: im Slice nur `flat`; `hexslice`/`hexagonal` → Exit 2 ohne Artefakt | `langArchs` `{archFlat}`; `TestGenerateArch_CsharpNurFlat`, Fall 705; Bootstrap `--lang csharp --arch hexslice` → `rc=2`, „verfuegbar: flat", kein Artefakt; Stufe: `add-lang … --arch hexslice` Exit 2 | bestätigt |
| 6 Guard `dotnet msbuild nuget csc`, kein `pip pip3 pipx` | `enforce.go`; Namens-Test; Stufe: `dotnet build` wird blockiert | bestätigt |

ADR-Folgepflicht „vier Wächter-Zusagen sind DoD-Punkte" ist erfüllt (TFM-Ableitung + Fehlerfall, vier
Bindungszeilen). Die ADR trennt Text-Wächter und Wirkung im Ziel selbst; die Wirkung am Ziel ist nur für
`IDE0005` und `CA1822` gefahren, für `IDE0130` und `TreatWarningsAsErrors` nicht — der Plan verlangt das auch
nur für die zwei, und die Abdeckungs-Sicht nennt die Lücke am selben Ort.

## Plan-vs-Code in beide Richtungen

* Plan → Code: jede Zeile der Datei-Tabelle §3 hat ihren Diff (`gen.go`, `csharp.go`, `csharp_test.go`,
  `enforce.go`/`enforce_test.go`, `main.go`/`main_test.go`, `full-smoke.sh`, `e2e-abdeckung.md`, Listen in
  `gen_test.go`/`zeilenenden_test.go`, `test/mutations/700–718`). `DOTNET_TAG` kollidiert mit keinem Namen der
  anderen Fragmente (Test + Fall 707).
* Code ohne Plan: `README.md` (Sprachliste und „Was heute noch fehlt", `README.md:42`/`:82`) — öffentlicher
  Vertrag, nicht in §3 geführt; Python hat es ebenso gehalten. Der Inhalt stimmt gegen den Stand (flat only,
  xunit, `dotnet format`). **Bewertung: vertretbar und nach `AGENTS.md` §6 Schritt 7 sogar geboten; kein Befund**,
  der Planner nimmt die Zeile in die §3-Tabelle der Vorlage auf, damit sie nicht zum dritten Mal Beobachtung
  wird. Weiter: `internal/gen/archgate_test.go` (3 Zeilen) und `cmd/ai-harness-init/kennungen_test.go`
  (1 Zeile) — additive Listeneinträge, ebenfalls nicht in §3 genannt, ohne Folge.
* Out-of-Scope eingehalten: kein hexslice-Renderer (`langArchs` nur flat), kein Handbuch (`docs/user/
  benutzerhandbuch.md` nicht im Diff), kein weiteres Sprachprofil, kein Freshness-Werkzeug, keine Entscheidung
  zu `LH-QA-02`.
* Rollen/Commit-Zuschnitt: `git diff --name-only fbdbc6ce..HEAD` berührt keine ADR, kein `AGENTS.md`, keine
  `harness/conventions*`, kein `spec/…` und keine Datei unter `docs/plan/planning/`. Vier Implementer-Commits
  tragen „Rolle Implementer", der Report-Commit „Rolle Reviewer", jeder mit Kennung `LH-FA-04`/`ADR-0096`.
  Keine Lint-Suppression (§3.2), keine Gate-Senkung (§3.5), keine Host-Toolchain im Diff (§3.9).

## Befunde

* **V-1 (MEDIUM, Prozess; wiederkehrend aus Java und Python): Laufzeit-Messzahl nicht im Baum.** Der Plan
  verlangt „die Messzahl liegt im Lieferstand (Handoff) vor". Commit-Messages und Baum tragen keine; ob der
  Handoff sie mit Kommando, Lage und Variante nennt, konnte ich nicht sehen. Meine Messung (oben) ist belegt,
  ersetzt aber den Implementer-Beleg nicht. Aktion: Planner gleicht den Handoff gegen die Tabelle ab.
* **V-2 (INFO): Kaltlauf ungemessen.** Beide Stände liefen warm; der erste `docker build` im frischen Ziel
  (Image-Pull, NuGet-Restore, 328 MB Paket-Cache laut ADR) liegt erwartbar darüber. Für die MR-089-Form der
  Closure: „warm, `full-smoke-host`, colima/arm64, `make -j`, 10 s Stufenzeit".
* **V-3 (INFO): Wirkung für `IDE0130` und `TreatWarningsAsErrors` am Ziel ungefahren** (Review INFO-2); am
  selben Ort deklariert, kein Verstoß. Ein Zahn je Bindung wäre ein eigener Slice.
* **V-4 (INFO): INFO-3 des Reviews (Bootstrap-Pfad) ist hiermit gefahren**, kein Rest.
* Zum Rot-Beleg für `711–714` und `718`: nicht von mir wiederholt, der Reviewer hat sie einzeln gefahren und
  `make mutate-greift` bestätigt den Anker gegen den realen Quelltext; Stichproben 709/710/716/717 eigen.
  Die Gegenprobe des Reviewers (11 von 16 Go-Fällen: der benannte Test bindet allein, 5 teilen sich die Stelle)
  übernehme ich ohne eigene Wiederholung.

## Für Closure und Register (Planner)

* Zähler-Folge: dritter Beleg zu `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` ist der Slice
  selbst (Schwelle 3, Lese-Schritt mit Ausgang bei der Closure); das Image-Muster misst die Reproduzierbarkeit
  weiter nicht (kein Lauf vergleicht zwei Bauten desselben Tags).
* Kein Fall von `gleichnamige-make-variable-…` (Test + Fall 707, Namen gegen die anderen Fragmente gelesen).
* Kein Fall von `dupl` (gemeinsame Helfer von Anfang an, `make lint` im Gate-Lauf grün).
* Handbuch bleibt Release-Schnitt; README-Zeile in die §3-Vorlage aufnehmen.

## Sensoren dieses Laufs

* `make mutate` einzeln: 716, 717 (`SMOKE_ARTIFACT_TARGET=artifact-host`), 709, 710 — alle `ok`.
* `make full-smoke-host` am Lieferstand und (Worktree `fbdbc6ce`, danach `git worktree remove --force`)
  am Vorstand — beide rc=0.
* `make host-bin`, danach Bootstrap-Aufrufe mit `SKEL_CSHARP_VERSION=latest|10` und `--arch hexslice` → je rc=2.
* `make gates` → rc=0; `make comment-claims` → 0 Befunde.
* Proben und Logs unter dem gitignorierten `.harness/state/tmp/`, danach gelöscht.

## Empfehlung

Closure freigeben, sobald der Planner (1) die Laufzeit-Messzahl aus dem Handoff gegen die Tabelle abgleicht
(V-1) und die MR-089-Angabe (warm, `full-smoke-host`) in §7 aufnimmt, (2) den dritten Beleg der
Reproduzierbarkeits-Beobachtung als Lese-Schritt mit Ausgang schreibt (Ausgang entscheidet nicht dieser Slice),
(3) die weiter offenen Risiken (transitive NuGet-Pakete, Reproduzierbarkeit) ins Register trägt. Keine
Nacharbeit am Code erforderlich.
