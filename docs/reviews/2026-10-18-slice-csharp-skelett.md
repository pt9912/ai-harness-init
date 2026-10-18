# Review slice-csharp-skelett — Diff `fbdbc6ce..8f12f0a0`

* Rolle: Reviewer, frischer Kontext, nach `.harness/skills/reviewer.md` und Modul 10.
* Gegenstand: drei Implementer-Commits (`535e7392` Renderer, `63c08d0a` Mutations-Fälle 700–718,
  `8f12f0a0` full-smoke-Stufe) zu `docs/plan/planning/in-progress/slice-csharp-skelett.md`.
* Geprüft gegen: Plan §1–§3, ADR-0096 (Accepted) und dessen Review, ADR-0094/0095/0088/0060,
  `AGENTS.md` §3.2, 3.5, 3.6, 3.7, 3.9. Nicht gegen die DoD (Verifier).
* Ergebnis: **keine HIGH, keine MEDIUM**, zwei LOW, vier INFO. Kein Finding blockiert.

## Findings

### LOW-1 — Kommentar im Konjunktiv über die verworfene Alternative

* `kategorie`: LOW (Grenzfall; nach strenger Lesart der HIGH-Zeile „Kommentar trägt keine der
  Kommentar-Klassen" eskalierbar — die Entscheidung liegt beim Aufrufer)
* `quelle`: AGENTS.md §3.7
* `pfad`: `internal/gen/csharp.go:36-37` (Hauptfund); verwandt `:150-154`, `:172`
* `befund`: `csharpTFM` sagt „fail-closed: *InvalidVersionError statt einer ungueltigen TFM, die erst
  beim `docker build` des Ziels rot wuerde" — Konjunktiv über die verworfene Alternative statt
  Indikativ über den Zustand. `:150-154` („sonst bleibt eine unbenutzte Variable gruen",
  „sonst faerbt … nicht") und `:172` („ohne die Zeile faerbt …") sind Indikativ und tragen die
  Kopplung (welche Zeile welchen Zahn bindet); sie stehen in derselben Form in Kotlin/Java/Python
  (`python.go:187` „sonst liefe …") und wurden dort nicht beanstandet.
* `verifizierbar`: nein (kein Gate fängt es; `make comment-claims` → 94 Dateien, 0 Befunde, prüft
  nur die Sensor-Nennung)
* `klasse`: Kommentar beschreibt verworfene Alternative im Konjunktiv

### LOW-2 — Kopfkommentar der gemeinsamen Test-Helfer nennt csharp nicht

* `kategorie`: LOW
* `quelle`: AGENTS.md §3.7 / Maintainability (Doku-Drift)
* `pfad`: `internal/gen/skeleton_helpers_test.go:13`
* `befund`: Der Kopf nennt als Nutzer „(java, python)"; `csharp_test.go` ruft `assertTargetsMatchStages`,
  `assertRootUndSubdir`, `assertTagVariable`, `assertNurFlat`, `generateWith`, `fragmentFassungen`
  daraus auf. Der Plan §3 führt die Helfer als gemeinsam mit „Kotlin/Java/Python" — die Aufzählung
  im Kopf ist damit durch diesen Diff unvollständig geworden. Der Diff fasst die Datei nicht an.
* `verifizierbar`: nein
* `klasse`: Aufzählung im Kommentar driftet gegen die Nutzer-Menge

### INFO-1 — Laufzeit-Messreihe: Differenz trägt keinen Zuwachs, Kaltlage ungemessen

* `kategorie`: INFO (Verweis Verifier, `MR-089`)
* `quelle`: MR-089, Plan §2 DoD 2
* `pfad`: Handoff des Implementers (die Zahlen stehen nicht im Baum, ich habe sie nicht
  nachgemessen — eine Messung ist nicht Aufgabe des Reviewers)
* `befund`: Vorher 201/218 s, Nachher 181/205 s: die Gesamtdauer sinkt trotz neuer Stufe, die Streuung
  zwischen Läufen liegt über der Stufenzeit (9–14 s). Tragend ist damit allein die Zeile
  `C#-Stufe dauerte <n>s`, nicht die Differenz. 9–14 s für `make -j gates` über sechs Sprachen mit
  `docker build` ist nur bei warmem Layer-Cache plausibel; der Kaltlauf (SDK-Image-Pull, NuGet-Restore,
  ADR-0096 Messung 4: 328 MB Paket-Cache im Image) ist nicht gemessen und liegt erwartbar deutlich darüber. Ob die
  Meldung Image-Lage und Variante nennt, sehe ich nicht (steht nicht im Baum).
* `verifizierbar`: nein
* `klasse`: Laufzeit-Zuwachs aus Gesamtdauer-Differenz gelesen

### INFO-2 — Zwei Bindungen ohne Lauf-Zahn im Ziel, korrekt benannt

* `kategorie`: INFO
* `quelle`: ADR-0096 Festlegung 3, AGENTS.md §3.6
* `pfad`: `harness/tools/full-smoke.sh` Stufe 17 (e2e_abdeckung-Kopf), `test/mutations/712`, `713`
* `befund`: `IDE0130 = error` und `TreatWarningsAsErrors` haben nur den Text-Wächter
  (`TestCsharpConfig_TraegtDieGebundenenZeilen`); die Wirkung am gebootstrappten Ziel (falscher Namensraum
  färbt `lint`, `CS0219` färbt `build`) fährt keine Stufe. Der Plan verlangt Lauf-Zähne nur für
  `IDE0005`/`CA1822`, und die Kurzbeschreibung nennt die Lücke am selben Ort („NICHT gemessen: …
  IDE0130 und TreatWarningsAsErrors am Ziel (nur der Text der Config ist gehalten)"). Kein Verstoß,
  festgehalten, weil ADR-0096 beide als Bindungen führt.
* `verifizierbar`: ja (eine Stufe mit `namespace`-Verstoß bzw. unbenutzter Variable)
* `klasse`: Wächter hält Text, Wirkung im Ziel ungefahren (deklariert)

### INFO-3 — Exit-2-Abbildung nur über `add-lang` gefahren

* `kategorie`: INFO
* `quelle`: ADR-0096 Festlegung 2
* `pfad`: `cmd/ai-harness-init/main.go:532` (Bootstrap `--lang`), `main_test.go` `TestRun_AddLangCsharpTagOhneMajorMinorIstExit2`
* `befund`: Beide Aufrufer (`add-lang`, Bootstrap `--lang csharp`) laufen durch `callExitCode`; Test und
  Fall 710 binden nur den `add-lang`-Pfad. Der Bootstrap-Pfad ist gelesen (derselbe Aufruf, vor jedem
  Schreiben und vor dem Baseline-Fetch), nicht gefahren. Mutation 710 trifft die gemeinsame Funktion und
  bindet beide mit.
* `verifizierbar`: ja
* `klasse`: gemeinsame Abbildung, ein Aufrufer ohne eigenen Fall

### INFO-4 — README-Änderung außerhalb des Plan-§3

* `kategorie`: INFO (Verweis Planner)
* `quelle`: Plan §3, `AGENTS.md` §6 Schritt 7
* `pfad`: `README.md:42`, `README.md:82`
* `befund`: Die README-Sprachliste ist öffentlicher Vertrag und nicht in der Datei-Tabelle des Plans
  geführt; der Python-Slice hat sie in `791e9bf4` ebenso nachgezogen. Die Aussage stimmt gegen den
  Stand (flat only, `dotnet format`, xunit). Das Benutzerhandbuch nennt weiter nur go/cpp/kotlin — laut
  Plan §1 Release-Schnitt, kein Gegenstand.
* `verifizierbar`: nein
* `klasse`: Öffentlicher Vertrag berührt, Plan-Tabelle nennt ihn nicht

## Prüfung nach Schwerpunkt

**(a) Gemeinsamer Code (`InvalidVersionError`, `versionValidators`, `callExitCode`).**

* Wirkung auf bestehende Sprachen: `versionValidators()` führt nur `csharp`; für go/cpp/kotlin/java/python
  liefert der Map-Zugriff `ok == false`, die Version bleibt ungeprüft wie zuvor. `GenerateArch` ruft die
  Prüfung erst nach der Arch-Validierung und vor dem ersten Schreiben (`gen.go:84-90`); `profiles()`-Builder
  haben keinen anderen Aufrufer als `GenerateArch` (`grep`), `csharpScaffolding` verwirft den Fehler von
  `csharpTFM` (`tfm, _ :=`) also nie unvalidiert. `callExitCode` hängt nur einen dritten `errors.As`-Zweig an;
  `UnknownLang`/`UnknownArch` unverändert. Bestehende Tests anderer Sprachen: nur additive Listen-Einträge
  (`gen_test.go`, `zeilenenden_test.go`, `archgate_test.go`, `kennungen_test.go`).
* Fall 709/710 einzeln: `make mutate` ok (709 → `TestGenerateCsharp_TagOhneMajorMinorBrichtAb`, 710 →
  `TestRun_AddLangCsharpTagOhneMajorMinorIstExit2`). Gegenprobe mit `t.Skip` ausschließlich im benannten Test,
  Mutation angewandt, `make test-go` in Kopie: **710 wird grün — der Test bindet allein.** 709 bleibt rot durch
  `TestRun_AddLangCsharpTagOhneMajorMinorIstExit2` — dieselbe Quell-Stelle (`versionValidators`-Aufruf) von der
  Exit-Seite aus; der benannte Gen-Test bindet daneben, was der cmd-Test nicht bindet (fünf Werte, Fehlertyp,
  Artefaktfreiheit) → struktureller Nebeneffekt, kein Befund. Der Kopf von 709 behauptet keine Exklusivität.
* Gegenprobe über alle 16 Go-Fälle (700–715), Ausgang je Fall (Skip im benannten Test, Mutation an):
  grün (der benannte Test bindet allein): 703, 704, 706, 707, 708, 710, 711, 712, 713, 714, 715. Mitgefärbt:
  700 (`TestCsharpStages_FuehrenDieKommandosDerAdr` bindet die Stage-Zeile mit), 701 (`…CsharpTraegtDieNamenDerAdr`,
  `TestRun_AddLangCsharp`), 702 (`TestRun_AddLangCsharp` bindet die Namensliste mit), 705
  (`TestRun_AddLangCsharpHexsliceIstExit2`), 709 (s. o.). Jeweils dieselbe Quell-Stelle, anderer Zugang oder
  gemeinsame Senke; die benannten Tests tragen jeweils Eigenes bei (703 zeigt es für den Namens-Test: allein rot;
  700: nur der benannte Test hält die Kopplung Fragment↔Stage in allen drei Fassungen). Keine Fall-Kopf-
  Behauptung von Exklusivität.

**(b) Fälle 700–718 gegen die reale Quelle.**

* `make mutate-greift` → `704 Fall/Faelle, 704 greifen, 0 Befund(e)` (jeder sed-Anker trifft realen Quelltext).
* `make mutate` serieller Lauf (`MUTATE_JOBS=1`) für 700–715: alle 16 `ok`, jeder mit dem benannten Test rot.
  (Ein erster Lauf mit mehreren Workern brach an einer Docker-Image-Race ab — Umgebung, kein Befund am Diff.)
* Fall 710 Endform: Mutation `|| errors.As(err, &ive) && false` kompiliert, Exit 1 statt 2, benannter Test
  rot, aus dem behaupteten Grund; Gegenprobe oben.
* Fälle 716, 717, 718 einzeln und nacheinander mit `SMOKE_ARTIFACT_TARGET=artifact-host`, voller Fallname:
  jeweils `ok`, rot mit der erwarteten `FEHLER`-Meldung (716: Lint bleibt bei unbenutztem `using` grün; 717:
  Build bleibt bei CA1822-Fall grün; 718: `make gates` ohne Beleg-Marker). Die Zähne laufen am echten
  `dotnet format`/`dotnet build` im gebootstrappten Ziel, nicht an einer Fixture; die Quelle der Mutation ist
  die reale `csharp.go`. Kein Rest im Baum (`git status` sauber).
* Grenz-Sonde (Teilzeichenkette): Namens-Tests prüfen `strings.Fields` als Wortmenge (kein `dotnet` in
  `dotnet-format`-Verwechslung); Stage-Prüfungen tragen `\n` vor und nach; Config-Prüfungen ankern
  `^…$` im Abschnitt `[*.cs]` und entfernen XML-/`#`-Kommentare vorher. Nicht gefahren: Tags `10.0x` und mit
  Zeilenumbruch gegen `csharpTagForm` (gelesen: `[.-]` ist Pflicht-Trenner, `.` matcht kein `\n`).

**(c) Skelett gegen ADR-0096.** Pins SDK `10.0.402`, xunit `2.9.3`, `Microsoft.NET.Test.Sdk 17.14.1`,
`xunit.runner.visualstudio 3.1.4` gleich den ADR-Messungen 2/7. `Directory.Build.props`: TFM-Literal aus
`csharpTFM`, `Nullable enable`, `ImplicitUsings disable`, `TreatWarningsAsErrors true`, `AnalysisLevel
latest-recommended`; weder `EnforceCodeStyleInBuild` noch `GenerateDocumentationFile` (Test hält es).
`.editorconfig`: `IDE0005`/`IDE0130` = error im Abschnitt `[*.cs]`. Stages `toolchain`/`build`/`test`/`lint`
mit den Kommandos der ADR; klassische `app.sln` mit zwei verschiedenen festen GUIDs und Typ-GUID
`FAE04EC0-…`; `langArchs` nur `flat`; `blockedByLang("csharp")` = `dotnet msbuild nuget csc`, der Boden der
Guard-Datei (`BLOCKED=` Zeile 46) trägt keinen dieser Namen und das Fragment keinen der Bodennamen
(`pip pip3 pipx` nicht gedoppelt, Test + Fall 703). `--arch hexslice`/`hexagonal` → `UnknownArchError`, Exit 2,
kein Artefakt (`TestGenerateArch_CsharpNurFlat`, `TestRun_AddLangCsharpHexsliceIstExit2`, full-smoke).
Fragment-Fassungen (Root, scoped, gemischt) im selben Muster wie Python (`GATE_CHECKS`-Reihenfolgen gleich);
`DOTNET_TAG` kollidiert mit keinem Namen der anderen Fragmente (`TestCsharpCodeGateFragment_EigeneTagVariable`).
Keine Lint-Suppression (3.2), keine Gate-Senkung (3.5), keine Host-Toolchain im Diff (3.9; `dotnet` nur in
Dockerfile-Stages und als String gegen den Guard).

**(d) Test-Helfer.** `csharp_test.go` nutzt die gemeinsamen Helfer; `skeleton_helpers_test.go` ist nicht
verändert; `dupl` läuft im `make lint`-Teil von `make gates` (Ergebnis unten). Bestehende Tests anderer
Sprachen: nur additive Listeneinträge. Stichprobe einzeln nachgefahren: 675 (Java blocked-Kopplung), 677 (Java
Hilfe-Knopf), 686 (Python blocked-Kopplung), 690 (Python hexslice) — alle `ok`, benannter Test rot.

**(e) full-smoke-Stufe und Abdeckungs-Sicht.** Die Kurzbeschreibung (Stufe 17 von 45) nennt Gemessenes
(Gates, beide roten Zähne, grüner Fall nach Rücknahme, Guard, Exit 2 für Tag ohne Major.Minor) und
Nicht-Gemessenes (hexslice/Arch-Gate, IDE0130, TreatWarningsAsErrors am Ziel, Root-Bootstrap, gemischter
Root mit C#, Reproduzierbarkeit zweier Bauten) am selben Ort; keine Aussage reicht weiter als der Lauf. Die
Stufe prüft die rote Ursache (`IDE0005` an `Program.cs(1,1)`, `CA1822` an `Program.cs(`), nicht nur den
roten Exit. Die Datei ist per `make e2e-abdeckung` erzeugt (der Byte-Gleichheitsfall läuft in `make gates`).

**(f) README.** s. INFO-4.

**(g) Messreihe.** s. INFO-1.

## Negativbefund (geprüft, ohne Befund)

* Verhalten bestehender Sprachen und gemeinsamer Wächter (a): ohne Befund — Validierung nur für `csharp`.
* Mutations-Fälle 700–718 (b): ohne Befund — jeder Anker greift, jeder Fall rot aus dem behaupteten Grund.
* Skelett-Inhalt, Pins, Guard-Menge, `langArchs` (c): ohne Befund gegen ADR-0096 Festlegungen 1–3, 5, 6.
* Test-Duplikation und Helfer-Nutzung (d): ohne Befund außer LOW-2.
* Abdeckungs-Aussage in Stufe 17 (e): ohne Befund — Teilmessung am selben Ort benannt.
* Hard Rules 3.2, 3.5, 3.9: ohne Befund. 3.6: Gegenbeispiele rot gesehen, auch an der realen Quelle (716–718).
* Superseded ADR: der Plan verweist auf ADR-0096 (Accepted); ohne Befund.
* Ausdrücklich nicht geprüft: Laufzeitzahlen (Handoff, INFO-1), Kaltlauf auf CI, a-check am C#-Layout
  (Gegenstand von `slice-csharp-hexslice-layout`), DoD-Abhakung (Verifier).

## Sensoren

* `make mutate-greift` → 704 greifen, 0 Befunde. `make comment-claims` → 94 Dateien, 0 Befunde.
* `make mutate` (serial) 700–715, 716, 717, 718, 675, 677, 686, 690: alle `ok`.
* `make gates` (GNU sed im PATH): Exit 0, letzte Zeile `span-check`. Ein erster Lauf ohne GNU sed im PATH scheiterte an `mutate-greift` (BSD-sed, Umgebung).

## Konflikt-Pfad

Kein HIGH, kein Rollen-Widerspruch; der Konflikt-Pfad aus Modul 8 greift nicht.
