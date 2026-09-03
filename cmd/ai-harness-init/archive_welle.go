// Das Unterkommando `archive-welle` sagt, was die Archivierung der Zeitdokumente
// einer geschlossenen Welle taete. Der Traeger ist das Produkt-Binaer, die
// Operation sein Unterkommando (ADR-0033 Festlegung 1); die Logik liegt in
// internal/archive, hier steht der Dispatch und die eine Stelle, an der `git`
// laeuft.
//
// ES SCHREIBT NICHTS. Zwei Stuecke tragen das, und beide sind nachrechenbar
// statt zugesagt: internal/archive fuehrt keinen schreibenden Aufruf
// (grep -cE 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\('
// ueber internal/archive/*.go), und der einzige Fremdprozess dieses Zweigs ist
// das lesende git status --porcelain unten. Ohne --vorschau endet er ausserdem
// VOR jedem Baum-Zugriff mit Exit 2 und nennt den Grund
// (TestArchiveWelleOhneVorschauSchreibtNichts).
//
// GRENZE, benannt statt verschwiegen: fuer die Schreib-Freiheit selbst gibt es
// keinen Waechter. Wer hier einen schreibenden Aufruf ergaenzt, faellt keinem
// Gate auf; die zwei Stuecke oben sind eine Messung von heute, keine Schranke.
//
// Der schreibende Zweig — Move, Zip, Stubs, Verweis-Nachzug, zwei Commits —
// liegt beim Shell-Helfer hinter `make archive-welle`, und der bleibt bis zu
// seiner Abloesung sein einziger Traeger (ADR-0033 Festlegung 2).

package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/pt9912/ai-harness-init/internal/archive"
	"github.com/pt9912/ai-harness-init/internal/span"
)

const archiveWelleUsage = `ai-harness-init archive-welle --vorschau <welle-id>

Sagt, was die Archivierung der Zeitdokumente einer geschlossenen Welle taete,
und schreibt dabei nichts: die drei Einsammel-Klassen (Mitglieder · wellenlos ·
fremd), die Review-Reports, die Dateien mit einem Verweis auf etwas Bewegtes und
die fail-closed-Ausgaenge, an denen der schreibende Lauf abbraeche.

  --vorschau    PFLICHT. Ohne sie endet der Aufruf mit Exit 2 und schreibt
                nichts — den schreibenden Zweig faehrt `+"`make archive-welle`"+`.

Exit-Codes:
  0   Vorschau gefahren, keine Sperre — der schreibende Lauf liefe.
  2   Aufruf-Fehler oder fehlendes --vorschau.
  3   mindestens eine Sperre steht.
  1   Laufzeit-Fehler (keine Repo-Wurzel, git nicht lauffaehig, Lesefehler).
`

// archiveWelle ist der testbare Kern des Unterkommandos: Argumente rein, Text
// raus, Exit-Code zurueck.
func archiveWelle(args []string, out, errOut io.Writer) int {
	welle, vorschau, code := parseArchiveWelle(args, out, errOut)
	if code >= 0 {
		return code
	}
	if !vorschau {
		fmt.Fprintln(errOut, "archive-welle: ohne --vorschau schreibt dieses Unterkommando nichts.")
		fmt.Fprintln(errOut, "  Der schreibende Zweig — Move, Zip, Stubs, Verweis-Nachzug, zwei Commits — liegt beim Shell-Helfer:")
		fmt.Fprintln(errOut, "    make archive-welle WELLE="+welle)
		return 2
	}
	root, err := repoWurzel()
	if err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	porcelain, err := gitStatusPorcelain(root)
	if err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	bericht, err := archive.Vorschau(root, welle, porcelain)
	if err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	fmt.Fprint(out, archive.Schreibe(bericht))
	if len(bericht.Sperren) > 0 {
		return 3
	}
	return 0
}

// parseArchiveWelle trennt die Welle-Kennung vom Vorschau-Schalter. Der dritte
// Rueckgabewert ist -1, solange der Aufruf weiterlaeuft, sonst der Exit-Code
// eines bereits gedruckten Ausgangs.
func parseArchiveWelle(args []string, out, errOut io.Writer) (welle string, vorschau bool, code int) {
	for _, a := range args {
		switch {
		case a == "-h" || a == "--help":
			fmt.Fprint(out, archiveWelleUsage)
			return "", false, 0
		case a == "--vorschau":
			vorschau = true
		case strings.HasPrefix(a, "-"):
			fmt.Fprintln(errOut, "Fehler: unbekanntes Flag:", a)
			fmt.Fprint(errOut, archiveWelleUsage)
			return "", false, 2
		case welle == "":
			welle = a
		default:
			fmt.Fprintln(errOut, "Fehler: archive-welle nimmt genau eine <welle-id>")
			fmt.Fprint(errOut, archiveWelleUsage)
			return "", false, 2
		}
	}
	if welle == "" {
		fmt.Fprintln(errOut, "Fehler: archive-welle braucht eine <welle-id>")
		fmt.Fprint(errOut, archiveWelleUsage)
		return "", false, 2
	}
	return welle, vorschau, -1
}

// repoWurzel loest die Repo-Wurzel ueber dem Arbeitsverzeichnis auf — dieselbe
// Aufloesung, die der Ablageort der Erfassung nutzt; eine zweite Fassung waere
// eine zweite Quelle.
func repoWurzel() (string, error) {
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	root, ok := span.FindRoot(wd)
	if !ok {
		return "", fmt.Errorf("keine Repo-Wurzel ueber %s", wd)
	}
	return root, nil
}

// gitStatusPorcelain ist die EINZIGE Stelle, an der dieser Zweig ein fremdes
// Programm startet. Der Aufruf ist rein lesend; sein Ergebnis geht als Wert an
// archive.Vorschau, damit die Urteils-Logik ohne git pruefbar bleibt.
func gitStatusPorcelain(root string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	b, err := exec.CommandContext(ctx, "git", "-C", root, "status", "--porcelain").Output()
	if err != nil {
		return "", fmt.Errorf("git status --porcelain: %w", err)
	}
	return string(b), nil
}
