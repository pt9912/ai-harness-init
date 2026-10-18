package gen

// Das hexSlice-Layout fuer C# (ADR-0096 Festlegung 5, ADR-0097): die Schichten sind PascalCase-
// Verzeichnisse unter src/App, die Richtungs-Ordner unter Ports heissen klein (inbound, outbound),
// und der Namensraum einer Datei ist ihr Verzeichnispfad ab App (IDE0130 haelt das in lint).
// a-check bildet den Namensraum eines `using` auf einen Pfad ab, nicht auf die Deklaration; ein
// Verzeichnis in anderer Schreibweise als der Namensraum loest darum nicht auf. Das Richtungs-
// Segment zieht a-check nur kleingeschrieben ab (port-locality greift nur dann).
// Die Typnamen tragen das I-Praefix der Schnittstellen (IGreet) oder ein Suffix (GreetCli), damit
// kein Typ den Namen eines Namensraums seines Pfades traegt.

const csHexSrc = "src/App/"

// csharpHexslice rendert eine Rolle des hexSlice-Layouts; jede andere Rolle -> nil.
func csharpHexslice(r codeRole) map[string]string {
	hex := csHexSrc + "Hexagon/"
	area := hex + "Application/Example/"
	adapters := csHexSrc + "Adapters/"
	switch r {
	case roleDomain:
		return map[string]string{hex + "Domain/Example/Greeting.cs": csHexDomain}
	case rolePorts:
		return map[string]string{
			area + "Greet/Ports/inbound/IGreet.cs":          csHexInboundPort,
			area + "Greet/Ports/outbound/INotifier.cs":      csHexSlicePort,
			area + "Ports/outbound/IGreetingRepository.cs": csHexAreaPort,
		}
	case roleAppSlice:
		return map[string]string{area + "Greet/Handler.cs": csHexHandler}
	case roleAdapters:
		return map[string]string{
			adapters + "Driving/Cli/Example/GreetCli.cs":                csHexDrivingCLI,
			adapters + "Driven/Memory/Example/InMemoryRepository.cs": csHexDrivenRepo,
			adapters + "Driven/Notify/StdoutNotifier.cs":             csHexDrivenNotify,
		}
	case roleCompositionRoot:
		return map[string]string{
			csHexSrc + "Program.cs":                   csHexMain,
			"tests/App.Tests/GreetTests.cs": csHexTest,
		}
	}
	return nil
}

const csHexDomain = `namespace App.Hexagon.Domain.Example;

// Domain-Schicht des generierten hexSlice-Skeletts: importiert keine andere Schicht.
public sealed record Greeting(string Message)
{
    // Liefert null fuer eine leere Nachricht — die Invariante der Domain.
    public static Greeting? Create(string message) =>
        string.IsNullOrWhiteSpace(message) ? null : new Greeting(message);
}
`

const csHexInboundPort = `namespace App.Hexagon.Application.Example.Greet.Ports.inbound;

// Port-Schicht (inbound, Greet): der Vertrag, ueber den die Welt die Use-Case ruft. Er spricht
// schlichte Typen und importiert die Domain nicht.
public interface IGreet
{
    string? Greet(string message);
}
`

const csHexSlicePort = `namespace App.Hexagon.Application.Example.Greet.Ports.outbound;

// Port-Schicht (outbound, slice-lokal, Greet): der Kanal, ueber den die Use-Case meldet.
public interface INotifier
{
    void Send(string message);
}
`

const csHexAreaPort = `using App.Hexagon.Domain.Example;

namespace App.Hexagon.Application.Example.Ports.outbound;

// Port-Schicht (outbound, business-area-geteilt): importiert nur die Domain.
public interface IGreetingRepository
{
    void Save(Greeting greeting);
}
`

const csHexHandler = `using App.Hexagon.Application.Example.Greet.Ports.inbound;
using App.Hexagon.Application.Example.Greet.Ports.outbound;
using App.Hexagon.Application.Example.Ports.outbound;
using App.Hexagon.Domain.Example;

namespace App.Hexagon.Application.Example.Greet;

// Application-Schicht (Use-Case-Slice Greet): app -> domain, app -> ports, nie Adapter.
public sealed class Handler : IGreet
{
    private readonly IGreetingRepository _repository;
    private readonly INotifier _notifier;

    public Handler(IGreetingRepository repository, INotifier notifier)
    {
        _repository = repository;
        _notifier = notifier;
    }

    public string? Greet(string message)
    {
        var greeting = Greeting.Create(message);
        if (greeting is null)
        {
            return null;
        }

        _repository.Save(greeting);
        _notifier.Send(greeting.Message);
        return greeting.Message;
    }
}
`

const csHexDrivingCLI = `using App.Hexagon.Application.Example.Greet.Ports.inbound;

namespace App.Adapters.Driving.Cli.Example;

// Adapter-Schicht (driving, CLI): spricht die Use-Case nur ueber ihren inbound-Port.
public sealed class GreetCli
{
    private readonly IGreet _greet;

    public GreetCli(IGreet greet)
    {
        _greet = greet;
    }

    public bool Run(string message) => _greet.Greet(message) is not null;
}
`

const csHexDrivenRepo = `using System.Collections.Generic;
using App.Hexagon.Application.Example.Ports.outbound;
using App.Hexagon.Domain.Example;

namespace App.Adapters.Driven.Memory.Example;

// Adapter-Schicht (driven, In-Memory): implementiert den Area-Port und importiert ihn deshalb
// (die driven_adapters -> ports_outbound-Kante der Config).
public sealed class InMemoryRepository : IGreetingRepository
{
    private readonly List<Greeting> _stored = new List<Greeting>();

    public IReadOnlyList<Greeting> Saved() => _stored.ToArray();

    public void Save(Greeting greeting) => _stored.Add(greeting);
}
`

const csHexDrivenNotify = `using System.IO;
using App.Hexagon.Application.Example.Greet.Ports.outbound;

namespace App.Adapters.Driven.Notify;

// Adapter-Schicht (driven, Ausgabe): implementiert den slice-lokalen Port INotifier.
public sealed class StdoutNotifier : INotifier
{
    private readonly TextWriter _out;

    public StdoutNotifier(TextWriter output)
    {
        _out = output;
    }

    public void Send(string message) => _out.WriteLine(message);
}
`

// csHexMain — Composition Root: verdrahtet Adapter, Ports und Use-Case-Slice; die a-check-Config
// fuehrt ihn als composition_root.
const csHexMain = `using System;
using App.Adapters.Driven.Memory.Example;
using App.Adapters.Driven.Notify;
using App.Adapters.Driving.Cli.Example;
using App.Hexagon.Application.Example.Greet;

namespace App;

// Composition Root des generierten hexSlice-Skeletts: verdrahtet Adapter, Ports und
// Use-Case-Slices (a-check-exempt).
public static class Program
{
    public static int Main()
    {
        var handler = new Handler(new InMemoryRepository(), new StdoutNotifier(Console.Out));
        return new GreetCli(handler).Run("Hallo vom generierten hexSlice-Skelett.") ? 0 : 1;
    }
}
`

// csHexTest — Test ueber xunit: die Domain-Invariante und der Durchlauf der Use-Case ueber
// beide getriebenen Adapter.
const csHexTest = `using System;
using System.IO;
using App.Adapters.Driven.Memory.Example;
using App.Adapters.Driven.Notify;
using App.Hexagon.Application.Example.Greet;
using App.Hexagon.Domain.Example;
using Xunit;

namespace App.Tests;

public class GreetTests
{
    [Fact]
    public void LeereNachrichtVerletztDieInvariante() => Assert.Null(Greeting.Create(""));

    [Fact]
    public void HandlerSpeichertUndMeldet()
    {
        var repository = new InMemoryRepository();
        var sink = new StringWriter();
        var handler = new Handler(repository, new StdoutNotifier(sink));
        Assert.Equal("hi", handler.Greet("hi"));
        Assert.Equal("hi", Assert.Single(repository.Saved()).Message);
        Assert.Equal("hi" + Environment.NewLine, sink.ToString());
    }
}
`

// csharpHexArchConfig — die .a-check.yml des hexSlice-C#-Moduls (ADR-0096 Festlegung 5,
// LH-FA-07, ADR-0097). MODUL-relativ (der Gate-Lauf mountet das Modul-Verzeichnis). Der resolution-Block
// ist tragend: ohne ihn loest kein using auf eine Schicht auf, und das Gate bleibt ueber jedem
// using gruen. Der Root endet im package_base-Verzeichnis, weil a-check "App." vom Namensraum
// abstreift, bevor es den Root voranstellt. Die Ports-Ordner (use-case-lokal inbound/outbound,
// area-geteilt outbound) und die Kanten-Menge sind die der Java- und der Python-Fassung; die
// driven_adapters -> ports_outbound-Kante folgt der Implementierung des Port-Interfaces.
const csharpHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Der Namensraum ist der Pfad: a-check loest ein using (using App.Adapters.Driven.Notify;)
# ueber den Namensraum auf — es streift package_base ("App.") ab, ersetzt die Punkte durch "/"
# und stellt den Root voran (src/App/Adapters/Driven/Notify). Der Root endet darum im
# package_base-Verzeichnis; ein Root src loest kein using auf, und a-check meldet dann
# "0 von N Import-Symbolen loesen auf". Ein Namensraum, der keinem Verzeichnis folgt, loest
# ebenfalls nicht auf und faerbt nichts; IDE0130 haelt Namensraum und Verzeichnis zusammen,
# unterscheidet aber Gross- und Kleinschreibung nicht, a-check unterscheidet sie. Halte die
# Verzeichnisse in PascalCase — ausser den Richtungs-Ordnern unter Ports. Nicht erkannt wird
# ein voll qualifizierter Name im Code ohne using; ein <Using Include=...> in einer .csproj-Datei
# liegt ausserhalb des Globs **/*.cs.
#
# Die Richtungs-Ordner heissen KLEIN: Ports/inbound und Ports/outbound, im Namensraum
# Ports.inbound und Ports.outbound, im Glob .../Ports/inbound/** und .../Ports/outbound/**.
# a-check zieht das Richtungs-Segment der Port-Schichten (direction) nur kleingeschrieben vom
# Namensraum ab. Mit einem grossgeschriebenen Segment (Inbound, Outbound) loest der Port-Glob
# nicht auf den App-Baum, a-check meldet den Hinweis "Port-Glob(s) erreichen den App-Baum
# nicht" und laesst port-locality fuer diesen Port aus; das Gate bleibt dabei gruen. Der Ordner
# Ports selbst ist PascalCase (Ports und ports gelten gleich).
#
# Die Slice-Globs (.../Greet/**) und Port-Globs (.../Ports/<richtung>/**) tragen bewusst
# literale Verzeichnis-Praefixe. An den Slice-Globs haengt die Vertical-Slice-Regel
# lateral-slice (eine Slice importiert keine andere derselben Schicht), an den Port-Globs die
# Regel port-locality (ein slice-lokaler Port bleibt in seiner Slice). Behalte jede Port-Glob-
# Endung auf ihrer Richtung.
#
# DIESE DATEI IST DEINE: sie wird beim Re-Bootstrap nicht ueberschrieben, also
# waechst sie nur, wenn du sie pflegst. Zwei Faelle:
#   - Area/Slice UMBENANNT  -> die Globs mitziehen.
#   - Slice HINZUGEFUEGT    -> je einen app-Glob (.../<NeueSlice>/**) und, falls sie Ports
#     traegt, je einen ports-Glob (.../<NeueSlice>/Ports/inbound/** bzw. .../outbound/**)
#     ERGAENZEN; Verzeichnis .../<NeueSlice>/Ports/outbound/, Namensraum
#     App.<Pfad>.<NeueSlice>.Ports.outbound, Richtung klein. Vergisst du es, faellt der neue
#     Code unter keine Schicht: importiert er eine (Domain/Ports), meldet a-check
#     wrong-direction und faellt — importiert er keine, bleibt er still gruen und ungeprueft.
#     Schreibst du die Richtung gross, bleibt der Port ohne port-locality; ein Sensor dafuer
#     gibt es beim Adopter nicht.
version: 1

languages:
  csharp: ["**/*.cs"]

layers:
  domain:
    globs: ["src/App/Hexagon/Domain/**"]
    role: domain
  ports_inbound:
    globs:
      - "src/App/Hexagon/Application/Example/Greet/Ports/inbound/**"   # use-case-lokal
    role: port
    direction: inbound      # von der Use-Case angeboten; ein driving Adapter ruft ihn
  ports_outbound:
    globs:
      - "src/App/Hexagon/Application/Example/Greet/Ports/outbound/**"   # use-case-lokal
      - "src/App/Hexagon/Application/Example/Ports/outbound/**"         # business-area-geteilt
    role: port
    direction: outbound     # von der Use-Case gebraucht; ein driven Adapter erfuellt ihn
  app:
    globs:
      - "src/App/Hexagon/Application/Example/Greet/**"         # Slice: Greet
    role: app
  driving_adapters:
    globs: ["src/App/Adapters/Driving/**"]
    role: adapter
    direction: driving      # ruft den Anwendungskern
  driven_adapters:
    globs: ["src/App/Adapters/Driven/**"]
    role: adapter
    direction: driven       # wird vom Anwendungskern gerufen

# Erlaubte gerichtete Abhaengigkeiten (nur nach innen). Ein Cross-Layer-Using
# ohne passende Kante ist ein Befund (wrong-direction).
edges:
  - {from: app,              to: domain}
  - {from: app,              to: ports_inbound}    # die Slice implementiert ihren inbound-Port
  - {from: app,              to: ports_outbound}   # die Slice ruft ihre outbound-Ports
  - {from: ports_outbound,   to: domain}
  - {from: driving_adapters, to: ports_inbound}    # der treibende Adapter spricht die inbound-Ports
  - {from: driven_adapters,  to: domain}           # Adapter bilden auf/von Domain-Objekten ab
  - {from: driven_adapters,  to: ports_outbound}   # der getriebene Adapter implementiert das
                                                   # Port-Interface und importiert es.

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["src/App/Program.cs"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "tests/**"

# Namensraum -> Pfad: package_base wird vom Namensraum abgestreift, der Root vorangestellt.
resolution:
  csharp:
    mode: fixed-root
    roots: ["src/App"]
    package_base: "App"
`
