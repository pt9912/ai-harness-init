package gen

// Das hexSlice-Layout fuer Java (ADR-0094 Festlegung 4): die Schichten sind Pakete unter
// src/main/java/app, Paket == Verzeichnis. Die Schicht-Dateien referenzieren einander
// ausschliesslich ueber vollqualifizierte `import app.…;`-Zeilen; genau diese Form loest die
// a-check-Config (resolution java, fixed-root mit package_base app) auf einen Pfad auf.
// Ein Paket ausserhalb seines Verzeichnisses entgeht der Aufloesung;
// TestJavaHexslice_PaketGleichVerzeichnis haelt die Form am generierten Skelett.

const javaHexDomain = `// Domain-Schicht des generierten hexSlice-Skeletts: importiert keine andere Schicht.
package app.hexagon.domain.example;

import java.util.Optional;

public final class Greeting {
    private final String message;

    private Greeting(String message) {
        this.message = message;
    }

    // of liefert leer fuer eine leere Nachricht — die Invariante der Domain.
    public static Optional<Greeting> of(String message) {
        if (message.isBlank()) {
            return Optional.empty();
        }
        return Optional.of(new Greeting(message));
    }

    public String message() {
        return message;
    }
}
`

const javaHexInboundPort = `// Port-Schicht (inbound, greet): der Vertrag, ueber den die Welt die Use-Case ruft.
// Er spricht schlichte Typen und importiert die Domain nicht.
package app.hexagon.application.example.greet.ports.inbound;

import java.util.Optional;

public interface Greet {
    Optional<String> greet(String message);
}
`

const javaHexSlicePort = `// Port-Schicht (outbound, slice-lokal, greet): der Kanal, ueber den die Use-Case meldet.
package app.hexagon.application.example.greet.ports.outbound;

public interface Notifier {
    void send(String message);
}
`

const javaHexAreaPort = `// Port-Schicht (outbound, business-area-geteilt): importiert nur die Domain.
package app.hexagon.application.example.ports.outbound;

import app.hexagon.domain.example.Greeting;

public interface GreetingRepository {
    void save(Greeting greeting);
}
`

const javaHexHandler = `// Application-Schicht (Use-Case-Slice greet): app -> domain, app -> ports, nie Adapter.
package app.hexagon.application.example.greet;

import app.hexagon.application.example.greet.ports.inbound.Greet;
import app.hexagon.application.example.greet.ports.outbound.Notifier;
import app.hexagon.application.example.ports.outbound.GreetingRepository;
import app.hexagon.domain.example.Greeting;
import java.util.Optional;

public final class Handler implements Greet {
    private final GreetingRepository repository;
    private final Notifier notifier;

    public Handler(GreetingRepository repository, Notifier notifier) {
        this.repository = repository;
        this.notifier = notifier;
    }

    @Override
    public Optional<String> greet(String message) {
        Optional<Greeting> greeting = Greeting.of(message);
        if (greeting.isEmpty()) {
            return Optional.empty();
        }
        repository.save(greeting.get());
        notifier.send(greeting.get().message());
        return Optional.of(greeting.get().message());
    }
}
`

const javaHexDrivingCLI = `// Adapter-Schicht (driving, CLI): spricht die Use-Case nur ueber ihren inbound-Port.
package app.adapters.driving.cli.example;

import app.hexagon.application.example.greet.ports.inbound.Greet;

public final class Cli {
    private final Greet greet;

    public Cli(Greet greet) {
        this.greet = greet;
    }

    public boolean run(String message) {
        return greet.greet(message).isPresent();
    }
}
`

const javaHexDrivenRepo = `// Adapter-Schicht (driven, In-Memory): erfuellt den Area-Port durch implements und
// importiert ihn deshalb (die driven_adapters -> ports_outbound-Kante der Config).
package app.adapters.driven.memory.example;

import app.hexagon.application.example.ports.outbound.GreetingRepository;
import app.hexagon.domain.example.Greeting;
import java.util.ArrayList;
import java.util.List;

public final class InMemoryRepository implements GreetingRepository {
    private final List<Greeting> stored = new ArrayList<>();

    public List<Greeting> saved() {
        return List.copyOf(stored);
    }

    @Override
    public void save(Greeting greeting) {
        stored.add(greeting);
    }
}
`

const javaHexDrivenNotify = `// Adapter-Schicht (driven, Ausgabe): erfuellt den slice-lokalen Notifier-Port.
package app.adapters.driven.notify;

import app.hexagon.application.example.greet.ports.outbound.Notifier;
import java.io.PrintStream;

public final class StdoutNotifier implements Notifier {
    private final PrintStream out;

    public StdoutNotifier(PrintStream out) {
        this.out = out;
    }

    @Override
    public void send(String message) {
        out.println(message);
    }
}
`

// javaHexMain — Composition Root: verdrahtet Adapter, Ports und Use-Case-Slice; die
// a-check-Config fuehrt ihn als composition_root.
const javaHexMain = `// Command app — vom ai-harness-init generiertes hexSlice-Skelett. Composition Root:
// verdrahtet Adapter, Ports und Use-Case-Slices (a-check-exempt).
package app;

import app.adapters.driven.memory.example.InMemoryRepository;
import app.adapters.driven.notify.StdoutNotifier;
import app.adapters.driving.cli.example.Cli;
import app.hexagon.application.example.greet.Handler;

public final class Main {
    private Main() {
    }

    public static void main(String[] args) {
        Handler handler = new Handler(new InMemoryRepository(), new StdoutNotifier(System.out));
        if (!new Cli(handler).run("Hallo vom generierten hexSlice-Skelett.")) {
            System.exit(1);
        }
    }
}
`

// javaHexTest — Test ueber JUnit Jupiter: die Domain-Invariante und der Durchlauf der
// Use-Case ueber beide getriebenen Adapter.
const javaHexTest = `// Minimaler Test ueber JUnit Jupiter — Domain-Invariante und greet-Use-Case.
package app;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import app.adapters.driven.memory.example.InMemoryRepository;
import app.adapters.driven.notify.StdoutNotifier;
import app.hexagon.application.example.greet.Handler;
import app.hexagon.domain.example.Greeting;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class GreetTest {
    @Test
    void leereNachrichtVerletztDieInvariante() {
        assertTrue(Greeting.of("").isEmpty());
    }

    @Test
    void handlerSpeichertUndMeldet() {
        InMemoryRepository repository = new InMemoryRepository();
        ByteArrayOutputStream sink = new ByteArrayOutputStream();
        Handler handler = new Handler(repository, new StdoutNotifier(new PrintStream(sink)));
        assertEquals(Optional.of("hi"), handler.greet("hi"));
        assertEquals(List.of("hi"), repository.saved().stream().map(Greeting::message).toList());
        assertEquals("hi" + System.lineSeparator(), sink.toString());
    }
}
`

// javaHexArchConfig — die .a-check.yml des hexSlice-Java-Moduls (ADR-0094 Festlegung 4,
// LH-FA-07). MODUL-relativ (der Gate-Lauf mountet das Modul-Verzeichnis). Der
// resolution-Block ist tragend: ohne ihn loest kein `import app.…;` auf eine Schicht auf,
// und das Gate bleibt ueber jedem Import gruen. Der Root endet im package_base-Verzeichnis,
// weil a-check `app.` vom Import abstreift, bevor es den Root voranstellt. Die Ports-Ordner
// (use-case-lokal inbound/outbound, area-geteilt outbound) und die Kanten-Menge sind die der
// Kotlin-Fassung; die driven_adapters -> ports_outbound-Kante folgt der
// implements-Erfuellung des Ports.
const javaHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Die Schichten sind Pakete, und Paket == Verzeichnis ist Pflicht: a-check loest
# einen Import (app.adapters.driven.notify.StdoutNotifier) ueber den PFAD auf —
# es streift package_base ("app.") ab, ersetzt die Punkte durch "/" und stellt
# den Root voran (src/main/java/app/adapters/driven/notify/...). Ein Paket, das
# nicht in seinem Verzeichnis liegt, entgeht damit der Pruefung; ebenso ein voll
# qualifizierter Name im Code ohne import. Der Root endet darum im
# package_base-Verzeichnis; ein Root src/main/java loest keinen Import auf, und
# a-check meldet dann "0 von N Import-Symbolen loesen auf".
#
# Die Slice-Globs (.../greet/**) und Port-Globs (.../ports/<richtung>/**) tragen
# bewusst literale Verzeichnis-Praefixe. Nur daran haengen die beiden Vertical-
# Slice-Regeln: lateral-slice (eine Slice importiert keine andere derselben
# Schicht) und port-locality (ein slice-lokaler Port bleibt in seiner Slice).
# Behalte jede Port-Glob-Endung auf ihrer Richtung.
#
# DIESE DATEI IST DEINE: sie wird beim Re-Bootstrap nicht ueberschrieben, also
# waechst sie nur, wenn du sie pflegst. Zwei Faelle:
#   - Area/Slice UMBENANNT  -> die Globs mitziehen.
#   - Slice HINZUGEFUEGT    -> je einen app-Glob (.../<neue-slice>/**) und, falls
#     sie Ports traegt, je einen ports-Glob (.../<neue-slice>/ports/<richtung>/**)
#     ERGAENZEN. Vergisst du es, faellt der neue Code unter keine Schicht: importiert
#     er eine (Domain/Ports), meldet a-check wrong-direction und faellt — importiert
#     er keine, bleibt er still gruen und ungeprueft.
version: 1

languages:
  java: ["**/*.java"]

layers:
  domain:
    globs: ["src/main/java/app/hexagon/domain/**"]
    role: domain
  ports_inbound:
    globs:
      - "src/main/java/app/hexagon/application/example/greet/ports/inbound/**"   # use-case-lokal
    role: port
    direction: inbound      # von der Use-Case angeboten; ein driving Adapter ruft ihn
  ports_outbound:
    globs:
      - "src/main/java/app/hexagon/application/example/greet/ports/outbound/**"   # use-case-lokal
      - "src/main/java/app/hexagon/application/example/ports/outbound/**"         # business-area-geteilt
    role: port
    direction: outbound     # von der Use-Case gebraucht; ein driven Adapter erfuellt ihn
  app:
    globs:
      - "src/main/java/app/hexagon/application/example/greet/**"         # Slice: greet
    role: app
  driving_adapters:
    globs: ["src/main/java/app/adapters/driving/**"]
    role: adapter
    direction: driving      # ruft den Anwendungskern
  driven_adapters:
    globs: ["src/main/java/app/adapters/driven/**"]
    role: adapter
    direction: driven       # wird vom Anwendungskern gerufen

# Erlaubte gerichtete Abhaengigkeiten (nur nach innen). Ein Cross-Layer-Import
# ohne passende Kante ist ein Befund (wrong-direction).
edges:
  - {from: app,              to: domain}
  - {from: app,              to: ports_inbound}    # die Slice implementiert ihren inbound-Port
  - {from: app,              to: ports_outbound}   # die Slice ruft ihre outbound-Ports
  - {from: ports_outbound,   to: domain}
  - {from: driving_adapters, to: ports_inbound}    # der treibende Adapter spricht die inbound-Ports
  - {from: driven_adapters,  to: domain}           # Adapter bilden auf/von Domain-Objekten ab
  - {from: driven_adapters,  to: ports_outbound}   # der getriebene Adapter implementiert den Port
                                                   # (Java-Interface) und importiert ihn.

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["src/main/java/app/Main.java"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "src/test/**"

# Paket -> Pfad: package_base wird vom Import abgestreift, der Root vorangestellt.
resolution:
  java:
    mode: fixed-root
    roots: ["src/main/java/app"]
    package_base: "app"
`

