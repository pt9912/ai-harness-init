package main

import (
	"bytes"
	"crypto/sha256"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
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

// TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe misst die eine
// Eigenschaft, die den lesenden vom schreibenden Zweig trennt: `--vorschau`
// SCHREIBT NICHTS. Gemessen wird sie an dem Baum, an dem sie ueberhaupt etwas
// aussagt — einem OHNE Sperre, an dem der schreibende Lauf also liefe.
//
// Die erste Pruefung ist die tragende und keine Formalie: an einem Baum MIT
// Sperre endet der Zweig schon eine Zeile frueher (Exit 3), und ein Test, der
// das nicht ausschliesst, misst die Vorpruefung statt des Schalters — er bliebe
// gruen, auch wenn es den Schalter gar nicht mehr gaebe.
//
// Drei unabhaengige Wege ins Rot: der Exit-Code, die git-Aufrufe und der
// Baum-Abdruck. Der Abdruck ist der breiteste — er faellt schon beim ersten
// `os.MkdirAll` des schreibenden Zweigs, also bevor eine git-Operation faellt.
// Gegenbeispiel: test/mutations/242-archive-welle-go-vorschau-schaltet-nicht-ab.sh.
func TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe(t *testing.T) {
	root := sperrenfreierBaum(t)
	dateien := indexAttrappe(t, root)
	vorher := baumAbdruck(t, root)

	g := &gitStumm{}
	var out, errb bytes.Buffer
	code := archiveWelleLauf(root, "welle-10", true, "", dateien, g, &out, &errb)

	// Zuerst die Vorbedingung, und sie ist die einzige mit Fatal: ohne sie sagen
	// die drei Pruefungen darunter nichts ueber den Schalter aus.
	if !strings.Contains(out.String(), "Sperren: keine") {
		t.Fatalf("der Prueftext traegt eine Sperre — gemessen waere die Vorpruefung, nicht der Schalter:\n%s", out.String())
	}
	// Danach alle drei Wege, keiner bricht ab: welche von ihnen faellt, ist der
	// Befund selbst — der Baum-Abdruck faellt frueher als die git-Aufrufe.
	if nachher := baumAbdruck(t, root); nachher != vorher {
		t.Errorf("der Vorschau-Zweig hat den Baum veraendert:\nvorher\n%s\nnachher\n%s", vorher, nachher)
	}
	if len(g.rufe) != 0 {
		t.Errorf("git-Operationen im Vorschau-Zweig: %v", g.rufe)
	}
	if code != 0 {
		t.Errorf("Exit %d, want 0 (Vorschau ohne Sperre; stderr: %q)", code, errb.String())
	}
}

// TestArchiveWelleSchreibendLaeuftAmSelbenBaum ist die Gegenprobe zum Fall
// darueber: DERSELBE Baum, nur ohne den Schalter — und dann faellt der Abdruck.
// Ohne sie sagte der Fall oben nur, dass an diesem Baum nichts passiert; mit ihr
// sagt er, dass der Schalter der Grund ist.
func TestArchiveWelleSchreibendLaeuftAmSelbenBaum(t *testing.T) {
	root := sperrenfreierBaum(t)
	dateien := indexAttrappe(t, root)
	vorher := baumAbdruck(t, root)

	g := &gitStumm{}
	var out, errb bytes.Buffer
	archiveWelleLauf(root, "welle-10", false, "", dateien, g, &out, &errb)

	if len(g.rufe) == 0 {
		t.Fatalf("ohne --vorschau keine einzige git-Operation — der Baum traegt eine Sperre:\n%s", out.String())
	}
	if baumAbdruck(t, root) == vorher {
		t.Fatal("ohne --vorschau blieb der Baum unveraendert — der Fall oben misst dann nichts")
	}
}

// sperrenfreierBaum legt den kleinsten Baum an, ueber dem KEINE der Sperren aus
// archive.Vorschau steht: Ergebnisnotiz da, genau ein Welle-Plan, ein eingesammelter Slice, kein
// done/welle-10/, kein wellenloser Slice (also keine Untergrenzen-Frage), kein
// Review-Report (also kein Haenger). Die zwei Stub-Vorlagen liegen mit, weil der
// schreibende Zweig sonst schon vor seinem ersten Schreibzugriff ausfiele — und
// der Baum-Abdruck dann nichts mehr zeigte.
func sperrenfreierBaum(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	vorlagen := filepath.Join(root, ".harness", "baseline", "v9.99.0",
		"templates", "docs", "plan", "planning")
	stub := "# <Titel>\n\n> **ARCHIVIERT** — Volltext:\n" +
		"> `unzip -p done/<welle-id>/archiv.zip <pfad-im-archiv>`\n\n" +
		"**Geschlossen:** <JJJJ-MM-TT>\n"
	for pfad, inhalt := range map[string]string{
		filepath.Join(vorlagen, "archiv-stub-slice.template.md"): stub,
		filepath.Join(vorlagen, "archiv-stub-welle.template.md"): stub,
		filepath.Join(done, "welle-10-eine-welle.md"):            "# Welle welle-10: Der Plan\n\n## 1. Ziel\n",
		filepath.Join(done, "welle-10-results.md"):               "# welle-10 — Ergebnisse\n\n**Abschluss:** 2026-06-06\n",
		filepath.Join(done, "slice-100-a.md"):                    "# Slice slice-100: Der Gegenstand\n\n**Welle:** welle-10\n",
	} {
		if err := os.MkdirAll(filepath.Dir(pfad), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(pfad, []byte(inhalt), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	return root
}

// indexAttrappe liefert den Suchraum-Eingang, den der Aufrufer im Betrieb aus
// `git ls-files` bekommt: jede Datei des Baums, repo-relativ.
func indexAttrappe(t *testing.T, root string) []string {
	t.Helper()
	var out []string
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		rel, rerr := filepath.Rel(root, p)
		if rerr != nil {
			return rerr
		}
		out = append(out, filepath.ToSlash(rel))
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	sort.Strings(out)
	return out
}

// baumAbdruck ist ein Abdruck des gesamten Baums unter root: jeder Pfad mit der
// Laenge und dem Hash seines Inhalts, sortiert. Verzeichnisse stehen mit darin —
// ein angelegtes leeres Verzeichnis ist bereits ein Schreibzugriff.
func baumAbdruck(t *testing.T, root string) string {
	t.Helper()
	var zeilen []string
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, rerr := filepath.Rel(root, p)
		if rerr != nil {
			return rerr
		}
		if d.IsDir() {
			zeilen = append(zeilen, filepath.ToSlash(rel)+"/")
			return nil
		}
		b, rerr := os.ReadFile(p)
		if rerr != nil {
			return rerr
		}
		zeilen = append(zeilen, fmt.Sprintf("%s %d %x", filepath.ToSlash(rel), len(b), sha256.Sum256(b)))
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	sort.Strings(zeilen)
	return strings.Join(zeilen, "\n")
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
