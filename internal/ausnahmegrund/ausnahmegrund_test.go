package ausnahmegrund_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/ausnahmegrund"
)

func TestPasst(t *testing.T) {
	for _, c := range []struct {
		m, p string
		want bool
	}{
		{".harness/**", ".harness/skills/reviewer.md", true},
		{".harness/**", "docs/x.md", false},
		{"**/*.template.md", "a/b/c.template.md", true},
		{"**/*.template.md", "c.template.md", true},
		{"docs/plan/planning/done/welle-*.md", "docs/plan/planning/done/welle-1.md", true},
		{"docs/plan/planning/done/welle-*.md", "docs/plan/planning/done/x/welle-1.md", false},
		{"docs/plan/adr/[0-9]*.md", "docs/plan/adr/0001-x.md", true},
	} {
		if got := ausnahmegrund.Passt(c.m, c.p); got != c.want {
			t.Errorf("Passt(%q, %q) = %v, want %v", c.m, c.p, got, c.want)
		}
	}
}

// TestBefunde_FixtureBeideRichtungen haelt die Regel an einer kleinen Konfiguration: ein Glob,
// dessen Begruendung einen getroffenen Baum nicht nennt, und ein Zitat-Eintrag ohne eigenen
// Kommentar melden; dieselbe Konfiguration mit vollstaendiger Begruendung meldet nichts.
func TestBefunde_FixtureBeideRichtungen(t *testing.T) {
	dateien := map[string]string{
		".harness/baseline/v1/regelwerk/README.md": "",
		".harness/skills/reviewer.md":              "",
		"docs/a.md":                                "siehe `tools/weg.sh`",
	}
	rot := "scan:\n  # .harness/baseline/: vendored\n  ignore: [\".harness/**\"]\n" +
		"codepaths:\n  ignore-refs:\n    - tools/weg.sh\n"
	b := ausnahmegrund.Befunde(ausnahmegrund.Eintraege(rot), dateien, func(string) bool { return true })
	if len(b) != 2 || !strings.Contains(b[0], ".harness/skills/ nicht") || !strings.Contains(b[1], "kein eigener Kommentar") {
		t.Fatalf("erwartet zwei Befunde (.harness/skills/, Zitat ohne Kommentar), bekommen:\n%s", strings.Join(b, "\n"))
	}
	gruen := "scan:\n  # .harness/baseline/ und .harness/skills/\n  ignore: [\".harness/**\"]\n" +
		"codepaths:\n  ignore-refs:\n    # zitiert in docs/\n    - tools/weg.sh\n"
	if b := ausnahmegrund.Befunde(ausnahmegrund.Eintraege(gruen), dateien, func(string) bool { return true }); len(b) != 0 {
		t.Fatalf("vollstaendige Begruendung meldet:\n%s", strings.Join(b, "\n"))
	}
}

// TestRepoKonfiguration_BegruendungNenntJedenBaum haelt die .d-check.yml dieses Repos gegen den
// Baum, den der Testlauf sieht. Der Lauf sieht ihn ohne .git/ und .harness/ (.dockerignore):
// was ein Eintrag dort trifft, misst er nicht.
func TestRepoKonfiguration_BegruendungNenntJedenBaum(t *testing.T) {
	root := filepath.Join("..", "..")
	yml, err := os.ReadFile(filepath.Join(root, ".d-check.yml"))
	if err != nil {
		t.Fatalf(".d-check.yml lesen: %v", err)
	}
	ee := ausnahmegrund.Eintraege(string(yml))
	if len(ee) < 10 {
		t.Fatalf("nur %d Ausnahme-Eintraege erkannt — der Parser liest die Schreibform der Datei nicht mehr", len(ee))
	}
	if b := ausnahmegrund.Befunde(ee, mustBaum(t, root), ausnahmegrund.Pruefbereich(ee)); len(b) > 0 {
		t.Errorf(".d-check.yml: %d Ausnahme-Eintrag/-Eintraege nennen ihren Gegenstand nicht ganz:\n%s",
			len(b), strings.Join(b, "\n"))
	}
}

func mustBaum(t *testing.T, root string) map[string]string {
	t.Helper()
	m, err := ausnahmegrund.MarkdownBaum(root)
	if err != nil {
		t.Fatalf("Baum lesen %s: %v", root, err)
	}
	return m
}
