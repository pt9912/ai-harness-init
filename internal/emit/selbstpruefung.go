package emit

// Die Selbstpruefung der emittierten Durchsetzungsschicht (LH-FA-11): das Skript, das
// das Ziel auf einem frischen Klon seines eigenen Repos faehrt, und das Fragment, das
// es ueber `make` des Ziels erreichbar macht. Zwei Dateien, ein Gegenstand.
//
// EIGENE DATEI NEBEN commitmsg.go, WEIL DER GEGENSTAND EIN ANDERER IST: dort liegt der
// Traeger der Commit-Kennung, hier der Nachweis, dass er im Ziel greift. Die Pruefung
// liest den Traeger; sie aendert ihn nicht.
//
// BEIDE KONVERGENT (ADR-0007 Festlegung 3): ihre Pfade liegen unter den Wurzeln
// tools/harness/* und harness/mk/*.mk der dortigen Tabelle — Orte, die die Emission
// bestimmt. Die skip-if-present-Klasse des Traegers (ADR-0054) faerbt nicht auf sie ab:
// sie haengt am Namen, den git fixiert, und den fuehrt keine dieser zwei Dateien.
//
// KEIN GATE: das Fragment definiert ein Kommando und haengt es an keine Gate-Kette des
// Ziels. Ein `gates`-Lauf, der einen Klon mitfuehrte, machte ein rotes Ziel-Gate von
// einem roten Klon-Lauf ununterscheidbar.
const (
	// SelbstpruefungPath ist der Zielort des Skripts — im emittierten Layout
	// tools/harness/ (nicht das lokal adaptierte harness/tools/, MR-005).
	SelbstpruefungPath = "tools/harness/selbstpruefung.sh"

	// SelbstpruefungMkPath ist der Zielort des Fragments, das das Kommando definiert.
	SelbstpruefungMkPath = "harness/mk/selbstpruefung.mk"
)

const (
	selbstpruefungSrc   = "templates/enforce/selbstpruefung.sh"
	selbstpruefungMkSrc = "templates/enforce/selbstpruefung.mk"
)

// SelbstpruefungMarker nennt die drei adaptierbaren Marker der Vorlage (LH-FA-02): ein
// Adopter setzt sie am Aufruf oder im Fragment, statt die Datei zu editieren — eine von
// Hand geaenderte Fassung schriebe der naechste konvergente Lauf ohnehin neu.
//
// Die Liste ist die EINE Stelle, an der die drei Namen stehen; der Test haelt Vorlage und
// Fragment gegen sie, und eine Umbenennung in nur einer der zwei Dateien faellt.
func SelbstpruefungMarker() []string {
	return []string{
		"SELBSTPRUEFUNG_TRAEGER",
		"SELBSTPRUEFUNG_AKTIVIERUNG",
		"SELBSTPRUEFUNG_GATE",
	}
}

// selbstpruefungFile bildet das Skript auf seinen Ziel-Relpfad ab — AUSFUEHRBAR: das
// Fragment startet es als Programm, und git transportiert vom Modus nur das
// Ausfuehrungs-Bit; ein verlorenes Bit waere eine Pruefung, die nur so aussieht.
func selbstpruefungFile() enforceFile {
	return enforceFile{src: selbstpruefungSrc, dst: SelbstpruefungPath, mode: 0o755, class: Konvergent}
}

// selbstpruefungMkFile bildet das Fragment auf seinen Ziel-Relpfad ab. Der Aggregator des
// Ziels bindet es ueber `include harness/mk/*.mk` ein.
func selbstpruefungMkFile() enforceFile {
	return enforceFile{src: selbstpruefungMkSrc, dst: SelbstpruefungMkPath, mode: 0o644, class: Konvergent}
}
