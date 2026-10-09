package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestDCheckConfig_EntschiedeneModulListe haelt die entschiedene Modul-Liste fest: die
// eingebettete .d-check.yml aktiviert genau [links, anchors, ids, matrix, codepaths, spans, planning, structure, targets] — nicht
// "mindestens zwei Module". Jedes neu aktivierte Modul ist im frischen Ziel gemessen gruen UND
// faengt sein Gegenbeispiel (harness/tools/full-smoke.sh); dieser Test bindet nur die
// LISTE, nicht das Verhalten (das braucht Docker und liegt in full-smoke). codepaths
// ist aktiv, sein Block traegt genau die roots [spec, docs, harness] und nimmt docs/reviews/**
// per exempt-paths aus. Das Requirement-Muster
// von ids bleibt auskommentiert: das Praefix gehoert dem Adopter und ist in einem
// frischen Ziel nicht bekannt. Die
// spec-straten-Klasse traegt order:/direction: no-downward: die Baseline-Vorlage fuehrt
// beide im auskommentierten matrix-Block, und die Entscheidungsregel fuer emittierte
// Module bindet auf Modul-, nicht auf Positions-Ebene. exclude-sections traegt genau
// [Geschichte], nicht die weitere Dogfood-Liste und nicht leer.
func TestDCheckConfig_EntschiedeneModulListe(t *testing.T) {
	yml := emit.DCheckConfig()
	if !strings.Contains(yml, "modules: [links, anchors, ids, matrix, codepaths, spans, planning, structure, targets]") {
		t.Errorf("eingebettete .d-check.yml aktiviert nicht genau [links, anchors, ids, matrix, codepaths, spans, planning, structure, targets]:\n%s", yml)
	}
	sawPrefixPattern := false
	// letzteKlasse haelt die LETZTE Klassen-Zeile — nur innerhalb von matrix.classes:,
	// sonst zaehlte jede spaetere Liste mit und die Positions-Zusicherung darunter
	// pruefte eine andere Stelle als die, ueber die sie spricht.
	var letzteKlasse string
	inClasses := false
	// idsADR haelt das ADR-Muster innerhalb des ids:-Blocks — nur dort, denn der Kommentar
	// der Vorlage nennt link-policy: always ebenfalls, und ein Contains ueber die ganze
	// Datei bliebe bei link-policy: never auf dieser Zeile erfuellt.
	var idsADR string
	inIDs := false
	if !strings.Contains(yml, "\ncodepaths:\n  roots: [spec, docs, harness]\n  exempt-paths: [\"docs/reviews/**\"]\n") {
		t.Errorf("der Block codepaths: ist nicht aktiv oder traegt nicht genau roots: [spec, docs, harness] und exempt-paths: [\"docs/reviews/**\"]:\n%s", yml)
	}
	for _, line := range strings.Split(yml, "\n") {
		if line != "" && line[0] != ' ' && line[0] != '#' {
			inIDs = strings.HasPrefix(line, "ids:")
		}
		trimmed := strings.TrimSpace(line)
		if inIDs && strings.HasPrefix(trimmed, "- {regex: 'ADR-") {
			idsADR = trimmed
		}
		switch trimmed {
		case "classes:":
			inClasses = true
		case "rules:":
			inClasses = false
		}
		if inClasses && strings.HasPrefix(trimmed, "- {name: ") {
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
	if !strings.Contains(idsADR, "link-policy: always") {
		t.Errorf("das ADR-Muster von ids traegt nicht link-policy: always (Zeile: %q):\n%s", idsADR, yml)
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
	} else if !strings.HasPrefix(letzteKlasse, "- {name: aussen,") {
		// Ordnung setzt Vorhandensein voraus: fehlt die Klasse, sagt der Zweig darueber
		// bereits alles, und eine zweite Meldung derselben Ursache naehme dieser hier
		// ihren eigenen Fall in test/mutations/.
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
		t.Errorf("der Welle-Pfad wird in der emittierten Konfiguration genannt — auch eine Nennung im Kommentar faengt diese Zusicherung, und als Ausnahme naehme er der Klasse welle ihre Status-Deckung:\n%s", yml)
	}
	// exclude-sections traegt exakt [Geschichte] — weder leer (dann faengt
	// {from: adr, to: slice} auch die legitime, im Zeilen-Marker deklarierte
	// Provenance-Zeile der ADR-Geschichte-Tabelle) noch die weitere Dogfood-Liste
	// [Historie, "7. Historie", "8. Historie", Geschichte] (die Spec-Straten-Vorlagen fuehren dort keine
	// Ausnahme, s. internal/emit/templates/d-check.yml Kopfkommentar).
	if !strings.Contains(yml, "exclude-sections: [Geschichte]") {
		t.Errorf("exclude-sections traegt nicht genau [Geschichte]:\n%s", yml)
	}
}

// TestDCheckConfig_PlanningBlock haelt den Top-Level-Block planning: der eingebetteten
// .d-check.yml (LH-FA-03): roadmap zeigt auf die emittierte Roadmap, heading und marker sind
// dieselben Wortlaute, die die Roadmap-Emission setzt (emit.RoadmapOffeneWellen,
// emit.RoadmapRuheMarker), und der Block fuehrt weder closure noch waves. Er liest die
// Vorlage; das Verhalten im Ziel belegt die full-smoke-Stufe planning_im_ziel.
func TestDCheckConfig_PlanningBlock(t *testing.T) {
	yml := emit.DCheckConfig()
	felder := map[string]string{}
	inBlock := false
	for _, line := range strings.Split(yml, "\n") {
		if line != "" && line[0] != ' ' && line[0] != '#' {
			inBlock = line == "planning:"
			continue
		}
		if !inBlock || !strings.HasPrefix(line, "  ") || strings.HasPrefix(line, "   ") {
			continue
		}
		k, v, ok := strings.Cut(strings.TrimSpace(line), ":")
		if !ok {
			continue
		}
		felder[k] = strings.Trim(strings.TrimSpace(v), `"`)
	}
	want := map[string]string{
		"roadmap": "docs/plan/planning/in-progress/roadmap.md",
		"heading": emit.RoadmapOffeneWellen,
		"marker":  emit.RoadmapRuheMarker,
	}
	for k, v := range want {
		if felder[k] != v {
			t.Errorf("planning.%s = %q, erwartet %q", k, felder[k], v)
		}
	}
	for k := range felder {
		if _, ok := want[k]; !ok {
			t.Errorf("planning traegt das Feld %q ueber roadmap/heading/marker hinaus", k)
		}
	}
}

// TestInjectRoadmapRuheMarker haelt den Ruhe-Marker im Abschnitt "## Offene Wellen" der
// emittierten Roadmap (LH-FA-03, LH-FA-02): genau einmal, innerhalb des Abschnitts, und ein
// zweiter Aufruf setzt ihn nicht doppelt. Der Ausschnitt folgt dem Abschnitt der Vorlage
// nach den Neutralisierungen (Regel-Zeile, entlinkter Platzhalter, naechste Ueberschrift).
func TestInjectRoadmapRuheMarker(t *testing.T) {
	in := "# Roadmap\n\n## Offene Wellen\n\nRegeln dieser Sektion: Text.\n\n- <welle-id>\n\n## Nächste Wellen\n\n| Welle |\n"
	got := emit.InjectRoadmapRuheMarker(in)
	start := strings.Index(got, "## Offene Wellen")
	ende := strings.Index(got, "## Nächste Wellen")
	if start < 0 || ende < start {
		t.Fatalf("Abschnitte fehlen:\n%s", got)
	}
	abschnitt := got[start:ende]
	if n := strings.Count(abschnitt, "\n"+emit.RoadmapRuheMarker+"\n"); n != 1 {
		t.Errorf("Abschnitt Offene Wellen traegt den Ruhe-Marker %d-mal als eigene Zeile statt einmal:\n%s", n, got)
	}
	if strings.Count(got, emit.RoadmapRuheMarker) != 1 {
		t.Errorf("der Ruhe-Marker steht ausserhalb des Abschnitts:\n%s", got)
	}
	if again := emit.InjectRoadmapRuheMarker(got); again != got {
		t.Errorf("zweiter Aufruf veraendert den Text:\n%s", again)
	}
	if ohne := "# Roadmap\n\n## Aktuelle Welle\n\n- x\n"; emit.InjectRoadmapRuheMarker(ohne) != ohne {
		t.Errorf("ohne die Ueberschrift veraendert die Injektion den Text")
	}
}

// TestDCheckConfig_KennungsForm haelt die Kennungs-Form der eingebetteten .d-check.yml fest
// (LH-FA-03): Praefix-Token auf den Klassen slice und welle, die Regel spec-straten -> welle,
// das segment-tolerante ADR-Muster von ids und die Klasse adr mit dem Bereichs-Praefix-Glob.
// Der Test bindet die MENGE der Token und der Regeln der matrix, nicht die Namen einzelner
// Zeilen: jede erwartete Regel steht in der Liste, keine weitere steht daneben, und die
// Ziffern-Form kommt ausserhalb der Klassen-Zeilen nirgends vor. Er liest die Vorlage, nicht
// das Verhalten im Ziel; das Verhalten belegt die full-smoke-Stufe der Kennungs-Form.
//
// Jede Zusicherung urteilt ueber genau eine Stelle; die acht Faelle 435 bis 442 faerben
// darum je genau einen Unterfall, eine Mutation ausserhalb der Faelle kann mehrere faerben
// (ein Token ganz weg faerbt token_slice und token_menge). Die Stellen: die Token je Klasse
// (token_slice, token_welle), die Zahl der Token
// (token_menge), je erwartete Regel eine Zusicherung, die Regeln ausserhalb der Liste
// (regel_menge), das ids-Muster, die Klasse adr und die Ziffern-Form in allen uebrigen Zeilen.
// Rot-Gegenbeispiele: test/mutations/435-emittierte-token-slice-kehrt-in-die-ziffern-form-zurueck.sh,
// test/mutations/436-emittierte-token-welle-kehrt-in-die-ziffern-form-zurueck.sh,
// test/mutations/437-emittierte-matrix-regel-spec-straten-zu-welle-fehlt.sh,
// test/mutations/438-emittiertes-ids-muster-adr-verliert-das-segment.sh,
// test/mutations/439-emittierte-adr-klasse-verliert-den-bereichs-praefix.sh,
// test/mutations/440-emittierte-ziffern-form-steht-im-kommentar.sh,
// test/mutations/441-emittierte-matrix-fuehrt-ein-weiteres-token.sh,
// test/mutations/442-emittierte-matrix-fuehrt-eine-weitere-regel.sh.
func TestDCheckConfig_KennungsForm(t *testing.T) {
	yml := emit.DCheckConfig()
	klassen := map[string]string{}
	var klassenZeilen, regelZeilen, idsMuster []string
	abschnitt := ""
	for _, line := range strings.Split(yml, "\n") {
		trimmed := strings.TrimSpace(line)
		switch {
		case strings.HasPrefix(line, "ids:"):
			abschnitt = "ids"
		case trimmed == "classes:":
			abschnitt = "classes"
		case trimmed == "rules:":
			abschnitt = "rules"
		case strings.HasPrefix(line, "  status:"):
			abschnitt = ""
		}
		switch {
		case abschnitt == "ids" && strings.HasPrefix(trimmed, "- {regex: "):
			idsMuster = append(idsMuster, trimmed)
		case abschnitt == "classes" && strings.HasPrefix(trimmed, "- {name: "):
			name := strings.TrimSuffix(strings.SplitN(strings.TrimPrefix(trimmed, "- {name: "), ",", 2)[0], "}")
			klassen[name] = trimmed
			klassenZeilen = append(klassenZeilen, trimmed)
		case abschnitt == "rules" && strings.HasPrefix(trimmed, "- {from: "):
			regelZeilen = append(regelZeilen, trimmed)
		}
	}

	t.Run("token_slice", func(t *testing.T) {
		if !strings.HasSuffix(klassen["slice"], "token: 'slice-'}") {
			t.Errorf("die Klasse slice traegt nicht das Praefix-Token slice-: %q", klassen["slice"])
		}
	})
	t.Run("token_welle", func(t *testing.T) {
		if !strings.HasSuffix(klassen["welle"], "token: 'welle-'}") {
			t.Errorf("die Klasse welle traegt nicht das Praefix-Token welle-: %q", klassen["welle"])
		}
	})
	t.Run("token_menge", func(t *testing.T) {
		// Drei Klassen tragen ein token: slice, welle und adaptionsblock. Die Zahl haengt nicht
		// am Wert eines Tokens, sondern an der Menge der Klassen, die eines tragen.
		n := 0
		for _, z := range klassenZeilen {
			if strings.Contains(z, "token: ") {
				n++
			}
		}
		if n != 3 {
			t.Errorf("%d Klassen tragen ein token: statt drei (slice, welle, adaptionsblock):\n%s", n, strings.Join(klassenZeilen, "\n"))
		}
	})

	erwartet := []string{
		"{from: spec-straten, to: adr, allow: false}",
		"{from: spec-straten, to: slice, allow: false}",
		"{from: spec-straten, to: welle, allow: false}",
		"{from: spec-straten, to: adaptionsblock, allow: false}",
		"{from: spec-straten, to: aussen, allow: false}",
		"{from: adr, to: slice, allow: false}",
		"{from: adr, to: welle, allow: false}",
	}
	vorhanden := map[string]bool{}
	for _, z := range regelZeilen {
		vorhanden[strings.TrimPrefix(z, "- ")] = true
	}
	regelName := strings.NewReplacer("{from: ", "", ", to: ", "_", ", allow: false}", "", "-", "_")
	for _, regel := range erwartet {
		t.Run("regel_"+regelName.Replace(regel), func(t *testing.T) {
			if !vorhanden[regel] {
				t.Errorf("die matrix-Regel %s fehlt:\n%s", regel, strings.Join(regelZeilen, "\n"))
			}
		})
	}
	t.Run("regel_menge", func(t *testing.T) {
		gelistet := map[string]bool{}
		for _, regel := range erwartet {
			gelistet[regel] = true
		}
		for _, z := range regelZeilen {
			if !gelistet[strings.TrimPrefix(z, "- ")] {
				t.Errorf("die matrix fuehrt eine Regel ausserhalb der Liste: %s", z)
			}
		}
	})

	t.Run("ids_muster_adr", func(t *testing.T) {
		if len(idsMuster) != 1 || !strings.HasPrefix(idsMuster[0], `- {regex: 'ADR-([A-Z]+-)?\d{4}', target: docs/plan/adr/,`) {
			t.Errorf("ids traegt nicht genau das segment-tolerante ADR-Muster: %q", idsMuster)
		}
	})
	t.Run("adr_klasse_bereichs_praefix", func(t *testing.T) {
		want := `- {name: adr, paths: ["docs/plan/adr/[0-9]*.md", "docs/plan/adr/[A-Z]*-[0-9]*.md"]}`
		if klassen["adr"] != want {
			t.Errorf("die Klasse adr traegt nicht genau die zwei Globs (Ziffern und Bereichs-Praefix, README.md bleibt draussen): %q", klassen["adr"])
		}
	})
	t.Run("keine_ziffern_form", func(t *testing.T) {
		// Die Klassen-Zeilen urteilen token_slice und token_welle; hier stehen alle uebrigen
		// Zeilen, Kommentare eingeschlossen.
		for _, line := range strings.Split(yml, "\n") {
			if strings.HasPrefix(strings.TrimSpace(line), "- {name: ") {
				continue
			}
			if strings.Contains(line, `slice-\d`) || strings.Contains(line, `welle-\d`) {
				t.Errorf("die Ziffern-Form von Slice oder Welle steht in der Vorlage: %q", line)
			}
		}
	})
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

// TestStreicheFremdeKennungenTrifftNurDieRegister haelt beide Richtungen der Streichung im
// Kommentar-Teil eines --print-mk-Fragments (LH-QA-01): die Kennungen aus den Registern der
// Nachbar-Werkzeuge fallen — die Zeilen mit ADR-0030, AC-QA-03 und slice-082 stehen so in
// der realen Ausgabe von a-check v0.23.0 —, eine Klammer gleicher Gestalt ohne Bezug auf
// ein Register (UTF-8, ISO-8601, SHA-256) bleibt stehen.
func TestStreicheFremdeKennungenTrifftNurDieRegister(t *testing.T) {
	for _, f := range [][2]string{
		{"# gueltig aussehend und falsch (ADR-0030).", "# gueltig aussehend und falsch."},
		{"# Die Pin-Hebung ist ein bewusster Commit (AC-QA-03).", "# Die Pin-Hebung ist ein bewusster Commit."},
		{"# die andere (slice-082).", "# die andere."},
		{"x: ## Pruefung (advisory, DC-FA-CLI-009)", "x: ## Pruefung (advisory)"},
		{"# Ausgabe als Text (UTF-8).", "# Ausgabe als Text (UTF-8)."},
		{"# Format (ISO-8601), Hash (SHA-256)", "# Format (ISO-8601), Hash (SHA-256)"},
		{"# Kodierung (Latin, UTF-8)", "# Kodierung (Latin, UTF-8)"},
	} {
		if got := emit.StreicheFremdeKennungen(f[0]); got != f[1] {
			t.Errorf("StreicheFremdeKennungen(%q) = %q, erwartet %q", f[0], got, f[1])
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

// TestDCheckConfig_ZellenlaengeStructure haelt die structure-Position der eingebetteten
// .d-check.yml fest (LH-QA-01): das Modul steht in modules:, und der Block waehlt
// "## Sensors (Feedback-Gates)" in harness/README.md mit genau den Spalten Vertrag und
// Tut was, je cell-max-chars: 200, ohne exempt-paths. Dass beide Spaltennamen in der
// vendorten harness/README.template.md als Kopfzeilen stehen, haelt
// test/emit-zellenlaenge-spalten.bats (der Go-Test-Build-Kontext traegt .harness nicht).
func TestDCheckConfig_ZellenlaengeStructure(t *testing.T) {
	yml := emit.DCheckConfig()
	var modulZeile string
	var block []string
	inBlock := false
	for _, line := range strings.Split(yml, "\n") {
		if strings.HasPrefix(line, "modules:") {
			modulZeile = line
		}
		if line != "" && line[0] != ' ' && line[0] != '#' {
			inBlock = strings.HasPrefix(line, "structure:")
			continue
		}
		if inBlock {
			block = append(block, strings.TrimSpace(line))
		}
	}
	if !strings.Contains(modulZeile, "structure") {
		t.Errorf("structure fehlt in der modules:-Liste (%q): das Ziel prueft keine Zelle", modulZeile)
	}
	text := strings.Join(block, "\n")
	for _, want := range []string{
		`- files: "harness/README.md"`,
		`section: "## Sensors (Feedback-Gates)"`,
		"- name: \"Vertrag\"\ncell-max-chars: 200",
		"- name: \"Tut was\"\ncell-max-chars: 200",
	} {
		if !strings.Contains(text, want) {
			t.Errorf("der structure-Block traegt %q nicht:\n%s", want, text)
		}
	}
	if strings.Contains(text, "exempt-paths") {
		t.Errorf("der structure-Block traegt exempt-paths (eine Senkung):\n%s", text)
	}
	if n := strings.Count(text, "- name:"); n != 2 {
		t.Errorf("der structure-Block fuehrt %d Spalten statt genau Vertrag und Tut was:\n%s", n, text)
	}
}

// TestDCheckConfig_ReviewsBleibtKommentarBlock haelt das Modul reviews in der eingebetteten
// .d-check.yml als begruendeten, inaktiven Kommentar-Block (MR-054 Setzung 3): kein
// reviews in modules:, kein unkommentierter reviews:-Block, und der Kommentar-Block traegt
// done-dir, reviews-dir und eine Trigger-Zeile. Ein unkommentierter Block laesst docs-check
// im Ziel gruen, solange das Modul nicht in modules: steht — er behauptete eine
// Konfiguration, die nicht laeuft; darum faengt ihn dieser Test und nicht das Ziel.
func TestDCheckConfig_ReviewsBleibtKommentarBlock(t *testing.T) {
	yml := emit.DCheckConfig()
	var kopf, doneDir, reviewsDir, trigger bool
	for _, line := range strings.Split(yml, "\n") {
		if strings.HasPrefix(line, "modules:") && strings.Contains(line, "reviews") {
			t.Errorf("reviews steht in der modules:-Liste des frischen Ziels: %q", line)
		}
		if strings.HasPrefix(line, "reviews:") || strings.HasPrefix(line, "  done-dir:") || strings.HasPrefix(line, "  reviews-dir:") {
			t.Errorf("reviews-Block unkommentiert im frischen Ziel: %q", line)
		}
		switch {
		case line == "# reviews:":
			kopf = true
		case line == "#   done-dir: docs/plan/planning/done":
			doneDir = true
		case line == "#   reviews-dir: docs/reviews":
			reviewsDir = true
		case strings.HasPrefix(line, "# Trigger: aktivieren — reviews in modules:"):
			trigger = true
		}
	}
	if !kopf || !doneDir || !reviewsDir || !trigger {
		t.Errorf("Kommentar-Block reviews unvollstaendig (Kopf %v, done-dir %v, reviews-dir %v, Trigger %v)", kopf, doneDir, reviewsDir, trigger)
	}
}
