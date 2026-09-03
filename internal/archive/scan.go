package archive

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// AusgenommenePfade nennt die repo-relativen Praefixe AUSSERHALB des Suchraums,
// in dem dieses Paket nach Verweisen sucht. Die Menge ist geschlossen und steht
// an dieser einen Stelle; wer sie erweitert, verengt alle drei Leser zugleich —
// die Haenger-Vorpruefung, den Verweis-Fund und den Verweis-Nachzug.
//
// Sie ist die EINZIGE Achse, an der der Suchraum verengt ist. Eine Dateityp-Achse
// gibt es nicht: gesucht wird in jeder uebergebenen Datei, `.md` oder nicht. Ein
// Verweis auf ein verschwindendes Zeitdokument steht im Bestand auch in
// Shell-Hooks und -Helfern, in Go-Kommentaren, in Mutations-Faellen und in
// bats-Dateien.
// TestHaengerFindetVerweisAusNichtMarkdownDatei und
// TestVerweisFundPraefixAusNichtMarkdownDatei decken beide Leser;
// test/mutations/238-archive-welle-go-suchraum-dateityp.sh nimmt die Achse weg.
//
// `.git` ist kein Prueftext, `.harness/baseline` unveraenderter Fremdtext, den
// das Doku-Gate unter scan.ignore nie liest.
//
// `docs/reviews/**` steht bewusst NICHT darin, und das ist ADR-0033
// Abnahme-Kriterium 1: die Zeitdokumente sind im Doku-Gate nur von codepaths und
// ids befreit, `links`/`anchors` pruefen jeden Markdown-Link dort wie ueberall
// sonst — und Reports verlinken einander quer ueber Wellen-Grenzen. Ein
// bleibender Report, der auf einen verschwindenden zeigt, faerbt `make
// docs-check` rot; die Haenger-Vorpruefung faengt genau das fail-closed ab.
// TestHaengerFindetVerweisAusReviewReport deckt es;
// test/mutations/233-archive-welle-go-haenger-suchraum.sh nimmt es weg.
func AusgenommenePfade() []string {
	return []string{".git", ".harness/baseline"}
}

// Ausgenommen sagt, ob ein repo-relativer Pfad ausserhalb des Suchraums liegt.
func Ausgenommen(rel string) bool {
	rel = filepath.ToSlash(rel)
	for _, p := range AusgenommenePfade() {
		if rel == p || strings.HasPrefix(rel, p+"/") {
			return true
		}
	}
	return false
}

// Suchraum ist die Menge der Dateien, in denen dieses Paket nach Verweisen sucht:
// die uebergebenen repo-relativen Pfade ohne die ausgenommenen Praefixe,
// sortiert und ohne Doppel. Jeder Leser dieses Pakets fuehrt jede Liste durch
// diese Funktion, damit die Ausnahme-Menge oben fuer jeden Eingang gilt.
//
// KOPPLUNG: die Liste liefert der Aufrufer aus dem GIT-INDEX (`git ls-files`) —
// eine Menge, die der zaehlende und der schreibende Zweig gemeinsam bekommen.
// Damit steht sie ohne git-Aufruf in diesem Paket, und was der Index nicht
// fuehrt — Ignoriertes unter `.harness/state/`, `bin/`, `dist/` und jede
// untrackte Datei —, liegt fuer beide ausserhalb.
func Suchraum(dateien []string) []string {
	out := make([]string, 0, len(dateien))
	gesehen := make(map[string]bool, len(dateien))
	for _, d := range dateien {
		rel := filepath.ToSlash(strings.TrimSpace(d))
		if rel == "" || gesehen[rel] || Ausgenommen(rel) {
			continue
		}
		gesehen[rel] = true
		out = append(out, rel)
	}
	sort.Strings(out)
	return out
}

// lies liefert den Inhalt einer Datei des Suchraums. Der zweite Rueckgabewert ist
// false fuer die zwei Eintraege, hinter denen kein durchsuchbarer Inhalt steht:
// ein Pfad, den der Index fuehrt und der Arbeitsbaum nicht (geloescht, noch nicht
// committet), und ein Symlink — dessen git-Blob ist sein Zielpfad, nicht der Text
// dahinter; ihm zu folgen zoege den ausgenommenen Baseline-Baum ueber
// `.claude/rules/` wieder in den Suchraum.
func lies(root, rel string) (string, bool, error) {
	p := filepath.Join(root, filepath.FromSlash(rel))
	st, err := os.Lstat(p)
	if errors.Is(err, fs.ErrNotExist) {
		return "", false, nil
	}
	if err != nil {
		return "", false, fmt.Errorf("%s lesen: %w", rel, err)
	}
	if !st.Mode().IsRegular() {
		return "", false, nil
	}
	b, err := os.ReadFile(p)
	if err != nil {
		return "", false, fmt.Errorf("%s lesen: %w", rel, err)
	}
	return string(b), true, nil
}

// Haenger nennt jeden lebenden Verweis auf eine Datei, die der Lauf ERSATZLOS
// loeschte — je Fund eine Zeile "<verweisende Datei> -> <Ziel>". `dateien` ist
// der rohe Suchraum-Eingang des Aufrufers.
//
// ZUSAGE: gefunden wird nur, was den Lauf UEBERLEBT. Wer selbst verschwindet —
// die eingesammelten Slices, der Welle-Plan und die anderen zu loeschenden
// Reports — traegt danach keinen lebenden Verweis mehr.
//
// GRENZE: gesucht wird der BASENAME als Teilzeichenkette, nicht ein aufgeloester
// Link. Das ist die Form, in der ein Markdown-Verweis auf ein Zeitdokument im
// Bestand steht; ein gleichlautender Name im Fliesstext zaehlt mit, und diese
// Richtung ist die fail-closed-sichere.
func Haenger(root string, dateien, ziele, verschwindend []string) ([]string, error) {
	weg := make(map[string]bool, len(verschwindend))
	for _, v := range verschwindend {
		weg[filepath.ToSlash(v)] = true
	}
	var out []string
	for _, datei := range Suchraum(dateien) {
		if weg[datei] {
			continue
		}
		inhalt, ok, err := lies(root, datei)
		if err != nil {
			return nil, err
		}
		if !ok {
			continue
		}
		out = append(out, treffer(inhalt, datei, ziele)...)
	}
	sort.Strings(out)
	return out, nil
}

// treffer nennt die Ziele, deren Basename im Inhalt der Datei vorkommt.
func treffer(inhalt, datei string, ziele []string) []string {
	var out []string
	for _, ziel := range ziele {
		if strings.Contains(inhalt, filepath.Base(ziel)) {
			out = append(out, datei+" -> "+ziel)
		}
	}
	return out
}
