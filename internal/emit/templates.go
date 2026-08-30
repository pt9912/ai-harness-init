package emit

import (
	"errors"
	"fmt"
	"io/fs"
	"path"
	"regexp"
	"sort"
	"strings"
)

// isRecurring markiert die sieben wiederkehrenden Templates (LH-FA-02, ab 0.8.0):
// sie werden NICHT (mehr) emittiert. Sie liegen aus dem Fetch bereits vendored unter
// .harness/baseline/<tag>/templates/ und werden von dort je Artefakt kopiert (wie im
// Dogfood, ADR-0005) — eine co-located .md-Kopie waere Redundanz und widerspraeche
// der emittierten AGENTS.md, die genau dieses referenzierte Modell beschreibt (der
// Selbstwiderspruch, den slice-024s Voll-Smoke aufdeckte). Sie ist per .d-check.yml
// (scan.ignore **/*.template.md) zwar gate-neutral, aber eben ueberfluessig.
//
// WIEDERKEHREND heisst hier: die Vorlage nennt ihren Ziel-Pfad mit einem
// Platzhalter darin, es gibt also mehr als ein Ziel je Repo. Wer einen Eintrag
// dazunimmt, sagt genau das zu. Die zwei mit v5.12.0 dazugekommenen sagen es
// selbst, jede in ihrem Template-Hinweis:
//
// Dass die Liste unten und diese Definition dasselbe meinen, misst
// test/courseset-fixture.bats ("emit.isRecurring fuehrt genau die Vorlagen mit
// Platzhalter im Ziel-Pfad") gegen den REALEN vendored Satz, nicht gegen die
// Fixture: er liest je Vorlage den Kopiere-Satz ihres Template-Hinweises und
// haelt die abgeleitete Menge gegen den Rumpf dieser Funktion. Ohne ihn faengt
// kein Sensor den Fall, dass upstream einen Ziel-Pfad umschreibt und die Liste
// hier stehen bleibt — Datei-Bestand und in-scope-Zahl bleiben dabei unberuehrt
// (test/mutations/219 faehrt genau diese Drift).
//
//	welle-results.template.md — "Kopiere nach docs/plan/planning/done/
//	  welle-<NN>-results.md": eine je Welle, neben die Welle-Plan-Datei, die
//	  ihrerseits aus welle.template.md kommt und schon hier steht.
//	MR-NNN-titel.template.md — "Kopiere nach harness/conventions/
//	  MR-<NNN>-<titel>.md … Ein Eintrag je Datei": eine je Adaption, dieselbe
//	  Form wie der ADR-Eintrag NNNN-titel.template.md.
//
// GRENZE: die namentliche Aufzaehlung in LH-FA-02 ("ADR · slice · welle ·
// carveout · review-report") fuehrt diese zwei nicht. Sie ist damit unvollstaendig
// — das Lastenheft ist Rang 1 der Source Precedence und wird nicht vom Emit
// fortgeschrieben; kein Gate sieht die Luecke, weil docs-check Kennungen und Links
// prueft, nicht die Vollstaendigkeit einer Aufzaehlung.
func isRecurring(base string) bool {
	switch base {
	case "NNNN-titel.template.md", "slice.template.md", "welle.template.md",
		"carveout.template.md", "review-report.template.md",
		"welle-results.template.md", "MR-NNN-titel.template.md":
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

// isBrownfieldOnly markiert die Vorlage, deren Anlass ein Bootstrap-MODUS ist:
// docs/plan/planning/reconciliation.template.md traegt das Register des Rueckbaus
// und sagt in ihrem Template-Hinweis selbst "Ein reines Greenfield-Repo braucht die
// Datei nicht". Sie wird NICHT emittiert.
//
// Der Bootstrap kennt den Modus des Zielrepos nicht — das Werkzeug hat dafuer kein
// Flag (cmd/ai-harness-init/main.go fuehrt --lang, --name, --arch), und LH-FA-01
// setzt in beiden Happy-Path-Kriterien ein LEERES Git-Repo voraus. Entschieden ist
// entlang der Prozedur, die die Baseline fuer diese Datei selbst vorschreibt:
//
//	Erzeugt wird sie im Rueckbau, nicht im Skelett-Kopierschritt. Baseline-Regelwerk
//	  modul-02-harness-bootstrap.md legt docs/plan/planning/reconciliation.md in
//	  BF-Schritt 8 an ("Diskrepanz-Schock"), also nach der Code-Inventur und nach dem
//	  Vendoren der Skelette (BF-Schritt 3 / GF-Schritt 2); die GF-Schritttabelle nennt
//	  die Datei ueberhaupt nicht. Ein Emit legte sie VOR dem Schritt an, der sie
//	  fuellt — §Das Reconciliation-Register sagt dazu "beim Bootstrap-Ende ist es im
//	  Gegenteil voll".
//	Emittiert widerspraeche der emittierte Stand sich selbst: die mitemittierte
//	  docs/plan/planning/README.md spricht dem frischen Repo die Datei ab
//	  ("Greenfield-Repos haben die Datei nicht"). Das ist derselbe Selbstwiderspruch
//	  IM emittierten Stand, an dem slice-024s Voll-Smoke die wiederkehrenden Vorlagen
//	  entschied.
//	Nicht emittiert bleibt nichts unausgesprochen: dieselbe README nennt die Datei
//	  samt ihrer Bedingung im Ziel-Repo, und der Brownfield-Adopter legt sie dort an,
//	  wo die Prozedur sie ohnehin verlangt.
//
// GRENZE gegen den Set-Index des vendored Satzes: sein §"Ein- vs. wiederkehrende
// Templates" (.harness/baseline/<tag>/templates/README.md) fuehrt reconciliation
// unter den SINGLETONS, seit v5.12.0 und dort gezielt gesetzt. Diese Weiche
// widerspricht ihm nicht auf derselben Achse — die zwei Lebenszyklen dort
// beantworten, WIE sich eine Vorlage vervielfaeltigt (ein Ziel je Repo, Vorlage
// danach verworfen; gegenueber: Vorlage bleibt co-located), nicht, OB ein gegebenes
// Repo dieses Ziel hat. Eine geschlossene Taxonomie ist die Liste ebenfalls nicht:
// derivative Indexe, Planning-Index, welle-results und MR-NNN-titel stehen in
// keinem der beiden Eimer. Ob daraus dennoch eine Abweichung im Sinne des
// Adaptions-Blocks folgt, ist eine Architektur-Frage (AGENTS 3.8) und hier nicht
// entschieden.
//
// Warum eine eigene Weiche und nicht eine der beiden daneben: isRecurring sagt
// "mehr als ein Ziel je Repo" zu, hier gibt es genau eines; isDerivativeIndex sagt
// "aus vorhandenen Originalen abgeleitet" zu, dieses Register ist aus nichts
// abgeleitet. Beide Namen waeren fuer diesen Eintrag falsch.
//
// GRENZE: LH-FA-02 fuehrt diese Disposition nicht — es nennt Singletons,
// Wiederkehrende, derivative Indexe, .gitkeeps und die nie kopierte Set-Index-README.
// Das Lastenheft ist Rang 1 und wird nicht vom Emit fortgeschrieben.
func isBrownfieldOnly(rel string) bool {
	return rel == "docs/plan/planning/reconciliation.template.md"
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
// ohne die Schreibvorgaenge (fuer Tests/Inspektion). checkRoot laeuft hier mit:
// eine falsch gewurzelte gefetchte Baseline faellt so schon hier auf, mit lauter
// Meldung statt still leerem Emit (LH-QA-01).
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

// Templates legt die Template-Baseline in targetDir ab (LH-FA-02): geschrieben
// werden die Singletons -> <ziel>.md (Template-Hinweis-Block gestrippt,
// <Projektname> gestempelt). Was NICHT geschrieben wird und warum, steht an den
// drei Weichen isRecurring / isDerivativeIndex / isBrownfieldOnly. name leer ->
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
	// GEMISCHTE Idempotenz-Klasse (slice-038, ADR-0007 Z.100): .harness/skills/* ist
	// tool-eigene Infrastruktur -> KONVERGENT (bei jedem Lauf kanonisch neu, heilt
	// Baseline-Bump); der uebrige Satz (Doc-Chain-Singletons + Struktur-gitkeeps) ist
	// Adopter-Boden -> SKIP-IF-PRESENT (nie clobbern, ein adopter-gefuelltes Singleton
	// ueberlebt unberuehrt).
	for rel, content := range plan {
		write := writeSkipIfPresent
		if strings.HasPrefix(rel, ".harness/skills/") {
			write = writeFileMode // konvergent
		}
		if err := write(targetDir, rel, content, 0o644); err != nil {
			return err
		}
	}
	return nil
}

// planTemplates klassifiziert den Quell-Baum in Ziel-Pfad -> Inhalt (LH-FA-02 0.8.0).
// Emittiert werden nur die Singletons; wiederkehrende Vorlagen, derivative Indexe und
// das Brownfield-Register bleiben ununemittiert (referenziert aus der vendored
// Baseline, Fuelle-wenn-Inhalt-da bzw. modus-gebunden). Zusaetzlich werden die
// tool-definierten Struktur-Verzeichnisse via .gitkeep gehalten (structureGitkeeps).
func planTemplates(src fs.FS, name string) (map[string][]byte, error) {
	targets, err := InitInvariantTargets()
	if err != nil {
		return nil, err
	}
	out := map[string][]byte{}
	err = fs.WalkDir(src, ".", func(rel string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() || !inScope(rel) {
			return nil
		}
		// Wiederkehrende Vorlagen, derivative Indexe und das Brownfield-Register
		// NICHT emittieren (ADR-0005): die Wiederkehrenden liegen aus dem Fetch
		// vendored und werden von dort je Artefakt kopiert; die Indexe sind
		// Fuelle-wenn-Inhalt-da (broken Platzhalter-Links in einem frischen Repo);
		// das Reconciliation-Register entsteht erst im Rueckbau eines
		// Brownfield-Bootstraps.
		//
		// WER HIER EINE VORLAGE NICHT EINTRAEGT, ENTSCHEIDET "Singleton" — das ist
		// die Voreinstellung, und fuer docs/plan/planning/observations.template.md
		// ist sie die richtige: das Beobachtungs-Register ist die stehende Datei des
		// Steering Loops ("Kopiere nach docs/plan/planning/observations.md", ein Ziel
		// je Repo, ohne Platzhalter im Pfad), und seine leere Tabelle ist laut
		// Baseline-Regelwerk modul-06-roadmap.md §Das Beobachtungs-Register "die, mit
		// der jedes Repo anfaengt". Ein Repo ohne die Datei haette keine
		// Vergabestelle fuer BEO-<NNN> und keinen Ort fuer den Sichtungs-Schritt der
		// Slice-Planung.
		if isRecurring(path.Base(rel)) || isDerivativeIndex(rel) || isBrownfieldOnly(rel) {
			return nil
		}
		content, readErr := fs.ReadFile(src, rel)
		if readErr != nil {
			return fmt.Errorf("template %s lesen: %w", rel, readErr)
		}
		body := stampName(StripHintBlock(string(content)), name)
		// Jedes Singleton geht durch die Ziel-Neutralisierung: der Vorlagen-Satz
		// gehoert dem Kurs (MR-008) und liegt unveraenderlich vendored (AGENTS 3.4),
		// die Ansprueche fallen darum emit-seitig (slice-087, LH-QA-01).
		body = NeutralizeMakeClaims(body, targets)
		// Dieselbe Lage eine Stelle weiter: ein Link, dessen Ziel-Pfad einen
		// <…>-Platzhalter traegt, zeigt im frischen Repo auf keine Datei.
		body = NeutralizePlaceholderLinks(body)
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
// courseSet()-Fixture. Aendert dagegen der KURS diesen Wortlaut upstream, bleibt dieser
// Test gruen — die Fixture traegt den alten Marker, und courseset-fixture.bats gleicht
// vom Inhalt allein die Platzhalter-Pfad-FORM ab, keinen Wortlaut; diese reale Drift
// faengt allein `make smoke` (Tier-2, NICHT in make gates), das gegen den realen Satz
// emittiert. Ein Ziel wie `../<welle-NN>/results.md` traegt dagegen einen Platzhalter
// im Pfad und faellt unter NeutralizePlaceholderLinks, ohne diesen Marker zu brauchen.
func NeutralizeRoadmap(s string) string {
	return strings.ReplaceAll(s, roadmapDoneLink, "`welle-NN-results.md`")
}

// makeTargetPlaceholder tritt an die Stelle einer Ziel-Nennung, die im
// gebootstrappten Repo kein Ziel trifft. Die Form stammt aus dem Vorlagen-Satz
// selbst (harness/README.template.md fuehrt „`<make-target-1>`, `<make-target-2>`"
// fuer noch nicht behauptete Ziele): die Zeile bleibt als Form-Beispiel stehen und
// nennt nur kein Ziel mehr. Sie steht im emittierten Bestand durchgaengig in
// Inline-Code — ausserhalb davon liest ein Markdown-Renderer sie als Tag.
const makeTargetPlaceholder = "<make-target>"

// makeClaimPattern erfasst eine `make <ziel>`-Nennung samt einem unmittelbar
// folgenden Stern. Der Stern trennt Muster von Anspruch: `make verify-*` nennt
// ein Muster und damit kein Ziel (ADR-0020 Festlegung 4(e)).
//
// BREIT mit Absicht, und das kostet etwas: das Muster liest jedes Kleinwort nach
// `make ` als Ziel-Namen, auch eines im Fliesstext. Die enge Alternative — nur
// Nennungen in Inline-Code — liesse einen Anspruch ausserhalb der Backticks
// stehen, und der waere ein stilles falsches Gate (LH-QA-01); ein verstuemmeltes
// Wort ist dagegen im emittierten Text sichtbar. Das ist die fail-closed-Richtung
// aus MR-017. Der vendored Satz `v5.12.0` traegt kein solches Wort: alle
// `make `-Nennungen der Vorlagen und der Workflow-Commands sind Ziel-Nennungen
// oder die Muster-Nennung mit Stern.
const makeClaimPattern = `make ([a-z][a-z0-9-]*)(\*?)`

// makeRulePattern erfasst eine Ziel-Definition am Zeilenanfang eines
// Make-Fragments; gateCheckPattern erfasst die Ziele, die ein Fragment an
// GATE_CHECKS haengt. Beides ist noetig: das Rezept von `docs-check` liegt im zur
// Bootstrap-Zeit erzeugten d-check.mk, das Doc-Gate-Fragment traegt allein die
// GATE_CHECKS-Kante.
const (
	makeRulePattern  = `(?m)^([a-z][a-z0-9-]*):`
	gateCheckPattern = `(?m)^GATE_CHECKS[ \t]*\+=[ \t]*(.+)$`
)

// initFragments liefert den Inhalt der Make-Fragmente, die die Init-Phase in JEDER
// Bootstrap-Variante schreibt, JE ZIEL-RELPFAD: den Root-Aggregator (makefile.go), das
// Baseline-Fragment (baseline.go), das Doc-Gate-Fragment (emit.go) und jedes
// `.mk` der Durchsetzungsschicht (enforce.go). Der Durchsetzungs-Teil kommt aus
// enforceFiles(), damit ein dort neu hinzukommendes Fragment mitfliesst.
//
// Der Pfad ist der Schluessel, weil die Waechter der Nicht-Verdrahtung sagen muessen,
// IN WELCHER Datei ein Ziel auftaucht — "irgendwo in der Kette" ist kein Befund, den
// jemand beheben kann.
func initFragments() (map[string]string, error) {
	out := map[string]string{
		MakefilePath:   aggregatorMakefile,
		BaselineMkPath: baselineMk,
		DocGateMkPath:  docGateMk,
	}
	for _, f := range enforceFiles() {
		if !strings.HasSuffix(f.dst, ".mk") {
			continue
		}
		content, err := enforceFS.ReadFile(f.src)
		if err != nil {
			return nil, fmt.Errorf("init-fragment %s lesen: %w", f.src, err)
		}
		out[f.dst] = string(content)
	}
	return out, nil
}

// InitFragments liefert dieselbe Menge je Ziel-Relpfad — die Make-Quellen, die die
// Init-Phase in JEDER Bootstrap-Variante ins Ziel schreibt.
//
// Exportiert fuer die Waechter der NICHT-Verdrahtung (slice-099): sie muessen die Kette
// DES ZIELS lesen. Eine im Test gepflegte Dateiliste waere die zweite Fassung, die
// driftet — ein neu hinzukommendes Fragment fiele aus ihr heraus, und der Waechter
// bliebe gruen, waehrend die Verdrahtung entstuende.
//
// GRENZE, dieselbe wie bei InitInvariantTargets: `d-check.mk` entsteht erst zur
// Bootstrap-Zeit aus `d-check --print-mk` und liegt hier nicht vor; aus ihm traegt die
// Menge allein die GATE_CHECKS-Kante des Doc-Gate-Fragments. Die Ziele der SPRACH-Phase
// liegen ebenfalls ausserhalb — sie kommen aus gen.CodeGateFragment.
func InitFragments() (map[string]string, error) { return initFragments() }

// InitInvariantTargets liefert sortiert die Make-Ziele, die die Init-Phase in
// jeder Bootstrap-Variante ins Ziel schreibt — aus den Fragmenten GELESEN, nicht
// aufgezaehlt: ein Fragment, das ein Ziel dazunimmt, waechst mit.
//
// AUSSERHALB der Menge liegen die Ziele der SPRACH-Phase (harness/mk/<lang>.mk:
// test, lint, build) und des konditionalen Arch-Gates (a-check) — beide fehlen in
// mindestens einer Bootstrap-Variante und sind darum nicht init-invariant.
//
// GRENZE: d-check.mk entsteht erst zur Bootstrap-Zeit aus `d-check --print-mk`
// und liegt hier nicht vor. Aus ihm traegt die Menge allein `docs-check` ueber die
// GATE_CHECKS-Kante des Doc-Gate-Fragments; die advisory `doc-*`-Rezepte fehlen.
// Die Menge ist damit ENGER als die reale Ziel-Menge eines Bootstraps — die
// fail-closed-Richtung aus MR-017: ein Anspruch auf `doc-links` wuerde
// neutralisiert, obwohl das Ziel im Ziel-Repo existiert.
func InitInvariantTargets() ([]string, error) {
	fragments, err := initFragments()
	if err != nil {
		return nil, err
	}
	makeRule := regexp.MustCompile(makeRulePattern)
	gateCheck := regexp.MustCompile(gateCheckPattern)
	seen := map[string]bool{}
	for _, frag := range fragments {
		for _, m := range makeRule.FindAllStringSubmatch(frag, -1) {
			seen[m[1]] = true
		}
		for _, m := range gateCheck.FindAllStringSubmatch(frag, -1) {
			for _, t := range strings.Fields(m[1]) {
				seen[t] = true
			}
		}
	}
	targets := make([]string, 0, len(seen))
	for t := range seen {
		targets = append(targets, t)
	}
	sort.Strings(targets)
	return targets, nil
}

// NeutralizeMakeClaims ersetzt jede `make <ziel>`-Nennung eines emittierten
// Dokuments durch makeTargetPlaceholder, sofern <ziel> nicht in targets liegt —
// die emit-seitige Neutralisierung aus slice-087, dieselbe Form wie
// NeutralizeRoadmap. Eine Muster-Nennung mit Stern bleibt unveraendert.
//
// Deckungs-Grenze (ehrlich): rot faerbt eine verlorene Wirkung
// TestEmittierteDokumente_NurInitInvarianteZiele gegen eine anspruchstragende
// Fixture. Was ein KUENFTIGER Kurs-Stand an neuen Anspruechen mitbringt, faengt
// kein Test hier — es faengt die Regel selbst, die ueber Namen nicht verfuegt.
func NeutralizeMakeClaims(s string, targets []string) string {
	known := make(map[string]bool, len(targets))
	for _, t := range targets {
		known[t] = true
	}
	makeClaim := regexp.MustCompile(makeClaimPattern)
	return makeClaim.ReplaceAllStringFunc(s, func(m string) string {
		g := makeClaim.FindStringSubmatch(m)
		if g[2] != "" || known[g[1]] {
			return m
		}
		return makeTargetPlaceholder
	})
}

// placeholderLinkPattern erfasst einen Markdown-Inline-Link samt Ziel. Der Link-TEXT
// steht auf EINER Zeile (`\n` ist ausgeschlossen), das ZIEL traegt weder Klammern noch
// Leerraum — die Form, in der der Vorlagen-Satz seine Verweise fuehrt. Die
// Zeilen-Schranke haelt den Text-Teil kurz: eine offene eckige Klammer im Fliesstext
// bindet nur bis zum Zeilenende, nicht bis zum naechsten `](…)` weiter unten.
const placeholderLinkPattern = `\[([^\[\]\n]*)\]\(([^()\s]*)\)`

// placeholderPattern erfasst einen <…>-Platzhalter. Angelegt wird er am PFAD-Teil
// des Ziels (vor dem `#`): ueber die Aufloesbarkeit eines Links entscheidet der
// Pfad. Ein Platzhalter allein im Anker laesst den Link auf eine reale Datei zeigen —
// ueber den Anker urteilt im Zielrepo das anchors-Modul des Doc-Gates.
const placeholderPattern = `<[^<>]*>`

// NeutralizePlaceholderLinks nimmt jedem Markdown-Link, dessen Ziel-PFAD einen
// <…>-Platzhalter traegt, die Link-Syntax: der Link-Text bleibt VERBATIM stehen, das
// Ziel faellt weg. Die Zeile bleibt damit als Form-Beispiel erhalten und traegt keinen
// toten Link — dieselbe Bauart wie NeutralizeRoadmap, nur ueber eine FORM statt ueber
// einen Wortlaut. Der emittierte Stand ist out-of-the-box gate-sicher (LH-FA-02); der
// Vorlagen-Satz gehoert dem Kurs und liegt unveraenderlich vendored (AGENTS 3.4), die
// Reparatur faellt darum emit-seitig.
//
// Emit-seitig und NICHT im emittierten Pruefbereich (templates/d-check.yml): ein
// scan.ignore dort naehme dem Adopter die Meldung, ohne den Link zu heilen — sein
// frisches Repo truege weiter einen Verweis ins Leere, nur unsichtbar. MR-017 verlangt
// fuer emittierte Pruefbereiche die fail-closed-Richtung, und ein Ausschluss ist die
// andere.
//
// Was die Regel HAELT: eine Vorlage, die upstream mit einem <…>-Ziel neu dazukommt,
// faellt ohne Codeaenderung darunter — die Regel verfuegt ueber keinen Namen und keinen
// Wortlaut.
//
// Was sie NICHT haelt, vier Grenzen:
//  1. Ein Ziel in einer anderen Platzhalter-Schreibweise ({{…}}, @@…@@, %…%) bleibt
//     stehen. Im emittierten Baum sieht diese Form allein `make smoke`, und der laeuft
//     ausserhalb von `make gates`.
//  2. Ein Platzhalter allein im ANKER (`../conventions.md#mr-<NNN>`) bleibt stehen.
//  3. Ein Link, dessen Text ueber einen Zeilenumbruch geht oder dessen Ziel Leerraum
//     bzw. Klammern traegt, bleibt stehen (s. placeholderLinkPattern).
//  4. Der Link-Text bleibt unveraendert. Traegt er selbst die Gestalt eines HTML-Tags
//     (`<welle-NN-titel>`), liest ein Markdown-Renderer ihn als Tag — dieselbe Form,
//     die der Vorlagen-Satz in seinen Tabellen ohnehin fuehrt.
//
// Rot faerbt eine verlorene Wirkung TestTemplates_KeinPlatzhalterLinkImEmittiertenSatz
// gegen die courseSet()-Fixture; dass die Fixture jede Platzhalter-Pfad-FORM des REALEN
// Satzes fuehrt, haelt test/courseset-fixture.bats fest. Ob diese Regel einen realen
// Link ERREICHT, misst dagegen kein Gate: dafuer braeuchte EIN Lauf den realen Satz und
// diese Regel zugleich, und keiner in `make gates` hat beides. Ein Link nach Grenze 1
// oder 3 faellt darum allein `make smoke` auf, ausserhalb von `make gates`.
func NeutralizePlaceholderLinks(s string) string {
	link := regexp.MustCompile(placeholderLinkPattern)
	placeholder := regexp.MustCompile(placeholderPattern)
	return link.ReplaceAllStringFunc(s, func(m string) string {
		g := link.FindStringSubmatch(m)
		pfad, _, _ := strings.Cut(g[2], "#")
		if !placeholder.MatchString(pfad) {
			return m
		}
		return g[1]
	})
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
