package archive_test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// schreibe legt eine Datei samt Verzeichnissen an — der gemeinsame Helfer aller
// Tests dieses Pakets.
func schreibe(t *testing.T, pfad, inhalt string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(pfad), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(pfad, []byte(inhalt), 0o600); err != nil {
		t.Fatal(err)
	}
}

// slicePfad ist der Ort einer flachen Slice-Datei im Planning-Layout.
func slicePfad(root, name string) string {
	return filepath.Join(root, "docs", "plan", "planning", "done", name)
}

// TestKlasseVonMitgliedNenntDieWelle haelt die erste Einsammel-Klasse: ein
// Slice, dessen Welle-Feld genau diese Welle nennt, ist Mitglied — in der
// Link-Form, in der blanken Form und in der Langform mit Titel-Suffix.
// Gegenbeispiel: test/mutations/234-archive-welle-go-klasse-mitglied.sh.
func TestKlasseVonMitgliedNenntDieWelle(t *testing.T) {
	faelle := []struct{ feld, welle string }{
		{"[welle-10](welle-10-re-baseline.md).", "welle-10"},
		{"welle-10.", "welle-10"},
		{"welle-05", "welle-05"},
		{"[welle-02-fetch-und-readme](welle-02-fetch-und-readme.md).", "welle-02"},
		{"[welle-09](../welle-09-modul-15.md) — die Tool-Ebene", "welle-09"},
	}
	for _, f := range faelle {
		if got := archive.KlasseVon(f.feld, f.welle); got != archive.Mitglied {
			t.Errorf("KlasseVon(%q, %q) = %q, want %q", f.feld, f.welle, got, archive.Mitglied)
		}
	}
}

// TestKlasseVonWellenlosOhneWelle haelt die zweite Klasse: das Feld sagt "ohne
// Welle" und der Slice wird mitgenommen, egal welche Einordnungs-Prosa dahinter
// steht. Gegenbeispiel: test/mutations/235-archive-welle-go-klasse-wellenlos.sh.
func TestKlasseVonWellenlosOhneWelle(t *testing.T) {
	for _, feld := range []string{
		"ohne Welle (Harness-Wartung).",
		"ohne Welle — der Schnitt-Test aus",
		"ohne Welle",
	} {
		if got := archive.KlasseVon(feld, "welle-10"); got != archive.Wellenlos {
			t.Errorf("KlasseVon(%q) = %q, want %q", feld, got, archive.Wellenlos)
		}
	}
}

// TestKlasseVonFremdBleibtLiegen haelt die dritte Klasse — die Umkehr-Probe: ein
// Slice mit ABWEICHENDER Welle und einer ganz ohne Angabe bleiben liegen. Die
// Ziffern-Grenze gehoert dazu: "welle-1" trifft "welle-14" nicht.
// Gegenbeispiel: test/mutations/236-archive-welle-go-klasse-fremd.sh.
func TestKlasseVonFremdBleibtLiegen(t *testing.T) {
	faelle := []struct{ feld, welle string }{
		{"[welle-14](welle-14-re-baseline.md).", "welle-10"},
		{"—", "welle-10"},
		{"", "welle-10"},
		{"[welle-14](welle-14-re-baseline.md).", "welle-1"},
		{"ohne Wellenbetrieb", "welle-10"},
	}
	for _, f := range faelle {
		if got := archive.KlasseVon(f.feld, f.welle); got != archive.Fremd {
			t.Errorf("KlasseVon(%q, %q) = %q, want %q", f.feld, f.welle, got, archive.Fremd)
		}
	}
}

func TestWelleFeldLiestErsteZeile(t *testing.T) {
	inhalt := "# Slice slice-100: X\n\n**Welle:** [welle-10](welle-10-re-baseline.md).\n\n**Welle:** welle-99.\n"
	if got := archive.WelleFeld(inhalt); got != "[welle-10](welle-10-re-baseline.md)." {
		t.Fatalf("WelleFeld = %q", got)
	}
	if got := archive.WelleFeld("# ohne Kopf-Feld\n"); got != "" {
		t.Fatalf("WelleFeld ohne Feld = %q, want leer", got)
	}
}

func TestSliceNummerTraegtDenReSchnittSuffix(t *testing.T) {
	faelle := map[string]string{
		"slice-170-titel.md":         "170",
		"slice-001a-cli-skeleton.md": "001a",
		"welle-10-re-baseline.md":    "",
		"2026-09-01-slice-170-r1.md": "",
	}
	for name, want := range faelle {
		if got := archive.SliceNummer(name); got != want {
			t.Errorf("SliceNummer(%q) = %q, want %q", name, got, want)
		}
	}
}

// TestReviewTrifftSuffixGrenze haelt die Grenze der Report-Zuordnung: "slice-001"
// trifft "slice-001a" NICHT. Ohne sie zoege die Archivierung der einen Haelfte
// eines Re-Schnitts die Reports der anderen mit.
func TestReviewTrifftSuffixGrenze(t *testing.T) {
	faelle := []struct {
		name, nummer string
		want         bool
	}{
		{"2026-09-01-slice-001-r1.md", "001", true},
		{"2026-09-01-slice-001a-r1.md", "001", false},
		{"2026-09-01-slice-001a-r1.md", "001a", true},
		{"2026-09-01-slice-0012-r1.md", "001", false},
		{"2026-09-01-slices-011-014-quer.md", "011", false},
	}
	for _, f := range faelle {
		if got := archive.ReviewTrifft(f.name, f.nummer); got != f.want {
			t.Errorf("ReviewTrifft(%q, %q) = %v, want %v", f.name, f.nummer, got, f.want)
		}
	}
}

// baumMitWelle legt einen synthetischen Planning-Baum an: ein Mitglied, ein
// wellenloser Slice, zwei fremde, Welle-Plan und Ergebnisnotiz.
func baumMitWelle(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	schreibe(t, slicePfad(root, "welle-10-re-baseline.md"), "# Welle welle-10: Re-Baseline\n")
	schreibe(t, slicePfad(root, "welle-10-results.md"), "# Ergebnis\n\n**Abschluss:** 2026-09-01\n")
	schreibe(t, slicePfad(root, "slice-100-a.md"), "# Slice slice-100: A\n\n**Welle:** [welle-10](welle-10-re-baseline.md).\n")
	schreibe(t, slicePfad(root, "slice-101-b.md"), "# Slice slice-101: B\n\n**Welle:** ohne Welle (Harness-Wartung).\n")
	schreibe(t, slicePfad(root, "slice-102-c.md"), "# Slice slice-102: C\n\n**Welle:** [welle-14](welle-14-x.md).\n")
	schreibe(t, slicePfad(root, "slice-103-d.md"), "# Slice slice-103: D\n\n**Welle:** —\n")
	return root
}

// TestEinsammelnDreiKlassen ist die Verdrahtungs-Probe: die Klassen-Regel wird
// nicht nachgebaut, sondern ueber Einsammeln gefahren — dieselbe Stelle, die der
// Vorschau-Lauf benutzt.
func TestEinsammelnDreiKlassen(t *testing.T) {
	root := baumMitWelle(t)
	b, err := archive.Einsammeln(root, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if len(b.Mitglieder) != 1 || filepath.Base(b.Mitglieder[0]) != "slice-100-a.md" {
		t.Errorf("Mitglieder = %v, want [slice-100-a.md]", b.Mitglieder)
	}
	if len(b.Wellenlose) != 1 || filepath.Base(b.Wellenlose[0]) != "slice-101-b.md" {
		t.Errorf("Wellenlose = %v, want [slice-101-b.md]", b.Wellenlose)
	}
	if len(b.Fremde) != 2 {
		t.Errorf("Fremde = %v, want 2", b.Fremde)
	}
	if len(b.Plaene) != 1 || filepath.Base(b.Plaene[0]) != "welle-10-re-baseline.md" {
		t.Errorf("Plaene = %v, want [welle-10-re-baseline.md]", b.Plaene)
	}
	if b.Ergebnis == "" {
		t.Error("Ergebnisnotiz nicht gefunden")
	}
	if len(b.Slices()) != 2 {
		t.Errorf("Slices() = %v, want 2", b.Slices())
	}
	if len(b.Bewegte()) != 3 {
		t.Errorf("Bewegte() = %v, want 3 (2 Slices + Welle-Plan)", b.Bewegte())
	}
}

// TestEinsammelnReviewsAnDerSuffixGrenze fuehrt die Suffix-Grenze ueber
// Einsammeln: der Report des Nachbarn mit Buchstaben-Suffix bleibt draussen.
func TestEinsammelnReviewsAnDerSuffixGrenze(t *testing.T) {
	root := baumMitWelle(t)
	schreibe(t, slicePfad(root, "slice-100a-e.md"), "# Slice slice-100a: E\n\n**Welle:** [welle-14](welle-14-x.md).\n")
	for _, n := range []string{
		"2026-09-01-slice-100-r1.md",
		"2026-09-02-slice-100-r2.md",
		"2026-09-01-slice-100a-r1.md",
		"2026-09-01-slice-999-fremd.md",
	} {
		schreibe(t, filepath.Join(root, "docs", "reviews", n), "x\n")
	}
	b, err := archive.Einsammeln(root, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if len(b.Reviews) != 2 {
		t.Fatalf("Reviews = %v, want 2 (nur slice-100, nicht slice-100a)", b.Reviews)
	}
	for _, r := range b.Reviews {
		if filepath.Base(r) == "2026-09-01-slice-100a-r1.md" {
			t.Errorf("Report des Nachbarn mit Suffix eingesammelt: %s", r)
		}
	}
}

// TestEinsammelnPlanAnDerZiffernGrenze haelt die dritte Zuordnungs-Stelle an
// derselben Grenze wie die zwei anderen: "welle-1" trifft die Dateien von
// "welle-10" und "welle-14" nicht. Ohne sie stuende die Ergebnisnotiz einer
// fremden Welle als Kandidat in der Sperre 'mehrdeutiger-plan'.
func TestEinsammelnPlanAnDerZiffernGrenze(t *testing.T) {
	root := t.TempDir()
	schreibe(t, slicePfad(root, "welle-1-erste.md"), "# Welle welle-1\n")
	schreibe(t, slicePfad(root, "welle-1-results.md"), "# Ergebnis\n")
	schreibe(t, slicePfad(root, "welle-10-re-baseline.md"), "# Welle welle-10\n")
	schreibe(t, slicePfad(root, "welle-10-results.md"), "# Ergebnis\n")
	schreibe(t, slicePfad(root, "welle-14-x.md"), "# Welle welle-14\n")

	b, err := archive.Einsammeln(root, "welle-1")
	if err != nil {
		t.Fatal(err)
	}
	if len(b.Plaene) != 1 || filepath.Base(b.Plaene[0]) != "welle-1-erste.md" {
		t.Fatalf("Plaene = %v, want nur [welle-1-erste.md]", b.Plaene)
	}
	if filepath.Base(b.Ergebnis) != "welle-1-results.md" {
		t.Fatalf("Ergebnis = %q, want welle-1-results.md", b.Ergebnis)
	}
}

// TestEinsammelnFindetUntergrenze belegt beide Richtungen des
// Untergrenzen-Merkmals: ohne ein bestehendes Archiv leer, mit einem gesetzt.
func TestEinsammelnFindetUntergrenze(t *testing.T) {
	root := baumMitWelle(t)
	b, err := archive.Einsammeln(root, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if b.Untergrenze != "" {
		t.Fatalf("Untergrenze = %q, want leer", b.Untergrenze)
	}
	schreibe(t, slicePfad(root, filepath.Join("welle-09", "archiv.zip")), "PK\n")
	b, err = archive.Einsammeln(root, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if b.Untergrenze == "" {
		t.Fatal("Untergrenze nicht gefunden, obwohl done/welle-09/archiv.zip liegt")
	}
}

// TestEinsammelnMeldetArchivierteWelle: liegt das Zielverzeichnis schon, ist die
// Welle archiviert.
func TestEinsammelnMeldetArchivierteWelle(t *testing.T) {
	root := baumMitWelle(t)
	schreibe(t, slicePfad(root, filepath.Join("welle-10", "archiv.zip")), "PK\n")
	b, err := archive.Einsammeln(root, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if !b.Archiviert {
		t.Fatal("done/welle-10/ liegt, Archiviert ist trotzdem false")
	}
}
