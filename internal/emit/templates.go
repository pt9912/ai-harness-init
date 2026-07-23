package emit

import (
	"errors"
	"fmt"
	"io/fs"
	"path"
	"sort"
	"strings"
)

// isRecurring markiert die fuenf wiederkehrenden Templates (LH-FA-02, ab 0.8.0):
// sie werden NICHT (mehr) emittiert. Sie liegen aus dem Fetch bereits vendored unter
// .harness/baseline/<tag>/templates/ und werden von dort je Artefakt kopiert (wie im
// Dogfood, ADR-0005) — eine co-located .md-Kopie waere Redundanz und widerspraeche
// der emittierten AGENTS.md, die genau dieses referenzierte Modell beschreibt (der
// Selbstwiderspruch, den slice-024s Voll-Smoke aufdeckte). Sie ist per .d-check.yml
// (scan.ignore **/*.template.md) zwar gate-neutral, aber eben ueberfluessig.
func isRecurring(base string) bool {
	switch base {
	case "NNNN-titel.template.md", "slice.template.md", "welle.template.md",
		"carveout.template.md", "review-report.template.md":
		return true
	}
	return false
}

// isDerivativeIndex markiert die beiden derivativen Index-Vorlagen (ADR-Index,
// Carveout-Index). Sie werden NICHT als gestempelte Singletons emittiert
// (Fuelle-wenn-Inhalt-da, LH-FA-02 0.8.0): ein frisches Repo hat null ADRs/Carveouts,
// ihr als .md emittierter Platzhalter-Link ([<NNNN>](<NNNN>-titel.md) bzw.
// [CO-<NNN>](CO-<NNN>-titel.md)) braeche docs-check out-of-the-box — genau zwei der
// drei Befunde, die slice-024s Voll-Smoke aufdeckte. Der Planning-Index
// (docs/plan/planning/README.template.md) ist bewusst NICHT dabei: er dokumentiert die
// Lifecycle-Konvention (nuetzlich auch leer) und traegt keinen broken Link.
func isDerivativeIndex(rel string) bool {
	switch rel {
	case "docs/plan/adr/README.template.md", "docs/plan/carveouts/README.template.md":
		return true
	}
	return false
}

// (Bis slice-026 haing checkRoot an dem HART VERDRAHTETEN Namen
// "AGENTS.template.md" — ein Upstream-Rename haette den Bootstrap mit
// irrefuehrender Meldung gebrochen, Review-Befund slice-022b N-4. Die Pruefung
// ist jetzt STRUKTURELL und kommt ohne Dateinamen aus.)

// checkRoot prueft POSITIV, dass src am templates/-Verzeichnis gewurzelt ist.
//
// Der Leer-Guard in Templates reicht dafuer nicht (Review-Befund slice-022b F-2):
// eine VORFAHREN-Wurzelung (etwa `.harness/baseline/<tag>/` statt dessen
// `templates/`) ist nicht leer — sie liefert sogar MEHR Treffer — und umgeht
// zugleich beide Ausschluesse aus inScope, weil die am FS-Root verankert sind
// (`project-readme.template.md` hiesse dann `templates/project-readme.template.md`).
// Das Ergebnis waere ein Emit mit zu vielen Dateien und ohne Fehler. Lieber laut
// abbrechen, als eine plausible Falsch-Wurzelung durchzulassen.
//
// Geprueft wird die IDENTITAET des Satzes, nicht seine FORM — nach zwei
// gescheiterten Struktur-Versuchen (Review-Befunde slice-026 F-3 und N-1):
//   1. "ein in-scope-Template an der Wurzel" liess jede templatehaltige
//      Unterebene durch.
//   2. "an der Wurzel UND tiefer" ebenfalls: beide Eigenschaften sind fuer eine
//      Vorfahren- wie fuer eine Nachfahren-Wurzelung konstruierbar.
// Der Grund ist grundsaetzlich: "welches Verzeichnis IST die templates-Wurzel"
// ist keine Frage nach der Gestalt, sondern danach, WELCHER Satz hier liegt.
// Formmerkmale koennen sie nicht beantworten.
//
// Darum: bekannte Mitglieder an ihren bekannten RELATIVEN Pfaden. Mindestens
// zwei muessen zutreffen, damit ein einzelnes Upstream-Rename den Bootstrap
// nicht bricht (das war der Einwand gegen den urspruenglichen Ein-Datei-Anker,
// Befund slice-022b N-4). Aendert der Kurs seinen Satz strukturell, faellt das
// vorher in test/courseset-fixture.bats auf.
//
// KOPPLUNG, die beim Aendern zaehlt: der Wurzel-Nachweis nutzt dieselbe
// inScope-Regel wie der Emit. Ein bestandener checkRoot garantiert damit
// mindestens einen Plan-Eintrag — der frueher hier stehende `len(plan) == 0`-Guard
// war dadurch UNERREICHBAR und ist entfallen (Review-Befund slice-022b N-1: der
// Test, der ihn zu pruefen behauptete, sicherte im Rumpf das Gegenteil zu).
// rootMarkers sind Mitglieder des Kurs-Template-Satzes an ihren Pfaden RELATIV
// zur templates/-Wurzel. Sie sind bewusst ueber mehrere Ebenen verteilt: eine
// Vorfahren-Wurzelung findet sie unter templates/…, eine Nachfahren-Wurzelung
// gar nicht.
func rootMarkers() []string {
	return []string{
		"AGENTS.template.md",
		"spec/lastenheft.template.md",
		"docs/plan/planning/slice.template.md",
	}
}

// minRootMarkers ist die Schwelle: zwei von drei. Ein einzelnes Upstream-Rename
// bricht den Bootstrap damit nicht.
//
// Folge fuer die Mutations-Abdeckung (Review-Befund slice-026 N-8): eine Mutation
// an EINEM Marker kann per Konstruktion nichts brechen — genau das sagt die
// Schwelle zu, und TestCheckRoot_EinRenameGenuegtNicht haelt es fest. Das Set
// (test/mutations/07) mutiert deshalb die SCHWELLE, nicht die Liste; ein Fall,
// der zwei Marker gleichzeitig verbiegt, waere ein konstruierter Beleg fuer eine
// Eigenschaft, die der Test schon direkt prueft.
const minRootMarkers = 2

func checkRoot(src fs.FS) error {
	var found, missing []string
	for _, m := range rootMarkers() {
		switch _, err := fs.Stat(src, m); {
		case err == nil:
			found = append(found, m)
		case errors.Is(err, fs.ErrNotExist):
			missing = append(missing, m)
		default:
			return fmt.Errorf("%s pruefen: %w", m, err)
		}
	}
	if len(found) < minRootMarkers {
		return fmt.Errorf("quelle ist nicht am templates/-Verzeichnis gewurzelt: nur %d von %d Marker-Pfaden gefunden (fehlend: %s) — eine Ebene zu hoch oder zu tief?",
			len(found), len(rootMarkers()), strings.Join(missing, ", "))
	}
	return nil
}

// inScope entscheidet, welche Datei des Kurs-Template-Satzes der Bootstrap als
// Doc-Template-Schicht emittiert (LH-FA-02).
//
// Bis slice-022b existierte diese Regel NICHT im Code: der eingebettete Baum war
// beim Einbetten von Hand vorgefiltert, und ihre einzige Formulierung stand im
// Drift-Waechter test/skel-drift.bats. Mit dem Wechsel auf die gefetchte Quelle
// (die den VOLLEN Satz traegt) muss sie explizit sein.
//
// Bewusst als REGEL, nicht als aufgezaehlte Allowlist: ein upstream neu
// hinzugekommenes Template fliesst damit automatisch mit. Genau die Klasse
// "Baseline gebumpt, Emit nicht nachgezogen" bewachte die Vollstaendigkeits-Achse
// des geloeschten Drift-Waechters — sie verschwindet hier strukturell, statt
// einen Ersatz-Sensor zu brauchen.
func inScope(rel string) bool {
	switch {
	case !strings.HasSuffix(rel, ".template.md"):
		// Traegt der Satz auch: .d-check.yml (das Tool AUTORIERT seine eigene,
		// minimale — emit.DocGate), Makefile (Ziel-Form, gehoert zum Skelett-
		// Generator) und die Set-Index-README.md (nie ein Ziel-Artefakt).
		return false
	case rel == "project-readme.template.md":
		return false // Root-README: LH-FA-05, eigener Emit-Schritt (slice-005)
	default:
		// .harness/skills/{reviewer,closure-note-reviewer}.template.md sind seit
		// slice-030 in-scope: der Reviewer-/Closure-Skill wird als Singleton emittiert
		// (LH-FA-06 Skill-Teil; er bleibt Fetch, ADR-0006 — nur er liegt im Kurs-Satz).
		return true
	}
}

// TemplateTargets liefert die Ziel-Relpfade, die Templates() in targetDir
// SCHREIBEN wuerde — dieselbe Klassifikation (checkRoot + planTemplates), nur
// ohne die Schreibvorgaenge. Der Bootstrap-Pre-Flight (cmd, slice-025) prueft
// damit die Template-Kollisionen VOR dem ersten Emit-Write, gemeinsam mit den
// uebrigen Emit-Zielen — kollidiert IRGENDEIN Emit-Ziel ohne --force, schreibt
// KEIN Emit-Schritt. checkRoot laeuft hier mit: eine falsch gewurzelte gefetchte
// Baseline faellt so im Pre-Flight auf, VOR dem Docker-Lauf in DocGate.
func TemplateTargets(src fs.FS, name string) ([]string, error) {
	if err := checkRoot(src); err != nil {
		return nil, err
	}
	plan, err := planTemplates(src, name)
	if err != nil {
		return nil, err
	}
	targets := make([]string, 0, len(plan))
	for rel := range plan {
		targets = append(targets, rel)
	}
	sort.Strings(targets)
	return targets, nil
}

// Templates legt die Template-Baseline zweiklassig in targetDir ab (LH-FA-02):
// Singletons -> <ziel>.md (Template-Hinweis-Block gestrippt, <Projektname>
// gestempelt), Wiederkehrende -> co-located .template.md (verbatim). name leer ->
// <Projektname> bleibt Platzhalter (Content-Urteil des Menschen). Ohne force wird
// eine vorhandene Zieldatei nicht ueberschrieben (LH-FA-01 Boundary-AC).
//
// src ist der Kurs-Template-Satz, gewurzelt am templates/-Verzeichnis — seit
// slice-022b die vom Bootstrap GEFETCHTE Baseline des Ziels statt eines
// eingebetteten Duplikats (ADR-0005: eine Quelle, der Kurs). Injiziert als fs.FS,
// damit die Tests hermetisch bleiben: der reale Baum liegt unter .harness/, das
// der Docker-Build-Kontext ausschliesst (.dockerignore) — genau der Grund, warum
// der alte Drift-Waechter nach bats musste.
func Templates(src fs.FS, targetDir, name string) error {
	if err := checkRoot(src); err != nil {
		return err
	}
	plan, err := planTemplates(src, name)
	if err != nil {
		return err
	}
	// SKIP-IF-PRESENT (slice-038, ADR-0007): die Doc-Chain-Singletons + Struktur-gitkeeps
	// sind Adopter-Boden — ein vorhandenes (adopter-gefuelltes) Singleton ueberlebt einen
	// idempotenten Re-Lauf unberuehrt; nie clobbern.
	for rel, content := range plan {
		if err := writeSkipIfPresent(targetDir, rel, content, 0o644); err != nil {
			return err
		}
	}
	return nil
}

// planTemplates klassifiziert den Quell-Baum in Ziel-Pfad -> Inhalt (LH-FA-02 0.8.0).
// Emittiert werden nur die Singletons; wiederkehrende Vorlagen und derivative Indexe
// bleiben ununemittiert (referenziert aus der vendored Baseline bzw.
// Fuelle-wenn-Inhalt-da). Zusaetzlich werden die tool-definierten
// Struktur-Verzeichnisse via .gitkeep gehalten (structureGitkeeps).
func planTemplates(src fs.FS, name string) (map[string][]byte, error) {
	out := map[string][]byte{}
	err := fs.WalkDir(src, ".", func(rel string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() || !inScope(rel) {
			return nil
		}
		// Wiederkehrende Vorlagen und derivative Indexe NICHT emittieren (ADR-0005):
		// die Wiederkehrenden liegen aus dem Fetch vendored und werden von dort je
		// Artefakt kopiert; die Indexe sind Fuelle-wenn-Inhalt-da (broken
		// Platzhalter-Links in einem frischen Repo).
		if isRecurring(path.Base(rel)) || isDerivativeIndex(rel) {
			return nil
		}
		content, readErr := fs.ReadFile(src, rel)
		if readErr != nil {
			return fmt.Errorf("template %s lesen: %w", rel, readErr)
		}
		body := stampName(StripHintBlock(string(content)), name)
		if rel == roadmapTemplate {
			// Die Roadmap MUSS emittiert bleiben (stark inbound-verlinkt), traegt aber
			// eine gate-unsichere Beispielzeile — emit-seitig neutralisieren (§6 b).
			body = NeutralizeRoadmap(body)
		}
		out[singletonTarget(rel)] = []byte(body)
		return nil
	})
	if err != nil {
		return nil, err
	}
	// Struktur-Verzeichnisse (tool-definiert, NICHT template-abgeleitet): der
	// Harness-Prozess sieht sie vor, ein frisches Repo laesst sie leer. Git trackt
	// keine leeren Verzeichnisse -> .gitkeep. docs/plan/adr/ traegt zugleich den
	// Verzeichnis-Link aus AGENTS.md/harness/README.md — nach dem Wegfall von Index
	// + NNNN-Template haelt nur .gitkeep es am Leben (sonst neuer docs-check-Befund).
	for _, k := range structureGitkeeps() {
		out[k] = []byte{}
	}
	return out, nil
}

// structureGitkeeps liefert die .gitkeep-Zielpfade der Lifecycle-/Struktur-
// Verzeichnisse, die der Harness-Prozess vorsieht (LH-FA-02 0.8.0): die
// Slice-Lifecycle-Ebenen open/next/done (in-progress/ traegt bereits die Roadmap)
// sowie die ADR-/Carveout-/Reviews-Ordner. Tool-definiert und quell-unabhaengig —
// darum eine feste Liste, kein Ableiten aus src.
func structureGitkeeps() []string {
	dirs := []string{
		"docs/plan/adr",
		"docs/plan/carveouts",
		"docs/reviews",
		"docs/plan/planning/open",
		"docs/plan/planning/next",
		"docs/plan/planning/done",
	}
	out := make([]string, len(dirs))
	for i, d := range dirs {
		out[i] = d + "/.gitkeep"
	}
	return out
}

// roadmapTemplate ist der Quell-Relpfad der Roadmap-Vorlage (templates/-gewurzelt).
const roadmapTemplate = "docs/plan/planning/roadmap.template.md"

// singletonTarget bildet einen Singleton-Template-Pfad auf sein .md-Ziel ab.
func singletonTarget(rel string) string {
	// Die Roadmap lebt unter in-progress/ — die emittierte planning/README.md
	// verweist dorthin; ein Ziel in planning/ liesse ihren Link brechen.
	if rel == roadmapTemplate {
		return "docs/plan/planning/in-progress/roadmap.md"
	}
	return strings.TrimSuffix(rel, ".template.md") + ".md"
}

// roadmapDoneLink ist die eine gate-unsichere Stelle der Roadmap-Vorlage: die
// "Abgeschlossene Wellen"-Beispielzeile verlinkt ../done/welle-NN-results.md, das im
// frischen Repo nicht existiert (broken link -> docs-check-Befund, der dritte aus
// slice-024s Voll-Smoke). Der Rest der Roadmap ist gate-sicher.
const roadmapDoneLink = "[`welle-NN-results.md`](../done/welle-NN-results.md)"

// NeutralizeRoadmap macht die emittierte Roadmap gate-sicher: es ersetzt den einen
// broken Vorwaerts-Link der "Abgeschlossene Wellen"-Beispielzeile durch Inline-Code
// (die Zeile bleibt als Form-Beispiel erhalten, traegt aber keinen toten Link). Das
// ist die emit-seitige Neutralisierung aus slice-028 §6 Option (b); der Kurs-Fix
// (Option a) waere die SSoT-Loesung, ist aber blockiert (immutable vendored Baseline,
// AGENTS 3.4). Ohne den Marker unveraendert. Deckungs-Grenze (ehrlich): geht der
// Neutralisierungs-Effekt VERLOREN (Logik-Regression), faengt es
// TestTemplates_RoadmapGateSafe (kein `](../done/` im emittierten Ziel) gegen die
// courseSet()-Fixture. Aendert dagegen der KURS die Link-Form upstream, bleibt dieser
// Test gruen — die Fixture traegt den alten Wortlaut, und courseset-fixture.bats
// gleicht nur den Datei-BESTAND ab, keinen Inhalt; diese reale Drift faengt allein
// `make smoke` (Tier-2, NICHT in make gates), das gegen den realen Satz emittiert.
func NeutralizeRoadmap(s string) string {
	return strings.ReplaceAll(s, roadmapDoneLink, "`welle-NN-results.md`")
}

// stampName ersetzt den <Projektname>-Platzhalter, falls ein Name gesetzt ist.
func stampName(s, name string) string {
	if name == "" {
		return s
	}
	return strings.ReplaceAll(s, "<Projektname>", name)
}

// StripHintBlock entfernt den `> **Template-Hinweis.** …`-Blockquote (samt einer
// folgenden Leerzeile) aus einem Singleton — die Datei wird ein echtes Repo-File,
// keine Vorlage mehr. Ohne Marker unveraendert. Annahme (Review-L1): der Hinweis ist
// ein eigenstaendiger, blank-getrennter Blockquote (so in allen 10 Singletons) — ein
// ohne Leerzeile angeklebter Content-Blockquote waere markdown-semantisch derselbe
// Block und wuerde mitentfernt; die vendored Vorlagen halten diese Trennung ein.
func StripHintBlock(s string) string {
	lines := strings.Split(s, "\n")
	start := -1
	for i, ln := range lines {
		if strings.HasPrefix(ln, ">") && strings.Contains(ln, "Template-Hinweis") {
			start = i
			break
		}
	}
	if start < 0 {
		return s
	}
	end := start
	for end < len(lines) && strings.HasPrefix(lines[end], ">") {
		end++
	}
	if end < len(lines) && strings.TrimSpace(lines[end]) == "" {
		end++ // die Leerzeile nach dem Block mitnehmen
	}
	out := make([]string, 0, len(lines))
	out = append(out, lines[:start]...)
	out = append(out, lines[end:]...)
	return strings.Join(out, "\n")
}
