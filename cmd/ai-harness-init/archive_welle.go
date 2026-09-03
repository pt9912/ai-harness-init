// Das Unterkommando `archive-welle` sagt, was die Archivierung der Zeitdokumente
// einer geschlossenen Welle taete. Der Traeger ist das Produkt-Binaer, die
// Operation sein Unterkommando (ADR-0033 Festlegung 1); die Logik liegt in
// internal/archive, hier steht der Dispatch und die eine Stelle, an der `git`
// laeuft.
//
// ES SCHREIBT NICHTS. Zwei Stuecke tragen das, und beide sind nachrechenbar
// statt zugesagt: der NICHT-Test-Anteil von internal/archive fuehrt keinen
// schreibenden Aufruf —
//
//	git grep -cE 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' \
//	  -- 'internal/archive/*.go' ':!internal/archive/*_test.go'
//
// bleibt ohne Treffer —, und die einzigen Fremdprozesse dieses Zweigs sind die
// zwei lesenden git-Aufrufe unten. Ohne --vorschau endet er ausserdem VOR jedem
// Baum-Zugriff mit Exit 2 und nennt den Grund
// (TestArchiveWelleOhneVorschauSchreibtNichts).
//
// Die Testdateien gehoeren nicht in die Messung und sind darum ausgeschlossen:
// sie legen ihre synthetischen Baeume selbst an und schreiben dabei in
// t.TempDir(). Wer sie mitzaehlt, bekommt eine Zahl, die die Zusage zu
// widerlegen scheint, und kann eine spaeter hinzukommende echte Schreib-Stelle
// nicht mehr von ihnen unterscheiden.
//
// GRENZE, benannt statt verschwiegen: fuer die Schreib-Freiheit selbst gibt es
// keinen Waechter. Wer hier einen schreibenden Aufruf ergaenzt, faellt keinem
// Gate auf; die zwei Stuecke oben sind eine Messung, keine Schranke.
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
	dateien, err := gitLsFiles(root)
	if err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	bericht, err := archive.Vorschau(root, welle, porcelain, dateien)
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

// gitStatusPorcelain und gitLsFiles sind die einzigen zwei Stellen, an denen
// dieser Zweig ein fremdes Programm startet — beide rein lesend, beide in dieser
// Datei. Ihre Ergebnisse gehen als Werte an archive.Vorschau, damit die
// Urteils-Logik ohne git pruefbar bleibt.
func gitStatusPorcelain(root string) (string, error) {
	b, err := gitLesend(root, "status", "--porcelain")
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// gitLsFiles liefert den Suchraum der Verweis-Vorpruefung: jeden Pfad, den der
// Index fuehrt. Es ist dieselbe Menge, ueber der der schreibende Traeger sein
// `git grep` fuehrt — ohne Dateityp-Einschraenkung, damit die Vorschau denselben
// Verweis sieht wie er. Ausgenommen wird nichts an dieser Stelle: die
// Ausnahme-Menge steht in archive.AusgenommenePfade und gilt dort fuer jeden
// Eingang. -z, weil ein Dateiname ein Zeilenende tragen darf.
func gitLsFiles(root string) ([]string, error) {
	b, err := gitLesend(root, "ls-files", "-z")
	if err != nil {
		return nil, err
	}
	return strings.FieldsFunc(string(b), func(r rune) bool { return r == 0 }), nil
}

// gitLesend startet git mit Kontext-Timeout und gibt stdout zurueck.
func gitLesend(root string, args ...string) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	b, err := exec.CommandContext(ctx, "git", append([]string{"-C", root}, args...)...).Output()
	if err != nil {
		return nil, fmt.Errorf("git %s: %w", strings.Join(args, " "), err)
	}
	return b, nil
}
