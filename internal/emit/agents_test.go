package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// agentFrontmatterName liest den `name:`-Schluessel aus dem YAML-Frontmatter eines
// Rollen-Typs. Bewusst ohne YAML-Parser und ohne die Emit-Seite: der Wert ist der
// Vertrag zur Rollen-Achse, und eine gemeinsame Lesung waere in beiden Richtungen
// gleich blind. Leerer String, wenn kein Frontmatter-Kopf mit `name:` da ist.
func agentFrontmatterName(doc string) string {
	if !strings.HasPrefix(doc, "---\n") {
		return ""
	}
	body, _, ok := strings.Cut(doc[4:], "\n---")
	if !ok {
		return ""
	}
	for _, line := range strings.Split(body, "\n") {
		if v, isName := strings.CutPrefix(line, "name:"); isName {
			return strings.TrimSpace(v)
		}
	}
	return ""
}

// TestAgents_KanonischeRollenLiegenImZiel (LH-FA-10, ADR-0022 Festlegung 3): der Emit
// legt GENAU die sechs kanonischen Rollen-Typen ab, und jede Datei fuehrt ihren
// Rollen-Namen im Frontmatter.
//
// Beide Haelften sind noetig, weil sie verschieden brechen: ein fehlender Typ macht eine
// Rolle im Ziel unstartbar; ein Typ unter abweichendem `name:` startet, traegt aber ein
// leeres Rollen-Feld — der Fall, den die Erfassung nicht von "unbekannt" unterscheiden
// kann.
func TestAgents_KanonischeRollenLiegenImZiel(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Agents(dir); err != nil {
		t.Fatalf("Agents: %v", err)
	}

	want := make([]string, 0, 6)
	for _, role := range emit.CanonicalRoles() {
		want = append(want, ".claude/agents/"+role+".md")
	}
	if len(want) != 6 {
		t.Fatalf("CanonicalRoles liefert %d Rollen, die Rollen-Sequenz aus Modul 8 hat 6: %v", len(want), emit.CanonicalRoles())
	}

	// Der IST-Bestand am Ziel, nicht die Liste, die der Emitter selbst fuehrt: ein
	// Eintrag, den agentFiles() vergaesse, faellt nur so auf. os.ReadDir liefert
	// namens-sortiert, die Rollen-Sequenz ist es nicht — verglichen wird gegen eine
	// sortierte Kopie.
	var got []string
	root := filepath.Join(dir, ".claude", "agents")
	entries, err := os.ReadDir(root)
	if err != nil {
		t.Fatalf(".claude/agents lesen: %v", err)
	}
	for _, e := range entries {
		got = append(got, ".claude/agents/"+e.Name())
	}
	wantSorted := append([]string(nil), want...)
	sort.Strings(wantSorted)
	if strings.Join(got, "\n") != strings.Join(wantSorted, "\n") {
		t.Errorf("emittierter Typ-Bestand weicht ab.\ngot:\n  %s\nwant:\n  %s",
			strings.Join(got, "\n  "), strings.Join(wantSorted, "\n  "))
	}
	// AgentPaths dagegen fuehrt die Rollen-SEQUENZ (Modul 8), nicht die Sortierung.
	if strings.Join(emit.AgentPaths(), "\n") != strings.Join(want, "\n") {
		t.Errorf("AgentPaths weicht vom Ziel-Layout-Vertrag ab:\n  %s", strings.Join(emit.AgentPaths(), "\n  "))
	}

	for _, role := range emit.CanonicalRoles() {
		rel := ".claude/agents/" + role + ".md"
		raw, readErr := os.ReadFile(filepath.Join(dir, filepath.FromSlash(rel)))
		if readErr != nil {
			t.Errorf("%s nicht emittiert: %v", rel, readErr)
			continue
		}
		if name := agentFrontmatterName(string(raw)); name != role {
			t.Errorf("%s fuehrt `name: %q`, die Erfassung besetzt die Rollen-Achse nur bei %q", rel, name, role)
		}
	}
}

// bezugsKlasse ist eine Klasse repo-eigener Bezuege: eine Kennung oder ein Pfad, der nur
// in DIESEM Repo existiert und darum in einem emittierten Rollen-Typ eine Falschaussage
// ueber das Zielrepo waere.
//
// probe ist der synthetische Positiv-Fall der Klasse: ein von Hand geschriebener Text,
// den finde treffen MUSS. Ohne ihn kann ein stumpf gewordener Finder nicht von einem
// sauberen Eingang unterschieden werden — der Waechter waere still gruen.
type bezugsKlasse struct {
	name     string
	richtung string
	probe    string
	finde    func(text string, invariant map[string]bool) []string
}

// bezugsKlassen ist die kuratierte Menge aus dem Slice-Plan. Sie prueft fuenf Klassen,
// nicht Vollstaendigkeit: eine sechste Klasse repo-eigener Bezuege bliebe still, bis
// jemand sie findet und hier eintraegt.
func bezugsKlassen() []bezugsKlasse {
	musterFinder := func(re *regexp.Regexp) func(string, map[string]bool) []string {
		return func(text string, _ map[string]bool) []string { return re.FindAllString(text, -1) }
	}
	return []bezugsKlasse{
		{
			name:     "Slice-ID",
			richtung: "sie benennt einen Vorgang dieses Repos; im Ziel zeigt sie ins Leere",
			probe:    "der Umbau aus slice-042 traegt das",
			finde:    musterFinder(regexp.MustCompile(`slice-[0-9]{2,}`)),
		},
		{
			name:     "Adaptions-Kennung",
			richtung: "sie zeigt auf den Adaptions-Block DIESES Repos, den kein Ziel bekommt",
			probe:    "die Zahl steht neben ihrem Kommando (MR-025)",
			finde:    musterFinder(regexp.MustCompile(`MR-[0-9]{3}`)),
		},
		{
			name:     "Entscheidungs-Kennung",
			richtung: "das Ziel fuehrt EIGENE Entscheidungen unter denselben Nummern — der Verweis ist nicht bloss tot, sondern falsch-treffend",
			probe:    "die Erfassungs-Policy aus ADR-0011 gilt",
			finde:    musterFinder(regexp.MustCompile(`ADR-[0-9]{4}`)),
		},
		{
			// STRENGER ALS DIE ABWESENHEITS-MENGE, und das ist die fail-closed-Richtung:
			// der Bootstrap schreibt dem Ziel unter diesen Verzeichnissen ZWEI Dateien
			// (docs/plan/planning/README.md und docs/plan/planning/in-progress/roadmap.md,
			// aus dem Vorlagen-Emit in templates.go) — das Muster verbietet auch sie.
			// Der Preis: aus einem Rollen-Typ heraus laesst sich nicht auf die Roadmap
			// des Ziels zeigen. Er ist bezahlbar, weil ein Rollen-Typ einen
			// Kontext-Zuschnitt traegt und dafuer keinen Datei-Pfad braucht; die
			// engere Fassung muesste die Emit-Menge nachbilden und driftete mit ihr.
			name:     "Dogfood-Pfad",
			richtung: "ein Rollen-Typ nennt keinen Datei-Pfad unter docs/plan/ — er traegt einen Kontext-Zuschnitt; die Verzeichnisse darf er nennen",
			probe:    "siehe docs/plan/adr/0011-telemetrie-erfassung-policy.md",
			finde:    musterFinder(regexp.MustCompile(`docs/plan/(?:planning|adr)/[A-Za-z0-9_<>./-]*\.[A-Za-z0-9]+`)),
		},
		{
			name:     "Dogfood-Ziel",
			richtung: "die Init-Phase des Ziels schreibt dieses `make`-Ziel nicht — ein behaupteter, aber leerer Gate (LH-QA-01)",
			probe:    "vor der Uebergabe `make mutate` fahren",
			finde: func(text string, invariant map[string]bool) []string {
				var out []string
				for _, claim := range claimsIn(text) {
					if !invariant[claim] {
						out = append(out, "make "+claim)
					}
				}
				return out
			},
		},
	}
}

// TestAgents_KeineRepoEigenenBezuege (LH-FA-10, LH-QA-01, ADR-0022 Festlegung 3): der
// emittierte Typ-Text ist GENERISCH — er traegt keine Kennung und keinen Pfad, den nur
// dieses Repo aufloest.
//
// Zwei Schritte, und der erste ist der wichtigere: jede Klasse trifft zuerst ihren
// eigenen, von Hand geschriebenen Positiv-Fall. Erst danach laeuft sie ueber den echten
// Text. Eine Klasse, deren Muster stumpf geworden ist, faellt so am Positiv-Fall auf und
// nicht erst, wenn ein Leck sie braucht.
func TestAgents_KeineRepoEigenenBezuege(t *testing.T) {
	targets, err := emit.InitInvariantTargets()
	if err != nil {
		t.Fatalf("InitInvariantTargets: %v", err)
	}
	invariant := map[string]bool{}
	for _, target := range targets {
		invariant[target] = true
	}
	if len(invariant) == 0 {
		t.Fatalf("die Init-Phase schreibt kein einziges Ziel — die Klasse Dogfood-Ziel misst nichts")
	}

	klassen := bezugsKlassen()
	for _, k := range klassen {
		if hits := k.finde(k.probe, invariant); len(hits) == 0 {
			t.Errorf("Klasse %q trifft ihren eigenen Positiv-Fall nicht: %q", k.name, k.probe)
		}
	}

	dir := t.TempDir()
	if err := emit.Agents(dir); err != nil {
		t.Fatalf("Agents: %v", err)
	}
	var geprueft int
	walkErr := filepath.WalkDir(filepath.Join(dir, ".claude", "agents"), func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		raw, readErr := os.ReadFile(p)
		if readErr != nil {
			return readErr
		}
		geprueft++
		rel, _ := filepath.Rel(dir, p)
		for _, k := range klassen {
			for _, hit := range k.finde(string(raw), invariant) {
				t.Errorf("%s nennt %q (%s) — %s", filepath.ToSlash(rel), hit, k.name, k.richtung)
			}
		}
		return nil
	})
	if walkErr != nil {
		t.Fatalf("emittierte Typ-Dateien lesen: %v", walkErr)
	}
	if geprueft != len(emit.CanonicalRoles()) {
		t.Fatalf("%d Typ-Dateien geprueft, %d Rollen erwartet — der Waechter lief ueber unvollstaendigem Bestand", geprueft, len(emit.CanonicalRoles()))
	}
}

// TestAgents_SkipIfPresent (ADR-0007 Festlegung 3, ADR-0022 Festlegung 4): ein Rollen-Typ
// ist ein Text, den der Adopter an sein Repo anpasst — dieselbe Idempotenz-Klasse wie die
// Workflow-Commands. Ein Re-Lauf laesst eine vorhandene Typ-Datei UNBERUEHRT und schreibt
// die fehlenden. Kein Fehler.
//
// Rot-Gegenbeispiel: mutiert Agents auf Clobber, ueberschreibt es planner.md.
func TestAgents_SkipIfPresent(t *testing.T) {
	dir := t.TempDir()
	const sentinel = "adopter-adaptiert"
	target := filepath.Join(dir, filepath.FromSlash(".claude/agents/planner.md"))
	if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	if err := os.WriteFile(target, []byte(sentinel), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	if err := emit.Agents(dir); err != nil {
		t.Fatalf("Agents (skip-if-present darf nicht fehlschlagen): %v", err)
	}
	// Die adaptierte Datei bleibt UNBERUEHRT.
	after, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(after) != sentinel {
		t.Errorf("planner.md clobbert (skip-if-present verletzt): %q", string(after))
	}
	// Die fehlenden Typen wurden geschrieben.
	if _, statErr := os.Stat(filepath.Join(dir, filepath.FromSlash(".claude/agents/verifier.md"))); statErr != nil {
		t.Errorf("verifier.md nicht geschrieben (skip-if-present schreibt fehlende): %v", statErr)
	}
}
