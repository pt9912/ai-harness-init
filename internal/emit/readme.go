package emit

import (
	"fmt"
	"io/fs"
)

// RootReadmePath ist das Ziel der Root-README (LH-FA-05): das Repo-Root README.md.
const RootReadmePath = "README.md"

// rootReadmeSource ist der Quell-Relpfad im Kurs-Template-Satz (templates/-gewurzelt).
const rootReadmeSource = "project-readme.template.md"

// RootReadme emittiert die Root-README.md aus project-readme.template.md
// (StripHintBlock + <Projektname>-Stempel, genau wie ein Singleton) — LH-FA-05.
//
// project-readme ist bewusst vom Templates-Emit ausgeschlossen (emit.inScope):
// ihr Ziel heisst README.md, nicht project-readme.md, und sie braucht einen
// eigenen Schritt. Der Pointer-/Trust-Abschnitt der Vorlage traegt gate-sichere
// Vorwaerts-Verweise auf co-emittierte Singletons (AGENTS.md / harness/README.md /
// spec/lastenheft.md) — KEINE Markdown-Links auf noch fehlende Ziele, sonst braeche
// docs-check im frischen Repo (LH-QA-01: keine halluzinierten Gates/Verweise). Der
// externe Kurs-URL lebt im Template-Hinweis-Block, den StripHintBlock entfernt, sodass
// die emittierte Datei ein echtes Repo-README ist, keine Vorlage mehr.
//
// name leer -> <Projektname> bleibt Platzhalter (Content-Urteil des Menschen).
// SKIP-IF-PRESENT (slice-038, ADR-0007): das README ist Adopter-Boden — ein vorhandenes
// (adopter-gewachsenes) README.md ueberlebt einen idempotenten Re-Lauf unberuehrt.
func RootReadme(src fs.FS, targetDir, name string) error {
	content, err := fs.ReadFile(src, rootReadmeSource)
	if err != nil {
		return fmt.Errorf("%s lesen: %w", rootReadmeSource, err)
	}
	out := []byte(stampName(StripHintBlock(string(content)), name))
	return writeSkipIfPresent(targetDir, RootReadmePath, out, 0o644)
}
