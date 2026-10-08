package emit_test

import (
	"go/ast"
	"go/parser"
	"go/token"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestWortlautNeutralisierungen_EineTabelle haelt die Vollstaendigkeit strukturell
// (LH-FA-02): jeder strings.Replace/ReplaceAll/NewReplacer- und bytes.Replace/ReplaceAll-
// Aufruf in templates.go bezieht seinen Marker aus emit.WortlautNeutralisierungen() (das
// Such-Argument ist ein Feld `.Alt`) oder steht in einer Funktion aus
// ersetzungOhneWortlaut. Zweitens steht jede Tabellen-Zeile auf einer Zeile, mit den
// Schluesseln Vorlage, Alt, Neu in dieser Reihenfolge im einzigen return-Literal der
// Funktion, und Vorlage und Alt sind
// Bezeichner einer einzeiligen `const X = "…"`-Deklaration — die Form, die
// test/neutralisierung-marker.bats liest, um jeden Marker am vendored Baum zu zaehlen.
// Grenze: eine Ersetzung ueber regexp oder ueber eine eigene Schleife sieht der Test
// nicht, ebenso wenig eine Wortlaut-Ersetzung ausserhalb von templates.go oder in einer
// Funktion aus ersetzungOhneWortlaut.
func TestWortlautNeutralisierungen_EineTabelle(t *testing.T) {
	// ersetzungOhneWortlaut nennt die Funktionen in templates.go, deren Ersetzung
	// keinen Wortlaut-Marker einer Vorlage traegt: stampName setzt den Projektnamen fuer
	// den <Projektname>-Platzhalter, unmaskQuotedCommentSyntax macht eine eigene
	// Maskierung rueckgaengig. Jede andere Funktion bezieht ihren Marker aus der Tabelle.
	ersetzungOhneWortlaut := map[string]bool{
		"stampName":                 true,
		"unmaskQuotedCommentSyntax": true,
	}
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "templates.go", nil, 0)
	if err != nil {
		t.Fatalf("templates.go parsen: %v", err)
	}

	consts := map[string]bool{} // einzeilige `const X = "…"` ausserhalb eines Blocks
	var tabelle *ast.CompositeLit
	for _, d := range file.Decls {
		if fd, ok := d.(*ast.FuncDecl); ok && fd.Recv == nil && fd.Name.Name == "WortlautNeutralisierungen" &&
			fd.Body != nil && len(fd.Body.List) == 1 {
			if rs, ok := fd.Body.List[0].(*ast.ReturnStmt); ok && len(rs.Results) == 1 {
				tabelle, _ = rs.Results[0].(*ast.CompositeLit)
			}
		}
		gd, ok := d.(*ast.GenDecl)
		if !ok {
			continue
		}
		for _, s := range gd.Specs {
			vs, ok := s.(*ast.ValueSpec)
			if !ok || len(vs.Names) != 1 || len(vs.Values) != 1 {
				continue
			}
			if gd.Tok == token.CONST && gd.Lparen == 0 {
				if bl, ok := vs.Values[0].(*ast.BasicLit); ok && bl.Kind == token.STRING && strings.HasPrefix(bl.Value, `"`) {
					consts[vs.Names[0].Name] = true
				}
			}
		}
	}
	if tabelle == nil || len(tabelle.Elts) == 0 {
		t.Fatal("templates.go: WortlautNeutralisierungen gibt kein einzelnes Tabellen-Literal zurueck")
	}
	if len(tabelle.Elts) != len(emit.WortlautNeutralisierungen()) {
		t.Errorf("Literal mit %d Zeilen, Laufzeit-Tabelle mit %d", len(tabelle.Elts), len(emit.WortlautNeutralisierungen()))
	}
	for _, e := range tabelle.Elts {
		pos := fset.Position(e.Pos())
		cl, ok := e.(*ast.CompositeLit)
		if !ok || fset.Position(e.End()).Line != pos.Line || len(cl.Elts) != 3 {
			t.Errorf("templates.go:%d: Tabellen-Zeile nicht einzeilig mit drei Feldern", pos.Line)
			continue
		}
		for i, key := range []string{"Vorlage", "Alt", "Neu"} {
			kv, ok := cl.Elts[i].(*ast.KeyValueExpr)
			if !ok || kv.Key.(*ast.Ident).Name != key {
				t.Errorf("templates.go:%d: Feld %d ist nicht %s", pos.Line, i+1, key)
				continue
			}
			if key == "Neu" {
				continue
			}
			id, ok := kv.Value.(*ast.Ident)
			if !ok || !consts[id.Name] {
				t.Errorf("templates.go:%d: %s ist kein Bezeichner einer einzeiligen `const X = \"…\"`", pos.Line, key)
			}
		}
	}

	ersetzer := map[string]map[string]bool{
		"strings": {"Replace": true, "ReplaceAll": true, "NewReplacer": true},
		"bytes":   {"Replace": true, "ReplaceAll": true},
	}
	for _, d := range file.Decls {
		fd, ok := d.(*ast.FuncDecl)
		if !ok || fd.Body == nil {
			continue
		}
		ast.Inspect(fd.Body, func(n ast.Node) bool {
			call, ok := n.(*ast.CallExpr)
			if !ok {
				return true
			}
			sel, ok := call.Fun.(*ast.SelectorExpr)
			if !ok {
				return true
			}
			pkg, ok := sel.X.(*ast.Ident)
			if !ok || !ersetzer[pkg.Name][sel.Sel.Name] {
				return true
			}
			if ersetzungOhneWortlaut[fd.Name.Name] {
				return true
			}
			if sel.Sel.Name != "NewReplacer" && len(call.Args) >= 2 {
				if a, ok := call.Args[1].(*ast.SelectorExpr); ok && a.Sel.Name == "Alt" {
					return true
				}
			}
			t.Errorf("templates.go:%d: %s.%s in %s bezieht seinen Marker nicht aus WortlautNeutralisierungen",
				fset.Position(call.Pos()).Line, pkg.Name, sel.Sel.Name, fd.Name.Name)
			return true
		})
	}
}

// roadmapAlterStand ist ein woertlicher Ausschnitt der Roadmap-Vorlage aelterer
// Kurs-Staende: Zeile 107 von lab/templates/docs/plan/planning/roadmap.template.md am
// Tag v6.5.0 im Kurs-Klon (gleichlautend an v6.0.0; an v3.5.2 Zeile 62). Grenze: eine
// Fixture, nicht der vendored Baum — vendored ist allein der gepinnte Stand, und der
// traegt die Zeile nicht. Ob die Zeile in der Vorlage eines aelteren Tags so steht,
// haelt kein Sensor dieses Repos.
const roadmapAlterStand = "| <welle-NN> | YYYY-MM-DD | [`welle-NN-results.md`](../done/welle-NN-results.md) |\n"

// TestNeutralizeRoadmap prueft die pure Neutralisierung: der tote ../done/-Link wird
// zu Inline-Code, ohne Marker bleibt der Text unveraendert.
func TestNeutralizeRoadmap(t *testing.T) {
	got := emit.NeutralizeRoadmap(roadmapAlterStand)
	if strings.Contains(got, "](../done/") {
		t.Errorf("toter ../done/-Link nicht neutralisiert:\n%s", got)
	}
	if !strings.Contains(got, "`welle-NN-results.md`") {
		t.Errorf("Beispiel-Form (Inline-Code) verloren:\n%s", got)
	}
	const plain = "kein Link hier\n"
	if emit.NeutralizeRoadmap(plain) != plain {
		t.Error("NeutralizeRoadmap veraenderte Text ohne den Marker")
	}
}

// TestTemplates_RoadmapTraegtRuheMarker haelt die Verdrahtung der Marker-Injektion: die von
// emit.Templates geschriebene Roadmap traegt den Ruhe-Marker im Abschnitt "## Offene Wellen"
// (LH-FA-02 — ohne ihn startet das Modul planning im Ziel rot).
func TestTemplates_RoadmapTraegtRuheMarker(t *testing.T) {
	src := courseSet().(fstest.MapFS)
	src["docs/plan/planning/roadmap.template.md"] = &fstest.MapFile{Data: []byte("# Roadmap\n\n## Offene Wellen\n\n- x\n\n## Nächste Wellen\n")}
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "X", testVorlagen, io.Discard); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "docs/plan/planning/in-progress/roadmap.md"))
	if err != nil {
		t.Fatalf("roadmap.md lesen: %v", err)
	}
	s := string(got)
	start, ende := strings.Index(s, "## Offene Wellen"), strings.Index(s, "## Nächste Wellen")
	if start < 0 || ende < start || !strings.Contains(s[start:ende], "\n"+emit.RoadmapRuheMarker+"\n") {
		t.Errorf("emittierte Roadmap traegt den Ruhe-Marker nicht im Abschnitt Offene Wellen:\n%s", s)
	}
}

// TestTemplates_RoadmapGateSafe: die emittierte Roadmap traegt keinen toten
// ../done/-Link, wenn die Vorlage die Zeile eines aelteren Kurs-Stands fuehrt — die
// Wiring-Probe, dass planTemplates die Roadmap durch NeutralizeRoadmap schickt.
func TestTemplates_RoadmapGateSafe(t *testing.T) {
	src := courseSet().(fstest.MapFS)
	src["docs/plan/planning/roadmap.template.md"] = &fstest.MapFile{Data: []byte("# Roadmap\n\n## Abgeschlossene Wellen\n\n" + roadmapAlterStand)}
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "X", testVorlagen, io.Discard); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "docs/plan/planning/in-progress/roadmap.md"))
	if err != nil {
		t.Fatalf("roadmap.md lesen: %v", err)
	}
	if strings.Contains(string(got), "](../done/") {
		t.Errorf("emittierte Roadmap traegt einen toten ../done/-Link:\n%s", got)
	}
}
