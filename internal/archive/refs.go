package archive

import (
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
// `dateien` ist der rohe Suchraum-Eingang des Aufrufers, `bewegte` sind
// Basenamen (Bestand.Bewegte).
//
// DIE DREI FORMEN HABEN VERSCHIEDENE SUCHRAEUME, und das ist keine Sparsamkeit,
// sondern die Aufloesungs-Regel von Markdown: die Praefix-Form ankert am Literal
// "done/", gilt ueberall und in jedem Dateityp — TestVerweisFundPraefixAusNichtMarkdownDatei
// haelt sie an einer Datei ohne `.md`. Die praefixlose Form loest gegen das
// Verzeichnis der LINKTRAGENDEN Datei auf und trifft nur aus done/ selbst; die
// aufsteigende nur aus einem Unterverzeichnis von done/. Beide sind zusaetzlich
// auf `.md` begrenzt: sie sind Markdown-Link-Ziele und loesen ausserhalb einer
// Markdown-Datei gegen nichts auf. Wer alle drei ueberall zaehlte, meldete
// Treffer, die kein Umzug beruehrt.
//
// ABGRENZUNG: die praefixlose Form zaehlt nicht in einer Datei, die dieser Lauf
// SELBST nach done/<welle-id>/ zoege. Ihre Geschwister-Links bleiben nach dem
// gemeinsamen Umzug gueltig, und der schreibende Traeger fasst sie nicht an.
// TestVerweisFundUebergehtDenEigenenUmzugsgegenstand haelt das.
//
// GRENZE: gefunden wird, was an einer dieser drei Formen ankert. Ein eingehender
// Verweis in Inline-Code ohne Verzeichnis-Segment (`slice-N….md` als Pfad-Span
// statt als Link-Ziel) traegt keine Link-Klammer und steht in keinem Fund.
func VerweisFund(root string, dateien, bewegte []string) ([]Fund, error) {
	zieht := make(map[string]bool, len(bewegte))
	for _, b := range bewegte {
		zieht[b] = true
	}
	var out []Fund
	for _, datei := range Suchraum(dateien) {
		inhalt, ok, err := lies(root, datei)
		if err != nil {
			return nil, err
		}
		if !ok {
			continue
		}
		if f := fundIn(inhalt, datei, bewegte, zieht); f.Summe() > 0 {
			out = append(out, f)
		}
	}
	return out, nil
}

// fundIn zaehlt die drei Formen fuer eine Datei, jede nur in ihrem Suchraum.
// `zieht` sind die Basenamen, die dieser Lauf selbst bewegt.
func fundIn(inhalt, datei string, bewegte []string, zieht map[string]bool) Fund {
	f := Fund{Datei: datei}
	dir := filepath.ToSlash(filepath.Dir(datei))
	markdown := strings.HasSuffix(datei, ".md")
	flachInDone := markdown && dir == doneDir && !zieht[filepath.Base(datei)]
	unterDone := markdown && strings.HasPrefix(dir, doneDir+"/")
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
