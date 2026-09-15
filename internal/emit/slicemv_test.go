package emit_test

import (
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// zielSliceMv ist der Name des Lifecycle-Kommandos im Ziel. Er steht hier als
// Name, weil er der Gegenstand der Waechter ist: gemessen wird, WO er auftaucht,
// nicht ob es ihn gibt.
const zielSliceMv = "slice-mv"

// slicemvZiel faehrt einen echten Emit in ein frisches Verzeichnis und liefert
// dessen Wurzel. GELESEN wird von der Platte: die Zusage gilt den zwei Dateien im
// Ziel, nicht dem Rueckgabewert einer Funktion.
func slicemvZiel(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	return dir
}

// TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette haelt die zwei
// Adressen des Fragments fest: es definiert das Kommando, und es haengt an keiner
// Gate-Kante.
//
// Der Grund ist derselbe wie bei der Archivierung: der Lifecycle-Wechsel
// BEWEGT und COMMITTET im versionierten Baum des Ziels. Ein Gate ueber ihm faerbte
// rot, sobald jemand gerade schreibt, und gruen, ohne etwas ueber den Baum zu
// sagen.
//
// Rot-Gegenbeispiel: test/mutations/343-lifecycle-kommando-haengt-an-gate-checks.sh.
func TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette(t *testing.T) {
	frag := mustReadString(t, filepath.Join(slicemvZiel(t), filepath.FromSlash(emit.SliceMvMkPath)))

	regeln, checks := regelnIn(frag)
	if _, da := regeln[zielSliceMv]; !da {
		t.Errorf("%s definiert das Ziel %q nicht — das Ziel-Repo hat damit kein Kommando:\n%s",
			emit.SliceMvMkPath, zielSliceMv, frag)
	}
	if len(checks) != 0 {
		t.Errorf("%s haengt %v an GATE_CHECKS — es traegt ein Kommando, kein Gate", emit.SliceMvMkPath, checks)
	}
	if huelle := gatesHuelle(t); huelle[zielSliceMv] {
		t.Errorf("%q haengt in der gates-Kette des Ziels — der Lifecycle-Wechsel prueft nichts: %v",
			zielSliceMv, sortiert(huelle))
	}
}

// TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen haelt fest, dass
// das Fragment nicht auf ein Programm zeigt, das der Bootstrap nicht ablegt: das
// Werkzeug liegt an seinem Zielort, ist ausfuehrbar, und es traegt beide
// Ersetzungsrichtungen samt der Voraussetzung, unter der es abbricht.
//
// Der Zielort wird gegen emit.SliceMvShPath gehalten und nicht abgeschrieben: der
// Pfad ist derselbe, den das Fragment setzt, und beide werden hier gemessen.
//
// Rot-Gegenbeispiel: test/mutations/344-lifecycle-fragment-ohne-werkzeug.sh.
func TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen(t *testing.T) {
	dir := slicemvZiel(t)
	pfad := filepath.Join(dir, filepath.FromSlash(emit.SliceMvShPath))

	info, err := os.Stat(pfad)
	if err != nil {
		t.Fatalf("%s liegt nicht im Ziel: %v", emit.SliceMvShPath, err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("%s ist nicht ausfuehrbar (%v) — `make slice-mv` ruft es als Programm",
			emit.SliceMvShPath, info.Mode().Perm())
	}

	skript := mustReadString(t, pfad)
	for _, noetig := range []struct{ teil, grund string }{
		{"rewrite_incoming_in_file", "die eingehende Ersetzung fehlt — Verweise auf die bewegte Datei bleiben stehen"},
		{"rewrite_outgoing_bare_in_file", "die ausgehende Ersetzung fehlt — praefixlose Ziele in der bewegten Datei zeigen ins alte Verzeichnis"},
		{"Arbeitsbaum nicht sauber", "die Voraussetzung nennt ihren Fall nicht — ein unsauberer Baum faellt dann still durch"},
		{"BASH_SOURCE", "der Waechter gegen den Selbstlauf fehlt — das Skript laesst sich nicht ohne Move pruefen"},
	} {
		if !strings.Contains(skript, noetig.teil) {
			t.Errorf("%s traegt %q nicht: %s", emit.SliceMvShPath, noetig.teil, noetig.grund)
		}
	}
	if strings.Contains(skript, "GATE_CHECKS") {
		t.Errorf("%s nennt GATE_CHECKS — das Werkzeug ist kein Gate", emit.SliceMvShPath)
	}
}

// TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert haelt die zwei Pfad-Ausnahmen
// fest UND ihre Markierung: sie stehen als benannte, im Aufruf setzbare Variable
// im Skriptkopf, nicht versteckt im Sed-Aufruf.
//
// Der Grund fuer die Markierung: was ein Zielrepo ausnimmt, ist seine Politik und
// nicht die Mechanik des Werkzeugs. Die zwei Vorgaben sind Ableitungen aus dem
// mitemittierten Regelwerk — Fremdtext und die Hard Rule fuer Accepted-ADRs —,
// und ein Repo mit einer anderen Politik soll sie setzen koennen, ohne das
// Werkzeug zu editieren: die Datei wird bei jedem Bootstrap kanonisch neu
// geschrieben, eine Aenderung an ihr ueberlebt den naechsten Lauf nicht.
func TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert(t *testing.T) {
	skript := mustReadString(t, filepath.Join(slicemvZiel(t), filepath.FromSlash(emit.SliceMvShPath)))

	for _, teil := range []string{
		"REPO-POLITIK",
		"SLICE_MV_AUSGENOMMENE_PFADE",
		":!.harness/baseline",
		":!docs/plan/adr",
	} {
		if !strings.Contains(skript, teil) {
			t.Errorf("%s traegt %q nicht — die zwei Ausnahmen sind dann weder benannt noch als Politik erkennbar",
				emit.SliceMvShPath, teil)
		}
	}
	// Die Ausnahmen wirken ueber die reine Funktion, die main() ausliest — nicht
	// als zweite, im Sed-Aufruf verdrahtete Liste.
	if !strings.Contains(skript, "eingehend_ausgenommene_pfade") {
		t.Errorf("%s liest die Ausnahmen nicht ueber eingehend_ausgenommene_pfade() aus — die Variable waere dann eine Deklaration ohne Wirkung",
			emit.SliceMvShPath)
	}
}

// TestSliceMvFragment_MeldetEinFehlendesWerkzeug haelt die fail-closed-Kante des
// Fragments fest: fehlt das Werkzeug, bricht das Ziel mit einer eigenen Meldung
// ab, statt in die Meldung eines Interpreters zu laufen.
//
// Die Unterscheidung ist nicht kosmetisch: `bash` ueber einer fehlenden Datei
// endet ebenfalls ungleich null, nennt aber nicht, was fehlt und wie es
// zurueckkommt.
func TestSliceMvFragment_MeldetEinFehlendesWerkzeug(t *testing.T) {
	frag := mustReadString(t, filepath.Join(slicemvZiel(t), filepath.FromSlash(emit.SliceMvMkPath)))
	flach := strings.Join(strings.Fields(frag), " ")

	if !strings.Contains(flach, `test -f "$(SLICE_MV)"`) {
		t.Errorf("%s prueft die Anwesenheit des Werkzeugs nicht — ein fehlendes Werkzeug faellt dann erst im Interpreter auf", emit.SliceMvMkPath)
	}
	if !strings.Contains(flach, "liegt nicht") {
		t.Errorf("%s sagt den fehlenden Traeger nicht — der Abbruch nennt dann nicht, was fehlt", emit.SliceMvMkPath)
	}
}

// TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen haelt den Lieferpunkt des
// Anweisungssatzes fest: der Lifecycle-Wechsel ist an den zwei Stellen, an denen
// die Anleitung ihn vorschreibt (Eintritt nach in-progress und Closure nach done),
// als Kommando benannt — und die repo-spezifische Stelle ist als Marker
// ausgewiesen, waehrend der Ziel-NAME ausdruecklich keiner ist.
//
// Die zweite Haelfte ist die tragende: der Ziel-Name kommt aus einem tool-eigenen
// Fragment, das jeder Bootstrap kanonisch neu schreibt. Eine Anleitung, die ihn
// als adaptierbar ausweist, laedt zu einer Umbenennung ein, die der naechste Lauf
// zuruecknimmt.
func TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen(t *testing.T) {
	anleitung := string(emit.CommandFile(".claude/commands/implement-slice.md"))
	if anleitung == "" {
		t.Fatal("die emittierte Anleitung ist leer — der Waechter misst nichts")
	}
	if n := strings.Count(anleitung, "make slice-mv"); n < 2 {
		t.Errorf("die Anleitung nennt `make slice-mv` %d-mal — der Eintritt nach in-progress UND die Closure nach done sind zwei Stellen", n)
	}
	if !strings.Contains(anleitung, "ANPASSEN") {
		t.Errorf("die Anleitung traegt keinen ANPASSEN-Marker — die repo-spezifische Stelle ist dann nicht als solche erkennbar")
	}
	if !strings.Contains(anleitung, "Der Ziel-NAME `slice-mv` ist es nicht") {
		t.Errorf("die Anleitung weist den Ziel-Namen nicht als NICHT-repo-spezifisch aus — er kommt aus einem tool-eigenen, kanonisch neu geschriebenen Fragment")
	}
	// Die zwei Stellen sind nicht mehr die Handarbeit, die sie ersetzt: der
	// Anweisungssatz fuehrt `git mv` nur noch dort, wo er den Move BESCHREIBT,
	// nicht als die vorgeschriebene Handlung.
	if strings.Contains(anleitung, "verschieben (`git mv`, eigener") {
		t.Errorf("die Anleitung schreibt an der Closure weiter den `git mv` von Hand vor")
	}
}

// TestSliceMvWerkzeug_IstNichtDerDogfoodPfad haelt die Layout-Grenze fest: der
// Dogfood dieses Repos fuehrt sein Werkzeug unter harness/tools/, das emittierte
// Layout unter tools/harness/. Ein vertauschter Pfad liesse das Fragment ins
// Leere zeigen, und der Emit faende es nicht.
func TestSliceMvWerkzeug_IstNichtDerDogfoodPfad(t *testing.T) {
	if emit.SliceMvShPath != "tools/harness/slice-mv.sh" {
		t.Errorf("SliceMvShPath ist %q — das emittierte Layout der ausfuehrbaren Tools ist tools/harness/", emit.SliceMvShPath)
	}
	if !fs.ValidPath(emit.SliceMvShPath) || !fs.ValidPath(emit.SliceMvMkPath) {
		t.Errorf("die zwei Zielpfade sind keine gueltigen Pfade: %q, %q", emit.SliceMvShPath, emit.SliceMvMkPath)
	}
}
