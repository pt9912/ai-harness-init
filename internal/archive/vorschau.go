package archive

import (
	"fmt"
	"io"
	"strings"
)

// AltbestandSchluessel ist der Schluessel aus ADR-0041 Festlegung 2: ein
// einzelnes Sammel-Archiv fuer den wellenlosen Bestand ohne Adressaten, keine
// Welle-Kennung. Er ist ortsfest und traegt genau einen Lauf; `sperren` hebt
// fuer ihn die vier welle- bzw. untergrenzen-gebundenen Ausgaenge auf.
const AltbestandSchluessel = "altbestand"

// Sperre ist ein fail-closed-Ausgang, an dem der SCHREIBENDE Lauf abbraeche.
// Die Vorschau nimmt ihn nicht — sie nennt ihn.
type Sperre struct {
	Kennung string   // stabile Kennung des Ausgangs
	Grund   string   // eine Zeile, die den Ausgang benennt
	Zeilen  []string // Details, je eine Zeile
}

// Bericht ist, was ein Vorschau-Lauf ueber eine Welle sagt: was er einsammelte,
// welche Dateien einen Verweis auf etwas Bewegtes tragen und welche Sperren dem
// schreibenden Lauf im Weg stuenden.
type Bericht struct {
	Bestand Bestand
	Funde   []Fund
	Sperren []Sperre
}

// Vorschau liest den Baum unter root und sagt, was eine Archivierung von welleID
// taete. Sie SCHREIBT nichts.
//
// Zwei Eingaben kommen als WERT herein statt aus einem git-Aufruf dieses Pakets:
// `porcelain` ist die Ausgabe von `git status --porcelain`, `dateien` der
// Suchraum aus `git ls-files`. Damit ist die Vorschau ohne git pruefbar, und der
// Aufrufer behaelt die eine Datei, in der git laeuft.
func Vorschau(root, welleID, porcelain string, dateien []string) (Bericht, error) {
	b, err := Einsammeln(root, welleID)
	if err != nil {
		return Bericht{}, err
	}
	ber := Bericht{Bestand: b}
	if ber.Funde, err = VerweisFund(root, dateien, b.Bewegte()); err != nil {
		return Bericht{}, err
	}
	haenger, err := Haenger(root, dateien, b.Reviews, b.Verschwindend())
	if err != nil {
		return Bericht{}, err
	}
	ber.Sperren = sperren(b, porcelain, haenger)
	return ber, nil
}

// sperren zaehlt die fail-closed-Ausgaenge auf, die der schreibende Lauf naehme.
//
// ABGRENZUNG: das sind die am RUHENDEN Baum beobachtbaren. Der Ausgang ueber eine
// verletzte Stub-Form entsteht erst zwischen den zwei Commits und steht in keiner
// Vorschau; das fehlende Wellen-Argument faengt der Aufrufer vor dem Lauf ab. Fuer
// AltbestandSchluessel gilt ein dritter Fall: Anwenden verlangt weiterhin genau
// einen Welle-Plan (len(b.Plaene) != 1) und traegt den Fall von keinem Plan nicht.
// "Sperren: keine" sagt fuer diesen Schluessel darum nicht, dass der schreibende
// Lauf durchlaeuft — ADR-0041 Folgepflicht 1 hebt fuer ihn nur die vier Ausgaenge
// dieser Funktion auf, nicht die Plan-Pruefung in Anwenden.
//
// BETRIEBSART: traegt der Schluessel AltbestandSchluessel (ADR-0041
// Festlegung 2), hebt diese Funktion vier welle- bzw. untergrenzen-gebundene
// Ausgaenge auf — ergebnisnotiz, kein-plan, mehrdeutiger-plan (alle drei aus
// planSperre) und untergrenze — weil ein Schluessel ohne Welle weder einen
// Welle-Plan noch eine Ergebnisnotiz in done/ hat und selbst die Untergrenze
// setzt, die die laufende Regel danach braucht. unsauber, archiviert,
// kein-slice und haenger bleiben unveraendert: haenger traegt ADR-0041
// Festlegung 4 und darf nicht mit aufgehen.
func sperren(b Bestand, porcelain string, haenger []string) []Sperre {
	var out []Sperre
	if grund := UnsauberGrund(porcelain); grund != "" {
		out = append(out, Sperre{
			Kennung: "unsauber",
			Grund:   "Arbeitsbaum nicht sauber (" + grund + ")",
			Zeilen:  []string{"erst committen, stashen oder aufraeumen — der schreibende Lauf committet selbst"},
		})
	}
	if b.Archiviert {
		out = append(out, Sperre{
			Kennung: "archiviert",
			Grund:   doneDir + "/" + b.Welle + " gibt es schon — diese Welle ist archiviert",
		})
	}
	welleGebunden := b.Welle != AltbestandSchluessel
	if welleGebunden {
		if b.Ergebnis == "" {
			out = append(out, Sperre{
				Kennung: "ergebnisnotiz",
				Grund:   doneDir + "/" + b.Welle + "-results.md fehlt",
				Zeilen:  []string{"Schritt 4 folgt auf Schritt 3 — die Ergebnisnotiz ist seine Vorbedingung"},
			})
		}
		out = append(out, planSperre(b)...)
	}
	if len(b.Slices()) == 0 {
		out = append(out, Sperre{
			Kennung: "kein-slice",
			Grund:   "kein Slice fuer " + b.Welle + " eingesammelt — nichts zu archivieren",
		})
	}
	if welleGebunden {
		out = append(out, untergrenzeSperre(b)...)
	}
	if len(haenger) > 0 {
		out = append(out, Sperre{
			Kennung: "haenger",
			Grund:   "ein Review-Report soll verschwinden, auf den noch verwiesen wird",
			Zeilen: append(append([]string{}, haenger...),
				"erst den Verweis aufloesen (oder die Referenz im Doku-Gate ausnehmen, mit ADR nach AGENTS.md 3.5)"),
		})
	}
	return out
}

// planSperre urteilt ueber den Welle-Plan: genau einer ist der Regelfall, keiner
// und mehrere sind je ein eigener Ausgang mit eigener Abhilfe.
func planSperre(b Bestand) []Sperre {
	switch len(b.Plaene) {
	case 1:
		return nil
	case 0:
		return []Sperre{{
			Kennung: "kein-plan",
			Grund:   "kein Welle-Plan '" + b.Welle + "*' in " + doneDir + "/",
			Zeilen:  []string{"er wandert bei Schritt 3 der Wellen-Closure dorthin"},
		}}
	default:
		return []Sperre{{
			Kennung: "mehrdeutiger-plan",
			Grund:   fmt.Sprintf("mehrdeutiger Welle-Plan — %d Kandidaten", len(b.Plaene)),
			Zeilen:  b.Plaene,
		}}
	}
}

// untergrenzeSperre traegt den Untergrenzen-Waechter: "wellenlos seit der
// letzten Closure" hat nur dort eine beobachtbare Untergrenze, wo schon einmal
// archiviert wurde. Solange kein done/<welle-x>/archiv.zip existiert, umfasste
// die Klasse jeden wellenlosen Slice, den das Repo je geschlossen hat — der Lauf
// raet dann nicht, sondern faellt fail-closed aus.
// Gedeckt von TestVorschauSperrtOhneUntergrenze.
func untergrenzeSperre(b Bestand) []Sperre {
	if len(b.Wellenlose) == 0 || b.Untergrenze != "" {
		return nil
	}
	return []Sperre{{
		Kennung: "untergrenze",
		Grund: fmt.Sprintf("%d wellenlose(r) Slice(s) liegen flach in %s/, aber kein %s/*/%s setzt eine Untergrenze",
			len(b.Wellenlose), doneDir, doneDir, archivName),
		Zeilen: []string{
			"'wellenlos seit der letzten Closure' umfasste damit den gesamten Altbestand",
			"die Archivierung des Altbestands ist ein eigener Vorgang — danach ist die Grenze beobachtbar",
		},
	}}
}

// Schreibe rendert den Bericht als Text. Beide Zweige geben ihn aus — der
// Vorschau-Lauf als sein Ergebnis, der schreibende als seine Vorpruefung —, und
// die vier Einsammel-Zahlen stehen darin in der Reihenfolge Mitglieder ·
// wellenlos · fremd · Review-Reports.
func Schreibe(b Bericht) string {
	var sb strings.Builder
	be := b.Bestand
	fmt.Fprintf(&sb, "archive-welle --vorschau: %s\n", be.Welle)
	fmt.Fprintf(&sb, "  Mitglieder (Welle-Feld nennt %s): %d\n", be.Welle, len(be.Mitglieder))
	fmt.Fprintf(&sb, "  wellenlos (seit der letzten Closure): %d\n", len(be.Wellenlose))
	fmt.Fprintf(&sb, "  fremd (andere Welle, bleibt liegen):  %d\n", len(be.Fremde))
	fmt.Fprintf(&sb, "  Review-Reports (ohne Stub):           %d\n", len(be.Reviews))
	schreibeVerweise(&sb, b.Funde)
	schreibeSperren(&sb, b.Sperren)
	return sb.String()
}

// schreibeVerweise nennt den Blast-Radius: die betroffenen Dateien mit ihrer
// Zahl je Form. Null Treffer ist eine Aussage und wird ausgeschrieben.
//
// ZWEI EINHEITEN, beide beschriftet: die erste Zahl zaehlt DATEIEN, die drei in
// der Klammer FUNDSTELLEN ueber alle Dateien. Eine Fundstellen-Zahl kann die
// Datei-Zahl uebersteigen — ohne eigenes Einheitswort laese der Aufrufer sie als
// Teilmenge der ersten. TestSchreibeTrenntDateienVonFundstellen haelt es.
func schreibeVerweise(sb io.Writer, funde []Fund) {
	praefix, geschwister, aufsteigend := 0, 0, 0
	for _, f := range funde {
		praefix += f.Praefix
		geschwister += f.Geschwister
		aufsteigend += f.Aufsteigend
	}
	fmt.Fprintf(sb, "  Verweise: %d Datei(en) betroffen (%d Praefix-, %d geschwister-relative, %d aufsteigende Fundstelle(n))\n",
		len(funde), praefix, geschwister, aufsteigend)
	for _, f := range funde {
		fmt.Fprintf(sb, "    %s (%d)\n", f.Datei, f.Summe())
	}
}

// schreibeSperren nennt die fail-closed-Ausgaenge. Keine Sperre ist ebenfalls
// eine Antwort und steht als Satz da, nicht als leere Liste.
func schreibeSperren(sb *strings.Builder, sperren []Sperre) {
	if len(sperren) == 0 {
		sb.WriteString("  Sperren: keine — der schreibende Lauf liefe.\n")
		return
	}
	fmt.Fprintf(sb, "  Sperren: %d — der schreibende Lauf braeche ab.\n", len(sperren))
	for _, s := range sperren {
		fmt.Fprintf(sb, "    [%s] %s\n", s.Kennung, s.Grund)
		for _, z := range s.Zeilen {
			fmt.Fprintf(sb, "      %s\n", z)
		}
	}
}
