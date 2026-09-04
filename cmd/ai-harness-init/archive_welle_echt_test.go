package main

import (
	"bytes"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
)

// Diese Datei faehrt den BETRIEBS-EINGANG. Die Faelle in archive_welle_test.go
// verdrahten laufEingang selbst (attrappenEingang) und erreichen echterEingang()
// darum nie; hier startet der Traeger als PROZESS in einem echten git-Repo, und
// die vier Felder der Verdrahtung tragen den Lauf: repoWurzel loest die Wurzel
// ueber dem Arbeitsverzeichnis auf, gitStatusPorcelain und gitLsFiles starten
// `git`, gitSchreibend fuehrt die vier schreibenden Operationen aus.
//
// DIE ZWEI SPERREN SIND DER MASSSTAB, beide fail-closed: der unsaubere
// Arbeitsbaum haengt an gitStatusPorcelain, der Haenger-Schutz an gitLsFiles. Ein
// Feld, das `git` weiter startet und seine Antwort verwirft, uebersetzt — und
// nimmt dem Unterkommando genau eine der zwei Sperren, ohne dass eine andere
// Stufe der Kette faellt. Die Faelle test/mutations/249 bis 252 nehmen je eines
// der Felder bzw. den ersten schreibenden Aufruf weg.
//
// KOPPLUNG an den Baum daneben: der Ausgangs-Baum ist derselbe sperrenfreie wie
// bei den Attrappen-Faellen (sperrenfreierBaum), damit eine Aenderung an der
// Einsammel-Regel beide Seiten zugleich trifft statt eine still veralten zu
// lassen.

// echterReport ist der Review-Report, den jeder Lauf dieser Datei einsammelt.
// Seine Nummer trifft slice-100-a.md aus dem sperrenfreien Baum.
const echterReport = "docs/reviews/2026-01-01-slice-100-review.md"

// schreibeDatei legt eine repo-relative Datei samt Verzeichnissen an.
func schreibeDatei(t *testing.T, root, rel, inhalt string) {
	t.Helper()
	p := filepath.Join(root, filepath.FromSlash(rel))
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(p, []byte(inhalt), 0o644); err != nil {
		t.Fatal(err)
	}
}

// gitLauf fuehrt ein git-Kommando im Pruef-Repo aus und bricht den Test ab, wenn
// es scheitert — ein misslungener Aufbau darf nicht als Befund durchgehen.
func gitLauf(t *testing.T, root string, args ...string) string {
	t.Helper()
	aus, err := exec.Command("git", append([]string{"-C", root}, args...)...).CombinedOutput()
	if err != nil {
		t.Fatalf("git %s: %v: %s", strings.Join(args, " "), err, aus)
	}
	return strings.TrimSpace(string(aus))
}

// echtesRepo baut aus dem sperrenfreien Baum ein echtes git-Repo: dieselbe
// Struktur, die die Attrappen-Faelle synthetisch fahren, dazu der Review-Report
// zum eingesammelten Slice und ein Ausgangs-Commit. `zusatz` legt weitere
// Dateien VOR dem Commit an — sie sind damit getrackt und stehen im Suchraum,
// den `git ls-files` liefert.
//
// Die Identitaet steht LOKAL im Pruef-Repo: der schreibende Lauf committet
// selbst, und ein Container ohne globale git-Konfiguration haette sonst keine.
func echtesRepo(t *testing.T, zusatz map[string]string) string {
	t.Helper()
	root := sperrenfreierBaum(t)
	schreibeDatei(t, root, echterReport, "# Review slice-100 — Runde 1\n")
	for rel, inhalt := range zusatz {
		schreibeDatei(t, root, rel, inhalt)
	}
	gitLauf(t, root, "init", "-q")
	gitLauf(t, root, "config", "user.email", "harness@example.invalid")
	gitLauf(t, root, "config", "user.name", "Harness Test")
	gitLauf(t, root, "add", "-A")
	gitLauf(t, root, "commit", "-q", "-m", "Ausgangsstand")
	return root
}

// traegerLauf startet dieses Test-Binary als Traeger — TestMain zweigt vor dem
// Framework ab, das Kind laeuft also durch main() und damit durch den realen
// Dispatch und echterEingang(). `dir` ist sein Arbeitsverzeichnis; von dort loest
// repoWurzel die Wurzel auf.
func traegerLauf(t *testing.T, dir string, args ...string) (stdout, stderr string, code int) {
	t.Helper()
	cmd := exec.Command(os.Args[0], args...)
	cmd.Env = append(os.Environ(), childEnv+"=1")
	cmd.Dir = dir
	var aus, fehler bytes.Buffer
	cmd.Stdout, cmd.Stderr = &aus, &fehler
	if err := cmd.Run(); err != nil {
		var ee *exec.ExitError
		if !errors.As(err, &ee) {
			t.Fatalf("Traeger nicht startbar: %v", err)
		}
		code = ee.ExitCode()
	}
	return aus.String(), fehler.String(), code
}

// commitZahl ist die Zahl der Commits auf HEAD — das Mass dafuer, ob ein Lauf
// geschrieben hat.
func commitZahl(t *testing.T, root string) int {
	t.Helper()
	roh := gitLauf(t, root, "rev-list", "--count", "HEAD")
	n, err := strconv.Atoi(roh)
	if err != nil {
		t.Fatalf("Commit-Zahl %q: %v", roh, err)
	}
	return n
}

// sperrtAb faehrt den Traeger schreibend (ohne `--vorschau`) und haelt fest, dass
// er an der genannten Sperre abbricht, ohne einen Commit zu setzen und ohne das
// Ziel-Verzeichnis anzulegen. Die erste Pruefung ist die tragende: steht die
// erwartete Sperre nicht im Bericht, sagt der Rest nichts ueber sie aus.
func sperrtAb(t *testing.T, root, dir, kennung string) {
	t.Helper()
	vorher := commitZahl(t, root)
	aus, fehler, code := traegerLauf(t, dir, "archive-welle", "welle-10")
	if !strings.Contains(aus, "["+kennung+"]") {
		t.Fatalf("die Sperre [%s] steht nicht im Bericht:\n%s\nstderr: %s", kennung, aus, fehler)
	}
	if code != 3 {
		t.Errorf("Exit %d, want 3 (Sperre steht; stderr: %q)", code, fehler)
	}
	if nachher := commitZahl(t, root); nachher != vorher {
		t.Errorf("Commits %d -> %d — der Lauf hat trotz Sperre geschrieben", vorher, nachher)
	}
	if _, err := os.Stat(filepath.Join(root, filepath.FromSlash("docs/plan/planning/done/welle-10"))); err == nil {
		t.Error("done/welle-10/ ist angelegt — der Lauf hat trotz Sperre geschrieben")
	}
}

// TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum misst die Sauberkeits-Sperre
// dort, wo sie im Betrieb entsteht: an der Ausgabe von `git status --porcelain`,
// die echterEingang() dem Zweig unterschiebt. Die Sperren-LOGIK ist daneben
// gedeckt (TestUnsauberGrundZaehltUntrackte); was hier faellt, ist die Strecke
// aus der Aussenwelt in sie hinein.
//
// Der Traeger laeuft aus einem UNTERVERZEICHNIS des Pruef-Repos. Das ist keine
// Beiläufigkeit: nur so traegt der Fall auch das Feld `wurzel` — ein
// Arbeitsverzeichnis, das selbst die Wurzel ist, macht jede Aufloesung richtig.
//
// Der Schmutz liegt auf der Slice-Datei, die dieser Lauf bewegte. Faellt die
// Sperre, wandert die nicht committete Zeile ins Archiv-Zip, waehrend der
// Move-Commit den sauberen Blob traegt.
// Gegenbeispiele: test/mutations/249-archive-welle-go-wurzel-ohne-aufstieg.sh,
// test/mutations/250-archive-welle-go-porcelain-verworfen.sh.
func TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum(t *testing.T) {
	root := echtesRepo(t, nil)
	schreibeDatei(t, root, "docs/plan/planning/done/slice-100-a.md",
		"# Slice slice-100: Der Gegenstand\n\n**Welle:** welle-10\n\nnoch nicht committet\n")

	sperrtAb(t, root, filepath.Join(root, "docs"), "unsauber")
}

// TestArchiveWelleEchtSperrtAmHaengendenVerweis misst den Haenger-Schutz dort, wo
// sein Suchraum entsteht: an der Liste von `git ls-files`, die echterEingang()
// dem Zweig unterschiebt. Die Suchraum-LOGIK ist daneben gedeckt
// (TestHaengerFindetVerweisAusReviewReport); was hier faellt, ist die Strecke aus
// der Aussenwelt in sie hinein.
//
// Der lebende Verweis steht in spec/lastenheft.md — Rang 1 der Source Precedence
// und ausserhalb von docs/. Faellt die Sperre, verschwindet der Report und der
// Verweis zeigt ins Leere.
// Gegenbeispiel: test/mutations/251-archive-welle-go-suchraum-leer.sh.
func TestArchiveWelleEchtSperrtAmHaengendenVerweis(t *testing.T) {
	root := echtesRepo(t, map[string]string{
		"spec/lastenheft.md": "# Lastenheft\n\nBeleg: [Runde 1](../" + echterReport + ")\n",
	})

	sperrtAb(t, root, root, "haenger")
}

// TestArchiveWelleEchtArchiviertUndSetztZweiCommits ist die Gegenprobe zu den
// zwei Faellen darueber und zugleich der einzige Fall, der die vier schreibenden
// git-Aufrufe wirklich ausfuehrt: derselbe Baum ohne die zwei Defekte, und dann
// laeuft die Operation durch.
//
// Ohne diesen Fall blieben die zwei Sperren-Faelle gruen, auch wenn das
// Unterkommando gar nichts mehr taete — "bricht ab" ist keine Aussage, solange
// niemand misst, dass es sonst laeuft.
//
// Vier unabhaengige Wege ins Rot, absteigend nach Reichweite: der Exit-Code, die
// zwei Commits, der leere Arbeitsbaum danach (er faellt, sobald ein Schritt seinen
// Pfad nicht stagt) und die Stub-Form an der neuen Adresse.
// Gegenbeispiel: test/mutations/252-archive-welle-go-mv-ohne-git.sh.
func TestArchiveWelleEchtArchiviertUndSetztZweiCommits(t *testing.T) {
	root := echtesRepo(t, nil)
	vorher := commitZahl(t, root)

	aus, fehler, code := traegerLauf(t, root, "archive-welle", "welle-10")
	if code != 0 {
		t.Fatalf("Exit %d, want 0:\n%s\nstderr: %s", code, aus, fehler)
	}
	if nachher := commitZahl(t, root); nachher != vorher+2 {
		t.Errorf("Commits %d -> %d, want %d (Move und Inhalt getrennt)", vorher, nachher, vorher+2)
	}
	if rest := gitLauf(t, root, "status", "--porcelain"); rest != "" {
		t.Errorf("Arbeitsbaum nach dem Lauf nicht sauber — ein Schritt hat seinen Pfad nicht gestagt:\n%s", rest)
	}
	if _, err := os.Stat(filepath.Join(root, filepath.FromSlash(echterReport))); err == nil {
		t.Error("der Review-Report liegt noch da — er sollte im Archiv stehen und geloescht sein")
	}
	stub, err := os.ReadFile(filepath.Join(root, filepath.FromSlash("docs/plan/planning/done/welle-10/slice-100-a.md")))
	if err != nil {
		t.Fatalf("Stub an der neuen Adresse: %v", err)
	}
	if !strings.Contains(string(stub), "> **ARCHIVIERT**") {
		t.Errorf("der Stub traegt keinen Archiv-Zeiger:\n%s", stub)
	}
}
