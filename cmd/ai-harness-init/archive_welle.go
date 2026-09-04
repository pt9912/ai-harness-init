// Das Unterkommando `archive-welle` archiviert die Zeitdokumente einer
// geschlossenen Welle — und sagt mit `--vorschau` vorher, was es taete. Der
// Traeger ist das Produkt-Binaer, die Operation sein Unterkommando (ADR-0033
// Festlegung 1); die Logik liegt in internal/archive, hier steht der Dispatch
// und die eine Stelle, an der `git` laeuft.
//
// ZWEI ZWEIGE, ein Einstiegspunkt. Beide fahren dieselbe Vorschau: sie ist die
// Vorpruefung des schreibenden Laufs, und eine Sperre beendet ihn mit Exit 3,
// bevor er etwas anfasst (TestArchiveWelleSchreibendBrichtAnEinerSperreAb). Mit
// `--vorschau` endet der Aufruf danach; ohne sie laeuft die Operation — Move und
// Commit 1, Zip, Stubs, Verweis-Nachzug, Staging, Commit 2.
//
// Die Vorschau-Haelfte ist an einem SPERRENFREIEN Baum gedeckt, denn nur dort
// sagt sie etwas: TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe misst
// Exit-Code, git-Aufrufe und den Baum-Abdruck,
// TestArchiveWelleSchreibendLaeuftAmSelbenBaum die Gegenprobe ohne den Schalter.
//
// GRENZE, benannt statt verschwiegen: die vier schreibenden git-Aufrufe unten
// laufen in keinem Test. Was ueber ihnen liegt — Reihenfolge, Aufteilung auf zwei
// Commits, die gestagte Pfad-Liste — traegt die Git-Schnittstelle von
// internal/archive und ist dort ueber einem synthetischen Baum gedeckt
// (TestAnwendenTrenntMoveVonInhalt); DASS die vier Aufrufe hier das tun, was ihr
// Name sagt, ist es nicht.

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

const archiveWelleUsage = `ai-harness-init archive-welle [--vorschau] <welle-id>

Archiviert die Zeitdokumente einer GESCHLOSSENEN Welle: Slice-Dateien,
Welle-Plan und Review-Reports wandern nach
docs/plan/planning/done/<welle-id>/archiv.zip, an der Stelle von Slice und Plan
bleibt je ein gekuerzter Stub aus der vendored Vorlage. Die Ergebnisnotiz bleibt
vollstaendig und flach. Verlangt einen sauberen Arbeitsbaum und setzt zwei
getrennte Commits: zuerst den reinen Move, danach Archiv, Stubs und
Verweis-Nachzug.

  --vorschau    Nur sagen, was der Lauf taete, und nichts schreiben: die drei
                Einsammel-Klassen (Mitglieder · wellenlos · fremd), die
                Review-Reports, die Dateien mit einem Verweis auf etwas Bewegtes
                und die fail-closed-Ausgaenge, an denen der Lauf abbraeche.

Exit-Codes:
  0   Lauf (bzw. Vorschau) gefahren, keine Sperre.
  2   Aufruf-Fehler.
  3   mindestens eine Sperre steht — geschrieben wurde nichts.
  1   Laufzeit-Fehler (keine Repo-Wurzel, git nicht lauffaehig, Lese-/Schreibfehler).
`

// archiveWelle ist der testbare Kern des Unterkommandos: Argumente rein, Text
// raus, Exit-Code zurueck.
func archiveWelle(args []string, out, errOut io.Writer) int {
	welle, vorschau, code := parseArchiveWelle(args, out, errOut)
	if code >= 0 {
		return code
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
	return archiveWelleLauf(root, welle, vorschau, porcelain, dateien, gitSchreibend{root}, out, errOut)
}

// archiveWelleLauf ist der Kern beider Zweige: er startet keinen Prozess, sondern
// nimmt die zwei git-Lesungen als Werte und die schreibenden git-Operationen als
// Schnittstelle. Dadurch ist die Reihenfolge-Zusage pruefbar — die Vorschau ist
// die Vorpruefung, und eine Sperre beendet den Lauf, BEVOR er etwas anfasst.
// Gedeckt von TestArchiveWelleSchreibendBrichtAnEinerSperreAb.
func archiveWelleLauf(root, welle string, vorschau bool, porcelain string, dateien []string, g archive.Git, out, errOut io.Writer) int {
	bericht, err := archive.Vorschau(root, welle, porcelain, dateien)
	if err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	fmt.Fprint(out, archive.Schreibe(bericht))
	if len(bericht.Sperren) > 0 {
		return 3
	}
	// ZUSAGE: hier endet der Vorschau-Zweig — mit Exit 0 und ohne einen einzigen
	// Schreibzugriff, auch dann, wenn keine Sperre steht. Das ist die einzige
	// Eigenschaft, die einen Blick auf eine Welle von ihrer Archivierung trennt.
	// Gedeckt von TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe;
	// test/mutations/242-archive-welle-go-vorschau-schaltet-nicht-ab.sh nimmt sie weg.
	if vorschau {
		return 0
	}
	if err := archive.Anwenden(root, bericht.Bestand, dateien, g, out); err != nil {
		fmt.Fprintf(errOut, "archive-welle: %v\n", err)
		return 1
	}
	return 0
}

// gitSchreibend verdrahtet die vier git-Operationen des schreibenden Laufs. Sie
// stehen hier und nicht in internal/archive, damit die Urteils-Logik dort ohne
// git pruefbar bleibt — dieselbe Aufteilung wie bei den zwei lesenden Aufrufen.
type gitSchreibend struct{ root string }

func (g gitSchreibend) Mv(alt, neu string) error { return g.lauf("mv", "--", alt, neu) }

func (g gitSchreibend) Rm(pfade []string) error {
	return g.lauf(append([]string{"rm", "-q", "--"}, pfade...)...)
}

func (g gitSchreibend) Add(pfade []string) error {
	return g.lauf(append([]string{"add", "--"}, pfade...)...)
}

func (g gitSchreibend) Commit(nachricht string) error {
	return g.lauf("commit", "-q", "-m", nachricht)
}

func (g gitSchreibend) lauf(args ...string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, "git", append([]string{"-C", g.root}, args...)...)
	if aus, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("git %s: %w: %s", strings.Join(args, " "), err, strings.TrimSpace(string(aus)))
	}
	return nil
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

// gitLsFiles liefert den Suchraum beider Zweige: jeden Pfad, den der Index
// fuehrt, ohne Dateityp-Einschraenkung. Der zaehlende und der schreibende Zweig
// bekommen dieselbe Liste — die Vorschau sieht damit denselben Verweis, den der
// Lauf umhaengt. Ausgenommen wird nichts an dieser Stelle: die
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
