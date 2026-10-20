package archive

import "io"

// AnwendenMitZip ist Anwenden mit ersetztem Schreibpunkt des Archivs. Nur im
// Testbinaer vorhanden.
func AnwendenMitZip(root string, b Bestand, dateien []string, g Git, out io.Writer, schreibe func(root, zielRel string, pfade []string) error) error {
	return anwenden(root, b, dateien, g, out, schreibe)
}
