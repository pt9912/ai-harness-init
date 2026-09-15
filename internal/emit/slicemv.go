package emit

// SliceMvMkPath ist der Zielort des Fragments des Lifecycle-Wechsels: das
// Gate-Fragment-Verzeichnis des Ziels, wie bei den Fragmenten der Erfassungs-
// und der Archivierungs-Schicht. Das Praefix ist die Adresse, unter der der
// Root-Aggregator die Fragmente per Glob einbindet; nur dort fahren die
// `make`-Laeufe des Adopters sie.
const SliceMvMkPath = "harness/mk/slice-mv.mk"

// SliceMvShPath ist der Zielort des Werkzeugs selbst. Es liegt im emittierten
// Layout der ausfuehrbaren Harness-Tools (tools/harness/) neben dem
// Vorlauf-Waechter; der Ablageort ist tool-eigen und wird kanonisch neu
// geschrieben.
const SliceMvShPath = "tools/harness/slice-mv.sh"

// slicemvMkSrc ist der eingebettete Quellpfad des Fragments (enforceFS).
const slicemvMkSrc = "templates/enforce/slice-mv.mk"

// slicemvShSrc ist der eingebettete Quellpfad des Werkzeugs (enforceFS).
const slicemvShSrc = "templates/enforce/slice-mv.sh"

// sliceMvMkFile bildet das Fragment auf seinen Ziel-Relpfad ab — KONVERGENT wie
// die uebrige tool-eigene Infrastruktur (ADR-0007, Idempotenz-Klasse
// "tool-eigenes Gate-Fragment").
//
// UNBEDINGT, wie die Fragmente der Erfassungs- und der Archivierungs-Schicht,
// und aus demselben Grund: es behauptet nichts ueber einen Lauf. Es meldet die
// Abwesenheit des Werkzeugs selbst, statt auf ein fehlendes Programm zu zeigen.
func sliceMvMkFile() enforceFile {
	return enforceFile{src: slicemvMkSrc, dst: SliceMvMkPath, mode: 0o644}
}

// sliceMvShFile bildet das Werkzeug auf seinen Ziel-Relpfad ab — KONVERGENT,
// aus demselben Grund, und AUSFUEHRBAR: es wird von `make slice-mv` gerufen.
//
// UNBEDINGT: der Lifecycle-Wechsel ist Teil des emittierten Prozesses, den der
// mitemittierte Anweisungssatz an zwei Stellen vorschreibt. Fehlt das Werkzeug,
// fehlt der Operation ihr Traeger — und das Fragment daneben, das ihn nennt,
// faellt mit ihm.
func sliceMvShFile() enforceFile {
	return enforceFile{src: slicemvShSrc, dst: SliceMvShPath, mode: 0o755}
}
