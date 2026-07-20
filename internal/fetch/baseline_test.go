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
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data)); err != nil {
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
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data)); err != nil {
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

// TestBaseline_SumsVerifiableByCoreutils belegt, dass die erzeugte Datei von
// `sha256sum -c` gelesen werden kann — die Form ist kein Selbstzweck, das
// emittierte baseline-verify fuettert sie genau so.
func TestBaseline_SumsVerifiableByCoreutils(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	root := filepath.Join(dest, "v3.5.0")
	raw, err := os.ReadFile(filepath.Join(root, "SHA256SUMS"))
	if err != nil {
		t.Fatalf("SHA256SUMS lesen: %v", err)
	}
	for _, ln := range strings.Split(strings.TrimRight(string(raw), "\n"), "\n") {
		wantHash, rel, _ := strings.Cut(ln, "  ")
		content, readErr := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
		if readErr != nil {
			t.Fatalf("gelistete Datei %s fehlt: %v", rel, readErr)
		}
		got := sha256.Sum256(content)
		if hex.EncodeToString(got[:]) != wantHash {
			t.Errorf("%s: Hash in SHA256SUMS stimmt nicht mit dem Inhalt ueberein", rel)
		}
	}
}

// TestBaseline_SHA256Mismatch_NothingWritten ist der LH-QA-01/LH-QA-02-Kern:
// bricht der Pin, wird NICHT emittiert — und zwar gar nichts, auch kein Rest.
func TestBaseline_SHA256Mismatch_NothingWritten(t *testing.T) {
	data, _ := stdBundle(t)
	dest := t.TempDir()
	wrong := strings.Repeat("0", 64)
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", wrong, false, assetFetch(data))
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
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data))
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
		if err := fetch.Baseline(context.Background(), d, "v3.5.0", sum, false, assetFetch(data)); err != nil {
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

// TestBaseline_ExistingTag: ohne force wird eine vorhandene Baseline nicht
// ueberschrieben (LH-FA-01 Boundary-AC, wie bei Templates/DocGate).
func TestBaseline_ExistingTag(t *testing.T) {
	data, sum := stdBundle(t)
	dest := t.TempDir()
	existing := filepath.Join(dest, "v3.5.0")
	if err := os.MkdirAll(existing, 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data))
	if err == nil {
		t.Fatal("vorhandene Baseline wurde ueberschrieben")
	}
	if !strings.Contains(err.Error(), "--force") {
		t.Errorf("Fehlermeldung nennt den Ausweg --force nicht: %v", err)
	}
}

func TestBaseline_FetchError(t *testing.T) {
	failing := func(_ context.Context, _ string) (io.ReadCloser, error) {
		return nil, errors.New("netz weg")
	}
	dest := t.TempDir()
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", fetch.DefaultBaselineSHA256, false, failing)
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

// TestBaseline_ForceReplaces schliesst Review-Befund M1: --force trug ueber alle
// anderen Emit-Schritte, nur nicht ueber den Baseline-Schritt — und die Meldung
// empfahl genau das Flag, das der Aufrufer schon gesetzt hatte.
func TestBaseline_ForceReplaces(t *testing.T) {
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
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, true, assetFetch(data)); err != nil {
		t.Fatalf("Baseline mit force: %v", err)
	}
	assertContent(t, filepath.Join(root, "regelwerk", "README.md"), "index")
	// Der alte Stand ist ERSETZT, nicht gemischt — sonst listete SHA256SUMS
	// eine Datei, die der Verifier als ungelistet meldete.
	assertAbsent(t, filepath.Join(root, "regelwerk", "alt.md"))
}

// TestBaseline_TraversalEntriesEscapeNothing deckt Review-Befund M4 (Zip-Slip)
// als EIGENSCHAFT ab, nicht als Zweig-Abdeckung: der `!filepath.IsLocal`-Zweig in
// unpackTrees ist durch die Marker-Logik konstruktionsbedingt unerreichbar
// (path.Clean laeuft VOR dem Marker-Scan, danach ueberleben `..` nur als
// FUEHRENDE Segmente — vor denen steht kein Marker). Er bleibt als zweites Netz
// stehen; testbar ist, dass nichts aus dem Ziel ausbricht.
func TestBaseline_TraversalEntriesEscapeNothing(t *testing.T) {
	data, sum := fixtureZip(t, map[string]string{
		"lab/regelwerk/README.md":          "index",
		"lab/templates/AGENTS.template.md": "agents",
		"lab/regelwerk/../../evil.txt":     "ausbruch",
		"../regelwerk/evil2.md":            "ausbruch2",
		"/regelwerk/evil3.md":              "ausbruch3",
	})
	dest := t.TempDir()
	if err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data)); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	for _, outside := range []string{
		filepath.Join(dest, "evil.txt"),
		filepath.Join(dest, "..", "evil.txt"),
		filepath.Join(dest, "v3.5.0", "evil.txt"),
	} {
		assertAbsent(t, outside)
	}
	// Gegenprobe: was NACH dem Clean unter einem Marker liegt, kommt normal an —
	// der Schutz darf nicht einfach alles verwerfen.
	assertContent(t, filepath.Join(dest, "v3.5.0", "regelwerk", "README.md"), "index")
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
	err := fetch.Baseline(context.Background(), dest, "v3.5.0", sum, false, assetFetch(data))
	if err == nil {
		t.Fatal("Pfad mit Backslash wurde akzeptiert — SHA256SUMS waere GNU-escapt")
	}
	if !strings.Contains(err.Error(), "Backslash") {
		t.Errorf("Fehlermeldung nennt die Ursache nicht: %v", err)
	}
	assertEmptyDir(t, dest)
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
