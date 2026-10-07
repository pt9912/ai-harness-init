package emit_test

import (
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// werkzeugIndexZiel legt ein Ziel mit Make-Dateien beider Eigentuemer und einer README an, die
// zwei Targets schon als Tabellenzeile fuehrt.
func werkzeugIndexZiel(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	files := map[string]string{
		"Makefile":            "GATE_CHECKS :=\ngates: record-gates ## Alle Gates\nrecord-gates: $(GATE_CHECKS)\nhelp: ## Diese Hilfe\n",
		"d-check.mk":          ".PHONY: docs-check\ndocs-check: ## Doku pruefen\ndoc-trace: ## RTM | Bericht\n",
		"harness/mk/go.mk":    "GATE_CHECKS += lint test\nlint: ## Lint\ntest:\n\t@true\n",
		"harness/mk/werk.mk":  "werkzeug-ohne-hilfe:\n\t@true\nVAR := 1\n",
		"repo.mk":             "eigen: ## gehoert dem Repo\n",
		"harness/README.md":   "# R\n\n## Sensors (Feedback-Gates)\n\n| Target | Vertrag | Bindung |\n|---|---|---|\n| `make docs-check` | d | — |\n| [`make help`](sensors/help.md) | h | — |\n",
		"harness/mk/notiz.md": "keine Make-Datei\n",
	}
	for rel, c := range files {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(c), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	return dir
}

// TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt haelt den vollstaendigen Ist-Bestand der Zeilen
// gegen die erwartete Liste: je Target der Werkzeug-Dateien genau eine Zeile, Gates (GATE_CHECKS
// und gates) in der ersten Tabelle, alles uebrige mit `kein Gate`; die zwei Targets, die
// harness/README.md schon fuehrt, und das Target aus repo.mk fehlen.
func TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt(t *testing.T) {
	dir := werkzeugIndexZiel(t)
	if err := emit.WerkzeugIndex(dir); err != nil {
		t.Fatal(err)
	}
	got, err := os.ReadFile(filepath.Join(dir, filepath.FromSlash(emit.WerkzeugIndexPath)))
	if err != nil {
		t.Fatal(err)
	}
	zeile := regexp.MustCompile("(?m)^\\| `make ([a-z][a-z0-9-]*)` \\| (.*) \\| (—|kein Gate) \\|$")
	ist := map[string]string{}
	var namen []string
	for _, m := range zeile.FindAllStringSubmatch(string(got), -1) {
		if _, dup := ist[m[1]]; dup {
			t.Errorf("Target %s steht zweimal im Werkzeug-Teil", m[1])
		}
		ist[m[1]] = m[2] + " | " + m[3]
		namen = append(namen, m[1])
	}
	soll := map[string]string{
		"gates":               "Alle Gates | —",
		"lint":                "Lint | —",
		"test":                "Ziel aus `harness/mk/go.mk`, ohne Hilfetext | —",
		"record-gates":        "Ziel aus `Makefile`, ohne Hilfetext | kein Gate",
		"doc-trace":           `RTM \| Bericht | kein Gate`,
		"werkzeug-ohne-hilfe": "Ziel aus `harness/mk/werk.mk`, ohne Hilfetext | kein Gate",
	}
	sort.Strings(namen)
	if len(ist) != len(soll) {
		t.Errorf("Werkzeug-Teil fuehrt %v, erwartet genau %d Targets", namen, len(soll))
	}
	for n, s := range soll {
		if ist[n] != s {
			t.Errorf("Zeile %s: %q, erwartet %q", n, ist[n], s)
		}
	}
	gateTabelle := strings.Index(string(got), "| Target | Vertrag | Bindung |")
	werkzeugTabelle := strings.Index(string(got), "| Target | Tut was | Bindung |")
	if gateTabelle < 0 || werkzeugTabelle < gateTabelle {
		t.Fatalf("Gate-Tabelle vor der Werkzeug-Tabelle erwartet:\n%s", got)
	}
	if i := strings.Index(string(got), "`make lint`"); i > werkzeugTabelle {
		t.Errorf("Gate lint steht in der Werkzeug-Tabelle")
	}
}

// TestWerkzeugIndex_KonvergentHeiltDrift: ein zweiter Lauf schreibt die Datei byte-gleich neu,
// auch ueber eine Aenderung von Hand.
func TestWerkzeugIndex_KonvergentHeiltDrift(t *testing.T) {
	dir := werkzeugIndexZiel(t)
	if err := emit.WerkzeugIndex(dir); err != nil {
		t.Fatal(err)
	}
	p := filepath.Join(dir, filepath.FromSlash(emit.WerkzeugIndexPath))
	erst, _ := os.ReadFile(p)
	if err := os.WriteFile(p, append(erst, "| `make von-hand` | x | — |\n"...), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := emit.WerkzeugIndex(dir); err != nil {
		t.Fatal(err)
	}
	zweit, _ := os.ReadFile(p)
	if string(erst) != string(zweit) {
		t.Errorf("zweiter Lauf schreibt nicht byte-gleich:\n%s\n---\n%s", erst, zweit)
	}
}

// TestInjectWerkzeugIndexLink: die Zeile steht am Ende der Sensors-Sektion, vor der naechsten
// Ueberschrift; fehlt die Sektion, endet die Injektion mit Fehler.
func TestInjectWerkzeugIndexLink(t *testing.T) {
	body := "# R\n\n## Sensors (Feedback-Gates)\n\n| a |\n\n**Status:** x\n\n## Traceability\n\nt\n"
	got, err := emit.InjectWerkzeugIndexLink(body)
	if err != nil {
		t.Fatal(err)
	}
	want := "# R\n\n## Sensors (Feedback-Gates)\n\n| a |\n\n**Status:** x\n\n" + emit.WerkzeugIndexZeile + "\n\n## Traceability\n\nt\n"
	if got != want {
		t.Errorf("Injektion:\n%q\nerwartet\n%q", got, want)
	}
	if !strings.Contains(emit.WerkzeugIndexZeile, "](mk/ai-harness-init.md)") ||
		emit.WerkzeugIndexPath != "harness/"+"mk/ai-harness-init.md" {
		t.Errorf("Link-Ziel der Zeile loest von harness/ nicht auf %s auf", emit.WerkzeugIndexPath)
	}
	if _, err := emit.InjectWerkzeugIndexLink("# R\n\n## Andere\n"); err == nil {
		t.Errorf("ohne Sensors-Sektion kein Fehler (fail-closed verletzt)")
	}
}
