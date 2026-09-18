package emit

// Der Erzeuger der E2E-Abdeckungs-Sicht der emittierten Ebene (LH-FA-12): das Skript, das den
// Quelltext des E2E-Skripts eines Zielrepos liest, und das Fragment, das es ueber
// `make` des Ziels erreichbar macht. Zwei Dateien, ein Gegenstand.
//
// EIGENE DATEI NEBEN selbstpruefung.go, WEIL DER GEGENSTAND EIN ANDERER IST: dort liegt
// das E2E des Ziels, hier die Sicht ueber dessen Stufen. Der Erzeuger liest jenes
// Skript; er faehrt es nicht und aendert es nicht.
//
// BEIDE KONVERGENT (ADR-0007 Festlegung 3): ihre Pfade liegen unter den Wurzeln
// tools/harness/* und harness/mk/*.mk der dortigen Tabelle — Orte, die die Emission
// bestimmt.
//
// KEIN GATE: das Fragment definiert ein Kommando und haengt es an keine Gate-Kette des
// Ziels. Der Erzeuger urteilt ueber den Quelltext eines Skripts, nicht ueber den Zustand
// des Baums (LH-QA-01); an einer Gate-Kette faerbte er rot, weil eine Deklaration fehlt,
// nicht weil etwas kaputt ist.
const (
	// E2eAbdeckungPath ist der Zielort des Erzeugers — im emittierten Layout
	// tools/harness/ (nicht das lokal adaptierte harness/tools/, MR-005).
	E2eAbdeckungPath = "tools/harness/e2e-abdeckung.sh"

	// E2eAbdeckungMkPath ist der Zielort des Fragments, das das Kommando definiert.
	E2eAbdeckungMkPath = "harness/mk/e2e-abdeckung.mk"
)

const (
	e2eAbdeckungSrc   = "templates/enforce/e2e-abdeckung.sh"
	e2eAbdeckungMkSrc = "templates/enforce/e2e-abdeckung.mk"
)

// E2eAbdeckungMarker nennt die adaptierbaren Marker der Vorlage (LH-FA-02): ein Adopter
// setzt sie am Aufruf oder in einem eigenen Fragment seines Repos, statt die Datei zu
// editieren — eine von Hand geaenderte Fassung schriebe der naechste konvergente Lauf
// ohnehin neu.
//
// VIER STELLEN SIND ZIEL-SPEZIFISCH, und keine davon ist erratbar: WO das E2E liegt,
// mit welchem WORT seine Stufen-Kopfzeilen beginnen, aus welcher SPEC-Datei die Anker
// der Kennungsspalte stammen und WOHIN die Sicht geschrieben wird. Die Vorgaben sind
// die des mitgelieferten Bootstraps; ein Repo mit eigenem E2E setzt seine.
//
// Die Liste ist die EINE Stelle, an der die Namen stehen; der Test haelt Vorlage und
// Fragment gegen sie, und eine Umbenennung in nur einer der zwei Dateien faellt.
func E2eAbdeckungMarker() []string {
	return []string{
		"E2E_ABDECKUNG_QUELLE",
		"E2E_ABDECKUNG_PRAEFIX",
		"E2E_ABDECKUNG_SPEC",
		"E2E_ABDECKUNG_ZIEL",
	}
}

// e2eAbdeckungFile bildet den Erzeuger auf seinen Ziel-Relpfad ab — AUSFUEHRBAR: das
// Fragment startet ihn als Programm, und git transportiert vom Modus nur das
// Ausfuehrungs-Bit; ein verlorenes Bit waere ein Kommando, das nur so aussieht.
func e2eAbdeckungFile() enforceFile {
	return enforceFile{src: e2eAbdeckungSrc, dst: E2eAbdeckungPath, mode: 0o755, class: Konvergent}
}

// e2eAbdeckungMkFile bildet das Fragment auf seinen Ziel-Relpfad ab. Der Aggregator des
// Ziels bindet es ueber `include harness/mk/*.mk` ein.
func e2eAbdeckungMkFile() enforceFile {
	return enforceFile{src: e2eAbdeckungMkSrc, dst: E2eAbdeckungMkPath, mode: 0o644, class: Konvergent}
}
