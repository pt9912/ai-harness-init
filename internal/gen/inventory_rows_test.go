package gen_test

import (
	"os"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// TestInventoryRows_SollTragtDenPinDesFragments haelt die Umgebungs-Inventar-Zeilen
// gegen die PIN-STELLE des gerenderten Go-Code-Gate-Fragments: der Soll-Wert der
// Zeile ist der abgeleitete Wert der Pin-Zeile im Fragment, nicht ein zweiter Wert
// daneben (MR-098-Form: Pin legt fest, Check belegt). Gelesen wird der gerenderte
// Fragment-Text, nicht der Parameter — nur so faerbt eine Abweichung zwischen
// Zeilen-Builder und Pin-Stelle den Test rot. Verglichen wird in der Version-
// Ausgabe-Form: ein Tag-Praefix v der Pin-Stelle ist gestrichen, denn die exakte
// Pruefform vergleicht ohne Praefix (die Parity zur Lab-Fassung traegt der
// Dogfood-Form-Waechter unten).
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
	if soll["go"] != strings.TrimPrefix(pins["GO_VERSION"], "v") {
		t.Errorf("go-Soll %q != Pin-Stelle %q — die Zeile traegt ein zweites Soll", soll["go"], pins["GO_VERSION"])
	}
	if soll["golangci-lint"] != strings.TrimPrefix(pins["GOLANGCI_LINT_VERSION"], "v") {
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

// TestInventoryRows_SollTragtDieDogfoodForm haelt die Inventar-Zeilen der Emission
// GLEICH der Lab-Fassung (harness/tools/environment-inventory.txt): die zwei Formen
// derselben Zeile tragen dieselbe Soll-Form. Die exakte Pruefform vergleicht die
// Version-AUSGABE des PATH-Werkzeugs — diese traegt den Tag-Wert OHNE v-Praefix
// ("2.15.0"), ein Soll mit v-Praefix ("abgeleitet:v2.15.0") bleibt im Ziel rot,
// selbst mit exakt gepinntem Werkzeug. Der Abgleich liest die Lab-Zeile, nicht den
// Pin: eine Abweichung zwischen beiden Faassungen faerbt den Test rot.
//
// GRENZE (benannt): der Waechter misst Text-Parity der zwei Inventar-Fassungen,
// nicht die Version-Ausgabe des Hosts — die Version-Zeile im real gebootstrappten
// Ziel traegt der reale Lauf (LP2), nicht dieser Wächter.
func TestInventoryRows_SollTragtDieDogfoodForm(t *testing.T) {
	raw, err := os.ReadFile("../../harness/tools/environment-inventory.txt")
	if err != nil {
		t.Fatalf("Inventar der Lab-Fassung lesen: %v", err)
	}
	lab := map[string]string{}
	for _, z := range strings.Split(string(raw), "\n") {
		if z == "" || strings.HasPrefix(z, "#") {
			continue
		}
		name := z[:strings.Index(z, "|")]
		if name == "go" || name == "golangci-lint" {
			lab[name] = z
		}
	}
	if lab["golangci-lint"] == "" || lab["go"] == "" {
		t.Fatalf("die Lab-Fassung traegt go/golangci-lint-Zeilen nicht: %v", lab)
	}
	// Die go-Version der Lab-Fassung traegt die Dogfood-Pin-Stelle (GO_VERSION,
	// Makefile); ihre Form liest der Pinsync, nicht dieser Waechter. Die Zeilen der
	// Emission werden fuer DIESE Version gebaut — ihre Soll-Form muss der Lab-Form
	// byte-genau folgen, sonst faerbt der Abgleich (go-Soll unter dem eigenen Pin).
	const version = "1.27.4"
	emitZeilen := map[string]string{}
	for _, z := range gen.InventoryRows("go", version) {
		emitZeilen[zeilenWerkzeug(z)] = z
	}
	for _, name := range []string{"go", "golangci-lint"} {
		emitSoll := zeilenSoll(emitZeilen[name])
		labSoll := zeilenSoll(lab[name])
		if emitSoll != labSoll {
			t.Errorf("%s: das Soll der Emission (%q) traegt formhaft nicht das der Lab-Fassung (%q)", name, emitSoll, labSoll)
		}
	}
}

// zeilenSoll liest die Soll-Spalte (Feld 4) der `|`-getrennten Inventar-Zeile.
func zeilenSoll(zeile string) string {
	felder := strings.SplitN(zeile, "|", 5)
	if len(felder) < 4 {
		return ""
	}
	return felder[3]
}
