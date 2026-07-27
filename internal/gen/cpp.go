package gen

import "strings"

// DefaultCppVersion ist der gepinnte Default des C++-Skeletts — der **ubuntu-Base-Tag**
// (nicht eine Compiler-Version): er bestimmt die apt-Toolchain (g++, cmake, clang-tidy).
// „Version" heisst je Sprache etwas anderes (go: Go-Version; cpp: ubuntu-Tag); das Profil
// interpretiert sie, der Aufrufer faedelt sie generisch (SKEL_CPP_VERSION). TAG-gepinnt,
// kein floating (LH-QA-02), aber bewusst OHNE Digest, damit der Knopf wirkt.
const DefaultCppVersion = "26.04"

// cppProfile ist das C++-SKELETT fuer die gegebene ubuntu-Version (ADR-0003 Docker-only):
// die Gates sind Dockerfile-Stages (build/test/lint); dazu ein CMake-Projekt, ein baubares
// src/main.cpp, ein NETZLOSER assert-freier Test (kein externes Framework — LH-QA-03) und
// eine .clang-tidy. An realen Harness-C++-Repos (cmake-xray, b-cad) geeicht. Das
// Code-Gate-Fragment (harness/mk/<modul>.mk) kommt wie bei go aus gen.CodeGateFragment;
// das Skelett selbst ist ortsunabhaengig. Statisch/deterministisch (LH-QA-02): gleiche
// version -> byte-identische Ausgabe.
func cppProfile(version, arch string) map[string]string {
	return composeSkeleton(cppScaffolding, cppRole, version, arch)
}

// cppScaffolding — die arch-INVARIANTE C++-Bau-/Toolchain-Gerueestung: das
// CMake-Projekt (die Gate-Stages), die Lint-Config und das Dockerfile. Immer praesent,
// unabhaengig vom Arch-Layout.
func cppScaffolding(version string) map[string]string {
	return map[string]string{
		"CMakeLists.txt": cppCMakeLists,
		".clang-tidy":    cppClangTidy,
		"Dockerfile":     renderCpp(cppDockerfileTmpl, version),
	}
}

// cppRole rendert eine Code-Rolle als C++-Datei(en). Entry-Point -> src/main.cpp;
// die Test-Rolle traegt den netzlosen CTest-Satz unter tests/ (ADR-0008: Tests folgen
// dem Code-Layout, nicht der Gerueestung). hexSlice (slice-053, ADR-0009): die vier
// Schicht-Rollen + der Composition Root rendern in die kanonischen Verzeichnisse
// (src/hexagon/{domain,application}, src/adapters/{inbound,outbound}, src/main.cpp).
//
// Die Schichten sind HEADER-ONLY, und das ist eine Design-Entscheidung, keine
// Bequemlichkeit: die arch-invariante CMakeLists uebersetzt genau eine
// Uebersetzungseinheit (add_executable(app src/main.cpp)). Eine .cpp-Schicht-Datei, die
// dort nicht gelistet ist, waere still tot — der Build bliebe gruen ueber einer Teilmenge
// (die slice-024-Klasse). Header-only heisst: was der Composition Root includiert, wird
// UEBERSETZT und von clang-tidy (HeaderFilterRegex '^src/') mitgelintet, ohne dass die
// Gerueestung arch-abhaengig wird. Der Beleg dafuer ist ein Zahn, keine Behauptung
// (full-smoke: Fehler in einer Schicht-Datei faerbt den Modul-Build rot).
//
// Der Composition Root traegt zusaetzlich tests/, weil die Gerueestung
// add_subdirectory(tests) arch-INVARIANT ausfuehrt: ohne tests/ scheiterte schon das
// CMake-Configure. Er ist die Stelle, an der in C++ verdrahtet wird — auch die Tests.
// Eine nicht unterstuetzte Rolle -> nil.
func cppRole(r codeRole) map[string]string {
	switch r {
	case roleEntrypoint:
		return map[string]string{"src/main.cpp": cppMain}
	case roleTest:
		return map[string]string{
			"tests/CMakeLists.txt": cppTestCMakeLists,
			"tests/test_main.cpp":  cppTest,
		}
	case roleDomain:
		return map[string]string{"src/hexagon/domain/example/greeting.hpp": cppHexDomain}
	case rolePorts:
		return map[string]string{
			"src/hexagon/application/example/ports/greeting_repository.hpp": cppHexAreaPort,
			"src/hexagon/application/example/greet/ports/notifier.hpp":      cppHexSlicePort,
		}
	case roleAppSlice:
		return map[string]string{
			"src/hexagon/application/example/greet/command.hpp": cppHexCommand,
			"src/hexagon/application/example/greet/handler.hpp": cppHexHandler,
		}
	case roleAdapters:
		return map[string]string{
			"src/adapters/inbound/cli/example/cli.hpp":            cppHexInboundCLI,
			"src/adapters/outbound/memory/example/repository.hpp": cppHexOutboundRepo,
			"src/adapters/outbound/notify/stdout.hpp":             cppHexOutboundNotify,
		}
	case roleCompositionRoot:
		return map[string]string{
			"src/main.cpp":         cppHexMain,
			"tests/CMakeLists.txt": cppHexTestCMakeLists,
			"tests/test_greet.cpp": cppHexTest,
		}
	}
	return nil
}

// cppFragment liefert das C++-Code-Gate-Fragment (harness/mk/<modul>.mk-Inhalt): am Root
// (context ".") die UNSCOPED Fassung (Targets test/lint/build, `docker build .`), im Subdir
// die MODUL-SCOPED Fassung (test-<modul> …, `docker build <context>`, kollisionsfrei im
// Mono-Repo). Jedes `docker build --target <stage>` referenziert eine gleichnamige
// Dockerfile-Stage (test/lint/build) — kein halluziniertes Gate (LH-QA-01),
// TestCodeGateFragment_TargetsMatchStages haelt die Kopplung fest.
func cppFragment(modul, context, version string) string {
	if context == "." {
		return renderCpp(cppMkFragmentTmpl, version)
	}
	return renderCppScoped(cppScopedMkFragmentTmpl, modul, context, version)
}

// renderCpp setzt die ubuntu-Version in ein cpp-Template ein ({{CXX_VERSION}}). Eigener
// Renderer, weil cpp nur EINEN Versions-Platzhalter hat (kein golangci-Pin wie go).
func renderCpp(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{CXX_VERSION}}", version)
}

// renderCppScoped setzt Modul-Name, Build-Kontext + Version in das modul-scoped Fragment ein.
func renderCppScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{CXX_VERSION}}", version,
	).Replace(tmpl)
}

const cppMain = `// Command app — vom ai-harness-init generiertes C++-Skelett.
#include <iostream>

int main() {
    std::cout << "Hallo vom generierten ai-harness-init-Skelett." << '\n';
    return 0;
}
`

// cppTest — minimaler NETZLOSER Test (kein doctest/FetchContent, LH-QA-03): eine explizite
// Pruefung + Exit-Code (kein assert, damit er auch unter NDEBUG greift). Er belegt, dass die
// Toolchain baut und CTest den Test faehrt.
const cppTest = `// Minimaler netzloser Test (kein externes Framework) — belegt Build + CTest-Lauf.
#include <cstdlib>

namespace {
int add(int a, int b) { return a + b; }
}  // namespace

int main() {
    if (add(2, 3) != 5) {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
`

// --- hexSlice-Schichten (slice-053, ADR-0009) -------------------------------------
//
// Import-Richtungen inward-only, wie im Go-Renderer — mit EINEM sprach-bedingten
// Unterschied, der kein Detail ist: Go-Outbound-Adapter erfuellen ihre Ports
// STRUKTURELL (Interface-Erfuellung ohne Import), C++ erfuellt sie durch VERERBUNG und
// muss den Port-Header also includieren. Die cpp-Schicht-Config traegt deshalb eine
// `adapters -> ports`-Kante, die die Go-Config bewusst NICHT hat. Wer die Kante fuer
// einen Copy-Paste-Fehler haelt und sie streicht, faerbt das Arch-Gate des generierten
// Skeletts rot.

// cppHexDomain — Domain-Schicht: importiert nur die Standardbibliothek, nie eine
// andere Schicht. Die Invariante (nicht-leere Nachricht) lebt hier.
const cppHexDomain = `// Domain-Schicht des generierten hexSlice-Skeletts: importiert nur sich selbst.
#ifndef HEXAGON_DOMAIN_EXAMPLE_GREETING_HPP
#define HEXAGON_DOMAIN_EXAMPLE_GREETING_HPP

#include <optional>
#include <string>

namespace hexagon::domain::example {

// Greeting ist ein Domain-Value-Object mit nicht-leerer Nachricht.
class Greeting {
  public:
    // make erzwingt die Domain-Invariante: eine leere Nachricht ergibt kein Greeting.
    static std::optional<Greeting> make(std::string message) {
        if (message.empty()) {
            return std::nullopt;
        }
        return Greeting{std::move(message)};
    }

    [[nodiscard]] const std::string& message() const { return message_; }

  private:
    explicit Greeting(std::string message) : message_(std::move(message)) {}

    std::string message_;
};

}  // namespace hexagon::domain::example

#endif  // HEXAGON_DOMAIN_EXAMPLE_GREETING_HPP
`

// cppHexAreaPort — Business-Area-Port: importiert nur die Domain.
const cppHexAreaPort = `// Port-Schicht (Business-Area der example-Area): importiert nur die Domain.
#ifndef HEXAGON_APPLICATION_EXAMPLE_PORTS_GREETING_REPOSITORY_HPP
#define HEXAGON_APPLICATION_EXAMPLE_PORTS_GREETING_REPOSITORY_HPP

#include "src/hexagon/domain/example/greeting.hpp"

namespace hexagon::application::example::ports {

// GreetingRepository persistiert Greetings (Outbound-Port; ein Adapter ERBT von ihm und
// verdrahtet wird im Composition Root).
class GreetingRepository {
  public:
    virtual ~GreetingRepository() = default;
    virtual bool save(const domain::example::Greeting& greeting) = 0;
};

}  // namespace hexagon::application::example::ports

#endif  // HEXAGON_APPLICATION_EXAMPLE_PORTS_GREETING_REPOSITORY_HPP
`

// cppHexSlicePort — slice-lokaler Port der greet-Use-Case: importiert nur die Domain.
const cppHexSlicePort = `// Port-Schicht (slice-lokal, greet): importiert nur die Domain.
#ifndef HEXAGON_APPLICATION_EXAMPLE_GREET_PORTS_NOTIFIER_HPP
#define HEXAGON_APPLICATION_EXAMPLE_GREET_PORTS_NOTIFIER_HPP

#include "src/hexagon/domain/example/greeting.hpp"

namespace hexagon::application::example::greet::ports {

// Notifier annonciert ein Greeting (slice-lokaler Outbound-Port).
class Notifier {
  public:
    virtual ~Notifier() = default;
    virtual bool notify(const domain::example::Greeting& greeting) = 0;
};

}  // namespace hexagon::application::example::greet::ports

#endif  // HEXAGON_APPLICATION_EXAMPLE_GREET_PORTS_NOTIFIER_HPP
`

// cppHexCommand — Eingabe-Typ der greet-Slice (App-Schicht, importiert nichts).
const cppHexCommand = `// Application-Schicht (Use-Case-Slice greet): der Eingabe-Typ.
#ifndef HEXAGON_APPLICATION_EXAMPLE_GREET_COMMAND_HPP
#define HEXAGON_APPLICATION_EXAMPLE_GREET_COMMAND_HPP

#include <string>

namespace hexagon::application::example::greet {

// Command ist die Eingabe der greet-Use-Case.
struct Command {
    std::string message;
};

}  // namespace hexagon::application::example::greet

#endif  // HEXAGON_APPLICATION_EXAMPLE_GREET_COMMAND_HPP
`

// cppHexHandler — die Use-Case-Slice: app -> domain, app -> ports, NIE app -> adapters.
const cppHexHandler = `// Application-Schicht (Use-Case-Slice greet): app -> domain, app -> ports.
#ifndef HEXAGON_APPLICATION_EXAMPLE_GREET_HANDLER_HPP
#define HEXAGON_APPLICATION_EXAMPLE_GREET_HANDLER_HPP

#include <optional>
#include <string>

#include "src/hexagon/application/example/greet/command.hpp"
#include "src/hexagon/application/example/greet/ports/notifier.hpp"
#include "src/hexagon/application/example/ports/greeting_repository.hpp"
#include "src/hexagon/domain/example/greeting.hpp"

namespace hexagon::application::example::greet {

// Aliase, weil "ports" hier zweideutig waere: innerhalb dieser Slice loest der Name auf
// den SLICE-LOKALEN Port-Namensraum auf, nie auf den der Business-Area. Dieselbe
// Unterscheidung, die der Go-Renderer mit den Import-Aliasen areaports/sliceports macht.
namespace areaports = hexagon::application::example::ports;
namespace sliceports = hexagon::application::example::greet::ports;

// Handler fuehrt die greet-Use-Case aus: validieren, persistieren, annoncieren.
class Handler {
  public:
    Handler(areaports::GreetingRepository& repo, sliceports::Notifier& notifier)
        : repo_(repo), notifier_(notifier) {}

    // handle liefert die Nachricht des persistierten Greetings, oder nullopt, wenn die
    // Domain-Invariante oder ein Port fehlschlaegt.
    std::optional<std::string> handle(const Command& command) const {
        auto greeting = domain::example::Greeting::make(command.message);
        if (!greeting.has_value()) {
            return std::nullopt;
        }
        if (!repo_.save(*greeting) || !notifier_.notify(*greeting)) {
            return std::nullopt;
        }
        return greeting->message();
    }

  private:
    areaports::GreetingRepository& repo_;
    sliceports::Notifier& notifier_;
};

}  // namespace hexagon::application::example::greet

#endif  // HEXAGON_APPLICATION_EXAMPLE_GREET_HANDLER_HPP
`

// cppHexInboundCLI — Inbound-Adapter: treibt die Use-Case (adapters -> app).
const cppHexInboundCLI = `// Adapter-Schicht (inbound, CLI): treibt die Use-Case — adapters -> app.
#ifndef ADAPTERS_INBOUND_CLI_EXAMPLE_CLI_HPP
#define ADAPTERS_INBOUND_CLI_EXAMPLE_CLI_HPP

#include <ostream>
#include <string>

#include "src/hexagon/application/example/greet/command.hpp"
#include "src/hexagon/application/example/greet/handler.hpp"

namespace adapters::inbound::cli::example {

// Runner treibt die greet-Use-Case von der Kommandozeile.
class Runner {
  public:
    Runner(const hexagon::application::example::greet::Handler& handler, std::ostream& out)
        : handler_(handler), out_(out) {}

    // run fuehrt die Use-Case aus und schreibt das Ergebnis; false bei Fehlschlag.
    bool run(const std::string& message) const {
        auto result = handler_.handle({message});
        if (!result.has_value()) {
            return false;
        }
        out_ << *result << '\n';
        return true;
    }

  private:
    const hexagon::application::example::greet::Handler& handler_;
    std::ostream& out_;
};

}  // namespace adapters::inbound::cli::example

#endif  // ADAPTERS_INBOUND_CLI_EXAMPLE_CLI_HPP
`

// cppHexOutboundRepo — Outbound-Adapter: ERBT vom Area-Port (adapters -> ports, die
// Kante, die die Go-Config nicht braucht) und mappt auf Domain-Objekte.
const cppHexOutboundRepo = `// Adapter-Schicht (outbound, in-memory): erfuellt den Area-Port durch VERERBUNG —
// in C++ ist das ein Import (adapters -> ports), anders als bei Gos struktureller
// Interface-Erfuellung.
#ifndef ADAPTERS_OUTBOUND_MEMORY_EXAMPLE_REPOSITORY_HPP
#define ADAPTERS_OUTBOUND_MEMORY_EXAMPLE_REPOSITORY_HPP

#include <string>
#include <vector>

#include "src/hexagon/application/example/ports/greeting_repository.hpp"
#include "src/hexagon/domain/example/greeting.hpp"

namespace adapters::outbound::memory::example {

// Repository haelt Greetings im Speicher (Test-/Start-Adapter, netzlos).
class Repository final : public hexagon::application::example::ports::GreetingRepository {
  public:
    bool save(const hexagon::domain::example::Greeting& greeting) override {
        saved_.push_back(greeting.message());
        return true;
    }

    [[nodiscard]] const std::vector<std::string>& saved() const { return saved_; }

  private:
    std::vector<std::string> saved_;
};

}  // namespace adapters::outbound::memory::example

#endif  // ADAPTERS_OUTBOUND_MEMORY_EXAMPLE_REPOSITORY_HPP
`

// cppHexOutboundNotify — Outbound-Adapter auf den slice-lokalen Port.
const cppHexOutboundNotify = `// Adapter-Schicht (outbound, stdout): erfuellt den slice-lokalen Notifier-Port.
#ifndef ADAPTERS_OUTBOUND_NOTIFY_STDOUT_HPP
#define ADAPTERS_OUTBOUND_NOTIFY_STDOUT_HPP

#include <ostream>

#include "src/hexagon/application/example/greet/ports/notifier.hpp"
#include "src/hexagon/domain/example/greeting.hpp"

namespace adapters::outbound::notify {

// Writer annonciert ein Greeting auf einem Ausgabe-Stream.
class Writer final : public hexagon::application::example::greet::ports::Notifier {
  public:
    explicit Writer(std::ostream& out) : out_(out) {}

    bool notify(const hexagon::domain::example::Greeting& greeting) override {
        out_ << "notify: " << greeting.message() << '\n';
        return out_.good();
    }

  private:
    std::ostream& out_;
};

}  // namespace adapters::outbound::notify

#endif  // ADAPTERS_OUTBOUND_NOTIFY_STDOUT_HPP
`

// cppHexMain — Composition Root: verdrahtet Adapter, Ports und Use-Case-Slice. Er ist
// die einzige Uebersetzungseinheit des Programms und zieht damit JEDE Schicht in den
// Build (siehe cppRole: header-only ist genau dafuer gewaehlt).
const cppHexMain = `// Command app — vom ai-harness-init generiertes hexSlice-Skelett. Composition Root:
// verdrahtet Adapter, Ports und Use-Case-Slices (a-check-exempt).
#include <iostream>

#include "src/adapters/inbound/cli/example/cli.hpp"
#include "src/adapters/outbound/memory/example/repository.hpp"
#include "src/adapters/outbound/notify/stdout.hpp"
#include "src/hexagon/application/example/greet/handler.hpp"

int main() {
    adapters::outbound::memory::example::Repository repo;
    adapters::outbound::notify::Writer notifier(std::cout);
    const hexagon::application::example::greet::Handler handler(repo, notifier);
    const adapters::inbound::cli::example::Runner runner(handler, std::cout);
    return runner.run("Hallo vom generierten hexSlice-Skelett.") ? 0 : 1;
}
`

// cppHexTest — netzloser CTest-Fall ueber der Use-Case (kein externes Framework,
// LH-QA-03): er belegt die Domain-Invariante UND den Handler-Durchlauf.
const cppHexTest = `// Minimaler netzloser Test (kein externes Framework) ueber der greet-Use-Case.
#include <cstdlib>
#include <sstream>

#include "src/adapters/outbound/memory/example/repository.hpp"
#include "src/adapters/outbound/notify/stdout.hpp"
#include "src/hexagon/application/example/greet/handler.hpp"
#include "src/hexagon/domain/example/greeting.hpp"

int main() {
    if (hexagon::domain::example::Greeting::make("").has_value()) {
        return EXIT_FAILURE;  // leere Nachricht muss die Domain-Invariante verletzen
    }

    adapters::outbound::memory::example::Repository repo;
    std::ostringstream sink;
    adapters::outbound::notify::Writer notifier(sink);
    const hexagon::application::example::greet::Handler handler(repo, notifier);

    const auto result = handler.handle({"hi"});
    if (!result.has_value() || *result != "hi") {
        return EXIT_FAILURE;
    }
    if (repo.saved().size() != 1 || repo.saved().front() != "hi") {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
`

// cppHexTestCMakeLists — der Test des hexSlice-Layouts braucht src/ im Include-Pfad
// (die Schicht-Header werden ueber ihren kanonischen Pfad eingebunden).
const cppHexTestCMakeLists = `add_executable(app_test test_greet.cpp)
# Modul-Root, NICHT src/: die Schicht-Header binden einander modul-root-relativ ein
# ("src/hexagon/..."), damit das Architektur-Gate sie aufloest (siehe .a-check.yml).
target_include_directories(app_test PRIVATE ${CMAKE_SOURCE_DIR})
add_test(NAME app_test COMMAND app_test)
`

// cppHexArchConfig — die `.a-check.yml` des hexSlice-C++-Moduls (slice-053, LH-FA-07).
// MODUL-relativ (der Gate-Lauf mountet das Modul-Verzeichnis). Der eine substanzielle
// Unterschied zur Go-Fassung ist die `adapters -> ports`-Kante: C++ erfuellt einen Port
// durch VERERBUNG, also mit einem Include — waehrend Go ihn strukturell erfuellt.
const cppHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Die Schicht-Header binden einander MODUL-ROOT-RELATIV ein ("src/hexagon/…").
# Das ist keine Stilfrage: a-check loest NUR diese Form auf — relative ("../…") und
# praefixlose ("hexagon/…") Includes sind ihm unsichtbar, und das Gate waere dann
# still gruen (gemessen; LH-QA-01). Die CMakeLists traegt dafuer den Modul-Root im
# Include-Pfad.
#
# Die Slice-Globs (.../greet/**) und Port-Globs (.../ports/**) tragen bewusst
# literale Verzeichnis-Praefixe. Nur daran haengen die beiden Vertical-Slice-
# Regeln: lateral-slice (eine Slice importiert keine andere derselben Schicht)
# und port-locality (ein slice-lokaler Port bleibt in seiner Slice).
#
# DIESE DATEI IST DEINE: sie wird beim Re-Bootstrap nicht ueberschrieben, also
# waechst sie nur, wenn du sie pflegst. Zwei Faelle:
#   - Area/Slice UMBENANNT  -> die Globs mitziehen.
#   - Slice HINZUGEFUEGT    -> je einen app-Glob (.../<neue-slice>/**) und, falls
#     sie einen slice-lokalen Port hat, einen ports-Glob (.../<neue-slice>/ports/**)
#     ERGAENZEN. Vergisst du es, faellt der neue Code unter keine Schicht: importiert
#     er eine (Domain/Ports), meldet a-check wrong-direction und faellt — importiert
#     er keine, bleibt er still gruen und ungeprueft.
version: 1

languages:
  cpp: ["**/*.cpp", "**/*.hpp"]

layers:
  domain:
    globs: ["src/hexagon/domain/**"]
    role: domain
  ports:
    globs:
      - "src/hexagon/application/example/greet/ports/**"   # use-case-lokal
      - "src/hexagon/application/example/ports/**"         # business-area-geteilt
    role: port
  app:
    globs:
      - "src/hexagon/application/example/greet/**"         # Slice: greet
    role: app
  adapters:
    globs: ["src/adapters/**"]
    role: adapter

# Erlaubte gerichtete Abhaengigkeiten (nur nach innen). Ein Cross-Layer-Import
# ohne passende Kante ist ein Befund (wrong-direction).
edges:
  - {from: app,      to: domain}
  - {from: app,      to: ports}
  - {from: ports,    to: domain}
  - {from: adapters, to: app}      # der Inbound-Adapter treibt die Use-Case
  - {from: adapters, to: domain}   # Adapter mappen auf/von Domain-Objekten
  - {from: adapters, to: ports}    # C++-SPEZIFISCH: der Outbound-Adapter ERBT vom
                                   # Port und includiert ihn deshalb. Die Go-Fassung
                                   # hat diese Kante bewusst NICHT (strukturelle
                                   # Interface-Erfuellung ohne Import).

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["src/main.cpp"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "tests/**"
`

const cppCMakeLists = `cmake_minimum_required(VERSION 3.20)
project(app CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_compile_options(-Wall -Wextra -Wpedantic)

add_executable(app src/main.cpp)
# Modul-Root im Include-Pfad: Schicht-Header binden einander MODUL-ROOT-RELATIV ein
# ("src/hexagon/..."), weil das Architektur-Gate nur diese Form aufloest — relative
# und praefixlose Includes sind ihm unsichtbar, das Gate waere still gruen (gemessen;
# LH-QA-01, LH-FA-04-AC "Arch-Achse"). Fuer das flache Skelett ist die Zeile wirkungslos.
target_include_directories(app PRIVATE ${CMAKE_SOURCE_DIR})

enable_testing()
add_subdirectory(tests)
`

const cppTestCMakeLists = `add_executable(app_test test_main.cpp)
add_test(NAME app_test COMMAND app_test)
`

// cppClangTidy — konservativer Start-Satz (bugprone + clang-analyzer + eine Komplexitaets-
// Schranke), an cmake-xray/b-cad geeicht. Der lint-Gate ist rot/gruen (Modul 13): die
// lint-Stage laeuft clang-tidy mit --warnings-as-errors='*', jeder aktivierte Check wird
// sofort ein harter Fehler. Am trivialen Skelett feuert keiner (out-of-the-box gruen).
const cppClangTidy = `# .clang-tidy — generiert von ai-harness-init. Der lint-Gate ist rot/gruen (Modul 13):
# die lint-Stage laeuft clang-tidy mit --warnings-as-errors='*', jeder aktivierte Check
# ist ein harter Fehler. Konservativer Start-Satz; erweiterbar, wenn das Projekt waechst.
Checks: >
  -*,
  bugprone-*,
  clang-analyzer-*,
  readability-function-cognitive-complexity
WarningsAsErrors: ''
HeaderFilterRegex: '^src/'
FormatStyle: none
CheckOptions:
  - key: readability-function-cognitive-complexity.Threshold
    value: '25'
`

const cppDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (C++-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das Basis-Image ist TAG-gepinnt (LH-QA-02, kein
# floating). Digest bewusst weggelassen, damit CXX_VERSION (ubuntu-Tag) ein echter Knopf
# bleibt. Die Toolchain (build-essential/cmake/clang-tidy) kommt per apt im Bild-Build —
# das ist kein Host-Toolchain-Aufruf (der Guard blockt sie nur auf dem Host).
ARG CXX_VERSION={{CXX_VERSION}}

FROM ubuntu:${CXX_VERSION} AS toolchain
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /src
RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential cmake clang-tidy \
    && rm -rf /var/lib/apt/lists/*

FROM toolchain AS build
COPY . .
RUN cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build --parallel

FROM build AS test
RUN ctest --test-dir build --output-on-failure

FROM build AS lint
RUN clang-tidy --warnings-as-errors='*' -p build src/main.cpp
`

// cppMkFragmentTmpl — das C++-Code-Gate-Fragment (harness/mk/cpp.mk): lint/build/test als
// Dockerfile-Stages, an GATE_CHECKS gehaengt. Recipe-Zeilen sind TAB-eingerueckt.
const cppMkFragmentTmpl = `# harness/mk/cpp.mk — C++-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only, ADR-0003); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
CXX_VERSION ?= {{CXX_VERSION}}
IMAGE ?= app

.PHONY: test lint build

test: ## C++-Tests (ctest, Dockerfile test-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target test -t $(IMAGE):test .

lint: ## C++-Lint (clang-tidy, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target lint -t $(IMAGE):lint .

build: ## C++-Binary bauen (Dockerfile build-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// cppScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Build-Kontext {{CONTEXT}}, Image-Tag
// inline der Modul-Name. Recipe-Zeilen sind TAB-eingerueckt.
const cppScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — C++-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only, ADR-0003); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
CXX_VERSION ?= {{CXX_VERSION}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## C++-Tests Modul {{MODULE}} (test-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## C++-Lint Modul {{MODULE}} (clang-tidy, lint-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## C++-Binary Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
