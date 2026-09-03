package archive_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// kennungen sammelt die Sperren-Kennungen eines Berichts.
func kennungen(b archive.Bericht) []string {
	out := make([]string, 0, len(b.Sperren))
	for _, s := range b.Sperren {
		out = append(out, s.Kennung)
	}
	return out
}

// hatSperre sagt, ob eine Kennung im Bericht steht.
func hatSperre(b archive.Bericht, kennung string) bool {
	for _, s := range b.Sperren {
		if s.Kennung == kennung {
			return true
		}
	}
	return false
}

// vollstaendigerBaum traegt alles, was ein schreibender Lauf braucht: Welle-Plan,
// Ergebnisnotiz, ein Mitglied und eine bestehende Untergrenze.
func vollstaendigerBaum(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "welle-10-re-baseline.md"), "# Welle welle-10: Re-Baseline\n")
	schreibe(t, filepath.Join(done, "welle-10-results.md"), "# Ergebnis\n\n**Abschluss:** 2026-09-01\n")
	schreibe(t, filepath.Join(done, "slice-100-a.md"), "# Slice slice-100: A\n\n**Welle:** welle-10.\n")
	schreibe(t, filepath.Join(done, "welle-09", "archiv.zip"), "PK\n")
	return root
}

// indexVon steht fuer den `git ls-files`-Aufruf, den der Traeger vor
// archive.Vorschau fuehrt: jeder Pfad des Baums, ohne Dateityp-Achse. Ueber einem
// synthetischen Verzeichnis ist die Aufzaehlung der Index.
func indexVon(t *testing.T, root string) []string {
	t.Helper()
	var out []string
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		rel, relErr := filepath.Rel(root, p)
		if relErr != nil {
			return relErr
		}
		out = append(out, filepath.ToSlash(rel))
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	return out
}

// vorschauVon fuehrt die Vorschau ueber einem synthetischen Baum mit dem
// vollstaendigen Suchraum dieses Baums.
func vorschauVon(t *testing.T, root, welle, porcelain string) archive.Bericht {
	t.Helper()
	b, err := archive.Vorschau(root, welle, porcelain, indexVon(t, root))
	if err != nil {
		t.Fatal(err)
	}
	return b
}

// TestVorschauOhneSperreLaeuftDurch: ein vollstaendiger Baum mit sauberem
// Arbeitsbaum traegt keine Sperre — die Umkehr-Probe zu allen Sperren-Tests.
func TestVorschauOhneSperreLaeuftDurch(t *testing.T) {
	b := vorschauVon(t, vollstaendigerBaum(t), "welle-10", "")
	if len(b.Sperren) != 0 {
		t.Fatalf("Sperren = %v, want keine", kennungen(b))
	}
	if len(b.Bestand.Mitglieder) != 1 {
		t.Fatalf("Mitglieder = %v, want 1", b.Bestand.Mitglieder)
	}
}

// TestVorschauSperrtOhneUntergrenze traegt den Untergrenzen-Waechter: liegt ein
// wellenloser Slice flach in done/ und existiert kein done/*/archiv.zip, faellt
// der Lauf fail-closed aus, statt den gesamten Altbestand mitzunehmen.
func TestVorschauSperrtOhneUntergrenze(t *testing.T) {
	root := vollstaendigerBaum(t)
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-101-b.md"), "# Slice slice-101: B\n\n**Welle:** ohne Welle (Wartung).\n")

	b := vorschauVon(t, root, "welle-10", "")
	if hatSperre(b, "untergrenze") {
		t.Fatalf("Sperre 'untergrenze' steht, obwohl done/welle-09/archiv.zip die Grenze setzt: %v", kennungen(b))
	}

	// Dieselbe Lage OHNE bestehendes Archiv: jetzt muss sie stehen.
	if err := os.RemoveAll(filepath.Join(done, "welle-09")); err != nil {
		t.Fatal(err)
	}
	b = vorschauVon(t, root, "welle-10", "")
	if !hatSperre(b, "untergrenze") {
		t.Fatalf("Sperre 'untergrenze' fehlt ohne jedes done/*/archiv.zip: %v", kennungen(b))
	}
}

// TestVorschauSperrtBeiUnsauberemBaum fuehrt die lesende Haelfte von
// Abnahme-Kriterium 2 ueber die Verdrahtung: die porcelain-Ausgabe kommt als
// Wert herein, und eine untrackte Fremddatei allein sperrt den Lauf.
func TestVorschauSperrtBeiUnsauberemBaum(t *testing.T) {
	b := vorschauVon(t, vollstaendigerBaum(t), "welle-10", "?? scratch.txt\n")
	if !hatSperre(b, "unsauber") {
		t.Fatalf("Sperre 'unsauber' fehlt bei untracktem Bestand: %v", kennungen(b))
	}
}

// TestVorschauSperrtBeiHaenger fuehrt Abnahme-Kriterium 1 ueber die
// Verdrahtung: ein bleibender Report verlinkt einen, der ins Archiv geht.
func TestVorschauSperrtBeiHaenger(t *testing.T) {
	root := vollstaendigerBaum(t)
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-09-01-slice-100-r1.md"), "# Runde 1\n")
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-09-02-slice-900-r1.md"),
		"# Fremder Report\n\nSiehe [Vorrunde](2026-09-01-slice-100-r1.md).\n")

	b := vorschauVon(t, root, "welle-10", "")
	if !hatSperre(b, "haenger") {
		t.Fatalf("Sperre 'haenger' fehlt: %v", kennungen(b))
	}
}

// TestVorschauSperrtOhnePlanUndOhneErgebnisnotiz: die zwei strukturellen
// Vorbedingungen der Wellen-Closure stehen als eigene Ausgaenge da.
func TestVorschauSperrtOhnePlanUndOhneErgebnisnotiz(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-100-a.md"), "# Slice slice-100: A\n\n**Welle:** welle-10.\n")

	b := vorschauVon(t, root, "welle-10", "")
	for _, k := range []string{"kein-plan", "ergebnisnotiz"} {
		if !hatSperre(b, k) {
			t.Errorf("Sperre %q fehlt: %v", k, kennungen(b))
		}
	}
}

// TestSchreibeNenntDieVierZahlenUndDieSperren: die Ausgabe traegt die vier
// Einsammel-Zahlen — Mitglieder, wellenlos, fremd, Review-Reports — und nennt
// jede Sperre mit ihrer Kennung.
func TestSchreibeNenntDieVierZahlenUndDieSperren(t *testing.T) {
	root := vollstaendigerBaum(t)
	b := vorschauVon(t, root, "welle-10", "?? scratch.txt\n")
	text := archive.Schreibe(b)
	for _, teil := range []string{
		"archive-welle --vorschau: welle-10",
		"Mitglieder (Welle-Feld nennt welle-10): 1",
		"wellenlos (seit der letzten Closure): 0",
		"fremd (andere Welle, bleibt liegen):  0",
		"Review-Reports (ohne Stub):           0",
		"Verweise:",
		"[unsauber]",
	} {
		if !strings.Contains(text, teil) {
			t.Errorf("Ausgabe nennt %q nicht:\n%s", teil, text)
		}
	}
}

// TestSchreibeTrenntDateienVonFundstellen: die Verweis-Zeile traegt ZWEI
// Einheiten, und beide sind beschriftet. Der Fall ist so gebaut, dass die
// Fundstellen-Summe die Datei-Zahl uebersteigt — genau die Lage, in der ein
// gemeinsames "Datei(en)"-Label die drei Klammer-Zahlen als Teilmenge der ersten
// ausgaebe.
func TestSchreibeTrenntDateienVonFundstellen(t *testing.T) {
	root := vollstaendigerBaum(t)
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"# Ergebnis\n\n**Abschluss:** 2026-09-01\n\n"+
			"Geliefert: [a](slice-100-a.md), nochmal [a](done/slice-100-a.md), "+
			"und [plan](welle-10-re-baseline.md).\n")

	text := archive.Schreibe(vorschauVon(t, root, "welle-10", ""))
	want := "  Verweise: 1 Datei(en) betroffen (1 Praefix-, 2 geschwister-relative, 0 aufsteigende Fundstelle(n))"
	if !strings.Contains(text, want) {
		t.Fatalf("Verweis-Zeile nennt die zwei Einheiten nicht getrennt:\nwant %q\n%s", want, text)
	}
}

// TestSchreibeSagtKeineSperre: null Sperren ist eine Aussage und steht als Satz
// da, nicht als Auslassung.
func TestSchreibeSagtKeineSperre(t *testing.T) {
	b := vorschauVon(t, vollstaendigerBaum(t), "welle-10", "")
	if !strings.Contains(archive.Schreibe(b), "Sperren: keine") {
		t.Fatalf("Ausgabe sagt nicht, dass keine Sperre steht:\n%s", archive.Schreibe(b))
	}
}
