// Das Unterkommando `vendor-baseline` legt den vendored Baum DIESES Repos aus
// dem verifizierten Release-Asset an, statt ihn von Hand aus einem fremden
// Arbeitsbaum zu kopieren. Die Faehigkeit liegt vollstaendig in
// internal/fetch.Baseline (LH-FA-09) und hat ausserhalb der Tests zwei
// Aufrufer: den Init-Pfad fuer ZIELREPOS (run() -> bootstrap()) und diesen
// Zweig, fuer den EIGENEN Baum (harness/conventions.md §Adoptierte
// Konventions-Quellen: „Asset -> vendored Baum haelt nichts" — dieser Vorgang
// gibt der Provenienz-Kette einen benannten Traeger statt Handarbeit).
//
// Wie `archive-welle` steht der Dispatch VOR run() (main() §GRENZE): er loest
// seine Repo-Wurzel selbst auf und braucht das targetDir von run() nicht.
//
// KONVERGENT (ADR-0007, wie beim Init-Pfad): ein vorhandenes <tag>-Verzeichnis,
// das GENAU DEN ANGEFORDERTEN TAG traegt, wird durch die aus dem Asset
// entpackte Fassung ERSETZT — das macht den Lauf WIEDERHOLBAR (LH-QA-02) und
// einen falschen sha256-Pin sichtbar, BEVOR irgendetwas geschrieben wird
// (SHA256Mismatch, TestBaseline_SHA256Mismatch_NothingWritten in
// internal/fetch/baseline_test.go deckt genau diesen Pfad).
//
// EIN ANDERER Tag daneben (Tag-Bump) ist NICHT konvergent: fremderTagVorhanden
// haelt genau diesen Fall VOR jedem Zugriff an, statt ein zweites
// <tag>-Verzeichnis danebenzulegen — MR-007 Setzung 4 verlangt genau EIN
// <tag>-Verzeichnis, und `make baseline-verify` braeche sonst NACH diesem
// Lauf mit "mehr als ein <tag>-Verzeichnis" ab.
// TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff deckt den Fall.
package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

const vendorBaselineUsage = `ai-harness-init vendor-baseline <tag> <sha256>

Legt den vendored Baum DIESES Repos (.harness/baseline/<tag>/) aus dem
verifizierten Release-Asset an: sha256 gegen <sha256> pruefen, regelwerk/ UND
templates/ entpacken, SHA256SUMS schreiben. KONVERGENT — ein vorhandenes
<tag>-Verzeichnis, das GENAU <tag> heisst, wird ersetzt. Liegt stattdessen ein
ANDERES <tag>-Verzeichnis da (Tag-Bump), bricht der Lauf VOR jedem Zugriff ab
— dieses Ziel vendort den angegebenen Tag neu, es zieht keinen Tag-Wechsel
nach (MR-007 Setzung 4: ein Tag zur Zeit).

  <tag>      Kurs-Tag (kanonisch: BASELINE_TAG im Makefile)
  <sha256>   erwarteter sha256 des Release-Assets (kanonisch:
             BASELINE_ZIP_SHA256 im Makefile)

Exit-Codes:
  0   Baseline steht, verifiziert.
  2   Aufruf-Fehler (Argumente).
  1   Laufzeit-Fehler (keine Repo-Wurzel, anderes <tag>-Verzeichnis vorhanden,
      Netz, sha256-Mismatch, Entpack-Fehler) — in jedem dieser Faelle bleibt
      ein bestehender Baum UNVERAENDERT.
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
	fremd, err := fremderTagVorhanden(dest, tag)
	if err != nil {
		fmt.Fprintf(errOut, "vendor-baseline: %v\n", err)
		return 1
	}
	if fremd != "" {
		fmt.Fprintf(errOut, "vendor-baseline: %s enthaelt bereits %q (ein anderer Tag) — dieses Ziel ersetzt nur %s selbst, ein Tag-Wechsel bleibt ausserhalb (MR-007 Setzung 4: ein Tag zur Zeit); %s von Hand entfernen und den Lauf wiederholen.\n", dest, fremd, tag, filepath.Join(dest, fremd))
		return 1
	}
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	if err := fetch.Baseline(ctx, dest, tag, sha, fetchFn); err != nil {
		fmt.Fprintf(errOut, "vendor-baseline: %v\n", err)
		return 1
	}
	fmt.Fprintf(out, "vendor-baseline: %s vendored (aus dem verifizierten Asset).\n", filepath.Join(dest, tag))
	return 0
}

// fremderTagVorhanden meldet den Namen eines Verzeichnisses unter dest, das
// NICHT tag heisst — also einen anderen als den angeforderten Tag traegt.
// Punkt-praefigierte Eintraege zaehlen nicht: internal/fetch legt Temp- und
// Beiseite-Verzeichnisse (`.baseline-*`, `.baseline-alt-*`) exakt so an, und
// harness/tools/baseline-verify.sh uebersieht sie aus demselben Grund (sein
// "$base"/*/-Glob ohne dotglob). Fehlt dest noch ganz (erster Lauf), ist das
// kein Fund.
func fremderTagVorhanden(dest, tag string) (string, error) {
	entries, err := os.ReadDir(dest)
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return "", nil
		}
		return "", fmt.Errorf("%s lesen: %w", dest, err)
	}
	for _, e := range entries {
		name := e.Name()
		if !e.IsDir() || name == tag || strings.HasPrefix(name, ".") {
			continue
		}
		return name, nil
	}
	return "", nil
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
