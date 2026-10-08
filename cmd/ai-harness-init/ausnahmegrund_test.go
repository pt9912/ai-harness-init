package main

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/ausnahmegrund"
)

// TestEmittierteKonfiguration_BegruendungNenntJedenBaum haelt die .d-check.yml, die der
// Bootstrap ins Ziel schreibt, gegen das Ziel, das derselbe Lauf erzeugt (LH-QA-01): jeder Baum,
// in dem ein Ausnahme-Eintrag eine Markdown-Datei trifft, steht in seiner Begruendung. Gefahren
// werden ein sprachloser und je ein Lauf mit --lang go und --lang cpp. Die Orte unter .harness/
// legt der reale Bootstrap an; den Inhalt des vendored Baums liefert die Baseline-Fixture, die
// neben den zwei Root-Markern die zwei Skill-Vorlagen des Kurs-Satzes traegt. Ein Baum, den nur
// der reale Kurs-Satz traefe, sieht der Fall nicht.
func TestEmittierteKonfiguration_BegruendungNenntJedenBaum(t *testing.T) {
	for _, args := range [][]string{nil, {"--lang", "go"}, {"--lang", "cpp"}} {
		dir := gitRepo(t)
		src := testSources(t)
		src.baseline, src.baselineSHA = baselineFixture(t,
			struct{ name, content string }{"templates/project-readme.template.md", "# <Projektname>\n"},
			struct{ name, content string }{"templates/.harness/skills/reviewer.template.md", "# Reviewer\n"},
			struct{ name, content string }{"templates/.harness/skills/closure-note-reviewer.template.md", "# Closure\n"})
		src.docMK = docMKFixture(t)
		var out, errb bytes.Buffer
		if code := run(append(append([]string{}, args...), dir), dir, src, &out, &errb); code != 0 {
			t.Fatalf("%v: Bootstrap exit %d: %s", args, code, errb.String())
		}
		yml, err := os.ReadFile(filepath.Join(dir, ".d-check.yml"))
		if err != nil {
			t.Fatalf("%v: emittierte .d-check.yml lesen: %v", args, err)
		}
		dateien, err := ausnahmegrund.MarkdownBaum(dir)
		if err != nil {
			t.Fatalf("%v: Ziel lesen: %v", args, err)
		}
		if _, ok := dateien[".harness/skills/reviewer.md"]; !ok {
			t.Fatalf("%v: der Lauf hat .harness/skills/reviewer.md nicht abgelegt — der Fall misst nicht, was sein Name sagt", args)
		}
		ee := ausnahmegrund.Eintraege(string(yml))
		if b := ausnahmegrund.Befunde(ee, dateien, ausnahmegrund.Pruefbereich(ee)); len(b) > 0 {
			t.Errorf("%v: emittierte .d-check.yml (internal/emit/templates/d-check.yml) — %d Befund(e):\n%s",
				args, len(b), strings.Join(b, "\n"))
		}
	}
}
