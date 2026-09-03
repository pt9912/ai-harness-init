package archive_test

import (
	"path/filepath"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

func TestZaehlePraefixAnDerWortgrenze(t *testing.T) {
	faelle := []struct {
		inhalt string
		want   int
	}{
		{"[a](done/slice-100-a.md) und [b](../done/slice-100-a.md)", 2},
		{"done/slice-100-a.md am Zeilenanfang", 1},
		{"[x](../../../docs/plan/planning/done/slice-100-a.md)", 1},
		{"nicht-done/slice-100-a.md", 0},
		{"[c](done/slice-100-anders.md)", 0},
	}
	for _, f := range faelle {
		if got := archive.ZaehlePraefix(f.inhalt, "slice-100-a.md"); got != f.want {
			t.Errorf("ZaehlePraefix(%q) = %d, want %d", f.inhalt, got, f.want)
		}
	}
}

func TestZaehleGeschwisterUndAufsteigendSindDisjunkt(t *testing.T) {
	inhalt := "[a](slice-100-a.md) · [b](../slice-100-a.md) · [c](done/slice-100-a.md)"
	if got := archive.ZaehleGeschwister(inhalt, "slice-100-a.md"); got != 1 {
		t.Errorf("ZaehleGeschwister = %d, want 1", got)
	}
	if got := archive.ZaehleAufsteigend(inhalt, "slice-100-a.md"); got != 1 {
		t.Errorf("ZaehleAufsteigend = %d, want 1", got)
	}
}

// TestVerweisFundDreiFormenInIhremSuchraum: jede Form wird genau dort gezaehlt,
// wo ihr Link-Ziel die bewegte Datei ueberhaupt aufloest — die praefixlose aus
// den flach in done/ liegenden Dateien, die aufsteigende aus done/<welle-x>/,
// die Praefix-Form ueberall.
func TestVerweisFundDreiFormenInIhremSuchraum(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(root, "docs", "plan", "adr", "0033-x.md"),
		"Siehe [slice-100](../planning/done/slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"Geliefert: [slice-100](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-09", "slice-090-x.md"),
		"Folge-Slice: [slice-100](../slice-100-a.md).\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "next", "slice-900-y.md"),
		"Geschwister im eigenen Verzeichnis: [x](slice-100-a.md).\n")

	funde, err := archive.VerweisFund(root, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]archive.Fund{}
	for _, f := range funde {
		got[f.Datei] = f
	}
	if f := got["docs/plan/adr/0033-x.md"]; f.Praefix != 1 || f.Summe() != 1 {
		t.Errorf("ADR: %+v, want genau 1 Praefix-Treffer", f)
	}
	if f := got["docs/plan/planning/done/welle-10-results.md"]; f.Geschwister != 1 || f.Summe() != 1 {
		t.Errorf("Ergebnisnotiz: %+v, want genau 1 geschwister-relativen Treffer", f)
	}
	if f := got["docs/plan/planning/done/welle-09/slice-090-x.md"]; f.Aufsteigend != 1 || f.Summe() != 1 {
		t.Errorf("Stub der Vorwelle: %+v, want genau 1 aufsteigenden Treffer", f)
	}
	if _, drin := got["docs/plan/planning/next/slice-900-y.md"]; drin {
		t.Error("praefixloses Ziel ausserhalb von done/ gezaehlt — es loest gegen next/ auf, nicht gegen done/")
	}
	if len(funde) != 3 {
		t.Fatalf("VerweisFund = %d Dateien, want 3", len(funde))
	}
}
