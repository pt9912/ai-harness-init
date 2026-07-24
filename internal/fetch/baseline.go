// Package fetch holt das Baseline-Bundle des Zielrepos (LH-FA-09, ADR-0005
// Herkunftsklasse "Fetch Kurs-SSoT"): das Release-Asset lab-regelwerk.zip, aus
// dem es Regelwerk UND Templates als committet-vendored Baseline im Ziel ablegt
// — es spiegelt MR-007 fuers Ziel. (Der Sprachskelett-Fetch aus fetch.go wich mit
// slice-023 dem Generator internal/gen; hier bleibt nur der Baseline-Fetch.)
//
// Drei Setzungen aus MR-007 sind hier Code, nicht Kommentar:
//   1. Provenienz != Integritaet: der sha256 des Assets wird VOR dem Entpacken
//      geprueft. Er ist der einzige Anker fuer die Upstream-Herkunft; die
//      selbst erzeugte SHA256SUMS belegt danach nur noch Unveraendertheit.
//   2. SHA256SUMS-Umfang: alle Dateien beider Baeume, Pfade relativ zu <tag>/,
//      LC_ALL=C-sortiert (nach PFAD, nicht nach Hash), die Datei selbst aus-
//      genommen — sie kann sich nicht selbst hashen.
//   3. Kein Teil-Emit (LH-QA-01): entpackt wird in ein Temp-Verzeichnis, das
//      erst nach vollstaendigem Erfolg an seinen Platz umbenannt wird. Bricht
//      irgendein Schritt ab, entsteht KEINE halbe Baseline — wohl aber ein
//      leeres destDir (s. Baseline). Das ist der Unterschied zwischen "keine
//      Teil-Baseline" und "nichts angefasst"; nur Ersteres wird zugesagt.
//      Ueber eine vorhandene Baseline (konvergent, slice-038) gilt das
//      eingeschraenkt: die alte wird beiseite gerenamt statt geloescht, ein
//      Fehlschlag rollt zurueck — es bleibt ein Restfenster von zwei Renames, in
//      dem ein Prozess-Tod das Ziel ohne Baseline zuruecklaesst (Daten unversehrt
//      in .baseline-alt-*, s. replaceBaseline). Ehrlich benannt statt pauschal zugesagt.
package fetch

import (
	"archive/zip"
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"net/http"
	"os"
	"path"
	"path/filepath"
	"sort"
	"strings"
)

// DefaultTag ist der per Default gepinnte Kurs-Tag (harness/conventions.md
// §Baseline, BASELINE_TAG; LH-QA-02). Per Env (COURSE_TAG) fuer bewussten
// Opt-in ueberschreibbar. TestDefaultTag_MatchesBaseline koppelt ihn an die
// einzige Tag-Quelle im Makefile.
const DefaultTag = "v3.5.1"

// DefaultBaselineSHA256 ist der gepinnte sha256 des Baseline-Assets zu
// DefaultTag (LH-QA-02). Kanonisch lebt er als BASELINE_ZIP_SHA256 im Makefile;
// TestDefaultBaselineSHA256_MatchesMakefile koppelt beide fail-closed, damit
// eine Re-Baseline nicht die eine Haelfte bewegt und die andere vergisst.
const DefaultBaselineSHA256 = "7268a8e6f36476c98d5cf0547d16deacec70fcddcf23df38f87d029e967cb10d"

const (
	baselineURLBase = "https://github.com/pt9912/ai-harness-course/releases/download/"
	baselineAsset   = "lab-regelwerk.zip"
	sumsName        = "SHA256SUMS"
)

// maxBaselineBytes schrankt den Asset-Puffer VOR dem sha256-Pin ein. Der Pin
// (Setzung 1) prueft den INHALT — aber erst NACH dem Lesen; ohne Schranke
// puffert io.ReadAll einen beliebig grossen Body eines boesartigen/kaputten
// Servers vollstaendig, bevor der Pin ihn verwerfen kann (Review-Befund
// slice-022a L4, LH-QA-03). Die Schranke ist eine DoS-Grenze, KEINE
// Inhaltsaussage: das reale Asset misst ~241 KB (MR-007); 8 MiB laesst ~34-fach
// Wachstum und begrenzt den Speicher auf einen festen Betrag.
const maxBaselineBytes = 8 << 20

// baselineTrees sind die beiden Wurzeln, die das Bundle traegt. Beide muessen
// ankommen — ein Bundle mit nur einem Baum ist kein gueltiger Stand. Als
// Funktion (nicht als Paket-Variable), gochecknoglobals-konform.
func baselineTrees() []string { return []string{"regelwerk", "templates"} }

// AssetFetch liefert ein Release-Asset am Tag. Injizierbar, damit der Entpack-
// und Verifikationspfad ohne Netz (Fixture-ZIP) testbar ist.
type AssetFetch func(ctx context.Context, tag string) (io.ReadCloser, error)

// DownloadBaseline ist der Produktions-Fetcher: HTTP-GET des Release-Assets.
func DownloadBaseline(ctx context.Context, tag string) (io.ReadCloser, error) {
	url := baselineURLBase + tag + "/" + baselineAsset
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("baseline-request %s: %w", tag, err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("baseline-fetch %s: %w", tag, err)
	}
	if resp.StatusCode != http.StatusOK {
		_ = resp.Body.Close()
		// Fehlendes Asset zur Version -> begruendet NICHT emittieren (LH-FA-09
		// Kein-Halluzinat-AC), statt eine erfundene Baseline zu schreiben.
		return nil, fmt.Errorf("baseline-fetch %s: HTTP %d (Asset %s fehlt zur Version?)", tag, resp.StatusCode, baselineAsset)
	}
	return resp.Body, nil
}

// SHA256Mismatch meldet ein Asset, dessen Hash nicht dem Pin entspricht. Als Typ,
// damit der Aufrufer den Pin-Bruch von einem Netz-/Entpack-Fehler unterscheiden
// kann (via errors.As) — ein Pin-Bruch ist ein Reproduzierbarkeits-Befund
// (LH-QA-02), kein transienter Fehler.
type SHA256Mismatch struct {
	Tag  string
	Want string
	Got  string
}

func (e *SHA256Mismatch) Error() string {
	return fmt.Sprintf("baseline %s: sha256 %s erwartet, %s erhalten — Asset veraendert oder falscher Pin (LH-QA-02)", e.Tag, e.Want, e.Got)
}

// AssetTooLargeError meldet ein Asset, das maxBaselineBytes ueberschreitet, BEVOR
// der sha256-Pin greift. Als Typ (via errors.As unterscheidbar), damit der
// Aufrufer es vom Pin-Bruch (SHA256Mismatch) trennt: es ist ein Abwehr-Befund
// (LH-QA-03), kein Reproduzierbarkeits-Befund.
type AssetTooLargeError struct{ Max int64 }

func (e *AssetTooLargeError) Error() string {
	return fmt.Sprintf("baseline-asset ueberschreitet %d bytes vor dem sha256-pin — abgewiesen (LH-QA-03)", e.Max)
}

// Baseline holt das Bundle zu tag, verifiziert es gegen wantSHA und legt es als
// <destDir>/<tag>/{regelwerk,templates}/ + SHA256SUMS ab. KONVERGENT (slice-038,
// ADR-0007): die vendored Baseline ist rein tool-eigen — ein vorhandenes <tag>-
// Verzeichnis wird bei jedem Lauf durch die kanonische Fassung ERSETZT (heilt Drift +
// Baseline-Bump). Der Swap ersetzt nur <tag>/ (ein tool-eigener Baum), prunt keinen
// anderen .harness/-Inhalt.
//
// Fehlerverhalten: bis zum finalen Rename entsteht unter destDir kein
// <tag>-Verzeichnis und kein Temp-Rest. destDir SELBST wird frueh angelegt
// (os.MkdirAll) und bleibt bei einem Abbruch leer zurueck — ein leeres
// .harness/baseline/ laesst den Verifier laut "kaputter Checkout" melden, statt
// still gruen zu werden. Ersetzt der Lauf eine vorhandene Baseline, gilt zusaetzlich
// die Einschraenkung aus replaceBaseline.
func Baseline(ctx context.Context, destDir, tag, wantSHA string, fetch AssetFetch) error {
	final := filepath.Join(destDir, tag)

	rc, err := fetch(ctx, tag)
	if err != nil {
		return err
	}
	data, err := readCapped(rc, maxBaselineBytes)
	if err != nil {
		return fmt.Errorf("baseline %s lesen: %w", tag, err)
	}

	// Setzung 1: Hash VOR dem Entpacken. Danach ist die Herkunft nicht mehr
	// pruefbar — jede spaeter erzeugte Summe beschreibt nur noch, was wir selbst
	// geschrieben haben.
	if got := hex.EncodeToString(sha256Sum(data)); got != wantSHA {
		return &SHA256Mismatch{Tag: tag, Want: wantSHA, Got: got}
	}

	zr, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return fmt.Errorf("baseline %s entpacken: %w", tag, err)
	}

	// Setzung 3: erst in ein Temp-Verzeichnis NEBEN dem Ziel (gleiches Dateisystem,
	// damit das Rename kein Copy wird), dann atomar an seinen Platz.
	if err := os.MkdirAll(destDir, 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", destDir, err)
	}
	tmp, err := os.MkdirTemp(destDir, ".baseline-*")
	if err != nil {
		return fmt.Errorf("temp-verzeichnis in %s: %w", destDir, err)
	}
	// defer raeumt tmp auf JEDEM Go-Fehlerpfad (no-op nach erfolgreichem Rename).
	// Damit bleibt bei einem ABBRUCH (Fehler-Return) kein .baseline-*-Rest —
	// TestBaseline_IncompleteBundle belegt genau das (Abbruch NACH MkdirTemp, dest
	// bleibt leer; entfaellt der defer, wird der Test rot). Restfenster (bewusst
	// benannt, slice-025 L3): stirbt der Prozess (SIGKILL) ZWISCHEN MkdirTemp und
	// Rename, laeuft der defer nicht und ein .baseline-*-Verzeichnis bleibt liegen —
	// benigne: punkt-praefigiert, also vom "$base"/*/-Glob des Verifiers uebersehen
	// (MR-007 Setzung 4), und ein Folgelauf legt via MkdirTemp einen frischen
	// eindeutigen Namen an. Das Stat->Rename-Fenster in placeBaseline ist derselbe
	// akzeptierte Klasse-Race (dort benannt).
	defer func() { _ = os.RemoveAll(tmp) }()

	if err := unpackTrees(zr, tmp, tag); err != nil {
		return err
	}
	if err := writeSums(tmp); err != nil {
		return err
	}
	return placeBaseline(tmp, final, tag)
}

// placeBaseline schiebt das fertige Temp-Verzeichnis an seinen Platz. Die
// Existenz-Pruefung sitzt bewusst HIER (kurz vor dem Rename) und zusaetzlich
// implizit im Rename selbst: ein frueher Check waere ein TOCTOU-Fenster ueber
// den ganzen Download.
//
// Das verbleibende Stat->Rename-Fenster (ein Fremdprozess legt final ZWISCHEN
// Stat und Rename an) ist ein bewusst akzeptierter Race (slice-025 L3): er ist
// benigne, weil os.Rename auf ein leeres Ziel-Verzeichnis ersetzt und auf ein
// nicht-leeres sauber mit ENOTEMPTY scheitert — kein stilles Ueberschreiben. Ihn
// zu schliessen verlangte ein Lock ueber den ganzen Bootstrap; das ist bei einem
// Einzel-Nutzer-Init (WIP=1) nicht der Kosten wert. Ehrlich benannt statt
// stillschweigend gelassen.
//
// Eine vorhandene Baseline wird ersetzt (konvergent, slice-038) — per BEISEITE-RENAME,
// nicht per Loeschen (Review-Befund slice-022a N1). Der naheliegende os.RemoveAll(final)
// vor dem Rename zerstoert die Alt-Baseline, BEVOR der Ersatz steht: RemoveAll
// akkumuliert Fehler und loescht Geschwister weiter, sodass ein einziger nicht
// entfernbarer Eintrag den Rest des Baums trotzdem vernichtet — und auf demselben
// Fehlerpfad raeumt der defer in Baseline() zusaetzlich den Ersatz weg. Uebrig
// bliebe ein Zielrepo ohne Baseline. Hier sind stattdessen beide bewegenden
// Schritte atomar und der zweite rueckrollbar; nur das abschliessende Aufraeumen
// darf folgenlos scheitern.
func placeBaseline(tmp, final, tag string) error {
	switch _, err := os.Stat(final); {
	case err == nil:
		return replaceBaseline(tmp, final, tag)
	case !errors.Is(err, fs.ErrNotExist):
		return fmt.Errorf("%s pruefen: %w", final, err)
	}
	if err := os.Rename(tmp, final); err != nil {
		return fmt.Errorf("baseline %s platzieren: %w", tag, err)
	}
	return nil
}

// replaceBaseline tauscht eine vorhandene Baseline gegen die neue: alt beiseite,
// neu hinein, alt weg. Scheitert Schritt 2, wird Schritt 1 zurueckgerollt.
//
// Das Beiseite-Verzeichnis ist PUNKT-praefigiert: der Verifier entdeckt sein
// <tag>-Verzeichnis per "$base"/*/-Glob, und ein sichtbarer zweiter Eintrag
// liesse ihn "mehr als ein <tag>-Verzeichnis" melden (MR-007 Setzung 4).
//
// Restfenster (bewusst, dokumentiert): stirbt der Prozess zwischen Schritt 1 und
// 2, steht das Ziel ohne Baseline da — die Daten liegen aber unversehrt im
// .baseline-alt-*-Verzeichnis und sind per Rename zurueckholbar. Das ist strikt
// besser als der geloeschte Baum, den RemoveAll hinterlassen haette.
func replaceBaseline(tmp, final, tag string) error {
	// MkdirTemp liefert einen EINDEUTIGEN Pfad — das angelegte Verzeichnis muss
	// aber wieder weg: rename(2) auf ein existierendes Verzeichnis liefert auf
	// dem hier benutzten Dateisystem EEXIST (gemessen, Overlay-FS im Container),
	// nicht das von POSIX fuer leere Ziele erlaubte Ersetzen. Gebraucht wird der
	// Name, nicht das Verzeichnis.
	aside, err := os.MkdirTemp(filepath.Dir(final), ".baseline-alt-*")
	if err != nil {
		return fmt.Errorf("beiseite-verzeichnis fuer %s: %w", tag, err)
	}
	if err := os.Remove(aside); err != nil {
		return fmt.Errorf("beiseite-verzeichnis %s freigeben: %w", aside, err)
	}
	if err := os.Rename(final, aside); err != nil {
		return fmt.Errorf("alte baseline %s beiseite schieben: %w", tag, err)
	}
	if err := os.Rename(tmp, final); err != nil {
		// Rueckrollen: die alte Baseline gehoert zurueck an ihren Platz, sonst
		// haette der Fehlerpfad das Ziel schlechter hinterlassen als er es fand.
		if back := os.Rename(aside, final); back != nil {
			return fmt.Errorf("baseline %s platzieren: %w — RUECKROLLEN FEHLGESCHLAGEN, alte Baseline liegt in %s: %w", tag, err, aside, back)
		}
		return fmt.Errorf("baseline %s platzieren: %w", tag, err)
	}
	// Ab hier steht die neue Baseline. Ein Fehler beim Aufraeumen ist folgenlos
	// fuer die Korrektheit — er hinterlaesst nur ein punkt-praefigiertes Rest-
	// verzeichnis, das der Verifier-Glob ohnehin uebersieht.
	_ = os.RemoveAll(aside)
	return nil
}

// unpackTrees schreibt die regelwerk/- und templates/-Baeume nach root und
// stellt sicher, dass BEIDE nicht-leer ankommen.
func unpackTrees(zr *zip.Reader, root, tag string) error {
	seen := map[string]int{}
	claimedBy := map[string]string{} // Rel-Pfad -> ZIP-Eintrag, der ihn zuerst beansprucht
	for _, f := range zr.File {
		rel := baselineEntry(f.Name)
		if rel == "" || f.FileInfo().IsDir() {
			continue
		}
		if !filepath.IsLocal(rel) {
			continue // unsicherer Pfad (../) — wie im Skelett-Pfad verworfen
		}
		// Zwei Eintraege auf denselben Rel-Pfad: FEHLER, nicht "letzter gewinnt"
		// (Review-Befund slice-022a N4, mit Fixture belegt). writeFile nutzt
		// O_TRUNC — ohne diese Schranke haengt der Inhalt der vendored Baseline
		// an der ZIP-REIHENFOLGE statt am Asset-Inhalt, und die selbst erzeugte
		// SHA256SUMS deckt das Ergebnis danach zu. Ein mehrdeutiges Bundle wird
		// begruendet NICHT aufgenommen — dieselbe Linie wie beim unvollstaendigen
		// Bundle und beim GNU-escapten Pfad (LH-QA-02, LH-FA-09 Kein-Halluzinat-AC).
		if prev, dup := claimedBy[rel]; dup {
			return fmt.Errorf("baseline %s: %q und %q bilden beide auf %s ab — mehrdeutiges Bundle, welcher Eintrag gewaenne haenge an der ZIP-Reihenfolge", tag, prev, f.Name, rel)
		}
		claimedBy[rel] = f.Name
		rc, err := f.Open()
		if err != nil {
			return fmt.Errorf("%s im bundle oeffnen: %w", f.Name, err)
		}
		err = writeFile(filepath.Join(root, filepath.FromSlash(rel)), rc, 0o644)
		_ = rc.Close()
		if err != nil {
			return err
		}
		seen[strings.SplitN(rel, "/", 2)[0]]++
	}
	for _, tree := range baselineTrees() {
		if seen[tree] == 0 {
			// Unvollstaendiges Bundle -> begruendet NICHT emittieren
			// (LH-FA-09 Kein-Halluzinat-AC), statt eine halbe Baseline abzulegen.
			return fmt.Errorf("baseline %s: kein %s/-Baum im Bundle (%s unvollstaendig?)", tag, tree, baselineAsset)
		}
	}
	return nil
}

// maxBaselinePrefix ist die Tiefe, in der ein Wurzel-Marker noch akzeptiert
// wird: 0 (Marker steht an der Bundle-Wurzel) oder 1 (ein einzelnes Wrapper-
// Verzeichnis davor). Mehr braucht die zugesagte Prefix-Toleranz nicht.
const maxBaselinePrefix = 1

// baselineEntry liefert den Pfad ab dem regelwerk/- oder templates/-Wurzel-
// segment. Ein einzelnes Wrapper-Verzeichnis davor ist erlaubt, damit ein
// kuenftiger Top-Level-Prefix im Bundle den Extrakt nicht aendert.
// Leerstring = ausserhalb beider Baeume.
//
// Zwei Schranken, beide aus Review-Befund slice-022a N2 — vorher akzeptierte
// die Suche JEDES Marker-Segment in BELIEBIGER Tiefe:
//   - Tiefe: ein sachfremder zweiter regelwerk/- oder templates/-Zweig im Asset
//     (z. B. docs/examples/regelwerk/…) waere sonst still in die vendored
//     Baseline gemischt und danach von deren eigenen Pruefsummen gedeckt worden.
//   - Praefix-Form: ein leeres Segment (absoluter Pfad) oder ".." vor dem Marker
//     ist ein Ausbruchsversuch. Er brach zwar nie aus dem Ziel aus (path.Clean
//     laeuft davor), wurde aber still zu einem gueltig aussehenden Rel-Pfad
//     UMGESCHRIEBEN und aufgenommen — schlechter als verworfen, weil unsichtbar.
func baselineEntry(name string) string {
	parts := strings.Split(path.Clean(name), "/")
	for i := 0; i < len(parts) && i <= maxBaselinePrefix; i++ {
		if i > 0 && (parts[i-1] == "" || parts[i-1] == "..") {
			return "" // absoluter Pfad bzw. Traversal vor dem Marker
		}
		for _, tree := range baselineTrees() {
			if parts[i] == tree && i+1 < len(parts) {
				return strings.Join(parts[i:], "/")
			}
		}
	}
	return ""
}

// writeSums erzeugt SHA256SUMS nach MR-007 Setzung 2: GNU-Format (<hash>, zwei
// Leerzeichen, Pfad), Pfade relativ zu root, nach PFAD sortiert (LC_ALL=C =
// Byte-Ordnung, die Go-Strings ohnehin haben), SHA256SUMS selbst ausgenommen.
func writeSums(root string) error {
	type entry struct{ rel, hash string }
	var entries []entry
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() {
			return nil
		}
		rel, relErr := filepath.Rel(root, p)
		if relErr != nil {
			return relErr
		}
		rel = filepath.ToSlash(rel)
		if rel == sumsName {
			return nil
		}
		// GNU sha256sum ESCAPT Namen mit Backslash/Newline; der netzlose
		// Vollstaendigkeits-Check des Verifiers dekodiert das nicht und wuerde
		// falsch-positiv melden. Ehrlich abbrechen schlaegt still falsch.
		if strings.ContainsAny(rel, "\\\n") {
			return fmt.Errorf("pfad %q enthaelt Backslash/Newline — SHA256SUMS waere GNU-escapt und der Vollstaendigkeits-Check falsch-positiv (MR-007)", rel)
		}
		data, readErr := os.ReadFile(p)
		if readErr != nil {
			return fmt.Errorf("%s lesen: %w", rel, readErr)
		}
		entries = append(entries, entry{rel: rel, hash: hex.EncodeToString(sha256Sum(data))})
		return nil
	})
	if err != nil {
		return err
	}
	sort.Slice(entries, func(i, j int) bool { return entries[i].rel < entries[j].rel })
	var b strings.Builder
	for _, e := range entries {
		fmt.Fprintf(&b, "%s  %s\n", e.hash, e.rel)
	}
	if err := os.WriteFile(filepath.Join(root, sumsName), []byte(b.String()), 0o644); err != nil {
		return fmt.Errorf("%s schreiben: %w", sumsName, err)
	}
	return nil
}

func sha256Sum(data []byte) []byte {
	sum := sha256.Sum256(data)
	return sum[:]
}

// writeFile schreibt r nach dst (Verzeichnisse anlegend) mit der uebergebenen
// Datei-Mode. Von unpackTrees genutzt (frueher auch vom Skelett-Fetch in
// fetch.go, der mit slice-023 dem Generator wich).
func writeFile(dst string, r io.Reader, mode os.FileMode) error {
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(dst), err)
	}
	f, err := os.OpenFile(dst, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, mode)
	if err != nil {
		return fmt.Errorf("%s oeffnen: %w", dst, err)
	}
	defer func() { _ = f.Close() }()
	if _, err := io.Copy(f, r); err != nil {
		return fmt.Errorf("%s schreiben: %w", dst, err)
	}
	return nil
}

// readCapped liest bis zu limit bytes und meldet AssetTooLargeError, wenn der Body
// die Schranke UEBERSCHREITET (statt still abzuschneiden — ein abgeschnittenes
// Asset verfehlte nur den Pin und kaeme als SHA256Mismatch statt als das echte
// Problem "zu gross"). rc wird immer geschlossen.
func readCapped(rc io.ReadCloser, limit int64) ([]byte, error) {
	defer func() { _ = rc.Close() }()
	// limit+1 lesen: kommt EIN Byte mehr als die Schranke, ist der Body zu gross.
	data, err := io.ReadAll(io.LimitReader(rc, limit+1))
	if err != nil {
		return nil, err
	}
	if int64(len(data)) > limit {
		return nil, &AssetTooLargeError{Max: limit}
	}
	return data, nil
}
