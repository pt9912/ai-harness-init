package span_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// namenVon zieht die Feld-Namen aus einer Feld-Liste — als Menge, damit die Waechter
// unten ueber MENGEN reden statt ueber Reihenfolgen.
func namenVon(fields []span.Field) map[string]bool {
	out := make(map[string]bool, len(fields))
	for _, f := range fields {
		out[f.Name] = true
	}
	return out
}

// sortiert liefert die Schluessel einer Menge sortiert — fuer Fehlermeldungen, die man
// zweimal gleich liest.
func sortiert(m map[string]bool) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

// TestSchemaDoc_JedesErfassteFeldStehtImAusdruck haelt die eine Haelfte der Zusage aus
// ADR-0022 Festlegung 7: ein Feld, das erfasst wird, steht in der Feldliste. Gemessen wird
// gegen den REFLEKTIERTEN Span-Typ, nicht gegen das gerenderte Dokument — sonst leitete
// der Test seine Erwartung aus derselben Funktion ab, die er prueft.
//
// Rot faerbt ihn test/mutations/165-feldliste-feld-ohne-eintrag.sh (ein Pflichtfeld kommt
// zur Zeile, der Ausdruck wird nicht nachgezogen).
func TestSchemaDoc_JedesErfassteFeldStehtImAusdruck(t *testing.T) {
	beschrieben := map[string]bool{}
	for _, n := range span.SchemaNotes() {
		beschrieben[n.Field] = true
	}
	fehlend := map[string]bool{}
	for _, f := range span.SchemaFields() {
		if !beschrieben[f.Name] {
			fehlend[f.Name] = true
		}
	}
	if len(fehlend) > 0 {
		t.Errorf("erfasst, aber im Ausdruck des Schemas nicht beschrieben: %v — das Ziel erfasst dann mehr, als seine Feldliste sagt", sortiert(fehlend))
	}
}

// TestSchemaDoc_KeinEintragOhneErfasstesFeld haelt die ANDERE Haelfte derselben Zusage:
// ein Eintrag, den der Traeger nicht erfasst, gehoert nicht in die Liste. Eine Feldliste,
// die mehr nennt als erfasst wird, beruhigt falsch — sie behauptet eine Erfassung, die es
// nicht gibt, und der naechste Leser sucht nach Zeilen, die nie entstehen.
//
// Rot faerbt ihn test/mutations/166-feldliste-eintrag-ohne-feld.sh.
func TestSchemaDoc_KeinEintragOhneErfasstesFeld(t *testing.T) {
	erfasst := namenVon(span.SchemaFields())
	ueberzaehlig := map[string]bool{}
	for _, n := range span.SchemaNotes() {
		if !erfasst[n.Field] {
			ueberzaehlig[n.Field] = true
		}
	}
	if len(ueberzaehlig) > 0 {
		t.Errorf("im Ausdruck des Schemas beschrieben, aber nicht erfasst: %v — die Feldliste behauptet dann eine Erfassung, die es nicht gibt", sortiert(ueberzaehlig))
	}
}

// TestSchemaFields_PflichtIstDieDrahtform prueft die zweite Spalte gegen die EINZIGE
// Instanz, die sie wirklich entscheidet: encoding/json. Ein Pflichtfeld steht in der Zeile
// eines LEEREN Span, ein optionales fehlt dort — genau das sagt die Spalte zu, und genau
// das misst dieser Waechter, ohne die Herleitung aus SchemaFields zu wiederholen.
func TestSchemaFields_PflichtIstDieDrahtform(t *testing.T) {
	rohzeile, err := json.Marshal(span.Span{})
	if err != nil {
		t.Fatalf("leeren Span serialisieren: %v", err)
	}
	var zeile map[string]json.RawMessage
	if unmarshalErr := json.Unmarshal(rohzeile, &zeile); unmarshalErr != nil {
		t.Fatalf("leere Zeile lesen: %v", unmarshalErr)
	}
	if len(zeile) == 0 {
		t.Fatalf("die leere Zeile traegt kein Feld — der Waechter misst nichts")
	}
	gelesen := namenVon(span.SchemaFields())
	for _, f := range span.SchemaFields() {
		_, inDerLeerenZeile := zeile[f.Name]
		if f.Required && !inDerLeerenZeile {
			t.Errorf("`%s` gilt als Pflicht, fehlt aber in der Zeile eines leeren Span — die Feldliste verspricht ein Feld, das ein Auswerter nicht findet", f.Name)
		}
		if !f.Required && inDerLeerenZeile {
			t.Errorf("`%s` gilt als Optional, steht aber in der Zeile eines leeren Span — die Feldliste sagt „fehlt, wo es nichts zu sagen gibt“, und das trifft dann nicht zu", f.Name)
		}
	}
	// Die Gegenrichtung, und sie ist die schaerfere: jeder Schluessel, den die leere Zeile
	// FUEHRT, muss gelesen worden sein. Ein exportiertes Feld ohne json-Tag steht unter
	// seinem Go-Namen auf dem Draht — es zu uebersehen hiesse, ein erfasstes Feld an der
	// Feldliste vorbeizuschmuggeln, und zwar unterhalb jedes Waechters, der nur die
	// gelesene Menge mit sich selbst vergleicht.
	for name := range zeile {
		if !gelesen[name] {
			t.Errorf("die Zeile eines leeren Span traegt `%s`, das SchemaFields nicht liest — dieses Feld erreicht keine Feldliste", name)
		}
	}
}

// TestFieldList_TabelleTraegtJedesErfassteFeldEinmal misst das GERENDERTE Dokument gegen
// den reflektierten Typ: je erfasstem Feld genau eine Tabellenzeile, mit der Pflichtigkeit,
// die der Draht traegt. Er faengt, was die zwei Mengen-Waechter oben nicht sehen — einen
// Renderer, der Zeilen ueberspringt, doppelt oder die Spalte verwechselt.
func TestFieldList_TabelleTraegtJedesErfassteFeldEinmal(t *testing.T) {
	doc, err := span.FieldList()
	if err != nil {
		t.Fatalf("FieldList: %v", err)
	}
	zeile := regexp.MustCompile("(?m)^\\| `([a-z0-9_]+)` \\| (Pflicht|Optional) \\|")
	gefunden := map[string]string{}
	for _, m := range zeile.FindAllStringSubmatch(doc, -1) {
		if vorher, doppelt := gefunden[m[1]]; doppelt {
			t.Errorf("`%s` steht zweimal in der Tabelle (%s und %s)", m[1], vorher, m[2])
		}
		gefunden[m[1]] = m[2]
	}
	for _, f := range span.SchemaFields() {
		want := "Optional"
		if f.Required {
			want = "Pflicht"
		}
		switch got, da := gefunden[f.Name]; {
		case !da:
			t.Errorf("`%s` wird erfasst, hat aber keine Zeile in der Tabelle", f.Name)
		case got != want:
			t.Errorf("`%s` steht als %s in der Tabelle, ist auf dem Draht aber %s", f.Name, got, want)
		}
		delete(gefunden, f.Name)
	}
	for name := range gefunden {
		t.Errorf("die Tabelle traegt eine Zeile fuer `%s`, das nicht erfasst wird", name)
	}
}

// TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr haelt DoD (2) aus
// slice-109-feldliste-jede-aussage-hat-ihre-quelle: die program-Notiz behauptete "das erste
// Token der Kommandozeile, nie die Zeile" — seit slice-204-das-programm-feld-nennt-das-programm
// nachweislich falsch (`cd /x && make gates` liefert `program="make"`, nicht das erste Token
// der ganzen Zeile; die geltende Regel steht in spec/spezifikation.md, Zeile SPEC-021: das
// erste Wort des AUSGEFUEHRTEN SEGMENTS, nie der ganzen Kommandozeile). Der Waechter sucht die
// widerlegte Formulierung im program-Note-Text und faellt, solange sie dort steht.
//
// Rot faerbt ihn test/mutations/488-feldliste-program-notiz-widerlegt.sh (setzt den Note-Text
// auf den alten, widerlegten Wortlaut zurueck).
//
// Die geltende Notiz sagt ZWEI Grenzen in einem Satz zu — "das erste Wort des
// ausgefuehrten Segments" (positive Haelfte) UND "nie das der ganzen Kommandozeile"
// (Verneinungs-Haelfte). Die Pruefung oben bindet nur den vollstaendigen Ruecksprung
// auf den alten Wortlaut; die zwei Assertions darunter binden jede Haelfte EINZELN
// (Reviewer-Skill "Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je
// Teil", seit slice-109-feldliste-jede-aussage-hat-ihre-quelle). Rot faerben sie
// test/mutations/489-feldliste-program-notiz-verneinung-verliert.sh (Verneinungs-Haelfte
// entfernt, positive Haelfte bleibt stehen) bzw.
// test/mutations/490-feldliste-program-notiz-positive-haelfte-falsch.sh (positive
// Haelfte verfaelscht, Verneinungs-Haelfte bleibt stehen).
func TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr(t *testing.T) {
	var frage string
	var gefunden bool
	for _, n := range span.SchemaNotes() {
		if n.Field == "program" {
			frage = n.Question
			gefunden = true
		}
	}
	if !gefunden {
		t.Fatalf("SchemaNotes traegt keinen Eintrag fuer das Feld program")
	}
	if strings.Contains(frage, "das erste Token der Kommandozeile") {
		t.Errorf("die program-Notiz behauptet noch die von slice-204-das-programm-feld-nennt-das-programm widerlegte Regel: %q", frage)
	}
	if !strings.Contains(frage, "erste Wort des ausgeführten Segments") {
		t.Errorf("die program-Notiz nennt nicht mehr die positive Haelfte (erstes Wort des AUSGEFUEHRTEN Segments): %q", frage)
	}
	if !strings.Contains(frage, "nie das der ganzen Kommandozeile") {
		t.Errorf("die program-Notiz nennt nicht mehr die Verneinungs-Haelfte (nie das der GANZEN Kommandozeile): %q", frage)
	}
}

// TestRenderFieldList_FeldOhneEintragBrichtAb misst den Abbruch selbst — die Mechanik, auf
// der der konstruktive Ausschluss der Drift ruht. Sie wird hier mit SYNTHETISCHEN Eingaben
// gefahren: der echte Schema-Stand ist heilig, und ein Waechter, der ihn braeuchte, koennte
// die Bruchstelle nie sehen.
func TestRenderFieldList_FeldOhneEintragBrichtAb(t *testing.T) {
	fields := []span.Field{{Name: "seq", Required: true}, {Name: "geheim", Required: true}}
	notes := []span.Note{{Field: "seq", Question: "Fehlt eine Zeile?"}}
	doc, err := span.RenderFieldList(fields, notes)
	if err == nil {
		t.Fatalf("ein erfasstes Feld ohne Eintrag ergab ein Dokument statt eines Abbruchs:\n%s", doc)
	}
	if !strings.Contains(err.Error(), "geheim") {
		t.Errorf("der Abbruch nennt das unbeschriebene Feld nicht: %v", err)
	}
}

// TestRenderFieldList_EintragOhneFeldBrichtAb misst die Gegenrichtung: ein Eintrag ohne
// erfasstes Feld ist derselbe Abbruch, nur mit anderer Meldung. Ohne ihn koennte die
// Feldliste mehr behaupten, als der Traeger schreibt.
func TestRenderFieldList_EintragOhneFeldBrichtAb(t *testing.T) {
	fields := []span.Field{{Name: "seq", Required: true}}
	notes := []span.Note{
		{Field: "seq", Question: "Fehlt eine Zeile?"},
		{Field: "prompt", Question: "Was stand im Auftrag?"},
	}
	doc, err := span.RenderFieldList(fields, notes)
	if err == nil {
		t.Fatalf("ein Eintrag ohne erfasstes Feld ergab ein Dokument statt eines Abbruchs:\n%s", doc)
	}
	if !strings.Contains(err.Error(), "prompt") {
		t.Errorf("der Abbruch nennt den ueberzaehligen Eintrag nicht: %v", err)
	}
}

// TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation haelt den Satz der
// Feldliste ueber die Kennzeichnung *nicht bekannt* auf der abschliessenden Fall-Menge von
// SPEC-087 (spec/spezifikation.md §5): genau diese Felder, keines mehr und keines weniger,
// jedes davon ein Pflichtfeld des Traegers. Eine Zusage an ALLE Pflichtfelder waere falsch —
// im Haupt-Kontext stehen `agent`, `agent_type`, `tool_use_id` und `event` als `""`.
//
// Rot faerbt ihn test/mutations/603-feldliste-kennzeichnung-an-alle-pflichtfelder.sh (der
// Satz sagt die Kennzeichnung wieder jedem Pflichtfeld ohne Quellwert zu).
func TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation(t *testing.T) {
	doc, err := span.FieldList()
	if err != nil {
		t.Fatalf("FieldList: %v", err)
	}
	const einleitung = "Die Kennzeichnung *nicht bekannt* tragen abschließend diese Felder:"
	i := strings.Index(doc, einleitung)
	if i < 0 {
		t.Fatalf("die Feldliste nennt die Felder mit Kennzeichnung nicht abschliessend (Satz %q fehlt)", einleitung)
	}
	rest := doc[i+len(einleitung):]
	ende := strings.Index(rest, ". ")
	if ende < 0 {
		t.Fatalf("der Satz %q endet nicht", einleitung)
	}
	genannt := map[string]bool{}
	for _, m := range regexp.MustCompile("`([a-z_]+)`").FindAllStringSubmatch(rest[:ende], -1) {
		genannt[m[1]] = true
	}
	erwartet := map[string]bool{
		"cache_creation_input_tokens": true, "cache_read_input_tokens": true, "agent_role": true,
		"branch": true, "commit": true, "slice": true, "requirement": true, "adr": true,
	}
	if strings.Join(sortiert(genannt), ",") != strings.Join(sortiert(erwartet), ",") {
		t.Errorf("die Feldliste nennt als Felder mit Kennzeichnung %v, SPEC-087 nennt %v", sortiert(genannt), sortiert(erwartet))
	}
	pflicht := map[string]bool{}
	for _, f := range span.SchemaFields() {
		pflicht[f.Name] = f.Required
	}
	for name := range genannt {
		if !pflicht[name] {
			t.Errorf("die Feldliste nennt %q als Feld mit Kennzeichnung, der Traeger fuehrt es nicht als Pflichtfeld", name)
		}
	}
	if strings.Contains(doc, "Ein Pflichtfeld, dessen Wert die Quelle nicht liefert") {
		t.Errorf("die Feldliste sagt die Kennzeichnung jedem Pflichtfeld ohne Quellwert zu; SPEC-087 begrenzt die Faelle abschliessend")
	}
}

// flacheFeldliste liefert die Feldliste mit zusammengezogenem Leerraum: WO das Dokument
// umbricht, ist gleichgueltig, WAS es sagt, nicht.
func flacheFeldliste(t *testing.T) string {
	t.Helper()
	doc, err := span.FieldList()
	if err != nil {
		t.Fatalf("FieldList: %v", err)
	}
	return strings.Join(strings.Fields(doc), " ")
}

// specZeile liefert die Tabellenzeile der Spezifikation (spec/spezifikation.md §5) mit der
// Kennung id, Leerraum zusammengezogen. Sie ist die Quelle, die ein Satz der Feldliste
// wiedergibt; fehlt sie, faellt der Test, statt einen Satz ohne Quelle stehen zu lassen.
func specZeile(t *testing.T, id string) string {
	t.Helper()
	roh, err := os.ReadFile(filepath.Join("..", "..", "spec", "spezifikation.md"))
	if err != nil {
		t.Fatalf("Spezifikation lesen: %v", err)
	}
	for _, zeile := range strings.Split(string(roh), "\n") {
		if strings.HasPrefix(zeile, "| `"+id+"` |") {
			return strings.Join(strings.Fields(zeile), " ")
		}
	}
	t.Fatalf("die Spezifikation fuehrt keine Zeile %s — die Feldliste nennt sie als Quelle", id)
	return ""
}

// quelleGenannt prueft, dass die Feldliste die Spec-Zeile id als ihre Quelle nennt — bei
// ihrem Gegenstand, der zweiten Zelle der Zeile, in „…" gesetzt. Gelesen wird die Zelle aus
// der Spezifikation, nicht abgeschrieben: benennt die Spezifikation den Gegenstand um,
// faellt der Test, und die Quellen-Angabe zeigt nie auf eine Zeile, die so nicht mehr heisst.
func quelleGenannt(t *testing.T, id string) {
	t.Helper()
	zellen := strings.Split(specZeile(t, id), " | ")
	if len(zellen) < 3 {
		t.Fatalf("die Spec-Zeile %s hat keine Gegenstands-Zelle: %q", id, zellen)
	}
	doc := flacheFeldliste(t)
	gegenstand := "„" + zellen[1] + "\""
	stehtJeweils(t, "die Feldliste (Quelle "+id+")", doc, gegenstand)
	vor, _, ok := strings.Cut(doc, gegenstand)
	if !ok {
		return
	}
	const quelle = "Quelle: Spezifikation von ai-harness-init, §"
	i := strings.LastIndex(vor, quelle)
	if i < 0 {
		t.Fatalf("die Feldliste nennt %s ohne vorangehendes %q", id, quelle)
	}
	genannt, _, _ := strings.Cut(vor[i+len(quelle):], ",")
	if soll := specAbschnitt(t, id); genannt != soll {
		t.Errorf("die Feldliste nennt %s unter §%s, die Spezifikation fuehrt die Zeile unter §%s", id, genannt, soll)
	}
}

// specAbschnitt liefert die Nummer des `## <N>.`-Abschnitts der Spezifikation, unter dem die
// Zeile id steht — gelesen aus der Ueberschrift, damit die Quellen-Angabe der Feldliste einer
// Umnummerierung der Spezifikation nicht still hinterherhinkt.
func specAbschnitt(t *testing.T, id string) string {
	t.Helper()
	roh, err := os.ReadFile(filepath.Join("..", "..", "spec", "spezifikation.md"))
	if err != nil {
		t.Fatalf("Spezifikation lesen: %v", err)
	}
	abschnitt := ""
	for _, zeile := range strings.Split(string(roh), "\n") {
		if rest, ok := strings.CutPrefix(zeile, "## "); ok {
			nr, _, _ := strings.Cut(rest, ". ")
			abschnitt = nr
		}
		if strings.HasPrefix(zeile, "| `"+id+"` |") {
			return abschnitt
		}
	}
	t.Fatalf("die Spezifikation fuehrt keine Zeile %s", id)
	return ""
}

// mrTitel liefert den Titel des Adaptions-Eintrags id aus seiner Datei unter
// harness/conventions/ — die Ueberschrift nach dem Gedankenstrich. Die Feldliste nennt den
// Eintrag beim Titel, weil im Ziel keine Kennung dieses Werkzeugs aufloest.
func mrTitel(t *testing.T, id string) string {
	t.Helper()
	treffer, err := filepath.Glob(filepath.Join("..", "..", "harness", "conventions", id+"-*.md"))
	if err != nil || len(treffer) != 1 {
		t.Fatalf("Adaptions-Eintrag %s nicht eindeutig gefunden: %v %v", id, treffer, err)
	}
	roh, err := os.ReadFile(treffer[0])
	if err != nil {
		t.Fatalf("Adaptions-Eintrag lesen: %v", err)
	}
	kopf, _, _ := strings.Cut(string(roh), "\n")
	_, titel, ok := strings.Cut(kopf, " — ")
	if !ok {
		t.Fatalf("die Ueberschrift von %s traegt keinen Titel nach ' — ': %q", id, kopf)
	}
	return titel
}

// stehtJeweils prueft, dass text jede der Wendungen traegt, und nennt im Rot die fehlende
// samt dem Ort, an dem sie fehlt.
func stehtJeweils(t *testing.T, ort, text string, wendungen ...string) {
	t.Helper()
	for _, w := range wendungen {
		if !strings.Contains(text, w) {
			t.Errorf("%s traegt die Wendung %q nicht", ort, w)
		}
	}
}

// TestFeldliste_CacheStatusNurAusSubagentImVordergrund haelt den Satz der Feldliste, dass
// den Cache-Status nur ein Subagenten-Aufruf im Vordergrund liefert und jeder andere Span
// die Kennzeichnung traegt — gekoppelt an die Zeilen SPEC-055 und SPEC-087 der
// Spezifikation, die ihn tragen.
//
// Rot faerbt ihn test/mutations/604-feldliste-cache-status-satz-gestrichen.sh (der Satz
// faellt aus dem Dokument).
func TestFeldliste_CacheStatusNurAusSubagentImVordergrund(t *testing.T) {
	stehtJeweils(t, "die Feldliste", flacheFeldliste(t),
		"**Den Cache-Status liefert nur ein Subagenten-Aufruf im Vordergrund.**",
		"Jeder andere Span und ein Aufruf, dessen Ergebnis keine Zähler führt, trägt in beiden Feldern `nicht bekannt: tool_response.usage`",
		"Der Cache des Haupt-Kontexts selbst steht in keinem Span.",
	)
	quelleGenannt(t, "SPEC-055")
	quelleGenannt(t, "SPEC-087")
	stehtJeweils(t, "die Spezifikation, Zeile SPEC-055", specZeile(t, "SPEC-055"),
		"`tool_response` eines Vordergrund-`Agent`-Aufrufs",
		"Jeder andere Span und ein `Agent`-Aufruf ohne `usage` tragen die Kennzeichnung",
	)
	stehtJeweils(t, "die Spezifikation, Zeile SPEC-087", specZeile(t, "SPEC-087"),
		"die zwei Cache-Zähler (`SPEC-024`, Quelle `tool_response.usage`",
	)
}

// TestFeldliste_PRNummerBewusstNichtImSchema haelt den Satz, dass eine PR-Nummer bewusst
// nicht im Schema steht und `branch`/`commit` an ihrer Stelle — gekoppelt an die Zeile
// SPEC-056 der Spezifikation.
//
// Rot faerbt ihn test/mutations/605-feldliste-pr-satz-gestrichen.sh.
func TestFeldliste_PRNummerBewusstNichtImSchema(t *testing.T) {
	stehtJeweils(t, "die Feldliste", flacheFeldliste(t),
		"**Eine PR-Nummer steht bewusst nicht im Schema.**",
		"ohne Netz und ohne `gh`",
		"An ihrer Stelle stehen `branch` und `commit`, abgeleitet aus `.git/HEAD`",
		"Adaptions-Eintrag „"+mrTitel(t, "MR-077")+"\" von ai-harness-init.",
	)
	quelleGenannt(t, "SPEC-056")
	stehtJeweils(t, "die Spezifikation, Zeile SPEC-056", specZeile(t, "SPEC-056"),
		"Der Span führt keine PR-Angabe.",
		"An ihrer Stelle erfasst er `branch` und `commit`",
		"abgeleitet aus `.git/HEAD`; der Emitter geht nicht ins Netz und ruft kein `gh`",
	)
}

// TestFeldliste_HauptKontextTraegtKeineZahl haelt den Satz, dass der Haupt-Kontext keine
// Zahl traegt und jede Token-Bilanz eine ueber Subagenten-Laeufe ist — gekoppelt an die
// Zeile SPEC-049 der Spezifikation.
//
// Rot faerbt ihn test/mutations/606-feldliste-haupt-kontext-satz-gestrichen.sh.
func TestFeldliste_HauptKontextTraegtKeineZahl(t *testing.T) {
	stehtJeweils(t, "die Feldliste", flacheFeldliste(t),
		"**Der Haupt-Kontext trägt keine Zahl.**",
		"`result_bytes` und `duration_ms` sind Größen eines Aufrufs, keine Token",
		"ihr Nenner ist nicht der Verbrauch des Laufs",
	)
	quelleGenannt(t, "SPEC-049")
	stehtJeweils(t, "die Spezifikation, Zeile SPEC-049", specZeile(t, "SPEC-049"),
		"Haupt-Kontext ohne Zahl",
		"den Haupt-Kontext umschließt kein `Agent`-Aufruf",
		"`result_bytes` und `duration_ms` sind Größen **eines** Aufrufs, keine Token",
		"ihr Nenner ist nicht der Verbrauch des Laufs",
	)
}

// TestFeldliste_BestandNurAusdruecklichGeraeumt haelt den Satz, dass der Bestand nie
// nebenbei geraeumt wird und `make span-clean` ihn ausdruecklich entfernt — gekoppelt an
// die Zeile SPEC-057 der Spezifikation.
//
// Rot faerbt ihn test/mutations/607-feldliste-aufbewahrungs-satz-gestrichen.sh.
func TestFeldliste_BestandNurAusdruecklichGeraeumt(t *testing.T) {
	stehtJeweils(t, "die Feldliste", flacheFeldliste(t),
		"**Der Bestand wird nie nebenbei geräumt.**",
		"Die Erfassung hängt ausschließlich an",
		"Aufgeräumt wird ausdrücklich mit `make span-clean`",
	)
	quelleGenannt(t, "SPEC-057")
	stehtJeweils(t, "die Spezifikation, Zeile SPEC-057", specZeile(t, "SPEC-057"),
		"Altbestände werden beim ersten Span einer Sitzung **nicht** entfernt",
		"der Emitter hängt ausschließlich an",
		"Aufgeräumt wird ausdrücklich mit `make span-clean`",
	)
}
