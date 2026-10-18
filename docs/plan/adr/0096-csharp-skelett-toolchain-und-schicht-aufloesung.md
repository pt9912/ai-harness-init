# ADR-0096: C#-Skelett — Toolchain und Schicht-Auflösung

**Status:** Proposed

**Datum:** 2026-10-18

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0095](0095-python-skelett-toolchain-und-schicht-aufloesung.md) (Vorbild),
[ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md),
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md); Gegenstand von
`slice-csharp-skelett` (Welle `welle-sprachprofile-java-python-csharp`)

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Generator und Verdrahtung für die Sprache `csharp`).

**Verfeinert (nicht supersedet):** [ADR-0095](0095-python-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md) und
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) — Mechanik (Image-Tag-Pin mit Knopf,
Stage-Fragment, `fixed-root`-Auflösung, Union-Guard) gilt unverändert und wird auf C# angewandt;
[ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md)
bleiben unberührt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) führt `csharp` in der
Sprachliste; ein Change Request ist nicht nötig. Offen sind Build-Werkzeug, Image, Test, Lint, Layout-Menge,
Schicht-Auflösung und Guard-Set; die Gerüstung muss arch-invariant bleiben
([ADR-0008](0008-arch-achse-emittiertes-skelett.md)). Der gepinnte a-check
(`grep -n 'DefaultArchImage  =' internal/emit/archgate.go` → `v0.23.2`) kennt `csharp` (Messung 6, Fall 9:
die Fehlermeldung zählt `cpp|csharp|go|java|kotlin|python|rust|typescript` auf). Der Guard-Boden führt
`dotnet`, `msbuild`, `nuget`, `csc` nicht (`grep -n '^BLOCKED=' internal/emit/templates/enforce/pretooluse-command-guard.sh`),
und kein Profil in `blockedByLang()` (`internal/emit/enforce.go`: go, cpp, kotlin, java, python) nennt sie.
Eigen bei C#: Namensraum und Verzeichnis sind nicht gekoppelt (anders als Paket gleich Verzeichnis bei
Kotlin, Java, Python); das trägt Festlegung 5.

## Entscheidung

Wir wählen **ein .NET-Gerüst aus zwei Projekten (`App`, `App.Tests`) in einer klassischen `.sln`, die
`dotnet`-CLI im SDK-Image als einziges Werkzeug (Restore, Build, Test, `dotnet format`), die TFM aus dem
Image-Tag abgeleitet, Layouts `flat` und `hexslice` (bedingt)**. Werkzeug- und Versionswahl, bei der mehrere
Optionen gleichwertig tragen, ist **noch nicht** vom Auftraggeber entschieden (Abschnitt „Offene
Entscheidungen des Auftraggebers“); die Festlegungen 2 und 3 nennen dort jeweils die Empfehlung und tragen sie
bedingt. Projekt-Form, TFM-Ableitung, Gate-Form, Layout-Menge und Namensraum-Regel (Festlegungen 1, 4, 5)
sind Linie des Architect.

**1. Projekt-Form.** `src/App/App.csproj` (`OutputType Exe`, `Program.cs`) und
`tests/App.Tests/App.Tests.csproj` (Test, `ProjectReference` auf `App`), dazu `app.sln` im klassischen Format
(gemessen mit `dotnet new sln --format sln` und `dotnet sln add`; der Generator trägt es als statischen Text
mit festen GUIDs). `Directory.Build.props` am Root trägt die gemeinsamen Eigenschaften
(`Nullable enable`, `ImplicitUsings disable`, `TreatWarningsAsErrors true`,
`AnalysisLevel latest-recommended`, TFM — Festlegung 2), `.editorconfig` die Analyzer-Schweregrade
(Festlegung 3). Schichten sind Verzeichnisse und Namensräume im Projekt `App`, **kein** Projekt je Schicht
(Alternative D). Das klassische `.sln` statt `.slnx`, weil der Image-Knopf auch ältere SDKs wählen darf;
`.slnx` ist nicht gemessen. Netz beim `docker build` des Ziels für den Restore, wie
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2 und kein Host-.NET
([`AGENTS.md`](../../../AGENTS.md) §3.9); Messung 4 zeigt, wo das Netz gebraucht wird.

**2. Image, Pin, TFM.** Image `mcr.microsoft.com/dotnet/sdk:<tag>`, per **Tag** gepinnt (kein Digest im
Gerüst, damit der Knopf wirkt — dieselbe Form wie Kotlin, Java, Python), Knopf `SKEL_CSHARP_VERSION` →
`gen.DefaultVersion("csharp")` mit eigener Konstante `DefaultCsharpVersion`; Make-Variable `DOTNET_TAG`
(Treffer von `grep -rn 'DOTNET' Makefile harness d-check.mk .d-check.yml internal` vor dieser ADR: keiner;
keine Kollision mit `GRADLE_TAG`, `JAVA_GRADLE_TAG`, `PYTHON_TAG`). **Empfehlung (offen, Frage 1):
`10.0.402`**; die Messung zeigt den Tag mit Digest, linux/amd64 und linux/arm64, und das Gerüst grün (Messung
1, 2, 8). Die **TFM wird vom Generator aus Major.Minor des Tags abgeleitet** (`10.0.402` → `net10.0`) und als
Literal in `Directory.Build.props` geschrieben: der Ausdruck `net$(NETCoreAppMaximumVersion)` ist dort leer und
färbt Restore und Build rot (Messung 2, Lauf 0); eine feste TFM gegen ein anderes SDK scheitert mit
`NETSDK1045` (Messung 2, Lauf 3). **Wächter-Zusage:** `slice-csharp-skelett` trägt als DoD-Punkt einen Test,
der die gerenderte TFM gegen Major.Minor des Tags hält und beim Verfälschen rot wird; Zusage, nicht gefahren.
Das Image ist die Ubuntu-Variante des Tags (`10.0.402-noble` trägt am Messtag denselben Digest); eine
Alpine-Variante ist nicht gemessen (der Tag `10.0.402-alpine` existiert nicht).

**3. Test und Lint.** `test`/`lint`/`build` sind Dockerfile-Stages, gekoppelt an das Code-Gate-Fragment;
drei Targets, **kein viertes**, damit die Präzedenz-Erweiterung des gemischten Roots unverändert greift.
`build` = `dotnet build --no-restore -c Release`, `test` = `dotnet test --no-restore`, `lint` =
`dotnet format --verify-no-changes --no-restore`; der Restore läuft einmal in der `toolchain`-Stage.
**Test-Framework — Empfehlung (offen, Frage 2): xunit 2.9.3** mit `Microsoft.NET.Test.Sdk 17.14.1` und
`xunit.runner.visualstudio 3.1.4` (die Vorgaben der SDK-Vorlage; Messung 2 zeigt die aufgelöste Menge,
Messung 7 NUnit und MSTest). **Lint-Form — Empfehlung (offen, Frage 3):** die im SDK enthaltenen Analyzer
plus `dotnet format` über `.editorconfig`, kein NuGet-Analyzer. **Welche Regel welchen Zahn färbt, ist
gemessen (Messung 2/3):** ein unbenutztes `using` → `IDE0005` in `lint` (`dotnet format`, Exit 2), nicht in
`build`; eine unbenutzte Variable → `CS0219` in `build` (Exit 1), nicht in `lint`; ein Format-Verstoß →
`lint`; Nullable-Fehler `CS8602`, unbenutztes privates Feld `CS0414`, Syntaxfehler → `build`; falsche
Assertion → `test`. **Gebunden** sind drei Dinge, weil ohne sie die jeweilige Zeile ungeprüft bliebe statt zu
brechen: `dotnet_diagnostic.IDE0005.severity = error` in `.editorconfig` (ohne die Zeile bleibt der unbenutzte
`using` in `lint` **und** `build` grün — Messung 3, A1), `TreatWarningsAsErrors true` (ohne es bleibt die
unbenutzte Variable grün — A5) und `dotnet_diagnostic.IDE0130.severity = error` (Festlegung 5; ohne die Zeile
färbt ein falscher Namensraum nichts — Messung 5, I1). `EnforceCodeStyleInBuild` und
`GenerateDocumentationFile` sind **nicht** gebunden und stehen nicht im Gerüst: `lint` meldet `IDE0005` ohne
sie (A2); im Build verlangt `IDE0005` sie (A4 bricht ohne `GenerateDocumentationFile` mit einem Hinweis ab),
und die Dokumentationsdatei wäre Gerüst-Ballast. **Wächter-Zusage:**
`slice-csharp-skelett` trägt als DoD-Punkt einen Test oder Mutationsfall, der in der emittierten
`.editorconfig` die zwei `severity = error`-Zeilen und in `Directory.Build.props` `TreatWarningsAsErrors` hält
und beim Entfernen rot wird; Zusage, nicht gefahren. **Was diese Text-Prüfung nicht hält:** dass `dotnet
format` die Regel im emittierten Ziel auch meldet (Wirkung, nur am Probe-Gerüst gemessen); dass die Stage-Form
läuft (Messung 2 fuhr die Kommandos in einem Container-Lauf, nicht als `docker build --target`-Stages).
Ein dritter Weg (StyleCop, Roslynator, SonarAnalyzer) braucht eine Folge-ADR.

**4. Gate-Targets und Fragment-Form.** `harness/mk/<modul>.mk` wie bei Python: Root unscoped
(`docker build .`), Subdir modul-scoped (`test-<modul>` …, `docker build <pfad>`), gemischter Root mit
Präzedenz-Erweiterung ohne eigenes Rezept; `GATE_CHECKS += lint build test`; das `docker build` reicht
`--build-arg DOTNET_TAG=$(DOTNET_TAG)` durch. Kein neues Muster.

**5. Layouts und Schicht-Auflösung.** Diese ADR legt für `csharp` die Layouts `flat` und `hexslice` fest,
`hexslice` unter den Bedingungen unten; `hexagonal` legt sie nicht fest (Trigger 3). Welcher Slice `hexslice`
liefert, ist Zuschnitt des Planner (Layout-Slice); die Festlegung gilt unabhängig davon. Ein Layout steht in
`langArchs()` nur, wenn sein Renderer es rendert, sonst gibt `add-lang csharp … --arch hexslice` Exit 2;
`flat` trägt kein Arch-Gate ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
a-check-Auflösung: `languages: csharp: ["**/*.cs"]`, `exclude: ["tests/**"]`,
`resolution: csharp: {mode: fixed-root, roots: ["src/App"], package_base: "App"}`; ohne den Block oder mit
Root `src` löst kein `using` auf (Messung 6, Fälle 2, 3). Gemessen erkannt: `using Ns;`, `using static`,
`using Alias = …`, `global using`, `using` innerhalb eines block-scoped `namespace` (Fälle 1, 4, 5, 6, 12) und
die erlaubte Kante (Fall 11 grün). **Namensraum ≠ Verzeichnis** — die C#-Eigenheit: a-check bildet den
Import-Namensraum auf einen Pfad ab, nicht auf die Deklaration; ein Namensraum, der keinem Verzeichnis folgt,
löst nicht auf und färbt nichts (Fall 10: `0 Befund(e)`, Hinweis „0 von 1 Import-Symbolen"). Das Skelett
schließt das mit zwei **Skelett-Pflichten**: (a) Namensraum = Verzeichnispfad ab `App`, durchgesetzt über
`IDE0130` in `lint` (Messung 5, I3 rot, I2 grün); (b) die Verzeichnisse in **PascalCase**
(`Adapters/Driven`, `Hexagon/Domain`), weil a-check Groß-/Kleinschreibung unterscheidet (Fall 8: Verzeichnisse
klein, Namensraum PascalCase → `0 Befund(e)`). **Lücke zu (b):** `IDE0130` unterscheidet sie **nicht**
(Messung 5, I4/I5 grün), kein Sensor dieser ADR hält die Schreibweise; ein Adopter, der Verzeichnisse
kleinschreibt, bekommt ein stilles Grün im Arch-Gate. Der Layout-Slice trägt dafür mindestens einen Test, der
die gerenderten Verzeichnis-Globs der `.a-check.yml` gegen die gerenderten Pfade hält — der erfasst den
Renderer, nicht den Adopter. Pfade nach [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
in PascalCase: `src/App/Hexagon/{Domain,Application}/…`, `src/App/Adapters/{Driving,Driven}/…`, Composition
Root `src/App/Program.cs`; Ports-Ordner und Kanten-Menge entscheidet der Layout-Slice nach dem Kotlin-Muster
(nicht gemessen: die Kante `driven_adapters → ports_outbound` am C#-Fall, nur die Kante `driven_adapters →
domain`, Fall 11). **Nicht erkannt** (Grenzen von a-check am Pin bzw. des Glob-Prüfbereichs, vom Skelett nicht
schließbar): ein voll qualifizierter Name im Code ohne `using` (Fall 7: `0 Befund(e)`); ein `<Using
Include=…>` im `.csproj` (liegt außerhalb des Glob `**/*.cs`; aus dem Glob abgeleitet, nicht gefahren);
Reflection (nicht gefahren).

**6. Guard.** `blockedByLang("csharp")`: Mindestmenge `dotnet`, die Toolchain des Gerüsts. **Empfehlung
(offen, Frage 4): `dotnet msbuild nuget csc`.** Keine Überschneidung mit dem Boden (`apt apt-get brew pip pip3
pipx npm pnpm yarn npx corepack cargo rustup gem conda`) und keinem der fünf Profile, am Skript und an
`blockedByLang()` gelesen; die Union ist die eine Quelle. `msbuild`/`nuget`/`csc` stehen in der Empfehlung,
obwohl das Gerüst sie nicht nutzt: der Guard blockt Host-Aufrufe, nicht nur die genutzte Toolchain, und sie
sind der naheliegende Host-Umweg — dieselbe Linie wie `mvn` neben Gradle
([ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md)); ob der Auftraggeber sie teilt, ist die
Frage. **Grenze (Stolperdraht, keine Sandbox):** der Guard vergleicht den Befehlskopf eines Segments als
exaktes Wort (`in_set` im Guard-Skript), nach Abzug des Pfad-Präfix. `/usr/share/dotnet/dotnet` blockt über
den Kopf `dotnet`; `dotnet-format` (ein eigener Name), ein Wrapper-Skript und `mono` stehen nicht im Set und
blocken nicht. Am Skript gelesen, nicht gefahren; die Block-Probe gehört in den Review. Die Kopplung an
`gen.SupportedLangs` hält der bestehende Test.

## Offene Entscheidungen des Auftraggebers

Nicht entschieden; die Festlegungen oben tragen die Empfehlung nur bedingt.

1. **SDK-Version / LTS.** Empfehlung `10.0.402` (die LTS-Linie 10; Messung 1, 2, 8). Alternative `8.0.426`:
   Basislauf grün (Messung 2, Lauf 2); `9.0` ist nur als Digest gemessen, nicht gebaut. Ob eine Linie LTS ist
   und bis wann sie gepflegt wird, ist **nicht gemessen** (Microsoft-Support-Policy nicht gelesen). Hängt
   daran: Default der Konstante, TFM des Gerüsts, Digest-Zeile der Messung.
2. **Test-Framework.** Empfehlung xunit 2.9.3. NUnit 4.3.2 und MSTest 4.0.2 laufen grün (Messung 7); xunit v3
   ist nicht gemessen (kein Template im SDK). Hängt daran: die drei Paket-Pins der Festlegung 3 und der Test.
3. **Lint-Form.** Empfehlung SDK-Analyzer plus `dotnet format` (Festlegung 3). Alternative: ein NuGet-Analyzer
   (StyleCop/Roslynator) — nicht gemessen, bräuchte Folge-ADR. Hängt daran: Festlegung 3 und die Bindungen.
4. **Guard-Umfang.** Empfehlung `dotnet msbuild nuget csc`; Minimum `dotnet`. Hängt daran: Festlegung 6 und
   der Test auf die Namen.
5. **[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).** Nicht entschieden und hier nicht beantwortet; die Lage steht im Abschnitt darunter.

Nicht vom Auftraggeber zu entscheiden, sondern Linie des Architect: Projekt-Form, TFM-Ableitung, Gate- und
Fragment-Form, Layout-Menge `flat` + `hexslice` (bedingt), Namensraum-Regel.

## Lage für die Reproduzierbarkeit (Messbasis, keine Entscheidung)

[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) misst Reproduzierbarkeit als Vergleich
zweier Bauten desselben Tags; kein Lauf vergleicht sie
(`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, Belege `slice-java-skelett`,
`slice-python-skelett`; der dritte Beleg entstünde mit `slice-csharp-skelett` und erreichte die Schwelle 3).
Für C# gilt, ohne dass diese ADR es als Lockerung fasst — es ist die Grenze der Messmethode:

- **Byte-identisch:** die Generator-Ausgabe aller Gerüst-Dateien, auch die TFM-Ableitung (eine Funktion des
  Tags).
- **Gepinnt:** der Image-Tag, die drei Paket-Versionen in der `.csproj` (am Messtag: Digest des Tags
  `10.0.402` = Digest von `10.0` und `10.0.402-noble`, Messung 1). NuGet löst eine angegebene Version als
  Untergrenze auf; die transitiven Pakete der Messung 2 sind die niedrigsten Versionen, die die direkten
  Pakete verlangen. Ein `packages.lock.json` hat das Gerüst nicht; `RestorePackagesWithLockFile` ist nicht
  gemessen.
- **Driftet:** ein vom Registry neu veröffentlichter Tag (über die Zeit nicht gemessen), die Verfügbarkeit des
  NuGet-Feeds, und dass der Restore **beim `docker build` des Ziels Netz braucht** (Messung 4: kalter Cache
  ohne Netz → `NU1301`; warmer Cache im selben Image ohne Netz grün; ein Projekt ohne Pakete baut ohne Netz).
- **Nicht gemessen:** zwei Bauten desselben Tags und ihr Vergleich.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (C# bleibt ungerendert) | kein Aufwand | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt C#; die Welle hätte keinen Gegenstand |
| B — ein Projekt mit Tests darin | keine zweite `.csproj` | nicht gemessen; der Test-SDK erzeugt einen eigenen Einstiegspunkt neben `Main` (erwartet, nicht gefahren) |
| C — `.slnx` statt `.sln` | neues Standardformat des SDK 10 | nicht gemessen unter älteren SDKs; der Knopf soll sie wählen dürfen |
| D — Projekt je Schicht | Compiler erzwingt die Grenze | Gerüstung arch-abhängig → bricht [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) AC *Arch-Achse*, nur mit CR |
| E — TFM als `net$(NETCoreAppMaximumVersion)` | Knopf wirkt ohne Generator-Ableitung | gemessen rot: der Wert ist in `Directory.Build.props` leer (Messung 2, Lauf 0) |
| F — feste TFM `net10.0` | einfach | der Knopf wählt ein SDK, das sie nicht baut: `NETSDK1045` (Messung 2, Lauf 3) |
| G — `EnforceCodeStyleInBuild` + `GenerateDocumentationFile` für `IDE0005` im Build | der Zahn färbt auch `build` | braucht eine erzeugte Dokumentationsdatei (A4); `lint` braucht beides nicht (Messung 3, A2/A3); ob dazu `NoWarn CS1591` nötig wäre, ist nicht gemessen |
| H — NUnit oder MSTest | beide grün (Messung 7) | Auftraggeber-Frage 2 |
| I — NuGet-Analyzer (StyleCop, Roslynator) | strengere Regeln | zusätzliche Pins; nicht gemessen |
| J — zusätzlich `hexagonal` | volle Achse | ohne benannten Bedarf |
| K — `flat` ohne `hexslice` | kein Schreibweisen-Loch (Festlegung 5) | der Layout-Slice hätte keinen Gegenstand; a-check löst C# auf |
| **L — zwei Projekte, `.sln`, `dotnet`-CLI, TFM aus dem Tag, `IDE0005`/`IDE0130` über `.editorconfig`, flat + hexslice** | gleiches Muster wie Python/Java; a-check löst `using` auf; Lint rot/grün gemessen | Schreibweise der Verzeichnisse nur über den Renderer gehalten; ein `<Using>` im `.csproj` und ein voll qualifizierter Name entgehen dem Arch-Gate; Restore braucht Netz |

## Konsequenzen

- Positiv: C# dockt an die sprach-agnostischen Stellen an (Kompositions-Seam, Arch-Gate-Bedingung); keine
  Anforderung an a-check oder d-check.
- Negativ (akzeptiert): je C#-Stufe ein `docker build` mit NuGet-Restore verlängert `make full-smoke`; der
  Zuwachs wird je Slice gemessen ([`MR-089`](../../../harness/conventions.md#mr-089)).
- Negativ (akzeptiert): Namensraum ≠ Verzeichnis wird nur durch `IDE0130` gefangen; die
  Verzeichnis-Schreibweise hält kein Sensor (Festlegung 5); ein voll qualifizierter Name, ein `<Using>` im
  `.csproj` und Reflection entgehen dem Arch-Gate.
- Negativ (akzeptiert): der Pin ist ein Tag. Kein Freshness-Lauf sieht den C#-Pin:
  `bash harness/tools/digest-freshness.sh --pins` führt go, golangci-lint, d-check (zwei Zeilen) und a-check,
  keinen Skelett-Pin; `make freshness-kotlin` liest allein die Kotlin-Konstante; die NuGet-Versionen sieht kein
  Lauf. Ein C#-Freshness-Werkzeug ist nicht Gegenstand dieser ADR und hat keinen Nehmer: der Pin altert
  unbemerkt (akzeptiertes Negativ).
- Folgepflicht: `spec/architecture.md` (Layout je Sprache) für `hexslice` nachziehen — Träger ist der
  Layout-Slice (Planner), als DoD-Punkt, ebenso Ports-Ordner, Kanten-Menge und der Schreibweisen-Test
  (Festlegung 5). Kein Sensor hält sie.
- Folgepflicht: die a-check-Zeile der Fitness Function hat ihren Träger (eine `make full-smoke`-Stufe mit
  rotem Domain→Adapter-`using`) erst mit dem Layout-Slice; bis dahin ist sie Zusage.
- Folgepflicht: die drei Wächter-Zusagen (Bindungen der Festlegung 3, TFM-Ableitung der Festlegung 2) sind
  DoD-Punkte von `slice-csharp-skelett`.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) über dem C#-`hexslice`-Ziel | ein `using` aus `App.Hexagon.Domain` nach `App.Adapters` färbt a-check rot mit `core-impurity` (Messung 6, Fälle 1, 4, 5, 6, 12), am gebootstrappten Ziel noch nicht; `app-impurity`, `wrong-direction`, `lateral-adapter` sind **nicht** gefahren: Zusage | `make full-smoke` (kein Gate), Stufe mit dem Layout-Slice |
| Code-Gate-Fragment ↔ Dockerfile | jedes Ziel `test`/`lint`/`build` des C#-Fragments hat seine Stage — Zusage eines Tests nach dem Muster `TestPythonCodeGateFragment_TargetsMatchStages`; Zusage, nicht Beleg | `make test` |
| Lint, Build, Test rot | unbenutzter `using` → `IDE0005` in `lint`, Format-Verstoß → `lint` Exit 2, unbenutzte Variable → `CS0219`, Nullable → `CS8602`, Syntaxfehler → `CS1001` in `build`, falsche Assertion → xunit `Failed` in `test`; rot gesehen am Probe-Gerüst, im Container-Lauf, nicht als Stage (Messung 2) | `make gates` im Ziel |
| Bindungen (Festlegung 3) | ohne `IDE0005`-Zeile bleibt der unbenutzte `using` grün (A1), ohne `TreatWarningsAsErrors` die Variable (A5), ohne `IDE0130`-Zeile der falsche Namensraum (I1) — das Gegenbeispiel ist am Probe gefahren; der **Wächter** (Text-Prüfung der emittierten Config) ist DoD-Zusage, nicht gefahren | `make test` |
| TFM-Ableitung | verfälschte TFM → `NETSDK1045` (Lauf 3); der Test auf die Ableitung ist Zusage | `make test` |
| Namensraum ≠ Verzeichnis | `IDE0130` färbt `lint` rot (I3); a-check färbt nichts (Fall 10) | `make gates` im Ziel |
| Guard ↔ `gen.SupportedLangs` | ein Profil ohne `blockedByLang`-Eintrag färbt den bestehenden Kopplungs-Test rot; für `csharp` Zusage; dazu ein Test auf die Namen von Festlegung 6 nach dem Muster der Java-Namensprüfung in `internal/emit/enforce_test.go` | `make test` |

Lücke: kein Sensor hält die Probe-Messung gegen das emittierte Skelett — bis das Skelett existiert, tragen die
Zeilen Zusage statt Beleg ([`AGENTS.md`](../../../AGENTS.md) §3.6). Lücke: die Verzeichnis-Schreibweise der
Festlegung 5 hat keinen Sensor. Lücke: der Test-Stage-Exit bei kaputtem Bau — im Lauf mit SDK 8.0.426 und
TFM `net10.0` meldete `dotnet test --no-restore` Exit 0 ohne Ausgabe (Ursache nicht untersucht); die Zeile
„falsche Assertion → `test`“ gilt für ein baubares Gerüst, und `build` im selben `GATE_CHECKS` fängt den
Fall. Lücke (Grenze der Messmethode, keine Lockerung): siehe den Abschnitt „Lage für die Reproduzierbarkeit“.

## Messungen

Methode: Der Docker-Daemon sieht das Scratchpad nicht als Mount. Das Probe-Gerüst liegt in einem
gitignorierten Pfad unter `.harness/state/`, der Bau läuft mit `docker build <Kontext>` (Kommandos in einem
Container-Lauf), a-check über `docker create` + `docker cp <fixture>/. <id>:/src` + `docker start -a` nach
`chmod -R a+rX` auf die Fixture. Host: arm64. Nach der Messung gelöscht.

```text
1. $ docker buildx imagetools inspect mcr.microsoft.com/dotnet/sdk:10.0.402 → sha256:0d99ebf1ccad15037b5c98c9fe8979d6b8dbac23812feae2277a0b277b5c5ffa
      Plattformen: linux/amd64, linux/arm/v7, linux/arm64  (dasselbe für :10.0 und :10.0.402-noble: gleicher Digest)
   $ … sdk:8.0.426  → sha256:f7e28a0a3f6f9235929ec19274fd0ddf8534e9159f99fac602ac73304f1ce99f  (amd64, arm/v7, arm64; = Digest von :8.0)
   $ … sdk:9.0      → sha256:2f5eb32870b4c0074a3d5b5191a03553bcab7b74463a76a7c0a5f3ef65c90fe5  (nur Digest, nicht gebaut)
   $ … sdk:10.0.402-alpine → not found
   $ docker run … sdk:10.0.402 dotnet --version → 10.0.402 (Laufzeit 10.0.13); sdk:8.0.426 → 8.0.426 (Laufzeit 8.0.32)
```

**2. Probe-Gerüst (vollständig).** Dateien:

```text
Directory.Build.props   <Project><PropertyGroup> TargetFramework=<TFM> · Nullable=enable · ImplicitUsings=disable ·
                        TreatWarningsAsErrors=true · AnalysisLevel=latest-recommended </PropertyGroup></Project>
.editorconfig           root = true · [*.cs] indent_style = space · indent_size = 4 ·
                        dotnet_diagnostic.IDE0005.severity = error
src/App/App.csproj      Sdk Microsoft.NET.Sdk · OutputType Exe
src/App/Program.cs      using System; namespace App; public static class Greeting { public static string For(string name)
                        => "Hallo, " + name; } public static class Program { public static void Main() =>
                        Console.WriteLine(Greeting.For("Welt")); }        (file-scoped namespace, je Typ eigener Block)
tests/App.Tests/App.Tests.csproj  IsPackable=false · PackageReference Microsoft.NET.Test.Sdk 17.14.1, xunit 2.9.3,
                        xunit.runner.visualstudio 3.1.4 · ProjectReference ../../src/App/App.csproj
tests/App.Tests/ProgramTests.cs   using Xunit; namespace App.Tests; public class ProgramTests { [Fact] public void
                        GreetingNenntDenNamen() => Assert.Equal("Hallo, Welt", Greeting.For("Welt")); }
app.sln                 dotnet new sln --format sln -n app (SDK 8: dotnet new sln -n app); dotnet sln add beide .csproj
Basisabbild             FROM mcr.microsoft.com/dotnet/sdk:<tag> · ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
                        DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 · WORKDIR /src · COPY . .
```

Kommandos je Lauf, nacheinander, im Container: `dotnet restore`; `dotnet build --no-restore -c Release`;
`dotnet test --no-restore`; `dotnet format --verify-no-changes --no-restore`.

```text
Lauf 0  SDK 10.0.402, TFM-Zeile  net$(NETCoreAppMaximumVersion)   → restore: error NU1202 (…net (.NETFramework,Version=v0.0)), exit 1
                                                                      build: error MSB3644 (….NETFramework,Version=v0.0 …), exit 1
Lauf 1  SDK 10.0.402, net10.0   restore 0 · build 0 (0 Warning) · test 0 (Passed 1, net10.0) · format 0
        aufgelöste Menge (dotnet list package --include-transitive): Microsoft.NET.Test.Sdk 17.14.1 · xunit 2.9.3 ·
        xunit.runner.visualstudio 3.1.4 · Microsoft.CodeCoverage 17.14.1 · Microsoft.TestPlatform.ObjectModel 17.14.1 ·
        Microsoft.TestPlatform.TestHost 17.14.1 · Newtonsoft.Json 13.0.3 · xunit.abstractions 2.0.3 · xunit.analyzers 1.18.0 ·
        xunit.assert 2.9.3 · xunit.core 2.9.3 · xunit.extensibility.core 2.9.3 · xunit.extensibility.execution 2.9.3
Lauf 2  SDK 8.0.426, net8.0     restore 0 · build 0 · test 0 (Passed 1, net8.0) · format 0
Lauf 3  SDK 8.0.426, net10.0    restore: error NETSDK1045 (… does not support targeting .NET 10.0), exit 1; build exit 1;
                                `dotnet test --no-restore` exit 0 ohne Ausgabe (Ursache nicht untersucht)
```

Rot (Lauf 1, je eine Änderung am Probe-Gerüst, dann Exit von build / format / test):

```text
Änderung                                                          build   format  test
Zeile 1 von Program.cs: `using System.Text;`                        0       2       0     format: IDE0005 Using directive is unnecessary
in Greeting: `public static void Dead() { int unused = 1; }`        1       0       1     build: CS0219
`=> "Hallo, " + name;` → `=>   "Hallo, "+name;`                     0       2       0     format: Whitespace
in Greeting: `public static int Len(string? s) => s.Length;`        1       0       1     build: CS8602
Test: "Hallo, Welt" → "Falsch"                                     0       0       1     Assert.Equal() Failure: Strings differ
in Greeting: `public static void Broken(:`                         1       0       1     build: CS1001/CS1026/CS1002
in Greeting: `private static int _x = 1;`                          1       0       1     build: CS0414
```

**3. Bindungs-Ablationen** (Lauf 1, `using System.Text;` in Zeile 1 bzw. `Dead()`; Exit build / format):

```text
A0 Props mit EnforceCodeStyleInBuild + GenerateDocumentationFile + NoWarn CS1591, IDE0005-Zeile        build 1 (IDE0005), format 2 (IDE0005)
A1 ohne IDE0005-Zeile in .editorconfig                               build 0, format 0   → still grün
A2 beide Eigenschaften entfernt (= Endfassung des Gerüsts), IDE0005-Zeile da                          build 0, format 2
A3 EnforceCodeStyleInBuild entfernt, GenerateDocumentationFile da    build 0, format 2
A4 GenerateDocumentationFile entfernt, EnforceCodeStyleInBuild da    build 1 („Set MSBuild property 'GenerateDocumentationFile' to 'true' to enable IDE0005 … on build"), format 2
A5 ohne TreatWarningsAsErrors, unbenutzte Variable                   build 0              → still grün
```

(A0 bis A5 liefen über einer früheren Fassung der Props, die EnforceCodeStyleInBuild, GenerateDocumentationFile und NoWarn CS1591 führte, jeweils mit der genannten Entfernung. Die Endfassung oben führt sie nicht; Lauf 1 und die Rot-Tabelle sind über ihr gefahren und bestätigen A2: unbenutzter using → build 0, format 2.)

```text
4. Netz (docker run --network none):
   O1 warmer Cache (Image nach Lauf 1): dotnet restore --force → exit 0; dotnet test --no-restore → Passed 1
   O2 kalter Cache (sdk:10.0.402, dotnet new xunit, dotnet restore) → exit 1, NU1301 „Unable to load the service index for
      source https://api.nuget.org/v3/index.json"
   O3 sdk:10.0.402, dotnet new console, dotnet build → exit 0 (Build succeeded)
   Paket-Cache im Image nach Lauf 1: 328 MB, `du -sh /root/.nuget/packages`
5. IDE0130 (Lauf 1, Datei src/App/Adapters/Driven/Store.cs, `namespace <NS>;`; format-Exit):
   ohne IDE0130-Zeile:  NS = App.Adapters.Driven → 0 · NS = App.Stores → 0                         (I0, I1: still grün)
   mit  `dotnet_diagnostic.IDE0130.severity = error`:
     NS = App.Adapters.Driven → 0 (I2) · App.Stores → 2 „Namespace "App.Stores" does not match folder structure, expected
     "App.Adapters.Driven"" (I3) · Verzeichnis adapters/driven (klein) mit App.Adapters.Driven → 0 (I4) ·
     Verzeichnis Adapters/Driven mit App.adapters.driven → 0 (I5)    → Groß-/Kleinschreibung wird nicht unterschieden
   Build (Release) bei NS = App.Stores → Build succeeded (I6)
```

**6.** a-check `ghcr.io/pt9912/a-check:v0.23.2`, vollständig. Fixture: `src/App/<Adp>/Store.cs` =
`<Zeile>\nnamespace <NS>;\n\npublic class Store\n{\n    public const int X = 1;\n}` (`<Adp>` = `Adapters/Driven`,
Fall 8: `adapters/driven`); `src/App/<Dom>/Greeting.cs` = `<Zeile 1: using>\n\nnamespace
App.Hexagon.Domain;\n\npublic class Greeting\n{\n<Körper>}` (`<Dom>` = `Hexagon/Domain` bzw. `hexagon/domain`; Fall 12:
block-scoped `namespace App.Hexagon.Domain { <using> public class Greeting { } }`). `.a-check.yml`: `version: 1` ·
`languages: csharp: ["**/*.cs"]` · `layers: domain {globs: [src/App/<Dom>/**], role: domain}, driven_adapters
{globs: [src/App/<Adp>/**], role: adapter, direction: driven}` · `edges: [{from: driven_adapters, to: domain}]` ·
`resolution: csharp: {mode: fixed-root, roots: [<R>], package_base: "App"}`; Vorbild-Fixture der Python-Messung
aus [ADR-0095](0095-python-skelett-toolchain-und-schicht-aufloesung.md) Messung 4.

```text
Fall  R / Änderung                                   Zeile 1 / Körper                                  Ausgabe                                          EXIT
1     src/App                                        using App.Adapters.Driven;                        core-impurity …Greeting.cs:1                      1
2     kein resolution-Block                          (wie 1)                                           0 Befund(e) + „0 von 1 Import-Symbolen"           0
3     src                                            (wie 1)                                           0 Befund(e) + „0 von 1 Import-Symbolen"           0
4     src/App                                        using static App.Adapters.Driven.Store;           core-impurity …Driven.Store                       1
5     src/App                                        using S = App.Adapters.Driven.Store;              core-impurity …Driven.Store                       1
6     src/App                                        global using App.Adapters.Driven;                 core-impurity                                     1
7     src/App                                        using System; Körper: private App.Adapters.Driven.Store _s = new();   0 Befund(e) + „0 von 1 …"         0
8     src/App, Verzeichnisse klein                   using App.Adapters.Driven;                        0 Befund(e) + „0 von 1 Import-Symbolen"           0
9     src/App, Schlüssel `cs`                        (wie 1)                                           a-check: unbekannte Sprache "cs" (cpp|csharp|…)   2
10    src/App, Store in `namespace App.Stores`       using App.Stores;                                 0 Befund(e) + „0 von 1 Import-Symbolen"           0
11    src/App, Store.cs importiert die Domain        Store.cs: using App.Hexagon.Domain;               0 Befund(e) (Kante driven_adapters→domain erlaubt) 0
12    src/App, block-scoped namespace                using App.Adapters.Driven; (in der Klammer)       core-impurity …Greeting.cs:3                      1
13    src/App                                        using System;                                     0 Befund(e) + „0 von 1 Import-Symbolen"           0
```

```text
7. Alternativen (dotnet new <vorlage> -n T; dotnet test T; SDK 10.0.402):
   nunit : NUnit 4.3.2, NUnit3TestAdapter 5.0.0, NUnit.Analyzers 4.7.0, Microsoft.NET.Test.Sdk 17.14.0 → Passed 1 (net10.0)
   mstest: MSTest 4.0.2 → Passed 1 (net10.0)
   xunit : xunit 2.9.3, xunit.runner.visualstudio 3.1.4, Microsoft.NET.Test.Sdk 17.14.1 → Passed 1 (net10.0)
   (dotnet new list zeigt keine xunit-v3-Vorlage)
8. Plattform: dasselbe Gerüst, SDK 10.0.402, `docker build --platform linux/amd64` (Emulation auf arm64-Host):
   restore 0 · build 0 · test 0 (Passed 1) · format 0. arm64 nativ: Lauf 1.
   Einzelmessung der Zeiten (nativ, Netz warm, ohne Folgerung auf die Stage-Dauer): restore 1,8 s, build 1,1 s,
   test 1,1 s, format 1,7 s.
```

Nicht gemessen: eine Stage-Form (`docker build --target`) gegen das Probe-Gerüst; `.slnx`; Projekt-Variante B;
xunit v3; NuGet-Analyzer; ein Lauf mit SDK 9.0; die Probe über dem vollständigen `hexslice`-Skelett (nur
Zwei-Schichten-Probe); `dotnet format` auf SDK 8.0.426 mit rotem Fall; Reflection und `<Using>` im `.csproj` gegen
a-check; ein Vergleich zweier Bauten desselben Tags; die Laufzeit der C#-Stufe in `make full-smoke`; die
Support-Zeiträume der SDK-Linien. Das Probe-Gerüst liegt nicht als Datei im Repo; die Listen oben sind seine
vollständige Beschreibung.

## Re-Evaluierungs-Trigger

1. Das Gegenbeispiel aus der Fitness Function färbt am `hexslice`-Ziel nicht rot → zuerst die Config gegen
   a-check prüfen: meldet der Lauf „0 von N Import-Symbolen lösen auf", ist es ein Config-Fehler oder die
   Schreibweise (Festlegung 5). Erst wenn eine Config, die `using`s auflöst, grün bleibt → Anforderung an a-check.
2. Das gepinnte SDK, xunit oder `dotnet format` laufen nicht grün, oder ein Pin-Zug an einer der Versionen färbt
   das Gerüst → Festlegung 2 und 3.
3. Ein Adopter verlangt `hexagonal` → Folge-ADR mit Pfaden und Auflösung; ein NuGet-Analyzer, `.slnx` oder ein
   Projekt je Schicht → Folge-ADR bzw. CR an [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4).
4. Der a-check-Pin löst Namensräume über die Deklaration auf oder unterscheidet die Schreibweise nicht mehr →
   Festlegung 5 (die Skelett-Pflichten entfielen nicht automatisch).
5. Ein C#-Freshness-Werkzeug entsteht → Konsequenz „Freshness“ entfällt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-18 | Proposed | `slice-csharp-skelett` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0096` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
