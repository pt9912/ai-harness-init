package emit

// Der Commit-Kennungs-Waechter der emittierten Ebene: der git-eigene Traeger, die
// Pruefung, die er aufruft, und das Ziel, das ihn aktiviert. Drei Dateien, ein
// Gegenstand — der Traeger liegt versioniert im Ziel und reist mit dessen Klon,
// seine Aktivierung ist lokale Konfiguration und darum ein eigener Schritt.
//
// ZWEI KLASSEN, UND DER UNTERSCHIED IST DER DES GEGENSTANDS (ADR-0054 Festlegung 1 und 2):
// die Pruefung und das Aktivierungs-Fragment liegen an Pfaden, die die Emission bestimmt —
// sie werden konvergent geschrieben. Der Traeger liegt an einem Namen, den git fixiert, in
// einem Verzeichnis des Adopters: an diesem Pfad ist das Werkzeug ein Gast, ein Ziel mit
// eigener Zusage behaelt seine Datei (skip-if-present). Keine der drei Klassen folgt aus
// einer der anderen.
//
// WARUM DIE PRUEFUNG NICHT IM HOOK STEHT: sie liegt als eigene Datei im
// emittierten Werkzeug-Verzeichnis wie der Vorlauf-Waechter der history-lesenden
// Targets — dort deckt der Shell-Lint dieses Repos sie, und der Hook bleibt ein
// Aufruf. Beide sind bash + coreutils, ohne Docker und ohne Netz.
const (
	// CommitMsgHookPath ist der Zielort des git-eigenen Hooks. Der Name ist der
	// von git verlangte: git ruft einen Hook ueber seinen nackten Namen auf.
	CommitMsgHookPath = ".githooks/commit-msg"

	// CommitMsgCheckPath ist der Zielort der Pruefung, die der Hook aufruft.
	CommitMsgCheckPath = "tools/harness/commit-msg-traceability.sh"

	// HooksInstallMkPath ist der Zielort des Fragments, das den Traeger aktiviert.
	HooksInstallMkPath = "harness/mk/hooks-install.mk"
)

// commitMsgBelegterPfadMeldung ist der Zusatz der Meldung, die ein BELEGTER Traeger-Pfad
// ausloest. Er nennt die Pruefung, weil sie das Stueck ist, das dem Adopter dann statt des
// Traegers bereitliegt — sie wird bei jedem Lauf kanonisch neu geschrieben, waehrend sein
// eigener Traeger stehenbleibt (ADR-0054 Festlegung 3).
const commitMsgBelegterPfadMeldung = "Die mitgelieferte Pruefung " + CommitMsgCheckPath + " liegt daneben bereit; ein eigener Traeger kann sie von dort aufrufen."

// commitMsgQuellen sind die eingebetteten Quellpfade (enforceFS). Der Hook-Quellname
// traegt die .sh-Endung, sein Zielname nicht: der Shell-Lint dieses Repos faehrt
// `internal/emit/templates/enforce/*.sh`, und git verlangt fuer den Hook den
// nackten Namen.
const (
	commitMsgHookSrc  = "templates/enforce/commit-msg-hook.sh"
	commitMsgCheckSrc = "templates/enforce/commit-msg-traceability.sh"
	hooksInstallMkSrc = "templates/enforce/hooks-install.mk"
)

// commitMsgHookFile bildet den git-eigenen Traeger auf seinen Ziel-Relpfad ab —
// AUSFUEHRBAR: git verwirft einen Hook ohne Ausfuehrungsrecht still, ein
// verlorenes Bit waere ein Waechter, der nur so aussieht.
//
// SKIP-IF-PRESENT, und das ist die Klasse des Bodens, auf dem er liegt: der Name ist von git
// fixiert und das Verzeichnis gehoert dem Repo — ein Adopter, der an diesem Pfad seine eigene
// Kennungs-Zusage fuehrt, behaelt sie, und der Lauf nennt ihm die Pruefung, die daneben
// bereitliegt (ADR-0054 Festlegung 1 und 3). Ein Lauf, der ihn konvergent schriebe, koennte
// am Pfad nicht erkennen, wessen Datei dort liegt, und stellte das Ziel schlechter als es war.
func commitMsgHookFile() enforceFile {
	return enforceFile{src: commitMsgHookSrc, dst: CommitMsgHookPath, mode: 0o755,
		class: SkipIfPresent, meldung: commitMsgBelegterPfadMeldung}
}

// commitMsgCheckFile bildet die Pruefung auf ihren Ziel-Relpfad ab — AUSFUEHRBAR,
// aus demselben Grund: der Hook startet sie als Programm.
//
// KONVERGENT: ihr Pfad liegt unter der Wurzel tools/harness/* der Tabelle in ADR-0007
// Festlegung 3, und sie ist das Stueck des Paares, das sich mit der Fassung des Werkzeugs
// aendert — eine aeltere Fassung im Ziel wird bei jedem Lauf geheilt.
func commitMsgCheckFile() enforceFile {
	return enforceFile{src: commitMsgCheckSrc, dst: CommitMsgCheckPath, mode: 0o755, class: Konvergent}
}

// hooksInstallMkFile bildet das Aktivierungs-Fragment auf seinen Ziel-Relpfad ab —
// KONVERGENT wie die uebrigen tool-eigenen Fragmente (ADR-0007): sein Pfad liegt unter der
// Wurzel harness/mk/*.mk der dortigen Tabelle. Es haengt an keinem Laufzeit-Ausgang und
// meldet die Abwesenheit des Traegers selbst, statt auf ein fehlendes Programm zu zeigen
// (LH-QA-01).
func hooksInstallMkFile() enforceFile {
	return enforceFile{src: hooksInstallMkSrc, dst: HooksInstallMkPath, mode: 0o644, class: Konvergent}
}
