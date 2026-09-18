package emit_test

import (
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// selbstpruefungZiel faehrt einen echten Emit in ein frisches Verzeichnis und liefert
// dessen Wurzel. GELESEN wird von der Platte: die Zusage gilt den zwei Dateien im Ziel,
// nicht dem Rueckgabewert einer Funktion.
func selbstpruefungZiel(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	return dir
}

// TestSelbstpruefung_LiegtImZielMitDemModusIhrerRolle haelt fest, dass beide Dateien im
// Ziel liegen und der Modus zur Rolle passt: das Skript wird gestartet und braucht das
// Ausfuehrungs-Bit, das Fragment wird von make gelesen und braucht keines.
//
// Warum das Bit hier gemessen wird: git transportiert vom Modus nur die
// Ausfuehrbarkeit. Ein verlorenes Bit liesse das Fragment auf ein Programm zeigen, das
// der Adopter nicht starten kann — und sein Abbruch-Zweig meldete das erst im Lauf.
func TestSelbstpruefung_LiegtImZielMitDemModusIhrerRolle(t *testing.T) {
	dir := selbstpruefungZiel(t)

	skript := filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungPath))
	info, err := os.Stat(skript)
	if err != nil {
		t.Fatalf("%s liegt nicht im Ziel: %v", emit.SelbstpruefungPath, err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("%s ist nicht ausfuehrbar (%v) — das Fragment startet sie als Programm",
			emit.SelbstpruefungPath, info.Mode().Perm())
	}

	frag := filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungMkPath))
	fi, err := os.Stat(frag)
	if err != nil {
		t.Fatalf("%s liegt nicht im Ziel: %v", emit.SelbstpruefungMkPath, err)
	}
	if fi.Mode().Perm()&0o111 != 0 {
		t.Errorf("%s ist ausfuehrbar (%v) — ein Fragment wird gelesen, nicht gestartet",
			emit.SelbstpruefungMkPath, fi.Mode().Perm())
	}
}

// TestSelbstpruefung_StehtInDerInventurUndIstKonvergent haelt beide Pfade in der Menge,
// die ein Lauf anfasst, und ihre Klasse: die Emission bestimmt beide Orte, also wird
// eine aeltere Fassung im Ziel bei jedem Lauf geheilt. Die skip-if-present-Klasse des
// Commit-Traegers faerbt nicht auf sie ab.
func TestSelbstpruefung_StehtInDerInventurUndIstKonvergent(t *testing.T) {
	t.Parallel()
	inventur := map[string]bool{}
	for _, p := range emit.EnforcePaths() {
		inventur[p] = true
	}
	for _, rel := range []string{emit.SelbstpruefungPath, emit.SelbstpruefungMkPath} {
		if !inventur[rel] {
			t.Errorf("%s steht nicht in EnforcePaths() — die Inventur nennt dann einen Pfad nicht, den der Lauf anfasst", rel)
		}
		if got := emit.PathClass(rel); got != emit.Konvergent {
			t.Errorf("%s traegt die Klasse %s, erwartet ist konvergent — sonst bleibt eine alte Fassung im Ziel stehen", rel, got)
		}
	}
}

// TestSelbstpruefung_FragmentHaengtAnKeinerGateKetteDesZiels liest die transitive Huelle
// von `gates` ueber den emittierten make-Quellen: das Kommando darf darin nicht
// vorkommen.
//
// Warum das die Zusage traegt: die Pruefung legt einen eigenen Klon an und faehrt darin
// ein Gate-Kommando. Haengte sie an `gates`, fuehrte jeder Gate-Lauf des Ziels einen
// Klon mit, und ein rotes Ziel-Gate waere von einem roten Klon-Lauf nicht mehr zu
// unterscheiden. Die Vorbedingung — dass die gelesene Huelle wirklich die Gate-Kette
// traegt — prueft gatesHuelle selbst.
func TestSelbstpruefung_FragmentHaengtAnKeinerGateKetteDesZiels(t *testing.T) {
	huelle := gatesHuelle(t)
	if huelle["selbstpruefung"] {
		t.Errorf("die gates-Kette des Ziels nennt selbstpruefung — sie legt einen Klon an und faehrt darin ein Gate; in der Kette waere jeder Gate-Lauf ein doppelter (LH-QA-01). Gelesene Huelle: %v",
			sortiert(huelle))
	}
}

// markerRe findet jeden Marker-Namen in Vorlage und Fragment. Gesucht wird der ganze
// Bestand, nicht die erwartete Liste: nur so faellt auch ein Name, den eine der zwei
// Dateien fuehrt und die andere nicht kennt.
var markerRe = regexp.MustCompile(`SELBSTPRUEFUNG_[A-Z]+(?:_[A-Z]+)*`)

// TestSelbstpruefung_DieMarkerStehenInBeidenDateienUndSonstKeiner haelt die
// Adaptierbarkeit an ihrer Verdrahtung fest: jeder Marker hat im Fragment eine Belegung
// und wird durchgereicht, und die Vorlage liest ihn mit derselben Belegung.
//
// GEMESSEN WIRD DER VOLLSTAENDIGE IST-BESTAND gegen die erwartete Liste, in beide
// Richtungen: ein weiterer Marker in einer der zwei Dateien faellt hier ebenso wie einer,
// der nur noch in einer steht. Eine Pruefung, die nur die erwarteten Namen sucht, bliebe
// bei einer halben Umbenennung gruen.
//
// WAS DIESER TEST NICHT LEISTET: er misst die Verdrahtung, nicht die Wirkung. Dass ein
// GESETZTER Wert den Lauf lenkt und der Lauf ihn nennt, misst die Stufe im Voll-E2E
// (harness/tools/full-smoke.sh): sie faehrt die Pruefung mit gesetztem Gate-Marker und
// liest die AUSGABE des gefahrenen Kommandos, und sie faehrt sie mit einem Traeger-Marker,
// der auf eine andere Datei zeigt, und verlangt den Abbruch.
func TestSelbstpruefung_DieMarkerStehenInBeidenDateienUndSonstKeiner(t *testing.T) {
	dir := selbstpruefungZiel(t)
	skript := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungPath)))
	frag := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungMkPath)))

	erwartet := append([]string(nil), emit.SelbstpruefungMarker()...)
	sort.Strings(erwartet)

	for name, text := range map[string]string{
		emit.SelbstpruefungPath:   skript,
		emit.SelbstpruefungMkPath: frag,
	} {
		gefunden := map[string]bool{}
		for _, m := range markerRe.FindAllString(text, -1) {
			gefunden[m] = true
		}
		ist := make([]string, 0, len(gefunden))
		for m := range gefunden {
			ist = append(ist, m)
		}
		sort.Strings(ist)
		if strings.Join(ist, " ") != strings.Join(erwartet, " ") {
			t.Errorf("%s fuehrt die Marker %v, erwartet sind %v — ein Marker, den nur eine der zwei Dateien kennt, ist nicht adaptierbar, sondern tot",
				name, ist, erwartet)
		}
	}

	for _, m := range emit.SelbstpruefungMarker() {
		if !strings.Contains(frag, m+" ?=") {
			t.Errorf("%s belegt %s nicht mit `?=` — ohne Belegung ist der Marker keine Vorgabe, sondern eine Pflicht am Aufruf",
				emit.SelbstpruefungMkPath, m)
		}
		if !strings.Contains(frag, "$("+m+")") {
			t.Errorf("%s reicht %s nicht an die Vorlage durch — am Aufruf gesetzt bliebe er wirkungslos",
				emit.SelbstpruefungMkPath, m)
		}
		if !strings.Contains(skript, "${"+m+":-") {
			t.Errorf("%s liest %s nicht mit eigener Belegung — ohne sie faellt ein direkter Aufruf ueber `set -u`",
				emit.SelbstpruefungPath, m)
		}
	}
}

// TestSelbstpruefung_FragmentRuftDenEmittiertenOrt haelt die zwei Dateien aneinander:
// das Fragment startet genau den Pfad, an dem derselbe Lauf die Vorlage ablegt.
//
// DAS LOKALE LAYOUT IST NICHT DAS EMITTIERTE (MR-005): nennt eine der zwei Dateien
// harness/tools/, zeigt sie in einem gebootstrappten Ziel ins Leere.
func TestSelbstpruefung_FragmentRuftDenEmittiertenOrt(t *testing.T) {
	dir := selbstpruefungZiel(t)
	skript := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungPath)))
	frag := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.SelbstpruefungMkPath)))

	if !strings.Contains(frag, "bash "+emit.SelbstpruefungPath) {
		t.Errorf("%s startet %s nicht — das Kommando zeigt damit auf einen Ort, an dem der Bootstrap nichts ablegt (LH-QA-01):\n%s",
			emit.SelbstpruefungMkPath, emit.SelbstpruefungPath, frag)
	}
	for name, text := range map[string]string{
		emit.SelbstpruefungPath:   skript,
		emit.SelbstpruefungMkPath: frag,
	} {
		if strings.Contains(text, "harness/tools/") {
			t.Errorf("%s nennt das lokale harness/tools/ (MR-005, emittiertes Layout ist tools/harness/)", name)
		}
	}
}

// TestSelbstpruefung_EinEditIstNachDemNaechstenLaufWiederDieAusgelieferteFassung misst die
// Folge der konvergenten Klasse: beide Dateien werden bei jedem Lauf kanonisch neu
// geschrieben, ein Edit an ihnen ist danach weg. Das ist der Grund, warum die
// anpassbaren Stellen VARIABLEN sind und kein Text zum Suchen-und-Ersetzen — und beide
// Dateien sagen es in ihrem Kopf, damit ein Adopter seine dauerhafte Vorgabe nicht dorthin
// schreibt, wo der naechste Lauf sie nimmt.
//
// Zwei Haelften, und die zweite ist die schwaechere: der Ueberschreib-Vorgang ist
// gemessen, die Anwesenheit des Satzes darueber nur als Wort geprueft. Ein Kopf, der die
// Klasse gar nicht mehr nennt, faellt; einer, der sie falsch erklaert, nicht.
func TestSelbstpruefung_EinEditIstNachDemNaechstenLaufWiederDieAusgelieferteFassung(t *testing.T) {
	dir := selbstpruefungZiel(t)
	kanonisch := map[string]string{}
	for _, rel := range []string{emit.SelbstpruefungPath, emit.SelbstpruefungMkPath} {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		kanonisch[rel] = mustReadString(t, p)
		if !strings.Contains(strings.ToLower(kanonisch[rel]), "konvergent") {
			t.Errorf("%s nennt seine Idempotenz-Klasse nicht — ein Adopter setzt seine Vorgabe dann in eine Datei, die der naechste Lauf neu schreibt (ADR-0007 Festlegung 3)", rel)
		}
		if err := os.WriteFile(p, []byte(kanonisch[rel]+"\n# Fassung des Adopters\n"), 0o644); err != nil {
			t.Fatalf("%s aendern: %v", rel, err)
		}
	}

	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("zweiter Enforce: %v", err)
	}

	for rel, soll := range kanonisch {
		ist := mustReadString(t, filepath.Join(dir, filepath.FromSlash(rel)))
		if ist != soll {
			t.Errorf("%s ist nach dem zweiten Lauf nicht die ausgelieferte Fassung — dann ist die Klasse nicht konvergent, und der Kopf der Datei sagt etwas anderes zu", rel)
		}
	}
}

// TestSelbstpruefung_DerGenannteVorgabeOrtWirdVonKeinemLaufGeschrieben haelt die zweite
// Haelfte der Klassen-Zusage: die Koepfe nennen einen Ort fuer eine DAUERHAFTE
// Marker-Vorgabe, und der traegt nur, wenn kein Lauf des Werkzeugs ihn anfasst.
//
// GEMESSEN WIRD DER ORT, NICHT EIN WORT: der genannte Pfad wird gegen die Pfad-Mengen
// gehalten, die ein Lauf schreibt. Ein Kopf, der stattdessen das Root-Makefile oder eine
// der zwei eigenen Dateien naennte, faellt hier — genau die Klasse, die der Kopf erklaert.
//
// GRENZE: geprueft sind die Mengen, die dieses Paket kennt (Durchsetzungsschicht,
// Commands, Rollen-Typen, Aggregator). Die Code-Gate-Fragmente, die das Sprach-Skelett
// unter harness/mk/ ablegt, tragen den Namen ihres Moduls und stehen in keiner von
// ihnen; ein Adopter, der sein Modul so nennt wie diesen Ort, kollidiert mit ihnen, und
// das faengt kein Test hier.
func TestSelbstpruefung_DerGenannteVorgabeOrtWirdVonKeinemLaufGeschrieben(t *testing.T) {
	dir := selbstpruefungZiel(t)
	for _, rel := range []string{emit.SelbstpruefungPath, emit.SelbstpruefungMkPath} {
		text := mustReadString(t, filepath.Join(dir, filepath.FromSlash(rel)))
		if !strings.Contains(text, emit.SelbstpruefungVorgabeOrt) {
			t.Errorf("%s nennt %s nicht als Ort der dauerhaften Vorgabe — ohne einen tragenden Ort steht die Vorgabe in einer Datei, die der naechste Lauf neu schreibt",
				rel, emit.SelbstpruefungVorgabeOrt)
		}
	}

	geschrieben := append([]string{emit.MakefilePath}, emit.EnforcePaths()...)
	geschrieben = append(geschrieben, emit.CommandPaths()...)
	geschrieben = append(geschrieben, emit.AgentPaths()...)
	for _, p := range geschrieben {
		if p == emit.SelbstpruefungVorgabeOrt {
			t.Errorf("%s wird von einem Lauf geschrieben — eine Vorgabe dort ist nach dem naechsten Bootstrap weg, und die Koepfe nennen sie trotzdem als dauerhaften Ort",
				emit.SelbstpruefungVorgabeOrt)
		}
	}
	// Vorbedingung: eine leere Menge liesse die Schleife oben still gruen.
	if len(geschrieben) < 2 {
		t.Fatalf("die gelesene Menge geschriebener Pfade traegt %d Eintraege — der Abgleich prueft dann nichts", len(geschrieben))
	}
}
