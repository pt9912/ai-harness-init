package archive

import (
	"fmt"
	"strings"
)

// UnsauberGrund nennt den Grund, aus dem der Arbeitsbaum nicht sauber ist —
// leer, wenn er es ist. Eingabe ist die Ausgabe von `git status --porcelain`.
//
// ZUSAGE, und sie ist ADR-0033 Abnahme-Kriterium 2 in seiner lesenden Haelfte:
// gezaehlt werden BEIDE Klassen — Aenderungen an getrackten Dateien UND
// untrackter Bestand. Die Zusage lautet "sauberer Arbeitsbaum" ohne
// Einschraenkung, und eine untrackte Fremddatei ist unter ihr keiner: der
// Inhalts-Commit des schreibenden Laufs ist der Wave-Self-Close-Punkt, den ein
// Audit liest — traegt er fremden Inhalt, ist die Zusage "der
// Archivierungs-Commit bezeugt die Vollstaendigkeit" gebrochen, ohne dass etwas
// rot wird. TestUnsauberGrundZaehltUntrackte deckt genau diese Haelfte;
// test/mutations/232-archive-welle-go-untrackt.sh nimmt sie weg.
//
// Die zwei Klassen stehen GETRENNT in der Meldung, weil die Abhilfe verschieden
// ist: committen oder stashen gegen aufraeumen oder ignorieren.
//
// ABGRENZUNG zur Wortwahl: gezaehlt werden ZEILEN der porcelain-Ausgabe, und
// eine Zeile kann ein untracktes VERZEICHNIS sein. Die Meldung sagt darum
// "Eintrag" und nicht "Datei"; nur die getrackte Haelfte nennt Dateien, weil git
// dort je Datei eine Zeile schreibt.
func UnsauberGrund(porcelain string) string {
	getrackt, untrackt := 0, 0
	for _, zeile := range strings.Split(porcelain, "\n") {
		if strings.TrimSpace(zeile) == "" {
			continue
		}
		if strings.HasPrefix(zeile, "?? ") {
			untrackt++
			continue
		}
		getrackt++
	}
	switch {
	case getrackt > 0 && untrackt > 0:
		return fmt.Sprintf("%d Aenderung(en) an getrackten Dateien und %d untrackte(r) Eintrag/Eintraege", getrackt, untrackt)
	case getrackt > 0:
		return fmt.Sprintf("%d Aenderung(en) an getrackten Dateien", getrackt)
	case untrackt > 0:
		return fmt.Sprintf("%d untrackte(r) Eintrag/Eintraege", untrackt)
	default:
		return ""
	}
}
