package archive_test

import (
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// TestUnsauberGrundZaehltUntrackte ist ADR-0033 Abnahme-Kriterium 2 in seiner
// lesenden Haelfte: eine untrackte Fremddatei allein macht den Baum unsauber.
// Ohne diese Haelfte truege der Archivierungs-Commit fremden Inhalt, und die
// Zusage "der Commit bezeugt die Vollstaendigkeit" waere gebrochen, ohne dass
// etwas rot wird. Gegenbeispiel: test/mutations/232-archive-welle-go-untrackt.sh
// verengt die Zaehlung auf getrackte Dateien, dann faellt dieser Test.
func TestUnsauberGrundZaehltUntrackte(t *testing.T) {
	got := archive.UnsauberGrund("?? scratch.txt\n?? notizen/\n")
	if got == "" {
		t.Fatal("UnsauberGrund = leer bei zwei untrackten Eintraegen — der Baum gilt faelschlich als sauber")
	}
	if !strings.Contains(got, "2") || !strings.Contains(got, "untrackte") {
		t.Fatalf("UnsauberGrund = %q, want die untrackte Klasse mit ihrer Zahl", got)
	}
}

// TestUnsauberGrundTrenntDieZweiKlassen: die Abhilfe ist verschieden, also steht
// jede Klasse mit eigener Zahl in der Meldung.
func TestUnsauberGrundTrenntDieZweiKlassen(t *testing.T) {
	got := archive.UnsauberGrund(" M AGENTS.md\n?? scratch.txt\n")
	if !strings.Contains(got, "getrackten") || !strings.Contains(got, "untrackte") {
		t.Fatalf("UnsauberGrund = %q, want beide Klassen getrennt", got)
	}
}

// TestUnsauberGrundNenntEintragNichtDatei: eine porcelain-Zeile kann ein
// untracktes VERZEICHNIS sein — die Meldung zaehlt Eintraege, nicht Dateien.
func TestUnsauberGrundNenntEintragNichtDatei(t *testing.T) {
	got := archive.UnsauberGrund("?? notizen/\n")
	if strings.Contains(got, "untrackte Datei") {
		t.Fatalf("UnsauberGrund = %q — eine Zeile kann ein Verzeichnis sein", got)
	}
}

// TestUnsauberGrundLeerBeiSauberemBaum ist die Umkehr-Probe: kein Grund, kein
// Befund.
func TestUnsauberGrundLeerBeiSauberemBaum(t *testing.T) {
	for _, porcelain := range []string{"", "\n", "   \n\n"} {
		if got := archive.UnsauberGrund(porcelain); got != "" {
			t.Errorf("UnsauberGrund(%q) = %q, want leer", porcelain, got)
		}
	}
}
