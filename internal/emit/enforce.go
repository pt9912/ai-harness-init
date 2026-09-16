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

// EnforceClass ist die Idempotenz-Klasse eines emittierten Pfades (ADR-0007 Festlegung 3):
// konvergent heisst "bei jedem Lauf kanonisch neu schreiben", skip-if-present heisst "nur
// schreiben, wo nichts liegt". Der Nullwert ist absichtlich ungueltig — ein Eintrag ohne
// ausgewiesene Klasse faellt im Emit aus, statt still als konvergent zu gelten: "im Zweifel
// konvergent" ist das Fehlerbild, gegen das die Klasse dasteht (ADR-0054 §Kontext).
type EnforceClass int

const (
	klasseUnbestimmt EnforceClass = iota
	// Konvergent ist die Klasse der tool-eigenen Infrastruktur an einem Pfad, den die
	// Emission bestimmt — ein Verzeichnis, das sie selbst anlegt, oder ein Name, den sie
	// waehlt.
	Konvergent
	// SkipIfPresent ist die Klasse eines Pfades, den ein Adopter selbst belegen kann; ein
	// liegender Inhalt bleibt unberuehrt.
	SkipIfPresent
)

// String nennt die Klasse in der Schreibweise der ADR. Dieselbe Zeichenkette liefert
// PathClass je Pfad; der Test ueber die ganze Menge haelt sie gegen die gefahrene Richtung.
func (c EnforceClass) String() string {
	switch c {
	case Konvergent:
		return "konvergent"
	case SkipIfPresent:
		return "skip-if-present"
	}
	return "unbestimmt"
}

// enforceFile bildet eine eingebettete Quelle auf ihren Ziel-Relpfad + Modus ab und traegt
// die Klasse, mit der Enforce sie ablegt.
type enforceFile struct {
	src   string       // Pfad in enforceFS
	dst   string       // Ziel-Relpfad (slash), relativ zu targetDir
	mode  fs.FileMode  // 0755 fuer ausfuehrbare Hooks/Tools, 0644 sonst
	class EnforceClass // Konvergent | SkipIfPresent

	// meldung ist der Zusatz, den ein skip-if-present-Eintrag nennt, wenn an seinem Pfad schon
	// eine Datei liegt: das Stueck, das dem Adopter dann statt dieser Datei bereitliegt
	// (ADR-0054 Festlegung 3). Leer bei konvergenten Eintraegen — dort gibt es diesen Zustand
	// nicht.
	meldung string
}

// enforceFiles ist die emittierte Durchsetzungsschicht. Die Tool-Skripte liegen
// unter tools/harness/ (emittiertes Layout, LH-FA-06/ADR-0004 — NICHT das lokal
// adaptierte harness/tools/, MR-005). Die Claude-Hooks/-Config liegen an ihren
// von Claude Code fixierten .claude/-Pfaden. settings.json verdrahtet BEIDE Hooks —
// den Stop-Hook (slice-031) und den PreToolUse-Command-Guard (slice-032); der Guard
// wird mit seinem awk-Extraktor (tools/harness/) mit-emittiert, sonst liefe der Hook
// im Ziel ins Leere.
//
// JEDER EINTRAG NENNT SEINE KLASSE, und die Klasse eines Pfades steht nur hier bzw. in
// der Konstruktor-Funktion ihres Eintrags (commitmsg.go, slicemv.go u. a.) — eine zweite
// Liste daneben liefe gegen sie. Der Commit-Traeger ist der eine Eintrag mit
// SkipIfPresent: er liegt an einem Namen, den git fixiert, in einem Verzeichnis des
// Adopters, und ein Ziel, das dort seine eigene Zusage fuehrt, behaelt sie (ADR-0054
// Festlegung 1 und 2).
func enforceFiles() []enforceFile {
	return []enforceFile{
		{src: "templates/enforce/working-tree-hash.sh", dst: "tools/harness/working-tree-hash.sh", mode: 0o755, class: Konvergent},
		{src: "templates/enforce/record-gates.sh", dst: "tools/harness/record-gates.sh", mode: 0o755, class: Konvergent},
		{src: "templates/enforce/stop-require-gates.sh", dst: ".claude/hooks/stop-require-gates.sh", mode: 0o755, class: Konvergent},
		{src: "templates/enforce/settings.json", dst: ".claude/settings.json", mode: 0o644, class: Konvergent},
		{src: "templates/enforce/gitignore", dst: ".harness/.gitignore", mode: 0o644, class: Konvergent},
		// Enforce-Gate-Fragment (slice-034): das record-gates-Rezept als
		// harness/mk/enforce.mk. Die Ordnungskante (record-gates: $(GATE_CHECKS)) +
		// `gates: record-gates` leben im Root-Aggregator (gen), weil sie GATE_CHECKS
		// erst nach dem Glob-Include vollstaendig sehen. Sprach-agnostisch, verbatim.
		{src: "templates/enforce/enforce.mk", dst: "harness/mk/enforce.mk", mode: 0o644, class: Konvergent},
		// Aufraeum- und Berichts-Fragment der Erfassungsschicht (slice-099): zwei
		// Kommandos, kein Gate. Es steht hier und nicht in captureFiles(), weil es an
		// keinem Laufzeit-Ausgang haengt — die Begruendung traegt erfassung.go.
		erfassungFile(),
		// Fragment der Wellen-Archivierung (ADR-0033 Festlegung 4): ein Kommando,
		// kein Gate, aus derselben Klasse wie das der Erfassungsschicht. Es steht
		// hier und nicht in captureFiles(), weil es an keinem Laufzeit-Ausgang
		// haengt — die Begruendung traegt archivierung.go.
		archivierungFile(),
		// Fragment UND Werkzeug des Lifecycle-Wechsels (die Zwei-Commit-Regel auf
		// der emittierten Ebene): der mitemittierte Anweisungssatz schreibt den
		// Wechsel an zwei Stellen vor, und ohne dieses Paar bleibt der
		// Verweis-Nachzug dort Handarbeit. Beide stehen hier und nicht in
		// captureFiles(), weil sie an keinem Laufzeit-Ausgang haengen — die
		// Begruendung traegt slicemv.go.
		sliceMvMkFile(),
		sliceMvShFile(),
		// Command-Guard (slice-032): bash+awk, kein node/jq (LH-QA-03). Der Guard
		// (0755) referenziert den awk-Extraktor unter tools/harness/ — beide
		// gehoeren in denselben Emit, sonst laeuft der Guard fail-closed ins Leere.
		{src: "templates/enforce/pretooluse-command-guard.sh", dst: ".claude/hooks/pretooluse-command-guard.sh", mode: 0o755, class: Konvergent},
		{src: "templates/enforce/extract-command.awk", dst: "tools/harness/extract-command.awk", mode: 0o644, class: Konvergent},
		// Vorlauf-Waechter der zwei history-lesenden d-check-Targets (doc-immutable/
		// doc-commits). Das Doc-Gate-Fragment haengt ihn als Vorbedingung vor beide
		// Targets: ueber einer aufloesbaren, aber leeren Commit-Range meldet ein
		// history-lesendes Modul sonst "0 Befund(e)", Exit 0 — gruen ueber leerem
		// Pruefbereich (MR-007 Setzung 3). Sprach-agnostisch wie der uebrige Kern:
		// das Skript ist bash + git, ohne Docker und ohne Image.
		{src: "templates/enforce/history-range-guard.sh", dst: "tools/harness/history-range-guard.sh", mode: 0o755, class: Konvergent},
		// Commit-Kennungs-Waechter: der git-eigene Traeger, die Pruefung, die er
		// aufruft, und das Ziel, das ihn aktiviert. Er liegt versioniert im Ziel und
		// reist mit dessen Klon; seine Aktivierung ist lokale Konfiguration. Die
		// Begruendung der drei Eintraege und ihre zwei Klassen traegt commitmsg.go.
		commitMsgHookFile(),
		commitMsgCheckFile(),
		hooksInstallMkFile(),
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
// KONVERGENT wie jedes weitere Hook-Skript an einem von Claude Code fixierten .claude/-Pfad
// (ADR-0007 Festlegung 3) — die Klasse nennt der Eintrag wie jeder andere. Bewusst NICHT in
// enforceFiles()/EnforcePaths(): jene Menge entsteht unbedingt, diese nur im Gelingens-Zweig.
func captureFiles() []enforceFile {
	return []enforceFile{
		{src: "templates/enforce/span-emit.sh", dst: ".claude/hooks/span-emit.sh", mode: 0o755, class: Konvergent},
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

// EnforcePaths liefert die Ziel-Relpfade der Durchsetzungs-Mechanik — die Inventur der
// Pfade, die der Emit anfasst. Tests koppeln den Bestand des Ziels daran
// (TestEnforce_EmitsAllMechanicFiles, TestEnforce_IdempotenzKlasseJePfad).
//
// Der Commit-Traeger bleibt in dieser Menge, obwohl er skip-if-present abgelegt wird: die
// Liste nennt die Pfade, die ein Lauf anfasst, nicht die, die er ueberschreibt — welche
// Klasse ein Pfad traegt, sagt PathClass.
//
// SPRACH-AGNOSTISCH: das blocked/<lang>-Fragment gehoert NICHT hierher — es ist
// skip-if-present (Mono-Repo-Wiederverwendung, mehrere Module gleicher Sprache) und wird von
// add-lang via BlockedFragment gedroppt, nicht von diesem Emit.
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

// PathClass nennt die Idempotenz-Klasse des Ziel-Relpfads dst; klasseUnbestimmt, wenn dst
// nicht in der Aufzaehlung steht oder ihr Eintrag keine Klasse nennt. Sie ist die Auskunft
// ueber dieselbe Klassifikation, die Enforce faehrt: die Klassen stehen an den Eintraegen der
// Aufzaehlung, und ein Test, der die Klassen je Pfad prueft, liest sie hier.
func PathClass(dst string) EnforceClass {
	for _, f := range enforceFiles() {
		if f.dst == dst {
			return f.class
		}
	}
	return klasseUnbestimmt
}

// Enforce schreibt die sprach-agnostische Durchsetzungs-Mechanik nach targetDir — JEDEN PFAD
// NACH SEINER KLASSE (ADR-0007 Festlegung 3, ADR-0054 Festlegung 1): ein konvergenter Pfad
// wird bei jedem Lauf kanonisch neu geschrieben (heilt Drift), ein skip-if-present-Pfad nur
// dort, wo nichts liegt — ein liegender Inhalt bleibt stehen und der Lauf nennt ihn auf
// notice. Kein Refuse, kein --force. Der Guard traegt seinen universellen Boden GEBACKEN;
// das Sprach-Set kommt als blocked/<lang>-Fragment (BlockedFragment, add-lang), NICHT hier
// (Enforce ist sprachlos).
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
		if err := writeEnforceFile(targetDir, f, content, notice); err != nil {
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
		if err := writeEnforceFile(targetDir, f, content, notice); err != nil {
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

// writeEnforceFile legt eine emittierte Datei nach der Klasse ihres Eintrags ab. Ein Eintrag
// ohne Klasse bricht ab, statt als konvergent durchzugehen: die Klasse entscheidet, ob ein
// liegender Inhalt ueberschrieben wird, und jeder Eintrag nennt sie darum (ADR-0054 §Kontext).
func writeEnforceFile(targetDir string, f enforceFile, content []byte, notice io.Writer) error {
	switch f.class {
	case Konvergent:
		return writeFileMode(targetDir, f.dst, content, f.mode)
	case SkipIfPresent:
		return writeSkipIfPresentTold(targetDir, f, content, notice)
	}
	return fmt.Errorf("%s: keine Idempotenz-Klasse (%s) — ein Pfad ohne Klasse faellt aus, statt konvergent zu gelten (ADR-0007 Festlegung 3)", f.dst, f.class)
}

// writeSkipIfPresentTold ist writeSkipIfPresent MIT Meldung: liegt am Zielpfad schon eine
// Datei, bleibt sie unberuehrt und der Lauf nennt es auf notice, zusammen mit dem Zusatz des
// Eintrags (ADR-0054 Festlegung 3). Die Meldung ist die Auskunft an den Adopter: sein Inhalt
// bleibt stehen, und ihm liegt die genannte Datei statt dieser bereit.
func writeSkipIfPresentTold(targetDir string, f enforceFile, content []byte, notice io.Writer) error {
	liegt, err := dateiLiegt(targetDir, f.dst)
	if err != nil {
		return err
	}
	if !liegt {
		return writeFileMode(targetDir, f.dst, content, f.mode)
	}
	zeile := fmt.Sprintf("ai-harness-init: %s liegt bereits — die Datei bleibt unberuehrt (skip-if-present).", f.dst)
	if f.meldung != "" {
		zeile += " " + f.meldung
	}
	fmt.Fprintln(notice, zeile)
	return nil
}

// dateiLiegt sagt, ob am Zielpfad schon etwas liegt. Ein anderes Stat-Ergebnis als
// "liegt" oder "fehlt" ist ein Fehler und wird zurueckgegeben, nicht als "fehlt" gelesen.
func dateiLiegt(targetDir, rel string) (bool, error) {
	_, err := os.Stat(filepath.Join(targetDir, filepath.FromSlash(rel)))
	switch {
	case err == nil:
		return true, nil
	case errors.Is(err, fs.ErrNotExist):
		return false, nil
	}
	return false, fmt.Errorf("%s pruefen: %w", rel, err)
}

// writeFileMode ist der KONVERGENTE Writer: schreibt content nach targetDir/rel
// (slash) mit mode IMMER (kanonisch, ueberschreibt) — MkdirAll fuer den Elternpfad + Chmod
// NACH dem Write (os.WriteFile wendet den Modus nur beim Anlegen an, und eine restriktive
// umask nimmt davon noch Bits weg: ueber eine vorhandene 0644-Datei geschrieben bliebe der
// richtige Inhalt sonst nicht ausfuehrbar zurueck). Fuer tool-eigene Infrastruktur an einem
// Pfad, den die Emission bestimmt — den Adopter-Boden kann er clobbern, ein
// skip-if-present-Pfad mit liegender Datei erreicht ihn nicht (writeSkipIfPresentTold).
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

// writeSkipIfPresent ist der SKIP-IF-PRESENT-Writer ohne Meldung: schreibt content
// NUR, wenn targetDir/rel FEHLT — eine vorhandene Datei bleibt unberuehrt (return nil, kein
// Fehler). Fuer Adopter-Boden (Doc-Chain, README, Skelett-Code, .d-check.yml, Commands,
// Rollen-Typen): der idempotente Re-Lauf clobbert adopter-modifizierten Inhalt NIE (der
// sichere Default der ADR). Ein Pfad, dessen belegter Zustand dem Adopter GEMELDET werden
// soll, nimmt writeSkipIfPresentTold.
func writeSkipIfPresent(targetDir, rel string, content []byte, mode fs.FileMode) error {
	liegt, err := dateiLiegt(targetDir, rel)
	if err != nil {
		return err
	}
	if liegt {
		return nil // vorhanden -> nie ueberschreiben (skip-if-present)
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
