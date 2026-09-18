package emit_test

import (
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// e2eKopfzeile ist die Kopfzeile der Tabelle, die die emittierte Fassung schreibt. Sie
// steht hier als WOERTLICHE Erwartung, weil die Spaltenfolge die eine Zusage ist, die
// ein Leser der Sicht ohne den Erzeuger nachvollziehen kann. Dass die Fassung dieses
// Repos dieselbe Folge fuehrt, haelt test/e2e-abdeckung.bats ueber beiden Dateien —
// hier liegt der Zielbaum, dort der gepruefte.
const e2eKopfzeile = "| Spec-Kennung | Stufe | Ort | Kurzbeschreibung |"

// TestE2eAbdeckung_LiegtImZielMitDemModusIhrerRolle haelt fest, dass beide Dateien im
// Ziel liegen und der Modus zur Rolle passt: der Erzeuger wird gestartet und braucht das
// Ausfuehrungs-Bit, das Fragment wird von make gelesen und braucht keines.
//
// Warum das Bit hier gemessen wird: git transportiert vom Modus nur die
// Ausfuehrbarkeit. Ein verlorenes Bit liesse das Fragment auf ein Programm zeigen, das
// der Adopter nicht starten kann — und sein Abbruch-Zweig meldete das erst im Lauf.
func TestE2eAbdeckung_LiegtImZielMitDemModusIhrerRolle(t *testing.T) {
	dir := selbstpruefungZiel(t)

	skript := filepath.Join(dir, filepath.FromSlash(emit.E2eAbdeckungPath))
	info, err := os.Stat(skript)
	if err != nil {
		t.Fatalf("%s liegt nicht im Ziel: %v", emit.E2eAbdeckungPath, err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("%s ist nicht ausfuehrbar (%v) — das Fragment startet ihn als Programm",
			emit.E2eAbdeckungPath, info.Mode().Perm())
	}

	frag := filepath.Join(dir, filepath.FromSlash(emit.E2eAbdeckungMkPath))
	fi, err := os.Stat(frag)
	if err != nil {
		t.Fatalf("%s liegt nicht im Ziel: %v", emit.E2eAbdeckungMkPath, err)
	}
	if fi.Mode().Perm()&0o111 != 0 {
		t.Errorf("%s ist ausfuehrbar (%v) — ein Fragment wird gelesen, nicht gestartet",
			emit.E2eAbdeckungMkPath, fi.Mode().Perm())
	}
}

// TestE2eAbdeckung_StehtInDerInventurUndIstKonvergent haelt beide Pfade in der Menge,
// die ein Lauf anfasst, und ihre Klasse: die Emission bestimmt beide Orte, also wird
// eine aeltere Fassung im Ziel bei jedem Lauf geheilt.
func TestE2eAbdeckung_StehtInDerInventurUndIstKonvergent(t *testing.T) {
	t.Parallel()
	inventur := map[string]bool{}
	for _, p := range emit.EnforcePaths() {
		inventur[p] = true
	}
	for _, rel := range []string{emit.E2eAbdeckungPath, emit.E2eAbdeckungMkPath} {
		if !inventur[rel] {
			t.Errorf("%s steht nicht in EnforcePaths() — die Inventur nennt dann einen Pfad nicht, den der Lauf anfasst", rel)
		}
		if got := emit.PathClass(rel); got != emit.Konvergent {
			t.Errorf("%s traegt die Klasse %s, erwartet ist konvergent — sonst bleibt eine alte Fassung im Ziel stehen", rel, got)
		}
	}
}

// TestE2eAbdeckung_FragmentHaengtAnKeinerGateKetteDesZiels liest die transitive Huelle
// von `gates` ueber den emittierten make-Quellen: das Kommando darf darin nicht
// vorkommen.
//
// Warum das die Zusage traegt: der Erzeuger urteilt ueber den QUELLTEXT des E2E-Skripts,
// nicht ueber den Zustand des Baums. An der Gate-Kette faerbte er rot, weil jemand eine
// Deklaration noch nicht geschrieben hat — ein Gate ohne Deckung (LH-QA-01). Die
// Vorbedingung, dass die gelesene Huelle wirklich die Gate-Kette traegt, prueft
// gatesHuelle selbst.
func TestE2eAbdeckung_FragmentHaengtAnKeinerGateKetteDesZiels(t *testing.T) {
	huelle := gatesHuelle(t)
	if huelle["e2e-abdeckung"] {
		t.Errorf("die gates-Kette des Ziels nennt e2e-abdeckung — der Erzeuger liest Quelltext und urteilt nicht ueber den Zustand des Baums (LH-QA-01). Gelesene Huelle: %v",
			sortiert(huelle))
	}
}

// e2eMarkerRe findet jeden Marker-Namen in Vorlage und Fragment. Gesucht wird der ganze
// Bestand, nicht die erwartete Liste: nur so faellt auch ein Name, den eine der zwei
// Dateien fuehrt und die andere nicht kennt.
var e2eMarkerRe = regexp.MustCompile(`E2E_ABDECKUNG_[A-Z]+(?:_[A-Z]+)*`)

// TestE2eAbdeckung_DieMarkerStehenInBeidenDateienUndSonstKeiner haelt die
// Adaptierbarkeit an ihrer Verdrahtung fest: jeder Marker hat im Fragment eine Belegung
// und wird durchgereicht, und die Vorlage liest ihn mit derselben Belegung.
//
// GEMESSEN WIRD DER VOLLSTAENDIGE IST-BESTAND gegen die erwartete Liste, in beide
// Richtungen: ein weiterer Marker in einer der zwei Dateien faellt hier ebenso wie einer,
// der nur noch in einer steht. Eine Pruefung, die nur die erwarteten Namen sucht, bliebe
// bei einer halben Umbenennung gruen.
//
// WAS DIESER TEST NICHT LEISTET: er misst die Verdrahtung, nicht die Wirkung. Dass ein
// GESETZTER Wert den Lauf lenkt, misst die Stufe im Voll-E2E (harness/tools/full-smoke.sh)
// am gebootstrappten Ziel.
func TestE2eAbdeckung_DieMarkerStehenInBeidenDateienUndSonstKeiner(t *testing.T) {
	dir := selbstpruefungZiel(t)
	skript := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.E2eAbdeckungPath)))
	frag := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.E2eAbdeckungMkPath)))

	erwartet := append([]string(nil), emit.E2eAbdeckungMarker()...)
	sort.Strings(erwartet)

	for name, text := range map[string]string{
		emit.E2eAbdeckungPath:   skript,
		emit.E2eAbdeckungMkPath: frag,
	} {
		gefunden := map[string]bool{}
		for _, m := range e2eMarkerRe.FindAllString(text, -1) {
			gefunden[m] = true
		}
		ist := make([]string, 0, len(gefunden))
		for m := range gefunden {
			ist = append(ist, m)
		}
		sort.Strings(ist)
		if strings.Join(ist, ",") != strings.Join(erwartet, ",") {
			t.Errorf("%s fuehrt die Marker %v, erwartet ist %v — Vorlage und Fragment tragen dieselbe Liste, sonst reicht das Fragment einen Namen durch, den die Vorlage nicht liest (oder umgekehrt)",
				name, ist, erwartet)
		}
	}

	// Jeder Marker hat im Fragment eine `?=`-Belegung: ohne sie ist er kein Default,
	// sondern ein leerer Wert, den das Rezept weiterreicht.
	for _, m := range erwartet {
		if !strings.Contains(frag, m+" ?= ") {
			t.Errorf("%s traegt fuer %s keine `?=`-Belegung — ein durchgereichter leerer Wert ist kein Default", emit.E2eAbdeckungMkPath, m)
		}
	}
}

// TestE2eAbdeckung_VorlageSchreibtDieVereinbarteSpaltenfolge haelt die Kopfzeile der
// Tabelle fest, die die emittierte Fassung schreibt. Sie ist das einzige Stueck der
// Sicht, das ein Leser ohne den Erzeuger gegen eine Erwartung halten kann — und die
// Stelle, an der die zwei Fassungen desselben Werkzeugs auseinanderlaufen wuerden.
func TestE2eAbdeckung_VorlageSchreibtDieVereinbarteSpaltenfolge(t *testing.T) {
	t.Parallel()
	vorlage := string(emit.EnforceFile(emit.E2eAbdeckungPath))
	if vorlage == "" {
		t.Fatalf("%s liefert keinen eingebetteten Inhalt", emit.E2eAbdeckungPath)
	}
	if !strings.Contains(vorlage, `echo "`+e2eKopfzeile+`"`) {
		t.Errorf("die Vorlage schreibt die Kopfzeile %q nicht — die Spaltenfolge der emittierten Sicht weicht dann von der dieses Repos ab", e2eKopfzeile)
	}
}
