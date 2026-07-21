// Package gen erzeugt Sprachskelette DETERMINISTISCH aus tool-eigenem
// Layout-Wissen (ADR-0005 Herkunftsklasse "Tool-als-Quelle"), statt sie zu
// fetchen. Ein Layout-Profil je Sprache; go ist das erste, die uebrigen aus
// LH-FA-04 folgen ohne Umbau der Mechanik.
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

// Generate schreibt das Skelett fuer lang nach destDir — in sortierter (also
// deterministischer) Reihenfolge. Eine Sprache ohne Profil liefert einen
// *UnknownLangError mit der sortierten Liste der unterstuetzten Profile, statt
// stillschweigend nichts zu tun.
func Generate(destDir, lang string) error {
	prof, ok := profiles()[lang]
	if !ok {
		return &UnknownLangError{Lang: lang, Available: SupportedLangs()}
	}
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

// profiles bildet Sprache -> (Ziel-Relpfad -> Inhalt). Als Funktion (nicht
// Paket-Variable) wie baselineTrees()/rootMarkers() im Repo — gochecknoglobals-
// konform. Eine neue Sprache ist ein neuer Eintrag, kein Umbau der Mechanik
// (LH-FA-04: sprach-agnostisch, ein Profil je Sprache).
func profiles() map[string]map[string]string {
	return map[string]map[string]string{
		"go": goProfile(),
	}
}
