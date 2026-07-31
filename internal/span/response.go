package span

import "encoding/json"

// AgentResult traegt die Werte, die aus dem ERGEBNIS eines Agenten-Aufrufs erfasst
// werden: NEUN Blatt-Werte aus SECHS Schluesseln von `tool_response` (nachgezaehlt —
// vier Zaehler in `usage`, drei Summen, die Rolle, das Modell). Eine fruehere
// Planfassung sagte "sieben" und war unter beiden Zaehlweisen falsch; die Zahl entsteht,
// wenn man Rolle und Modell vergisst.
//
// DIES IST DER TRAEGER, NICHT DIE AUSWAHL. Was erfasst wird, entscheidet allein die
// Positiv-Liste responseKeys() — an EINER Stelle, ueber die die Erfassung iteriert. Die
// Unterscheidung ist eine Plan-Vorgabe von slice-060 und traegt den Grenz-Zahn: waere
// die Auswahl die Feldliste dieses Structs, wuerde "alles ausser den vier Freitext-
// Feldern" einen Wechsel der Datenstruktur verlangen, waehrend jede bestehende
// Span-Mutation einzeilig ist (test/mutations/127-span-positivliste-negiert.sh).
//
// EINGEBETTET in Span — die Felder erscheinen dort flach in der Zeile. So gibt es genau
// EINE Stelle, an der ein neues Feld eingetragen wird, statt einer zweiten
// Zuweisungs-Liste in Build, die gegen die erste driften kann.
//
// Die Feldtabelle samt Incident-Fragen steht in harness/conventions.md MR-018 — sie ist
// die normative Fassung (ADR-0011 Folgepflicht 1: "der naechste Leser muss es ohne Code
// finden"), dieses Struct ihre Umsetzung.
type AgentResult struct {
	SpawnedRole              string `json:"spawned_role,omitempty"`
	InputTokens              *int64 `json:"input_tokens,omitempty"`
	OutputTokens             *int64 `json:"output_tokens,omitempty"`
	CacheCreationInputTokens *int64 `json:"cache_creation_input_tokens,omitempty"`
	CacheReadInputTokens     *int64 `json:"cache_read_input_tokens,omitempty"`
	TotalTokens              *int64 `json:"total_tokens,omitempty"`
	TotalDurationMS          *int64 `json:"total_duration_ms,omitempty"`
	TotalToolUseCount        *int64 `json:"total_tool_use_count,omitempty"`
	ModelVersion             string `json:"model_version,omitempty"`
}

// responseKey ist ein Eintrag der Positiv-Liste: WO der Wert steht und WIE er
// uebernommen wird. Die Schranke sitzt im `take`, nicht beim Leser — ein Auswerter, der
// sich auf eine Schranke verlassen muesste, hat keine.
type responseKey struct {
	// path ist der Weg in `tool_response`: ein Element fuer einen Schluessel auf
	// oberster Ebene, zwei fuer die Zaehler im `usage`-Objekt.
	path []string
	take func(*AgentResult, json.RawMessage)
}

// responseKeys ist die POSITIV-LISTE: aus `tool_response` wird AUSSCHLIESSLICH erfasst,
// was hier steht. Alles andere faellt heraus, ohne genannt zu werden — der konstruktive
// Ausschluss aus ADR-0011 Festlegung 1 Punkt 3 ("das Schema ist GESCHLOSSEN") und dem
// Satz "kein Byte fremden Inhalts" aus Festlegung 2.
//
// WARUM POSITIV UND NICHT NEGATIV: die Messung an vier echten Aufrufen (slice-060 §3)
// zeigte VIER Freitext-Felder im Ergebnis — `content`, `prompt`, `description`,
// `outputFile` — und dabei fuenf undokumentierte Schluessel; die Flaeche waechst
// erkennbar weiter. Eine Negativ-Liste altert mit jedem neuen Antwortfeld, eine
// Positiv-Liste haelt auch beim fuenften Freitext-Feld.
//
// FUNKTION statt Paket-Variable: Hard Rule 3.2 laesst keine Inline-Suppression zu, und
// gochecknoglobals (.golangci.yml) verbietet die Paket-Variable. Der Aufrufer sieht
// dieselbe eine Liste.
//
// Bewacht von TestNoResponseFreetextReachesSpan (die vier gemessenen Freitext-Felder,
// je mit eigener Mutation in test/mutations/123..126) und TestUnlistedResponseKeyStaysOut
// (die GRENZE selbst: ein erfundener, ungelisteter Schluessel).
func responseKeys() []responseKey {
	return []responseKey{
		{path: []string{"usage", "input_tokens"}, take: intoInputTokens},
		{path: []string{"usage", "output_tokens"}, take: intoOutputTokens},
		{path: []string{"usage", "cache_creation_input_tokens"}, take: intoCacheCreation},
		{path: []string{"usage", "cache_read_input_tokens"}, take: intoCacheRead},
		{path: []string{"totalTokens"}, take: intoTotalTokens},
		{path: []string{"totalDurationMs"}, take: intoTotalDuration},
		{path: []string{"totalToolUseCount"}, take: intoTotalToolUse},
		{path: []string{"agentType"}, take: intoSpawnedRole},
		{path: []string{"resolvedModel"}, take: intoModelVersion},
	}
}

func intoInputTokens(r *AgentResult, v json.RawMessage)   { r.InputTokens = count(v) }
func intoOutputTokens(r *AgentResult, v json.RawMessage)  { r.OutputTokens = count(v) }
func intoCacheCreation(r *AgentResult, v json.RawMessage) { r.CacheCreationInputTokens = count(v) }
func intoCacheRead(r *AgentResult, v json.RawMessage)     { r.CacheReadInputTokens = count(v) }
func intoTotalTokens(r *AgentResult, v json.RawMessage)   { r.TotalTokens = count(v) }
func intoTotalDuration(r *AgentResult, v json.RawMessage) { r.TotalDurationMS = count(v) }
func intoTotalToolUse(r *AgentResult, v json.RawMessage)  { r.TotalToolUseCount = count(v) }

// intoSpawnedRole nimmt die TATSAECHLICH gelaufene Rolle aus dem ERGEBNIS
// (`agentType`) — nie aus `tool_input.subagent_type`, das nur die Anforderung ist und
// auf der Argument-Achse liegt, die ADR-0011 Festlegung 2 schuetzt. Der Span fuehrt
// `agent_type`/`agent_role` schon mit anderer Bedeutung (der Typ des LAUFENDEN Agenten),
// deshalb der eigene Feldname.
//
// roleFromAgentType wird WIEDERVERWENDET, nicht kopiert: ein unbekannter Wert — heute
// durchweg `general-purpose` — ergibt ein LEERES Feld. `general-purpose` ist keine
// Rolle, und eine Ergebniszeile `general-purpose: 62 %` waere genau das, was die
// Lesevorschrift in MR-018 verbietet.
//
// LEER HEISST HIER ABWESEND, nicht `""`: das Feld traegt `omitempty`. Das ist die andere
// Draht-Form als bei `agent_role`, das als Pflichtfeld present-and-empty in jeder Zeile
// steht — `agent_role` gehoert zu einem Block, den JEDER Span traegt, `spawned_role`
// entsteht nur bei einem `Agent`-Aufruf. Ein `"spawned_role":""` in jedem `Bash`-Span
// behauptete einen Subagenten, den es nicht gab. Lesbar bleibt der Unterschied, weil
// `tool` Pflicht ist: ein `Agent`-Span OHNE `spawned_role` ist ein Lauf mit unbekannter
// Rolle, nicht ein Lauf ohne Rolle. Die bindende Fassung steht in MR-018.
//
// Bewacht von TestSpawnedRoleIsNormalised mit dem Dauer-Sensor
// test/mutations/128-span-rolle-unnormalisiert.sh. Die Abwesenheit bei fehlendem Ergebnis
// bewachen TestAgentGetsNoArgumentFields und TestFailedAgentCallCapturesNothing — die
// zwei Achsen liegen aber NICHT gleich ueber beiden Waechtern:
//
// HERKUNFT (Rueckfall auf `tool_input.subagent_type`):
// test/mutations/132-span-rolle-aus-argument.sh faerbt NUR den ersten. Der zweite fuehrt
// `subagent_type: "nope"`, das roleFromAgentType zu leer normalisiert, und bleibt unter
// 132 absichtlich gruen — seine Herkunfts-Achse hat damit keinen Zahn, und das ist
// Absicht: ein ROHER Rueckfall faerbte ihn mit, und "132 rot" hiesse dann nicht mehr
// eindeutig "die Herkunft greift im ERSTEN Waechter".
//
// DRAHT-FORM (`spawned_role` ohne `omitempty`):
// test/mutations/137-span-rollenfeld-praesent-leer.sh und
// test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh faerben BEIDE. Die zwei
// Faelle tragen dieselbe Mutation und unterscheiden sich nur in ihrer `# expect:`-Zeile:
// 137 bindet den `mustNotContain`-Eintrag des Fehlschlag-Waechters, 138 den des ersten.
// Ein Fall bindet nur EINEN von beiden, weil der Treiber je Fall genau einen Namen in
// der Fehlschlag-Ausgabe sucht.
func intoSpawnedRole(r *AgentResult, v json.RawMessage) {
	r.SpawnedRole = roleFromAgentType(text(v))
}

func intoModelVersion(r *AgentResult, v json.RawMessage) {
	r.ModelVersion = modelVersion(text(v))
}

// maxModelVersion ist die Laengen-Schranke des einzigen Rohstrings unter den neun
// Werten. 64 ist rund das Doppelte des laengsten hier bekannten Bezeichners
// (`claude-opus-5[1m]` misst 17) — Luft fuer Datums- und Varianten-Suffixe, ohne dass
// Prosa hineinpasst.
const maxModelVersion = 64

// modelVersion ist die STRUKTURELLE Schranke um `resolvedModel`. Acht der neun erfassten
// Werte sind Zahlen oder das gegen sechs Namen normalisierte `spawned_role`; dieser eine
// ist eine unbegrenzte Zeichenkette aus der Payload des Herstellers. Sein Mandat ist
// echt (Modul 15 verlangt `model.version` als Label), aber ADR-0011 Festlegung 2 sagt
// "konstruktiv ausgeschlossen, NICHT per Regel verboten" — eine woertliche Kopie eines
// unbegrenzten Fremdstrings waere genau "per Regel verboten".
//
// VERWORFEN WIRD GANZ, NICHT GEKUERZT. Ein Kuerzen auf 64 Zeichen kopierte immer noch
// 64 Byte fremden Inhalts ins Log — bei einem Geheimnis am Anfang genau die Bytes, die
// nie hineindarfen. Ein Modell-Bezeichner ist ein kurzes, wohlgeformtes Token; was diese
// Gestalt nicht hat, IST keiner, und dann ist das ehrliche Protokoll "unbekannt" (Feld
// fehlt) statt eines verstuemmelten Praefixes. Dieselbe fail-closed Linie faehrt
// commandProgram: bleibt nach den Zuweisungs-Praefixen etwas mit `=` uebrig, wird GAR
// NICHTS ausgegeben.
//
// DER ZEICHENSATZ IST EINE ENTSCHEIDUNG UNTER UNSICHERHEIT, und das gehoert gesagt: die
// Messung von slice-060 §3 erfasste nur SCHLUESSELNAMEN und Wertlaengen, nie Werte — die
// Gestalt eines echten `resolvedModel` ist hier also NICHT gemessen. Zugelassen sind
// Buchstaben, Ziffern, `.`, `_`, `-` und die Klammern `[` `]`: Letztere gehoeren zur
// Bezeichner-Sprache des Herstellers (der Bezeichner des in dieser Umgebung laufenden
// Modells ist `claude-opus-5[1m]`). Nicht zugelassen sind `=`, Leerraum, Pfad-Trenner
// und alles Uebrige. Der Fehlermodus ist damit ein FEHLENDES Feld, nicht ein falsches —
// und er ist am Bestand ablesbar: traegt kein einziger `Agent`-Span mit Zaehlern ein
// `model_version`, ist die Schranke zu eng geraten und wird hier weiter, nicht im Code
// aufgeweicht.
//
// Bewacht von TestResolvedModelIsStructurallyBounded und
// test/mutations/129-span-modellschranke-kuerzt.sh (die Mutation KUERZT statt zu
// verwerfen — der Fall, gegen den der Absatz oben steht).
func modelVersion(s string) string {
	if s == "" || len(s) > maxModelVersion {
		return ""
	}
	for _, r := range s {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9',
			r == '.', r == '_', r == '-', r == '[', r == ']':
		default:
			return ""
		}
	}
	return s
}

// count nimmt eine ZAHL oder nichts. Ein Wert anderen Typs kostet dieses Feld, nicht den
// Span — dieselbe tolerante Linie wie Parse. Und ein fehlender Zaehler bleibt ABWESEND
// statt 0: `0` waere eine Messung, die nie stattfand (Hintergrund-Laeufe liefern keine
// Zaehler, gemessen in slice-060 §3).
func count(v json.RawMessage) *int64 {
	var n int64
	if err := json.Unmarshal(v, &n); err != nil {
		return nil
	}
	return &n
}

func text(v json.RawMessage) string {
	var s string
	if err := json.Unmarshal(v, &s); err != nil {
		return ""
	}
	return s
}

// extractAgentResult ist die Erfassung: sie iteriert ueber die Positiv-Liste und holt
// AUSSCHLIESSLICH deren Schluessel. Ein ungelisteter Schluessel wird nicht
// uebersprungen, sondern nie angesehen — es gibt keinen Zweig, der ihn erreicht.
//
// DER FEHLSCHLAG-FALL BRAUCHT KEINE SONDERREGEL: bei einem fehlgeschlagenen
// Agenten-Aufruf fehlt `tool_response` ganz (gemessen, slice-060 §3 Zeile 4). Dann ruft
// Parse diese Funktion nicht auf, und es entsteht ein Span mit Name und Status — kein
// halber. Bewacht von TestFailedAgentCallCapturesNothing.
func extractAgentResult(response json.RawMessage) AgentResult {
	var obj map[string]json.RawMessage
	if err := json.Unmarshal(response, &obj); err != nil {
		// Kein Objekt (String, Zahl, null): nichts Gelistetes existiert. Der Span
		// entsteht trotzdem, nur ohne diese Werte.
		return AgentResult{}
	}
	var res AgentResult
	for _, k := range responseKeys() {
		v, ok := descend(obj, k.path)
		if !ok {
			continue
		}
		k.take(&res, v)
	}
	return res
}

// descend folgt dem Pfad EINES Listen-Eintrags. Der Pfad kommt aus der Liste, nie aus
// der Payload — eine Antwort kann sich also keinen eigenen Weg in den Span bauen.
func descend(obj map[string]json.RawMessage, path []string) (json.RawMessage, bool) {
	cur := obj
	for i, key := range path {
		v, ok := cur[key]
		if !ok {
			return nil, false
		}
		if i == len(path)-1 {
			return v, true
		}
		var next map[string]json.RawMessage
		if err := json.Unmarshal(v, &next); err != nil {
			return nil, false
		}
		cur = next
	}
	return nil, false
}
