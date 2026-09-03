package archive

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// Fund nennt je Datei, wie viele Verweise auf bewegte Dateien sie traegt —
// aufgeschluesselt nach den drei Formen, in denen ein solcher Verweis im Bestand
// steht.
type Fund struct {
	Datei       string // repo-relativ
	Praefix     int    // "done/<datei>", jede Aufstiegstiefe
	Geschwister int    // "](<datei>)" in den flach in done/ liegenden Dateien
	Aufsteigend int    // "](../<datei>)" in den Dateien unter done/<welle-x>/
}

// Summe ist die Zahl der Verweise dieser Datei ueber alle drei Formen.
func (f Fund) Summe() int { return f.Praefix + f.Geschwister + f.Aufsteigend }

// ZaehlePraefix zaehlt die eingehende Form MIT Verzeichnis-Praefix:
// "done/<base>" an einer Wortgrenze — Zeilenanfang oder ein Zeichen davor, das
// kein Wortzeichen ist; der Bindestrich zaehlt als Wortzeichen mit, weil
// Verzeichnisnamen wie "in-progress" einen tragen. Eine Regel statt einer
// Praefix-Liste: sie deckt jede Aufstiegstiefe und jeden Kontext.
func ZaehlePraefix(inhalt, base string) int {
	if base == "" {
		return 0
	}
	re := regexp.MustCompile(`(^|[^A-Za-z0-9_-])` + doneName + `/` + regexp.QuoteMeta(base))
	return len(re.FindAllStringIndex(inhalt, -1))
}

// ZaehleGeschwister zaehlt die geschwister-relative Form "](<base>)": ein
// Link-Ziel OHNE Verzeichnis-Segment zeigt auf einen Geschwister im Verzeichnis
// der linktragenden Datei. Es trifft eine bewegte Datei nur dort, wo die
// linktragende Datei selbst flach in done/ liegt — diese Zuordnung macht
// VerweisFund, nicht diese Funktion.
func ZaehleGeschwister(inhalt, base string) int {
	if base == "" {
		return 0
	}
	return strings.Count(inhalt, "]("+base+")")
}

// ZaehleAufsteigend zaehlt die aufsteigende Form "](../<base>)": ein Link-Ziel
// aus einer Datei unter done/<welle-x>/ zeigt eine Ebene hoeher auf die flache
// done/-Ebene, aus der die bewegte Datei gerade verschwindet. Diese Form
// schreibt das Werkzeug selbst in die Stubs, wenn ein Folge-Slice noch flach in
// done/ liegt.
func ZaehleAufsteigend(inhalt, base string) int {
	if base == "" {
		return 0
	}
	return strings.Count(inhalt, "](../"+base+")")
}

// VerweisFund nennt jede Datei des Suchraums, die einen Verweis auf eine der
// bewegten Dateien traegt, mit der Zahl je Form — sortiert nach Dateiname.
// `bewegte` sind Basenamen (Bestand.Bewegte).
//
// DIE DREI FORMEN HABEN VERSCHIEDENE SUCHRAEUME, und das ist keine Sparsamkeit,
// sondern die Aufloesungs-Regel von Markdown: die Praefix-Form ankert am Literal
// "done/" und gilt ueberall; die praefixlose Form loest gegen das Verzeichnis
// der LINKTRAGENDEN Datei auf und trifft nur aus done/ selbst; die aufsteigende
// nur aus einem Unterverzeichnis von done/. Wer alle drei ueberall zaehlte,
// meldete Treffer, die kein Umzug beruehrt.
//
// GRENZE: gefunden wird, was an einer dieser drei Formen ankert. Ein eingehender
// Verweis in Inline-Code ohne Verzeichnis-Segment (`slice-N….md` als Pfad-Span
// statt als Link-Ziel) traegt keine Link-Klammer und steht in keinem Fund.
func VerweisFund(root string, bewegte []string) ([]Fund, error) {
	dateien, err := MarkdownDateien(root)
	if err != nil {
		return nil, err
	}
	var out []Fund
	for _, datei := range dateien {
		inhalt, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(datei)))
		if err != nil {
			return nil, fmt.Errorf("%s lesen: %w", datei, err)
		}
		if f := fundIn(string(inhalt), datei, bewegte); f.Summe() > 0 {
			out = append(out, f)
		}
	}
	return out, nil
}

// fundIn zaehlt die drei Formen fuer eine Datei, jede nur in ihrem Suchraum.
func fundIn(inhalt, datei string, bewegte []string) Fund {
	f := Fund{Datei: datei}
	dir := filepath.ToSlash(filepath.Dir(datei))
	flachInDone := dir == doneDir
	unterDone := strings.HasPrefix(dir, doneDir+"/")
	for _, base := range bewegte {
		f.Praefix += ZaehlePraefix(inhalt, base)
		if flachInDone {
			f.Geschwister += ZaehleGeschwister(inhalt, base)
		}
		if unterDone {
			f.Aufsteigend += ZaehleAufsteigend(inhalt, base)
		}
	}
	return f
}
