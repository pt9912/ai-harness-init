package main

import (
	"io/fs"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// kantenLink trifft das Ziel eines Markdown-Links "](<ziel>)" oder "](<ziel>#…)".
var kantenLink = regexp.MustCompile(`\]\(([^)#\s]+)(#[^)]*)?\)`)

// kantenRepo baut das Wegwerf-Repo fuer eine Kante `<from> → done`: die zu
// bewegende Datei slice-kante.md in <from>/ mit einem praefixlosen
// AUSGEHEND-Ziel auf ein Geschwister, das liegen bleibt; dieses Geschwister
// zeigt auf die bewegte Datei in BEIDEN Formen (praefixlos und mit Praefix);
// eingehende Praefix-Verweise aus done/** und docs/reviews/**; eine Datei in
// einem Unterverzeichnis von <from>/ (getrackt) und eine ungetrackte Datei
// direkt in <from>/, beide mit demselben praefixlosen Verweis. Der
// Shell-Traeger wird hineinkopiert, weil er seine Repo-Wurzel aus der eigenen
// Lage bestimmt (s. sliceMvRepo).
func kantenRepo(t *testing.T, from string) string {
	t.Helper()
	root := t.TempDir()
	pl := "docs/plan/planning/"
	schreibeDatei(t, root, pl+from+"/slice-kante.md",
		"# Slice slice-kante\n\nGeschwister: [bleibt](slice-kante-bleibt.md)\n")
	schreibeDatei(t, root, pl+from+"/slice-kante-bleibt.md",
		"# Slice slice-kante-bleibt\n\nPraefixlos: [kante](slice-kante.md#1-ziel)\nMit Praefix: [kante](../"+from+"/slice-kante.md)\n")
	schreibeDatei(t, root, pl+from+"/sub/slice-sub.md", "[kante](slice-kante.md)\n")
	schreibeDatei(t, root, pl+"done/slice-alt.md", "[kante](../"+from+"/slice-kante.md)\n")
	schreibeDatei(t, root, "docs/reviews/2026-01-01-r.md", "[kante](../plan/planning/"+from+"/slice-kante.md)\n")

	skript, err := os.ReadFile(sliceMvSkript)
	if err != nil {
		t.Fatalf("Shell-Traeger nicht lesbar (%s): %v", sliceMvSkript, err)
	}
	schreibeDatei(t, root, "harness/tools/slice-mv.sh", string(skript))

	gitLauf(t, root, "init", "-q")
	gitLauf(t, root, "config", "user.email", "harness@example.invalid")
	gitLauf(t, root, "config", "user.name", "Harness Test")
	gitLauf(t, root, "add", "-A")
	gitLauf(t, root, "commit", "-q", "-m", "Ausgangsstand")
	schreibeDatei(t, root, pl+from+"/slice-ungetrackt.md", "[kante](slice-kante.md)\n")
	return root
}

// kantenVerweise zaehlt ueber alle getrackten .md-Dateien die Links, deren Ziel
// relativ zur Datei auf den repo-relativen Pfad `ziel` aufloest.
func kantenVerweise(t *testing.T, root, ziel string) int {
	t.Helper()
	n := 0
	for _, rel := range strings.Fields(gitLauf(t, root, "ls-files", "*.md")) {
		inhalt, err := os.ReadFile(filepath.Join(root, rel))
		if err != nil {
			t.Fatal(err)
		}
		for _, m := range kantenLink.FindAllStringSubmatch(string(inhalt), -1) {
			if path.Join(path.Dir(rel), m[1]) == ziel {
				n++
			}
		}
	}
	return n
}

// kantenBestand liest das Ausgangsverzeichnis vollstaendig (rekursiv, getrackt
// wie ungetrackt) als Abbildung repo-relativer Pfad → Inhalt.
func kantenBestand(t *testing.T, dir string) map[string]string {
	t.Helper()
	ist := map[string]string{}
	err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		b, err := os.ReadFile(p)
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(dir, p)
		ist[filepath.ToSlash(rel)] = string(b)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	return ist
}

// pruefeKanteNachDone faehrt `slice-mv.sh slice-kante done` als echten
// bash-Prozess ueber kantenRepo(from) und haelt den ganzen Ausgang: Exit 0,
// genau zwei neue Commits, deren erster ein reiner Rename ist, jeder Link, der
// vorher auf die bewegte Datei aufloeste, loest danach auf ihren neuen Ort auf,
// der vollstaendige Ist-Bestand von <from>/ gegen die erwartete Abbildung und
// die Zaehlzeilen der Ausgabe.
func pruefeKanteNachDone(t *testing.T, from string) {
	t.Helper()
	root := kantenRepo(t, from)
	pl := "docs/plan/planning/"
	alt, neu := pl+from+"/slice-kante.md", pl+"done/slice-kante.md"
	vorher := kantenVerweise(t, root, alt)
	if vorher != 4 {
		t.Fatalf("Aufbau: erwartet 4 Links auf %s, sind %d", alt, vorher)
	}

	cmd := exec.Command("bash", filepath.Join(root, "harness/tools/slice-mv.sh"), "slice-kante", "done")
	cmd.Dir = root
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("slice-mv.sh %s -> done: %v\n%s", from, err, out)
	}

	if n := gitLauf(t, root, "rev-list", "--count", "HEAD"); n != "3" {
		t.Errorf("erwartet Ausgangsstand plus Move- und Nachzug-Commit (3 Commits), sind %s", n)
	}
	if s := gitLauf(t, root, "log", "-1", "--format=%s", "HEAD~1"); !strings.HasSuffix(s, "(reiner Move)") {
		t.Errorf("der vorletzte Commit ist nicht der reine Move: %q", s)
	}
	numstat := gitLauf(t, root, "show", "--numstat", "--format=", "-M", "HEAD~1")
	if want := "0\t0\t" + pl + "{" + from + " => done}/slice-kante.md"; numstat != want {
		t.Errorf("der Move-Commit ist kein reiner Rename:\nist:      %q\nerwartet: %q", numstat, want)
	}

	if n := kantenVerweise(t, root, alt); n != 0 {
		t.Errorf("%d Link(s) zeigen nach dem Wechsel weiter auf %s", n, alt)
	}
	if n := kantenVerweise(t, root, neu); n != vorher {
		t.Errorf("%d von %d Links loesen nach dem Wechsel auf %s auf", n, vorher, neu)
	}

	bewegt, err := os.ReadFile(filepath.Join(root, neu))
	if err != nil {
		t.Fatal(err)
	}
	if want := "# Slice slice-kante\n\nGeschwister: [bleibt](../" + from + "/slice-kante-bleibt.md)\n"; string(bewegt) != want {
		t.Errorf("bewegte Datei:\nist:\n%s\nerwartet:\n%s", bewegt, want)
	}

	soll := map[string]string{
		"slice-kante-bleibt.md": "# Slice slice-kante-bleibt\n\nPraefixlos: [kante](../done/slice-kante.md#1-ziel)\nMit Praefix: [kante](../done/slice-kante.md)\n",
		"sub/slice-sub.md":      "[kante](slice-kante.md)\n",
		"slice-ungetrackt.md":   "[kante](slice-kante.md)\n",
	}
	ist := kantenBestand(t, filepath.Join(root, pl+from))
	for k, v := range soll {
		if ist[k] != v {
			t.Errorf("%s/%s:\nist:\n%q\nerwartet:\n%q", from, k, ist[k], v)
		}
	}
	for k := range ist {
		if _, ok := soll[k]; !ok {
			t.Errorf("%s/%s liegt im Ausgangsverzeichnis und ist nicht erwartet", from, k)
		}
	}

	if st := gitLauf(t, root, "status", "--porcelain"); st != "?? "+pl+from+"/slice-ungetrackt.md" {
		t.Errorf("Arbeitsbaum nach dem Lauf: erwartet nur die ungetrackte Datei, ist:\n%s", st)
	}
	for _, zeile := range []string{
		"eingehend: 3 Datei(en) mit Verweisen nachgezogen, darin 1 praefixlose(r) Link(s) aus Geschwistern unter " + from + "/",
		"ausgehend: 1 präfixloses Ziel(e)",
	} {
		if !strings.Contains(string(out), zeile) {
			t.Errorf("die Ausgabe nennt %q nicht:\n%s", zeile, out)
		}
	}
}

// TestSliceMvEchtKanteOpenNachDone haelt die Kante `open → done` von
// harness/tools/slice-mv.sh im Ganzen (pruefeKanteNachDone): Exit 0, reiner
// Rename als eigener Commit, jeder Verweis loest am neuen Ort auf, der
// Ist-Bestand von open/ ist vollstaendig der erwartete, und die Datei mit
// Praefix- und praefixloser Form zaehlt in der Zeile `eingehend:` einmal.
//
// Gegenbeispiele: test/mutations/589-slice-mv-main-verliert-den-move-commit.sh
// nimmt main() den Move-Commit, test/mutations/590-slice-mv-main-ruft-die-praefixlose-ersetzung-nicht.sh
// nimmt main() den Aufruf der praefixlosen Ersetzung.
func TestSliceMvEchtKanteOpenNachDone(t *testing.T) {
	pruefeKanteNachDone(t, "open")
}

// TestSliceMvEchtKanteNextNachDone haelt die Kante `next → done` mit derselben
// Pruefung wie TestSliceMvEchtKanteOpenNachDone; die zwei Kanten unterscheiden
// sich allein im Ausgangsverzeichnis, und beide sind die Stilllegungs-Kanten aus
// modul-05-planning-harness.md §Ein Slice, dessen Gegenstand ein anderer
// uebernimmt.
//
// Gegenbeispiele: dieselben zwei Faelle wie dort (589, 590) faerben auch diesen
// Test rot.
func TestSliceMvEchtKanteNextNachDone(t *testing.T) {
	pruefeKanteNachDone(t, "next")
}
