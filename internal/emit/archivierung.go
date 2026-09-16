package emit

// ArchivierungMkPath ist der Zielort des Fragments der Wellen-Archivierung: das
// Gate-Fragment-Verzeichnis des Ziels (ADR-0033 Festlegung 4, Muster MR-010).
// Das Praefix ist die Adresse, unter der der Root-Aggregator die Fragmente per
// Glob einbindet; nur dort fahren die `make`-Laeufe des Adopters sie.
const ArchivierungMkPath = "harness/mk/archivierung.mk"

// archivierungMkSrc ist der eingebettete Quellpfad des Fragments (enforceFS).
const archivierungMkSrc = "templates/enforce/archivierung.mk"

// archivierungFile bildet das Fragment auf seinen Ziel-Relpfad ab — KONVERGENT wie
// die uebrige tool-eigene Infrastruktur (ADR-0007, Idempotenz-Klasse "tool-eigenes
// Gate-Fragment").
//
// UNBEDINGT, wie das Fragment der Erfassungsschicht, und aus demselben Grund: es
// behauptet nichts ueber einen Lauf, sondern meldet die Abwesenheit des Traegers
// selbst. Der Traeger liegt gitignored, ein frischer Klon hat ihn also nicht — und
// das Kommando, das ihm das sagt, liegt hier und nicht bei ihm.
func archivierungFile() enforceFile {
	return enforceFile{src: archivierungMkSrc, dst: ArchivierungMkPath, mode: 0o644, class: Konvergent}
}
