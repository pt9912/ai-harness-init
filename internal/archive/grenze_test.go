package archive_test

import (
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// einCommit ist die Abstammung eines synthetischen Baums, in dem jede Datei im
// selben Commit hinzukam: jeder Pfad, den die Operation liest, traegt "c0", und
// c0 <= c0. Damit gehoert jeder wellenlose Slice zu jedem Lauf — die Einordnung
// eines Baums ohne Grenze.
func einCommit(t *testing.T, root string) archive.Abstammung {
	t.Helper()
	ergebnisse, slices, err := archive.AbstammungsPfade(root)
	if err != nil {
		t.Fatal(err)
	}
	a := archive.Abstammung{Add: map[string]string{}, Vorfahren: map[string]map[string]bool{"c0": {"c0": true}}}
	for _, p := range append(ergebnisse, slices...) {
		a.Add[p] = "c0"
	}
	return a
}

const doneRel = "docs/plan/planning/done/"

// grenzBaum: zwei geschlossene Wellen und drei wellenlose Slices, dazu je ein
// Review-Report. Die Abstammung dazu (linear) liefert linear().
func grenzBaum(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	for _, w := range []string{"welle-1", "welle-2"} {
		schreibe(t, filepath.Join(done, w+"-plan.md"), "# Welle "+w+"\n")
		schreibe(t, filepath.Join(done, w+"-results.md"), "# Ergebnis "+w+"\n")
	}
	for _, s := range []string{"slice-301-frueh", "slice-302-mitte", "slice-303-spaet"} {
		schreibe(t, filepath.Join(done, s+".md"), "# Slice\n\n**Welle:** ohne Welle\n")
	}
	schreibe(t, filepath.Join(done, "welle-0", "archiv.zip"), "PK\n")
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-01-01-slice-303-review.md"), "# Review\n")
	return root
}

// linear: frueh < G1 < mitte < G2 < spaet — eine Kette ohne Verzweigung.
func linear() archive.Abstammung {
	return archive.Abstammung{
		Add: map[string]string{
			doneRel + "welle-1-results.md":   "g1",
			doneRel + "welle-2-results.md":   "g2",
			doneRel + "slice-301-frueh.md":   "s1",
			doneRel + "slice-302-mitte.md":   "s2",
			doneRel + "slice-303-spaet.md":   "s3",
		},
		Vorfahren: map[string]map[string]bool{
			"g1": {"s1": true, "g1": true},
			"g2": {"s1": true, "g1": true, "s2": true, "g2": true},
		},
	}
}

func grenzEinsammeln(t *testing.T, root, welle string, a archive.Abstammung) archive.Bestand {
	t.Helper()
	b, err := archive.Einsammeln(root, welle, a)
	if err != nil {
		t.Fatal(err)
	}
	return b
}

func basen(pfade []string) []string {
	out := []string{}
	for _, p := range pfade {
		out = append(out, strings.TrimSuffix(filepath.Base(p), ".md"))
	}
	return out
}

// TestGrenzeAltbestandNimmtNurSlicesVorEinerGrenze traegt ADR-0081
// Festlegung 2: der Altbestand-Lauf nimmt die wellenlosen Slices, deren
// Add-Commit Vorfahr eines Grenz-Commits ist; der nach der letzten Closure
// geschlossene bleibt liegen, samt seinem Review-Report, und die Vorschau zaehlt
// ihn in der eigenen Zeile.
// Gegenbeispiel: test/mutations/542-archive-welle-go-grenze-vergleich-umgekehrt.sh.
func TestGrenzeAltbestandNimmtNurSlicesVorEinerGrenze(t *testing.T) {
	b := grenzEinsammeln(t, grenzBaum(t), archive.AltbestandSchluessel, linear())
	if got, want := basen(b.Wellenlose), []string{"slice-301-frueh", "slice-302-mitte"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("Wellenlose = %v, want %v", got, want)
	}
	if got, want := basen(b.NachGrenze), []string{"slice-303-spaet"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("NachGrenze = %v, want %v", got, want)
	}
	if len(b.Reviews) != 0 {
		t.Errorf("Reviews = %v — der Report des liegen bleibenden Slice wanderte mit", b.Reviews)
	}
	if !strings.Contains(archive.Schreibe(archive.Bericht{Bestand: b}), "bleibt liegen (nach der Grenze):      1") {
		t.Errorf("die Vorschau zaehlt den liegen bleibenden Slice nicht:\n%s", archive.Schreibe(archive.Bericht{Bestand: b}))
	}
}

// TestGrenzeWelleNimmtDieFruehesteClosure traegt ADR-0081 Festlegung 3: ein
// Slice gehoert der fruehesten Closure in seiner Abstammung. welle-2 nimmt nur
// den Slice zwischen den Closures, welle-1 nur den davor; der spaete bleibt bei
// beiden liegen.
func TestGrenzeWelleNimmtDieFruehesteClosure(t *testing.T) {
	root := grenzBaum(t)
	for _, f := range []struct {
		welle       string
		nimmt, nach []string
	}{
		{"welle-1", []string{"slice-301-frueh"}, []string{"slice-302-mitte", "slice-303-spaet"}},
		{"welle-2", []string{"slice-302-mitte"}, []string{"slice-301-frueh", "slice-303-spaet"}},
	} {
		b := grenzEinsammeln(t, root, f.welle, linear())
		if got := basen(b.Wellenlose); !reflect.DeepEqual(got, f.nimmt) {
			t.Errorf("%s: Wellenlose = %v, want %v", f.welle, got, f.nimmt)
		}
		if got := basen(b.NachGrenze); !reflect.DeepEqual(got, f.nach) {
			t.Errorf("%s: NachGrenze = %v, want %v", f.welle, got, f.nach)
		}
	}
}

// TestGrenzeParalleleClosuresTeilenDenSlice: zwei Grenz-Commits, keiner Vorfahr
// des anderen, beide mit s <= G — der Slice gehoert beiden Laeufen.
func TestGrenzeParalleleClosuresTeilenDenSlice(t *testing.T) {
	root := grenzBaum(t)
	a := linear()
	a.Vorfahren = map[string]map[string]bool{
		"g1": {"s1": true, "g1": true},
		"g2": {"s1": true, "g2": true},
	}
	for _, w := range []string{"welle-1", "welle-2"} {
		b := grenzEinsammeln(t, root, w, a)
		if got := basen(b.Wellenlose); !reflect.DeepEqual(got, []string{"slice-301-frueh"}) {
			t.Errorf("%s: Wellenlose = %v, want [slice-301-frueh]", w, got)
		}
	}
}

// TestGrenzeOhneErgebnisnotizVerhaeltSichWieBisher: ohne Ergebnisnotiz in done/
// gibt es keinen Grenz-Commit — jeder wellenlose Slice bleibt eingesammelt, und
// weder ein flacher Klon noch fehlende Add-Commits sperren.
func TestGrenzeOhneErgebnisnotizVerhaeltSichWieBisher(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-301-frueh.md"), "# Slice\n\n**Welle:** ohne Welle\n")
	b, err := archive.Vorschau(root, archive.AltbestandSchluessel, "", indexVon(t, root), archive.Abstammung{Flach: true})
	if err != nil {
		t.Fatal(err)
	}
	if len(b.Bestand.Wellenlose) != 1 || len(b.Bestand.NachGrenze) != 0 {
		t.Fatalf("Wellenlose = %v, NachGrenze = %v", b.Bestand.Wellenlose, b.Bestand.NachGrenze)
	}
	if hatSperre(b, "flacher-klon") || hatSperre(b, "add-commit") {
		t.Fatalf("Sperren = %v — ohne Ergebnisnotiz braucht kein Lauf einen Grenz-Commit", kennungen(b))
	}
}

// TestGrenzeSperrtImFlachenKlon traegt ADR-0081 Festlegung 4(a).
func TestGrenzeSperrtImFlachenKlon(t *testing.T) {
	root := grenzBaum(t)
	a := linear()
	a.Flach = true
	b, err := archive.Vorschau(root, archive.AltbestandSchluessel, "", indexVon(t, root), a)
	if err != nil {
		t.Fatal(err)
	}
	if !hatSperre(b, "flacher-klon") {
		t.Fatalf("Sperre 'flacher-klon' fehlt: %v", kennungen(b))
	}
}

// TestGrenzeSperrtOhneAddCommit traegt ADR-0081 Festlegung 4(b): ein
// eingesammelter Slice ohne Add-Commit sperrt und steht in den Zeilen der Sperre.
func TestGrenzeSperrtOhneAddCommit(t *testing.T) {
	root := grenzBaum(t)
	a := linear()
	delete(a.Add, doneRel+"slice-302-mitte.md")
	b, err := archive.Vorschau(root, archive.AltbestandSchluessel, "", indexVon(t, root), a)
	if err != nil {
		t.Fatal(err)
	}
	for _, s := range b.Sperren {
		if s.Kennung == "add-commit" && reflect.DeepEqual(s.Zeilen, []string{doneRel + "slice-302-mitte.md"}) {
			return
		}
	}
	t.Fatalf("Sperre 'add-commit' mit slice-302-mitte fehlt: %+v", b.Sperren)
}
