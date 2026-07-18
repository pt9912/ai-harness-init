// Package fetch holt Sprachskelette vom gepinnten Kurs-Tag (ADR-0001, Variante C)
// und extrahiert lab/example/<lang>/ aus dem Tag-Tarball. Der Fetcher ist
// injizierbar, damit die Extrakt-Logik ohne Netz (Fixture-Tarball) testbar ist;
// der echte Netz-Fetch ist ein Tier-2-Smoke (LH-QA-01 hält make gates offline).
//
// Scope slice-004a: nur holen + in den Staging-Bereich extrahieren. Der Merge in
// den Repo-Root (AGENTS.md/Makefile-Konflikt) ist slice-004b.
package fetch

import (
	"archive/tar"
	"compress/gzip"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// DefaultTag ist der per Default gepinnte Kurs-Tag (harness/conventions.md §Baseline,
// BASELINE_TAG; LH-QA-02). Per Env (COURSE_TAG) für bewussten Opt-in überschreibbar.
const DefaultTag = "v3.1.0"

const (
	courseTarballBase = "https://codeload.github.com/pt9912/ai-harness-course/tar.gz/refs/tags/"
	labExampleMarker  = "/lab/example/"
)

// UnknownLangError meldet eine nicht im Tag vorhandene Sprache samt der Liste der
// verfügbaren Skelette. Als Typ (kein Sentinel-Global), via errors.As unterscheidbar
// (Aufruf-Fehler → Exit 2, anders als ein Netz-/Extrakt-Fehler).
type UnknownLangError struct {
	Lang      string
	Available []string
}

func (e *UnknownLangError) Error() string {
	return fmt.Sprintf("unbekannte Sprache %q; verfügbar: %s", e.Lang, strings.Join(e.Available, ", "))
}

// TarballFetch liefert den gzip-Tar des Kurs-Repos am Tag. Injizierbar für Tests.
type TarballFetch func(ctx context.Context, tag string) (io.ReadCloser, error)

// DownloadTarball ist der Produktions-Fetcher: HTTP-GET des codeload-Tag-Tarballs.
func DownloadTarball(ctx context.Context, tag string) (io.ReadCloser, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, courseTarballBase+tag, nil)
	if err != nil {
		return nil, fmt.Errorf("tarball-request %s: %w", tag, err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("tarball-fetch %s: %w", tag, err)
	}
	if resp.StatusCode != http.StatusOK {
		_ = resp.Body.Close()
		return nil, fmt.Errorf("tarball-fetch %s: HTTP %d", tag, resp.StatusCode)
	}
	return resp.Body, nil
}

// Skeleton extrahiert lab/example/<lang>/ aus dem Tag-Tarball nach destDir (den
// lab/example/<lang>/-Präfix strippend). Eine unbekannte Sprache liefert einen
// *UnknownLangError mit der Liste der im Tarball vorhandenen Skelette.
func Skeleton(ctx context.Context, destDir, lang, tag string, fetch TarballFetch) error {
	rc, err := fetch(ctx, tag)
	if err != nil {
		return err
	}
	defer func() { _ = rc.Close() }()

	gz, err := gzip.NewReader(rc)
	if err != nil {
		return fmt.Errorf("gzip %s: %w", tag, err)
	}
	tr := tar.NewReader(gz)
	langs := map[string]bool{}
	written := 0
	for {
		hdr, err := tr.Next()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return fmt.Errorf("tar %s: %w", tag, err)
		}
		entryLang, rel := skeletonEntry(hdr.Name, lang)
		if entryLang != "" {
			langs[entryLang] = true
		}
		if rel == "" || hdr.Typeflag != tar.TypeReg || !filepath.IsLocal(rel) {
			continue // Sprach-Dir selbst, Nicht-Datei oder unsicherer Pfad (../)
		}
		if err := writeFile(filepath.Join(destDir, rel), tr, os.FileMode(hdr.Mode).Perm()); err != nil {
			return err
		}
		written++
	}
	if !langs[lang] {
		return unknownLangError(lang, langs)
	}
	if written == 0 {
		return fmt.Errorf("skelett %q am Tag %s: keine Dateien extrahiert", lang, tag)
	}
	return nil
}

// skeletonEntry zerlegt einen Tar-Pfad an `/lab/example/`: liefert die Sprache und
// (nur wenn sie lang ist und eine Datei referenziert) den Rel-Pfad unter der Sprache.
func skeletonEntry(name, lang string) (entryLang, rel string) {
	i := strings.Index(name, labExampleMarker)
	if i < 0 {
		return "", ""
	}
	sub := name[i+len(labExampleMarker):] // "<L>/rest…"
	parts := strings.SplitN(sub, "/", 2)
	entryLang = parts[0]
	if entryLang == "" || entryLang != lang || len(parts) < 2 {
		return entryLang, ""
	}
	return entryLang, parts[1]
}

// writeFile schreibt r nach dst (Verzeichnisse anlegend), mit der Tar-Dateimode.
func writeFile(dst string, r io.Reader, mode os.FileMode) error {
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(dst), err)
	}
	f, err := os.OpenFile(dst, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, mode)
	if err != nil {
		return fmt.Errorf("%s öffnen: %w", dst, err)
	}
	defer func() { _ = f.Close() }()
	if _, err := io.Copy(f, r); err != nil {
		return fmt.Errorf("%s schreiben: %w", dst, err)
	}
	return nil
}

func unknownLangError(lang string, langs map[string]bool) error {
	available := make([]string, 0, len(langs))
	for l := range langs {
		available = append(available, l)
	}
	sort.Strings(available)
	return &UnknownLangError{Lang: lang, Available: available}
}
