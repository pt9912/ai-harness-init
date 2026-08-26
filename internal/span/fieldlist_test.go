package span_test

import (
	"encoding/json"
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
