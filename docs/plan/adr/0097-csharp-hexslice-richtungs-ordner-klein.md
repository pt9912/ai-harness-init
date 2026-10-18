# ADR-0097: C#-hexslice — Richtungs-Ordner `inbound`/`outbound` klein, damit `port-locality` greift

**Status:** Accepted

**Datum:** 2026-10-18

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0096](0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5,
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md),
[ADR-0095](0095-python-skelett-toolchain-und-schicht-aufloesung.md) (Vorbild der Port-Ordner),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Accept-Übergang);
Gegenstand von `slice-csharp-hexslice-layout`

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Layout je Sprache, C# `hexslice`).

**Supersedes (Teil):** [ADR-0096](0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5, und nur
die drei Sätze, die §Abgelöste und unberührte Sätze wörtlich aufzählt. Alles übrige von ADR-0096 gilt fort.
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
`dotnet format` grün bleibt (Messung 3). Die Einzelheiten der Festlegungen 1 bis 4 sind Linie des Architect.

### Entscheidung des Auftraggebers (2026-10-18)

Der Auftraggeber hat **A bestätigt** — in Kenntnis von Messung 4: Alternative B1 (PascalCase, eine Port-Schicht ohne
`direction`) hielte alles PascalCase, verlöre aber `port-direction-mismatch` und die Richtungs-Kanten; A kostet die
Mischschreibweise (`Ports/inbound`, `Ports.inbound`) und lässt die Schreibweise beim Adopter ohne Sensor (Festlegung 4,
Messung 5, Messung 6). Er hat den Trade-off ausdrücklich zugunsten der gehaltenen Richtungs-Regeln gewählt.

**Alternative C** (a-check ignoriert die Schreibweise des Richtungs-Segments) ist **keine Anforderung an a-check
jetzt**; sie bleibt **Re-Evaluierungs-Trigger** (Trigger 1 und 5). **Nicht entschieden** ist, wann eine solche
Anforderung gestellt wird und ob der Adopter-Sensor für die Schreibweise nachgezogen wird; beides folgt aus den
Triggern, nicht aus dieser ADR.

**1. Schreibweise.** Verzeichnisse `src/App/Hexagon/Application/<Area>/<UseCase>/Ports/{inbound,outbound}/` und
`…/<Area>/Ports/outbound/`; Namensraum gleich Verzeichnispfad (ADR-0096 Festlegung 5 (a)), also
`App.Hexagon.Application.Example.Greet.Ports.inbound`. Die Namensraum-Teile `inbound`/`outbound` sind klein, weil a-check
den Namensraum lexikalisch auf den Pfad abbildet und Groß-/Kleinschreibung unterscheidet; ein groß geschriebener Teil
löste nicht auf.

**2. Config.** Die Port-Globs enden auf `…/Ports/inbound/**` und `…/Ports/outbound/**`; beide Port-Schichten tragen weiter
ihre `direction` — die Richtung, deren Segment a-check kleingeschrieben abzieht (Messung 2; `direction: Inbound` groß ist
gar kein gültiger Wert, Messung 6). Schlüssel, Root, Kanten-Menge (sieben Kanten) und Slice-Globs bleiben die von ADR-0096.

**3. Die Ursache steht im Config-Kommentar, wie gemessen.** Der Kommentar der emittierten `.a-check.yml` nennt das
kleingeschriebene Richtungs-Segment als Bedingung für `port-locality` und nicht den Port-Ordner `ports` (der Review-Befund
F1 war eine Aussage ohne Gegenprobe an der behaupteten Ursache). Er nennt auch, was der Adopter bei einer neuen Slice
schreibt: Verzeichnis, Namensraum und Glob mit kleingeschriebener Richtung.

**4. Grenze, bleibt benannt.** Ein Adopter, der ein Richtungs-Verzeichnis `Inbound` schreibt, bringt den Hinweis zurück
und verliert `port-locality` für diesen Port; der Hinweis ist advisory (Exit 0). Schreibt er das Verzeichnis klein und
den Namensraum groß, färbt a-check nur, wenn ein Adapter den Port importiert (`wrong-direction`, Messung 6); eine Slice
ohne Adapter-Import bliebe still (nicht gefahren), `IDE0130` färbt es nicht (Messung 6). Kein Sensor beim Adopter hält
die Schreibweise (wie ADR-0096, Lücke zu (b)); gehalten wird der Renderer (Fitness Function).

### Abgelöste und unberührte Sätze von ADR-0096

**Abgelöst (Teil), wörtlich aus Festlegung 5:** (i) „die Verzeichnisse in **PascalCase** (`Adapters/Driven`,
`Hexagon/Domain`)"; (ii) „Pfade nach ADR-0060 in PascalCase: `src/App/Hexagon/{Domain,Application}/…`,
`src/App/Adapters/{Driving,Driven}/…`, Composition Root `src/App/Program.cs`" — beide gelten künftig für alle
Verzeichnisse **außer** den Richtungs-Ordnern `inbound`/`outbound` unter `Ports`; (iii) „Ports-Ordner und Kanten-Menge
entscheidet der Layout-Slice": die Schreibweise der Richtungs-Ordner ist hiermit entschieden, die Kanten-Menge nicht
berührt. Die Begründung „weil a-check Groß-/Kleinschreibung unterscheidet" gilt unverändert und trägt diese Festlegung.

**Unberührt:** Festlegungen 1 bis 4 und 6; in Festlegung 5 der `resolution`-Block, `exclude`, `languages`, die Skelett-Pflicht
(a) Namensraum gleich Verzeichnis samt `IDE0130`, die Liste „Nicht erkannt", `hexagonal` als nicht festgelegt, und die Lücke zu (b)
(`IDE0130` unterscheidet die Schreibweise nicht). [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
legt `inbound`/`outbound` als Rollen-Namen fest; die kleine Schreibweise folgt dem Namen dort, nur `Ports` ist die
C#-Großschreibung.

**Form.** Gewählt ist „Supersedes (Teil)" mit wörtlicher Aufzählung (Form von ADR-0060), nicht „Verfeinert": die Sätze (i) und
(ii) sagen „alle Verzeichnisse PascalCase", und wer ADR-0096 allein liest, läse dort PascalCase auch für `inbound`/`outbound`.
ADR-0096 bleibt unverändert (§3.4); die Teil-Ablösung steht in dieser ADR und in der Status-Spalte der Index-Zeile von
ADR-0096.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A0 — nichts tun (ausgeliefertes PascalCase-Layout) | kein Aufwand; Grenze steht an vier Orten | `port-locality` ungeprüft (Messung 1, 2); Config-Kommentar nennt die falsche Ursache |
| **A — Richtungs-Ordner klein, `Ports` und alles übrige PascalCase** (gewählt, Auftraggeber in Kenntnis von Messung 4) | `port-locality` **und** `port-direction-mismatch` greifen; Kanten-Menge und Schichten wie Java/Python; Gerüst grün (Messung 3) | kleingeschriebener Namensraum-Teil `Ports.inbound` ist unüblich in .NET; Mischschreibweise im Pfad; die Schreibweise hält beim Adopter kein Sensor |
| B1 — PascalCase bleibt, **eine** Port-Schicht mit Glob auf dem Port-Ordner (`…/Ports/**`, ohne `direction`) | alles PascalCase; `port-locality` greift (Messung 4, B1) | `port-direction-mismatch` und die Richtungs-Kanten entfallen: ein treibender Adapter darf einen outbound-Port importieren, a-check meldet nichts (Messung 4); weicht von der Kanten-Menge der übrigen Sprachen ab |
| B2 — Verzeichnisse PascalCase, Richtungs-Globs klein | nur Config | die Globs treffen keine Dateien: `lateral-slice` und `wrong-direction` färben das Gerüst rot (Messung 4, B2) |
| B3 — PascalCase, `direction` von den Port-Schichten entfernt | nur Config | der Hinweis bleibt, `port-locality` ungeprüft (Messung 4, B3) |
| C — Anforderung an a-check (Richtungs-Segment ohne Beachtung der Schreibweise) | sauberste Lösung in PascalCase | hängt an einem Fremdwerkzeug; vom Auftraggeber **nicht jetzt** gestellt, bleibt Re-Evaluierungs-Trigger 1 und 5 |

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
gemessen. Gemessene Lage zum Dateisystem: die Stufe fährt a-check über `docker run -v "$(CURDIR)":/src:ro`
(`a-check.mk:20` im Ziel), einen Bind-Mount; Bind-Mount und `docker cp` lieferten dieselbe Ausgabe (Messung 6), a-check wertet
Pfade lexikalisch aus. Ungemessen: der Lauf auf dem CI-Linux-Dateisystem.

## Messungen

Methode: a-check `ghcr.io/pt9912/a-check@sha256:2368f7b3a84f1dc5d075edccfe2201e19947d12fcbc8eaf4df84ef162d94f422`
(`DefaultArchDigest`, Tag `v0.23.2`). Basis-Ziel: `ai-harness-init --lang csharp --arch hexslice <ziel>` aus dem Träger
des Standes `28f051cb` (`make host-bin`; `<ziel>` ein vorher mit `git init` angelegtes Verzeichnis unter dem
gitignorierten `.harness/state/`); alle Probe-Ziele danach gelöscht. Die Messungen 4 und 5 liefen über
`docker create --network none <image> /src`, `docker cp <ziel>/. <id>:/src`, `docker start -a <id>`
(Container-Dateisystem, case-sensitiv); die Messungen 1 bis 3 liefen über `make a-check` bzw. denselben Aufruf mit Bind-Mount
auf dem macOS-Dateisystem, wobei in jeder Variante Verzeichnis, Namensraum und Glob dieselbe Schreibweise trugen.
Host: macOS arm64, Docker über colima. Messung 6 stammt aus dem Review `2026-10-18-adr-0097-review` (Reviewer, nachgefahren,
nicht vom Architect gefahren).

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

**6. Nachgefahren vom Reviewer** (Quelle `2026-10-18-adr-0097-review`, Träger Stand `28f051cb`, Docker-only; die Messungen 1 bis 5
wurden reproduziert):

```text
Gegenrichtung zu 5 (Ziel nach A, Namensraum …Ports.Outbound bei Verzeichnis outbound, alle Dateien):
   make lint → Exit 0, kein IDE0130;  make a-check → Exit 1 (über make: 2): wrong-direction: driven_adapters -> app
   (laut nur, weil der Adapter-Import auf den app-Glob fällt; eine Slice ohne Adapter-Import bliebe still — nicht gefahren)
direction: Inbound (groß) in der Config → Exit 2 „ungültige direction … (inbound|outbound)"
Bind-Mount (make build lint test a-check im Ziel) und docker cp/start -a → dieselbe Ausgabe (Exit 0 bzw. dieselbe Meldung)
```

Der Test-Zähler `Passed: 2` des Bind-Mount-Laufs ist wegen Docker-Cache nicht neu gesehen.

Nicht gemessen: `IDE1006` aktiv; `CA1707`/`CS8981` einzeln; der Lauf auf CI-Linux; ein Lauf der Stufe im Mono-Repo (Träger ist der
Layout-Slice); eine andere a-check-Version; ob a-check die Schreibweise im Hinweis-Text oder in einer Regel dokumentiert (die
Hinweis-Ausgabe nennt sie nicht).

## Re-Evaluierungs-Trigger

1. Ein a-check-Pin zieht das Richtungs-Segment ohne Beachtung der Schreibweise ab (Messung 2 wiederholt: `Ports/Inbound` ohne Hinweis)
   → Folge-ADR zurück auf PascalCase (Alternative C erfüllt).
2. Ein Analyzer, ein SDK-Pin oder `IDE1006` färbt einen kleingeschriebenen Namensraum-Teil → Folge-ADR: Alternative B1 oder eine
   Anforderung an a-check.
3. Der Lauf-Zahn färbt am Stufen-Ziel nicht, obwohl der Probe-Lauf färbte → zuerst Config und Schreibweise des Stufen-Ziels gegen
   Messung 2 prüfen, dann den CI-Lauf (ungemessen) gegen die Probe.
4. Ein Adopter meldet `port-direction-mismatch` oder `port-locality` als zu streng (Mischschreibweise) → Alternative B1 neu bewerten.
5. Der Auftraggeber stellt Alternative C als Anforderung an a-check, oder ein Adopter trifft die Schreibweisen-Lücke (Festlegung 4)
   → Folge-ADR zu C bzw. zum Adopter-Sensor.
6. `hexagonal` für C# wird festgelegt → Ports ohne Richtungs-Segment, diese ADR berührt es nicht.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-18 | Proposed | Review `2026-10-18-slice-csharp-hexslice-layout` (F1, F2); Entscheidung des Auftraggebers „Architect: Folge-ADR für kleine Richtungs-Ordner" |
| 2026-10-18 | **Accepted** | Review `2026-10-18-adr-0097-review` (0 HIGH; M-1 und L-1, L-2 sowie I-1 vor der Annahme eingearbeitet: Wahl A vom Auftraggeber in Kenntnis von Messung 4 bestätigt, Alternative C bleibt Re-Evaluierungs-Trigger und keine Anforderung an a-check jetzt; Dateisystem-Gegenüberstellung berichtigt; Form „Supersedes (Teil)" mit wörtlicher Aufzählung; Gegenrichtung zu Messung 5 als Messung 6 übernommen), Entscheidung des Auftraggebers vom 2026-10-18 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1). Diese Datei trägt **keinen** Acceptance-Trigger; der Review-Report ist Prüfung, kein Trigger-Beleg, und eine zweite Runde war mangels blockierendem Befund nicht verlangt ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR
(Baseline-Regelwerk `modul-04-adrs.md` §Hard Rule für Accepted-ADRs).
