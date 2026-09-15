package emit_test

import (
	"io"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// zielArchiv ist der Name des Archivierungs-Kommandos im Ziel. Er steht hier als
// Name, weil er der Gegenstand der Waechter ist: gemessen wird, WO er auftaucht,
// nicht ob es ihn gibt.
const zielArchiv = "archive-welle"

// archivierungsFragment liest das abgelegte Fragment unter dir. GELESEN wird von
// der Platte: die Zusage gilt der Datei im Ziel, nicht dem Rueckgabewert einer
// Funktion.
func archivierungsFragment(t *testing.T, dir string) string {
	t.Helper()
	return mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.ArchivierungMkPath)))
}

// archivierungsFragmentMitTraeger faehrt einen echten Emit in ein frisches
// Verzeichnis, in dem die Traeger-Ablage gelingt.
func archivierungsFragmentMitTraeger(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	return archivierungsFragment(t, dir)
}

// gatesHuelle liefert die transitive Prerequisite-Huelle des emittierten
// `gates`-Ziels ueber JEDER Make-Quelle des Ziels. Sie wird GELESEN, nicht
// aufgezaehlt: eine im Test gepflegte Kette waechst nicht mit, wenn ein neues
// Fragment eine Kante dazunimmt.
func gatesHuelle(t *testing.T) map[string]bool {
	t.Helper()
	quellen := makeQuellenDesZiels(t)

	regeln := map[string][]string{}
	var checks []string
	for _, pfad := range sortierteSchluessel(quellen) {
		r, c := regelnIn(quellen[pfad])
		for k, v := range r {
			regeln[k] = append(regeln[k], v...)
		}
		checks = append(checks, c...)
	}

	huelle := map[string]bool{}
	offen := []string{"gates"}
	for len(offen) > 0 {
		aktuell := offen[0]
		offen = offen[1:]
		if huelle[aktuell] {
			continue
		}
		huelle[aktuell] = true
		for _, p := range regeln[aktuell] {
			if p == "$(GATE_CHECKS)" {
				offen = append(offen, checks...)
				continue
			}
			offen = append(offen, p)
		}
	}
	// Vorbedingung: die Huelle traegt wirklich die Gate-Kette — sie ist der
	// Pruefbereich des Waechters, und ein leeres Ergebnis hat keinen.
	for _, noetig := range []string{"record-gates", "baseline-verify", "docs-check"} {
		if !huelle[noetig] {
			t.Fatalf("die gelesene gates-Kette traegt %q nicht — der Waechter misst nichts (gelesen: %v)", noetig, sortiert(huelle))
		}
	}
	return huelle
}

// TestArchivierungFragment_LiegtAuchOhneTraeger haelt die Zusage fest, an der die
// Meldung des fehlenden Traegers haengt: das Fragment ist UNBEDINGT und teilt den
// Zweig des Traegers nicht.
//
// Das Fragment ist die Stelle, an der ein Ziel liest, dass die Archivierung nicht
// eingetreten ist — und der Fall des frischen Klons ist der, fuer den der Satz
// dasteht.
//
// Rot-Gegenbeispiel: test/mutations/334-archivierungs-fragment-am-traeger-zweig.sh.
func TestArchivierungFragment_LiegtAuchOhneTraeger(t *testing.T) {
	frag := archivierungsFragment(t, zielOhneTraeger(t))
	if !strings.Contains(frag, zielArchiv) {
		t.Errorf("%s liegt ohne abgelegten Traeger, nennt %q aber nicht — dem Ziel fehlt damit das Kommando, das ihm die fehlende Faehigkeit nennt:\n%s",
			emit.ArchivierungMkPath, zielArchiv, frag)
	}
}

// TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette haelt die zwei
// Adressen des Fragments fest: es definiert das Kommando, und es haengt an keiner
// Gate-Kante.
//
// Der Ablageort des Traegers steht NICHT als abgeschriebener Pfad im Waechter: er
// wird gegen emit.CarrierPath gehalten, denselben Ort, an den der Bootstrap den
// Traeger legt. Die zwei sind derselbe Ort, und beide werden hier gemessen.
//
// Rot-Gegenbeispiel: test/mutations/337-archivierung-haengt-an-gate-checks.sh.
func TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette(t *testing.T) {
	frag := archivierungsFragmentMitTraeger(t)

	regeln, checks := regelnIn(frag)
	if _, da := regeln[zielArchiv]; !da {
		t.Errorf("%s definiert das Ziel %q nicht — das Ziel-Repo hat damit kein Kommando:\n%s", emit.ArchivierungMkPath, zielArchiv, frag)
	}
	if len(checks) != 0 {
		t.Errorf("%s haengt %v an GATE_CHECKS — es traegt ein Kommando, kein Gate", emit.ArchivierungMkPath, checks)
	}
	if !strings.Contains(frag, "ARCHIV_CARRIER ?= "+emit.CarrierPath("ai-harness-init")+"\n") {
		t.Errorf("%s nennt als Ablageort nicht %q — gesucht wird damit an einem Ort, an dem der Bootstrap nichts ablegt:\n%s",
			emit.ArchivierungMkPath, emit.CarrierPath("ai-harness-init"), frag)
	}
	if huelle := gatesHuelle(t); huelle[zielArchiv] {
		t.Errorf("%q haengt in der gates-Kette des Ziels — die Archivierung prueft nichts: %v",
			zielArchiv, sortiert(huelle))
	}
}

// TestArchivierungFragment_TraegtPreisUndMeldung haelt zwei Aussagen ueber den
// emittierten Text fest, die kein Lauf dieses Repos sonst traegt:
//
//   - den Preis des Aufrufs (ADR-0033 Festlegung 5): dass er im VERSIONIERTEN
//     Baum bewegt, loescht und committet, dass er ausdruecklich gerufen wird und
//     dass ein Lauf ueber einem unsauberen Arbeitsbaum abbricht. Wo der Traeger
//     startet, ist in einem fremden Repo nicht ablesbar; der Satz steht darum im
//     Ziel geschrieben.
//   - den Zweig des fehlenden Traegers: er nennt den Ablageort und seine
//     Abhilfe. Beide Saetze stehen im Rezept; ob sie auch laufen, misst
//     harness/tools/full-smoke.sh am gebootstrappten Ziel.
//
// Rot-Gegenbeispiel: test/mutations/335-archivierungs-fragment-ohne-preis.sh.
func TestArchivierungFragment_TraegtPreisUndMeldung(t *testing.T) {
	frag := archivierungsFragmentMitTraeger(t)

	// Leerraum-normalisiert verglichen: WO das Fragment umbricht, ist
	// gleichgueltig; WAS es sagt, nicht.
	flach := strings.Join(strings.Fields(frag), " ")
	for _, satz := range []string{
		"IM VERSIONIERTEN BAUM DIESES REPOS",
		"loescht",
		"committet",
		"nur auf ausdruecklichen Aufruf",
		"unsauberen Arbeitsbaum",
	} {
		if !strings.Contains(flach, satz) {
			t.Errorf("%s nennt den Preis des Aufrufs nicht — es fehlt: %q", emit.ArchivierungMkPath, satz)
		}
	}
	if !strings.Contains(flach, "der Traeger liegt nicht") {
		t.Errorf("%s meldet den fehlenden Traeger nicht — dieser Zweig ist der Fall des frischen Klons", emit.ArchivierungMkPath)
	}
}
