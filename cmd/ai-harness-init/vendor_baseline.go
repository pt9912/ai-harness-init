// Das Unterkommando `vendor-baseline` legt den vendored Baum DIESES Repos aus
// dem verifizierten Release-Asset an, statt ihn von Hand aus einem fremden
// Arbeitsbaum zu kopieren. Die Faehigkeit liegt vollstaendig in
// internal/fetch.Baseline (LH-FA-09) und hatte bislang genau EINEN Aufrufer,
// den Init-Pfad fuer ZIELREPOS (run() -> bootstrap()); dieser Zweig ist der
// zweite, fuer den eigenen Baum (harness/conventions.md §Adoptierte
// Konventions-Quellen: „Asset -> vendored Baum haelt nichts" — dieser Vorgang
// gibt der Provenienz-Kette einen benannten Traeger statt Handarbeit).
//
// Wie `archive-welle` steht der Dispatch VOR run() (main() §GRENZE): er loest
// seine Repo-Wurzel selbst auf und braucht das targetDir von run() nicht.
//
// KONVERGENT (ADR-0007, wie beim Init-Pfad): ein vorhandenes <tag>-Verzeichnis
// wird durch die aus dem Asset entpackte Fassung ERSETZT — das macht den Lauf
// WIEDERHOLBAR (LH-QA-02) und einen falschen sha256-Pin sichtbar, BEVOR
// irgendetwas geschrieben wird (SHA256Mismatch, TestBaseline_SHA256Mismatch_NothingWritten
// in internal/fetch/baseline_test.go deckt genau diesen Pfad).
package main

import (
	"context"
	"fmt"
	"io"
	"path/filepath"
	"time"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

const vendorBaselineUsage = `ai-harness-init vendor-baseline <tag> <sha256>

Legt den vendored Baum DIESES Repos (.harness/baseline/<tag>/) aus dem
verifizierten Release-Asset an: sha256 gegen <sha256> pruefen, regelwerk/ UND
templates/ entpacken, SHA256SUMS schreiben. KONVERGENT — ein vorhandenes
<tag>-Verzeichnis wird ersetzt, kein zweites legt sich daneben.

  <tag>      Kurs-Tag (kanonisch: BASELINE_TAG im Makefile)
  <sha256>   erwarteter sha256 des Release-Assets (kanonisch:
             BASELINE_ZIP_SHA256 im Makefile)

Exit-Codes:
  0   Baseline steht, verifiziert.
  2   Aufruf-Fehler (Argumente).
  1   Laufzeit-Fehler (keine Repo-Wurzel, Netz, sha256-Mismatch, Entpack-Fehler)
      — bei Mismatch/Entpack-Fehler bleibt ein bestehender Baum UNVERAENDERT.
`

// vendorBaseline ist der testbare Kern des Unterkommandos: Argumente rein,
// Text raus, Exit-Code zurueck. Er verdrahtet den Betriebs-Eingang — die
// echte Repo-Wurzel (dieselbe Aufloesung wie `archive-welle`, repoWurzel in
// archive_welle.go) und den echten Netz-Fetch — und delegiert.
func vendorBaseline(args []string, out, errOut io.Writer) int {
	return vendorBaselineMit(args, repoWurzel, fetch.DownloadBaseline, out, errOut)
}

// vendorBaselineMit nimmt die Repo-Wurzel-Aufloesung und den Asset-Fetch als
// Werte, damit der Parser- und Verdrahtungspfad ohne Repo und ohne Netz
// pruefbar bleibt — dieselbe Fixture-Form wie internal/fetch/baseline_test.go.
func vendorBaselineMit(args []string, wurzel func() (string, error), fetchFn fetch.AssetFetch, out, errOut io.Writer) int {
	tag, sha, code := parseVendorBaseline(args, out, errOut)
	if code >= 0 {
		return code
	}
	root, err := wurzel()
	if err != nil {
		fmt.Fprintf(errOut, "vendor-baseline: %v\n", err)
		return 1
	}
	dest := baselineDir(root)
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	if err := fetch.Baseline(ctx, dest, tag, sha, fetchFn); err != nil {
		fmt.Fprintf(errOut, "vendor-baseline: %v\n", err)
		return 1
	}
	fmt.Fprintf(out, "vendor-baseline: %s vendored (aus dem verifizierten Asset).\n", filepath.Join(dest, tag))
	return 0
}

// parseVendorBaseline liest die zwei Pflicht-Positionsargumente. Der dritte
// Rueckgabewert ist -1, solange der Aufruf weiterlaeuft, sonst der Exit-Code
// eines bereits gedruckten Ausgangs — dieselbe Form wie parseArchiveWelle in
// archive_welle.go.
func parseVendorBaseline(args []string, out, errOut io.Writer) (tag, sha string, code int) {
	if len(args) == 1 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Fprint(out, vendorBaselineUsage)
		return "", "", 0
	}
	if len(args) != 2 {
		fmt.Fprintln(errOut, "Fehler: vendor-baseline braucht genau <tag> <sha256>")
		fmt.Fprint(errOut, vendorBaselineUsage)
		return "", "", 2
	}
	return args[0], args[1], -1
}
