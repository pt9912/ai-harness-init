package fetch_test

import (
	"archive/zip"
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// fixtureZip baut ein Bundle aus name→inhalt und liefert Bytes + deren sha256,
// damit der Pin im Test aus derselben Quelle stammt wie das Asset (kein Netz).
func fixtureZip(t *testing.T, entries map[string]string) ([]byte, string) {
	t.Helper()
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	names := make([]string, 0, len(entries))
	for n := range entries {
		names = append(names, n)
	}
	sort.Strings(names) // stabile Fixture -> stabiler Fixture-Hash
	for _, n := range names {
		w, err := zw.Create(n)
		if err != nil {
			t.Fatalf("zip Create %s: %v", n, err)
		}
		if _, err := w.Write([]byte(entries[n])); err != nil {
			t.Fatalf("zip Write %s: %v", n, err)
		}
	}
	if err := zw.Close(); err != nil {
		t.Fatalf("zip Close: %v", err)
	}
	data := buf.Bytes()
	sum := sha256.Sum256(data)
	return data, hex.EncodeToString(sum[:])
}

func assetFetch(data []byte) fetch.AssetFetch {
	return func(_ context.Context, _ string) (io.ReadCloser, error) {
		return io.NopCloser(bytes.NewReader(data)), nil
	}
}

// stdBundle: beide Baeume unter einem Top-Level-Prefix (belegt die Marker-Logik)
// plus eine Datei AUSSERHALB beider Baeume, die nicht mitkommen darf.
func stdBundle(t *testing.T) ([]byte, string) {
	return fixtureZip(t, map[string]string{
		"lab/regelwerk/README.md":                            "index",
		"lab/regelwerk/modul-05-planning-harness.md":         "modul5",
		"lab/templates/AGENTS.template.md":                   "agents",
		"lab/templates/docs/plan/planning/slice.template.md": "slice",
		"lab/README.md":                                      "bundle-readme",
	})
}

func TestBaseline_Extract(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	root := filepath.Join(dest, "v3.5.0")
	assertContent(t, filepath.Join(root, "regelwerk", "README.md"), "index")
	assertContent(t, filepath.Join(root, "templates", "AGENTS.template.md"), "agents")
	assertContent(t, filepath.Join(root, "templates", "docs", "plan", "planning", "slice.template.md"), "slice")
	// Der Prefix ist gestrippt und die Datei ausserhalb beider Baeume fehlt:
	assertAbsent(t, filepath.Join(root, "lab"))
	assertAbsent(t, filepath.Join(root, "README.md"))
	if _, err := os.Stat(filepath.Join(root, "SHA256SUMS")); err != nil {
		t.Errorf("SHA256SUMS fehlt: %v", err)
	}
}

// TestBaseline_SumsForm haelt MR-007 Setzung 2 fest: GNU-Format, Pfade relativ
// zu <tag>/, nach PFAD sortiert, SHA256SUMS selbst nicht gelistet. Die Sortier-
// Achse ist der Punkt — nach Hash sortiert waere die Datei genauso "sortiert",
// aber der Vollstaendigkeits-Vergleich des Verifiers vergleicht Pfad-Listen.
func TestBaseline_SumsForm(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	raw, err := os.ReadFile(filepath.Join(dest, "v3.5.0", "SHA256SUMS"))
	if err != nil {
		t.Fatalf("SHA256SUMS lesen: %v", err)
	}
	lines := strings.Split(strings.TrimRight(string(raw), "\n"), "\n")
	var paths []string
	for _, ln := range lines {
		h, p, ok := strings.Cut(ln, "  ")
		if !ok {
			t.Fatalf("Zeile ohne GNU-Trenner (zwei Leerzeichen): %q", ln)
		}
		if len(h) != 64 {
			t.Errorf("Hash-Laenge %d in %q, want 64", len(h), ln)
		}
		if p == "SHA256SUMS" {
			t.Error("SHA256SUMS listet sich selbst (kann sich nicht selbst hashen, MR-007 Setzung 2)")
		}
		paths = append(paths, p)
	}
	if !sort.StringsAreSorted(paths) {
		t.Errorf("Pfade nicht LC_ALL=C-sortiert: %v", paths)
	}
	want := []string{
		"regelwerk/README.md",
		"regelwerk/modul-05-planning-harness.md",
		"templates/AGENTS.template.md",
		"templates/docs/plan/planning/slice.template.md",
	}
	if strings.Join(paths, ",") != strings.Join(want, ",") {
		t.Errorf("gelistete Pfade = %v, want %v", paths, want)
	}
}

// TestBaseline_SumsVerifiableByCoreutils fuettert die von writeSums ERZEUGTE
// Datei an das echte `sha256sum -c` — genau so konsumiert sie das emittierte
// baseline-verify.
//
// Die Vorgaenger-Fassung trug denselben Namen, rechnete den Hash aber selbst mit
// crypto/sha256 nach und rief nie coreutils auf (Review-Befund slice-022a L1).
// Eine Formatabweichung (ein Trenner statt zwei Leerzeichen) waere gruen
// geblieben und haette das emittierte Skript rot gemacht. `sha256sum` liegt im
// gepinnten Test-Image; fehlt es, ist das ein Image-Bruch und kein Grund, still
// zu ueberspringen.
func TestBaseline_SumsVerifiableByCoreutils(t *testing.T) {
	bin, err := exec.LookPath("sha256sum")
	if err != nil {
		t.Fatalf("sha256sum nicht im Test-Image gefunden: %v", err)
	}
	data, sum := stdBundle(t)
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	root := filepath.Join(dest, "v3.5.0")

	cmd := exec.Command(bin, "-c", "SHA256SUMS")
	cmd.Dir = root
	if out, runErr := cmd.CombinedOutput(); runErr != nil {
		t.Fatalf("sha256sum -c auf der erzeugten SHA256SUMS: %v\n%s", runErr, out)
	}
	// Gegenprobe mit Zaehnen: eine manipulierte Datei MUSS coreutils rot machen —
	// sonst belegt der gruene Lauf oben nichts.
	if err := os.WriteFile(filepath.Join(root, "regelwerk", "README.md"), []byte("manipuliert"), 0o644); err != nil {
		t.Fatalf("manipulieren: %v", err)
	}
	cmd = exec.Command(bin, "-c", "SHA256SUMS")
	cmd.Dir = root
	if _, runErr := cmd.CombinedOutput(); runErr == nil {
		t.Error("sha256sum -c blieb nach Manipulation gruen — die Pruefung traegt nicht")
	}
}

// TestBaseline_SHA256Mismatch_NothingWritten ist der LH-QA-01/LH-QA-02-Kern:
// bricht der Pin, wird NICHT emittiert — und zwar gar nichts, auch kein Rest.
func TestBaseline_SHA256Mismatch_NothingWritten(t *testing.T) {
	data, _ := stdBundle(t)
	dest := t.TempDir()
	wrong := strings.Repeat("0", 64)
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", wrong, assetFetch(data))
	var mm *fetch.SHA256Mismatch
	if !errors.As(err, &mm) {
		t.Fatalf("erwartete *SHA256Mismatch, got %v", err)
	}
	if mm.Want != wrong || len(mm.Got) != 64 {
		t.Errorf("Mismatch traegt Want=%q Got=%q — beide Hashes gehoeren in die Meldung", mm.Want, mm.Got)
	}
	assertEmptyDir(t, dest)
}

// TestBaseline_IncompleteBundle: fehlt ein Baum, ist der Stand ungueltig —
// begruendet nicht emittieren statt halbe Baseline (LH-FA-09 Kein-Halluzinat-AC).
func TestBaseline_IncompleteBundle(t *testing.T) {
	data, sum := fixtureZip(t, map[string]string{"lab/regelwerk/README.md": "nur regelwerk"})
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data))
	if err == nil {
		t.Fatal("unvollstaendiges Bundle wurde akzeptiert")
	}
	if !strings.Contains(err.Error(), "templates") {
		t.Errorf("Fehlermeldung nennt den fehlenden Baum nicht: %v", err)
	}
	assertEmptyDir(t, dest)
}

// TestBaseline_Deterministic haelt LH-QA-02 fest: gleiche Version, gleiches
// Asset -> byte-identische Ablage, SHA256SUMS eingeschlossen.
func TestBaseline_Deterministic(t *testing.T) {
	data, sum := stdBundle(t)
	d1, d2 := t.TempDir(), t.TempDir()
	for _, d := range []string{d1, d2} {
		if err := fetch.Baseline(context.Background(), d, "v3.5.0", sum, assetFetch(data)); err != nil {
			t.Fatalf("Baseline nach %s: %v", d, err)
		}
	}
	for _, rel := range []string{"SHA256SUMS", "regelwerk/README.md", "templates/AGENTS.template.md"} {
		a := mustRead(t, filepath.Join(d1, "v3.5.0", filepath.FromSlash(rel)))
		b := mustRead(t, filepath.Join(d2, "v3.5.0", filepath.FromSlash(rel)))
		if !bytes.Equal(a, b) {
			t.Errorf("%s unterscheidet sich zwischen zwei Laeufen", rel)
		}
	}
}

// TestBaseline_ExistingTag_Convergent (slice-038): eine vorhandene Baseline ist
// KONVERGENT — sie wird durch die kanonische Fassung ERSETZT, kein Refuse (das Pre-Flight-
// Modell aus slice-025 ist gefallen). So heilt ein Re-Lauf Drift + Baseline-Bump.
// Rot-Gegenbeispiel: eine Mutation, die wieder refust, faerbt den Idempotenz-Test rot.
func TestBaseline_ExistingTag_Convergent(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	existing := filepath.Join(dest, "v3.5.0")
	if err := os.MkdirAll(existing, 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline (konvergent darf nicht refusen): %v", err)
	}
	// Die kanonische Baseline steht jetzt (regelwerk/README.md aus dem Bundle).
	assertContent(t, filepath.Join(existing, "regelwerk", "README.md"), "index")
}

func TestBaseline_FetchError(t *testing.T) {
	failing := func(_ context.Context, _ string) (io.ReadCloser, error) {
		return nil, errors.New("netz weg")
	}
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", fetch.DefaultBaselineSHA256, failing)
	if err == nil {
		t.Fatal("Fetch-Fehler wurde nicht propagiert")
	}
	assertEmptyDir(t, dest)
}

// TestDefaultBaselineSHA256_MatchesMakefile koppelt den eingebetteten Pin an
// BASELINE_ZIP_SHA256 (Makefile) — dieselbe Tier-1-Achse wie DefaultTag. Ohne
// sie bewegt eine Re-Baseline den Makefile-Pin und vergisst den Tool-Pin
// (MR-007 Zwei-Pin-Kopplung, hier fuer den Emitter).
func TestDefaultBaselineSHA256_MatchesMakefile(t *testing.T) {
	want := makeVar(t, filepath.Join("..", "..", "Makefile"), "BASELINE_ZIP_SHA256")
	if fetch.DefaultBaselineSHA256 != want {
		t.Errorf("fetch.DefaultBaselineSHA256 %q != Makefile BASELINE_ZIP_SHA256 %q (Drift bei Re-Baseline)", fetch.DefaultBaselineSHA256, want)
	}
}

// TestBaseline_Convergent_Replaces (slice-038; loest den frueheren ForceReplaces-Fall
// ab): eine vorhandene, NICHT-leere Baseline wird konvergent ERSETZT (Beiseite-Rename,
// nicht gemischt) — der alte Stand ist danach weg, der kanonische steht. Kein Refuse,
// kein --force noetig (das Flag ist mit slice-038 entfallen).
func TestBaseline_Convergent_Replaces(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	root := filepath.Join(dest, "v3.5.0")
	// Vorhandene, NICHT-leere Baseline: os.Rename allein scheitert daran.
	if err := os.MkdirAll(filepath.Join(root, "regelwerk"), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(filepath.Join(root, "regelwerk", "alt.md"), []byte("alt"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline (konvergent): %v", err)
	}
	assertContent(t, filepath.Join(root, "regelwerk", "README.md"), "index")
	// Der alte Stand ist ERSETZT, nicht gemischt — sonst listete SHA256SUMS
	// eine Datei, die der Verifier als ungelistet meldete.
	assertAbsent(t, filepath.Join(root, "regelwerk", "alt.md"))
	// Kein .baseline-alt-*-Rest: der Ersatz laeuft ueber ein Beiseite-Rename
	// (N1), und das Aufraeumen danach gehoert zum Erfolgspfad.
	assertNoTempResidue(t, dest)
}

// assertNoTempResidue belegt, dass weder das Entpack- noch das Beiseite-
// Verzeichnis liegen bleibt. Beide sind punkt-praefigiert und daher fuer den
// <tag>-Glob des Verifiers unsichtbar — ein Rest faellt sonst niemandem auf.
func assertNoTempResidue(t *testing.T, dest string) {
	t.Helper()
	entries, err := os.ReadDir(dest)
	if err != nil {
		t.Fatalf("lesen %s: %v", dest, err)
	}
	for _, e := range entries {
		if strings.HasPrefix(e.Name(), ".baseline-") {
			t.Errorf("Rest-Verzeichnis %s in %s (Temp oder Beiseite nicht aufgeraeumt)", e.Name(), dest)
		}
	}
}

// TestBaseline_NurErwarteteEintraegeLanden loest Review-Befund N2 ab. Die
// Vorgaenger-Fassung hiess "TraversalEntriesEscapeNothing" und pruefte nur die
// Abwesenheit von Pfaden AUSSERHALB des Ziels — sie war gruen, waehrend zwei
// ihrer eigenen Fixture-Eintraege (`../regelwerk/evil2.md`, `/regelwerk/evil3.md`)
// unbeobachtet IM Baum landeten und von der selbst erzeugten SHA256SUMS gedeckt
// wurden. "Bricht nicht aus" war die falsche Frage; die richtige ist "was genau
// kommt an".
//
// Deshalb assertiert dieser Test den Ist-Bestand VOLLSTAENDIG: was nicht in der
// Erwartung steht, darf nicht da sein.
func TestBaseline_NurErwarteteEintraegeLanden(t *testing.T) {
	data, sum := fixtureZip(t, map[string]string{
		// erlaubt: Marker an der Wurzel bzw. hinter EINEM Wrapper
		"lab/regelwerk/README.md":          "index",
		"lab/templates/AGENTS.template.md": "agents",
		// verworfen: Clean frisst den Marker
		"lab/regelwerk/../../evil.txt": "ausbruch",
		// verworfen: Traversal bzw. absoluter Pfad VOR dem Marker
		"../regelwerk/evil2.md": "ausbruch2",
		"/regelwerk/evil3.md":   "ausbruch3",
		// verworfen: sachfremder zweiter Marker-Zweig zu tief im Bundle
		"lab/docs/examples/regelwerk/fremd.md": "fremd",
	})
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	root := filepath.Join(dest, "v3.5.0")
	want := []string{"SHA256SUMS", "regelwerk/README.md", "templates/AGENTS.template.md"}
	var got []string
	if err := filepath.WalkDir(root, func(p string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		rel, relErr := filepath.Rel(root, p)
		if relErr != nil {
			return relErr
		}
		got = append(got, filepath.ToSlash(rel))
		return nil
	}); err != nil {
		t.Fatalf("Baum lesen: %v", err)
	}
	sort.Strings(got)
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("Ist-Bestand = %v\nwant %v\n(ein unerwarteter Eintrag ist still aufgenommen worden — N2)", got, want)
	}
	// Und die Pruefsummen decken genau diese zwei Dateien, nicht mehr.
	raw := mustRead(t, filepath.Join(root, "SHA256SUMS"))
	if n := len(strings.Split(strings.TrimRight(string(raw), "\n"), "\n")); n != 2 {
		t.Errorf("SHA256SUMS listet %d Dateien, want 2 — verworfene Eintraege duerfen nicht gedeckt werden", n)
	}
}

// TestBaseline_KollidierendeEintraegeRefused deckt Review-Befund N4 — der bis
// hierher NICHT belegt war, sondern nur aus dem Code hergeleitet (der Reviewer
// notierte ihn ausdruecklich als "verifizierbar, aber keine Fixture vorhanden").
// Diese Fixture ist der Beleg: zwei verschiedene ZIP-Namen, ein Ziel-Rel-Pfad.
//
// Warum Fehler und nicht Warnung: welcher Eintrag gewinnt, haengt allein an der
// ZIP-Reihenfolge. Das Ergebnis waere von der Asset-Ordnung abhaengig statt von
// seinem Inhalt — und die vendored Baseline deckt es danach mit ihren eigenen
// Pruefsummen. Ein mehrdeutiges Bundle ist kein Bundle, das man halb aufnimmt;
// dieselbe Linie wie beim unvollstaendigen Bundle und beim escapten Pfad.
func TestBaseline_KollidierendeEintraegeRefused(t *testing.T) {
	data, sum := fixtureZip(t, map[string]string{
		"lab/regelwerk/README.md":          "index",
		"lab/templates/AGENTS.template.md": "agents",
		// Beide erlaubt (Tiefe 1, sauberes Praefix), beide -> regelwerk/modul.md:
		"lab/regelwerk/modul.md":  "aus lab",
		"docs/regelwerk/modul.md": "aus docs",
	})
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data))
	if err == nil {
		t.Fatal("mehrdeutiges Bundle wurde akzeptiert — ein Eintrag hat den anderen still ueberschrieben")
	}
	// Die Meldung muss BEIDE Quell-Eintraege nennen, sonst sucht der Maintainer blind.
	for _, want := range []string{"lab/regelwerk/modul.md", "docs/regelwerk/modul.md", "regelwerk/modul.md"} {
		if !strings.Contains(err.Error(), want) {
			t.Errorf("Fehlermeldung nennt %q nicht: %v", want, err)
		}
	}
	assertEmptyDir(t, dest)
}

// TestBaseline_EscapedPathRefused deckt den zweiten Zweig aus M4: ein Pfad mit
// Backslash wuerde von GNU sha256sum ESCAPT geschrieben, was den Vollstaendigkeits-
// Check des Verifiers falsch-positiv machte. Lieber laut abbrechen (MR-007).
func TestBaseline_EscapedPathRefused(t *testing.T) {
	data, sum := fixtureZip(t, map[string]string{
		"lab/regelwerk/README.md":          "index",
		"lab/templates/AGENTS.template.md": "agents",
		"lab/regelwerk/a\\b.md":            "backslash",
	})
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, assetFetch(data))
	if err == nil {
		t.Fatal("Pfad mit Backslash wurde akzeptiert — SHA256SUMS waere GNU-escapt")
	}
	if !strings.Contains(err.Error(), "Backslash") {
		t.Errorf("Fehlermeldung nennt die Ursache nicht: %v", err)
	}
	assertEmptyDir(t, dest)
}

// TestBaseline_AssetTooLarge belegt die L4-Schranke: ein Body ueber
// maxBaselineBytes wird als *AssetTooLargeError abgewiesen, BEVOR der Pin greift —
// und es bleibt nichts liegen. Die 8 MiB+1 muessen > maxBaselineBytes sein; steigt
// der Cap, faellt dieser Test (dann Groesse UND Max-Erwartung hier nachziehen — die
// Kopplung ist Absicht). Rot-Gegenbeispiel (AGENTS 3.6): faellt die Schranke, kommt
// der Body durch und der Pin meldet stattdessen SHA256Mismatch.
// test/mutations/11-baseline-groessen-schranke.sh mutiert genau das.
func TestBaseline_AssetTooLarge(t *testing.T) {
	oversized := bytes.Repeat([]byte{0}, 8<<20+1)
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", strings.Repeat("0", 64), assetFetch(oversized))
	var tl *fetch.AssetTooLargeError
	if !errors.As(err, &tl) {
		t.Fatalf("erwartete *AssetTooLargeError, got %v", err)
	}
	if tl.Max != 8<<20 {
		t.Errorf("Max = %d, want %d (maxBaselineBytes)", tl.Max, 8<<20)
	}
	assertEmptyDir(t, dest) // die Schranke greift VOR jedem Schreiben
}

func mustRead(t *testing.T, path string) []byte {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	return data
}

// assertEmptyDir belegt "kein Teil-Emit": weder das <tag>-Verzeichnis noch ein
// liegengebliebenes Temp-Verzeichnis.
func assertEmptyDir(t *testing.T, dir string) {
	t.Helper()
	entries, err := os.ReadDir(dir)
	if err != nil {
		t.Fatalf("lesen %s: %v", dir, err)
	}
	if len(entries) != 0 {
		var names []string
		for _, e := range entries {
			names = append(names, e.Name())
		}
		t.Errorf("%s ist nicht leer: %v (Teil-Emit oder Temp-Rest)", dir, names)
	}
}
