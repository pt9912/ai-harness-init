package main

import (
	"bytes"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// gitStumm ist die Test-Verdrahtung der vier schreibenden git-Operationen: sie
// schreibt mit und tut nichts. Ein Lauf, der sie ueberhaupt beruehrt, hat die
// Vorpruefung passiert — genau das misst der Fall darunter.
type gitStumm struct{ rufe []string }

func (g *gitStumm) Mv(alt, neu string) error  { g.rufe = append(g.rufe, "mv"); return nil }
func (g *gitStumm) Rm(pfade []string) error   { g.rufe = append(g.rufe, "rm"); return nil }
func (g *gitStumm) Add(pfade []string) error  { g.rufe = append(g.rufe, "add"); return nil }
func (g *gitStumm) Commit(nachricht string) error {
	g.rufe = append(g.rufe, "commit")
	return nil
}

// TestArchiveWelleSchreibendBrichtAnEinerSperreAb haelt die Reihenfolge-Zusage
// des schreibenden Zweigs: die Vorschau ist seine VORPRUEFUNG. Steht eine Sperre,
// endet er mit Exit 3, nennt sie — und hat bis dahin keine einzige git-Operation
// angefasst. Ein Zweig, der erst schriebe und dann urteilte, liesse den Baum
// zwischen zwei Zustaenden stehen.
//
// Die Sperre hier ist der unsaubere Arbeitsbaum, und zwar in seiner UNTRACKTEN
// Form (ADR-0033 Abnahme-Kriterium 2, lesende Haelfte).
func TestArchiveWelleSchreibendBrichtAnEinerSperreAb(t *testing.T) {
	root := t.TempDir()
	if err := os.MkdirAll(filepath.Join(root, "docs", "plan", "planning", "done"), 0o755); err != nil {
		t.Fatal(err)
	}
	g := &gitStumm{}
	var out, errb bytes.Buffer
	code := archiveWelleLauf(root, "welle-10", false, "?? fremd.txt\n", nil, g, &out, &errb)
	if code != 3 {
		t.Fatalf("Exit %d, want 3 (Sperre steht)", code)
	}
	if len(g.rufe) != 0 {
		t.Fatalf("git-Operationen trotz Sperre: %v", g.rufe)
	}
	if !strings.Contains(out.String(), "[unsauber]") {
		t.Errorf("die Sperre steht nicht im Bericht: %q", out.String())
	}
}

// TestArchiveWelleVorschauRuehrtKeineGitOperationAn: mit --vorschau endet der
// Zweig nach dem Bericht, auch wenn keine Sperre steht.
func TestArchiveWelleVorschauRuehrtKeineGitOperationAn(t *testing.T) {
	root := t.TempDir()
	if err := os.MkdirAll(filepath.Join(root, "docs", "plan", "planning", "done"), 0o755); err != nil {
		t.Fatal(err)
	}
	g := &gitStumm{}
	var out, errb bytes.Buffer
	// Ein leerer done/-Baum traegt eigene Sperren; gemessen wird hier allein, dass
	// der Vorschau-Zweig keine git-Operation anfasst.
	archiveWelleLauf(root, "welle-10", true, "", nil, g, &out, &errb)
	if len(g.rufe) != 0 {
		t.Fatalf("git-Operationen im Vorschau-Zweig: %v", g.rufe)
	}
}

// TestArchiveWelleAufrufFehler: fehlende Kennung, unbekanntes Flag und zwei
// Kennungen sind Aufruf-Fehler (Exit 2) mit Usage auf stderr; --help ist Exit 0
// mit Usage auf stdout.
func TestArchiveWelleAufrufFehler(t *testing.T) {
	faelle := []struct {
		name string
		args []string
		want int
	}{
		{"ohne Argument", []string{}, 2},
		{"nur --vorschau", []string{"--vorschau"}, 2},
		{"unbekanntes Flag", []string{"--bogus", "welle-10"}, 2},
		{"zwei Kennungen", []string{"--vorschau", "welle-10", "welle-11"}, 2},
	}
	for _, f := range faelle {
		t.Run(f.name, func(t *testing.T) {
			var out, errb bytes.Buffer
			if code := archiveWelle(f.args, &out, &errb); code != f.want {
				t.Fatalf("Exit %d, want %d (stderr: %q)", code, f.want, errb.String())
			}
			if !strings.Contains(errb.String(), "archive-welle [--vorschau]") {
				t.Errorf("Usage fehlt auf stderr: %q", errb.String())
			}
		})
	}
}

func TestArchiveWelleHelp(t *testing.T) {
	var out, errb bytes.Buffer
	if code := archiveWelle([]string{"--help"}, &out, &errb); code != 0 {
		t.Fatalf("Exit %d, want 0", code)
	}
	if !strings.Contains(out.String(), "archive-welle [--vorschau]") {
		t.Fatalf("Usage fehlt auf stdout: %q", out.String())
	}
}

// TestUsageNenntAlleDreiUnterkommandos: die Hilfe des Traegers fuehrt jedes
// Unterkommando, das main() dispatcht — sonst ist eine Faehigkeit vorhanden und
// unauffindbar.
func TestUsageNenntAlleDreiUnterkommandos(t *testing.T) {
	for _, name := range []string{"span-emit", "span-report", "archive-welle"} {
		if !strings.Contains(usage, name) {
			t.Errorf("usage nennt %q nicht", name)
		}
	}
}

// TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad misst den
// main()-Zweig als PROZESS, nicht die Funktion dahinter: Traegt das Argument
// keine Welle-Kennung, endet der Traeger mit Exit 2, schreibt nichts auf stdout
// und laesst das Arbeitsverzeichnis, wie es war.
//
// Der Durchfall ist die Gefahr, und er ist still: ohne den `case` landet
// `archive-welle` in run() — dort ist es ein Positionsargument, das der
// Flag-Parser stehen laesst, und der Init-Pfad SCHREIBT in das
// Arbeitsverzeichnis. Genau die Eigenschaft, die dieses Unterkommando traegt,
// kippte damit lautlos. Die dritte Pruefung unten faengt diesen Durchfall, die
// ersten zwei ein Umhaengen des Zweigs auf ein anderes Unterkommando.
// Gegenbeispiel: test/mutations/237-archive-welle-go-routing-vertauscht.sh.
func TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad(t *testing.T) {
	root := newRoot(t)
	stdout, err := runChild(t, root, "archive-welle", "")

	var ee *exec.ExitError
	if !errors.As(err, &ee) || ee.ExitCode() != 2 {
		t.Fatalf("Exit %v, want 2 (Aufruf-Fehler ohne <welle-id>)", err)
	}
	if stdout != "" {
		t.Errorf("stdout nicht leer: %q", stdout)
	}
	eintraege, lerr := os.ReadDir(root)
	if lerr != nil {
		t.Fatal(lerr)
	}
	if len(eintraege) != 1 || eintraege[0].Name() != ".git" {
		namen := make([]string, 0, len(eintraege))
		for _, e := range eintraege {
			namen = append(namen, e.Name())
		}
		t.Fatalf("Arbeitsverzeichnis nach dem Lauf = %v, want nur .git — der Zweig hat in den schreibenden Init-Pfad durchgereicht", namen)
	}
}
