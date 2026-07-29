// Package span erfasst je Tool-Call eines Agenten-Werkzeugs EINEN Span und haengt ihn
// an den Strom seiner Sitzung an. Es setzt ADR-0011 um; die Policy steht dort, hier
// steht nur die Mechanik.
//
// WARUM GO UND NICHT bash+awk (slice-059, nach Messung): der Emitter ist FAIL-OPEN.
// Der PreToolUse-Guard darf bei Unsicherheit blocken und faengt damit jede Luecke
// seines handgefuehrten Scanners auf; die Telemetrie hat diese Kompensation nicht —
// sie verliert im Zweifel still ihre eigene Aussage. Genau das trat ein: die
// awk-Fassung erkannte `error` nur als Top-Level-String und meldete "ok" fuer einen
// fehlgeschlagenen Aufruf. Hier parst encoding/json, und das geschlossene Schema ist
// ein Typ statt einer Kette von Sonderfaellen.
//
// ZWEI EIGENSCHAFTEN SIND NICHT VERHANDELBAR (ADR-0011 Festlegung 6): stdout bleibt
// leer (dort liegt bei Hooks der ENTSCHEIDUNGS-Kanal) und der Exit-Code ist 0. Beides
// stellt cmd/span-emit her — dieses Paket gibt Fehler normal zurueck, damit sie
// TESTBAR sind, statt sie hier schon zu schlucken.
package span

import (
	"bytes"
	"encoding/json"
	"strings"
)

// Payload ist das GESCHLOSSENE Schema (ADR-0011 Festlegung 1.3): hier steht
// vollstaendig, was aus einer Hook-Payload ueberhaupt gelesen wird. Ein neues Feld
// einer kuenftigen Werkzeug-Version wird NICHT still mitgeschrieben — es muesste in
// Parse eingetragen werden, und das ist eine Entscheidung, kein Nebeneffekt.
type Payload struct {
	Event          string
	Tool           string
	ToolUseID      string
	Session        string
	Agent          string
	AgentType      string
	Transcript     string
	PermissionMode string
	Input          ToolInput
	Failed         bool

	// DurationMS und ResultBytes stammen aus einer MESSUNG an einer echten Payload
	// (2026-07-29), nicht aus der Werkzeug-Doku: sie traegt `duration_ms` und
	// `tool_response`. Die Doku nennt fuer das Ergebnis `tool_output`; der Slice-Plan
	// hatte `tool_response` stehen und "korrigierte" es zu `tool_output` — die
	// Korrektur ging von der Doku aus und lag daneben.
	DurationMS  int64
	ResultBytes int64
	HasDuration bool
	HasResult   bool
}

// ToolInput traegt die drei Felder, aus denen ueberhaupt abgeleitet wird. Der
// Kommando-REST und jeder Datei-INHALT (`content`, `new_string`, …) stehen hier
// bewusst nicht: was nicht gelesen wird, kann nicht ins Log geraten
// (ADR-0011 Festlegung 2).
type ToolInput struct {
	FilePath     string `json:"file_path"`
	NotebookPath string `json:"notebook_path"`
	Command      string `json:"command"`
}

// Parse liest die Hook-Payload TOLERANT: ein Feld mit unerwartetem Typ kostet dieses
// Feld, nicht den ganzen Span. Ein strikt typisiertes Struct wuerde bei einer
// einzigen Typ-Abweichung die gesamte Erfassung verlieren — fuer einen fail-open
// Sensor der falsche Ausgang.
func Parse(b []byte) (Payload, error) {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(b, &raw); err != nil {
		return Payload{}, err
	}
	p := Payload{
		Event:          rawString(raw, "hook_event_name"),
		Tool:           rawString(raw, "tool_name"),
		ToolUseID:      rawString(raw, "tool_use_id"),
		Session:        rawString(raw, "session_id"),
		Agent:          rawString(raw, "agent_id"),
		AgentType:      rawString(raw, "agent_type"),
		Transcript:     rawString(raw, "transcript_path"),
		PermissionMode: rawString(raw, "permission_mode"),
	}
	if in, ok := raw["tool_input"]; ok {
		// Fehler bewusst verworfen: ist `tool_input` kein Objekt, bleiben die
		// abgeleiteten Werte leer — der Span selbst entsteht trotzdem.
		_ = json.Unmarshal(in, &p.Input)
	}
	// Die DAUER kommt fertig aus der Payload — es braucht dafuer keinen zweiten Hook
	// auf PreToolUse, wie zuerst angenommen.
	if v, ok := raw["duration_ms"]; ok {
		var ms int64
		if err := json.Unmarshal(v, &ms); err == nil {
			p.DurationMS, p.HasDuration = ms, true
		}
	}
	// Vom ERGEBNIS wird ausschliesslich die LAENGE genommen, nie der Inhalt — dieselbe
	// Linie wie bei `tool_input` (ADR-0011 Festlegung 2). Gemessen wird die Groesse,
	// wie die Payload sie traegt.
	if v, ok := raw["tool_response"]; ok {
		p.ResultBytes, p.HasResult = int64(len(v)), true
	}
	p.Failed = failed(raw, p.Event)
	return p, nil
}

func rawString(raw map[string]json.RawMessage, key string) string {
	v, ok := raw[key]
	if !ok {
		return ""
	}
	var s string
	if err := json.Unmarshal(v, &s); err != nil {
		return ""
	}
	return s
}

// failed entscheidet den Status aus ZWEI Quellen, und das ist der Kern des
// Review-Befunds MEDIUM-5: `error` traegt je nach Werkzeug einen String, ein Objekt
// oder null. Auf den TYP zu pruefen war der Fehler — hier zaehlt "vorhanden und nicht
// leer". Dazu das Ereignis selbst: ein Fehlschlag-Event ist auch ohne `error`-Feld
// ein Fehlschlag. Bewacht von TestFailedStatusFromErrorShapes.
func failed(raw map[string]json.RawMessage, event string) bool {
	if strings.Contains(event, "Failure") {
		return true
	}
	v, ok := raw["error"]
	if !ok {
		return false
	}
	trimmed := bytes.TrimSpace(v)
	if len(trimmed) == 0 || bytes.Equal(trimmed, []byte("null")) {
		return false
	}
	// Ein leerer String ist kein Fehler; jede andere Form (Objekt, Array, Zahl,
	// nicht-leerer String) ist einer.
	var s string
	if err := json.Unmarshal(trimmed, &s); err == nil {
		return s != ""
	}
	return true
}

// class ist die ACHSE des fail-closed Defaults: der WERKZEUG-NAME, nicht der
// Feld-Name. Die Unterscheidung ist der Review-Befund HIGH-1 — haengt die Erfassung
// am Feld, gibt jedes unbekannte Werkzeug, das zufaellig `command` fuehrt, seine
// Argumente preis (gemessen: `mcp__db__run` lieferte `"program":"psql"`).
type class int

const (
	classNone class = iota
	classFileRead
	classFileWrite
	classCommand
)

func toolClass(tool string) class {
	switch tool {
	case "Write", "Edit", "MultiEdit", "NotebookEdit":
		return classFileWrite
	case "Read":
		return classFileRead
	case "Bash":
		return classCommand
	// `BashOutput` steht hier BEWUSST NICHT: seine Eingabe ist eine Shell-Kennung,
	// keine Kommandozeile — es faellt damit auf den fail-closed Default und gibt nur
	// Name und Status preis. Es zu listen war eine Zusage, die strukturell nie
	// eintreten konnte (Review Runde 2, LOW-7).
	default:
		// Der Default (ADR-0011 Festlegung 2): was nicht namentlich in der
		// MR-018-Tabelle steht, gibt NUR Name und Status preis.
		return classNone
	}
}

// Derived sind die abgeleiteten Argument-Werte — nie die rohen.
type Derived struct {
	Path    string
	Program string
	Argc    int
	HasArgc bool
}

// Derive bildet die MR-018-Tabelle ab: Datei-Werkzeuge geben den Pfad, Kommando-
// Werkzeuge das Programm-Token und die Argument-Anzahl, alles andere nichts.
func Derive(p Payload) Derived {
	switch toolClass(p.Tool) {
	case classFileRead, classFileWrite:
		return Derived{Path: filePath(p.Input)}
	case classCommand:
		prog, argc, ok := commandProgram(p.Input.Command)
		if !ok {
			return Derived{}
		}
		return Derived{Program: prog, Argc: argc, HasArgc: true}
	default:
		return Derived{}
	}
}

func filePath(in ToolInput) string {
	if in.FilePath != "" {
		return in.FilePath
	}
	return in.NotebookPath
}

// commandProgram zieht das PROGRAMM aus einer Kommandozeile — nicht schlicht das
// erste Feld. Eine Zeile darf mit Zuweisungen beginnen, und deren WERTE sind oft
// genau das, was nie ins Log darf (Review-Befund HIGH-7: `GITHUB_TOKEN=ghp_… gh pr
// create` landete verbatim als "program"). Fuehrende NAME=WERT-Praefixe werden
// uebersprungen; bleibt danach etwas mit `=` uebrig, wird GAR NICHTS ausgegeben.
// Bewacht von TestCommandProgramSkipsAssignments.
func commandProgram(cmd string) (string, int, bool) {
	// strings.Fields verwirft fuehrenden Leerraum, statt ein leeres erstes Feld zu
	// erzeugen — der Review-Befund LOW-2 ("  ls -l" ergab argc 2 statt 1).
	fields := strings.Fields(cmd)
	for i, f := range fields {
		if isAssignment(f) {
			continue
		}
		if strings.Contains(f, "=") {
			return "", 0, false
		}
		return f, len(fields) - i - 1, true
	}
	return "", 0, false
}

func isAssignment(field string) bool {
	eq := strings.Index(field, "=")
	if eq <= 0 {
		return false
	}
	for i, r := range field[:eq] {
		valid := (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || r == '_' ||
			(i > 0 && r >= '0' && r <= '9')
		if !valid {
			return false
		}
	}
	return true
}
