package emit

import (
	"bytes"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

// enforceFS traegt die tool-AUTORIERTE Durchsetzungs-Mechanik (LH-FA-06,
// ADR-0006): Gate-Nachweis (record-gates + working-tree-hash) und Stop-Hook
// (stop-require-gates + settings.json + .harness/.gitignore). Sie ist
// eingebettet, nicht gefetcht — die Mechanik gehoert der Generator-Klasse aus
// ADR-0005/ADR-0006 ("Tool-als-Quelle"), genau wie baseline-verify.sh und die
// minimale .d-check.yml.
//
// SPRACH-AGNOSTISCH: alle eingebetteten Skripte inkl. des Command-Guards sind verbatim
// (slice-036: der Guard traegt den universellen Boden GEBACKEN und liest blocked/* zur
// Laufzeit; das Sprach-Set kommt als separates blocked/<lang>-Fragment, nicht mehr per
// @@BLOCKED_SET@@-Substitution). all: bettet auch die dot-lose gitignore-Quelle sicher ein.
//
//go:embed all:templates/enforce
var enforceFS embed.FS

// enforceFile bildet eine eingebettete Quelle auf ihren Ziel-Relpfad + Modus ab.
type enforceFile struct {
	src  string      // Pfad in enforceFS
	dst  string      // Ziel-Relpfad (slash), relativ zu targetDir
	mode fs.FileMode // 0755 fuer ausfuehrbare Hooks/Tools, 0644 sonst
}

// enforceFiles ist die emittierte Durchsetzungsschicht. Die Tool-Skripte liegen
// unter tools/harness/ (emittiertes Layout, LH-FA-06/ADR-0004 — NICHT das lokal
// adaptierte harness/tools/, MR-005). Die Claude-Hooks/-Config liegen an ihren
// von Claude Code fixierten .claude/-Pfaden. settings.json verdrahtet BEIDE Hooks —
// den Stop-Hook (slice-031) und den PreToolUse-Command-Guard (slice-032); der Guard
// wird mit seinem awk-Extraktor (tools/harness/) mit-emittiert, sonst liefe der Hook
// im Ziel ins Leere.
func enforceFiles() []enforceFile {
	return []enforceFile{
		{"templates/enforce/working-tree-hash.sh", "tools/harness/working-tree-hash.sh", 0o755},
		{"templates/enforce/record-gates.sh", "tools/harness/record-gates.sh", 0o755},
		{"templates/enforce/stop-require-gates.sh", ".claude/hooks/stop-require-gates.sh", 0o755},
		{"templates/enforce/settings.json", ".claude/settings.json", 0o644},
		{"templates/enforce/gitignore", ".harness/.gitignore", 0o644},
		// Enforce-Gate-Fragment (slice-034): das record-gates-Rezept als
		// harness/mk/enforce.mk. Die Ordnungskante (record-gates: $(GATE_CHECKS)) +
		// `gates: record-gates` leben im Root-Aggregator (gen), weil sie GATE_CHECKS
		// erst nach dem Glob-Include vollstaendig sehen. Sprach-agnostisch, verbatim.
		{"templates/enforce/enforce.mk", "harness/mk/enforce.mk", 0o644},
		// Command-Guard (slice-032): bash+awk, kein node/jq (LH-QA-03). Der Guard
		// (0755) referenziert den awk-Extraktor unter tools/harness/ — beide
		// gehoeren in denselben Emit, sonst laeuft der Guard fail-closed ins Leere.
		{"templates/enforce/pretooluse-command-guard.sh", ".claude/hooks/pretooluse-command-guard.sh", 0o755},
		{"templates/enforce/extract-command.awk", "tools/harness/extract-command.awk", 0o644},
	}
}

// carrierDir ist der Ablageort des Traegers im Ziel: der gitignorierte Zustands-Bereich,
// den die mit-emittierte .harness/.gitignore mit `state/` deckt (ADR-0011 Festlegung 3).
// Ein Traeger im getrackten Baum verschoebe den working-tree-hash des Ziels und liesse
// dessen Stop-Hook sich selbst blockieren (MR-003).
const carrierDir = ".harness/state/bin"

// carrierName ist der feste Name des Traegers im Ziel — NICHT der Plattform-Dateiname
// des Release-Assets (ai-harness-init-linux-amd64 u. a.). Der emittierte Hook-Wrapper
// sucht genau diesen Namen; ein mitgeschleppter Asset-Name machte ihn unauffindbar.
const carrierName = "ai-harness-init"

// carrierMode ist der Modus des abgelegten Traegers: der Hook startet ihn je Tool-Call,
// eine nicht ausfuehrbare Kopie waere ein Traeger, der nur aussieht wie einer.
const carrierMode fs.FileMode = 0o755

// CarrierPath liefert den Ziel-Relpfad des Traegers aus dem Pfad des LAUFENDEN Bildes.
// Der Name ist fest, die Endung wandert mit: ein Windows-Bild traegt `.exe`, und ohne
// sie bekaeme ein Windows-Ziel eine Datei, die es nicht starten kann (LH-QA-04). Der
// emittierte Wrapper sucht beide Namen — die Kopplung misst
// TestEnforce_WrapperSuchtDenAblageort, die Endungs-Achse TestCarrierPath_NimmtDieEndungMit.
// Exportiert fuer genau diese zwei Tests.
func CarrierPath(image string) string {
	if ext := filepath.Ext(image); strings.EqualFold(ext, ".exe") {
		return carrierDir + "/" + carrierName + ext
	}
	return carrierDir + "/" + carrierName
}

// captureFiles sind die eingebetteten Erfassungs-Artefakte, die NUR mit dem Traeger
// entstehen (ADR-0022 Festlegung 5): heute der Hook-Wrapper. Er liegt committet unter
// .claude/hooks/, weil der Traeger gitignored liegt — eine Konfiguration, die direkt
// auf ihn zeigte, waere ein Hook auf ein fehlendes Programm (LH-QA-01), sobald ein
// frischer Klon oder ein Aufraeum-Lauf ihn wegnimmt.
//
// KONVERGENT wie die uebrigen Hook-Skripte (ADR-0007 Festlegung 3), aber bewusst NICHT
// in enforceFiles()/EnforcePaths(): jene Menge entsteht unbedingt, diese nur im
// Gelingens-Zweig.
func captureFiles() []enforceFile {
	return []enforceFile{
		{"templates/enforce/span-emit.sh", ".claude/hooks/span-emit.sh", 0o755},
	}
}

// settingsSrc ist die Hook-Konfiguration — die EINZIGE emittierte Datei, deren Inhalt
// am Ausgang der Traeger-Ablage haengt.
const settingsSrc = "templates/enforce/settings.json"

// captureHooksSrc ist der Erfassungs-Block als JSON-FRAGMENT (kein eigenstaendiges
// Dokument): drei Ereignisse mit leerem Matcher, je auf den Wrapper gerichtet.
const captureHooksSrc = "templates/enforce/settings-capture-hooks.json"

// hooksAnchor ist die Marke, hinter der das Fragment eingesetzt wird.
const hooksAnchor = "\"hooks\": {\n"

// blockedDir ist das Verzeichnis der Sprach-BLOCKED-Fragmente im Ziel (emittiertes
// Layout, MR-005). Der emittierte Guard traegt den universellen Boden GEBACKEN (fail-safe,
// nie fail-open) und liest zusaetzlich blocked/* (Union, reines bash+cat, LH-QA-03).
// add-lang droppt blocked/<sprache> (slice-037); der --lang-One-Shot emittiert es hier.
const blockedDir = "tools/harness/blocked"

// BlockedFragmentPath liefert den Zielpfad des Sprach-BLOCKED-Fragments blocked/<lang>.
func BlockedFragmentPath(lang string) string { return blockedDir + "/" + lang }

// blockedByLang bildet jede von gen unterstuetzte Sprache auf ihre Host-Toolchain ab —
// der Inhalt des blocked/<lang>-Fragments (whitespace-getrennt, mit Zeilenumbruch). An
// gen.SupportedLangs() gekoppelt (Test): ein neues gen-Profil ohne Eintrag hier liesse die
// Sprach-Toolchain im Ziel ungehindert laufen (stille Luecke).
func blockedByLang() map[string]string {
	return map[string]string{
		"go":  "go gofmt golangci-lint staticcheck\n",
		"cpp": "g++ gcc cmake clang-tidy clang clang++\n",
	}
}

// BlockedFragmentForLang exportiert den Fragment-Inhalt fuer Tests (Kopplung an
// gen-Profile); leer, wenn lang kein Profil hat.
func BlockedFragmentForLang(lang string) string { return blockedByLang()[lang] }

// EnforcePaths liefert die Ziel-Relpfade der Durchsetzungs-Mechanik — fuer den
// Bootstrap-Pre-Flight (cmd, Phase 3). Ohne sie faende eine Kollision (z.B. eine
// vorhandene .claude/settings.json) erst mitten in Phase 4 statt (Teil-Bootstrap).
// SPRACH-AGNOSTISCH (slice-037): das blocked/<lang>-Fragment gehoert NICHT mehr hierher
// — es ist skip-if-present (Mono-Repo-Wiederverwendung, mehrere Module gleicher Sprache)
// und wird von add-lang via BlockedFragment gedroppt, nicht vom Kollisions-Pre-Flight
// erfasst.
//
// UNBEDINGT (ADR-0022 Festlegung 5): der Hook-Wrapper aus captureFiles() gehoert
// ebenfalls nicht hierher. Diese Menge entsteht bei jedem Lauf; jene nur, wenn der
// Traeger liegt — eine Liste, die beide fuehrt, behauptete eine Anwesenheit, die der
// Fehlerzweig ausdruecklich ausschliesst.
func EnforcePaths() []string {
	files := enforceFiles()
	paths := make([]string, 0, len(files))
	for _, f := range files {
		paths = append(paths, f.dst)
	}
	return paths
}

// Enforce schreibt die sprach-agnostische Durchsetzungs-Mechanik nach targetDir —
// KONVERGENT (slice-038, ADR-0007 Idempotenz-Klasse): reine tool-eigene Infrastruktur,
// bei jedem Lauf kanonisch neu geschrieben (heilt Drift), kein Refuse, kein --force
// (das Pre-Flight-refuse-Modell aus slice-025 ist mit slice-038 gefallen). Der Guard
// traegt seinen universellen Boden GEBACKEN (slice-036); das Sprach-Set kommt als
// blocked/<lang>-Fragment (BlockedFragment, add-lang), NICHT hier (Enforce ist sprachlos).
//
// MIT DER ERFASSUNG, UND ZWAR GEKOPPELT (LH-FA-10, ADR-0022 Festlegung 4 und 5): der
// Traeger, der Hook-Wrapper und der Erfassungs-Block in .claude/settings.json entstehen
// GEMEINSAM oder gar nicht. Scheitert die Ablage des Traegers, schreibt Enforce keinen
// der drei, nennt den Grund auf notice und gibt KEINEN Fehler zurueck — der Bootstrap
// endet erfolgreich, und das Ziel ist ohne Erfassung vollstaendig (LH-QA-01: kein Hook,
// der auf ein fehlendes Programm zeigt). Beide Zweige messen
// TestEnforce_ErfassungLiegtMitDemTraeger und TestEnforce_KeineErfassungOhneTraeger.
//
// notice ist Pflicht und darf nicht nil sein: der Grund ist der Vertrag des
// Fehlerzweigs, und ein stiller Fehlerzweig waere die Zusage ohne ihre Haelfte.
//
// DER BLOCK HAENGT DAMIT AN EINEM LAUFZEIT-AUSGANG. Ein Re-Lauf, der ihn nicht setzen
// kann, schreibt die Datei ohne ihn (konvergent, kein Prune) — die Konfiguration
// beschreibt die Wirklichkeit. Zwei Laeufe derselben Tool-Version erzeugen deshalb
// verschiedene Bytes, wenn die Ablage beim einen gelingt und beim anderen nicht
// (ADR-0022 Festlegung 4; LH-QA-02 bindet die Bytes an Version UND Ausgang).
//
// Der WRAPPER wird im Fehlerzweig nicht entfernt: konvergente Artefakte prunen nie
// (spec/architecture.md §5), und ein liegengebliebener Wrapper ohne Traeger schweigt
// ohnehin — das ist der Fall, fuer den es ihn gibt.
func Enforce(targetDir string, notice io.Writer) error {
	captureErr := placeCarrier(targetDir)
	captured := captureErr == nil
	if !captured {
		fmt.Fprintf(notice, "ai-harness-init: Erfassungsschicht nicht abgelegt — %v. "+
			"Das Repo ist ohne sie vollstaendig; ein erneuter Lauf des Werkzeugs legt sie an.\n", captureErr)
	}
	for _, f := range enforceFiles() {
		content, err := enforceContent(f.src, captured)
		if err != nil {
			return err
		}
		if err := writeFileMode(targetDir, f.dst, content, f.mode); err != nil {
			return err
		}
	}
	if !captured {
		return nil
	}
	for _, f := range captureFiles() {
		content, err := enforceFS.ReadFile(f.src)
		if err != nil {
			return fmt.Errorf("%s einbetten: %w", f.src, err)
		}
		if err := writeFileMode(targetDir, f.dst, content, f.mode); err != nil {
			return err
		}
	}
	// DIE FELDLISTE TEILT DEN ZWEIG DES TRAEGERS (ADR-0022 Festlegung 5(a) und 7): sie ist
	// sein Ausdruck ueber sein eigenes Schema und entsteht deshalb mit ihm. Ein Ziel ohne
	// abgelegten Traeger erfasst nichts, und eine Liste ueber einer Erfassung, die dort
	// nicht liegt, waere eine Aussage ueber ein fehlendes Programm — dieselbe Klasse wie
	// der Hook-Eintrag, den der Fehlerzweig ausdruecklich ausspart. Beide Zweige messen
	// TestFeldliste_LiegtMitDemTraeger und TestFeldliste_KeineFeldlisteOhneTraeger.
	return FieldList(targetDir)
}

// enforceContent liefert den zu schreibenden Inhalt einer eingebetteten Quelle. Alle
// bis auf die Hook-Konfiguration gehen verbatim durch; jene bekommt den Erfassungs-Block
// genau dann, wenn der Traeger liegt (ADR-0022 Festlegung 5).
//
// FAIL-CLOSED an zwei Stellen: fehlt die Marke, oder ergibt das Ergebnis kein gueltiges
// JSON, bricht der Emit ab. Eine still ungefuegte Konfiguration waere eine Erfassung,
// die niemand ruft, bei gruenem Bootstrap.
func enforceContent(src string, captured bool) ([]byte, error) {
	raw, err := enforceFS.ReadFile(src)
	if err != nil {
		return nil, fmt.Errorf("%s einbetten: %w", src, err)
	}
	if src != settingsSrc || !captured {
		return raw, nil
	}
	block, err := enforceFS.ReadFile(captureHooksSrc)
	if err != nil {
		return nil, fmt.Errorf("%s einbetten: %w", captureHooksSrc, err)
	}
	at := bytes.Index(raw, []byte(hooksAnchor))
	if at < 0 {
		return nil, fmt.Errorf("%s: die Marke %q fehlt — der Erfassungs-Block hat keinen Ort", src, hooksAnchor)
	}
	at += len(hooksAnchor)
	out := make([]byte, 0, len(raw)+len(block))
	out = append(out, raw[:at]...)
	out = append(out, block...)
	out = append(out, raw[at:]...)
	if !json.Valid(out) {
		return nil, fmt.Errorf("%s: mit dem Erfassungs-Block ergibt sich kein gueltiges JSON", src)
	}
	return out, nil
}

// placeCarrier kopiert das LAUFENDE Bild in den gitignorierten Zustands-Bereich des
// Ziels (ADR-0022 Festlegung 1). Kein Bau im Ziel, kein Fetch, keine zweite
// Plattform-Matrix: die Plattform des Bildes ist die des Bootstrap-Hosts, weil es
// gerade laeuft.
//
// Der Fehler wird ZURUECKGEGEBEN, nicht behandelt — er ist der Zweig aus Festlegung
// 5(a), und wer ihn behandelt, ist Enforce.
func placeCarrier(targetDir string) error {
	image, err := os.Executable()
	if err != nil {
		return fmt.Errorf("das laufende Bild ist nicht aufloesbar: %w", err)
	}
	return copyExecutable(image, targetDir, CarrierPath(image))
}

// copyExecutable oeffnet das Bild src und legt es unter targetDir/rel (slash) ab.
// Zwei Schritte, weil zwei Fehlerbilder zu unterscheiden sind: die Quelle ist nicht
// lesbar, oder das Ziel ist nicht beschreibbar. GESTREAMT statt am Stueck gelesen —
// das Bild ist zweistellig MB gross, und der Bootstrap soll es nicht zusaetzlich im
// Speicher halten.
func copyExecutable(src, targetDir, rel string) error {
	in, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("%s lesen: %w", src, err)
	}
	defer func() { _ = in.Close() }()
	return writeCarrier(targetDir, rel, in)
}

// writeCarrier schreibt den Strom src nach targetDir/rel (slash) mit carrierMode.
// Geschrieben wird DANEBEN und dann umbenannt, aus zwei Gruenden: ueber ein gerade
// laufendes Bild schreibt Linux nicht (ETXTBSY — ein Re-Lauf waehrend eines aktiven
// Agenten-Laufs traefe genau das), und ein abgebrochener Lauf liesse sonst ein halbes
// Bild an der Stelle zurueck, an der der Hook je Tool-Call ein ganzes startet.
func writeCarrier(targetDir, rel string, src io.Reader) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(rel))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
	}
	tmp := dst + ".neu"
	out, err := os.OpenFile(tmp, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, carrierMode)
	if err != nil {
		return fmt.Errorf("%s schreiben: %w", rel, err)
	}
	if _, err := io.Copy(out, src); err != nil {
		_ = out.Close()
		_ = os.Remove(tmp)
		return fmt.Errorf("%s schreiben: %w", rel, err)
	}
	if err := out.Close(); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("%s schreiben: %w", rel, err)
	}
	// Chmod NACH dem Anlegen: OpenFile wendet den Modus nur beim ANLEGEN an, und eine
	// restriktive umask nimmt davon noch Bits weg — dieselbe Klasse wie in writeFileMode.
	if err := os.Chmod(tmp, carrierMode); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("%s Modus setzen: %w", rel, err)
	}
	if err := os.Rename(tmp, dst); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("%s ersetzen: %w", rel, err)
	}
	return nil
}

// BlockedFragment droppt das Sprach-BLOCKED-Fragment blocked/<lang> nach targetDir —
// KONVERGENT (slice-038, Review-I-1-Versoehnung: ADR-0007 Z.100 listet blocked/<sprache>
// als konvergent, nicht mehr skip-if-present wie slice-037). Kanonisch neu schreiben ist
// auch im Mono-Repo idempotent: ein zweites add-lang derselben Sprache schreibt byte-
// identisch (LH-QA-02), kein Clobber-Risiko (der Inhalt ist tool-fixiert). Ohne gen-Profil
// (unbekannte/leere Sprache) ist es ein no-op — sprachlos gibt es kein Fragment, nur den
// gebackenen Guard-Boden. Der emittierte Guard vereinigt es zur Laufzeit mit dem Boden.
func BlockedFragment(targetDir, lang string) error {
	frag, ok := blockedByLang()[lang]
	if !ok {
		return nil
	}
	return writeFileMode(targetDir, BlockedFragmentPath(lang), []byte(frag), 0o644)
}

// writeFileMode ist der KONVERGENTE Writer (slice-038): schreibt content nach targetDir/rel
// (slash) mit mode IMMER (kanonisch, ueberschreibt) — MkdirAll fuer den Elternpfad + Chmod
// NACH dem Write (os.WriteFile wendet den Modus nur beim Anlegen an — ueber eine vorhandene
// 0644-Datei geschrieben bliebe der richtige Inhalt sonst nicht ausfuehrbar zurueck, Befund
// slice-022a L2). Fuer tool-eigene Infrastruktur, die der Adopter nicht editieren soll.
func writeFileMode(targetDir, rel string, content []byte, mode fs.FileMode) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(rel))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
	}
	if err := os.WriteFile(dst, content, mode); err != nil {
		return fmt.Errorf("%s schreiben: %w", rel, err)
	}
	if err := os.Chmod(dst, mode); err != nil {
		return fmt.Errorf("%s Modus setzen: %w", rel, err)
	}
	return nil
}

// writeSkipIfPresent ist der SKIP-IF-PRESENT-Writer (slice-038, ADR-0007): schreibt content
// NUR, wenn targetDir/rel FEHLT — eine vorhandene Datei bleibt unberuehrt (return nil, kein
// Fehler). Fuer Adopter-Boden (Doc-Chain, README, Skelett-Code, .d-check.yml, Commands): der
// idempotente Re-Lauf clobbert adopter-modifizierten Inhalt NIE (der sichere Default der ADR).
func writeSkipIfPresent(targetDir, rel string, content []byte, mode fs.FileMode) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(rel))
	switch _, err := os.Stat(dst); {
	case err == nil:
		return nil // vorhanden -> nie ueberschreiben (skip-if-present)
	case !errors.Is(err, fs.ErrNotExist):
		return fmt.Errorf("%s pruefen: %w", rel, err)
	}
	return writeFileMode(targetDir, rel, content, mode)
}

// EnforceFile liefert den eingebetteten Inhalt einer Mechanik-Quelle an ihrem
// Ziel-Relpfad (fuer Tests/Inspektion). Leerer slice, falls dst unbekannt.
func EnforceFile(dst string) []byte {
	for _, f := range enforceFiles() {
		if f.dst == dst {
			content, err := enforceFS.ReadFile(f.src)
			if err != nil {
				return nil
			}
			return content
		}
	}
	return nil
}
