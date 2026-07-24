package gen

// Kompositions-Seam (ADR-0008): das Skelett entsteht aus der arch-INVARIANTEN
// Bau-/Toolchain-Gerueestung (go.mod/Dockerfile/CMakeLists … — immer praesent,
// unabhaengig von der Architektur) PLUS dem arch-gegateten Code-Layout. Das
// Arch-Layout waehlt, WELCHE Code-Rollen ein Skelett traegt; der Sprach-Renderer
// fuellt jede Rolle mit Dateien in seiner Sprache. So komponiert der Generator
// `lang-renderer × arch-layout` — N Sprachen + M Architekturen, nicht N×M Profile.
//
// Diese Stufe (slice-044) etabliert nur die Seam mit dem EINEN Layout `flat` (dem
// heutigen Skelett, byte-identisch); slice-045 setzt `hexagonal` (domain/ports/
// adapters) + die `--arch`-Achse darauf.

// codeRole benennt die strukturelle Rolle einer Skelett-CODE-Datei (im Gegensatz
// zur arch-invarianten Gerueestung). Das Arch-Layout ist die Menge der Rollen;
// der Sprach-Renderer rendert jede Rolle in {relpfad: inhalt}.
type codeRole string

const (
	// roleEntrypoint — der ausfuehrbare Einstieg (go: cmd/app/main.go; cpp: src/main.cpp).
	roleEntrypoint codeRole = "entrypoint"
	// roleTest — der Toolchain-Test (cpp: tests/…; go traegt im flachen Skelett heute keinen).
	roleTest codeRole = "test"
)

// archFlat ist die heutige, flache Architektur (ein Entry-Point, kein Schichten-
// Layout) — der einzige Wert dieser Stufe. slice-045 fuegt "hexagonal" hinzu.
const archFlat = "flat"

// archLayout liefert die Code-Rollen einer Architektur in STABILER Reihenfolge.
// `flat` traegt Entry-Point + Test; ein geschichtetes Layout (hexagonal, slice-045)
// ergaenzt domain/ports/adapters-Rollen. Unbekannte Architektur -> nil: slice-045
// macht daraus die `--arch`-Validierung (analog UnknownLangError). Heute ist der
// Aufrufer sprach-intern auf archFlat fixiert (kein CLI-Flag in dieser Stufe).
func archLayout(arch string) []codeRole {
	switch arch {
	case "", archFlat:
		return []codeRole{roleEntrypoint, roleTest}
	}
	return nil
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
