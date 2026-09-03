package archive

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

const (
	stubVorlageSlice = "archiv-stub-slice.template.md"
	stubVorlageWelle = "archiv-stub-welle.template.md"
	templatesUnter   = "templates/docs/plan/planning"
	leerwert         = "— keine —"
)

// Ersetzung ist ein Platzhalter der Vorlage und der Wert, der an seine Stelle
// tritt. Die Reihenfolge einer Ersetzungs-Liste ist TRAGEND: `<welle-id>` ist
// Teilzeichenkette von `<welle-id>-results.md` und von
// `done/<welle-id>/archiv.zip`, also stehen die zusammengesetzten Platzhalter
// vor dem einfachen. Gedeckt von TestAnwendenSchreibtBeideStubArtenAusDerVorlage:
// sein Welle-Stub traegt `**Ergebnisnotiz:** [welle-10-results.md](…)` — bei
// umgedrehter Reihenfolge stuende dort `welle-10-results.md` ohne Link.
type Ersetzung struct {
	Platzhalter string
	Wert        string
}

// VorlagenVerzeichnis liefert den Pfad zu den Stub-Vorlagen im vendored
// Baseline-Baum. Der <tag> wird ENTDECKT statt geraten — derselbe Weg, den
// baseline-verify und der Regelwerk-Injektor gehen, und darum ohne eine zweite
// Quelle fuer den Tag-String.
//
// FAIL-CLOSED: mehr oder weniger als ein <tag>-Verzeichnis ist ein Fehler. Die
// Setzung lautet "ein Tag zur Zeit"; wer zwei findet, weiss nicht, welche Form
// gilt.
func VorlagenVerzeichnis(root string) (string, error) {
	basis := filepath.Join(root, ".harness", "baseline")
	eintraege, err := os.ReadDir(basis)
	if err != nil {
		return "", fmt.Errorf(".harness/baseline lesen: %w", err)
	}
	var tags []string
	for _, e := range eintraege {
		if e.IsDir() {
			tags = append(tags, e.Name())
		}
	}
	if len(tags) != 1 {
		return "", fmt.Errorf("erwartet genau ein <tag>-Verzeichnis unter .harness/baseline/ (gefunden: %d)", len(tags))
	}
	return filepath.Join(basis, tags[0], filepath.FromSlash(templatesUnter)), nil
}

// AusVorlage liest die Vorlage, kuerzt sie auf die drei Teile, die die Ziel-Form
// ausmachen, und ersetzt die Platzhalter der Reihe nach.
//
// ZUSAGE, und sie ist ADR-0033 Festlegung 3: die Form kommt aus der Vorlage,
// nicht aus einem im Code formatierten Text. Fehlt die Vorlage, faellt der Aufruf
// mit einem Fehler aus und erfindet keine Form.
// Gedeckt von TestAusVorlageFaelltOhneVorlageAus.
func AusVorlage(vorlage string, ersetzungen []Ersetzung) (string, error) {
	roh, err := os.ReadFile(vorlage)
	if errors.Is(err, os.ErrNotExist) {
		return "", fmt.Errorf("%s: Vorlage fehlt", vorlage)
	}
	if err != nil {
		return "", fmt.Errorf("%s lesen: %w", vorlage, err)
	}
	text := Kuerze(string(roh))
	for _, e := range ersetzungen {
		text = strings.ReplaceAll(text, e.Platzhalter, e.Wert)
	}
	return text, nil
}

// Kuerze zieht aus einer Stub-Vorlage die drei Teile heraus, die die Ziel-Form
// ausmachen: die H1-Zeile, den Archiv-Zeiger-Block (die zusammenhaengenden
// `>`-Zeilen ab `> **ARCHIVIERT**`) und den LETZTEN Absatz — den Feld-Block.
//
// ABGRENZUNG: was dazwischen liegt, schreibt an den Kopierenden — Template-Hinweis,
// Regel-Absatz, Bedienhinweis — und faellt weg, wie es die Vorlagen-Konvention
// vorsieht. In hundert Stubs waeren es hundert Kopien einer Norm, die an einer
// Stelle lebt.
func Kuerze(inhalt string) string {
	var h1, zeiger, absatz []string
	imZeiger := false
	// Der abschliessende Zeilenumbruch der Datei ergaebe eine letzte, leere Zeile
	// — und die setzte den Feld-Block zurueck, den die Kuerzung gerade braucht.
	for i, zeile := range strings.Split(strings.TrimRight(inhalt, "\n"), "\n") {
		if i == 0 {
			h1 = append(h1, zeile)
			continue
		}
		leer := strings.TrimSpace(zeile) == ""
		if strings.HasPrefix(zeile, "> **ARCHIVIERT**") {
			imZeiger = true
		}
		switch {
		case imZeiger && leer:
			imZeiger = false
		case imZeiger:
			zeiger = append(zeiger, zeile)
		case leer:
			absatz = nil
		default:
			absatz = append(absatz, zeile)
		}
	}
	teile := append(h1, "")
	teile = append(teile, zeiger...)
	teile = append(teile, "")
	teile = append(teile, absatz...)
	return strings.Join(teile, "\n") + "\n"
}

// FormOK prueft den geschriebenen Stub gegen die zwei Merkmale, an denen die
// Kuerzung ablesbar ist: er traegt den Archiv-Zeiger, und er traegt KEINE
// Abschnittsueberschrift mehr.
//
// Die zweite Haelfte ist die tragende — ein Stub mit Zeiger und vollem Text waere
// die Archivierung, die nicht stattfand. Gedeckt von
// TestFormOKMeldetStehengebliebeneUeberschrift;
// test/mutations/239-archive-welle-go-stub-ueberschrift.sh nimmt sie weg.
func FormOK(inhalt string) error {
	var fehlt []string
	if !strings.Contains(inhalt, "> **ARCHIVIERT**") || !strings.Contains(inhalt, archivName) {
		fehlt = append(fehlt, "kein Archiv-Zeiger (> **ARCHIVIERT** … "+archivName+")")
	}
	for _, zeile := range strings.Split(inhalt, "\n") {
		if strings.HasPrefix(zeile, "##") {
			fehlt = append(fehlt, "noch Abschnittsueberschriften — gekuerzt ist er damit nicht")
			break
		}
	}
	if len(fehlt) == 0 {
		return nil
	}
	return errors.New(strings.Join(fehlt, "; "))
}

// kennungRE trifft eine Kennung am Anfang der Titelzeile, gefolgt von einem der
// drei Trenner. Der Gedankenstrich steht als ALTERNATIVE und nicht in einer
// Zeichenklasse — Go liest die Datei als UTF-8, und die Alternative sagt dasselbe
// ohne die Byte-Frage aufzuwerfen.
var kennungRE = regexp.MustCompile(`^(?:slice|welle)-[0-9]+[A-Za-z0-9-]*\s*(?::|—|-)\s*`)

var rautenRE = regexp.MustCompile(`^#\s*`)
var wortRE = regexp.MustCompile(`^(?:Slice|Welle)\s+`)

// TitelVon liefert den Titel aus der ersten Zeile eines Slice- oder Welle-Plans.
// Drei Ersetzungen laufen der Reihe nach: die fuehrende Raute, das Wort
// `Slice`/`Welle` dahinter, und eine Kennung `slice-NNN`/`welle-NN` samt Trenner.
// Getroffen sind damit `# Slice slice-190: T`, `# slice-190 — T`,
// `# Welle welle-87: T` und `# welle-87 — T`.
//
// GRENZE, gemessen und nicht wegdefiniert: was keine der drei Ersetzungen trifft,
// bleibt stehen — auch ein Rest. Die Form `# Slice 190: T` traegt das Wort ohne
// das `slice-`-Praefix; die dritte Ersetzung greift dort nicht, und der Titel
// lautet danach `190: T`. Gedeckt von TestTitelVonLaesstDenNummernRestStehen.
func TitelVon(kopfzeile string) string {
	t := rautenRE.ReplaceAllString(strings.TrimRight(kopfzeile, "\r"), "")
	t = wortRE.ReplaceAllString(t, "")
	return kennungRE.ReplaceAllString(t, "")
}

// Kopfzeile ist die erste Zeile eines Dateiinhalts.
func Kopfzeile(inhalt string) string {
	if i := strings.IndexByte(inhalt, '\n'); i >= 0 {
		return inhalt[:i]
	}
	return inhalt
}

var datumRolleRE = regexp.MustCompile(`(?m)^\*\*Rolle:\*\*.*\*\*Datum:\*\*\s*([0-9]{4}-[0-9]{2}-[0-9]{2})`)
var datumAbschlussRE = regexp.MustCompile(`(?m)^\*\*Abschluss:\*\*\s*([0-9]{4}-[0-9]{2}-[0-9]{2})`)

// GeschlossenDatum liest das Abschluss-Datum eines Slice aus der
// `**Rolle:** … **Datum:**`-Zeile seiner Closure-Notiz — die LETZTE, wenn die
// Datei mehrere traegt. Fehlt die Zeile, gilt der uebergebene Ersatz.
func GeschlossenDatum(inhalt, ersatz string) string {
	treffer := datumRolleRE.FindAllStringSubmatch(inhalt, -1)
	if len(treffer) == 0 {
		return ersatz
	}
	return treffer[len(treffer)-1][1]
}

// WelleDatum liest das Abschluss-Datum einer Welle aus der `**Abschluss:**`-Zeile
// ihrer Ergebnisnotiz. Ohne Zeile steht der Leerwert-Gedankenstrich.
func WelleDatum(inhalt string) string {
	if m := datumAbschlussRE.FindStringSubmatch(inhalt); m != nil {
		return m[1]
	}
	return "—"
}

var beoRE = regexp.MustCompile(`BEO-[0-9]{3}`)
var adrRE = regexp.MustCompile(`ADR-[0-9]{4}`)
var sliceRE = regexp.MustCompile(`slice-[0-9]{3}`)
var ausgangsZeileRE = regexp.MustCompile(`(?m)^- \*\*(?:Beobachtungs-Register|Folge-Slices)`)

// Hervorgegangen liefert den Wert des Stub-Felds `Hervorgegangen:` — die
// Kennungen, die den Vorgang ueberlebt haben. Quelle sind die zwei Zeilen der
// Closure-Notiz, die einen Ausgang tragen: die Register-Zeile und die
// Folge-Slice-Zeile. Traegt die Datei keine davon, steht der Leerwert.
//
// Jede Kennung wird als Anker-Link NEU GEBAUT, nicht abgeschrieben: die Pfade der
// Closure-Notiz gelten fuer die flache done/-Ebene, der Stub liegt eine Ebene
// tiefer — und die ID-Link-Pflicht des Doku-Gates gilt im Stub wie ueberall.
// Ein Folge-Slice, den der Lifecycle nicht mehr fuehrt, steht ohne Link da statt
// mit einem toten. Gedeckt von TestHervorgegangenBautAnkerLinks.
func Hervorgegangen(root, inhalt, welleID string) string {
	zeilen := ausgangsZeilen(inhalt)
	if len(zeilen) == 0 {
		return leerwert
	}
	verbund := strings.Join(zeilen, "\n")
	var teile []string
	for _, id := range eindeutig(beoRE.FindAllString(verbund, -1)) {
		teile = append(teile, "[`"+id+"`](../../observations.md)")
	}
	for _, id := range eindeutig(adrRE.FindAllString(verbund, -1)) {
		if datei := adrDatei(root, id); datei != "" {
			teile = append(teile, "[`"+id+"`](../../../adr/"+datei+")")
		}
	}
	var folge []string
	for _, z := range zeilen {
		if strings.HasPrefix(z, "- **Folge-Slices") {
			folge = append(folge, z)
		}
	}
	for _, id := range eindeutig(sliceRE.FindAllString(strings.Join(folge, "\n"), -1)) {
		if pfad := SlicePfadRelativ(root, strings.TrimPrefix(id, "slice-"), welleID); pfad != "" {
			teile = append(teile, "["+id+"]("+pfad+")")
		} else {
			teile = append(teile, id)
		}
	}
	if len(teile) == 0 {
		return leerwert
	}
	return strings.Join(teile, " · ")
}

// ausgangsZeilen liefert die Zeilen der Closure-Notiz, die einen Ausgang tragen.
func ausgangsZeilen(inhalt string) []string {
	var out []string
	for _, z := range strings.Split(inhalt, "\n") {
		if ausgangsZeileRE.MatchString(z) {
			out = append(out, z)
		}
	}
	return out
}

// eindeutig sortiert und dedupliziert — der Stub soll bei gleichem Eingang
// dieselbe Zeile tragen, unabhaengig von der Reihenfolge im Volltext.
func eindeutig(werte []string) []string {
	gesehen := map[string]bool{}
	var out []string
	for _, w := range werte {
		if !gesehen[w] {
			gesehen[w] = true
			out = append(out, w)
		}
	}
	sort.Strings(out)
	return out
}

// adrDatei sucht die Datei zu einer ADR-Kennung unter docs/plan/adr/. Leer, wenn
// keine da ist — dann faellt die Kennung aus dem Feld, statt einen toten Link zu
// tragen.
func adrDatei(root, id string) string {
	nummer := strings.TrimPrefix(id, "ADR-")
	treffer, err := filepath.Glob(filepath.Join(root, "docs", "plan", "adr", nummer+"-*.md"))
	if err != nil || len(treffer) == 0 {
		return ""
	}
	sort.Strings(treffer)
	return filepath.Base(treffer[0])
}

// SlicePfadRelativ liefert den Pfad von docs/plan/planning/done/<welle-id>/ zu
// einer Slice-Datei, die noch irgendwo im Lifecycle liegt. Gesucht wird in vier
// Lagen, in dieser Reihenfolge: im Ziel-Verzeichnis dieses Laufs · flach in done/
// · in einem frueher archivierten Welle-Verzeichnis · in open/, next/ oder
// in-progress/. Leer, wenn keine da ist.
//
// KOPPLUNG: die zweite Lage liefert die AUFSTEIGENDE Form `../<datei>.md`. Sie ist
// der Grund, aus dem der Verweis-Nachzug eine dritte Ersetzungsrichtung fuehrt —
// zieht diese Datei bei einem SPAETEREN Lauf eine Ebene tiefer, muss das
// Welle-Segment dazwischen. Gedeckt von TestSlicePfadRelativLiefertDieAufsteigendeForm.
func SlicePfadRelativ(root, nummer, welleID string) string {
	kandidaten := []struct{ glob, form string }{
		{filepath.Join(root, filepath.FromSlash(doneDir), welleID, "slice-"+nummer+"-*.md"), "%s"},
		{filepath.Join(root, filepath.FromSlash(doneDir), "slice-"+nummer+"-*.md"), "../%s"},
	}
	for _, k := range kandidaten {
		if b := ersterTreffer(k.glob); b != "" {
			return fmt.Sprintf(k.form, b)
		}
	}
	if t := ersteDatei(filepath.Join(root, filepath.FromSlash(doneDir), "*", "slice-"+nummer+"-*.md")); t != "" {
		return "../" + filepath.Base(filepath.Dir(t)) + "/" + filepath.Base(t)
	}
	for _, d := range []string{"open", "next", "in-progress"} {
		if b := ersterTreffer(filepath.Join(root, filepath.FromSlash(planningDir), d, "slice-"+nummer+"-*.md")); b != "" {
			return "../../" + d + "/" + b
		}
	}
	return ""
}

func ersterTreffer(muster string) string {
	if t := ersteDatei(muster); t != "" {
		return filepath.Base(t)
	}
	return ""
}

func ersteDatei(muster string) string {
	treffer, err := filepath.Glob(muster)
	if err != nil || len(treffer) == 0 {
		return ""
	}
	sort.Strings(treffer)
	return treffer[0]
}
