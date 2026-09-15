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

// TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch haelt die Verdrahtung
// fest, an der der zweite genannte Ort der Repo-Politik haengt: das Fragment
// fuehrt die Variable mit Vorgabe UND gibt sie dem Werkzeug als Umgebung mit.
//
// Der Grund ist gemessen: eine blosse Zuweisung in einer Make-Quelle erreicht das
// Rezept nicht — nur die Umgebung, die Kommandozeile oder `export` tun es. Ohne
// die Uebergabe unten waere "setze sie in deinem Make-Fragment" eine Zusage, die
// der Aufruf nicht einloest, und der Nachzug schriebe weiter in Baeume hinein,
// die das Repo ausgenommen glaubt.
func TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch(t *testing.T) {
	frag := mustReadString(t, filepath.Join(slicemvZiel(t), filepath.FromSlash(emit.SliceMvMkPath)))
	flach := strings.Join(strings.Fields(frag), " ")

	if !strings.Contains(flach, "SLICE_MV_AUSGENOMMENE_PFADE ?=") {
		t.Errorf("%s fuehrt %s nicht mit Vorgabe — ein Repo ohne eigene Zuweisung bekaeme dann keine Ausnahmen",
			emit.SliceMvMkPath, "SLICE_MV_AUSGENOMMENE_PFADE")
	}
	if !strings.Contains(flach, `SLICE_MV_AUSGENOMMENE_PFADE='$(SLICE_MV_AUSGENOMMENE_PFADE)'`) {
		t.Errorf("%s reicht %s dem Werkzeug nicht als Umgebung durch — eine Zuweisung in einer Make-Quelle erreicht das Rezept sonst nicht",
			emit.SliceMvMkPath, "SLICE_MV_AUSGENOMMENE_PFADE")
	}
}

// TestSliceMvFragment_TraegtDieFailClosedKante haelt den TEXT der Kante fest:
// das Fragment prueft die Anwesenheit des Werkzeugs und nennt selbst, was fehlt.
//
// WAS DIESER TEST NICHT MISST, und wo der Beleg dafuer liegt: dass die Kante
// greift. Ein Name, der ein Verhalten fuehrt, und ein Rumpf, der Zeichenketten
// zaehlt, sind zwei verschiedene Aussagen — gefahren wird der Zweig am
// gebootstrappten Ziel, in harness/tools/full-smoke.sh Abschnitt (h): Werkzeug
// beiseite, Aufruf, Ausgabe und Exit gelesen.
//
// Die Unterscheidung der zwei Meldungen ist nicht kosmetisch: `bash` ueber einer
// fehlenden Datei endet ebenfalls ungleich null, nennt aber nicht, was fehlt und
// wie es zurueckkommt.
func TestSliceMvFragment_TraegtDieFailClosedKante(t *testing.T) {
	frag := mustReadString(t, filepath.Join(slicemvZiel(t), filepath.FromSlash(emit.SliceMvMkPath)))
	flach := strings.Join(strings.Fields(frag), " ")

	if !strings.Contains(flach, `test -f "$(SLICE_MV)"`) {
		t.Errorf("%s prueft die Anwesenheit des Werkzeugs nicht — ein fehlendes Werkzeug faellt dann erst im Interpreter auf", emit.SliceMvMkPath)
	}
	if !strings.Contains(flach, "liegt nicht") {
		t.Errorf("%s sagt den fehlenden Traeger nicht — der Abbruch nennt dann nicht, was fehlt", emit.SliceMvMkPath)
	}
}

// schritteIn zerlegt eine nummerierte Anleitung in ihre Schritte: Schluessel ist
// die Nummer, Wert der Text des Schrittes — die Zeile, die in Spalte 0 mit
// "<n>." beginnt, und alles, was folgt, bis die naechste solche Zeile kommt.
//
// GELESEN, NICHT GEZAEHLT: ein `strings.Count` ueber das ganze Dokument kann die
// Stelle nicht von einer Erwaehnung daneben unterscheiden. Der Anker dieses
// Waechters ist die Stelle, an der die Anleitung die Handlung vorschreibt — also
// der Schritt, in dem sie steht.
func schritteIn(text string) map[string]string {
	out := map[string]string{}
	aktuell := ""
	for _, line := range strings.Split(text, "\n") {
		if nr, ok := schrittNummer(line); ok {
			aktuell = nr
			out[aktuell] = ""
		}
		if aktuell != "" {
			out[aktuell] += line + "\n"
		}
	}
	return out
}

// schrittNummer liest "<n>. " am Zeilenanfang in Spalte 0 — die Form, in der die
// Anleitung ihre Schritte fuehrt. Eine eingerueckte Aufzaehlung im Fliesstext ist
// damit keine Schritt-Grenze, und eine Fortsetzungszeile ebenso wenig.
func schrittNummer(line string) (string, bool) {
	if line == "" || line[0] < '0' || line[0] > '9' {
		return "", false
	}
	i := strings.Index(line, ". ")
	if i <= 0 {
		return "", false
	}
	for _, r := range line[:i] {
		if r < '0' || r > '9' {
			return "", false
		}
	}
	return line[:i], true
}

// ohneKommentare entfernt HTML-Kommentare aus einem Text: eine Bemerkung im
// Kommentar ist keine Vorschrift. Ohne diesen Schnitt genuegte eine
// Ersatz-Nennung im ANPASSEN-Block, um einen Schritt als "nennt das Werkzeug"
// durchgehen zu lassen, waehrend sein Text die Handarbeit vorschreibt.
//
// Ein ungeschlossener Kommentar nimmt den Rest mit: die Form ist dann kaputt, und
// was danach kommt, ist nicht mehr als Vorschrift lesbar.
func ohneKommentare(text string) string {
	var b strings.Builder
	rest := text
	for {
		i := strings.Index(rest, "<!--")
		if i < 0 {
			b.WriteString(rest)
			return b.String()
		}
		b.WriteString(rest[:i])
		j := strings.Index(rest[i:], "-->")
		if j < 0 {
			return b.String()
		}
		rest = rest[i+j+3:]
	}
}

// TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen haelt den Lieferpunkt des
// Anweisungssatzes fest: der Lifecycle-Wechsel ist an den zwei Stellen, an denen
// die Anleitung ihn vorschreibt (Eintritt nach in-progress und Closure nach done),
// als Kommando benannt — und die repo-spezifische Stelle ist als Marker
// ausgewiesen, waehrend der Ziel-NAME ausdruecklich keiner ist.
//
// GEMESSEN WIRD JE SCHRITT UND AUSSERHALB DER KOMMENTARE. Zwei engere Anker, und
// beide sind noetig: ein Zaehler ueber das ganze Dokument bliebe gruen, waehrend
// Schritt 9 wieder die Handarbeit vorschreibt; und ein Schritt-Anker allein
// bliebe gruen, solange die Ersatz-Nennung im ANPASSEN-Kommentar desselben
// Schrittes steht. Eine Bemerkung ist keine Vorschrift.
//
// WAS DIESER TEST NICHT ENTSCHEIDET: ob die gefundene Nennung im Schritt die
// vorgeschriebene Handlung ist. Der Anker ist die Stelle ohne Kommentar; die
// Prosa daneben, die den Aufruf nur erwaehnt, waere ein Review-Griff.
//
// Die zweite Haelfte ist die tragende: der Ziel-Name kommt aus einem tool-eigenen
// Fragment, das jeder Bootstrap kanonisch neu schreibt. Eine Anleitung, die ihn
// als adaptierbar ausweist, laedt zu einer Umbenennung ein, die der naechste Lauf
// zuruecknimmt.
//
// Rot-Gegenbeispiel: test/mutations/345-lifecycle-anleitung-ohne-werkzeug.sh.
func TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen(t *testing.T) {
	anleitung := string(emit.CommandFile(".claude/commands/implement-slice.md"))
	if anleitung == "" {
		t.Fatal("die emittierte Anleitung ist leer — der Waechter misst nichts")
	}
	schritte := schritteIn(anleitung)

	// Vorbedingung: die zwei Schritte sind wirklich gelesen — ueber fehlenden
	// Schritten misst der Waechter nichts.
	eingangRoh, ok := schritte["9"]
	if !ok {
		t.Fatalf("Schritt 9 nicht gelesen — der Waechter misst dann keine Stelle")
	}
	verschlussRoh, ok := schritte["24"]
	if !ok {
		t.Fatalf("Schritt 24 nicht gelesen — der Waechter misst dann keine Stelle")
	}
	eingang := ohneKommentare(eingangRoh)
	verschluss := ohneKommentare(verschlussRoh)

	// Die vorgeschriebene Handlung, nicht die Erwaehnung: der Aufruf in seiner
	// vollen Form steht in jedem der zwei Schritte, und zwar im Text — nicht im
	// Kommentar daneben.
	if !strings.Contains(eingang, "make slice-mv SLICE=") {
		t.Errorf("Schritt 9 (Eintritt nach in-progress) nennt den Aufruf `make slice-mv SLICE=…` nicht in seinem Text — der Lifecycle-Wechsel steht dort als Handarbeit")
	}
	if !strings.Contains(verschluss, "make slice-mv SLICE=") || !strings.Contains(verschluss, "TO=done") {
		t.Errorf("Schritt 24 (Closure nach done) nennt den Aufruf `make slice-mv SLICE=… TO=done` nicht in seinem Text — die Closure steht dort als Handarbeit")
	}
	if strings.Contains(verschluss, "verschieben (`git mv`, eigener") {
		t.Errorf("Schritt 24 schreibt weiter den `git mv` von Hand vor")
	}

	// Der Marker steht an der Stelle daneben, an der die Adaption faellig wird,
	// und er weist den Ziel-Namen als NICHT-repo-spezifisch aus.
	if !strings.Contains(eingangRoh, "ANPASSEN") {
		t.Errorf("Schritt 9 traegt keinen ANPASSEN-Marker — die repo-spezifische Stelle ist dann nicht als solche erkennbar")
	}
	if !strings.Contains(eingangRoh, "Der Ziel-NAME `slice-mv` ist es nicht") {
		t.Errorf("Schritt 9 weist den Ziel-Namen nicht als NICHT-repo-spezifisch aus — er kommt aus einem tool-eigenen, kanonisch neu geschriebenen Fragment")
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
