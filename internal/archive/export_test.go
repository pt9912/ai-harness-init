package archive

// ZipSchreiberErsetzen tauscht den Schreibpunkt des Archivs und gibt die
// Rueckstellung zurueck. Nur im Testbinaer vorhanden.
func ZipSchreiberErsetzen(f func(root, zielRel string, pfade []string) error) (zurueck func()) {
	alt := schreibeZip
	schreibeZip = f
	return func() { schreibeZip = alt }
}
