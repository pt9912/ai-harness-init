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
	stubVorlageSlice  = "archive-stub-slice.template.md"
	stubVorlageWelle  = "archive-stub-wave.template.md"
	stubVorlageReport = "archive-stub-report.template.md"
	// stubVorlageUmzug ist die Vorlage des Umzugs-Stubs (ADR-0112 Festlegung 2) —
	// repo-eigen wie die Report-Vorlage, planningVorlagePfad liest dort.
	stubVorlageUmzug = "archive-stub-umzug.template.md"
	templatesUnter   = "templates/docs/plan/planning"
	leerwert         = "— keine —"
)

// Die zwei Zeiger-Marken der Stub-Formen. archivZeigerMarke oeffnet den
// Archiv-Zeiger-Block (Slice, Welle, Report), umzugsZeigerMarke den des
// Umzugs-Stubs — der Umzugs-Stub traegt bewusst KEINEN Archiv-Zeiger: sein
// Volltext liegt an der neuen Arbeitsbaum-Adresse, nicht im Archiv-Zip
// (ADR-0112 Festlegung 2). Beide steuern Kuerze/FormOK (Archiv-Formen) und
// KuerzeUmzug/FormOKUmzug (Umzugs-Form) aus einer Quelle.
const (
	archivZeigerMarke = "> **ARCHIVIERT**"
	umzugsZeigerMarke = "> **UMZUGEZOGEN**"
	// Die zwei Überschriften, die die Umzugs-Stub-Form zusätzlich trägt. Die
	// structure-Regel der Gate-Konfiguration liest die Stub-Datei unter
	// done/slice-*.md als geschlossenen Slice und verlangt die §2-Sektion (leer
	// reicht — die DoD-Sektion braucht kein Häkchen), das planning-Modul die
	// §7-Stillgelegt-Fassung mit der **Gegenstand:**-Zeile ·
	// seit slice-altbestand-stubs-voll-v1. Jede andere Überschrift bleibt
	// form-widrig.
	umzugsDoDHeaderUeberschrift   = "## 2. Definition of Done"
	umzugsClosureNotizUeberschrift = "## 7. Closure-Notiz"
)

// Ersetzung ist ein Platzhalter der Vorlage und der Wert, der an seine Stelle
// tritt. Die Reihenfolge einer Ersetzungs-Liste ist TRAGEND: `<wave-id>` ist
// Teilzeichenkette von `<wave-id>-results.md` und von
// `done/<wave-id>/archive.zip`, also stehen die zusammengesetzten Platzhalter
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
	return AusVorlageAn(vorlage, archivZeigerMarke, ersetzungen)
}

// AusVorlageAn ist AusVorlage in der Fassung des Umzugs-Stubs: die Kuerzung
// ankeret an der uebergebenen Zeiger-Marke statt am Archiv-Zeiger. Dieselbe
// Setzung wie AusVorlage — die Form kommt aus der Vorlage, fehlt sie, faellt der
// Aufruf aus. Gedeckt wie AusVorlage ueber TestAusVorlageFaelltOhneVorlageAus;
// die Umzugs-Fassung haelt TestAnwendenBrichtBeiVerletzterUmzugStubFormAb am
// Lauf (die Vorlage ohne ihren Zeiger-Block).
func AusVorlageAn(vorlage, marke string, ersetzungen []Ersetzung) (string, error) {
	roh, err := os.ReadFile(vorlage)
	if errors.Is(err, os.ErrNotExist) {
		return "", fmt.Errorf("%s: Vorlage fehlt", vorlage)
	}
	if err != nil {
		return "", fmt.Errorf("%s lesen: %w", vorlage, err)
	}
	text := kuerzeAn(string(roh), marke)
	for _, e := range ersetzungen {
		text = strings.ReplaceAll(text, e.Platzhalter, e.Wert)
	}
	return text, nil
}

// Kuerze zieht aus einer Stub-Vorlage die drei Teile heraus, die die Ziel-Form
// ausmachen: die H1-Zeile, den Archiv-Zeiger-Block und den LETZTEN Absatz — den
// Feld-Block. Gedeckt von TestKuerzeLaesstNurH1ZeigerUndFeldblock.
func Kuerze(inhalt string) string { return kuerzeAn(inhalt, archivZeigerMarke) }

// kuerzeAn ist Kuerze mit der Zeiger-Marke als Parameter: der Zeiger-Block
// beginnt an der zusammenhaengenden `>`-Zeile ab <marke>, alles Uebrige wie in
// Kuerze. Eine zweite Fassung der Kuerzung haette driften koennen — die Umzugs-
// Vorlage ankeret an ihrer eigenen Marke. ABGRENZUNG: was zwischen H1 und
// Feld-Block liegt, schreibt an den Kopierenden — Template-Hinweis, Regel-Absatz,
// Bedienhinweis — und faellt weg, wie es die Vorlagen-Konvention vorsieht. In
// hundert Stubs waeren es hundert Kopien einer Norm, die an einer Stelle lebt.
func kuerzeAn(inhalt, marke string) string {
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
		if strings.HasPrefix(zeile, marke) {
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
	if !strings.Contains(inhalt, archivZeigerMarke) || !strings.Contains(inhalt, archivName) {
		fehlt = append(fehlt, "kein Archiv-Zeiger ("+archivZeigerMarke+" … "+archivName+")")
	}
	fehlt = ohneUeberschriften(inhalt, fehlt, nil)
	if len(fehlt) == 0 {
		return nil
	}
	return errors.New(strings.Join(fehlt, "; "))
}

// FormOKUmzug ist die Umzugsvariante der Stub-FORM (ADR-0112 Festlegung 2): der
// Stub traegt den Umzugs-Zeiger auf die neue Arbeitsbaum-Adresse, und er traegt
// gerade KEINEN Archiv-Zeiger und sonst keine Abschnittsüberschrift — ein Stub
// mit Umzugs-Zeiger und vollem Text waere der Umzug, der nicht stattfand. Die
// EINE erlaubten Überschriften sind die zwei der Stillgelegt-Fassung
// (umzugsStillgelegtUeberschriften), die structure-Regel und planning-Modul von
// einem done/-slice-Plan verlangen. Die zweite Haelfte ist die tragende, wie
// bei FormOK; die
// Abwesenheit des Archiv-Zeigers ist die dieser Klasse eigene: ihr Volltext
// liegt byte-genau an der neuen Adresse, nicht im Archiv-Zip. Gedeckt von
// TestFormOKUmzugMeldetDieFehlendeMarke; die Verdrahtung misst
// TestAnwendenBrichtBeiVerletzterUmzugStubFormAb
// (test/mutations/825-archive-welle-go-umzug-stub-form-verdrahtung.sh).
func FormOKUmzug(inhalt string) error {
	var fehlt []string
	if !strings.Contains(inhalt, umzugsZeigerMarke) || !strings.Contains(inhalt, doneName+"/") {
		fehlt = append(fehlt, "kein Umzugs-Zeiger ("+umzugsZeigerMarke+" … "+doneName+"/…)")
	}
	if strings.Contains(inhalt, archivZeigerMarke) {
		fehlt = append(fehlt, "Archiv-Zeiger im Umzugs-Stub — der Volltext liegt an der neuen Adresse, nicht im Archiv")
	}
	fehlt = ohneUeberschriften(inhalt, fehlt, map[string]bool{
		umzugsDoDHeaderUeberschrift:   true,
		umzugsClosureNotizUeberschrift: true,
	})
	if len(fehlt) == 0 {
		return nil
	}
	return errors.New(strings.Join(fehlt, "; "))
}

// ohneUeberschriften haelt die Haelfte, die FormOK und FormOKUmzug teilen:
// stehengebliebene Abschnittsueberschriften melden. `erlaubte` nennt die
// Überschriften, die der Rufende zulaesst — FormOK keine, die Umzugsvariante die
// Stillgelegt-Fassung. Eine zweite Fassung dieser Schleife in zwei Formen haette
// gedriftet; 239 enthemmt sie — fuer beide Stub-Formen zugleich, weil die
// Halte-Funktion geteilt ist — und die Verdrahtung der Umzugsvariante misst 825.
// Gedeckt von TestFormOKMeldetStehengebliebeneUeberschrift und der
// erlaubten-Fassung in TestFormOKUmzugMeldetDieFehlendeMarke.
func ohneUeberschriften(inhalt string, fehlt []string, erlaubte map[string]bool) []string {
	for _, zeile := range strings.Split(inhalt, "\n") {
		if strings.HasPrefix(zeile, "##") {
			if erlaubte[strings.TrimSpace(zeile)] {
				continue
			}
			return append(fehlt, "noch Abschnittsueberschriften — gekuerzt ist er damit nicht")
		}
	}
	return fehlt
}

// kennungRE trifft eine Kennung am Anfang der Titelzeile, gefolgt von einem der
// drei Trenner — die Nummer (`slice-190`) wie den Namen (`slice-<name>`, MR-057
// Setzung 1); beide beginnen mit einem Zeichen aus [0-9A-Za-z]. Der
// Gedankenstrich steht als ALTERNATIVE und nicht in einer Zeichenklasse — Go
// liest die Datei als UTF-8, und die Alternative sagt dasselbe ohne die
// Byte-Frage aufzuwerfen. Gedeckt von TestTitelVonStreiftDenNamen.
var kennungRE = regexp.MustCompile(`^(?:slice|wave)-[0-9A-Za-z][A-Za-z0-9-]*\s*(?::|—|-)\s*`)

var rautenRE = regexp.MustCompile(`^#\s*`)
var wortRE = regexp.MustCompile(`^(?:Slice|Welle)\s+`)

// TitelVon liefert den Titel aus der ersten Zeile eines Slice- oder Welle-Plans.
// Drei Ersetzungen laufen der Reihe nach: die fuehrende Raute, das Wort
// `Slice`/`Welle` dahinter, und eine Kennung `slice-<Kennung>`/`welle-<Kennung>`
// samt Trenner. Getroffen sind damit `# Slice slice-190: T`, `# slice-190 — T`,
// `# Welle welle-87: T`, `# welle-87 — T` und `# Slice slice-<name>: T`.
//
// GRENZE, gemessen und nicht wegdefiniert: was keine der drei Ersetzungen trifft,
// bleibt stehen — auch ein Rest. Die Form `# Slice 190: T` traegt das Wort ohne
// das `slice-`-Praefix; die dritte Ersetzung greift dort nicht, und der Titel
// lautet danach `190: T`. Und fehlt der Trenner hinter der Kennung, streift
// kennungRE nur einen Teil von ihr — Nummer wie Name: der Bindestrich im Inneren
// gilt dann als Trenner, `# slice-foo-bar T` ergibt `bar T`, `# slice-190-2 T`
// ergibt `2 T`; eine Kennung ohne inneren Bindestrich bleibt ganz stehen.
// Gedeckt von TestTitelVonLaesstDenNummernRestStehen.
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

// beoRE trifft die Register-Kennung, die dieses Repo heute fuehrt:
// `BEO-<KUERZEL>/<slug>` (ADR-0034 Festlegung 3) — <KUERZEL> aus der
// Modus-Deklaration (Grossbuchstaben), <slug> lowercase Kebab-Case. Die vor
// ADR-0034 gefuehrte dreistellige Form `BEO-NNN` wird NICHT MEHR erkannt: das
// Register selbst kennt sie nicht mehr, ein aufgeloester Nachfolgepfad laesst
// sich aus drei Ziffern nicht rekonstruieren, und ein aus der Luft gegriffener
// Link waere schlechter als das bare Fehlen der Zeile — dieselbe Abwaegung, die
// adrDatei() fuer eine ADR ohne Datei trifft. Historische Closure-Notizen in
// done/ (eingefroren, AGENTS.md §3.11) tragen die alte Form weiter; faellt eine
// solche Welle dereinst unter archive-welle, verliert ihr Stub die Zeile still
// — derselbe Ausgang, den Risiko 4 des auslösenden Slice als "entfallen"
// vorsieht, wenn diese Entscheidung hier steht. Gedeckt von
// TestHervorgegangenBautAnkerLinks (heutige Form) und
// TestHervorgegangenAlteDreistelligeFormBleibtUnerkannt (die Grenze).
var beoRE = regexp.MustCompile(`BEO-[A-Z]+/[a-z0-9]+(?:-[a-z0-9]+)*`)
var adrRE = regexp.MustCompile(`ADR-[0-9]{4}`)

// sliceRE trifft eine nummerierte Slice-Kennung (slice-NNN) oder eine
// benannte (ein Slug aus Kleinbuchstaben, Ziffern und Bindestrich, MR-057
// Setzung 1, etwa slice-welle-10-aspekt) — eine rein numerische Kebab-Kette
// wie "slice-13" faellt unter die zweite Alternative; "ohne Ziffern" waere
// enger, als die Zeichenklasse [a-z0-9] zulaesst.
//
// REIHENFOLGE IST TRAGEND: Go-`regexp` waehlt leftmost-first, nicht
// leftmost-longest (anders als `MustCompilePOSIX`) — die Ziffernform steht
// deshalb ZUERST. Stuende die Kebab-Alternative vorn, gewaenne sie bei
// "slice-170-archivierungs-werkzeug" vor der Ziffernform und liefert die
// GANZE Kette statt der Nummer allein. Gedeckt von
// TestSliceKennungAusTitelSuffixBleibtDieNummer;
// test/mutations/318-stub-slicere-alternativen-reihenfolge.sh vertauscht
// genau diese Reihenfolge.
//
// GRENZE, gemessen (MR-057 Setzung 1, zweite Namensform): das Praefix eines
// vorhandenen Ankers (`LH-*`, `ADR-*`, `CO-*`) ist in diesem Repo
// grossgeschrieben (`.d-check.yml` ids-Muster `ADR-\d{4}`,
// `LH-[A-Z]{2}-\d{2}`) und trifft die Zeichenklasse [a-z0-9] nicht — ein
// Slice namens "slice-ADR-0042-nachzug" faellt aus dieser Erkennung heraus,
// wie aus dem Fundmuster in harness/tools/slice-mv.sh (dieselbe Grenze dort).
var sliceRE = regexp.MustCompile(`slice-(?:[0-9]{3}|[a-z0-9]+(?:-[a-z0-9]+)*)`)
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
// mit einem toten (SlicePfadRelativ liefert dafuer "", nummeriert wie benannt).
// Gedeckt von TestHervorgegangenBautAnkerLinks.
//
// GRENZE, gemessen: ein Fliesstext-Token "slice-<x>", das keine Datei im
// Lifecycle referenziert (etwa ein Befehlsname wie "make slice-mv" statt
// einer echten Folge-Slice-Kennung), ist von einer echten benannten Kennung
// ohne (mehr) aufloesbare Datei nicht zu unterscheiden — beide erscheinen
// bar. Einen Existenz-Guard wie rewrite_outgoing_bare_in_file() in
// harness/tools/slice-mv.sh (dort geprueft gegen das $from-Verzeichnis der
// bewegten Datei) gibt es hier nicht. Gedeckt von
// TestHervorgegangenFliesstextTokenBleibtVonEchterKennungUnunterscheidbar.
func Hervorgegangen(root, inhalt, welleID string) string {
	zeilen := ausgangsZeilen(inhalt)
	if len(zeilen) == 0 {
		return leerwert
	}
	verbund := strings.Join(zeilen, "\n")
	var teile []string
	for _, id := range eindeutig(beoRE.FindAllString(verbund, -1)) {
		// Der Link wird aus der Kennung selbst gebaut, nicht aus einem festen
		// Pfad: `BEO-<KUERZEL>/<slug>` TRAEGT ihren Ort im Register bereits, der
		// Stub liegt zwei Ebenen unter docs/plan/planning/. Ob das Verzeichnis
		// existiert, prueft diese Funktion nicht — dieselbe Grenze wie bei der
		// Folge-Slice-Aufloesung: ein Existenz-Guard ist hier so wenig gebaut wie
		// dort (Funktionskopf, GRENZE).
		teile = append(teile, "[`"+id+"`](../../observations/"+id+"/observation.md)")
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

// sliceDateiMuster liefert die zwei Dateiform-Muster zu einer Kennung ohne
// "slice-"-Praefix, in Suchreihenfolge: die BENANNTE Form ist die Datei
// EXAKT — kein Titel-Suffix, `slice-<slug>.md`
// (docs/plan/planning/slice.template.md, MR-057 Setzung 1) —, die
// NUMMERIERTE verlangt einen Titel-Suffix hinter der Nummer,
// `slice-<nummer>-*.md`. Beide Formen leben im selben Lifecycle nebeneinander;
// eine Kennung ist immer nur unter einer der beiden Formen eine echte Datei.
func sliceDateiMuster(kennungTeil string) []string {
	return []string{
		"slice-" + kennungTeil + ".md",
		"slice-" + kennungTeil + "-*.md",
	}
}

// SlicePfadRelativ liefert den Pfad von docs/plan/planning/done/<wave-id>/ zu
// einer Slice-Datei, die noch irgendwo im Lifecycle liegt — nummeriert wie
// benannt (sliceDateiMuster). Gesucht wird in vier Lagen, in dieser
// Reihenfolge: im Ziel-Verzeichnis dieses Laufs · flach in done/ · in einem
// frueher archivierten Welle-Verzeichnis · in open/, next/ oder in-progress/.
// Leer, wenn keine da ist.
//
// KOPPLUNG: die zweite Lage liefert die AUFSTEIGENDE Form `../<datei>.md`. Sie ist
// der Grund, aus dem der Verweis-Nachzug eine dritte Ersetzungsrichtung fuehrt —
// zieht diese Datei bei einem SPAETEREN Lauf eine Ebene tiefer, muss das
// Welle-Segment dazwischen. Gedeckt von TestSlicePfadRelativLiefertDieAufsteigendeForm.
func SlicePfadRelativ(root, kennungTeil, welleID string) string {
	muster := sliceDateiMuster(kennungTeil)

	if b := ersterTrefferInDir(filepath.Join(root, filepath.FromSlash(doneDir), welleID), muster); b != "" {
		return b
	}
	if b := ersterTrefferInDir(filepath.Join(root, filepath.FromSlash(doneDir)), muster); b != "" {
		return "../" + b
	}
	for _, m := range muster {
		if t := ersteDatei(filepath.Join(root, filepath.FromSlash(doneDir), "*", m)); t != "" {
			return "../" + filepath.Base(filepath.Dir(t)) + "/" + filepath.Base(t)
		}
	}
	for _, d := range []string{"open", "next", "in-progress"} {
		if b := ersterTrefferInDir(filepath.Join(root, filepath.FromSlash(planningDir), d), muster); b != "" {
			return "../../" + d + "/" + b
		}
	}
	return ""
}

// ersterTrefferInDir probiert beide Dateiform-Muster aus sliceDateiMuster()
// in einem Verzeichnis, in ihrer Reihenfolge, und liefert den ersten Treffer.
func ersterTrefferInDir(dir string, muster []string) string {
	for _, m := range muster {
		if b := ersterTreffer(filepath.Join(dir, m)); b != "" {
			return b
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
