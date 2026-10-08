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
	b := ausnahmegrund.Befunde(mustEintraege(t, rot), dateien, func(string) bool { return true })
	if len(b) != 2 || !strings.Contains(b[0], ".harness/skills/ nicht") || !strings.Contains(b[1], "kein eigener Kommentar") {
		t.Fatalf("erwartet zwei Befunde (.harness/skills/, Zitat ohne Kommentar), bekommen:\n%s", strings.Join(b, "\n"))
	}
	gruen := "scan:\n  # .harness/baseline/ und .harness/skills/\n  ignore: [\".harness/**\"]\n" +
		"codepaths:\n  ignore-refs:\n    # zitiert in docs/\n    - tools/weg.sh\n"
	if b := ausnahmegrund.Befunde(mustEintraege(t, gruen), dateien, func(string) bool { return true }); len(b) != 0 {
		t.Fatalf("vollstaendige Begruendung meldet:\n%s", strings.Join(b, "\n"))
	}
}

// TestRepoKonfiguration_BegruendungNenntJedenBaum haelt die .d-check.yml dieses Repos gegen den
// Baum, den der Testlauf sieht. Der Lauf sieht ihn ohne .git/ und von .harness/ allein
// .harness/skills/ (.dockerignore); was ein Glob-Eintrag unter .harness/baseline/ trifft, misst er
// nicht — dort liegt kein Zitat im Pruefbereich, scan.ignore nimmt den Baum aus. Positiv belegt
// sind: je erfasstem Schluessel mindestens ein gelesener Eintrag, je Zitat-Eintrag mindestens ein
// Treffer und die Skills im Baum; fehlt einer, bricht der Fall ab, statt ueber einer leeren Menge
// gruen zu sein.
func TestRepoKonfiguration_BegruendungNenntJedenBaum(t *testing.T) {
	root := filepath.Join("..", "..")
	yml, err := os.ReadFile(filepath.Join(root, ".d-check.yml"))
	if err != nil {
		t.Fatalf(".d-check.yml lesen: %v", err)
	}
	ee := mustEintraege(t, string(yml))
	je := map[string]int{}
	for _, e := range ee {
		je[e.Schluessel]++
	}
	for _, s := range []string{"scan.ignore", "codepaths.ignore-refs", "codepaths.exempt-paths", "ignore-refs.in", "structure.exempt-paths"} {
		if je[s] == 0 {
			t.Fatalf("kein Eintrag unter %s gelesen (gelesen: %v) — der Parser liest die Schreibform der Datei nicht mehr", s, je)
		}
	}
	baum := mustBaum(t, root)
	if _, ok := baum[".harness/skills/reviewer.md"]; !ok {
		t.Fatalf(".harness/skills/reviewer.md fehlt im Testbaum — der Lauf sieht einen Baum im Pruefbereich von codepaths nicht (.dockerignore)")
	}
	pb := ausnahmegrund.Pruefbereich(ee)
	for _, e := range ee {
		if e.Klasse == ausnahmegrund.Zitat && len(ausnahmegrund.Treffer(e, baum, pb)) == 0 {
			t.Fatalf("%s %s (Zeile %d): kein Treffer im Testbaum — entweder sieht der Lauf den Baum der Nennung nicht (.dockerignore), oder der Eintrag schaltet nichts mehr stumm",
				e.Schluessel, e.Wert, e.Zeile)
		}
	}
	if b := ausnahmegrund.Befunde(ee, baum, pb); len(b) > 0 {
		t.Errorf(".d-check.yml: %d Ausnahme-Eintrag/-Eintraege nennen ihren Gegenstand nicht ganz:\n%s",
			len(b), strings.Join(b, "\n"))
	}
}

func mustEintraege(t *testing.T, yml string) []ausnahmegrund.Eintrag {
	t.Helper()
	ee, err := ausnahmegrund.Eintraege(yml)
	if err != nil {
		t.Fatalf("Eintraege: %v", err)
	}
	return ee
}

// TestEintraege_UnbekannteFormFailClosed haelt den Fehler-Zweig: ein erfasster Schluessel in
// einer Form, die der Parser nicht liest, liefert einen Fehler mit Schluessel und Zeile statt
// einer kuerzeren Liste.
func TestEintraege_UnbekannteFormFailClosed(t *testing.T) {
	for _, c := range []struct{ name, yml, schl string }{
		{"Skalar statt Liste", "scan:\n  ignore: \".harness/**\"\n", "scan.ignore (Zeile 2)"},
		{"Flow ueber zwei Zeilen", "ids:\n  exempt-paths: [\"a/**\",\n    \"b/**\"]\n", "ids.exempt-paths (Zeile 2)"},
		{"verschachteltes Item", "codepaths:\n  ignore-refs:\n    # x\n    - {pfad: tools/weg.sh}\n", "codepaths.ignore-refs (Zeile 4)"},
		{"Fortsetzungszeile im Block", "ids:\n  exempt-paths:\n    - a/**\n      b\n", "ids.exempt-paths (Zeile 4)"},
		{"in als Flow-Liste", "ignore-refs:\n  - in: [\"a.md\"]\n    refs: [x]\n", "ignore-refs.in (Zeile 2)"},
	} {
		ee, err := ausnahmegrund.Eintraege(c.yml)
		if err == nil || !strings.Contains(err.Error(), c.schl) {
			t.Errorf("%s: erwartet Fehler mit %q, bekommen err=%v eintraege=%+v", c.name, c.schl, err, ee)
		}
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

// TestEintraege_Schreibformen haelt die gelesenen Formen fest: Block-Items einfach und doppelt
// gequotet und ungequotet, scan.ignore als Block-Liste, Flow-Listen in beiden Quote-Formen. Der
// Wert steht ohne Anfuehrungszeichen im Eintrag.
func TestEintraege_Schreibformen(t *testing.T) {
	for _, c := range []struct{ name, yml, schl, wert string }{
		{"Block einfach gequotet (Zitat)", "codepaths:\n  ignore-refs:\n    # x\n    - 'tools/weg.sh'\n", "codepaths.ignore-refs", "tools/weg.sh"},
		{"Block einfach gequotet (Glob)", "ids:\n  exempt-paths:\n    - 'tools/**'\n", "ids.exempt-paths", "tools/**"},
		{"Block doppelt gequotet", "ids:\n  exempt-paths:\n    - \"tools/**\"\n", "ids.exempt-paths", "tools/**"},
		{"Block ungequotet", "ids:\n  exempt-paths:\n    - tools/**\n", "ids.exempt-paths", "tools/**"},
		{"scan.ignore Block-Liste", "scan:\n  ignore:\n    - \".harness/**\"\n", "scan.ignore", ".harness/**"},
		{"scan.ignore Block einfach gequotet", "scan:\n  ignore:\n    - '.harness/**'\n", "scan.ignore", ".harness/**"},
		{"Flow einfach gequotet", "scan:\n  ignore: ['.harness/**']\n", "scan.ignore", ".harness/**"},
		{"in-Wert einfach gequotet", "ignore-refs:\n  - in: 'docs/a.md'\n    refs: [x]\n", "ignore-refs.in", "docs/a.md"},
	} {
		ee, err := ausnahmegrund.Eintraege(c.yml)
		if err != nil {
			t.Errorf("%s: %v", c.name, err)
			continue
		}
		if len(ee) != 1 || ee[0].Schluessel != c.schl || ee[0].Wert != c.wert {
			t.Errorf("%s: erwartet [%s=%q], gelesen %+v", c.name, c.schl, c.wert, ee)
		}
	}
}
