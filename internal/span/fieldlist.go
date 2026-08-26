package span

import (
	"fmt"
	"reflect"
	"sort"
	"strings"
)

// Field ist ein Feld der geschriebenen Zeile, so wie es auf dem Draht steht: sein
// json-Name und seine Pflichtigkeit. Es wird aus dem Span-Typ GELESEN, nicht danebengelegt
// — eine zweite Liste waere die Drift-Konstruktion, die ADR-0022 Festlegung 7 ausschliesst.
type Field struct {
	Name     string
	Required bool
}

// Note ist der Eintrag des AUSDRUCKS zu einem Feld: die Frage, die es beantwortet. Eine
// Frage kann kein Typ tragen, darum steht sie hier — und darum ist sie die Stelle, an der
// ein neu erfasstes Feld auffaellt: RenderFieldList bricht ab, wenn sie fehlt.
type Note struct {
	Field    string
	Question string
}

// SchemaFields liest die erfassten Felder aus dem Span-Typ: json-Name und Pflichtigkeit,
// in der Reihenfolge der Zeile. Pflicht ist ein Feld genau dann, wenn sein Tag KEIN
// `omitempty` traegt — dieselbe Unterscheidung, die die Zeile selbst trifft: ein
// Pflichtfeld steht auch leer da, ein optionales fehlt dann ganz.
//
// GELESEN WIRD, WAS AUF DEM DRAHT STEHT, nicht was einen Tag traegt. Ein exportiertes Feld
// OHNE json-Tag erscheint unter seinem Go-Namen in der Zeile; wer es hier ueberginge,
// liesse genau die Fehlhandlung durch, gegen die dieses Dokument steht — ein Feld, das
// erfasst wird und in keiner Liste auftaucht. Der Abgleich mit encoding/json selbst steht
// in TestSchemaFields_PflichtIstDieDrahtform.
//
// Der eingebettete AgentResult wird MITGELESEN, weil seine Werte flach in der Zeile
// erscheinen; ein Leser sieht dort keinen Unterschied, und die Feldliste darf keinen
// machen.
func SchemaFields() []Field {
	var out []Field
	var walk func(t reflect.Type)
	walk = func(t reflect.Type) {
		for i := range t.NumField() {
			f := t.Field(i)
			name, opts, _ := strings.Cut(f.Tag.Get("json"), ",")
			switch {
			case !f.IsExported():
				continue // steht nie in der Zeile
			case f.Anonymous && name == "" && f.Type.Kind() == reflect.Struct:
				walk(f.Type) // eingebettet ohne eigenen Namen -> flach in derselben Zeile
				continue
			case name == "-" && opts == "":
				continue // ausdruecklich ausgeschlossen
			case name == "":
				name = f.Name // ohne Tag traegt die Zeile den Go-Namen
			}
			out = append(out, Field{Name: name, Required: !strings.Contains(opts, "omitempty")})
		}
	}
	walk(reflect.TypeOf(Span{}))
	return out
}

// SchemaNotes liefert die Frage je Feld — die eine Stelle, an der eine Aussage UEBER die
// Erfassung von Hand gepflegt wird. Sie ist bewusst keine zweite Feldliste: WELCHE Felder
// es gibt, sagt SchemaFields; hier steht nur, wonach jedes gefragt wird. Ein Eintrag ohne
// Feld und ein Feld ohne Eintrag sind beide ein Abbruch in RenderFieldList, keine stille
// Luecke.
//
// Die Reihenfolge dieser Liste ist ohne Wirkung: gerendert wird in der Reihenfolge der
// Zeile.
func SchemaNotes() []Note {
	return []Note{
		{Field: "seq", Question: "Fehlt eine Zeile? — je Strom vergeben und steigend, damit eine Lücke sichtbar wird"},
		{Field: "ts", Question: "Wann geschah es?"},
		{Field: "event", Question: "Welches Ereignis löste die Zeile aus — Nachlauf oder Fehlschlag?"},
		{Field: "tool", Question: "Welches Werkzeug lief?"},
		{Field: "tool_use_id", Question: "Welche Ereignisse gehören zu einem Aufruf?"},
		{Field: "session", Question: "Welcher Lauf war es? — zusammen mit `agent` der Strom"},
		{Field: "agent", Question: "Welcher Agent innerhalb des Laufs? — zusammen mit `session` der Strom"},
		{Field: "agent_type", Question: "Welche Art Lauf? — der Typ des laufenden Agenten, roh übernommen"},
		{Field: "agent_role", Question: "Welche Rolle verursachte den Zugriff? — besetzt, wenn `agent_type` eine kanonische Rolle nennt"},
		{Field: "slice", Question: "Auf wessen Rechnung lief der Zugriff? — aus dem Lifecycle-Verzeichnis abgeleitet, Liste"},
		{Field: "requirement", Question: "Gegen welche Anforderung? — aus dem Bezug-Block der laufenden Slices, Liste"},
		{Field: "adr", Question: "Auf wessen Entscheidung? — aus demselben Bezug-Block, Liste"},
		{Field: "branch", Question: "Zu welchem Zweig gehört der Zugriff? — aus dem git-Zustand abgeleitet"},
		{Field: "commit", Question: "Zu welchem Stand gehört der Zugriff? — aus dem git-Zustand abgeleitet"},
		{Field: "status", Question: "Ging es gut?"},
		{Field: "permission_mode", Question: "Unter welcher Berechtigungs-Lage lief der Aufruf?"},
		{Field: "path", Question: "Was wurde gelesen oder geschrieben? — der Pfad, nie der Inhalt, und nur bei namentlich geführten Datei-Werkzeugen"},
		{Field: "bytes", Question: "Wie groß ist die geschriebene Datei? — aus dem Dateisystem, nie aus der Payload"},
		{Field: "sha256_16", Question: "Hat sich der Inhalt geändert? — ein Fingerabdruck-Präfix aus dem Dateisystem, nie der Inhalt selbst"},
		{Field: "program", Question: "Welches Programm lief? — das erste Token der Kommandozeile, nie die Zeile"},
		{Field: "argc", Question: "Wie viele Argumente hatte es? — die Anzahl, nie die Argumente"},
		{Field: "duration_ms", Question: "Wie lange dauerte der Aufruf, wie der Hook ihn sieht?"},
		{Field: "result_bytes", Question: "Wie groß war das Ergebnis? — die Länge, nie der Inhalt"},
		{Field: "spawned_role", Question: "Welche Rolle lief im Subagenten? — aus dem Ergebnis, gegen die kanonischen Namen normalisiert"},
		{Field: "input_tokens", Question: "Wie viele Eingabe-Token verbrauchte der Subagenten-Lauf?"},
		{Field: "output_tokens", Question: "Wie viele Ausgabe-Token verbrauchte er?"},
		{Field: "cache_creation_input_tokens", Question: "Zahlte der Lauf den Cache?"},
		{Field: "cache_read_input_tokens", Question: "Nutzte der Lauf den Cache?"},
		{Field: "total_tokens", Question: "Wie groß war der Subagenten-Lauf insgesamt? — die Summe, die das Werkzeug selbst ausweist"},
		{Field: "total_duration_ms", Question: "Wie lange lief der Subagent selbst? — nicht `duration_ms`, das den Aufruf misst"},
		{Field: "total_tool_use_count", Question: "Wie viele Werkzeug-Aufrufe verursachte der Subagent?"},
		{Field: "model_version", Question: "Welches Modell verursachte die Kosten? — strukturell begrenzt; was die Gestalt eines Bezeichners nicht hat, wird verworfen"},
	}
}

// limitAgentGuard, limitCounters und limitStore sind die drei STEHENDEN Grenz-Saetze des
// Dokuments. Sie gelten auch dann, wenn niemand eine Auswertung ruft — deshalb stehen sie
// im Dokument und nicht nur in deren Ausgabe (ADR-0022 Festlegung 7 fuer die ersten zwei,
// Festlegung 6 Stueck 3 fuer den dritten).
//
// EINZELN und nicht als ein Block: jeder Satz ist eine eigene Zusage mit eigener Richtung,
// und die drei Waechter in internal/emit/fieldlist_test.go treffen je einen. Ein Block
// haette einen Zahn fuer drei Aussagen.
const limitAgentGuard = "**Über die Aufrufform des Agenten-Werkzeugs führt diese Ebene keinen Wächter.**\n" +
	"Das Feld `agent_role` besetzt sich genau dann, wenn der Agenten-Typ eine der sechs kanonischen\n" +
	"Rollen nennt — `planner`, `architect`, `implementer`, `reviewer`, `verifier`, `validator`. Wer\n" +
	"seine Typen umbenennt, bekommt ein leeres Feld, und **leer heißt unbekannt, nie rollenlos**.\n" +
	"Kein Gate und kein Hook erzwingt, dass Rollen-Arbeit unter ihrem Rollen-Typ läuft; die\n" +
	"Rollen-Achse ruht hier auf Disziplin.\n"

const limitCounters = "**Die Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht.**\n" +
	"Die Token- und Cache-Zähler erreichen eine Zeile nur, wenn das Werkzeug sie im Ergebnis eines\n" +
	"Subagenten-Aufrufs mitliefert; ein im Hintergrund gestarteter Lauf liefert sie nicht. **Kein\n" +
	"Lauf dieses Repos führt sie herbei** — das ist keine Eigenschaft dieses Aufbaus, sondern der\n" +
	"Mechanik. Ein Bestand ohne Zähler ist deshalb der Normalfall und kein Defekt.\n"

const limitStore = "**Über den Bestand ist nichts zugesagt.** Er ist **gitignored**, aber **nicht\n" +
	"verschlüsselt** und **nicht zugriffsbeschränkt**: wer dieses Arbeitsverzeichnis lesen kann,\n" +
	"liest ihn. Und **Pfadnamen sind nicht als unkritisch zugesagt** — sie stehen als `path` in der\n" +
	"Zeile, und ein Pfad kann selbst die Aussage sein, die niemand teilen wollte. Wer den Bestand\n" +
	"weitergibt, gibt beides weiter.\n"

// limits liefert die drei Grenz-Saetze in ihrer Reihenfolge im Dokument.
func limits() []string { return []string{limitAgentGuard, limitCounters, limitStore} }

// fieldListHead ist der Kopf des Dokuments: was es ist, woher es kommt, und was das
// geschlossene Schema bedeutet. Er nennt KEIN `make`-Ziel und traegt KEINEN Markdown-Link
// — das Dokument liegt im geprueften Doku-Bereich des Ziels, und ein toter Verweis darin
// faerbte dessen Doku-Gate rot, ohne dass der Adopter ihn heilen koennte: die Datei ist
// konvergent, ein Re-Lauf setzt sie zurueck.
const fieldListHead = "# Erfassungsschicht — die Feldliste und ihre Grenzen\n" +
	"\n" +
	"Dieses Dokument ist **werkzeug-erzeugt**: es ist der Ausdruck der Erfassungsschicht über ihr\n" +
	"eigenes Schema. Ein Feld, das erfasst wird, steht in der Tabelle; einen Eintrag der Tabelle\n" +
	"ohne erfasstes Feld gibt es nicht. Beide entstehen aus derselben Quelle — deshalb kann die\n" +
	"Liste nicht gegen die Erfassung driften.\n" +
	"\n" +
	"**Ein erneuter Lauf des Werkzeugs schreibt diese Datei kanonisch neu.** Änderungen von Hand\n" +
	"gehen dabei verloren; sie gehören in ein eigenes Dokument daneben.\n" +
	"\n" +
	"## Was erfasst wird\n" +
	"\n" +
	"Je Werkzeug-Aufruf eines Agenten-Laufs entsteht **eine** Zeile JSON in einem gitignorierten\n" +
	"Zustands-Bereich unterhalb von `.harness/`, ein Strom je Paar aus Sitzung und Agent.\n" +
	"\n" +
	"**Das Schema ist geschlossen.** Erfasst wird ausschließlich, was die Tabelle unten führt; ein\n" +
	"Feld einer künftigen Werkzeug-Fassung wird nicht still mitgeschrieben. Von Argument-Werten\n" +
	"wandert **nie der Inhalt**, sondern eine Ableitung: der Pfad, die Größe, ein\n" +
	"Fingerabdruck-Präfix, das Programm-Token, die Anzahl der Argumente. Ein Werkzeug, das die\n" +
	"Erfassung nicht namentlich führt, gibt **nur seinen Namen und seinen Status** preis.\n" +
	"\n" +
	"**Die Liste gilt auch dann, wenn gerade nichts erfasst wird.** Die Erfassung läuft über ein\n" +
	"Programm, das gitignored liegt: ein frischer Klon dieses Repos hat es nicht, dieses Dokument\n" +
	"schon. Dann sagt die Tabelle, was erfasst **würde**, sobald ein erneuter Lauf des Werkzeugs\n" +
	"das Programm wieder ablegt.\n" +
	"\n" +
	"## Feldliste\n" +
	"\n" +
	"**Pflicht** heißt: das Feld steht in jeder Zeile, auch leer — leer ist dort eine Aussage und\n" +
	"kein fehlender Wert. **Optional** heißt: das Feld fehlt, wo es nichts zu sagen gibt.\n" +
	"\n" +
	"| Feld | Pflicht | Wonach gefragt wird |\n" +
	"|---|---|---|\n"

// fieldListLimitsHead leitet den zweiten Gegenstand des Dokuments ein. Er ist kein Anhang
// der Tabelle: die Nicht-Zusage ist die Kehrseite genau dieser Liste — wer liest, WAS
// erfasst wird, liest hier, wie wenig darueber zugesagt ist.
const fieldListLimitsHead = "\n" +
	"## Grenzen, die kein Sensor hält\n" +
	"\n" +
	"Sie gelten auch dann, wenn niemand eine Auswertung ruft — deshalb stehen sie hier und nicht\n" +
	"nur in deren Ausgabe.\n" +
	"\n"

// RenderFieldList baut das Dokument aus den erfassten Feldern und ihren Fragen — und
// BRICHT AB, sobald die zwei auseinanderfallen. Genau das ist der konstruktive Ausschluss
// der Drift: ein Feld ohne Frage und eine Frage ohne Feld sind keine Schoenheitsfehler,
// sondern der Grund, aus dem es dieses Dokument gibt.
//
// Die zwei Richtungen tragen zwei Meldungen, weil sie zwei verschiedene Fehlhandlungen
// benennen: die erste, dass jemand ein Feld erfasst und den Ausdruck nicht nachgezogen
// hat; die zweite, dass der Ausdruck eine Erfassung behauptet, die es nicht gibt.
//
// Exportiert fuer die zwei Waechter, die genau diese Abbrueche messen —
// TestRenderFieldList_FeldOhneEintragBrichtAb und TestRenderFieldList_EintragOhneFeldBrichtAb.
func RenderFieldList(fields []Field, notes []Note) (string, error) {
	offen := make(map[string]string, len(notes))
	for _, n := range notes {
		if _, doppelt := offen[n.Field]; doppelt {
			return "", fmt.Errorf("das Feld %q hat zwei Eintraege im Ausdruck des Schemas — die Feldliste traegt je Feld eine Zeile", n.Field)
		}
		offen[n.Field] = n.Question
	}
	var b strings.Builder
	b.WriteString(fieldListHead)
	for _, f := range fields {
		frage, beschrieben := offen[f.Name]
		if !beschrieben {
			return "", fmt.Errorf("das Feld %q wird erfasst, aber der Ausdruck des Schemas beschreibt es nicht — ein erfasstes Feld gehoert in die Feldliste, sonst erfasst das Ziel mehr, als es lesbar sagt", f.Name)
		}
		delete(offen, f.Name)
		pflicht := "Optional"
		if f.Required {
			pflicht = "Pflicht"
		}
		b.WriteString("| `" + f.Name + "` | " + pflicht + " | " + frage + " |\n")
	}
	if len(offen) > 0 {
		uebrig := make([]string, 0, len(offen))
		for name := range offen {
			uebrig = append(uebrig, name)
		}
		sort.Strings(uebrig)
		return "", fmt.Errorf("der Ausdruck des Schemas beschreibt %s, aber der Traeger erfasst das nicht — die Feldliste ist der Ausdruck der Erfassung, keine zweite Liste daneben",
			strings.Join(uebrig, ", "))
	}
	// Ein Leerzeile zwischen den Saetzen, KEINE dahinter: jeder Satz endet auf einen
	// Zeilenumbruch, der Trenner setzt den zweiten. Faellt einer weg, bleibt die Datei
	// wohlgeformt — der Waechter ueber ihm faellt, nicht das Markdown.
	b.WriteString(fieldListLimitsHead)
	b.WriteString(strings.Join(limits(), "\n"))
	return b.String(), nil
}

// FieldList ist der AUSDRUCK DES TRAEGERS ueber sein eigenes Schema: das Dokument, das der
// Bootstrap unveraendert ins Zielrepo legt (ADR-0022 Festlegung 7). Es entsteht aus der
// Erfassung selbst, nicht aus einer gepflegten Kopie daneben.
func FieldList() (string, error) {
	return RenderFieldList(SchemaFields(), SchemaNotes())
}
