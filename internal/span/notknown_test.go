package span_test

import (
	"encoding/json"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// TestCacheStatusIsMarkedNotKnown haelt SPEC-024 mit der Draht-Form aus SPEC-087: der
// Cache-Status ist Pflicht. Liefert `tool_response.usage` die Zaehler nicht — ein
// `Agent`-Ergebnis ohne `usage`, jedes andere Werkzeug —, steht in beiden Feldern die
// Kennzeichnung mit der Quelle, nie `0`, nie Abwesenheit; mit `usage` stehen die Zahlen.
// Die Erwartung ist die woertliche Zeichenkette der Spezifikation, nicht der Aufruf von
// span.NotKnown — sonst folgte der Waechter einer geaenderten Draht-Form mit.
// LH-FA-13
func TestCacheStatusIsMarkedNotKnown(t *testing.T) {
	const (
		creation = `"cache_creation_input_tokens":"nicht bekannt: tool_response.usage"`
		read     = `"cache_read_input_tokens":"nicht bekannt: tool_response.usage"`
	)
	ohne := map[string]string{
		"Agent ohne usage":     `{"tool_name":"Agent","session_id":"s1","tool_response":{"totalTokens":110,"agentType":"reviewer"}}`,
		"Agent mit usage null": `{"tool_name":"Agent","session_id":"s1","tool_response":{"usage":{"cache_creation_input_tokens":null,"cache_read_input_tokens":null}}}`,
		"Bash":                 `{"tool_name":"Bash","session_id":"s1","tool_input":{"command":"make gates"}}`,
	}
	for name, payload := range ohne {
		t.Run(name, func(t *testing.T) {
			root := newRoot(t)
			emit(t, root, payload)
			line := rawStream(t, root, "s1")
			// Erst die Null: steht sie da, nennt die Meldung die geschriebene Messung statt
			// einer fehlenden Erfassung.
			mustNotContain(t, line, `"cache_creation_input_tokens":0`, `"cache_read_input_tokens":0`)
			mustContain(t, line, creation, read)
		})
	}

	root := newRoot(t)
	emit(t, root, `{"tool_name":"Agent","session_id":"s1","tool_response":{
	  "usage":{"input_tokens":11,"cache_creation_input_tokens":33,"cache_read_input_tokens":0}}}`)
	line := rawStream(t, root, "s1")
	mustContain(t, line, `"cache_creation_input_tokens":33`, `"cache_read_input_tokens":0`)
	mustNotContain(t, line, "nicht bekannt: tool_response.usage")

	// Ein Leser bekommt die gemessene Null als Wert und die Kennzeichnung als *ohne Wert*.
	var s span.Span
	if err := json.Unmarshal([]byte(line), &s); err != nil {
		t.Fatalf("Zeile mit Cache-Zaehlern unlesbar: %v", err)
	}
	if s.CacheReadInputTokens.N == nil || *s.CacheReadInputTokens.N != 0 {
		t.Fatalf("cache_read_input_tokens: gemessene 0 ging beim Lesen verloren: %+v", s.CacheReadInputTokens)
	}
	if err := json.Unmarshal([]byte(`{"cache_creation_input_tokens":"nicht bekannt: tool_response.usage"}`), &s); err != nil {
		t.Fatalf("Zeile mit Kennzeichnung unlesbar: %v", err)
	}
	if s.CacheCreationInputTokens.N != nil {
		t.Fatalf("cache_creation_input_tokens: die Kennzeichnung las sich als Wert %d", *s.CacheCreationInputTokens.N)
	}
	if err := json.Unmarshal([]byte(`{"cache_read_input_tokens":null}`), &s); err != nil {
		t.Fatalf("Zeile mit null unlesbar: %v", err)
	}
	if s.CacheReadInputTokens.N != nil {
		t.Fatalf("cache_read_input_tokens: null las sich als Wert %d", *s.CacheReadInputTokens.N)
	}
}
