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
	Praefix     int    // "done/<datei>", jede Aufstiegstiefe; unter docs/reviews/ nur als Link-Ziel
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

// imReportBaum sagt, ob eine repo-relative Datei unter docs/reviews/ liegt — dem
// Baum, in dem der Nachzug nur die Link-Form schreibt (ADR-0070 Festlegung 1).
// Die Zaehl-Seite (fundIn) und die Ersetz-Seite (ersetzeIn) fragen diese eine
// Stelle.
func imReportBaum(datei string) bool {
	return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")
}

// praefixLinkRE ist die Regel fuer den Baum docs/reviews/: "done/<base>" gilt
// nur dort, wo die Adresse UNMITTELBAR hinter "](" steht und bis ")" oder "#"
// reicht. Gruppe 1 reicht von "](" bis vor "done/", Gruppe 2 ist das Zeichen
// hinter der Adresse. Vor "done/" steht dieselbe Wortgrenze wie bei
// ZaehlePraefix (der Bindestrich zaehlt als Wortzeichen); zwischen "](" und
// "done/" liegt hoechstens Text derselben Zeile ohne ")" und "#" — die Regel
// ueberquert weder eine Link-Grenze noch eine Zeilengrenze.
func praefixLinkRE(base string) *regexp.Regexp {
	return regexp.MustCompile(`(\]\((?:[^)#\n]*[^A-Za-z0-9_)#\n-])?)` + doneName + `/` + regexp.QuoteMeta(base) + `([)#])`)
}

// ZaehlePraefixLink zaehlt die Praefix-Form in der Fassung fuer docs/reviews/
// (ADR-0070 Festlegung 1): nur als Ziel eines Inline-Markdown-Links. Ein Pfad im
// Code-Span, als Operand, im Code-Block oder im Fliesstext steht nicht hinter
// "](" und zaehlt nicht. Die Regel liest kein Markdown: Link-Syntax, die als
// Zitat in einem Code-Span oder Code-Block steht, zaehlt mit. Ein Link mit Titel
// ("](ziel "titel")") und die Spitzklammer-Form ("](<ziel>)") enden nicht
// unmittelbar an ")" oder "#" und zaehlen nicht.
func ZaehlePraefixLink(inhalt, base string) int {
	if base == "" {
		return 0
	}
	return len(praefixLinkRE(base).FindAllStringIndex(inhalt, -1))
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
// Basenamen (Bestand.Bewegte). Der Suchraum ist SuchraumNachzug, nicht
// Suchraum: eine Accepted-ADR unter `docs/plan/adr` traegt hier keinen Fund
// (ADR-0042 Festlegung 2) — `docs/reviews/**` bleibt darin, s. Haenger.
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
// gemeinsamen Umzug gueltig, und der Nachzug fasst sie nicht an.
// TestVerweisFundUebergehtDenEigenenUmzugsgegenstand haelt das.
//
// GRENZE: gefunden wird, was an einer dieser drei Formen ankert. Ein eingehender
// Verweis in Inline-Code ohne Verzeichnis-Segment (`slice-N….md` als Pfad-Span
// statt als Link-Ziel) traegt keine Link-Klammer und steht in keinem Fund. Die
// Praefix-Form zaehlt unter docs/reviews/ nur als Link-Ziel (ZaehlePraefixLink,
// ADR-0070 Festlegung 1), in jedem anderen Baum in jeder Form.
func VerweisFund(root string, dateien, bewegte []string) ([]Fund, error) {
	zieht := make(map[string]bool, len(bewegte))
	for _, b := range bewegte {
		zieht[b] = true
	}
	var out []Fund
	for _, datei := range SuchraumNachzug(dateien) {
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

// rollen sagt, welche der zwei relativen Formen in dieser Datei ueberhaupt auf
// die flache done/-Ebene aufloesen. Es ist die EINE Stelle, an der beide Leser
// dieser Datei ihren Suchraum bestimmen — der zaehlende (VerweisFund) und der
// schreibende (Nachziehen). Zwei Fassungen dieser Regel drifteten, und die
// Vorschau saegte dann etwas anderes, als der Lauf taete.
// `zieht` sind die Basenamen, die dieser Lauf selbst bewegt.
func rollen(datei string, zieht map[string]bool) (flachInDone, unterDone bool) {
	dir := filepath.ToSlash(filepath.Dir(datei))
	markdown := strings.HasSuffix(datei, ".md")
	flachInDone = markdown && dir == doneDir && !zieht[filepath.Base(datei)]
	unterDone = markdown && strings.HasPrefix(dir, doneDir+"/")
	return flachInDone, unterDone
}

// fundIn zaehlt die drei Formen fuer eine Datei, jede nur in ihrem Suchraum; die
// Praefix-Form unter docs/reviews/ in der Fassung ZaehlePraefixLink.
func fundIn(inhalt, datei string, bewegte []string, zieht map[string]bool) Fund {
	f := Fund{Datei: datei}
	flachInDone, unterDone := rollen(datei, zieht)
	zaehlePraefix := ZaehlePraefix
	if imReportBaum(datei) {
		zaehlePraefix = ZaehlePraefixLink
	}
	for _, base := range bewegte {
		f.Praefix += zaehlePraefix(inhalt, base)
		if flachInDone {
			f.Geschwister += ZaehleGeschwister(inhalt, base)
		}
		if unterDone {
			f.Aufsteigend += ZaehleAufsteigend(inhalt, base)
		}
	}
	return f
}

// ErsetzePraefix haengt die eingehende Form MIT Verzeichnis-Praefix um:
// "done/<base>" wird zu "done/<welle-id>/<base>", an derselben Wortgrenze, an
// der ZaehlePraefix zaehlt. Liefert den neuen Inhalt und die Zahl der
// Ersetzungen.
func ErsetzePraefix(inhalt, base, welleID string) (string, int) {
	if base == "" {
		return inhalt, 0
	}
	re := regexp.MustCompile(`(^|[^A-Za-z0-9_-])` + doneName + `/` + regexp.QuoteMeta(base))
	n := 0
	out := re.ReplaceAllStringFunc(inhalt, func(m string) string {
		n++
		return m[:len(m)-len(doneName)-1-len(base)] + doneName + "/" + welleID + "/" + base
	})
	return out, n
}

// ErsetzePraefixLink haengt die Praefix-Form in der Fassung fuer docs/reviews/
// um: "done/<base>" wird zu "done/<welle-id>/<base>", nur dort, wo
// ZaehlePraefixLink zaehlt — unmittelbar hinter "](" und bis ")" oder "#". Alles
// andere in der Datei bleibt Byte fuer Byte. Liefert den neuen Inhalt und die
// Zahl der Ersetzungen.
func ErsetzePraefixLink(inhalt, base, welleID string) (string, int) {
	if base == "" {
		return inhalt, 0
	}
	var b strings.Builder
	rest, n := 0, 0
	for _, m := range praefixLinkRE(base).FindAllStringSubmatchIndex(inhalt, -1) {
		b.WriteString(inhalt[rest:m[3]])
		b.WriteString(doneName + "/" + welleID + "/" + base)
		rest = m[4]
		n++
	}
	if n == 0 {
		return inhalt, 0
	}
	b.WriteString(inhalt[rest:])
	return b.String(), n
}

// ErsetzeGeschwister haengt die geschwister-relative Form um: "](<base>)" wird zu
// "](<welle-id>/<base>)". Sie trifft nur in einer Datei, die flach in done/
// liegen BLEIBT — die Zuordnung macht ersetzeIn, nicht diese Funktion.
func ErsetzeGeschwister(inhalt, base, welleID string) (string, int) {
	if base == "" {
		return inhalt, 0
	}
	alt := "](" + base + ")"
	n := strings.Count(inhalt, alt)
	if n == 0 {
		return inhalt, 0
	}
	return strings.ReplaceAll(inhalt, alt, "]("+welleID+"/"+base+")"), n
}

// ErsetzeAufsteigend haengt die aufsteigende Form um: "](../<base>)" wird zu
// "](../<welle-id>/<base>)".
//
// ZUSAGE, und sie ist ADR-0033 Abnahme-Kriterium 3: diese Form schreibt das
// Werkzeug SELBST in die Stubs (SlicePfadRelativ liefert sie fuer einen
// Folge-Slice, der noch flach in done/ liegt). Zieht dieses Ziel bei einem
// SPAETEREN Lauf eine Ebene tiefer, erreicht es keine der beiden anderen Regeln:
// die Praefix-Regel ankert am Literal "done/", das hier fehlt, und die
// geschwister-relative laeuft ueber die flachen done/*.md.
// Gedeckt von TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach;
// test/mutations/240-archive-welle-go-aufsteigender-verweis.sh nimmt sie weg.
func ErsetzeAufsteigend(inhalt, base, welleID string) (string, int) {
	if base == "" {
		return inhalt, 0
	}
	alt := "](../" + base + ")"
	n := strings.Count(inhalt, alt)
	if n == 0 {
		return inhalt, 0
	}
	return strings.ReplaceAll(inhalt, alt, "](../"+welleID+"/"+base+")"), n
}

// ersetzeIn wendet die drei Formen auf eine Datei an, jede nur in ihrem
// Suchraum — derselbe, den fundIn zaehlt (beide fragen `rollen`); die
// Praefix-Form unter docs/reviews/ in der Fassung ErsetzePraefixLink.
func ersetzeIn(inhalt, datei, welleID string, bewegte []string, zieht map[string]bool) (string, Fund) {
	f := Fund{Datei: datei}
	flachInDone, unterDone := rollen(datei, zieht)
	ersetzePraefix := ErsetzePraefix
	if imReportBaum(datei) {
		ersetzePraefix = ErsetzePraefixLink
	}
	for _, base := range bewegte {
		var n int
		inhalt, n = ersetzePraefix(inhalt, base, welleID)
		f.Praefix += n
		if flachInDone {
			inhalt, n = ErsetzeGeschwister(inhalt, base, welleID)
			f.Geschwister += n
		}
		if unterDone {
			inhalt, n = ErsetzeAufsteigend(inhalt, base, welleID)
			f.Aufsteigend += n
		}
	}
	return inhalt, f
}

// Nachziehen SCHREIBT den Verweis-Nachzug: jede Datei des Suchraums, die einen
// Verweis auf eine bewegte Datei traegt, bekommt ihn auf die neue Adresse
// umgehaengt. Liefert die geaenderten Dateien mit ihrer Zahl je Form — dieselbe
// Struktur, die die Vorschau ausgibt, damit beide Seiten dasselbe zaehlen. Der
// Suchraum ist SuchraumNachzug: eine Accepted-ADR unter `docs/plan/adr` bleibt
// unangetastet (ADR-0042 Festlegung 2).
//
// GRENZEN, wie beim zaehlenden Zwilling: es haengt PFADE um, keine
// Zustandssaetze; und ein eingehender Verweis in Inline-Code ohne
// Verzeichnis-Segment traegt keine Link-Klammer und wird nicht getroffen.
// `make docs-check` nach dem Lauf zeigt den Rest.
//
// FORM-REGEL UNTER docs/reviews/ (ADR-0070 Festlegung 1, ADR-0042 Festlegung 1 in
// der Fassung von ADR-0070): dort schreibt der Nachzug die Praefix-Adresse nur als
// Ziel eines Inline-Markdown-Links; ein Pfad im Code-Span, als Operand, im
// Code-Block oder im Fliesstext bleibt Byte fuer Byte, und eine Datei ohne
// Link-Treffer wird nicht geschrieben. Die Erkennung ist syntaktisch (der Anker
// "](", ErsetzePraefixLink), keine Span- oder Fence-Erkennung: Link-Syntax, die
// als Zitat in einem Code-Span oder Code-Block steht, wird mitersetzt. In den
// uebrigen Baeumen gilt jede Form.
//
// SCHREIBEN: os.WriteFile kuerzt die Datei an Ort und Stelle und schreibt dann;
// ein Fehler dabei wird gemeldet und bricht den Lauf ab, die Datei kann
// halbgeschrieben zurueckbleiben (der Aufrufer nennt den git-Rueckweg).
func Nachziehen(root string, dateien, bewegte []string, welleID string) ([]Fund, error) {
	zieht := make(map[string]bool, len(bewegte))
	for _, b := range bewegte {
		zieht[b] = true
	}
	var out []Fund
	for _, datei := range SuchraumNachzug(dateien) {
		inhalt, ok, err := lies(root, datei)
		if err != nil {
			return nil, err
		}
		if !ok {
			continue
		}
		neu, f := ersetzeIn(inhalt, datei, welleID, bewegte, zieht)
		if f.Summe() == 0 {
			continue
		}
		p := filepath.Join(root, filepath.FromSlash(datei))
		if err := os.WriteFile(p, []byte(neu), dateiRechte(p)); err != nil {
			return nil, fmt.Errorf("%s schreiben: %w", datei, err)
		}
		out = append(out, f)
	}
	return out, nil
}

// dateiRechte erhaelt den Modus einer bestehenden Datei — der Nachzug fasst auch
// ausfuehrbare Skripte an, und ein pauschales 0644 naehme ihnen das x-Bit.
func dateiRechte(p string) os.FileMode {
	if st, err := os.Stat(p); err == nil {
		return st.Mode().Perm()
	}
	return 0o644
}
