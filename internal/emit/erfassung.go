package emit

// ErfassungMkPath ist der Zielort des Aufraeum- und Berichts-Fragments: das
// Gate-Fragment-Verzeichnis des Ziels (ADR-0022 Festlegung 6 Stueck 2, Muster MR-010).
// Das Praefix ist die Adresse, unter der der Root-Aggregator die Fragmente per Glob
// einbindet — ein Ziel daneben liefe in keinem `make` des Adopters.
const ErfassungMkPath = "harness/mk/erfassung.mk"

// erfassungMkSrc ist der eingebettete Quellpfad des Fragments (enforceFS).
const erfassungMkSrc = "templates/enforce/erfassung.mk"

// erfassungFile bildet das Fragment auf seinen Ziel-Relpfad ab — KONVERGENT wie die
// uebrige tool-eigene Infrastruktur (ADR-0022 Idempotenz-Tabelle: "tool-eigenes
// Gate-Fragment").
//
// UNBEDINGT, und das ist eine Entscheidung: es teilt den Zweig des Traegers NICHT.
// ADR-0022 Festlegung 5(a) zaehlt drei Artefakte auf, die mit dem Traeger stehen und
// fallen — Traeger, Wrapper, Hook-Eintrag —, und Festlegung 7 nimmt die Feldliste dazu,
// weil sie eine Aussage UEBER eine Erfassung waere, die nicht liegt. Dieses Fragment
// behauptet nichts: `span-clean` braucht den Traeger gar nicht (ein Bestand ueberlebt
// ihn), und `span-report` prueft ihn, statt ihn vorauszusetzen — es meldet seine
// Abwesenheit, statt auf ein fehlendes Programm zu zeigen (LH-QA-01). Waere es bedingt,
// haette ein Ziel mit gescheiterter Ablage kein Aufraeum-Kommando fuer einen Bestand,
// den ein frueherer Lauf hinterlassen hat — und seine zwei Ziele fielen aus der
// init-invarianten Menge, obwohl jeder Bootstrap sie schreibt.
func erfassungFile() enforceFile {
	return enforceFile{src: erfassungMkSrc, dst: ErfassungMkPath, mode: 0o644}
}
