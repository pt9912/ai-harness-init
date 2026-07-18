package fetch_test

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// fixtureFetch baut aus name→inhalt einen gzip-Tar und liefert einen Fetcher, der
// bei jedem Aufruf einen frischen Reader darüber gibt (kein Netz).
func fixtureFetch(t *testing.T, entries map[string]string) fetch.TarballFetch {
	t.Helper()
	var buf bytes.Buffer
	gz := gzip.NewWriter(&buf)
	tw := tar.NewWriter(gz)
	for name, content := range entries {
		hdr := &tar.Header{Name: name, Mode: 0o644, Size: int64(len(content)), Typeflag: tar.TypeReg}
		if err := tw.WriteHeader(hdr); err != nil {
			t.Fatalf("WriteHeader %s: %v", name, err)
		}
		if _, err := tw.Write([]byte(content)); err != nil {
			t.Fatalf("Write %s: %v", name, err)
		}
	}
	if err := tw.Close(); err != nil {
		t.Fatalf("tar Close: %v", err)
	}
	if err := gz.Close(); err != nil {
		t.Fatalf("gzip Close: %v", err)
	}
	data := buf.Bytes()
	return func(_ context.Context, _ string) (io.ReadCloser, error) {
		return io.NopCloser(bytes.NewReader(data)), nil
	}
}

// stdFixture: go- und python-Skelett, dazu ein Top-README (kein lab/example) und
// ein Traversal-Eintrag (muss abgewiesen werden).
func stdFixture(t *testing.T) fetch.TarballFetch {
	return fixtureFetch(t, map[string]string{
		"ai-harness-course-3.1.0/lab/example/go/Makefile":     "go-makefile",
		"ai-harness-course-3.1.0/lab/example/go/cmd/main.go":  "package main",
		"ai-harness-course-3.1.0/lab/example/python/Makefile": "py-makefile",
		"ai-harness-course-3.1.0/README.md":                   "top",
		"ai-harness-course-3.1.0/lab/example/go/../evil.txt":  "traversal",
		// stray file + Nicht-Skelett-Dir DIREKT unter lab/example/ (wie im echten Repo):
		// duerfen NICHT in der Unknown-Lang-Liste erscheinen (Review-R1/L1).
		"ai-harness-course-3.1.0/lab/example/AGENTS.md":      "stray",
		"ai-harness-course-3.1.0/lab/example/docs/README.md": "nicht-Skelett",
	})
}

func TestSkeleton_Extract(t *testing.T) {
	dir := t.TempDir()
	if err := fetch.Skeleton(context.Background(), dir, "go", "v3.1.0", stdFixture(t)); err != nil {
		t.Fatalf("Skeleton: %v", err)
	}
	// lab/example/go/-Präfix gestrippt; nur go-Dateien:
	assertContent(t, filepath.Join(dir, "Makefile"), "go-makefile")
	assertContent(t, filepath.Join(dir, "cmd", "main.go"), "package main")
	// python (andere Sprache) und der Traversal-Eintrag NICHT geschrieben:
	assertAbsent(t, filepath.Join(dir, "..", "evil.txt"))
}

func TestSkeleton_UnknownLang(t *testing.T) {
	dir := t.TempDir()
	err := fetch.Skeleton(context.Background(), dir, "rust", "v3.1.0", stdFixture(t))
	var ule *fetch.UnknownLangError
	if !errors.As(err, &ule) {
		t.Fatalf("erwartete *UnknownLangError, got %v", err)
	}
	if ule.Lang != "rust" {
		t.Errorf("Lang = %q, want rust", ule.Lang)
	}
	if got := strings.Join(ule.Available, ","); got != "go,python" {
		t.Errorf("Available = %q, want go,python (sortiert, aus dem Tarball)", got)
	}
}

// TestSkeleton_Deterministic hält LH-QA-02 fest: zwei Läufe, gleicher Tarball →
// identische Ausgabe.
func TestSkeleton_Deterministic(t *testing.T) {
	f := stdFixture(t)
	d1, d2 := t.TempDir(), t.TempDir()
	if err := fetch.Skeleton(context.Background(), d1, "go", "v3.1.0", f); err != nil {
		t.Fatalf("Lauf 1: %v", err)
	}
	if err := fetch.Skeleton(context.Background(), d2, "go", "v3.1.0", f); err != nil {
		t.Fatalf("Lauf 2: %v", err)
	}
	for _, rel := range []string{"Makefile", filepath.Join("cmd", "main.go")} {
		a, err := os.ReadFile(filepath.Join(d1, rel))
		if err != nil {
			t.Fatalf("lesen d1/%s: %v", rel, err)
		}
		b, err := os.ReadFile(filepath.Join(d2, rel))
		if err != nil {
			t.Fatalf("lesen d2/%s: %v", rel, err)
		}
		if !bytes.Equal(a, b) {
			t.Errorf("%s unterscheidet sich zwischen zwei Läufen", rel)
		}
	}
}

func TestSkeleton_FetchError(t *testing.T) {
	failing := func(_ context.Context, _ string) (io.ReadCloser, error) {
		return nil, errors.New("netz weg")
	}
	err := fetch.Skeleton(context.Background(), t.TempDir(), "go", "v3.1.0", failing)
	if err == nil {
		t.Fatal("Fetch-Fehler wurde nicht propagiert")
	}
	var ule *fetch.UnknownLangError
	if errors.As(err, &ule) {
		t.Error("Fetch-Fehler faelschlich als UnknownLangError klassifiziert")
	}
}

// TestDefaultTag_MatchesBaseline koppelt fetch.DefaultTag an BASELINE_TAG (Makefile),
// die EINZIGE Tag-Quelle (MR-007) — sonst driftet der Skelett-Tag bei einem Re-Baseline
// von der vendored Baseline (Review-M1, LH-QA-02).
func TestDefaultTag_MatchesBaseline(t *testing.T) {
	baseline := makeVar(t, filepath.Join("..", "..", "Makefile"), "BASELINE_TAG")
	if fetch.DefaultTag != baseline {
		t.Errorf("fetch.DefaultTag %q != Makefile BASELINE_TAG %q (Drift bei Re-Baseline)", fetch.DefaultTag, baseline)
	}
}

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
