package gen

import "sort"

// Kompositions-Seam (ADR-0008): das Skelett entsteht aus der arch-INVARIANTEN
// Bau-/Toolchain-Gerueestung (go.mod/Dockerfile/CMakeLists … — immer praesent,
// unabhaengig von der Architektur) PLUS dem arch-gegateten Code-Layout. Das
// Arch-Layout waehlt, WELCHE Code-Rollen ein Skelett traegt; der Sprach-Renderer
// fuellt jede Rolle mit Dateien in seiner Sprache. So komponiert der Generator
// `lang-renderer × arch-layout` — N Sprachen + M Architekturen, nicht N×M Profile.
//
// Stufe slice-044 etablierte die Seam mit dem EINEN Layout `flat` (dem heutigen
// Skelett, byte-identisch); slice-045a setzt das `hexslice`-Layout (HexSlice =
// Hexagonal + Vertical Slice, ADR-0009) + den Go-Rollen-Renderer darauf. slice-045b
// verdrahtet die `--arch`-CLI-Achse.

// codeRole benennt die strukturelle Rolle einer Skelett-CODE-Datei (im Gegensatz
// zur arch-invarianten Gerueestung). Das Arch-Layout ist die Menge der Rollen;
// der Sprach-Renderer rendert jede Rolle in {relpfad: inhalt}.
type codeRole string

const (
	// roleEntrypoint — der ausfuehrbare Einstieg des flachen Skeletts (go: cmd/app/main.go;
	// cpp: src/main.cpp).
	roleEntrypoint codeRole = "entrypoint"
	// roleTest — der Toolchain-Test des flachen Skeletts (cpp: tests/…; go traegt im
	// flachen Skelett heute keinen).
	roleTest codeRole = "test"
	// roleDomain — die Domain-Schicht des hexSlice-Layouts (importiert nur sich selbst).
	roleDomain codeRole = "domain"
	// rolePorts — die Port-Schicht (Area- + slice-lokale Ports; importiert nur die Domain).
	rolePorts codeRole = "ports"
	// roleAppSlice — die Application-Use-Case-Slice (importiert Domain + Ports, nie Adapter).
	roleAppSlice codeRole = "app-slice"
	// roleAdapters — die Adapter-Schicht (Inbound + Outbound; treibt die App bzw. erfuellt
	// die Ports strukturell).
	roleAdapters codeRole = "adapters"
	// roleCompositionRoot — der Composition Root (cmd/**), der Adapter/Ports/Slices
	// verdrahtet; a-check-exempt.
	roleCompositionRoot codeRole = "composition-root"
)

// archFlat ist die heutige, flache Architektur (ein Entry-Point, kein Schichten-Layout).
const archFlat = "flat"

// archHexslice ist das schichten-tragende HexSlice-Layout (Hexagonal + Vertical Slice,
// ADR-0009): domain / application (Use-Case-Slices) / ports / adapters + Composition Root.
const archHexslice = "hexslice"

// archLayout liefert die Code-Rollen einer Architektur in STABILER Reihenfolge.
// `flat` traegt Entry-Point + Test; `hexslice` traegt die vier Schicht-Rollen + den
// Composition Root (der Sprach-Renderer fuellt jede Rolle). Unbekannte Architektur ->
// nil: GenerateArch macht daraus den *UnknownArchError (analog UnknownLangError),
// slice-045b haengt die `--arch`-CLI-Validierung (Exit 2) daran.
func archLayout(arch string) []codeRole {
	switch arch {
	case "", archFlat:
		return []codeRole{roleEntrypoint, roleTest}
	case archHexslice:
		return []codeRole{roleDomain, rolePorts, roleAppSlice, roleAdapters, roleCompositionRoot}
	}
	return nil
}

// SupportedArchs liefert die unterstuetzten Architektur-Werte sortiert — fuer Hilfetexte
// und die Unknown-Arch-Liste (slice-045b: die `--arch`-Fehlermeldung). Der Go-Renderer
// ist heute der einzige mit einem hexslice-Layout (slice-045a); weitere Sprachen folgen
// linear (LH-FA-04).
func SupportedArchs() []string {
	archs := []string{archFlat, archHexslice}
	sort.Strings(archs)
	return archs
}

// composeSkeleton komponiert die arch-invariante Gerueestung mit den Rollen des
// Arch-Layouts zum vollen {relpfad: inhalt}-Skelett. Deterministisch (LH-QA-02):
// Generate schreibt sortiert, die Map-Merge-Reihenfolge ist unsichtbar. Gerueestung
// und Rollen tragen DISJUNKTE Pfade (eine Rolle ueberschreibt die Gerueestung nie);
// die Byte-Identitaet des `flat`-Skeletts belegen TestGenerate_GoProfile/CppProfile.
func composeSkeleton(scaffolding func(version string) map[string]string, role func(codeRole) map[string]string, version, arch string) map[string]string {
	out := scaffolding(version)
	for _, r := range archLayout(arch) {
		for rel, content := range role(r) {
			out[rel] = content
		}
	}
	return out
}
