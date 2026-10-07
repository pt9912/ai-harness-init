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
	if _, err := emit.WerkzeugIndex(dir); err != nil {
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

// TestWerkzeugIndex_ErkenntRegelnWieDasDokuGate haelt die Target-Erkennung des Werkzeug-Teils
// gegen die des Moduls targets am Pin d-check v0.82.0 (`^[A-Za-z][A-Za-z0-9 _-]*:([^=]|$)`, je
// Name der Liste vor dem Doppelpunkt ein Target): Unterstrich, Grossbuchstabe, Mehrfach-Target,
// Leerzeichen vor dem Doppelpunkt und `::` sind Regeln; `.PHONY`, Pattern-Regeln und
// Zuweisungen nicht. Die Tabellenzelle `make doc_ok` in harness/README.md nimmt ihr Target aus.
func TestWerkzeugIndex_ErkenntRegelnWieDasDokuGate(t *testing.T) {
	dir := werkzeugIndexZiel(t)
	frag := "my_tgt: ## u\nBuild: ## g\nmulti-a multi-b: ## m\nsp : ## s\ndbl:: ## d\ndoc_ok: ## o\n" +
		".PHONY: my_tgt\n%.o: %.c\nX ?= 1\nY := 2\n"
	if err := os.WriteFile(filepath.Join(dir, "harness", "mk", "form.mk"), []byte(frag), 0o644); err != nil {
		t.Fatal(err)
	}
	readme := filepath.Join(dir, "harness", "README.md")
	r, _ := os.ReadFile(readme)
	if err := os.WriteFile(readme, append(r, "| `make doc_ok` | o | — |\n"...), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := emit.WerkzeugIndex(dir); err != nil {
		t.Fatal(err)
	}
	got, err := os.ReadFile(filepath.Join(dir, filepath.FromSlash(emit.WerkzeugIndexPath)))
	if err != nil {
		t.Fatal(err)
	}
	for _, n := range []string{"my_tgt", "Build", "multi-a", "multi-b", "sp", "dbl"} {
		if !strings.Contains(string(got), "| `make "+n+"` |") {
			t.Errorf("Regel %s aus form.mk fehlt im Werkzeug-Teil", n)
		}
	}
	for _, n := range []string{"doc_ok", ".PHONY", "%.o", "X", "Y"} {
		if strings.Contains(string(got), "| `make "+n+"` |") {
			t.Errorf("%s steht im Werkzeug-Teil, ist aber keine Regel fuer das Doku-Gate oder steht schon in harness/README.md", n)
		}
	}
}

// TestWerkzeugIndex_KonvergentHeiltDrift: ein zweiter Lauf schreibt die Datei byte-gleich neu,
// auch ueber eine Aenderung von Hand.
func TestWerkzeugIndex_KonvergentHeiltDrift(t *testing.T) {
	dir := werkzeugIndexZiel(t)
	if _, err := emit.WerkzeugIndex(dir); err != nil {
		t.Fatal(err)
	}
	p := filepath.Join(dir, filepath.FromSlash(emit.WerkzeugIndexPath))
	erst, _ := os.ReadFile(p)
	if err := os.WriteFile(p, append(erst, "| `make von-hand` | x | — |\n"...), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := emit.WerkzeugIndex(dir); err != nil {
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

// TestWerkzeugIndex_BerichtNenntNeueTargets haelt den Bericht, den der Lauf aus dem liegenden
// gegen den geschriebenen Werkzeug-Teil zieht (LH-QA-01): der Erstlauf nennt keine Einzel-Targets,
// sondern die Zahlen; ein Re-Lauf ohne Aenderung nennt nichts; ein neues Fragment nennt sein Gate
// und sein Werkzeug-Ziel vollstaendig, Gates zuerst; ein Target, das von der zweiten in die
// Gate-Tabelle wechselt, steht als Gate darin; ein entfallenes Target nennt er nicht.
func TestWerkzeugIndex_BerichtNenntNeueTargets(t *testing.T) {
	dir := werkzeugIndexZiel(t)
	erst, err := emit.WerkzeugIndex(dir)
	if err != nil {
		t.Fatal(err)
	}
	if !erst.Erstlauf || len(erst.Neu) != 0 || erst.Targets != 6 || erst.Gates != 3 {
		t.Errorf("Erstlauf: %+v, erwartet Erstlauf ohne Neu mit 6 Targets, davon 3 Gates", erst)
	}
	gleich, err := emit.WerkzeugIndex(dir)
	if err != nil {
		t.Fatal(err)
	}
	if gleich.Erstlauf || len(gleich.Neu) != 0 {
		t.Errorf("Re-Lauf ohne Aenderung: %+v, erwartet keinen Erstlauf und nichts Neues", gleich)
	}
	frag := "GATE_CHECKS += neu-gate record-gates\nneu-gate: ## G\nneu-werkzeug: ## W\n"
	if err := os.WriteFile(filepath.Join(dir, "harness", "mk", "neu.mk"), []byte(frag), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Remove(filepath.Join(dir, "harness", "mk", "werk.mk")); err != nil {
		t.Fatal(err)
	}
	b, err := emit.WerkzeugIndex(dir)
	if err != nil {
		t.Fatal(err)
	}
	soll := []emit.WerkzeugTargetNeu{{Name: "neu-gate", Gate: true}, {Name: "record-gates", Gate: true}, {Name: "neu-werkzeug"}}
	if b.Erstlauf || len(b.Neu) != len(soll) {
		t.Fatalf("Bericht nach neuem Fragment: %+v, erwartet Neu = %+v", b, soll)
	}
	for i, s := range soll {
		if b.Neu[i] != s {
			t.Errorf("Neu[%d] = %+v, erwartet %+v", i, b.Neu[i], s)
		}
	}
}
