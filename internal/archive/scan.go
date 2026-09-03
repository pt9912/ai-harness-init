package archive

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// AusgenommenePfade nennt die repo-relativen Praefixe AUSSERHALB des Suchraums,
// in dem dieses Paket nach Verweisen sucht. Die Menge ist geschlossen und steht
// an dieser einen Stelle; wer sie erweitert, verengt beide Leser zugleich — die
// Haenger-Vorpruefung und den Verweis-Fund.
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

// MarkdownDateien liefert jede `.md`-Datei unter root als repo-relativen Pfad,
// sortiert und ohne die ausgenommenen Praefixe.
//
// GRENZE, benannt statt verschwiegen: der Lauf geht ueber den ARBEITSBAUM, nicht
// ueber den git-Index. Eine untrackte Markdown-Datei zaehlt damit mit — der
// schreibende Zweig verlangt ohnehin einen sauberen Baum, und in einem sauberen
// Baum fallen beide Mengen zusammen.
func MarkdownDateien(root string) ([]string, error) {
	var out []string
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, relErr := filepath.Rel(root, p)
		if relErr != nil {
			return relErr
		}
		rel = filepath.ToSlash(rel)
		if d.IsDir() {
			if rel != "." && Ausgenommen(rel) {
				return filepath.SkipDir
			}
			return nil
		}
		if strings.HasSuffix(rel, ".md") && !Ausgenommen(rel) {
			out = append(out, rel)
		}
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("%s durchsuchen: %w", root, err)
	}
	sort.Strings(out)
	return out, nil
}

// Haenger nennt jeden lebenden Verweis auf eine Datei, die der Lauf ERSATZLOS
// loeschte — je Fund eine Zeile "<verweisende Datei> -> <Ziel>".
//
// ZUSAGE: gefunden wird nur, was den Lauf UEBERLEBT. Wer selbst verschwindet —
// die eingesammelten Slices, der Welle-Plan und die anderen zu loeschenden
// Reports — traegt danach keinen lebenden Verweis mehr.
//
// GRENZE: gesucht wird der BASENAME als Teilzeichenkette, nicht ein aufgeloester
// Link. Das ist die Form, in der ein Markdown-Verweis auf ein Zeitdokument im
// Bestand steht; ein gleichlautender Name im Fliesstext zaehlt mit, und diese
// Richtung ist die fail-closed-sichere.
func Haenger(root string, ziele, verschwindend []string) ([]string, error) {
	dateien, err := MarkdownDateien(root)
	if err != nil {
		return nil, err
	}
	weg := make(map[string]bool, len(verschwindend))
	for _, v := range verschwindend {
		weg[filepath.ToSlash(v)] = true
	}
	var out []string
	for _, datei := range dateien {
		if weg[datei] {
			continue
		}
		inhalt, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(datei)))
		if err != nil {
			return nil, fmt.Errorf("%s lesen: %w", datei, err)
		}
		out = append(out, treffer(string(inhalt), datei, ziele)...)
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
