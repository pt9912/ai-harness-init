package main

// archive-lesen — das Unterkommando liest ein Archiv am Host: jeden Eintrag
// bis zum Ende (der CRC-Vergleich liegt am Ende des Lesens) und die
// Namensliste des Archivs auf stdout. Es ist die Leseprobe hinter einem
// abgeschlossenen Lauf (full-smoke, archiv_gueltig) und vergleicht NICHT
// gegen Quellen: die Rueckleseprobe des Traegers (archive-welle, pruefeArchiv)
// haelt Namen und Bytes gegen die repo-relativen Quellen und gilt fuer den
// Zeitpunkt der Probe; dieses Unterkommando liest die Datei, die ein Lauf
// hinterlassen hat — dort kann die Quelle schon zum Stub gekuerzt sein.
//
// Ein Befund endet laut mit Exit 1: das Archiv liess sich nicht oeffnen, ein
// Eintrag liess sich nicht bis zum Ende lesen, oder einer der genannten
// Eintraege liegt nicht in der Namensliste. archive-lesen nimmt nur einen
// Dateipfad und Eintrag-Namen, kein Zielverzeichnis; der Dispatch ruft es
// nicht ueber die Ziel-Aufloesung des Init-Pfads (os.Args[2:] direkt), damit
// ein Pfad als Leseprobe-Argument bleibt.
import (
	"archive/zip"
	"fmt"
	"io"
)

func archiveLesen(args []string, stdout, stderr io.Writer) int {
	if len(args) < 1 {
		fmt.Fprintln(stderr, "archive-lesen: kein Archiv angegeben — ai-harness-init archive-lesen <archiv.zip> [eintrag...]")
		return 2
	}
	zipPfad := args[0]
	eintraege := args[1:]

	zr, fehler := zip.OpenReader(zipPfad)
	if fehler != nil {
		fmt.Fprintf(stderr, "archive-lesen: %s nicht lesbar: %v\n", zipPfad, fehler)
		return 1
	}
	defer func() { _ = zr.Close() }()

	namen := make([]string, 0, len(zr.File))
	for _, eintr := range zr.File {
		leser, oeffnefehler := eintr.Open()
		if oeffnefehler != nil {
			fmt.Fprintf(stderr, "archive-lesen: Eintrag %s nicht lesbar: %v\n", eintr.Name, oeffnefehler)
			return 1
		}
		// Bis zum Ende lesen — fuer Deflate-Eintraege prueft der Leser am Ende
		// des Lesens die CRC; ein Eintrag, der nur angeschnitten wird, faellt
		// im Lese-Fehler, nicht im Namen.
		_, lesefehler := io.Copy(io.Discard, leser)
		_ = leser.Close()
		if lesefehler != nil {
			fmt.Fprintf(stderr, "archive-lesen: Eintrag %s nicht lesbar: %v\n", eintr.Name, lesefehler)
			return 1
		}
		namen = append(namen, eintr.Name)
	}
	for _, name := range namen {
		fmt.Fprintln(stdout, name)
	}
	for _, eintrag := range eintraege {
		enhalten := false
		for _, name := range namen {
			if name == eintrag {
				enhalten = true
				break
			}
		}
		if !enhalten {
			fmt.Fprintf(stderr, "archive-lesen: %s fuehrt den Eintrag %s nicht\n", zipPfad, eintrag)
			return 1
		}
	}
	return 0
}
