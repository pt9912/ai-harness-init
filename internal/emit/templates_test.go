package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// courseSet bildet den Kurs-Template-Satz nach, wie ihn die gefetchte Baseline
// traegt — inklusive der Dateien, die NICHT emittiert werden duerfen. Seit
// slice-022b liest emit.Templates aus einem fs.FS statt aus einem eingebetteten
// Baum; die Tests bleiben damit hermetisch (der reale Baum liegt unter .harness/,
// das der Docker-Build-Kontext ausschliesst).
func courseSet() fs.FS {
	hint := "> **Template-Hinweis.** Vorlage.\n\n"
	body := "# <Projektname>\n\nInhalt.\n"
	f := func(s string) *fstest.MapFile { return &fstest.MapFile{Data: []byte(s)} }
	return fstest.MapFS{
		// in scope — Singletons
		"AGENTS.template.md":                    f(hint + body),
		"spec/lastenheft.template.md":           f(hint + body),
		"spec/architecture.template.md":         f(hint + body),
		"spec/spezifikation.template.md":        f(hint + body),
		"harness/README.template.md":            f(hint + body),
		"harness/conventions.template.md":       f(hint + body),
		"docs/plan/adr/README.template.md":      f(hint + body),
		"docs/plan/carveouts/README.template.md": f(hint + body),
		"docs/plan/planning/README.template.md": f(hint + body),
		"docs/plan/planning/roadmap.template.md": f(hint + body),
		// in scope — Wiederkehrende (verbatim, Hinweis bleibt)
		"docs/plan/adr/NNNN-titel.template.md":       f(hint + body),
		"docs/plan/planning/slice.template.md":       f(hint + body),
		"docs/plan/planning/welle.template.md":       f(hint + body),
		"docs/plan/carveouts/carveout.template.md":   f(hint + body),
		"docs/reviews/review-report.template.md":     f(hint + body),
		// AUSSER Scope — jede Zeile ein eigener Grund, s. emit.inScope
		"README.md":                                    f("# Set-Index\n"),
		"project-readme.template.md":                   f(hint + body),
		".harness/skills/reviewer.template.md":         f(hint + body),
		".harness/skills/closure-note-reviewer.template.md": f(hint + body),
		".d-check.yml":                                 f("modules: [links]\n"),
		"Makefile":                                     f("all:\n\t@true\n"),
	}
}

func TestTemplates_Layout(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	singletons := []string{
		"AGENTS.md",
		"spec/lastenheft.md", "spec/architecture.md", "spec/spezifikation.md",
		"harness/README.md", "harness/conventions.md",
		"docs/plan/adr/README.md", "docs/plan/carveouts/README.md",
		"docs/plan/planning/README.md",
		"docs/plan/planning/in-progress/roadmap.md", // Sonderfall: in-progress/, nicht flach
	}
	for _, rel := range singletons {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf("Singleton %s fehlt: %v", rel, err)
		}
	}
	recurring := []string{
		"docs/plan/adr/NNNN-titel.template.md",
		"docs/plan/planning/slice.template.md",
		"docs/plan/planning/welle.template.md",
		"docs/plan/carveouts/carveout.template.md",
		"docs/reviews/review-report.template.md",
	}
	for _, rel := range recurring {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf("Wiederkehrend %s fehlt: %v", rel, err)
		}
	}
	// Set-Index-README wird NIE emittiert; roadmap NICHT flach unter planning/.
	if _, err := os.Stat(filepath.Join(dir, "README.md")); err == nil {
		t.Error("Set-Index-README.md wurde emittiert (darf nicht)")
	}
	if _, err := os.Stat(filepath.Join(dir, "docs/plan/planning/roadmap.md")); err == nil {
		t.Error("roadmap.md liegt flach unter planning/ statt in-progress/")
	}
}

func TestTemplates_StampAndStrip(t *testing.T) {
	dir := t.TempDir()
	const name = "MeinProjekt"
	if err := emit.Templates(courseSet(), dir, name, true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "spec/lastenheft.md"))
	if err != nil {
		t.Fatalf("lastenheft.md lesen: %v", err)
	}
	s := string(got)
	if !strings.Contains(s, name) {
		t.Errorf("Projektname nicht gestempelt:\n%s", s)
	}
	if strings.Contains(s, "<Projektname>") {
		t.Error("<Projektname>-Platzhalter blieb stehen")
	}
	if strings.Contains(s, "Template-Hinweis") {
		t.Error("Template-Hinweis-Block nicht gestrippt")
	}
}

// TestTemplates_RecurringVerbatim: wiederkehrende Templates werden verbatim
// emittiert — ihr Template-Hinweis-Block bleibt stehen (Singletons bekommen ihn
// gestrippt, siehe TestTemplates_StampAndStrip).
//
// Gegen den REALEN Kurs-Satz laeuft dieser Test NICHT: er nutzt courseSet(), und
// `.harness/` ist im Docker-Build-Kontext gar nicht sichtbar (.dockerignore). Die
// Treue der Fixture zum realen Satz haelt `test/courseset-fixture.bats` fest.
// (Eine frueher hier stehende Zuschreibung an `make smoke` war falsch: smoke
// prueft Bootstrap-Exit, Skelett und d-check-Config — kein emittiertes Template.
// Review-Befund slice-022b F-3.)
func TestTemplates_RecurringVerbatim(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "docs/plan/adr/NNNN-titel.template.md"))
	if err != nil {
		t.Fatalf("NNNN-titel lesen: %v", err)
	}
	if !strings.Contains(string(got), "Template-Hinweis") {
		t.Error("wiederkehrendes Template transformiert (Hinweis-Block gestrippt) — nicht verbatim")
	}
}

// TestTemplates_EmittierterBestandVollstaendig ist der Kern von slice-022b: die
// gefetchte Quelle traegt den VOLLEN Kurs-Satz (21 Dateien), emittiert werden
// genau 15. Geprueft wird der Ist-Bestand VOLLSTAENDIG — was nicht in der
// Erwartung steht, darf nicht da sein.
//
// Die Vorgaenger-Fassung hiess AusserScopeNichtEmittiert und stat'te die
// QUELL-Namen (`README.md`, `project-readme.template.md`, …). Der Emitter
// schreibt aber TRANSFORMIERTE Namen: singletonTarget haengt `.md` an, wenn
// `.template.md` nicht greift — aus `README.md` wuerde `README.md.md`, aus
// `project-readme.template.md` wuerde `project-readme.md`. Alle sieben
// Zusicherungen prueften damit Pfade, die der Code unter KEINER Mutation
// schreibt: der Test war inert (Review-Befund slice-022b F-1, per Mutations-Sonde
// belegt). Abwesenheits-Stichproben auf geratene Namen sind die falsche Form —
// derselbe Fehler wie bei slice-022a N2.
func TestTemplates_EmittierterBestandVollstaendig(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	want := []string{
		// 10 Singletons -> .md
		"AGENTS.md",
		"docs/plan/adr/README.md",
		"docs/plan/carveouts/README.md",
		"docs/plan/planning/README.md",
		"docs/plan/planning/in-progress/roadmap.md",
		"harness/README.md",
		"harness/conventions.md",
		"spec/architecture.md",
		"spec/lastenheft.md",
		"spec/spezifikation.md",
		// 5 Wiederkehrende -> verbatim co-located
		"docs/plan/adr/NNNN-titel.template.md",
		"docs/plan/carveouts/carveout.template.md",
		"docs/plan/planning/slice.template.md",
		"docs/plan/planning/welle.template.md",
		"docs/reviews/review-report.template.md",
	}
	sort.Strings(want)
	got := emittedTree(t, dir)
	if strings.Join(got, "\n") != strings.Join(want, "\n") {
		t.Errorf("emittierter Bestand weicht ab.\ngot:\n  %s\nwant:\n  %s",
			strings.Join(got, "\n  "), strings.Join(want, "\n  "))
	}
}

// emittedTree liefert alle emittierten Dateien relativ zu dir, slash-normalisiert
// und sortiert.
func emittedTree(t *testing.T, dir string) []string {
	t.Helper()
	var out []string
	if err := filepath.WalkDir(dir, func(p string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		rel, relErr := filepath.Rel(dir, p)
		if relErr != nil {
			return relErr
		}
		out = append(out, filepath.ToSlash(rel))
		return nil
	}); err != nil {
		t.Fatalf("Baum lesen: %v", err)
	}
	sort.Strings(out)
	return out
}

// TestTemplates_NeuesUpstreamTemplateFliesstMit ist der strukturelle Ersatz fuer
// die Vollstaendigkeits-Achse des geloeschten Drift-Waechters. Die bewachte
// "Baseline gebumpt, Embed nicht re-synct". Mit einer REGEL statt einer
// aufgezaehlten Allowlist kann die Klasse nicht mehr entstehen — dieser Test
// haelt genau das fest: ein Template, das niemand kennt, kommt trotzdem an.
func TestTemplates_NeuesUpstreamTemplateFliesstMit(t *testing.T) {
	src := courseSet().(fstest.MapFS)
	src["spec/glossar.template.md"] = &fstest.MapFile{Data: []byte("> **Template-Hinweis.** X\n\n# <Projektname>\n")}
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	if _, err := os.Stat(filepath.Join(dir, "spec", "glossar.md")); err != nil {
		t.Errorf("neu hinzugekommenes Template wurde nicht emittiert: %v", err)
	}
}

// TestTemplates_FalscheWurzelung deckt Review-Befund F-2. Der Leer-Guard allein
// reicht nicht: eine VORFAHREN-Wurzelung ist nicht leer, liefert mehr Treffer und
// umgeht die FS-Root-verankerten Ausschluesse — sie wuerde ohne Fehler zu viel
// emittieren. Beide Formen muessen laut abbrechen.
func TestTemplates_FalscheWurzelung(t *testing.T) {
	// (a) Vorfahren-Wurzelung: der Satz liegt unter templates/, src zeigt darueber.
	nested := fstest.MapFS{}
	for p, f := range courseSet().(fstest.MapFS) {
		nested["templates/"+p] = f
	}
	nested["regelwerk/README.md"] = &fstest.MapFile{Data: []byte("# Index\n")}
	dir := t.TempDir()
	err := emit.Templates(nested, dir, "X", true)
	if err == nil {
		t.Fatal("Vorfahren-Wurzelung wurde akzeptiert — sie emittiert zu viel, nicht zu wenig")
	}
	if !strings.Contains(err.Error(), "gewurzelt") {
		t.Errorf("Fehlermeldung benennt die Ursache nicht: %v", err)
	}
	if got := emittedTree(t, dir); len(got) != 0 {
		t.Errorf("trotz Fehler emittiert: %v", got)
	}

	// (b) NACHFAHREN-Wurzelung: eine Ebene ZU TIEF. Sie traegt in-scope-Templates
	// an ihrer Wurzel — die erste checkRoot-Fassung liess sie deshalb durch und
	// haette `lastenheft.md` in den Ziel-ROOT statt nach spec/ geschrieben
	// (Review-Befund slice-026 F-3: Erkennung war unter den abgeloesten
	// Namens-Anker gefallen).
	deep := fstest.MapFS{
		"lastenheft.template.md":    &fstest.MapFile{Data: []byte("# <Projektname>\n")},
		"architecture.template.md":  &fstest.MapFile{Data: []byte("# <Projektname>\n")},
		"spezifikation.template.md": &fstest.MapFile{Data: []byte("# <Projektname>\n")},
	}
	dir2 := t.TempDir()
	err = emit.Templates(deep, dir2, "X", true)
	if err == nil {
		t.Fatal("Nachfahren-Wurzelung wurde akzeptiert — sie emittiert in den falschen Ziel-Pfad")
	}
	if !strings.Contains(err.Error(), "zu tief") {
		t.Errorf("Fehlermeldung unterscheidet die Richtung nicht: %v", err)
	}
	if got := emittedTree(t, dir2); len(got) != 0 {
		t.Errorf("trotz Fehler emittiert: %v", got)
	}

	// (c) voellig fremde Quelle.
	if err := emit.Templates(fstest.MapFS{"irgendwas.txt": &fstest.MapFile{Data: []byte("x")}}, t.TempDir(), "X", true); err == nil {
		t.Error("fremde Quelle wurde als Erfolg gemeldet")
	}
}

// TestTemplates_MinimalQuelle: eine Quelle, die NUR den Wurzel-Anker traegt,
// emittiert genau ihn — checkRoot verwirft sie nicht als "zu duenn".
//
// Der Test hiess vorher TestTemplates_LeereQuelle und trug einen
// LH-QA-01-Kommentar ueber den `len(plan) == 0`-Guard, sicherte im Rumpf aber
// dessen GEGENTEIL zu (Erfolg statt Fehler). Der Guard war zu dem Zeitpunkt
// bereits unerreichbar, weil rootAnchor selbst in-scope ist — Name und Kommentar
// behaupteten eine Eigenschaft, die der Rumpf nicht pruefte und der Code nicht
// hatte (Review-Befund slice-022b N-1, Bruch von AGENTS.md Hard Rule 3.6). Der
// tote Guard ist entfernt, der Test heisst jetzt nach dem, was er misst.
func TestTemplates_MinimalQuelle(t *testing.T) {
	// Minimal GUELTIG heisst seit dem F-3-Fix: in-scope-Templates auf BEIDEN
	// Ebenen. Eine Quelle mit nur einem Wurzel-Template ist von einer
	// Nachfahren-Wurzelung nicht unterscheidbar und wird abgelehnt.
	minimal := fstest.MapFS{
		"AGENTS.template.md":          &fstest.MapFile{Data: []byte("# <Projektname>\n")},
		"spec/lastenheft.template.md": &fstest.MapFile{Data: []byte("# <Projektname>\n")},
	}
	dir := t.TempDir()
	if err := emit.Templates(minimal, dir, "X", true); err != nil {
		t.Fatalf("minimale gueltige Quelle sollte emittieren: %v", err)
	}
	if got := emittedTree(t, dir); strings.Join(got, ",") != "AGENTS.md,spec/lastenheft.md" {
		t.Errorf("emittiert = %v, want [AGENTS.md spec/lastenheft.md]", got)
	}
}

func TestTemplates_ForceBoundary(t *testing.T) {
	dir := t.TempDir()
	if err := os.MkdirAll(filepath.Join(dir, "spec"), 0o755); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	const sentinel = "# vorhanden\n"
	target := filepath.Join(dir, "spec/lastenheft.md")
	if err := os.WriteFile(target, []byte(sentinel), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	// ohne force -> Fehler, Original unveraendert, nichts geschrieben (Pre-Flight).
	if err := emit.Templates(courseSet(), dir, "X", false); err == nil {
		t.Fatal("ohne force: kein Fehler trotz vorhandener Datei")
	}
	before, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(before) != sentinel {
		t.Errorf("Datei ohne force veraendert: %q", string(before))
	}
	// mit force -> ueberschrieben.
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("mit force: %v", err)
	}
	after, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(after) == sentinel {
		t.Error("mit force: Datei nicht ueberschrieben")
	}
}

func TestStripHintBlock(t *testing.T) {
	in := "# Titel\n\n> **Template-Hinweis.** Zeile eins.\n> Zeile zwei.\n\n**Inhalt**\n"
	want := "# Titel\n\n**Inhalt**\n"
	if got := emit.StripHintBlock(in); got != want {
		t.Errorf("StripHintBlock = %q, want %q", got, want)
	}
	no := "# Titel\n\nkein Hinweis\n"
	if got := emit.StripHintBlock(no); got != no {
		t.Errorf("StripHintBlock ohne Marker veraenderte den Text: %q", got)
	}
}
