package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestDCheckConfig_EntschiedeneModulListe haelt die entschiedene Modul-Liste fest: die
// eingebettete .d-check.yml aktiviert genau [links, anchors, ids, matrix, spans] — nicht
// "mindestens zwei Module". Jedes der drei neu aktivierten ist im frischen Ziel gemessen gruen UND
// faengt sein Gegenbeispiel (harness/tools/full-smoke.sh); dieser Test bindet nur die
// LISTE, nicht das Verhalten (das braucht Docker und liegt in full-smoke). codepaths
// bleibt aus — ihre Aktivierung ist eine eigene Entscheidung. Das Requirement-Muster
// von ids bleibt auskommentiert: das Praefix gehoert dem Adopter und ist in einem
// frischen Ziel nicht bekannt. Die
// spec-straten-Klasse traegt order:/direction: no-downward: die Baseline-Vorlage fuehrt
// beide im auskommentierten matrix-Block, und die Entscheidungsregel fuer emittierte
// Module bindet auf Modul-, nicht auf Positions-Ebene. exclude-sections traegt genau
// [Geschichte], nicht die weitere Dogfood-Liste und nicht leer.
func TestDCheckConfig_EntschiedeneModulListe(t *testing.T) {
	yml := emit.DCheckConfig()
	if !strings.Contains(yml, "modules: [links, anchors, ids, matrix, spans]") {
		t.Errorf("eingebettete .d-check.yml aktiviert nicht genau [links, anchors, ids, matrix, spans]:\n%s", yml)
	}
	sawPrefixPattern := false
	var letzteKlasse string
	for _, line := range strings.Split(yml, "\n") {
		if strings.HasPrefix(line, "codepaths:") {
			t.Errorf("codepaths unkommentiert aktiv im frischen Repo (halluziniertes Gate): %q", line)
		}
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "- {name: ") {
			letzteKlasse = trimmed
		}
		if strings.Contains(trimmed, "<PREFIX>") {
			sawPrefixPattern = true
			if !strings.HasPrefix(trimmed, "#") {
				t.Errorf("das Requirement-Muster von ids ist unkommentiert aktiv, obwohl das Praefix in einem frischen Ziel nicht bekannt ist: %q", line)
			}
		}
	}
	if !sawPrefixPattern {
		t.Errorf("das auskommentierte Requirement-Muster von ids fehlt ganz (kein <PREFIX> mehr in der Vorlage):\n%s", yml)
	}
	if !strings.Contains(yml, "regex: 'ADR-\\d{4}'") || !strings.Contains(yml, "link-policy: always") {
		t.Errorf("das ADR-Muster von ids fehlt oder traegt nicht link-policy: always:\n%s", yml)
	}
	if !strings.Contains(yml, "{from: adr, to: slice, allow: false}") || !strings.Contains(yml, "{from: adr, to: welle, allow: false}") {
		t.Errorf("die beiden neuen matrix-Regeln (adr->slice, adr->welle) fehlen:\n%s", yml)
	}
	if !strings.Contains(yml, "order: [spec/lastenheft.md, spec/spezifikation.md, spec/architecture.md]") || !strings.Contains(yml, "direction: no-downward") {
		t.Errorf("die Richtungspruefung (order:/direction: no-downward) auf spec-straten fehlt:\n%s", yml)
	}
	// Die Klasse aussen ist die LETZTE in classes: — sie faengt, was keine fruehere
	// faengt, und macht ihre Regel zur Decken-Regel. Steht sie nicht ganz unten, nimmt
	// sie den nachfolgenden Klassen ihre Dateien, und deren Regeln laufen leer.
	if !strings.Contains(yml, `- {name: aussen, paths: ["**"]}`) ||
		!strings.Contains(yml, "{from: spec-straten, to: aussen, allow: false}") {
		t.Errorf("die Klasse aussen oder ihre Regel aus spec-straten fehlt:\n%s", yml)
	}
	if !strings.HasPrefix(letzteKlasse, "- {name: aussen,") {
		t.Errorf("aussen ist nicht die letzte Klasse in classes: (letzte ist %q)", letzteKlasse)
	}
	// Die blosse MR-Kennung faengt im Ziel kein ids-Muster: die emittierte
	// harness/conventions.md nennt ihre eigenen Kennungen blank, ein solches Muster
	// liesse ein frisches Ziel rot starten. Der Fang haengt darum am token: dieser
	// Klasse, begrenzt durch die Regel aus spec-straten.
	if !strings.Contains(yml, `- {name: adaptionsblock, paths: ["harness/conventions.md", "harness/conventions/**"], token: 'MR-\d{3}'}`) ||
		!strings.Contains(yml, "{from: spec-straten, to: adaptionsblock, allow: false}") {
		t.Errorf("die Klasse adaptionsblock samt token: oder ihre Regel aus spec-straten fehlt:\n%s", yml)
	}
	// exempt-paths traegt genau zwei Pfade. Die Welle-Dateien in done/ gehoeren NICHT
	// dazu: im frischen Ziel hat die Ausnahme keinen Gegenstand und naehme der Klasse
	// welle ab dem ersten geschlossenen Buendel ihre Status-Deckung.
	if !strings.Contains(yml, `exempt-paths: ["docs/plan/adr/README.md", "docs/reviews/**"]`) {
		t.Errorf("matrix.exempt-paths traegt nicht genau [ADR-Index, Review-Reports]:\n%s", yml)
	}
	if strings.Contains(yml, "docs/plan/planning/done/welle-") {
		t.Errorf("die Welle-Dateien in done/ stehen in der emittierten Konfiguration (Status-Deckung der Klasse welle):\n%s", yml)
	}
	// exclude-sections traegt exakt [Geschichte] — weder leer (dann faengt
	// {from: adr, to: slice} auch die legitime, im Zeilen-Marker deklarierte
	// Provenance-Zeile der ADR-Geschichte-Tabelle) noch die weitere Dogfood-Liste
	// [Historie, "7. Historie", Geschichte] (die Spec-Straten-Vorlagen fuehren dort keine
	// Ausnahme, s. internal/emit/templates/d-check.yml Kopfkommentar).
	if !strings.Contains(yml, "exclude-sections: [Geschichte]") {
		t.Errorf("exclude-sections traegt nicht genau [Geschichte]:\n%s", yml)
	}
}

// TestDefaultDigest_MatchesCanonical haelt DoD-3/LH-QA-02 fest: der Default-Pin des
// Tools ist identisch zur kanonischen Pin-Quelle des Repos (./d-check.mk). Faengt
// Drift, wenn ./d-check.mk bei einem d-check-Bump neu gepinnt, das Tool aber vergessen wird.
func TestDefaultDigest_MatchesCanonical(t *testing.T) {
	canonical := mkVar(t, filepath.Join("..", "..", "d-check.mk"), "DCHECK_DIGEST")
	if !strings.HasPrefix(emit.DefaultDigest, "sha256:") {
		t.Errorf("emit.DefaultDigest nicht sha256-gepinnt: %q", emit.DefaultDigest)
	}
	if emit.DefaultDigest != canonical {
		t.Errorf("emit.DefaultDigest %q != kanonische Pin-Quelle %q (Drift)", emit.DefaultDigest, canonical)
	}
}

// TestDefaultImage_MatchesCanonical koppelt auch die Tag-Referenz an die kanonische
// ./d-check.mk (nicht nur den Digest) — Tag-Drift bliebe sonst unbemerkt (Review-L3).
func TestDefaultImage_MatchesCanonical(t *testing.T) {
	canonical := mkVar(t, filepath.Join("..", "..", "d-check.mk"), "DCHECK_IMAGE")
	if emit.DefaultImage != canonical {
		t.Errorf("emit.DefaultImage %q != kanonische Quelle %q (Tag-Drift)", emit.DefaultImage, canonical)
	}
}

// TestRunRef deckt die pure Referenz-Berechnung ab (die gepinnte repo@digest-Achse,
// LH-QA-02) — ohne Docker, also Tier-1 statt nur make smoke (Review-M1).
func TestRunRef(t *testing.T) {
	tests := []struct {
		name, image, digest, want string
	}{
		{"digest sticht tag", "ghcr.io/pt9912/d-check:v0.46.0", "sha256:abc", "ghcr.io/pt9912/d-check@sha256:abc"},
		{"ohne digest -> tag-referenz", "ghcr.io/pt9912/d-check:v0.46.0", "", "ghcr.io/pt9912/d-check:v0.46.0"},
		{"registry-port bleibt, nur tag entfernt", "reg.example:5000/d-check:v1", "sha256:xyz", "reg.example:5000/d-check@sha256:xyz"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := emit.Options{Image: tt.image, Digest: tt.digest}.RunRef()
			if got != tt.want {
				t.Errorf("RunRef() = %q, want %q", got, tt.want)
			}
		})
	}
}

// TestAdaptMK_Fixture prueft die vier MR-010-Handgriffe an einer echten
// --print-mk-Ausgabe (testdata/raw-print-mk.txt, v0.46.0): docs-check-Rename,
// Digest-Pin, doc-help-Grep, Adopter-Header — advisory doc-*-Targets unberuehrt.
func TestAdaptMK_Fixture(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "raw-print-mk.txt"))
	if err != nil {
		t.Fatalf("Fixture lesen: %v", err)
	}
	const digest = "sha256:deadbeef"
	got, err := emit.AdaptMK(raw, digest)
	if err != nil {
		t.Fatalf("AdaptMK: %v", err)
	}
	mk := string(got)

	wantContains := []string{
		"Emittiert von ai-harness-init",          // Adopter-Header ersetzt
		".PHONY: docs-check",                     // Rename (.PHONY)
		"docs-check: ## Doku-Referenzen",         // Rename (Target)
		"DCHECK_DIGEST ?= " + digest,             // Digest gepinnt
		"'^docs?-[a-z-]+:",                        // doc-help-Grep erweitert
		".PHONY: doc-trace",                      // advisory verbatim
		".PHONY: doc-help",                       // advisory verbatim
	}
	for _, w := range wantContains {
		if !strings.Contains(mk, w) {
			t.Errorf("adaptiertes Fragment enthaelt %q nicht:\n%s", w, mk)
		}
	}
	wantAbsent := []string{
		".PHONY: doc-check\n", // altes Befund-Gate-Target darf weg sein
		"DCHECK_DIGEST ?=\n",  // leere Pin-Zeile darf weg sein
		"d-check --print-mk (DC-FA-CLI-010)", // d-checks eigener Kopf ersetzt
	}
	for _, w := range wantAbsent {
		if strings.Contains(mk, w) {
			t.Errorf("adaptiertes Fragment enthaelt unerwartet noch %q", w)
		}
	}
}

// TestDocGate_FragmentWiresDocsCheck: das Doc-Gate-Fragment haengt docs-check an
// GATE_CHECKS und bindet d-check.mk ein — der netzlose Waechter auf die Verdrahtung
// (DocGate selbst braucht Docker; ersetzt zusammen mit full-smoke die Deckung des
// entfernten Mutations-Falls 21, Review-Befund slice-034 F-1). test/mutations/40 bricht
// die GATE_CHECKS-Zeile -> dieser Test wird rot.
func TestDocGate_FragmentWiresDocsCheck(t *testing.T) {
	frag := emit.DocGateMk()
	for _, want := range []string{"include d-check.mk", "GATE_CHECKS += docs-check"} {
		if !strings.Contains(frag, want) {
			t.Errorf("Doc-Gate-Fragment enthaelt %q nicht (docs-check nicht in gates verdrahtet):\n%s", want, frag)
		}
	}
}

// TestDocGateMk_BindetDenVorlaufWaechter: das Doc-Gate-Fragment haengt den Vorlauf-Waechter
// als Vorbedingung vor die zwei history-lesenden Targets — ohne deren Rezept anzuruehren
// (die Rezepte kommen aus dem tool-generierten d-check.mk und werden bei jedem Bootstrap
// kanonisch neu geschrieben).
//
// WOZU DER TEST, obwohl full-smoke die Wirkung faehrt: die Bindung ist eine Zeile, und eine
// verschwundene Zeile ist im gebootstrappten Ziel GRUEN — `make gates` faehrt keines der
// zwei Targets (beide brauchen eine RANGE). Der netzlose Waechter auf die Verdrahtung steht
// darum hier; die Wirkung (Abbruch ueber einer leeren Range) belegen
// harness/tools/full-smoke.sh und der Mutations-Fall 325.
func TestDocGateMk_BindetDenVorlaufWaechter(t *testing.T) {
	frag := emit.DocGateMk()
	// Eine Vorbedingungs-Zeile je history-lesendem Target. Fehlt eine, bleibt genau ein
	// Modul blind — und zwar das, dessen Target niemand mehr an den Waechter haengt.
	for _, want := range []string{"doc-immutable: history-range-guard", "doc-commits: history-range-guard"} {
		if !strings.Contains(frag, want) {
			t.Errorf("Doc-Gate-Fragment bindet den Vorlauf-Waechter nicht: %q fehlt:\n%s", want, frag)
		}
	}
	// Die Bindung steht NACH dem include: davor haengte sie an einem Target, das dieses
	// Fragment erst mit der eingebundenen Datei erhaelt.
	inkl, bindung := strings.Index(frag, "include d-check.mk"), strings.Index(frag, "doc-immutable: history-range-guard")
	if inkl < 0 || bindung < inkl {
		t.Errorf("die Bindung steht vor dem `include d-check.mk` (oder das include fehlt):\n%s", frag)
	}
	// Der Waechter ruft das EMITTIERTE Skript (tools/harness/, MR-005) — nicht den lokalen
	// Pfad dieses Repos.
	if !strings.Contains(frag, "tools/harness/history-range-guard.sh") {
		t.Errorf("der Waechter ruft nicht das emittierte Skript (tools/harness/, MR-005):\n%s", frag)
	}
	if strings.Contains(frag, "harness/tools/") {
		t.Errorf("das Fragment verweist auf das lokale harness/tools/ statt auf tools/harness/ (MR-005):\n%s", frag)
	}
	// KEIN GATE: die Range setzt der Aufrufer, ohne sie ist der Pruefbereich nicht
	// hermetisch (LH-QA-01) — ein `GATE_CHECKS += history-range-guard` waere ein Gate
	// ueber variablem Pruefbereich.
	for _, zeile := range strings.Split(frag, "\n") {
		if strings.HasPrefix(zeile, "GATE_CHECKS +=") && strings.Contains(zeile, "history-range-guard") {
			t.Errorf("der Vorlauf-Waechter haengt an GATE_CHECKS — die Range variiert pro Lauf:\n%s", frag)
		}
	}
}

func TestAdaptMK_MissingAnchor(t *testing.T) {
	if _, err := emit.AdaptMK([]byte("# voellig anderes Format\n"), "sha256:x"); err == nil {
		t.Error("AdaptMK: kein Fehler trotz fehlendem DCHECK_IMAGE-Anker")
	}
}

// TestAdaptMK_BrichtBeiFehlendemVorbindungsTarget: das Doc-Gate-Fragment haengt den
// Vorlauf-Waechter als Vorbedingung vor `doc-immutable` und `doc-commits`. Fuehrt das
// erzeugte d-check.mk eines der zwei Ziele nicht, hat die Vorbindungs-Zeile dort kein
// Rezept — `make` meldet ueber dem Ziel dann Exit 0 und faehrt allein den Waechter, wo es
// ohne die Zeile mit "Keine Regel" abbraeche (LH-QA-01, MR-017). Die Adaption bricht darum
// ab, statt das Fragment ueber dieser Luecke zu schreiben.
func TestAdaptMK_BrichtBeiFehlendemVorbindungsTarget(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "raw-print-mk.txt"))
	if err != nil {
		t.Fatalf("Fixture lesen: %v", err)
	}
	// Die unveraenderte --print-mk-Ausgabe traegt beide Ziele — die Adaption laeuft.
	if _, err := emit.AdaptMK(raw, "sha256:deadbeef"); err != nil {
		t.Fatalf("AdaptMK ueber der vollstaendigen Fixture: %v", err)
	}
	for _, ziel := range []string{"doc-immutable", "doc-commits"} {
		ohne := strings.Replace(string(raw), "\n"+ziel+":", "\n"+ziel+"_entfernt:", 1)
		if ohne == string(raw) {
			t.Fatalf("die Fixture fuehrt das Target %q nicht — der Fall misst nichts", ziel)
		}
		if _, err := emit.AdaptMK([]byte(ohne), "sha256:deadbeef"); err == nil {
			t.Errorf("AdaptMK ohne das Target %q: kein Fehler — die Vorbindung haette dort kein Rezept (LH-QA-01)", ziel)
		}
	}
}

// mkVar zieht den Wert einer `<name> ?= <wert>`-Zuweisung aus einem d-check.mk.
func mkVar(t *testing.T, mkPath, name string) string {
	t.Helper()
	data, err := os.ReadFile(mkPath)
	if err != nil {
		t.Fatalf("mk lesen (%s): %v", mkPath, err)
	}
	prefix := name + " ?= "
	for _, line := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(line, prefix) {
			return strings.TrimSpace(strings.TrimPrefix(line, prefix))
		}
	}
	t.Fatalf("%s nicht gefunden in %s", name, mkPath)
	return ""
}
