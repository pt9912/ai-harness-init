# ADR-0097: C#-hexslice — Richtungs-Ordner `inbound`/`outbound` klein, damit `port-locality` greift

**Status:** Proposed

**Datum:** 2026-10-18

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0096](0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5,
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md),
[ADR-0095](0095-python-skelett-toolchain-und-schicht-aufloesung.md) (Vorbild der Port-Ordner);
Gegenstand von `slice-csharp-hexslice-layout`

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Layout je Sprache, C# `hexslice`).

**Verfeinert (nicht supersedet):** [ADR-0096](0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)
Festlegung 5, und nur die Sätze, die Abschnitt „Berührte und unberührte Sätze" nennt.
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) bleibt unberührt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0096](0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5 legt für C# PascalCase-Verzeichnisse
fest (`Hexagon/Domain`, `Adapters/Driven`) und lässt „Ports-Ordner und Kanten-Menge" dem Layout-Slice. Der Slice
lieferte `…/Ports/{Inbound,Outbound}/…`. Der gepinnte a-check
(`grep -n 'DefaultArchImage  =' internal/emit/archgate.go` → `v0.23.2`) meldet dort bei grünem Lauf
`Hinweis: 2 Port-Glob(s) erreichen den App-Baum nicht — port-locality bleibt dafür ungeprueft` (Messung 1): ein
fremder Slice-Port-`using` im Handler bleibt grün. Das Review nennt die Ursache nicht `ports`, sondern das
Richtungs-Segment; die Messung unten bestätigt es und grenzt es ein. Java und Python (`ports/inbound`) prüfen die
Regel. ADR-0096 hat den Fall nicht gemessen — ihre Messung 6 kennt nur die Kante `driven_adapters → domain` und
Zwei-Schichten-Fixtures — und führt `port-locality` weder in der Fitness Function noch in der Liste „Nicht erkannt".

## Entscheidung

Wir legen **kleingeschriebene Richtungs-Ordner `inbound` und `outbound`** fest; `Ports` und jedes übrige Verzeichnis
bleibt PascalCase. Gemessen ist, dass a-check das Richtungs-Segment nur kleingeschrieben abzieht (Messung 2) und dass
das Gerüst mit dieser Schreibweise unter `TreatWarningsAsErrors`, `AnalysisLevel latest-recommended`, `IDE0130` und
`dotnet format` grün bleibt (Messung 3). Die Wahl der Richtung ist Entscheidung des Auftraggebers („Architect:
Folge-ADR für kleine Richtungs-Ordner", 2026-10-18); die Messung trägt sie. Die Einzelheiten sind Linie des Architect.

**1. Schreibweise.** Verzeichnisse `src/App/Hexagon/Application/<Area>/<UseCase>/Ports/{inbound,outbound}/` und
`…/<Area>/Ports/outbound/`; Namensraum gleich Verzeichnispfad (ADR-0096 Festlegung 5 (a)), also
`App.Hexagon.Application.Example.Greet.Ports.inbound`. Die Namensraum-Teile `inbound`/`outbound` sind klein, weil a-check
den Namensraum lexikalisch auf den Pfad abbildet und Groß-/Kleinschreibung unterscheidet; ein groß geschriebener Teil
löste nicht auf.

**2. Config.** Die Port-Globs enden auf `…/Ports/inbound/**` und `…/Ports/outbound/**`; beide Port-Schichten tragen weiter
ihre `direction` — die Richtung, deren Segment a-check kleingeschrieben abzieht (Messung 2). Schlüssel, Root, Kanten-Menge
(sieben Kanten) und Slice-Globs bleiben die von ADR-0096.

**3. Die Ursache steht im Config-Kommentar, wie gemessen.** Der Kommentar der emittierten `.a-check.yml` nennt das
kleingeschriebene Richtungs-Segment als Bedingung für `port-locality` und nicht den Port-Ordner `ports` (der Review-Befund
F1 war eine Aussage ohne Gegenprobe an der behaupteten Ursache). Er nennt auch, was der Adopter bei einer neuen Slice
schreibt: Verzeichnis, Namensraum und Glob mit kleingeschriebener Richtung.

**4. Grenze, bleibt benannt.** Ein Adopter, der ein Richtungs-Verzeichnis `Inbound` schreibt, bringt den Hinweis zurück
und verliert `port-locality` für diesen Port; der Hinweis ist advisory (Exit 0). Kein Sensor beim Adopter hält die
Schreibweise (wie ADR-0096, Lücke zu (b)); gehalten wird der Renderer (Fitness Function).

### Berührte und unberührte Sätze von ADR-0096

**Berührt:** (i) „die Verzeichnisse in **PascalCase** (`Adapters/Driven`, `Hexagon/Domain`)" und der Pfad-Satz „Pfade nach
ADR-0060 in PascalCase": gelten für alle Verzeichnisse **außer** den Richtungs-Ordnern `inbound`/`outbound`; (ii) „Ports-Ordner
und Kanten-Menge entscheidet der Layout-Slice": die Schreibweise der Richtungs-Ordner ist hiermit entschieden, die
Kanten-Menge nicht berührt; (iii) die Begründung „weil a-check Groß-/Kleinschreibung unterscheidet" gilt unverändert und
ist die Grundlage dieser Festlegung.
**Unberührt:** Festlegungen 1 bis 4 und 6; in Festlegung 5 der `resolution`-Block, `exclude`, `languages`, die Skelett-Pflicht
(a) Namensraum gleich Verzeichnis samt `IDE0130`, die Liste „Nicht erkannt", `hexagonal` als nicht festgelegt, und die Lücke zu (b)
(`IDE0130` unterscheidet die Schreibweise nicht). [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
legt `inbound`/`outbound` als Rollen-Namen fest; die kleine Schreibweise folgt dem Namen dort, nur `Ports` ist die
C#-Großschreibung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A0 — nichts tun (ausgeliefertes PascalCase-Layout) | kein Aufwand; Grenze steht an vier Orten | `port-locality` ungeprüft (Messung 1, 2); Config-Kommentar nennt die falsche Ursache |
| **A — Richtungs-Ordner klein, `Ports` und alles übrige PascalCase** | `port-locality` **und** `port-direction-mismatch` greifen; Kanten-Menge und Schichten wie Java/Python; Gerüst grün (Messung 3) | kleingeschriebener Namensraum-Teil `Ports.inbound` ist unüblich in .NET; Mischschreibweise im Pfad; die Schreibweise hält beim Adopter kein Sensor |
| B1 — PascalCase bleibt, **eine** Port-Schicht mit Glob auf dem Port-Ordner (`…/Ports/**`, ohne `direction`) | alles PascalCase; `port-locality` greift (Messung 4, B1) | `port-direction-mismatch` und die Richtungs-Kanten entfallen: ein treibender Adapter darf einen outbound-Port importieren, a-check meldet nichts (Messung 4); weicht von der Kanten-Menge der übrigen Sprachen ab |
| B2 — Verzeichnisse PascalCase, Richtungs-Globs klein | nur Config | die Globs treffen keine Dateien: `lateral-slice` und `wrong-direction` färben das Gerüst rot (Messung 4, B2) |
| B3 — PascalCase, `direction` von den Port-Schichten entfernt | nur Config | der Hinweis bleibt, `port-locality` ungeprüft (Messung 4, B3) |
| C — Anforderung an a-check (Richtungs-Segment ohne Beachtung der Schreibweise) | sauberste Lösung in PascalCase | hängt an einem Fremdwerkzeug; Auftraggeber-Entscheidung vor Folge-ADR; später als Re-Evaluierungs-Trigger 1 |

Zu B1: der Auftraggeber entschied die Richtung A, bevor B1 gemessen war; B1 ist die gemessene Alternative mit
anderem Trade-off (Verlust einer Regel statt einer Schreibweise).

## Konsequenzen

- Positiv: `port-locality` ist für C# im emittierten Ziel real geprüft; die Aussage „ungeprüft" aus dem Config-Kommentar,
  `spec/architecture.md`, der Abdeckungs-Zeile und dem Stufen-Kopf entfällt.
- Negativ (akzeptiert): Mischschreibweise `Ports/inbound` im Pfad und `Ports.inbound` im Namensraum. Kein Analyzer färbt
  sie (Messung 3); `IDE1006` ist nicht aktiv, ob er sie färbte, ist nicht gemessen.
- Negativ (akzeptiert): wie ADR-0096 hält kein Sensor die Verzeichnis-Schreibweise beim Adopter; ein groß geschriebenes
  Richtungs-Verzeichnis zeigt sich als Hinweis in der a-check-Ausgabe, `make gates` bleibt grün.
- Folgepflicht (Träger der Layout-Slice, als Plan-Änderung vom Planner zu übernehmen, nicht von dieser ADR): Renderer
  (Verzeichnisse, Namensräume), emittierte Config (Globs, Kommentar), Fälle der Mutations-Reihe 748 bis 763, Stufe,
  `spec/architecture.md`, Abdeckungs-Zeile und Kurzbeschreibung der Stufe tragen die kleine Richtung und nennen die
  Messung statt der alten Grenze. Kein Sensor hält die Übereinstimmung der vier Aussagen.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) im C#-`hexslice`-Ziel, Lauf-Zahn | in einem Ziel mit zweiter Slice färbt ein `using` des Handlers auf den `outbound`-Port der fremden Slice a-check rot mit `port-locality: app außerhalb Port-Scope …/<Slice>` an `Handler.cs:<Zeile>`; die grüne Ausgabe des unveränderten Ziels trägt den Hinweis „erreichen den App-Baum nicht" nicht. Rot gesehen am Probe-Ziel (Messung 3 gegen Messung 1/2); am Stufen-Ziel noch nicht | `make full-smoke` (kein Gate), Stufe von `slice-csharp-hexslice-layout` |
| Text-Wächter im Generator-Test | die gerenderten Port-Globs enden auf `inbound`/`outbound` klein und treffen die gerenderten Verzeichnisse; Namensraum gleich Verzeichnispfad auch für die Richtungs-Segmente. Rot herstellbar: ein Richtungs-Segment in Renderer oder Config groß schreiben. Zusage, nicht gefahren | `make test` |

**Wächter und Lauf-Zahn gehören in dieselbe Lieferung** ([`AGENTS.md`](../../../AGENTS.md) §3.6): der Text-Wächter bindet die
Schreibweise an den Renderer, den Lauf-Zahn beweist, dass a-check im Ziel die Regel prüft; keiner ersetzt den anderen
(der Text-Wächter hielt den Hinweis aus Messung 1 nicht auf, weil er die Wirkung nicht misst).
Der Lauf-Zahn legt die zweite Slice im Stufen-Ziel so an, wie es der Config-Kommentar dem Adopter vorschreibt (Port-Datei,
`app`-Glob, `outbound`-Port-Glob), und hält die Meldung wörtlich.
Lücke: die Schreibweise beim Adopter hat keinen Sensor (Festlegung 4). Lücke: `IDE1006`/Namensraum-Konvention ist nicht
gemessen. Nicht gefahren: dass der Lauf-Zahn am Stufen-Ziel (Linux-Container-Dateisystem) dieselbe Meldung liefert wie
am Probe-Ziel (die Läufe 1 bis 3 unten lasen den Bind-Mount des macOS-Dateisystems).

## Messungen

Methode: a-check `ghcr.io/pt9912/a-check@sha256:2368f7b3a84f1dc5d075edccfe2201e19947d12fcbc8eaf4df84ef162d94f422`
(`DefaultArchDigest`, Tag `v0.23.2`). Basis-Ziel: `ai-harness-init --lang csharp --arch hexslice <ziel>` aus dem Träger
des Standes `28f051cb` (`make host-bin`; `<ziel>` ein vorher mit `git init` angelegtes Verzeichnis unter dem
gitignorierten `.harness/state/`); alle Probe-Ziele danach gelöscht. Die Läufe 4 und 5 liefen über
`docker create --network none <image> /src`, `docker cp <ziel>/. <id>:/src`, `docker start -a <id>`
(Container-Dateisystem, case-sensitiv); die Läufe 1 bis 3 liefen über `make a-check` bzw. denselben Aufruf mit Bind-Mount auf dem
macOS-Dateisystem, wobei in jeder Variante Verzeichnis, Namensraum und Glob dieselbe Schreibweise trugen. Host: macOS arm64, Docker über colima.

```text
Variante  = Basis-Ziel + (1) Verzeichnisse Ports/Inbound/Outbound umbenannt, (2) in allen *.cs
            "Ports.Inbound"→"<P>.<I>", "Ports.Outbound"→"<P>.<O>", (3) in .a-check.yml "Ports/Inbound"→"<P>/<I>",
            "Ports/Outbound"→"<P>/<O>", (4) zweite Slice Other:
  src/App/Hexagon/Application/Example/Other/<P>/<O>/IOther.cs
      namespace App.Hexagon.Application.Example.Other.<P>.<O>;  public interface IOther { void Run(); }
  .a-check.yml: Glob "…/Example/Other/**" in Schicht app, Glob "…/Example/Other/<P>/<O>/**" in ports_outbound
  fremd = Zeile 1 von Greet/Handler.cs: using App.Hexagon.Application.Example.Other.<P>.<O>;
```

**1. Reproduktion am ausgelieferten Layout** (Basis-Ziel, `make a-check`, Exit 0):

```text
gesamt: 0 Befund(e)
Hinweis: 2 Port-Glob(s) erreichen den App-Baum nicht — port-locality bleibt dafür ungeprueft:
  src/App/Hexagon/Application/Example/Greet/Ports/Inbound/** -> Scope src/App/Hexagon/Application/Example/Greet/Ports
  src/App/Hexagon/Application/Example/Greet/Ports/Outbound/** -> Scope src/App/Hexagon/Application/Example/Greet/Ports
  Abhilfe: Port-Glob auf den Port-Ordner schneiden (…/ports/**) oder der Schicht ihre direction geben.
```

**2. Schreibweise-Matrix** (`<P>`, `<I>`, `<O>`; beide Port-Schichten tragen `direction`; „fremd" = Handler mit `using` auf die fremde
`<O>`; mit zweiter Slice zählt der Hinweis drei Globs):

```text
<P>    <I>      <O>       ohne fremd           mit fremd
Ports  Inbound  Outbound  Hinweis (3 Globs)    0 Befund(e), Exit 0 (grün)
ports  Inbound  Outbound  Hinweis (3 Globs)    0 Befund(e), Exit 0 (grün)
Ports  inbound  outbound  0 Befund(e), kein Hinweis   port-locality 1, Exit 1:
                                               Greet/Handler.cs:1: port-locality: app außerhalb Port-Scope
                                               src/App/Hexagon/Application/Example/Other: App.Hexagon.Application.Example.Other.Ports.outbound
ports  inbound  outbound  (wie Ports)        port-locality 1, Exit 1 (gleiche Meldung mit ports.outbound)
Ports  Inbound  outbound  —                  Hinweis nur für den Inbound-Glob; port-locality 1, Exit 1
Ports  inbound  Outbound  —                  Hinweis nur für die Outbound-Globs; 0 Befund(e), Exit 0 (grün)
```

Befund: das Richtungs-Segment zieht a-check nur kleingeschrieben ab (je Richtung einzeln); `Ports` und `ports` gelten gleich.
Der Hinweis nennt als Scope `…/Greet/Ports` — das Segment `Outbound` bleibt im Scope hängen.

**3. Alternative A im vollständigen Ziel** (Basis-Ziel mit `inbound`/`outbound` nach 1 bis 3; ohne Other-Slice):

```text
make build lint test a-check  → Exit 0; "Passed!  - Failed: 0, Passed: 2" (net10.0); a-check "gesamt: 0 Befund(e)", kein Hinweis
Kontrolle IDE0130 (Namensraum in INotifier.cs auf App.…Example.Stores): make lint → Exit 2
   …/Greet/Ports/outbound/INotifier.cs(1,11): error IDE0130: Namespace "App.Hexagon.Application.Example.Stores" does not
   match folder structure, expected "App.Hexagon.Application.Example.Greet.Ports.outbound"
mit Other-Slice und fremd (Handler hält das Feld `public IOther? Fremd { get; set; }`, damit der using genutzt ist):
   make build lint test → Exit 0 (Passed 2);   make a-check → Exit 1 (über make: 2):
   Greet/Handler.cs:1: port-locality: app außerhalb Port-Scope …/Example/Other: App.Hexagon.Application.Example.Other.Ports.outbound
```

Kein Analyzer und keine IDE-Regel färbt den kleingeschriebenen Namensraum-Teil `Ports.inbound` unter `TreatWarningsAsErrors`,
`AnalysisLevel latest-recommended`, `IDE0005`/`IDE0130` als Fehler und `dotnet format --verify-no-changes`; `CA1707`, `CS8981`
und `IDE1006` wurden nicht einzeln hergestellt, gemessen ist nur, dass das Gerüst grün bleibt. (Eine erste Fixture-Fassung scheiterte
an `CA1716` für eine Methode `Do` — der Fehler lag an der Fixture, nicht an der Schreibweise.)

**4. Alternativen B** (Basis-Ziel mit Other-Slice, Verzeichnisse und Namensräume PascalCase):

```text
B1 eine Schicht ports {Glob …/Greet/Ports/**, …/Example/Ports/**, …/Example/Other/Ports/**}, role: port, ohne direction;
   Kanten app→ports, ports→domain, driving_adapters→ports, driven_adapters→ports, app→domain, driven_adapters→domain
   mit fremd:   port-locality 1, Exit 1 (Handler.cs:1 …Other.Ports.Outbound)     ohne fremd: 0 Befund(e), Exit 0, kein Hinweis
   GreetCli.cs (driving) mit `using …Greet.Ports.Outbound;` bzw. `…Ports.outbound;` (A):
      B1: 0 Befund(e), Exit 0
      A : port-direction-mismatch: driving_adapters (driving) -> ports_outbound (outbound): …Greet.Ports.outbound, Exit 1
B2 Richtungs-Globs klein, Verzeichnisse groß:  lateral-slice 1, wrong-direction 3, "gesamt: 4 Befund(e)", Exit 1
   (IGreetingRepository.cs liegt in keiner Schicht)
B3 direction von beiden Port-Schichten entfernt, Globs PascalCase:  0 Befund(e), Hinweis für alle 3 Globs, Exit 0
```

**5. Eine Schreibweisen-Lücke, einzeln gemessen** (Verzeichnisse `Inbound`/`Outbound` groß, Namensräume und Globs klein): a-check
`wrong-direction 1`, „1 gescannte Datei(en) liegen in keiner Schicht" (`…/Example/Ports/Outbound/IGreetingRepository.cs`), Exit 1 — rot
in diesem Fixture, nicht verallgemeinert: wie sich eine Abweichung zeigt, hängt davon ab, welche Importe auflösen.

Nicht gemessen: `IDE1006` aktiv; `CA1707`/`CS8981` einzeln; ein Lauf der Stufe im Mono-Repo (Träger ist der Layout-Slice); eine andere
a-check-Version; ob a-check die Schreibweise im Hinweis-Text oder in einer Regel dokumentiert (die Hinweis-Ausgabe nennt sie nicht).

## Re-Evaluierungs-Trigger

1. Ein a-check-Pin zieht das Richtungs-Segment ohne Beachtung der Schreibweise ab (Messung 2 wiederholt: `Ports/Inbound` ohne Hinweis)
   → Folge-ADR zurück auf PascalCase (Alternative C erfüllt).
2. Ein Analyzer, ein SDK-Pin oder `IDE1006` färbt einen kleingeschriebenen Namensraum-Teil → Folge-ADR: Alternative B1 oder eine
   Anforderung an a-check.
3. Der Lauf-Zahn färbt am Stufen-Ziel nicht, obwohl der Probe-Lauf färbte → zuerst Config und Schreibweise des Stufen-Ziels gegen
   Messung 2 prüfen, dann den Dateisystem-Unterschied.
4. Ein Adopter meldet `port-direction-mismatch` oder `port-locality` als zu streng (Mischschreibweise) → Alternative B1 neu bewerten.
5. `hexagonal` für C# wird festgelegt → Ports ohne Richtungs-Segment, diese ADR berührt es nicht.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-18 | Proposed | Review `2026-10-18-slice-csharp-hexslice-layout` (F1, F2); Entscheidung des Auftraggebers „Architect: Folge-ADR für kleine Richtungs-Ordner" |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR
(Baseline-Regelwerk `modul-04-adrs.md` §Hard Rule für Accepted-ADRs).
