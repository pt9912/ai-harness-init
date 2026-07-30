package span_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// Die vier gemessenen Freitext-Felder aus `tool_response` (slice-060 §3, Zeilen 1-2),
// je mit EIGENEM Kanarienvogel: so sagt ein Fehlschlag, WELCHES Feld durchkam. Der
// Aufbau ist die Voraussetzung dafuer, dass jedes der vier eine eigene Mutation
// bekommen kann (test/mutations/123..126).
const (
	geheimContent     = "CONTENT-AWS_SECRET_ACCESS_KEY=aaa111"
	geheimPrompt      = "PROMPT-hunter2-bbb222"
	geheimDescription = "DESCRIPTION-token-ccc333"
	geheimOutputFile  = "/tmp/OUTPUTFILE-ddd444.md"
)

// rawStream liefert die GESCHRIEBENE Zeile als Text. Die Erfassungs-Zusagen dieses
// Slice sind Aussagen ueber die ZEILE, nicht ueber einen Rueckgabewert: was aus einem
// eingebetteten Struct erst beim Marshalling entsteht, ist an einer Struct-Assertion
// nicht vollstaendig messbar.
func rawStream(t *testing.T, root, stream string) string {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(root, span.Dir, stream+".jsonl"))
	if err != nil {
		t.Fatalf("Strom lesen: %v", err)
	}
	return string(b)
}

func mustNotContain(t *testing.T, line string, verboten ...string) {
	t.Helper()
	for _, v := range verboten {
		if strings.Contains(line, v) {
			t.Fatalf("%q steht in der Span-Zeile: %s", v, line)
		}
	}
}

// mustContain traegt die GEGENPROBE: ohne sie bestuende ein Waechter, der eine
// ERFASSUNG prueft, auch bei einer Erfassung von NICHTS — der Name behauptet dann eine
// Eigenschaft und prueft eine leere Menge (AGENTS.md §3.6).
//
// WIE WEIT DAS TRAEGT: fuenf
// der sieben Waechter dieser Datei nennen in ihrer Gegenprobe erfasste WERTE und fallen
// damit bei einer Erfassung von nichts. ZWEI tun das nicht, weil sie reine
// NEGATIV-Waechter sind: TestAgentGetsNoArgumentFields und
// TestFailedAgentCallCapturesNothing pruefen Name, Status und Ereignis — Groessen, die
// von der Erfassung unabhaengig sind. Ihre Gegenprobe schliesst „kein Span" aus, nicht
// „keine Erfassung"; das ist fuer ihre Zusage auch richtig (beide messen die ABWESENHEIT
// von Feldern), aber es ist die schwaechere Aussage.
func mustContain(t *testing.T, line string, erwartet ...string) {
	t.Helper()
	for _, v := range erwartet {
		if !strings.Contains(line, v) {
			t.Fatalf("%s fehlt in der Span-Zeile — ohne diese Gegenprobe waere der Waechter auch bei einer Erfassung von nichts gruen: %s", v, line)
		}
	}
}

// agentForegroundPayload ist die gemessene Gestalt eines Vordergrund-Aufrufs
// (slice-060 §3 Zeile 1), VEREINIGT mit den zwei Freitext-Feldern, die nur der
// Hintergrund-Lauf trug (`outputFile`, `description`, Zeile 2). Die Vereinigung ist
// absichtlich synthetisch: die Zusage lautet "kein Freitext aus dem Ergebnis" und
// nicht "kein Freitext aus DIESEM Ergebnis", und die Erfassung entscheidet nach dem
// WERKZEUG-Namen, nicht nach der Betriebsart.
func agentForegroundPayload() string {
	return `{"hook_event_name":"PostToolUse","tool_name":"Agent","session_id":"s1",
	  "tool_input":{"subagent_type":"reviewer","prompt":"` + geheimPrompt + `",
	    "description":"` + geheimDescription + `","run_in_background":false},
	  "tool_response":{
	    "usage":{"input_tokens":11,"output_tokens":22,
	      "cache_creation_input_tokens":33,"cache_read_input_tokens":44},
	    "totalTokens":110,"totalDurationMs":4184,"totalToolUseCount":7,
	    "agentType":"reviewer","resolvedModel":"claude-opus-5[1m]","status":"completed",
	    "content":"` + geheimContent + `","prompt":"` + geheimPrompt + `",
	    "description":"` + geheimDescription + `","outputFile":"` + geheimOutputFile + `"}}`
}

// TestNoResponseFreetextReachesSpan ist der Kanarienvogel der ERGEBNIS-Flaeche. Sie ist
// nicht die harmlose Seite: `content` ist der groesste Freitext-Block des ganzen
// Aufrufs (der vollstaendige Bericht des Subagenten), und `prompt` — das
// ADR-0011 Festlegung 2 namentlich fuerchtet — steht in `tool_input` UND hier.
//
// Gemessen wird die geschriebene Zeile gegen VIER eigene Kanarienvoegel plus die vier
// Schluesselnamen: ein Leck ueber einen anderen Weg als den Wert (etwa der Schluessel
// als Text) faellt damit auch.
func TestNoResponseFreetextReachesSpan(t *testing.T) {
	root := newRoot(t)
	emit(t, root, agentForegroundPayload())
	line := rawStream(t, root, "s1")
	mustNotContain(t, line,
		geheimContent, geheimPrompt, geheimDescription, geheimOutputFile,
		"aaa111", "bbb222", "ccc333", "ddd444",
		`"content"`, `"prompt"`, `"description"`, `"outputFile"`)
	// Die neun gelisteten Werte MUESSEN dastehen — sonst messe dieser Waechter eine
	// Erfassung, die es nicht gibt.
	mustContain(t, line,
		`"spawned_role":"reviewer"`,
		`"input_tokens":11`, `"output_tokens":22`,
		`"cache_creation_input_tokens":33`, `"cache_read_input_tokens":44`,
		`"total_tokens":110`, `"total_duration_ms":4184`, `"total_tool_use_count":7`,
		`"model_version":"claude-opus-5[1m]"`)
}

// TestUnlistedResponseKeyStaysOut ist der GRENZ-Zahn: er misst die Positiv-Liste als
// EIGENSCHAFT, nicht als Aufzaehlung. Vier namentliche Faelle (123..126) unterscheiden
// eine Positiv-Liste nicht von einer Implementierung, die genau diese vier ausfiltert —
// sie belegen die Zusage, nicht die Eigenschaft (slice-060 DoD (2)).
//
// Die ungelisteten Schluessel sind zur Haelfte GEMESSEN (`agentId`, `isAsync`,
// `canReadOutputFile`, `is_interrupt` — §3 Zeilen 2 und 4) und zur Haelfte ERFUNDEN.
// Dass die erfundenen dabei sind, ist der Punkt: die Flaeche wuchs in vier gemessenen
// Aufrufen auf fuenf undokumentierte Schluessel, und der fuenfte kuenftige ist derselbe
// Fall. Ein ungelisteter Schluessel liegt hier auch VERSCHACHTELT (in `usage`) —
// dieselbe Frage eine Ebene tiefer.
//
// DIE GEGENPROBE UNTEN LAESST `model_version` ABSICHTLICH AUS. Die Senke des Grenz-Zahns
// test/mutations/127-span-positivliste-negiert.sh IST dieses Feld — es ist der einzige
// String unter den neun erfassten Werten. Stuende `"model_version":"claude-opus-5[1m]"`
// in der Gegenprobe, verschoebe die Senke die schliessende Anfuehrung und dieser
// Waechter faellt unter Fall 127 aus ZWEI unabhaengigen Gruenden. Wer dann den
// mustNotContain-Block streicht — die Grenz-Zusicherung selbst —, bekaeme von
// `make mutate` weiter „127 ok": Bedingung 4 des Treibers fand den erwarteten Namen
// nach wie vor in der Fehlschlag-Ausgabe. So faellt der Waechter unter Fall 127 an
// GENAU der Zusicherung, die er tragen soll. Dass `model_version` ueberhaupt erfasst
// wird, deckt TestNoResponseFreetextReachesSpan mit; hier waere es Ueberdetermination.
func TestUnlistedResponseKeyStaysOut(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Agent","session_id":"s1","tool_response":{
	  "usage":{"input_tokens":11,"geheimZaehler":"NESTED-eee555"},
	  "totalTokens":110,"agentType":"verifier","resolvedModel":"claude-opus-5[1m]",
	  "agentId":"AGENTID-fff666","isAsync":true,"canReadOutputFile":true,
	  "is_interrupt":false,"erfundenesFeld":"ERFUNDEN-ggg777",
	  "nochNieGesehen":{"tief":"TIEF-hhh888"}}}`)
	line := rawStream(t, root, "s1")
	mustNotContain(t, line,
		"NESTED-eee555", "AGENTID-fff666", "ERFUNDEN-ggg777", "TIEF-hhh888",
		"eee555", "fff666", "ggg777", "hhh888",
		"geheimZaehler", "agentId", "isAsync", "canReadOutputFile", "is_interrupt",
		"erfundenesFeld", "nochNieGesehen")
	mustContain(t, line,
		`"spawned_role":"verifier"`, `"input_tokens":11`, `"total_tokens":110`)
}

// TestOnlyAgentToolGetsResponseValues haelt die ACHSE fest: erfasst wird nach dem
// WERKZEUG-Namen (ADR-0011 Festlegung 2), nicht nach der Gestalt der Antwort. Haengt
// die Erfassung an der Antwort, gibt jedes fremde Werkzeug, dessen Ergebnis zufaellig
// `usage` fuehrt, seine Zaehler und sein Modell preis — dieselbe Klasse, die auf der
// Argument-Achse schon aufgetreten ist (`mcp__db__run` lieferte "psql").
func TestOnlyAgentToolGetsResponseValues(t *testing.T) {
	const response = `"tool_response":{"usage":{"input_tokens":11},"totalTokens":110,
	  "agentType":"reviewer","resolvedModel":"claude-opus-5[1m]"}`
	for _, tool := range []string{"Bash", "Read", "Write", "Task", "mcp__x__agent", "BashOutput", "agent"} {
		t.Run(tool, func(t *testing.T) {
			p, err := span.Parse([]byte(`{"tool_name":"` + tool + `",` + response + `}`))
			if err != nil {
				t.Fatalf("Parse: %v", err)
			}
			s := span.Build(p, t.TempDir(), time.Now())
			if s.SpawnedRole != "" || s.ModelVersion != "" || s.TotalTokens != nil || s.InputTokens != nil {
				t.Fatalf("Werkzeug %q gab Ergebnis-Werte preis: %+v", tool, s)
			}
			// Name, Status und die LAENGE gelten fuer JEDES Werkzeug und bleiben.
			if s.ResultBytes == nil || s.Status == "" {
				t.Fatalf("Werkzeug %q verlor Name/Status/Laenge: %+v", tool, s)
			}
		})
	}
	// Gegenprobe unter dem gelisteten Namen.
	p, err := span.Parse([]byte(`{"tool_name":"Agent",` + response + `}`))
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	s := span.Build(p, t.TempDir(), time.Now())
	if s.SpawnedRole != "reviewer" || s.TotalTokens == nil || s.InputTokens == nil || s.ModelVersion == "" {
		t.Fatalf("`Agent` ist namentlich gelistet und erfasst nichts: %+v", s)
	}
}

// TestAgentGetsNoArgumentFields ist B1 und B2 des Architect-Verdikts vom 2026-07-30
// (docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md §6) in einer Payload.
//
// B1: `spawned_role` kommt aus `tool_response.agentType`, NIE aus
// `tool_input.subagent_type`. Steht bei fehlendem Ergebnis trotzdem `reviewer` im
// Span, ist die Argument-Achse geoeffnet — genau die Achse, die die Default-Zeile von
// ADR-0011 Festlegung 2 regelt — und das ADR-Verdikt faellt.
//
// B2: `Agent` ist auf KEINE der drei Gattungszeilen abgebildet. Das `tool_input` traegt
// hier zusaetzlich `command` und `file_path` — die Eingaben, mit denen ein Kommando-
// oder Datei-Werkzeug Programm, Argument-Anzahl, Pfad und Fingerabdruck bekaeme.
func TestAgentGetsNoArgumentFields(t *testing.T) {
	root := newRoot(t)
	const payload = `{"tool_name":"Agent","session_id":"s1","tool_input":{
	  "subagent_type":"reviewer","prompt":"` + geheimPrompt + `",
	  "description":"` + geheimDescription + `","run_in_background":true,
	  "command":"gh auth login --with-token TOKEN-iii999","file_path":"/etc/shadow"}}`
	emit(t, root, payload)
	line := rawStream(t, root, "s1")
	mustNotContain(t, line, "spawned_role",
		geheimPrompt, geheimDescription, "bbb222", "ccc333",
		"TOKEN-iii999", "/etc/shadow", "subagent_type", "run_in_background")
	mustContain(t, line, `"tool":"Agent"`, `"status":"ok"`)

	// Die Gattungs-Felder gegen das STRUCT, nicht gegen die Zeile: `bytes` ist ein
	// Teilstring von `result_bytes`, und eine Teilstring-Assertion waere hier nur
	// deshalb gruen, weil dieser Span kein Ergebnis hat.
	p, err := span.Parse([]byte(payload))
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	s := span.Build(p, root, time.Now())
	if s.Path != "" || s.Program != "" || s.Argc != nil || s.Bytes != nil || s.Sha256Prefix != "" {
		t.Fatalf("`Agent` wurde auf eine Gattungszeile abgebildet: %+v", s)
	}
	if s.SpawnedRole != "" {
		t.Fatalf("spawned_role = %q — es kam aus tool_input.subagent_type (B1 gebrochen)", s.SpawnedRole)
	}
}

// TestSpawnedRoleIsNormalised: der Wert aus dem ERGEBNIS wird gegen die sechs
// kanonischen Namen normalisiert, alles andere wird LEER. `general-purpose` ist keine
// Rolle — eine Ergebniszeile `general-purpose: 62 %` waere genau die erfundene
// Kostenstelle, die die Lesevorschrift in MR-018 verbietet.
//
// Geprueft wird der Weg ueber `tool_response.agentType` (nicht roleFromAgentType
// selbst — das deckt TestAgentRoleFromKnownTypes): die WIEDERVERWENDUNG ist die
// Zusage, die hier faellt, wenn jemand daneben eine zweite Abbildung baut.
func TestSpawnedRoleIsNormalised(t *testing.T) {
	cases := map[string]string{
		`"planner"`: "planner", `"architect"`: "architect", `"implementer"`: "implementer",
		`"reviewer"`: "reviewer", `"verifier"`: "verifier", `"validator"`: "validator",
		`"general-purpose"`: "", `""`: "", `"Explore"`: "", `"reviewer-2"`: "",
		`"Reviewer"`: "", `"reviewer "`: "", `42`: "", `null`: "",
		`{"name":"reviewer"}`: "", `["reviewer"]`: "",
	}
	for raw, want := range cases {
		p, err := span.Parse([]byte(`{"tool_name":"Agent","tool_response":{"agentType":` + raw + `}}`))
		if err != nil {
			t.Fatalf("Parse %s: %v", raw, err)
		}
		if got := span.Build(p, t.TempDir(), time.Now()).SpawnedRole; got != want {
			t.Fatalf("agentType %s -> spawned_role %q, erwartet %q", raw, got, want)
		}
	}
}

// TestResolvedModelIsStructurallyBounded ist B5: `resolvedModel` ist der EINZIGE
// Rohstring unter den neun erfassten Werten — acht sind Zahlen oder das gegen sechs
// Namen normalisierte Etikett. Sein Mandat ist echt (Modul 15 verlangt `model.version`
// als Label), aber ADR-0011 Festlegung 2 sagt "konstruktiv ausgeschlossen, NICHT per
// Regel verboten".
//
// VERWORFEN WIRD GANZ, NICHT GEKUERZT: 64 Byte eines Geheimnisses sind auch 64 Byte
// fremden Inhalts. Der Fehlermodus ist deshalb ein FEHLENDES Feld, nicht ein
// verstuemmeltes — dieselbe fail-closed Linie wie commandProgram.
func TestResolvedModelIsStructurallyBounded(t *testing.T) {
	const geheim = "AWS_SECRET_ACCESS_KEY=jjj000"
	cases := []struct{ name, in, want string }{
		{"der gemessene Bezeichner dieser Umgebung", "claude-opus-5[1m]", "claude-opus-5[1m]"},
		{"Datums-Suffix", "claude-opus-4-1-20250805", "claude-opus-4-1-20250805"},
		{"Punkt und Unterstrich", "gpt_4.1-mini", "gpt_4.1-mini"},
		{"genau die Laengen-Schranke", strings.Repeat("a", 64), strings.Repeat("a", 64)},
		{"ein Byte darueber", strings.Repeat("a", 65), ""},
		{"100 kB Prosa mit Geheimnis", strings.Repeat("Lorem ipsum ", 8500) + geheim, ""},
		{"nur die Zuweisung", geheim, ""},
		{"Leerraum", "claude opus", ""},
		{"Pfad-Ausbruch", "../../etc/passwd", ""},
		{"leer", "", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			payload, err := json.Marshal(map[string]any{
				"tool_name":     "Agent",
				"tool_response": map[string]any{"resolvedModel": tc.in},
			})
			if err != nil {
				t.Fatalf("Payload bauen: %v", err)
			}
			p, err := span.Parse(payload)
			if err != nil {
				t.Fatalf("Parse: %v", err)
			}
			s := span.Build(p, t.TempDir(), time.Now())
			if s.ModelVersion != tc.want {
				t.Fatalf("model_version hat %d Byte, erwartet %q", len(s.ModelVersion), tc.want)
			}
			b, err := json.Marshal(s)
			if err != nil {
				t.Fatalf("Marshal: %v", err)
			}
			// Auch kein PRAEFIX des Geheimnisses: ein Kuerzen auf die Schranke haette
			// hier ein `AWS_SECRET_ACCESS_KEY=` stehen lassen.
			if strings.Contains(string(b), "AWS_SECRET") || strings.Contains(string(b), "jjj000") ||
				strings.Contains(string(b), "Lorem") {
				t.Fatalf("fremder Inhalt aus resolvedModel steht im Span (model_version hat %d Byte)", len(s.ModelVersion))
			}
		})
	}
}

// TestFailedAgentCallCapturesNothing: der Fehlschlag braucht KEINE Sonderregel. Bei
// einem unbekannten Agenten-Typ fehlt `tool_response` GANZ (gemessen, slice-060 §3
// Zeile 4 — nicht leer, sondern nicht vorhanden); `error` steht auf oberster Ebene,
// dazu ein bis dahin ungesehenes `is_interrupt`. Es entsteht ein Span mit Name und
// Status, kein HALBER: die neun Werte fehlen alle, statt mit 0 dazustehen.
//
// WAS AN DIESER LISTE EINEN DAUER-ZAHN HAT, und was nicht — sonst behauptet die Liste
// mehr, als sie bindet: DREI der neun Eintraege sind einzeln
// gebunden — `input_tokens` von test/mutations/134-span-zaehler-praesent-leer.sh,
// `output_tokens` von test/mutations/136-span-ausgabezaehler-praesent-leer.sh,
// `spawned_role` von test/mutations/137-span-rollenfeld-praesent-leer.sh. Die
// uebrigen SECHS prueft dieser Waechter, aber kein Fall bindet sie einzeln: wer einen
// von ihnen aus der Liste streicht, bekommt von `make mutate` keinen Befund. Die
// normative Fassung dieser Auszaehlung steht in harness/conventions.md MR-018
// §Bewacht Punkt 8.
func TestFailedAgentCallCapturesNothing(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"hook_event_name":"PostToolUseFailure","tool_name":"Agent",
	  "session_id":"s1","error":"Agent type 'nope' not found","is_interrupt":false,
	  "tool_input":{"subagent_type":"nope","prompt":"`+geheimPrompt+`"}}`)
	line := rawStream(t, root, "s1")
	mustContain(t, line, `"tool":"Agent"`, `"status":"error"`, `"event":"PostToolUseFailure"`)
	// DIE NEUN WERTE NAMENTLICH. Fehlt einer, faellt seine Draht-Form aus der Pruefung:
	// ein Feld ohne `omitempty` stuende als `"<name>":null` in JEDER Zeile, auch in einem
	// reinen `Bash`-Span, und kippte die MR-018-Lesart "unbekannt" gegen "nicht
	// vorhanden" — bei gruenem Gate-Stack.
	//
	// Die zwei Cache-Zaehler deckte `"input_tokens"` schon per TEILSTRING ab; sie
	// stehen jetzt trotzdem namentlich da, damit der Leser NEUN Namen gegen die
	// Feldtabelle in MR-018 zaehlen kann statt sieben plus einer Teilstring-
	// Ueberlegung. `result_bytes` ist KEINER der neun — es ist die Laenge, die jedes
	// Werkzeug abgibt; sie fehlt hier, weil `tool_response` ganz fehlt.
	mustNotContain(t, line,
		"spawned_role", "input_tokens", "output_tokens",
		"cache_creation_input_tokens", "cache_read_input_tokens",
		"total_tokens", "total_duration_ms", "total_tool_use_count", "model_version",
		"result_bytes",
		geheimPrompt, "is_interrupt", "not found")
}
