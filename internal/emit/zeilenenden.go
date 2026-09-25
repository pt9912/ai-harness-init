package emit

// zeilenendenSrc ist die eine Vorlage, die jede der fuenf emittierten .gitattributes
// traegt: die Zeile `* text=auto eol=lf`. `*` erfasst jede Datei des Verzeichnisses, auch
// die ohne Endung (blocked/<sprache>, .githooks/commit-msg); `text=auto` laesst eine Datei,
// die git als binaer erkennt, unberuehrt (ADR-0067 Festlegung 2).
const zeilenendenSrc = "templates/enforce/gitattributes"

// zeilenendenMeldung ist der Zusatz der Meldung, die ein BELEGTER skip-if-present-Pfad
// ausloest: er nennt das Verzeichnis und sagt, was dann gilt — die liegende Datei entscheidet,
// und traegt sie die Zeile nicht, liegen die Dateien des Verzeichnisses im Klon mit
// core.autocrlf=true mit CRLF (ADR-0067 Festlegung 4).
func zeilenendenMeldung(verzeichnis string) string {
	return "Traegt sie die Zeile `* text=auto eol=lf` nicht, tragen die Dateien in " + verzeichnis +
		"/ im Klon mit core.autocrlf=true CRLF."
}

// zeilenendenFiles sind die fuenf .gitattributes der Verzeichnisse, in denen das Werkzeug
// Dateien mit Interpreter- oder Byte-Konsument ablegt (ADR-0067 Festlegung 1). Die Klasse folgt
// dem Boden (Festlegung 3): KONVERGENT, wo das Werkzeug das Verzeichnis bestimmt — .harness/
// und tools/harness/ —, SKIP-IF-PRESENT MIT MELDUNG, wo ein Adopter oder ein fremdes Werkzeug
// den Namensraum mitfuehrt — harness/mk/, .claude/hooks/ und .githooks/. Die Klasse eines
// dieser Pfade steht nur hier. Die Wurzel des Ziels bekommt keinen Eintrag (Festlegung 5).
func zeilenendenFiles() []enforceFile {
	return []enforceFile{
		{src: zeilenendenSrc, dst: ".harness/.gitattributes", mode: 0o644, class: Konvergent},
		{src: zeilenendenSrc, dst: "tools/harness/.gitattributes", mode: 0o644, class: Konvergent},
		{src: zeilenendenSrc, dst: "harness/mk/.gitattributes", mode: 0o644, class: SkipIfPresent, meldung: zeilenendenMeldung("harness/mk")},
		{src: zeilenendenSrc, dst: ".claude/hooks/.gitattributes", mode: 0o644, class: SkipIfPresent, meldung: zeilenendenMeldung(".claude/hooks")},
		{src: zeilenendenSrc, dst: ".githooks/.gitattributes", mode: 0o644, class: SkipIfPresent, meldung: zeilenendenMeldung(".githooks")},
	}
}
