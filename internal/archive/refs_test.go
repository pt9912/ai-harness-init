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
	// Die zwei relativen Formen tragen zusaetzlich eine Dateityp-Achse: sie sind
	// Markdown-Link-Ziele und loesen ausserhalb einer Markdown-Datei gegen nichts
	// auf. Beide Nicht-Markdown-Dateien liegen IM Suchraum ihrer Form und duerfen
	// trotzdem keinen Treffer ergeben.
	schreibe(t, filepath.Join(done, "notiz.txt"),
		"Kein Markdown: [x](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-09", "notiz.txt"),
		"Kein Markdown: [x](../slice-100-a.md).\n")

	funde, err := archive.VerweisFund(root, []string{
		"docs/plan/adr/0033-x.md",
		"docs/plan/planning/done/welle-10-results.md",
		"docs/plan/planning/done/welle-09/slice-090-x.md",
		"docs/plan/planning/next/slice-900-y.md",
		"docs/plan/planning/done/notiz.txt",
		"docs/plan/planning/done/welle-09/notiz.txt",
	}, []string{"slice-100-a.md"})
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
	for _, ohneMd := range []string{
		"docs/plan/planning/done/notiz.txt",
		"docs/plan/planning/done/welle-09/notiz.txt",
	} {
		if _, drin := got[ohneMd]; drin {
			t.Errorf("relative Link-Form in %s gezaehlt — ausserhalb einer Markdown-Datei loest sie gegen nichts auf", ohneMd)
		}
	}
	if len(funde) != 3 {
		t.Fatalf("VerweisFund = %d Dateien, want 3", len(funde))
	}
}

// TestVerweisFundPraefixAusNichtMarkdownDatei: die Praefix-Form ankert am
// Literal "done/" und gilt in jedem Dateityp — der schreibende Traeger zieht sie
// mit `git grep` ohne Endungs-Filter nach und stagt die getroffene Datei in
// seinen Inhalts-Commit. Zwei Dateien des Bestands stehen fuer die Klasse:
// `Dockerfile`, aus dem `make test`, `make lint` und `make build` ihre Stages
// ziehen, und eine bats-Datei. Nennt die Vorschau sie nicht, ist ihr
// Blast-Radius kleiner als das, was der Lauf anfasst.
// Gegenbeispiel: test/mutations/238-archive-welle-go-suchraum-dateityp.sh.
// Die Fixture-Namen sind ERFUNDEN, obwohl der Bestand echte traegt. Ein echter
// Name in dieser Datei stuende im Blast-Radius des naechsten Laufs, und der
// schreibende Traeger zoege ihn nach — der Fall risse sich damit selbst um.
func TestVerweisFundPraefixAusNichtMarkdownDatei(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "Dockerfile"),
		"# Begruendung: docs/plan/planning/done/slice-900-kompilat-cache.md\n")
	schreibe(t, filepath.Join(root, "test", "full-smoke-ausgang.bats"),
		"# siehe done/slice-900-kompilat-cache.md\n")

	funde, err := archive.VerweisFund(root,
		[]string{"Dockerfile", "test/full-smoke-ausgang.bats"},
		[]string{"slice-900-kompilat-cache.md"})
	if err != nil {
		t.Fatal(err)
	}
	if len(funde) != 2 {
		t.Fatalf("VerweisFund = %v, want beide Dateien ohne .md-Endung", funde)
	}
	for _, f := range funde {
		if f.Praefix != 1 || f.Summe() != 1 {
			t.Errorf("%+v, want genau 1 Praefix-Treffer", f)
		}
	}
}

// TestVerweisFundUebergehtDenEigenenUmzugsgegenstand: die praefixlose Form zaehlt
// nicht in einer Datei, die dieser Lauf selbst mitnimmt. Zwei Mitglieder
// derselben Welle, die einander geschwister-relativ verlinken, wandern gemeinsam
// nach done/<welle-id>/; ihre Links bleiben gueltig, und der schreibende Traeger
// fasst sie nicht an. Wer sie zaehlt, meldet einen zu grossen Blast-Radius.
func TestVerweisFundUebergehtDenEigenenUmzugsgegenstand(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-100-a.md"),
		"Nachbar: [slice-101](slice-101-b.md).\n")
	schreibe(t, filepath.Join(done, "slice-101-b.md"),
		"Vorlaeufer: [slice-100](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"Geliefert: [slice-100](slice-100-a.md) und [slice-101](slice-101-b.md).\n")

	funde, err := archive.VerweisFund(root, []string{
		"docs/plan/planning/done/slice-100-a.md",
		"docs/plan/planning/done/slice-101-b.md",
		"docs/plan/planning/done/welle-10-results.md",
	}, []string{"slice-100-a.md", "slice-101-b.md"})
	if err != nil {
		t.Fatal(err)
	}
	if len(funde) != 1 || funde[0].Datei != "docs/plan/planning/done/welle-10-results.md" {
		t.Fatalf("VerweisFund = %+v, want nur die bleibende Ergebnisnotiz", funde)
	}
	if funde[0].Geschwister != 2 {
		t.Fatalf("Ergebnisnotiz = %+v, want 2 geschwister-relative Fundstellen", funde[0])
	}
}
