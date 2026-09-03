package main

import (
	"bytes"
	"errors"
	"os"
	"os/exec"
	"strings"
	"testing"
)

// TestArchiveWelleOhneVorschauSchreibtNichts haelt die Abgrenzung dieses Zweigs:
// ohne --vorschau endet er mit Exit 2, VOR jedem Baum-Zugriff, und nennt den
// Traeger des schreibenden Wegs. Ein Zweig, der ohne Schalter losliefe, waere die
// zweite Fassung derselben Operation, die ADR-0033 Festlegung 2 ausschliesst.
func TestArchiveWelleOhneVorschauSchreibtNichts(t *testing.T) {
	var out, errb bytes.Buffer
	if code := archiveWelle([]string{"welle-10"}, &out, &errb); code != 2 {
		t.Fatalf("Exit %d, want 2", code)
	}
	if out.Len() != 0 {
		t.Errorf("stdout nicht leer: %q", out.String())
	}
	if !strings.Contains(errb.String(), "make archive-welle WELLE=welle-10") {
		t.Errorf("stderr nennt den schreibenden Traeger nicht: %q", errb.String())
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
			if !strings.Contains(errb.String(), "archive-welle --vorschau") {
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
	if !strings.Contains(out.String(), "archive-welle --vorschau") {
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
