package fetch_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// TestDefaultTag_MatchesBaseline koppelt fetch.DefaultTag an BASELINE_TAG (Makefile),
// die EINZIGE Tag-Quelle (MR-007) — sonst driftet der Baseline-Tag bei einem
// Re-Baseline von der vendored Baseline (LH-QA-02).
func TestDefaultTag_MatchesBaseline(t *testing.T) {
	baseline := makeVar(t, filepath.Join("..", "..", "Makefile"), "BASELINE_TAG")
	if fetch.DefaultTag != baseline {
		t.Errorf("fetch.DefaultTag %q != Makefile BASELINE_TAG %q (Drift bei Re-Baseline)", fetch.DefaultTag, baseline)
	}
}

// makeVar liest ein `NAME ?= wert`-Makefile-Var — geteilter Helfer fuer die
// Pin-Kopplungstests (auch baseline_test.go).
func makeVar(t *testing.T, path, name string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	prefix := name + " ?= "
	for _, line := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(line, prefix) {
			return strings.TrimSpace(strings.TrimPrefix(line, prefix))
		}
	}
	t.Fatalf("%s nicht in %s gefunden", name, path)
	return ""
}

func assertContent(t *testing.T, path, want string) {
	t.Helper()
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	if string(got) != want {
		t.Errorf("%s = %q, want %q", path, string(got), want)
	}
}

func assertAbsent(t *testing.T, path string) {
	t.Helper()
	if _, err := os.Stat(path); err == nil {
		t.Errorf("%s existiert, sollte aber nicht (fremde Sprache / unsicherer Eintrag)", path)
	}
}
