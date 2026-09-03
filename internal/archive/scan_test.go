package archive_test

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

func TestAusgenommenTrifftPraefixUndVerzeichnis(t *testing.T) {
	faelle := map[string]bool{
		".harness/baseline/v5.18.0/regelwerk/x.md": true,
		".harness/baseline":                        true,
		".harness/state/spans/x.md":                false,
		"docs/reviews/2026-09-01-slice-100-r1.md":  false,
		"docs/plan/planning/done/slice-100-a.md":   false,
	}
	for rel, want := range faelle {
		if got := archive.Ausgenommen(rel); got != want {
			t.Errorf("Ausgenommen(%q) = %v, want %v", rel, got, want)
		}
	}
}

// TestMarkdownDateienUeberspringtBaseline: der vendored Fremdtext liegt
// ausserhalb des Suchraums, alles andere darin.
func TestMarkdownDateienUeberspringtBaseline(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "docs", "reviews", "r.md"), "x\n")
	schreibe(t, filepath.Join(root, ".harness", "baseline", "v1", "regelwerk", "m.md"), "x\n")
	schreibe(t, filepath.Join(root, "README.md"), "x\n")
	schreibe(t, filepath.Join(root, "Makefile"), "x\n")

	got, err := archive.MarkdownDateien(root)
	if err != nil {
		t.Fatal(err)
	}
	want := []string{"README.md", "docs/reviews/r.md"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Fatalf("MarkdownDateien = %v, want %v", got, want)
	}
}

// baumMitReports legt zwei Review-Reports an, von denen einer den anderen
// verlinkt — der Fall, den der Haenger-Waechter faengt.
func baumMitReports(t *testing.T) (root, ziel, verweiser string) {
	t.Helper()
	root = t.TempDir()
	ziel = "docs/reviews/2026-09-01-slice-100-r1.md"
	verweiser = "docs/reviews/2026-09-02-slice-900-r1.md"
	schreibe(t, filepath.Join(root, filepath.FromSlash(ziel)), "# Report zu slice-100\n")
	schreibe(t, filepath.Join(root, filepath.FromSlash(verweiser)),
		"# Report zu slice-900\n\nSiehe [Vorrunde](2026-09-01-slice-100-r1.md).\n")
	return root, ziel, verweiser
}

// TestHaengerFindetVerweisAusReviewReport ist ADR-0033 Abnahme-Kriterium 1: ein
// Report, der BLEIBT, verlinkt einen, der ins Archiv geht — der Waechter muss
// ihn melden. Das ist kein Randfall, sondern die Klasse, die den Suchraum
// bestimmt: Reports verlinken einander quer ueber Wellen-Grenzen.
// Gegenbeispiel: test/mutations/233-archive-welle-go-haenger-suchraum.sh nimmt
// docs/reviews/** aus dem Suchraum, dann faellt dieser Test.
func TestHaengerFindetVerweisAusReviewReport(t *testing.T) {
	root, ziel, verweiser := baumMitReports(t)

	got, err := archive.Haenger(root, []string{ziel}, []string{ziel})
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 {
		t.Fatalf("Haenger = %v, want genau einen Treffer aus %s", got, verweiser)
	}
	if !strings.Contains(got[0], verweiser) || !strings.Contains(got[0], ziel) {
		t.Fatalf("Haenger-Zeile nennt nicht beide Dateien: %q", got[0])
	}
}

// TestHaengerUebergehtVerschwindende ist die Umkehr-Probe: wer selbst
// verschwindet, traegt danach keinen lebenden Verweis mehr und ist kein Haenger.
func TestHaengerUebergehtVerschwindende(t *testing.T) {
	root, ziel, verweiser := baumMitReports(t)

	got, err := archive.Haenger(root, []string{ziel}, []string{ziel, verweiser})
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 0 {
		t.Fatalf("Haenger = %v, want keinen — der Verweiser verschwindet selbst", got)
	}
}
