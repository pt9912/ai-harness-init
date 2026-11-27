package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// labSkriptPfad ist die Lab-Fassung des Tool-/Versions-Checks im erzeugenden Werkzeug.
const labSkriptPfad = "../../harness/tools/environment-check.sh"

// labFetchPfad ist die Lab-Fassung des d-check-Fetch im erzeugenden Werkzeug.
const labFetchPfad = "../../harness/tools/dcheck-fetch.sh"

// anweisungsZeilen liest die Zeilen ab der ersten Nicht-Kommentar-Zeile und streicht
// Kommentar- und Leerzeilen — die Identitaets-Ebene zwischen Kopie und Lab-Fassung
// (die Kopie nennt die Ziel-Pfade in Kommentaren, die Lab-Fassung die Lab-Pfade).
func anweisungsZeilen(t *testing.T, pfad string) []string {
	t.Helper()
	raw, err := os.ReadFile(pfad)
	if err != nil {
		t.Fatalf("Skript %s lesen: %v", pfad, err)
	}
	var zeilen []string
	for _, z := range strings.Split(string(raw), "\n") {
		h := strings.TrimSpace(z)
		if h == "" || strings.HasPrefix(h, "#") {
			continue
		}
		zeilen = append(zeilen, z)
	}
	return zeilen
}

func gleichZeilenweise(t *testing.T, ziel, lab []string) {
	t.Helper()
	n := len(lab)
	if len(ziel) < n {
		t.Fatalf("Kopie traegt %d Anweisungs-Zeilen, die Lab-Fassung %d — die Kopie ist kleiner als ihr Original", len(ziel), n)
	}
	for i := 0; i < n; i++ {
		if ziel[i] != lab[i] {
			t.Errorf("Zeile %d weicht ab (Kopie vs Lab-Fassung):\n  Kopie: %s\n  Lab:   %s", i+1, ziel[i], lab[i])
		}
	}
}

// TestEmittedEnvironmentCheck_EngineGleichDerLabFassung: die emittierte Kopie des
// Tool-/Versions-Checks und des d-check-Fetch laeuft ab der ersten Anweisungs-Zeile
// Zeile fuer Zeile wie die Lab-Fassung — eine zweite Engine wuerde still eigene
// Pruefformen tragen, die niemand im Dogfood gebrochen hat.
func TestEmittedEnvironmentCheck_EngineGleichDerLabFassung(t *testing.T) {
	gleichZeilenweise(t,
		anweisungsZeilen(t, filepath.FromSlash("templates/enforce/environment-check.sh")),
		anweisungsZeilen(t, labSkriptPfad))
	gleichZeilenweise(t,
		anweisungsZeilen(t, filepath.FromSlash("templates/enforce/dcheck-fetch.sh")),
		anweisungsZeilen(t, labFetchPfad))
}

// TestEmittedEnvironmentMk_StelltCheckVorAlleChecks: das Fragment haengt
// environment-check per Praefix-Zuweisung an GATE_CHECKS — nach allen Fragmenten, die
// alphabetisch vor environment.mk liegen und ihre Checks schon akkumuliert haben, und
// vor allen spaeter eingebundenen (die nur hinten anhaengen). Der netzlose Waechter
// auf die "erster Check"-Zusage (ADR-0109): traegt die Zeile statt dessen ein
// hinten-anhaengendes GATE_CHECKS +=, verliert der Check die Kante an alphabetisch
// spaetere Fragmente (harness/mk/<lang>.mk). Rot-Zug: die Praepenziell-Zeile durch
// eine Anhangs-Zeile ersetzen.
func TestEmittedEnvironmentMk_StelltCheckVorAlleChecks(t *testing.T) {
	frag := emit.EnvironmentMk()
	if !strings.Contains(frag, "\nGATE_CHECKS := environment-check $(GATE_CHECKS)\n") {
		t.Errorf("environment.mk traegt die Praeferenz-Zeile nicht:\n%s", frag)
	}
	if strings.Contains(frag, "GATE_CHECKS += environment-check") {
		t.Errorf("environment.mk haengt den Check als Anhang statt als Praeferenz — spaetere Fragmente (Sprach-Fragmente) laufen ihm voraus:\n%s", frag)
	}
	if !strings.Contains(frag, "tools/harness/environment-check.sh") {
		t.Errorf("environment.mk ruft das Skript am emitted Pfad nicht:\n%s", frag)
	}
}

// TestEnforce_EmitUndInventarLiegenImZiel: ein Lauf legt Skript (ausfuehrbar),
// Inventar-Basissatz und das Environment-Fragment ueber derselben Klasse (konvergent)
// ab; der Inventar-Basissatz traegt die d-check-Anwesenheit mit fetched Ablage.
func TestEnforce_EmitUndInventarLiegenImZiel(t *testing.T) {
	ziel := t.TempDir()
	notice := &strings.Builder{}
	if err := emit.Enforce(ziel, notice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	if err := emit.EnvironmentCheck(ziel); err != nil {
		t.Fatalf("EnvironmentCheck: %v", err)
	}
	for _, p := range []string{"tools/harness/environment-check.sh", "tools/harness/environment-inventory.txt", "tools/harness/dcheck-fetch.sh", "harness/mk/environment.mk"} {
		if _, err := os.Stat(filepath.Join(ziel, filepath.FromSlash(p))); err != nil {
			t.Errorf("%s fehlt nach dem Enforce-Lauf: %v", p, err)
		}
	}
	inventar, err := os.ReadFile(filepath.Join(ziel, "tools/harness/environment-inventory.txt"))
	if err != nil {
		t.Fatalf("Inventar lesen: %v", err)
	}
	for _, zeile := range emit.InventoryBasissatz() {
		if !strings.Contains(string(inventar), zeile) {
			t.Errorf("Inventar-Basissatz traegt die Zeile nicht: %s", zeile)
		}
	}
}

// TestEnsureInventoryRows_LiegtDasInventarJeSollEinmal: der anhaengende Lauf traegt
// jede Werkzeug-Zeile GENAU EINMAL (dedupliert je Name) und ersetzt ein abweichendes
// Soll. Negative ueber einem Inventar, das den Basissatz NICHT traegt: kein Ziel, ein
// Lauf ohne Enforce — die Zeilen werden nicht still an ein fehlendes Inventar
// gehaengt.
func TestEnsureInventoryRows_LiegtDasInventarJeSollEinmal(t *testing.T) {
	t.Run("haengt an", func(t *testing.T) {
		ziel := t.TempDir()
		if err := os.MkdirAll(filepath.Join(ziel, "tools/harness"), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(ziel, "tools/harness/environment-inventory.txt"), []byte("# kopf\nbash|Mindestversion|pflicht|manifest:4.0|a|b\n"), 0o644); err != nil {
			t.Fatal(err)
		}
		zeilen := []string{
			"go|exakt|pflicht|abgeleitet:1.27.4|Toolchain|soll vom Pin abgeleitet",
			"golangci-lint|exakt|pflicht|abgeleitet:v2.15.0|Lint|soll vom Pin abgeleitet",
		}
		if geaendert, err := emit.EnsureInventoryRows(ziel, zeilen); err != nil || !geaendert {
			t.Fatalf("anhaengen: geaendert=%v err=%v", geaendert, err)
		}
		raw, _ := os.ReadFile(filepath.Join(ziel, "tools/harness/environment-inventory.txt"))
		if n := strings.Count(string(raw), "go|exakt"); n != 1 {
			t.Errorf("go-Zeile %dx im Inventar", n)
		}
		loesche := []string{"go|exakt|pflicht|abgeleitet:1.27.4|Toolchain|soll vom Pin abgeleitet"}
		if geaendert, err := emit.EnsureInventoryRows(ziel, loesche); err != nil || geaendert {
			t.Errorf("Wiederholung aendert nichts: geaendert=%v err=%v", geaendert, err)
		}
		neu := []string{"go|exakt|pflicht|abgeleitet:1.30.0|Toolchain|soll vom Pin abgeleitet"}
		if geaendert, err := emit.EnsureInventoryRows(ziel, neu); err != nil || !geaendert {
			t.Fatalf("Soll-Ersetzung: geaendert=%v err=%v", geaendert, err)
		}
		raw, _ = os.ReadFile(filepath.Join(ziel, "tools/harness/environment-inventory.txt"))
		if !strings.Contains(string(raw), "abgeleitet:1.30.0") || strings.Contains(string(raw), "1.27.4") {
			t.Errorf("abweichendes Soll gewinnt nicht:\n%s", raw)
		}
	})
	t.Run("fehlt", func(t *testing.T) {
		if geaendert, err := emit.EnsureInventoryRows(t.TempDir(), []string{"go|exakt|pflicht|abgeleitet:1.27.4|a|b"}); err != nil || geaendert {
			t.Errorf("fehlendes Inventar: geaendert=%v err=%v", geaendert, err)
		}
	})
}
