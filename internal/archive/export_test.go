package archive

import "io"

// AnwendenMitZip ist Anwenden mit ersetztem Schreibpunkt des Archivs. Nur im
// Testbinaer vorhanden.
func AnwendenMitZip(root string, b Bestand, dateien []string, g Git, out io.Writer, schreibe func(root, zielRel string, pfade []string) error) error {
	return anwenden(root, b, dateien, g, out, schreibe)
}

// SperrenFuerTest ist sperren fuer den Test: seit ADR-0061 Festlegung 1 traegt
// die Haenger-Liste keinen Fall mehr, und der Nicht-Lift der Sperre unter dem
// Schluessel altbestand (ADR-0041 Festlegung 4) ist ueber der Vorschau-Kante
// nicht mehr konstruktierbar. Der Test konstruiert die Liste ueber dieser Kante
// und haelt die Verdrahtung — nur hier, nicht an der Vorschau.
func SperrenFuerTest(b Bestand, porcelain string, haenger []string) []Sperre {
	return sperren(b, porcelain, haenger)
}

// AltbestandFuerTest liefert einen Bestand unter dem Schluessel altbestand, an
// dem keiner der vier aufgehobenen Ausgaenge steht.
func AltbestandFuerTest() Bestand {
	return Bestand{Welle: AltbestandSchluessel, Mitglieder: []string{"docs/plan/planning/done/slice-100-a.md"}}
}
