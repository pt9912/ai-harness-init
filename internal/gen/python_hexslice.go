package gen

// Das hexSlice-Layout fuer Python (ADR-0095 Festlegung 5): die Schichten sind Verzeichnisse
// unter src/app, der Dateipfad ist das Modul. Die Schicht-Dateien referenzieren einander
// ausschliesslich ueber absolute `from app.… import …`-Zeilen; genau diese Form loest die
// a-check-Config (resolution python, fixed-root mit package_base app) auf einen Pfad auf.
// Ein relativer Import erkennt a-check nicht; ihn schliesst die ruff-Regel TID252 der
// pyproject.toml. Jedes Paket-Verzeichnis traegt eine leere __init__.py: mypy bildet den
// Modulnamen ueber sie.

const pyHexSrc = "src/app/"

// pyFiles rendert die Dateien einer Rolle: je Verzeichnis in dirs (relativ zu pyHexSrc) eine
// leere __init__.py, dazu die Paare (Pfad relativ zu pyHexSrc, Inhalt) aus kv.
func pyFiles(dirs []string, kv ...string) map[string]string {
	out := map[string]string{}
	for _, d := range dirs {
		out[pyHexSrc+d+"/__init__.py"] = ""
	}
	for i := 0; i+1 < len(kv); i += 2 {
		out[pyHexSrc+kv[i]] = kv[i+1]
	}
	return out
}

// pythonHexslice rendert eine Rolle des hexSlice-Layouts; jede andere Rolle -> nil. Die
// __init__.py eines Verzeichnisses gehoert der Rolle, deren Schicht das Verzeichnis traegt.
func pythonHexslice(r codeRole) map[string]string {
	const area = "hexagon/application/example/"
	switch r {
	case roleDomain:
		return pyFiles([]string{"hexagon", "hexagon/domain", "hexagon/domain/example"},
			"hexagon/domain/example/greeting.py", pyHexDomain)
	case rolePorts:
		return pyFiles([]string{
			area + "greet/ports", area + "greet/ports/inbound", area + "greet/ports/outbound",
			area + "ports", area + "ports/outbound",
		},
			area+"greet/ports/inbound/greet.py", pyHexInboundPort,
			area+"greet/ports/outbound/notifier.py", pyHexSlicePort,
			area+"ports/outbound/greeting_repository.py", pyHexAreaPort)
	case roleAppSlice:
		return pyFiles([]string{"hexagon/application", "hexagon/application/example", area + "greet"},
			area+"greet/handler.py", pyHexHandler)
	case roleAdapters:
		return pyFiles([]string{
			"adapters", "adapters/driving", "adapters/driving/cli", "adapters/driving/cli/example",
			"adapters/driven", "adapters/driven/memory", "adapters/driven/memory/example", "adapters/driven/notify",
		},
			"adapters/driving/cli/example/cli.py", pyHexDrivingCLI,
			"adapters/driven/memory/example/in_memory_repository.py", pyHexDrivenRepo,
			"adapters/driven/notify/stdout_notifier.py", pyHexDrivenNotify)
	case roleCompositionRoot:
		out := pyFiles(nil, "main.py", pyHexMain)
		out["tests/test_greet.py"] = pyHexTest
		return out
	}
	return nil
}
const pyHexDomain = `"""Domain-Schicht des generierten hexSlice-Skeletts: importiert keine andere Schicht."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Greeting:
    message: str


def new_greeting(message: str) -> Greeting | None:
    """Liefert None fuer eine leere Nachricht — die Invariante der Domain."""
    if not message.strip():
        return None
    return Greeting(message)
`

const pyHexInboundPort = `"""Port-Schicht (inbound, greet): der Vertrag, ueber den die Welt die Use-Case ruft.

Er spricht schlichte Typen und importiert die Domain nicht.
"""

from typing import Protocol


class Greet(Protocol):
    def greet(self, message: str) -> str | None: ...
`

const pyHexSlicePort = `"""Port-Schicht (outbound, slice-lokal, greet): der Kanal, ueber den die Use-Case meldet."""

from typing import Protocol


class Notifier(Protocol):
    def send(self, message: str) -> None: ...
`

const pyHexAreaPort = `"""Port-Schicht (outbound, business-area-geteilt): importiert nur die Domain."""

from typing import Protocol

from app.hexagon.domain.example.greeting import Greeting


class GreetingRepository(Protocol):
    def save(self, greeting: Greeting) -> None: ...
`

const pyHexHandler = `"""Application-Schicht (Use-Case-Slice greet): app -> domain, app -> ports, nie Adapter."""

from app.hexagon.application.example.greet.ports.inbound.greet import Greet
from app.hexagon.application.example.greet.ports.outbound.notifier import Notifier
from app.hexagon.application.example.ports.outbound.greeting_repository import (
    GreetingRepository,
)
from app.hexagon.domain.example.greeting import new_greeting


class Handler(Greet):
    def __init__(self, repository: GreetingRepository, notifier: Notifier) -> None:
        self._repository = repository
        self._notifier = notifier

    def greet(self, message: str) -> str | None:
        greeting = new_greeting(message)
        if greeting is None:
            return None
        self._repository.save(greeting)
        self._notifier.send(greeting.message)
        return greeting.message
`

const pyHexDrivingCLI = `"""Adapter-Schicht (driving, CLI): spricht die Use-Case nur ueber ihren inbound-Port."""

from app.hexagon.application.example.greet.ports.inbound.greet import Greet


class Cli:
    def __init__(self, greet: Greet) -> None:
        self._greet = greet

    def run(self, message: str) -> bool:
        return self._greet.greet(message) is not None
`

const pyHexDrivenRepo = `"""Adapter-Schicht (driven, In-Memory): erfuellt den Area-Port durch Vererbung und
importiert ihn deshalb (die driven_adapters -> ports_outbound-Kante der Config)."""

from app.hexagon.application.example.ports.outbound.greeting_repository import (
    GreetingRepository,
)
from app.hexagon.domain.example.greeting import Greeting


class InMemoryRepository(GreetingRepository):
    def __init__(self) -> None:
        self._stored: list[Greeting] = []

    def saved(self) -> list[Greeting]:
        return list(self._stored)

    def save(self, greeting: Greeting) -> None:
        self._stored.append(greeting)
`

const pyHexDrivenNotify = `"""Adapter-Schicht (driven, Ausgabe): erfuellt den slice-lokalen Notifier-Port."""

from typing import TextIO

from app.hexagon.application.example.greet.ports.outbound.notifier import Notifier


class StdoutNotifier(Notifier):
    def __init__(self, out: TextIO) -> None:
        self._out = out

    def send(self, message: str) -> None:
        print(message, file=self._out)
`

// pyHexMain — Composition Root: verdrahtet Adapter, Ports und Use-Case-Slice; die
// a-check-Config fuehrt ihn als composition_root.
const pyHexMain = `"""Command app — vom ai-harness-init generiertes hexSlice-Skelett.

Composition Root: verdrahtet Adapter, Ports und Use-Case-Slices (a-check-exempt).
"""

import sys

from app.adapters.driven.memory.example.in_memory_repository import InMemoryRepository
from app.adapters.driven.notify.stdout_notifier import StdoutNotifier
from app.adapters.driving.cli.example.cli import Cli
from app.hexagon.application.example.greet.handler import Handler


def main() -> int:
    handler = Handler(InMemoryRepository(), StdoutNotifier(sys.stdout))
    return 0 if Cli(handler).run("Hallo vom generierten hexSlice-Skelett.") else 1


if __name__ == "__main__":
    sys.exit(main())
`

// pyHexTest — Test ueber pytest: die Domain-Invariante und der Durchlauf der Use-Case ueber
// beide getriebenen Adapter.
const pyHexTest = `"""Minimaler Test ueber pytest — Domain-Invariante und greet-Use-Case."""

import io

from app.adapters.driven.memory.example.in_memory_repository import InMemoryRepository
from app.adapters.driven.notify.stdout_notifier import StdoutNotifier
from app.hexagon.application.example.greet.handler import Handler
from app.hexagon.domain.example.greeting import new_greeting


def test_leere_nachricht_verletzt_die_invariante() -> None:
    assert new_greeting("") is None


def test_handler_speichert_und_meldet() -> None:
    repository = InMemoryRepository()
    sink = io.StringIO()
    handler = Handler(repository, StdoutNotifier(sink))
    assert handler.greet("hi") == "hi"
    assert [g.message for g in repository.saved()] == ["hi"]
    assert sink.getvalue() == "hi\n"
`

// pythonHexArchConfig — die .a-check.yml des hexSlice-Python-Moduls (ADR-0095 Festlegung 5,
// LH-FA-07). MODUL-relativ (der Gate-Lauf mountet das Modul-Verzeichnis). Der
// resolution-Block ist tragend: ohne ihn loest kein `from app.… import …` auf eine
// Schicht auf, und das Gate bleibt ueber jedem Import gruen. Der Root endet im
// package_base-Verzeichnis, weil a-check `app.` vom Import abstreift, bevor es den Root voranstellt.
// Die Ports-Ordner (use-case-lokal inbound/outbound, area-geteilt outbound) und die
// Kanten-Menge sind die der Java-Fassung; die driven_adapters -> ports_outbound-Kante folgt der
// Erfuellung des Ports durch Vererbung.
const pythonHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Der Dateipfad ist das Modul: a-check loest einen Import
# (from app.adapters.driven.notify.stdout_notifier import StdoutNotifier) ueber den PFAD auf —
# es streift package_base ("app.") ab, ersetzt die Punkte durch "/" und stellt den Root
# voran (src/app/adapters/driven/notify/stdout_notifier.py). Der Root endet darum im
# package_base-Verzeichnis; ein Root src loest keinen Import auf, und a-check meldet dann
# "0 von N Import-Symbolen loesen auf". Nicht erkannt werden ein relativer Import (ihn
# schliesst die ruff-Regel TID252 der pyproject.toml), ein voll qualifizierter Name ohne
# Import und ein dynamischer Import (importlib.import_module).
#
# Die leeren __init__.py ausserhalb der Schichten (src/app/__init__.py, hexagon/, application/ ...)
# erscheinen im Hinweis "gescannte Dateien liegen in keiner Schicht": sie tragen keinen Import.
# Traegt eine davon einen, ist sie ungeprueft, bis eine Schicht sie deckt.
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
  python: ["**/*.py"]

layers:
  domain:
    globs: ["src/app/hexagon/domain/**"]
    role: domain
  ports_inbound:
    globs:
      - "src/app/hexagon/application/example/greet/ports/inbound/**"   # use-case-lokal
    role: port
    direction: inbound      # von der Use-Case angeboten; ein driving Adapter ruft ihn
  ports_outbound:
    globs:
      - "src/app/hexagon/application/example/greet/ports/outbound/**"   # use-case-lokal
      - "src/app/hexagon/application/example/ports/outbound/**"         # business-area-geteilt
    role: port
    direction: outbound     # von der Use-Case gebraucht; ein driven Adapter erfuellt ihn
  app:
    globs:
      - "src/app/hexagon/application/example/greet/**"         # Slice: greet
    role: app
  driving_adapters:
    globs: ["src/app/adapters/driving/**"]
    role: adapter
    direction: driving      # ruft den Anwendungskern
  driven_adapters:
    globs: ["src/app/adapters/driven/**"]
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
  - {from: driven_adapters,  to: ports_outbound}   # der getriebene Adapter erbt vom Port
                                                   # (Protocol) und importiert ihn.

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["src/app/main.py"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "tests/**"

# Modul -> Pfad: package_base wird vom Import abgestreift, der Root vorangestellt.
resolution:
  python:
    mode: fixed-root
    roots: ["src/app"]
    package_base: "app"
`
