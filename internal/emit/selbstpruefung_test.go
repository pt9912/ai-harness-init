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
var markerRe = regexp.MustCompile(`SELBSTPRUEFUNG_[A-Z]+`)

// TestSelbstpruefung_DieDreiMarkerStehenInBeidenDateienUndSonstKeiner haelt die
// Adaptierbarkeit an ihrer Verdrahtung fest: jeder der drei Marker hat im Fragment eine
// Belegung und wird durchgereicht, und die Vorlage liest ihn mit derselben Belegung.
//
// GEMESSEN WIRD DER VOLLSTAENDIGE IST-BESTAND gegen die erwartete Liste, in beide
// Richtungen: ein vierter Marker in einer der zwei Dateien faellt hier ebenso wie ein
// dritter, der nur noch in einer steht. Eine Pruefung, die nur die drei erwarteten
// Namen sucht, bliebe bei einer halben Umbenennung gruen.
//
// WAS DIESER TEST NICHT LEISTET: er misst die Verdrahtung, nicht die Wirkung. Dass ein
// GESETZTER Wert den Lauf lenkt und der Lauf ihn nennt, misst die Stufe im Voll-E2E
// (harness/tools/full-smoke.sh), die die Pruefung mit gesetztem Marker faehrt.
func TestSelbstpruefung_DieDreiMarkerStehenInBeidenDateienUndSonstKeiner(t *testing.T) {
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
