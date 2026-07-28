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
	// roleHexagonalCore — der Kern des hexagonal-Layouts (Domaene UND Use-Case in EINER
	// geprueften Schicht, `role: app`; importiert seine Ports, nie einen Adapter — ADR-0010).
	roleHexagonalCore codeRole = "hexagonal-core"
	// roleHexagonalPort — die Port-Schicht des hexagonal-Layouts: IMPORTFREI (darum
	// sprechen ihre Signaturen Standardtypen; es gibt keine Kante ports->core, sie waere
	// mit core->ports ein Import-Zyklus — ADR-0010).
	roleHexagonalPort codeRole = "hexagonal-port"
	// roleHexagonalDriven — die getriebenen Adapter (internal/adapter/driven/**): sie
	// erfuellen die Ports und bilden auf Kern-Typen ab (driven->ports, driven->core).
	roleHexagonalDriven codeRole = "hexagonal-driven"
	// roleHexagonalDriving — die treibenden Adapter (internal/adapter/driving/**): sie
	// rufen den Kern (driving->core). Bei uns eine GEPRUEFTE Schicht, nicht Composition
	// Root — ADR-0010 Festlegung 3 (fail-closed bei unbekannten Adoptern).
	roleHexagonalDriving codeRole = "hexagonal-driving"
	// roleHexagonalRoot — der Composition Root des hexagonal-Layouts (cmd/**): eigene
	// Rolle, weil der Inhalt layout-spezifisch ist (hier entsteht der getriebene Adapter,
	// wird in die Use-Case injiziert und diese an den treibenden Adapter uebergeben —
	// ADR-0010 §Wo verdrahtet wird). a-check-exempt wie roleCompositionRoot.
	roleHexagonalRoot codeRole = "hexagonal-composition-root"
)

// archFlat ist die heutige, flache Architektur (ein Entry-Point, kein Schichten-Layout).
const archFlat = "flat"

// archHexslice ist das schichten-tragende HexSlice-Layout (Hexagonal + Vertical Slice,
// ADR-0009): domain / application (Use-Case-Slices) / ports / adapters + Composition Root.
const archHexslice = "hexslice"

// archHexagonal ist das schichten-tragende hexagonal-Layout (ADR-0010): core / port /
// adapter (driven + driving) + Composition Root — die drei klassischen Schichten OHNE
// Use-Case-Slices. Eigenes Layout, kein Strenge-Grad von hexslice: die Verzeichnisnamen
// sind disjunkt (ADR-0010 Festlegung 2), was TestArchLayouts_Disjunkt festhaelt.
const archHexagonal = "hexagonal"

// archLayout liefert die Code-Rollen einer Architektur in STABILER Reihenfolge.
// `flat` traegt Entry-Point + Test; `hexslice` und `hexagonal` tragen je ihre vier
// Schicht-Rollen + ihren Composition Root (der Sprach-Renderer fuellt jede Rolle).
// Unbekannte Architektur -> nil: GenerateArch macht daraus den *UnknownArchError (analog
// UnknownLangError), slice-045b haengt die `--arch`-CLI-Validierung (Exit 2) daran.
func archLayout(arch string) []codeRole {
	switch arch {
	case "", archFlat:
		return []codeRole{roleEntrypoint, roleTest}
	case archHexslice:
		return []codeRole{roleDomain, rolePorts, roleAppSlice, roleAdapters, roleCompositionRoot}
	case archHexagonal:
		return []codeRole{roleHexagonalCore, roleHexagonalPort, roleHexagonalDriven, roleHexagonalDriving, roleHexagonalRoot}
	}
	return nil
}

// archLayered sagt, ob eine Architektur SCHICHTEN traegt — STRUKTURELL aus dem Layout
// abgeleitet: traegt es mindestens eine Rolle, die weder Entry-Point noch Toolchain-Test
// noch Composition Root ist? Genau das ist eine gepruefte Schicht. Bis slice-058 fragte
// die Bedingung nach der hexslice-Rolle `domain` — ein NAME, kein Struktur-Merkmal: ein
// zweites geschichtetes Layout mit anderem Vokabular (hexagonal: core/port/adapter) waere
// „nicht geschichtet" gewesen und haette sein Arch-Gate lautlos verloren
// (LH-QA-01, ADR-0010 Folgepflicht 1).
//
// Das ist die LH-QA-01-Bedingung des Arch-Gates (slice-046): nur ueber einem
// schichten-tragenden Layout hat a-check einen nicht-leeren Pruefbereich; `flat`
// bekommt darum kein Gate. Der Wert dieser Funktion wird NICHT von den Wächtern
// befragt, die sie bewachen — TestArchGateConfig_CoversEveryLayeredCombo leitet
// „geschichtet" aus dem gerenderten Baum ab, sonst waere er tautologisch.
func archLayered(arch string) bool {
	for _, r := range archLayout(arch) {
		if isLayerRole(r) {
			return true
		}
	}
	return false
}

// isLayerRole sagt, ob eine Rolle eine GEPRUEFTE SCHICHT ist. Nicht-Schichten sind der
// ausfuehrbare Entry-Point des flachen Skeletts, der Toolchain-Test und jeder Composition
// Root (a-check-exempt, cmd/**) — alles andere ist Schicht. Ein neues Layout bringt
// hoechstens einen weiteren Composition Root mit; jede seiner uebrigen Rollen ist per
// Default Schicht (fail-closed: ein vergessener Eintrag macht ein Layout „geschichtet",
// nicht lautlos gate-los).
func isLayerRole(r codeRole) bool {
	switch r {
	case roleEntrypoint, roleTest, roleCompositionRoot, roleHexagonalRoot:
		return false
	}
	return true
}

// ArchGateConfig liefert die `.a-check.yml` des Moduls fuer (lang, arch) und ok=false,
// wenn diese Kombination KEIN Arch-Gate traegt (slice-046, LH-FA-07): `flat` (kein
// Pruefbereich, LH-QA-01), eine sprach-fremde Architektur oder ein Renderer ohne
// hinterlegte Config. Die Config gehoert zum LAYOUT-Wissen — sie lebt in derselben
// Quelle wie die Rollen-Pfade, damit Schicht-Globs und generierte Verzeichnisse nicht
// auseinanderdriften (ADR-0009 Fitness-Function; TestArchGateConfig_MatchesSkeleton
// haelt die Kopplung fest). Der Inhalt ist MODUL-RELATIV: der Gate-Lauf mountet das
// Modul-Verzeichnis, darum traegt die Config keinen <pfad>-Praefix.
func ArchGateConfig(lang, arch string) (string, bool) {
	if !archLayered(arch) || !archSupported(lang, arch) {
		return "", false
	}
	cfg, ok := archGateConfigs()[lang][arch]
	return cfg, ok
}

// archGateConfigs bildet Sprache -> Architektur -> `.a-check.yml`-Inhalt. Ein fehlender
// Eintrag heisst „kein Arch-Gate" — TestArchGateConfig_CoversEveryLayeredCombo verhindert,
// dass eine schichten-tragende (lang, arch)-Kombination hier still ohne Config bleibt und
// das Gate lautlos ausfaellt.
func archGateConfigs() map[string]map[string]string {
	return map[string]map[string]string{
		"go":  {archHexslice: goHexArchConfig, archHexagonal: goHexagonalArchConfig},
		"cpp": {archHexslice: cppHexArchConfig},
	}
}

// SupportedArchs liefert das Achsen-VOKABULAR sortiert — den Union aller Architekturen,
// die irgendein Sprach-Renderer traegt (aus langArchs abgeleitet, kein Doppel-Pflegepunkt).
// Fuer Hilfetexte und die Unknown-Arch-Liste bei einem Tippfehler (slice-045b). Welche
// Architektur eine KONKRETE Sprache rendert, sagt archsForLang (per-Sprache, enger).
func SupportedArchs() []string {
	set := map[string]bool{}
	for _, archs := range langArchs() {
		for _, a := range archs {
			set[a] = true
		}
	}
	out := make([]string, 0, len(set))
	for a := range set {
		out = append(out, a)
	}
	sort.Strings(out)
	return out
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
