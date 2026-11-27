package gen_test

import (
	"regexp"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// TestInventoryRows_SollTragtDenPinDesFragments haelt die Umgebungs-Inventar-Zeilen
// gegen die PIN-STELLE des gerenderten Go-Code-Gate-Fragments: der Soll-Wert der
// Zeile ist der abgeleitete Wert der Pin-Zeile im Fragment, nicht ein zweiter Wert
// daneben (MR-098-Form: Pin legt fest, Check belegt). Gelesen wird der gerenderte
// Fragment-Text, nicht der Parameter — nur so faerbt eine Abweichung zwischen
// Zeilen-Builder und Pin-Stelle den Test rot.
//
// Rot-Zug: den Soll-Wert in gen.InventoryRows hart verdrahten (statt vom Pin
// abzuleiten) -> dieser Test wird rot.
func TestInventoryRows_SollTragtDenPinDesFragments(t *testing.T) {
	const version = "9.9.9"
	frag, fragErr := gen.CodeGateFragment("go", ".", version)
	if fragErr != nil {
		t.Fatalf("CodeGateFragment(go): %v", fragErr)
	}
	pinMuster := regexp.MustCompile(`(?m)^(GO_VERSION|GOLANGCI_LINT_VERSION) \?= (.+)$`)
	pins := map[string]string{}
	for _, m := range pinMuster.FindAllStringSubmatch(frag, -1) {
		pins[m[1]] = m[2]
	}
	if pins["GO_VERSION"] == "" || pins["GOLANGCI_LINT_VERSION"] == "" {
		t.Fatalf("das Fragment traegt die Pin-Stellen nicht: %v\n%s", pins, frag)
	}
	zeilen := gen.InventoryRows("go", version)
	soll := map[string]string{}
	for _, z := range zeilen {
		felder := regexp.MustCompile(`^[^|]+\|[^|]+\|[^|]+\|([^|]+)\|`).FindStringSubmatch(z)
		if felder == nil {
			t.Fatalf("Inventar-Zeile ohne Spaltenform: %q", z)
		}
		wert := felder[1]
		if nach, ok := cutPrefix(wert, "abgeleitet:"); !ok {
			t.Errorf("Inventar-Zeile traegt Soll ohne Pin-Herkunft: %q", wert)
		} else {
			soll[zeilenWerkzeug(z)] = nach
		}
	}
	if soll["go"] != pins["GO_VERSION"] {
		t.Errorf("go-Soll %q != Pin-Stelle %q — die Zeile traegt ein zweites Soll", soll["go"], pins["GO_VERSION"])
	}
	if soll["golangci-lint"] != pins["GOLANGCI_LINT_VERSION"] {
		t.Errorf("golangci-lint-Soll %q != Pin-Stelle %q", soll["golangci-lint"], pins["GOLANGCI_LINT_VERSION"])
	}
	if gen.InventoryRows("kotlin", version) != nil {
		t.Errorf("nicht-Go-Sprachen tragen keine Zeilen (die Skelett-Gates stehen nicht am Host-Weg)")
	}
}

// zeilenWerkzeug liefert den Werkzeugnamen der Inventar-Zeile (Spalte 1).
func zeilenWerkzeug(zeile string) string {
	for i, c := range zeile {
		if c == '|' {
			return zeile[:i]
		}
	}
	return zeile
}

// cutPrefix trennt ein Praefix samt Rest.
func cutPrefix(wert, praefix string) (string, bool) {
	if len(wert) >= len(praefix) && wert[:len(praefix)] == praefix {
		return wert[len(praefix):], true
	}
	return "", false
}
