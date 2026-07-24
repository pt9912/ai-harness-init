package gen_test

import (
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genGoArch generiert das go-Skelett fuer eine Architektur in ein frisches Temp-Verzeichnis.
func genGoArch(t *testing.T, arch string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "go", gen.DefaultGoVersion, arch); err != nil {
		t.Fatalf("GenerateArch(go, %q): %v", arch, err)
	}
	return dir
}

// TestGenerate_GoHexsliceProfile_FileSet (slice-045a, ADR-0009): --arch hexslice erzeugt
// GENAU die kanonischen hexSlice-Rollen-Dateien (domain/application/ports/adapters +
// Composition Root) PLUS die arch-invariante Bau-Gerueestung — nicht mehr, nicht weniger.
// Die Mutation "eine Schicht-Datei aus goRole entfernen" faerbt diesen Test rot.
func TestGenerate_GoHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genGoArch(t, "hexslice"))
	want := []string{
		".golangci.yml",
		"Dockerfile",
		"cmd/app/main.go",
		"go.mod",
		"internal/adapters/inbound/cli/example/cli.go",
		"internal/adapters/outbound/memory/example/repository.go",
		"internal/adapters/outbound/notify/stdout.go",
		"internal/hexagon/application/example/greet/command.go",
		"internal/hexagon/application/example/greet/handler.go",
		"internal/hexagon/application/example/greet/handler_test.go",
		"internal/hexagon/application/example/greet/ports/notifier.go",
		"internal/hexagon/application/example/greet/result.go",
		"internal/hexagon/application/example/greet/validator.go",
		"internal/hexagon/application/example/ports/greeting_repository.go",
		"internal/hexagon/domain/example/greeting.go",
		"internal/hexagon/domain/example/greeting_test.go",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestGenerate_GoHexslice_Compiles ist der Renderer-Compile-Beleg (slice-045a): das
// gerenderte hexSlice-Skelett muss uebersetzen UND seine Tests bestehen — die STRING-
// Konstanten des Generators sind sonst ungeprueft (die Repo-Gates linten sie nicht, sie
// sind nur Daten). Netzlos (nur Standardbibliothek, keine externen Module). Ohne
// go-Toolchain (host-loser Kontext) uebersprungen; im Docker-test-Stage laeuft er real.
// Der volle Gate-/Lint-/CLI-Nachweis end-to-end folgt in slice-045b via full-smoke.
func TestGenerate_GoHexslice_Compiles(t *testing.T) {
	if _, err := exec.LookPath("go"); err != nil {
		t.Skip("go-Toolchain nicht verfuegbar")
	}
	dir := genGoArch(t, "hexslice")
	cmd := exec.Command("go", "test", "./...")
	cmd.Dir = dir
	cmd.Env = goBuildEnv()
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("go test des hexSlice-Skeletts schlug fehl: %v\n%s", err, out)
	}
}

// goBuildEnv liefert das Prozess-Env fuer den nested go-Lauf: GOFLAGS auf -buildvcs=false
// gesetzt (das Temp-Verzeichnis ist kein git-Repo -> sonst VCS-Stamp-Fehler), sonst geerbt
// (GOMODCACHE/GOCACHE aus dem Container).
func goBuildEnv() []string {
	env := make([]string, 0, len(os.Environ())+1)
	for _, kv := range os.Environ() {
		if strings.HasPrefix(kv, "GOFLAGS=") {
			continue
		}
		env = append(env, kv)
	}
	return append(env, "GOFLAGS=-buildvcs=false")
}

// TestGenerateArch_UnknownArch (slice-045a): eine Architektur ohne Layout -> *UnknownArchError
// mit sortierter Liste — der Generator schreibt NICHT still ein Gerueestung-only-Skelett.
// slice-045b haengt daran die `--arch`-CLI-Validierung (Exit 2).
func TestGenerateArch_UnknownArch(t *testing.T) {
	err := gen.GenerateArch(t.TempDir(), "go", gen.DefaultGoVersion, "onion")
	var uae *gen.UnknownArchError
	if !errors.As(err, &uae) {
		t.Fatalf("erwartete *UnknownArchError, got %v", err)
	}
	if uae.Arch != "onion" {
		t.Errorf("Arch = %q, want onion", uae.Arch)
	}
	if strings.Join(uae.Available, ",") != "flat,hexslice" {
		t.Errorf("Available = %v, want [flat hexslice] (sortiert)", uae.Available)
	}
}

// TestGenerate_FlatUnchangedByArch (slice-045a, LH-QA-02): die additive hexslice-Erweiterung
// darf das FLACHE Skelett nicht beruehren — GenerateArch(…, "flat") liefert byte-identisch
// denselben Datei-Satz und -Inhalt wie das bestehende Generate(…). Der Anker dafuer, dass
// slice-045a keinen flat-Content-Konstant angefasst hat.
func TestGenerate_FlatUnchangedByArch(t *testing.T) {
	flatArch := genGoArch(t, "flat")
	legacy := t.TempDir()
	if err := gen.Generate(legacy, "go", gen.DefaultGoVersion); err != nil {
		t.Fatalf("Generate(go): %v", err)
	}
	rels := walkRel(t, legacy)
	if strings.Join(walkRel(t, flatArch), ",") != strings.Join(rels, ",") {
		t.Fatal("GenerateArch(flat) und Generate erzeugen verschiedene Datei-Saetze")
	}
	for _, rel := range rels {
		a := mustRead(t, filepath.Join(flatArch, filepath.FromSlash(rel)))
		b := mustRead(t, filepath.Join(legacy, filepath.FromSlash(rel)))
		if a != b {
			t.Errorf("%s unterscheidet sich zwischen GenerateArch(flat) und Generate", rel)
		}
	}
}

// TestSupportedArchs (slice-045a): sortiert und enthaelt flat + hexslice.
func TestSupportedArchs(t *testing.T) {
	archs := gen.SupportedArchs()
	if !sort.StringsAreSorted(archs) {
		t.Errorf("SupportedArchs nicht sortiert: %v", archs)
	}
	if strings.Join(archs, ",") != "flat,hexslice" {
		t.Errorf("SupportedArchs = %v, want [flat hexslice]", archs)
	}
}
