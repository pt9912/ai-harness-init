package gen

// jvmLayout ordnet die Code-Rollen eines JVM-Renderers (flat und hexSlice) ihren Dateien zu. Kotlin
// und Java teilen die Verzeichnis-Form (ADR-0088/ADR-0094 Festlegung 4, ADR-0060): Schichten
// sind Pakete unter srcMain, Paket == Verzeichnis, Dateinamen sind die Typnamen plus ext;
// nur die Inhalte der Dateien sind sprachspezifisch.
type jvmLayout struct {
	srcMain, srcTest string // mit abschliessendem "/", z. B. "src/main/java/app/"
	ext              string // mit Punkt, z. B. ".java"

	domain, inboundPort, slicePort, areaPort, handler string // Inhalte: Domain-, Port- und Application-Schicht
	cli, repo, notify                                 string // Inhalte: Adapter-Schicht
	main, test                                        string // Inhalte: Composition Root und Test
	flatMain, flatTest                                string // Inhalte: Entry-Point und Test des flat-Layouts
}

// role rendert eine Rolle von flat oder hexSlice; eine andere Rolle (hexagonal) -> nil.
func (h jvmLayout) role(r codeRole) map[string]string {
	hex := h.srcMain + "hexagon/"
	adapters := h.srcMain + "adapters/"
	e := h.ext
	switch r {
	case roleEntrypoint:
		return map[string]string{h.srcMain + "Main" + e: h.flatMain}
	case roleTest:
		return map[string]string{h.srcTest + "MainTest" + e: h.flatTest}
	case roleDomain:
		return map[string]string{hex + "domain/example/Greeting" + e: h.domain}
	case rolePorts:
		return map[string]string{
			hex + "application/example/greet/ports/inbound/Greet" + e:          h.inboundPort,
			hex + "application/example/greet/ports/outbound/Notifier" + e:      h.slicePort,
			hex + "application/example/ports/outbound/GreetingRepository" + e: h.areaPort,
		}
	case roleAppSlice:
		return map[string]string{hex + "application/example/greet/Handler" + e: h.handler}
	case roleAdapters:
		return map[string]string{
			adapters + "driving/cli/example/Cli" + e:                   h.cli,
			adapters + "driven/memory/example/InMemoryRepository" + e: h.repo,
			adapters + "driven/notify/StdoutNotifier" + e:             h.notify,
		}
	case roleCompositionRoot:
		return map[string]string{
			h.srcMain + "Main" + e:      h.main,
			h.srcTest + "GreetTest" + e: h.test,
		}
	}
	return nil
}
