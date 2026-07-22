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
		// Roadmap traegt die gate-unsichere "Abgeschlossene Wellen"-Beispielzeile
		// (broken ../done/-Link) — NeutralizeRoadmap muss sie beim Emit entschaerfen.
		"docs/plan/planning/roadmap.template.md": f(hint + "# Roadmap\n\n| <welle-NN> | YYYY-MM-DD | [`welle-NN-results.md`](../done/welle-NN-results.md) |\n"),
		// in scope — Wiederkehrende (LH-FA-02 0.8.0: NICHT emittiert, referenziert
		// aus der vendored Baseline) und derivative Indexe (nicht emittiert)
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

// TestTemplateTargets_SpiegeltDenEmittiertenSatz koppelt den Phase-3-Pre-Flight
// (cmd, slice-025) an das, was emit.Templates wirklich schreibt: TemplateTargets
// muss GENAU die Ziel-Pfade liefern, die ein voller Templates-Lauf anlegt — sonst
// prueft der Pre-Flight andere Pfade als der Emit schreibt (ein stilles Loch).
func TestTemplateTargets_SpiegeltDenEmittiertenSatz(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	var written []string
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
		written = append(written, filepath.ToSlash(rel))
		return nil
	}); err != nil {
		t.Fatalf("Baum lesen: %v", err)
	}
	sort.Strings(written)

	targets, err := emit.TemplateTargets(courseSet(), "X")
	if err != nil {
		t.Fatalf("TemplateTargets: %v", err)
	}
	if strings.Join(targets, ",") != strings.Join(written, ",") {
		t.Errorf("TemplateTargets = %v\nemit.Templates schrieb %v\n(Pre-Flight und Emit muessen dieselbe Menge sehen)", targets, written)
	}
}

// TestTemplateTargets_MisrootedRejected: eine falsch gewurzelte Quelle faellt im
// Pre-Flight auf (checkRoot), nicht erst beim Schreiben.
func TestTemplateTargets_MisrootedRejected(t *testing.T) {
	empty := fstest.MapFS{"irgendwas.txt": &fstest.MapFile{Data: []byte("x")}}
	if _, err := emit.TemplateTargets(empty, ""); err == nil {
		t.Error("falsch gewurzelte Quelle wurde akzeptiert (checkRoot muss greifen)")
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
		"docs/plan/planning/README.md",
		"docs/plan/planning/in-progress/roadmap.md", // Sonderfall: in-progress/, nicht flach
	}
	for _, rel := range singletons {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf("Singleton %s fehlt: %v", rel, err)
		}
	}
	// Struktur-Verzeichnisse via .gitkeep gehalten (LH-FA-02 0.8.0). docs/plan/adr/
	// traegt zugleich den Verzeichnis-Link aus AGENTS.md/harness/README.md.
	gitkeeps := []string{
		"docs/plan/adr/.gitkeep",
		"docs/plan/carveouts/.gitkeep",
		"docs/reviews/.gitkeep",
		"docs/plan/planning/open/.gitkeep",
		"docs/plan/planning/next/.gitkeep",
		"docs/plan/planning/done/.gitkeep",
	}
	for _, rel := range gitkeeps {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf(".gitkeep %s fehlt: %v", rel, err)
		}
	}
	// NICHT emittiert (0.8.0): wiederkehrende Vorlagen (referenziert aus vendored),
	// derivative Indexe (Fuelle-wenn-Inhalt-da), Set-Index-README; roadmap NICHT flach.
	absent := []string{
		"docs/plan/adr/NNNN-titel.template.md",
		"docs/plan/planning/slice.template.md",
		"docs/plan/planning/welle.template.md",
		"docs/plan/carveouts/carveout.template.md",
		"docs/reviews/review-report.template.md",
		"docs/plan/adr/README.md",       // derivativer ADR-Index
		"docs/plan/carveouts/README.md", // derivativer Carveout-Index
		"README.md",                     // Set-Index
		"docs/plan/planning/roadmap.md", // roadmap gehoert unter in-progress/
	}
	for _, rel := range absent {
		if _, err := os.Stat(filepath.Join(dir, rel)); err == nil {
			t.Errorf("%s wurde emittiert (darf nicht)", rel)
		}
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

// TestTemplates_RecurringNichtEmittiert: die fuenf wiederkehrenden Templates werden
// ab 0.8.0 (LH-FA-02, ADR-0005) NICHT mehr emittiert — weder co-located als
// .template.md (alte 0.7.0-Form) noch transformiert als .md. Sie liegen aus dem Fetch
// vendored und werden von dort je Artefakt kopiert (wie im Dogfood). Geprueft werden
// BEIDE Formen, die der Code faelschlich schreiben koennte (§3.6: alle Ziel-Namen
// pruefen, die unter einer Mutation entstuenden — hier faellt entweder die
// isRecurring-Weiche auf Singleton oder der alte co-located Zweig kehrt zurueck).
//
// Gegen den REALEN Kurs-Satz laeuft dieser Test NICHT: er nutzt courseSet(), und
// `.harness/` ist im Docker-Build-Kontext gar nicht sichtbar (.dockerignore). Die
// Treue der Fixture zum realen Satz haelt `test/courseset-fixture.bats` fest.
func TestTemplates_RecurringNichtEmittiert(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	for _, rel := range []string{
		// co-located (alte 0.7.0-Form)
		"docs/plan/adr/NNNN-titel.template.md",
		"docs/plan/planning/slice.template.md",
		"docs/plan/planning/welle.template.md",
		"docs/plan/carveouts/carveout.template.md",
		"docs/reviews/review-report.template.md",
		// transformierte .md-Form (falls die isRecurring-Weiche auf Singleton faellt)
		"docs/plan/adr/NNNN-titel.md",
		"docs/plan/planning/slice.md",
		"docs/plan/planning/welle.md",
		"docs/plan/carveouts/carveout.md",
		"docs/reviews/review-report.md",
	} {
		if _, err := os.Stat(filepath.Join(dir, rel)); err == nil {
			t.Errorf("wiederkehrendes Template emittiert (darf nicht, 0.8.0): %s", rel)
		}
	}
}

// TestTemplates_EmittierterBestandVollstaendig ist der Kern von slice-022b/028: die
// gefetchte Quelle traegt den VOLLEN Kurs-Satz (21 Dateien); emittiert werden ab
// 0.8.0 genau 14 — 8 Singletons (10 minus die zwei derivativen Indexe) plus 6
// .gitkeep der Struktur-Verzeichnisse; wiederkehrende Vorlagen bleiben ununemittiert.
// Geprueft wird der Ist-Bestand VOLLSTAENDIG — was nicht in der Erwartung steht,
// darf nicht da sein.
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
		// 8 Singletons -> .md (10 minus ADR-/Carveout-Index)
		"AGENTS.md",
		"docs/plan/planning/README.md",
		"docs/plan/planning/in-progress/roadmap.md",
		"harness/README.md",
		"harness/conventions.md",
		"spec/architecture.md",
		"spec/lastenheft.md",
		"spec/spezifikation.md",
		// 6 .gitkeep der Struktur-Verzeichnisse
		"docs/plan/adr/.gitkeep",
		"docs/plan/carveouts/.gitkeep",
		"docs/plan/planning/done/.gitkeep",
		"docs/plan/planning/next/.gitkeep",
		"docs/plan/planning/open/.gitkeep",
		"docs/reviews/.gitkeep",
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

	// (b)+(c) sind die Fixtures, an denen die VORIGE Fassung scheiterte
	// (Review-Befund slice-026 N-1): beide tragen in-scope-Templates an ihrer
	// Wurzel UND in Unterverzeichnissen, erfuellen also die damalige
	// Zwei-Ebenen-Bedingung — und kamen durch. Die aeltere Test-Fixture bestand
	// nur, weil sie zufaellig FLACH war. Genau die Klasse "ein Waechter besteht,
	// weil seine Fixture zufaellig passt", zum vierten Mal in diesem Zug.
	for _, c := range []struct {
		name string
		src  fstest.MapFS
	}{
		{"Vorfahre mit Template an der eigenen Wurzel", fstest.MapFS{
			"CHANGELOG.template.md":                &fstest.MapFile{Data: []byte("# <Projektname>\n")},
			"templates/AGENTS.template.md":         &fstest.MapFile{Data: []byte("# <Projektname>\n")},
			"templates/spec/lastenheft.template.md": &fstest.MapFile{Data: []byte("# <Projektname>\n")},
		}},
		{"Nachfahre mit Templates auf beiden Ebenen", fstest.MapFS{
			"README.template.md":              &fstest.MapFile{Data: []byte("# <Projektname>\n")},
			"planning/roadmap.template.md":    &fstest.MapFile{Data: []byte("# <Projektname>\n")},
			"planning/slice.template.md":      &fstest.MapFile{Data: []byte("# <Projektname>\n")},
		}},
	} {
		d := t.TempDir()
		if err := emit.Templates(c.src, d, "X", true); err == nil {
			t.Errorf("%s wurde akzeptiert — sie emittiert in falsche Ziel-Pfade", c.name)
		}
		if got := emittedTree(t, d); len(got) != 0 {
			t.Errorf("%s: trotz Fehler emittiert: %v", c.name, got)
		}
	}

	// (d) voellig fremde Quelle.
	if err := emit.Templates(fstest.MapFS{"irgendwas.txt": &fstest.MapFile{Data: []byte("x")}}, t.TempDir(), "X", true); err == nil {
		t.Error("fremde Quelle wurde als Erfolg gemeldet")
	}
}

// TestCheckRoot_EinRenameGenuegtNicht: die Schwelle ist zwei von drei Markern.
// Ein einzelnes Upstream-Rename darf den Bootstrap NICHT brechen — das war der
// Einwand gegen den urspruenglichen Ein-Datei-Anker (Befund slice-022b N-4).
func TestCheckRoot_EinRenameGenuegtNicht(t *testing.T) {
	src := courseSet().(fstest.MapFS)
	delete(src, "AGENTS.template.md") // upstream umbenannt/verschoben
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "X", true); err != nil {
		t.Fatalf("ein fehlender Marker sollte den Bootstrap nicht brechen: %v", err)
	}
	// Gegenprobe: zwei fehlende Marker MUESSEN abbrechen, sonst ist die
	// Schwelle wirkungslos.
	delete(src, "spec/lastenheft.template.md")
	if err := emit.Templates(src, t.TempDir(), "X", true); err == nil {
		t.Error("zwei fehlende Marker wurden akzeptiert — Schwelle wirkungslos")
	}
}

// TestTemplates_MinimalQuelle: eine Quelle, die nur die Wurzel-Anker traegt,
// emittiert genau sie (plus die quell-unabhaengigen Struktur-.gitkeep) — checkRoot
// verwirft sie nicht als "zu duenn".
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
	// Emittiert: die zwei Singletons der Quelle PLUS die tool-definierten .gitkeep der
	// Struktur-Verzeichnisse (quell-unabhaengig, LH-FA-02 0.8.0).
	want := []string{
		"AGENTS.md", "spec/lastenheft.md",
		"docs/plan/adr/.gitkeep", "docs/plan/carveouts/.gitkeep", "docs/reviews/.gitkeep",
		"docs/plan/planning/open/.gitkeep", "docs/plan/planning/next/.gitkeep", "docs/plan/planning/done/.gitkeep",
	}
	sort.Strings(want)
	if got := emittedTree(t, dir); strings.Join(got, "\n") != strings.Join(want, "\n") {
		t.Errorf("emittiert = %v\nwant = %v", got, want)
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

// TestNeutralizeRoadmap prueft die pure Neutralisierung: der broken ../done/-Link der
// "Abgeschlossene Wellen"-Beispielzeile wird zu Inline-Code (Form bleibt, Link weg),
// ohne Marker unveraendert.
func TestNeutralizeRoadmap(t *testing.T) {
	in := "## Abgeschlossene Wellen\n\n| <welle-NN> | YYYY-MM-DD | [`welle-NN-results.md`](../done/welle-NN-results.md) |\n"
	got := emit.NeutralizeRoadmap(in)
	if strings.Contains(got, "](../done/") {
		t.Errorf("broken ../done/-Link nicht neutralisiert:\n%s", got)
	}
	if !strings.Contains(got, "`welle-NN-results.md`") {
		t.Errorf("Beispiel-Form (Inline-Code) verloren:\n%s", got)
	}
	const plain = "kein Link hier\n"
	if emit.NeutralizeRoadmap(plain) != plain {
		t.Error("NeutralizeRoadmap veraenderte Text ohne den Marker")
	}
}

// TestTemplates_RoadmapGateSafe: die emittierte Roadmap (in-progress/roadmap.md)
// traegt KEINEN broken ../done/-Link mehr. Das ist die Wiring-Probe — sie belegt, dass
// der Roadmap-Zweig in planTemplates NeutralizeRoadmap wirklich aufruft (die
// Fixture-Roadmap in courseSet() traegt den realen broken Link). Ginge upstream der
// Link-Wortlaut verloren oder aenderte er seine Form, faellt es hier auf (Ausgabe-
// Property gemessen, nicht die Implementierung — §3.6).
func TestTemplates_RoadmapGateSafe(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "docs/plan/planning/in-progress/roadmap.md"))
	if err != nil {
		t.Fatalf("roadmap.md lesen: %v", err)
	}
	if strings.Contains(string(got), "](../done/") {
		t.Errorf("emittierte Roadmap traegt noch einen broken ../done/-Link:\n%s", got)
	}
	if strings.Contains(string(got), "Template-Hinweis") {
		t.Error("emittierte Roadmap traegt noch den Template-Hinweis-Block")
	}
}
