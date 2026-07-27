// Package gen erzeugt Sprachskelette DETERMINISTISCH aus tool-eigenem
// Layout-Wissen (ADR-0005 Herkunftsklasse "Tool-als-Quelle"), statt sie zu
// fetchen. Ein Layout-Profil je Sprache; go war das erste, cpp das zweite
// (slice-039) — weitere folgen aus LH-FA-04 als neuer Eintrag, ohne Umbau der
// Mechanik. Die „Toolchain-Version" (version) ist per Sprache verschieden (go:
// Go-Version; cpp: ubuntu-Base-Tag) — das Profil interpretiert sie, der Aufrufer
// faedelt sie generisch (SKEL_<LANG>_VERSION -> DefaultVersion(lang)).
//
// Determinismus (LH-QA-02): der Inhalt jedes Profils ist STATISCH (Konstanten,
// kein Zeitstempel, keine Map-Iteration im Datei-INHALT), und Generate schreibt
// in sortierter Reihenfolge. Zwei Laeufe mit derselben Sprache liefern
// byte-identische Dateien — der Test belegt es, die Konstruktion garantiert es.
package gen

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// UnknownLangError meldet eine Sprache ohne Profil samt der sortierten Liste der
// unterstuetzten. Uebernimmt die Rolle des frueheren fetch.UnknownLangError: die
// --lang-Validierung wandert mit slice-023 vom Skelett-Fetch zum Generator (sie
// darf nicht ersatzlos verschwinden). Als Typ (via errors.As unterscheidbar),
// damit der Aufrufer den Aufruf-Fehler (Exit 2) vom Emit-Fehler trennt.
type UnknownLangError struct {
	Lang      string
	Available []string
}

func (e *UnknownLangError) Error() string {
	return fmt.Sprintf("unbekannte Sprache %q; verfuegbar: %s", e.Lang, strings.Join(e.Available, ", "))
}

// UnknownArchError meldet eine Architektur ohne Layout samt der sortierten Liste der
// unterstuetzten (slice-045a). Symmetrisch zu UnknownLangError: als Typ (via errors.As
// unterscheidbar), damit slice-045b den Aufruf-Fehler (Exit 2) sauber vom Emit-Fehler
// trennt. Der Generator selbst emittiert bei unbekannter Architektur nichts, statt still
// ein Gerueestung-only-Skelett zu schreiben.
type UnknownArchError struct {
	Arch      string
	Available []string
}

func (e *UnknownArchError) Error() string {
	return fmt.Sprintf("unbekannte Architektur %q; verfuegbar: %s", e.Arch, strings.Join(e.Available, ", "))
}

// Generate schreibt das FLACHE Skelett fuer lang nach destDir (Rueckwaerts-API: der
// heutige --lang-One-Shot ruft es unveraendert). Aequivalent zu GenerateArch(…, "flat").
func Generate(destDir, lang, version string) error {
	return GenerateArch(destDir, lang, version, archFlat)
}

// GenerateArch schreibt das Skelett fuer (lang, arch) nach destDir — in sortierter (also
// deterministischer) Reihenfolge. version ist die Toolchain-Version des Profils (go: die
// Go-Version; cpp: der ubuntu-Base-Tag); der Generator bleibt REIN — gleiche (lang, version,
// arch) liefert byte-identische Ausgabe (LH-QA-02), die Aufloesung der Werte (Default/Env/
// CLI) macht der Aufrufer (cmd, slice-045b). Eine Sprache ohne Profil -> *UnknownLangError,
// eine Architektur ohne Layout -> *UnknownArchError (je mit sortierter Liste), statt
// stillschweigend nichts bzw. ein Gerueestung-only-Skelett zu schreiben.
func GenerateArch(destDir, lang, version, arch string) error {
	build, ok := profiles()[lang]
	if !ok {
		return &UnknownLangError{Lang: lang, Available: SupportedLangs()}
	}
	// Zwei-stufige Arch-Validierung: (1) existiert die Architektur ueberhaupt (Tippfehler
	// -> globales Vokabular SupportedArchs)? (2) rendert der Renderer DIESER Sprache sie
	// (-> die von der Sprache getragenen Archs)? Ohne (2) schriebe eine nicht getragene
	// Kombination still ein Geruestung-only-Skelett statt Exit 2 (slice-045a-Review
	// INFO-1). Seit slice-053 tragen go und cpp beide Archs — der Zweig bleibt fuer die
	// naechste Sprache noetig und ist ueber einen Renderer ohne hexslice bewacht.
	if archLayout(arch) == nil {
		return &UnknownArchError{Arch: arch, Available: SupportedArchs()}
	}
	if !archSupported(lang, arch) {
		return &UnknownArchError{Arch: arch, Available: archsForLang(lang)}
	}
	prof := build(version, arch)
	rels := make([]string, 0, len(prof))
	for rel := range prof {
		rels = append(rels, rel)
	}
	sort.Strings(rels) // deterministische Schreib-Reihenfolge (kein Map-Iterations-Leak)
	for _, rel := range rels {
		dst := filepath.Join(destDir, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
		}
		if err := os.WriteFile(dst, []byte(prof[rel]), 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", rel, err)
		}
	}
	return nil
}

// SupportedLangs liefert die Sprachen mit Profil, sortiert — fuer Hilfetexte und
// die Unknown-Lang-Liste.
func SupportedLangs() []string {
	langs := make([]string, 0, len(profiles()))
	for l := range profiles() {
		langs = append(langs, l)
	}
	sort.Strings(langs)
	return langs
}

// profiles bildet Sprache -> Profil-Builder (Ziel-Relpfad -> Inhalt fuer eine
// Toolchain-Version). Als Funktion (nicht Paket-Variable) wie baselineTrees()/
// rootMarkers() im Repo — gochecknoglobals-konform. Eine neue Sprache ist ein
// neuer Eintrag, kein Umbau der Mechanik (LH-FA-04: sprach-agnostisch).
func profiles() map[string]func(version, arch string) map[string]string {
	return map[string]func(string, string) map[string]string{
		"go":  goProfile,
		"cpp": cppProfile,
	}
}

// DefaultArch ist der Default-Architektur-Wert der CLI (flat = das heutige Skelett) —
// exportiert, damit cmd das `--arch`-Flag ohne Magie-String vorbelegen kann.
const DefaultArch = archFlat

// langArchs bildet Sprache -> die Architekturen, die ihr Renderer WIRKLICH rendert.
// Heute tragen go (slice-045a) und cpp (slice-053) beide Architekturen. Getrennt vom
// Achsen-Vokabular SupportedArchs() (dem Union aller Werte): ein Achsen-Wert kann
// existieren, bevor jeder Renderer ihn implementiert. GenerateArch validiert die
// (lang, arch)-Kombination hiergegen, damit eine nicht getragene Kombination fail-fast
// Exit 2 gibt, statt still ein Geruestung-only-Skelett zu schreiben (slice-045a-Review
// INFO-1).
//
// EHRLICH BENANNT (slice-053): seit cpp hexslice rendert, tragen BEIDE Sprachen BEIDE
// Architekturen — die sprach-spezifische zweite Stufe ist damit von aussen nicht mehr
// erreichbar und folglich UNBEWACHT. Sie bleibt als Verteidigung fuer die naechste
// Sprache stehen (die kommt mit flat und ohne hexslice-Renderer), aber niemand soll
// glauben, ein Test decke sie: der Exit-2-Beleg haengt jetzt an Stufe 1 (unbekannte
// Architektur). Ein Seam nur fuer die Testbarkeit waere eine Paket-Variable und
// verstiesse gegen gochecknoglobals. EINE Quelle: SupportedArchs() leitet den Union
// hieraus ab (kein Doppel-Pflegepunkt).
func langArchs() map[string][]string {
	return map[string][]string{
		"go":  {archFlat, archHexslice},
		"cpp": {archFlat, archHexslice},
	}
}

// archSupported prueft, ob der Renderer der Sprache lang die Architektur arch rendert.
func archSupported(lang, arch string) bool {
	for _, a := range langArchs()[lang] {
		if a == arch {
			return true
		}
	}
	return false
}

// archsForLang liefert die von lang getragenen Architekturen sortiert — fuer die
// UnknownArchError-Liste (die CLI-Fehlermeldung bei einer sprach-fremden Architektur).
func archsForLang(lang string) []string {
	archs := append([]string(nil), langArchs()[lang]...)
	sort.Strings(archs)
	return archs
}

// DefaultVersion liefert die gepinnte Default-Toolchain-Version fuer lang (go: die
// Go-Version; cpp: der ubuntu-Base-Tag). Die Bedeutung von „Version" ist per Sprache
// verschieden — der Aufrufer (cmd) faedelt sie generisch (SKEL_<LANG>_VERSION), das
// Profil interpretiert sie. Unbekannte Sprache -> "" (Generate faengt sie separat via
// UnknownLangError; ein leerer Versions-Default schadet dort nicht).
func DefaultVersion(lang string) string {
	switch lang {
	case "go":
		return DefaultGoVersion
	case "cpp":
		return DefaultCppVersion
	}
	return ""
}

// ModuleName leitet den Modul-Namen aus dem Zielpfad ab (slice-037, Mono-Repo): Root
// (".") -> die Sprache (Fragment harness/mk/<lang>.mk, rueckwaertskompatibel), sonst
// der bereinigte Pfad mit Slashes zu Bindestrichen (apps/api -> apps-api, Fragment
// harness/mk/apps-api.mk). Der Name traegt die Kollisionsfreiheit: das Fragment
// benennt seine Targets modul-scoped (test-<modul> …), sodass zwei Module gleicher
// Sprache nicht dasselbe Target definieren.
func ModuleName(path, lang string) string {
	clean := cleanPath(path)
	if clean == "." {
		return lang
	}
	return strings.ReplaceAll(clean, "/", "-")
}

// cleanPath bereinigt den Zielpfad zu einem slash-Pfad; leer -> ".".
func cleanPath(path string) string {
	if path == "" {
		return "."
	}
	return filepath.ToSlash(filepath.Clean(path))
}

// CodeGateFragment liefert den Inhalt des Code-Gate-Fragments (harness/mk/<modul>.mk)
// fuer lang am Zielpfad path (slice-037): Root (".") -> die bestehende UNSCOPED Fassung
// (Targets test/lint/build, `docker build .`, rueckwaertskompatibel); Subdir ->
// modul-scoped (test-<modul> …, `docker build <path>`, kollisionsfrei im Mono-Repo).
// Eine Sprache ohne Fragment-Builder liefert *UnknownLangError — dieselbe Liste wie
// Generate, damit `add-lang <sprache>` fail-fast dieselbe Diagnose gibt.
func CodeGateFragment(lang, path, version string) (string, error) {
	build, ok := fragments()[lang]
	if !ok {
		return "", &UnknownLangError{Lang: lang, Available: SupportedLangs()}
	}
	return build(ModuleName(path, lang), cleanPath(path), version), nil
}

// fragments bildet Sprache -> Code-Gate-Fragment-Builder (Modul-Name, Build-Kontext,
// Toolchain-Version -> Fragment-Inhalt). Getrennt von profiles(), weil das Fragment
// <pfad>-aware ist (Kontext/Scoping), das Skelett aber ortsunabhaengig.
func fragments() map[string]func(modul, context, version string) string {
	return map[string]func(string, string, string) string{
		"go":  goFragment,
		"cpp": cppFragment,
	}
}
