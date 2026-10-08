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
		{Field: "agent_role", Question: "Welche Rolle verursachte den Zugriff? — besetzt, wenn `agent_type` eine kanonische Rolle nennt, sonst `" + NotKnown(SourceAgentType) + "`"},
		{Field: "slice", Question: "Auf wessen Rechnung lief der Zugriff? — aus dem Lifecycle-Verzeichnis abgeleitet, Liste; `[]` heißt kein Slice, ein unlesbares Verzeichnis die Kennzeichnung"},
		{Field: "requirement", Question: "Gegen welche Anforderung? — aus dem Bezug-Block der laufenden Slices, Liste; `[]` heißt kein Bezug, eine unlesbare Slice-Datei die Kennzeichnung"},
		{Field: "adr", Question: "Auf wessen Entscheidung? — aus demselben Bezug-Block, Liste; `[]` und Kennzeichnung wie bei `requirement`"},
		{Field: "branch", Question: "Zu welchem Zweig gehört der Zugriff? — aus dem git-Zustand abgeleitet, sonst `" + NotKnown(SourceGitHead) + "`"},
		{Field: "commit", Question: "Zu welchem Stand gehört der Zugriff? — aus dem git-Zustand abgeleitet, sonst `" + NotKnown(SourceGitHead) + "`"},
		{Field: "status", Question: "Ging es gut?"},
		{Field: "rule_version", Question: "Unter welcher Fassung der Erfassungsregel entstand die Zeile? — eine Ganzzahl, die mit jedem Bedeutungswechsel eines Feldes steigt; eine Zeile ohne dieses Feld hat eine nicht bekannte Fassung"},
		{Field: "permission_mode", Question: "Unter welcher Berechtigungs-Lage lief der Aufruf?"},
		{Field: "path", Question: "Was wurde gelesen oder geschrieben? — der Pfad, nie der Inhalt, und nur bei namentlich geführten Datei-Werkzeugen"},
		{Field: "bytes", Question: "Wie groß ist die geschriebene Datei? — aus dem Dateisystem, nie aus der Payload"},
		{Field: "sha256_16", Question: "Hat sich der Inhalt geändert? — ein Fingerabdruck-Präfix aus dem Dateisystem, nie der Inhalt selbst"},
		{Field: "program", Question: "Welches Programm lief? — das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile"},
		{Field: "argc", Question: "Wie viele Argumente hatte es? — die Anzahl, nie die Argumente"},
		{Field: "duration_ms", Question: "Wie lange dauerte der Aufruf, wie der Hook ihn sieht?"},
		{Field: "result_bytes", Question: "Wie groß war das Ergebnis? — die Länge, nie der Inhalt"},
		{Field: "spawned_role", Question: "Welche Rolle lief im Subagenten? — aus dem Ergebnis, gegen die kanonischen Namen normalisiert"},
		{Field: "input_tokens", Question: "Wie viele Eingabe-Token verbrauchte der Subagenten-Lauf?"},
		{Field: "output_tokens", Question: "Wie viele Ausgabe-Token verbrauchte er?"},
		{Field: "cache_creation_input_tokens", Question: "Zahlte der Lauf den Cache? — ohne Zähler im Ergebnis `" + NotKnown(SourceUsage) + "`"},
		{Field: "cache_read_input_tokens", Question: "Nutzte der Lauf den Cache? — ohne Zähler im Ergebnis `" + NotKnown(SourceUsage) + "`"},
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
//
// FUNKTION STATT KONSTANTE: der Satz baut die Rollen-Liste aus CanonicalRoles, und ein
// package-level var mit Funktionsaufruf ist gegen die Lint-Config verboten
// (gochecknoglobals) — AGENTS.md §3.2 laesst dafuer keine Inline-Suppression zu.
func limitAgentGuard() string {
	return "**Über die Aufrufform des Agenten-Werkzeugs führt diese Ebene keinen Wächter.**\n" +
		"Das Feld `agent_role` besetzt sich genau dann, wenn der Agenten-Typ eine der sechs kanonischen\n" +
		"Rollen nennt — " + backtickJoin(CanonicalRoles()) + ". Wer\n" +
		"seine Typen umbenennt, bekommt `" + NotKnown(SourceAgentType) + "`, und **das heißt unbekannt, nie rollenlos**.\n" +
		"Kein Gate und kein Hook erzwingt, dass Rollen-Arbeit unter ihrem Rollen-Typ läuft; die\n" +
		"Rollen-Achse ruht hier auf Disziplin.\n"
}

// backtickJoin haengt jeden Namen in Backticks und trennt mit Komma+Leerzeichen. Die
// Liste selbst kommt aus CanonicalRoles, nicht aus einer zweiten Aufzaehlung hier.
func backtickJoin(names []string) string {
	quoted := make([]string, len(names))
	for i, n := range names {
		quoted[i] = "`" + n + "`"
	}
	return strings.Join(quoted, ", ")
}

const limitCounters = "**Die Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht.**\n" +
	"Die Token- und Cache-Zähler tragen einen Wert nur, wenn das Werkzeug sie im Ergebnis eines\n" +
	"Subagenten-Aufrufs mitliefert; ein im Hintergrund gestarteter Lauf liefert sie nicht. Dann\n" +
	"fehlen die Token-Zähler, und die Cache-Zähler tragen `nicht bekannt: tool_response.usage`. **Kein\n" +
	"Lauf dieses Repos führt sie herbei** — das ist keine Eigenschaft dieses Aufbaus, sondern der\n" +
	"Mechanik. Ein Bestand ohne Zähler ist deshalb der Normalfall und kein Defekt.\n"

const limitStore = "**Über den Bestand ist nichts zugesagt.** Er ist **gitignored**, aber **nicht\n" +
	"verschlüsselt** und **nicht zugriffsbeschränkt**. Und **Pfadnamen sind nicht als unkritisch\n" +
	"zugesagt** — sie stehen als `path` in der Zeile, und ein Pfad kann selbst die Aussage sein, die\n" +
	"niemand teilen wollte. Wer den Bestand weitergibt, gibt beides weiter.\n"

// limits liefert die drei Grenz-Saetze in ihrer Reihenfolge im Dokument.
func limits() []string { return []string{limitAgentGuard(), limitCounters, limitStore} }

// fieldListHead ist der Kopf des Dokuments: was es ist, woher es kommt, und was das
// geschlossene Schema bedeutet. Er nennt KEIN `make`-Ziel (das Dokument nennt allein
// `make span-clean`, das jeder Lauf schreibt) und traegt KEINEN Markdown-Link
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
	"**Pflicht** heißt: das Feld steht in jeder Zeile. Eine leere Liste `[]` ist dort eine Aussage —\n" +
	"keiner — und kein fehlender Wert. Die Kennzeichnung *nicht bekannt* tragen abschließend diese Felder:\n" +
	"`cache_creation_input_tokens`, `cache_read_input_tokens`, `agent_role`, `branch`, `commit`, `slice`,\n" +
	"`requirement`, `adr`. Liefert die Quelle ihren Wert nicht, steht statt seiner `nicht bekannt:` und die\n" +
	"Quelle, die ihn nicht liefert — nie `0`, nie `\"\"`, nie `[]`. Für die übrigen Pflichtfelder gilt sie\n" +
	"nicht; im Haupt-Kontext stehen etwa `agent`, `agent_type`, `tool_use_id` und `event` als `\"\"`.\n" +
	"**Optional** heißt: das Feld fehlt, wo es nichts zu sagen gibt.\n" +
	"\n" +
	"| Feld | Pflicht | Wonach gefragt wird |\n" +
	"|---|---|---|\n"

// availCache, availPR, availMainContext und availStore sind die vier Saetze ueber
// Verfuegbarkeit und Aufbewahrung. Jeder gibt eine Zeile der Spezifikation dieses Werkzeugs
// wieder (spec/spezifikation.md §5) und nennt sie als Quelle — bei ihrem Gegenstand, nicht
// bei ihrer Kennung: im Ziel loest keine Kennung dieses Werkzeugs auf (LH-QA-01, gehalten
// von TestEmittierteDateienTragenNurImZielAufloesendeKennungen). Je Satz haelt ein Test in
// fieldlist_test.go den Satz, den genannten Gegenstand gegen die Zelle der Spec-Zeile UND
// die Wendungen der Zeile, die er wiedergibt; aendert sich die Zeile, faellt der Test.
//
// availCache gibt SPEC-055 mit SPEC-087 wieder: eine Zahl traegt nur der Span eines
// Subagenten-Aufrufs im Vordergrund, jeder andere die Kennzeichnung.
const availCache = "**Den Cache-Status liefert nur ein Subagenten-Aufruf im Vordergrund.** Die zwei\n" +
	"Cache-Zähler tragen eine Zahl nur im Span eines solchen Aufrufs, und die Zahl ist die des\n" +
	"Subagenten-Laufs. Jeder andere Span und ein Aufruf, dessen Ergebnis keine Zähler führt, trägt in\n" +
	"beiden Feldern `nicht bekannt: tool_response.usage`; die Felder stehen trotzdem in jeder Zeile.\n" +
	"Der Cache des Haupt-Kontexts selbst steht in keinem Span.\n" +
	"Quelle: Spezifikation von ai-harness-init, §5, Festlegungen „Cache-Status (Quelle)\" und\n" +
	"„Kennzeichnung *nicht bekannt*\".\n"

// availPR gibt SPEC-056 wieder und die Begruendung des Adaptions-Eintrags MR-077.
const availPR = "**Eine PR-Nummer steht bewusst nicht im Schema.** Sie lebt bei der Forge, und die\n" +
	"Erfassung läuft je Werkzeug-Aufruf, ohne Netz und ohne `gh`. An ihrer Stelle stehen `branch`\n" +
	"und `commit`, abgeleitet aus `.git/HEAD`; über sie schlägt eine Auswertung den PR nach. Das ist\n" +
	"eine Ableitung, keine Erfüllung: liegt zum Zweig kein PR vor, bleibt die Frage offen.\n" +
	"Quelle: Spezifikation von ai-harness-init, §5, Festlegung „PR-Nummer (Abweichung 2)\";\n" +
	"Adaptions-Eintrag „Statt der PR-Nummer erfasst der Span branch und commit\" von ai-harness-init.\n"

// availMainContext gibt SPEC-049 wieder: der Verbrauch des Haupt-Kontexts steht in keinem
// Span, und eine Token-Bilanz ist eine ueber Subagenten-Laeufe.
const availMainContext = "**Der Haupt-Kontext trägt keine Zahl.** Die Token-Zähler und die drei\n" +
	"Gesamtwerte stehen ausschließlich im Ergebnis eines Subagenten-Aufrufs, und den Haupt-Kontext\n" +
	"umschließt keiner. `result_bytes` und `duration_ms` sind Größen eines Aufrufs, keine Token;\n" +
	"geschätzt wird nicht. Jede Token-Bilanz aus diesen Zeilen ist eine Bilanz über\n" +
	"Subagenten-Läufe: ihr Nenner ist nicht der Verbrauch des Laufs, und ein Prozentsatz daraus ist\n" +
	"ein Anteil an der erfassten Teilmenge.\n" +
	"Quelle: Spezifikation von ai-harness-init, §5, Festlegung „Haupt-Kontext ohne Zahl (Abweichung 6)\".\n"

// availStore gibt SPEC-057 wieder. `make span-clean` steht im Ziel in jedem Lauf: das
// Fragment harness/mk/erfassung.mk ist unbedingt und konvergent (internal/emit/erfassung.go).
const availStore = "**Der Bestand wird nie nebenbei geräumt.** Die Erfassung hängt ausschließlich an;\n" +
	"Altbestände bleiben auch beim ersten Span einer Sitzung liegen. Aufgeräumt wird ausdrücklich mit\n" +
	"`make span-clean`, das den ganzen Bestand entfernt. Ein Werkzeug, das Sitzungs-Kennungen\n" +
	"wiederverwendet, mischt zwei Läufe in einer Datei.\n" +
	"Quelle: Spezifikation von ai-harness-init, §5, Festlegung „Altbestände (Abweichung 4)\".\n"

// availability liefert die vier Saetze in ihrer Reihenfolge im Dokument.
func availability() []string {
	return []string{availCache, availPR, availMainContext, availStore}
}

// fieldListAvailabilityHead leitet die vier Saetze ueber Verfuegbarkeit und Aufbewahrung
// ein: was die Erfassung nicht liefern kann und was mit dem Bestand geschieht.
const fieldListAvailabilityHead = "\n" +
	"## Verfügbarkeit und Aufbewahrung\n" +
	"\n"

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
	// wohlgeformt — der Waechter ueber ihm faellt, nicht das Markdown. Dieselbe Fuge gilt
	// fuer die Saetze ueber Verfuegbarkeit und Aufbewahrung.
	b.WriteString(fieldListAvailabilityHead)
	b.WriteString(strings.Join(availability(), "\n"))
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
