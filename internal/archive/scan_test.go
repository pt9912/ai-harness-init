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

// TestSuchraumFiltertNurDieAusgenommenenPraefixe: der vendored Fremdtext und
// `.git` fallen heraus, JEDER andere uebergebene Pfad bleibt drin — auch der
// ohne `.md`. Sortiert und ohne Doppel, damit die Fund-Reihenfolge stabil ist.
func TestSuchraumFiltertNurDieAusgenommenenPraefixe(t *testing.T) {
	got := archive.Suchraum([]string{
		"README.md",
		"Makefile",
		".harness/baseline/v1/regelwerk/m.md",
		".git/COMMIT_EDITMSG",
		"docs/reviews/r.md",
		"test/mutations/132-x.sh",
		"README.md",
	})
	want := []string{"Makefile", "README.md", "docs/reviews/r.md", "test/mutations/132-x.sh"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Fatalf("Suchraum = %v, want %v", got, want)
	}
}

// baumMitReports legt zwei Review-Reports an, von denen einer den anderen
// verlinkt — der Fall, den der Haenger-Waechter faengt. Der dritte Rueckgabewert
// ist der Suchraum-Eingang, wie ihn der Aufrufer aus dem Index liefert.
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

	got, err := archive.Haenger(root, []string{ziel, verweiser}, []string{ziel}, []string{ziel})
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

// TestHaengerFindetVerweisAusNichtMarkdownDatei haelt die zweite Achse des
// Suchraums: gesucht wird in JEDER getrackten Datei ausser der Baseline, ohne
// Ruecksicht auf die Endung. Im Bestand tragen Shell-Hooks und -Helfer,
// Go-Kommentare, Mutations-Faelle und bats-Dateien Verweise auf Review-Reports;
// ein Suchraum nur aus `.md` liesse den Lauf durchgehen und das Rot erst nach dem
// Commit an `make docs-check` entstehen. Die vier Fixture-Namen sind je ein
// Vertreter dieser vier Klassen.
// Gegenbeispiel: test/mutations/238-archive-welle-go-suchraum-dateityp.sh.
func TestHaengerFindetVerweisAusNichtMarkdownDatei(t *testing.T) {
	root, ziel, _ := baumMitReports(t)
	ohneMd := []string{
		".claude/hooks/pretooluse-agent-guard.sh",
		"internal/span/response_test.go",
		"test/mutations/132-span-rolle-aus-argument.sh",
		"test/agent-guard.bats",
	}
	for _, f := range ohneMd {
		schreibe(t, filepath.Join(root, filepath.FromSlash(f)),
			"# siehe docs/reviews/2026-09-01-slice-100-r1.md\n")
	}

	got, err := archive.Haenger(root, append([]string{ziel}, ohneMd...), []string{ziel}, []string{ziel})
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != len(ohneMd) {
		t.Fatalf("Haenger = %v, want je einen Treffer aus %v", got, ohneMd)
	}
	for _, f := range ohneMd {
		gefunden := false
		for _, g := range got {
			if strings.HasPrefix(g, f+" -> ") {
				gefunden = true
			}
		}
		if !gefunden {
			t.Errorf("%s traegt einen lebenden Verweis, steht aber in keinem Haenger: %v", f, got)
		}
	}
}

// TestHaengerUebergehtVerschwindende ist die Umkehr-Probe: wer selbst
// verschwindet, traegt danach keinen lebenden Verweis mehr und ist kein Haenger.
func TestHaengerUebergehtVerschwindende(t *testing.T) {
	root, ziel, verweiser := baumMitReports(t)

	got, err := archive.Haenger(root, []string{ziel, verweiser}, []string{ziel}, []string{ziel, verweiser})
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 0 {
		t.Fatalf("Haenger = %v, want keinen — der Verweiser verschwindet selbst", got)
	}
}

// TestHaengerUebergehtFehlendeDatei: ein Pfad, den der Index fuehrt und der
// Arbeitsbaum nicht, ist kein Lesefehler, sondern uebersprungen.
func TestHaengerUebergehtFehlendeDatei(t *testing.T) {
	root, ziel, verweiser := baumMitReports(t)

	got, err := archive.Haenger(root,
		[]string{ziel, verweiser, "docs/plan/planning/done/nie-angelegt.md"},
		[]string{ziel}, []string{ziel})
	if err != nil {
		t.Fatalf("fehlender Pfad im Suchraum ist ein Fehler geworden: %v", err)
	}
	if len(got) != 1 {
		t.Fatalf("Haenger = %v, want genau einen Treffer aus %s", got, verweiser)
	}
}
