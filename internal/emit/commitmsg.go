package emit

// Der Commit-Kennungs-Waechter der emittierten Ebene: der git-eigene Traeger, die
// Pruefung, die er aufruft, und das Ziel, das ihn aktiviert. Drei Dateien, ein
// Gegenstand — der Traeger liegt versioniert im Ziel und reist mit dessen Klon,
// seine Aktivierung ist lokale Konfiguration und darum ein eigener Schritt.
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
// UNBEDINGT wie die uebrigen Fragmente: er behauptet nichts ueber einen Lauf. Ein
// Ziel ohne den Aufruf `make hooks-install` ist ungeprueft — der Traeger liegt
// dann da und schweigt, und das Fragment daneben sagt es.
func commitMsgHookFile() enforceFile {
	return enforceFile{src: commitMsgHookSrc, dst: CommitMsgHookPath, mode: 0o755}
}

// commitMsgCheckFile bildet die Pruefung auf ihren Ziel-Relpfad ab — AUSFUEHRBAR,
// aus demselben Grund: der Hook startet sie als Programm.
func commitMsgCheckFile() enforceFile {
	return enforceFile{src: commitMsgCheckSrc, dst: CommitMsgCheckPath, mode: 0o755}
}

// hooksInstallMkFile bildet das Aktivierungs-Fragment auf seinen Ziel-Relpfad ab —
// KONVERGENT wie die uebrigen tool-eigenen Fragmente (ADR-0007), UNBEDINGT: es
// haengt an keinem Laufzeit-Ausgang und meldet die Abwesenheit des Traegers
// selbst, statt auf ein fehlendes Programm zu zeigen (LH-QA-01).
func hooksInstallMkFile() enforceFile {
	return enforceFile{src: hooksInstallMkSrc, dst: HooksInstallMkPath, mode: 0o644}
}
