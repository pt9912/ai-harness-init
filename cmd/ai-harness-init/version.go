package main

import (
	"fmt"
	"io"
)

// fassung traegt die Fassung des geschnittenen Tags, die der Release-Bau per
// ldflags -X main.fassung injiziert (ADR-0063 Festlegung 1). Der Default ist
// LEER, und das ist die Zusage, keine Ausnahme: ein Bau ohne uebergebenen
// Fassungs-Wert injiziert nicht — er meldet auf --version den Fehlt-Fall laut,
// nie einen leeren String und nie den Pin-Stand des Makefiles (der ist der Stand
// des letzten Schnitts, nicht der des Bau-Moments; ADR-0063 Festlegung 2). Die
// Injektion hat ihren eigenen Namen (TRAEGER_VERSION), den der Release-Workflow
// auf denselben Wert setzt wie den Pin-Zug — TRAEGER_TAG bleibt die Fetch-Achse
// und liest hier nichts.
var fassung string

// versionFehltMeldung ist der dokumentierte Wortlaut des Fehlt-Falls (ADR-0063
// Festlegung 2): eine Meldung ueber den Zustand des Binary, kein Fehler des
// Repos — dieselbe Lesart wie der Fehlt-Fall des Traegers, nur mit dem Exit, den
// die Festlegung setzt. Der Wortlaut ist der Anker der Skriptbarkeit und steht
// verbatim im Handbuch (Weg A und Weg B); er nennt dem Installierer den Zustand
// ohne repo-interne Referenz. Unter der geschwaechten Zusage (leere Ausgabe,
// Pin-Wert statt Meldung, Exit 0) faellt TestVersionFehltFallIstLaut rot.
const versionFehltMeldung = "ai-harness-init: keine Fassung injiziert — dieser Bau traegt keinen geschnittenen Tag; die Fassung kommt nur mit einem Release-Bau."

// runVersion meldet die Fassung des Binaries oder ihren Fehlt-Fall (ADR-0063
// Festlegung 2): mit Injektion den Tag auf stdout und Exit 0, ohne Injektion den
// dokumentierten Wortlaut auf stderr und Exit 2. stdout bleibt im Fehlt-Fall
// leer — ein leeres stdout mit Exit 0 waere der stille Ausgang, der laut-Befund
// ablöst.
func runVersion(stdout, stderr io.Writer) int {
	if fassung == "" {
		fmt.Fprintln(stderr, versionFehltMeldung)
		return 2
	}
	fmt.Fprintln(stdout, fassung)
	return 0
}