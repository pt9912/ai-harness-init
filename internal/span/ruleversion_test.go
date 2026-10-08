package span_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// TestSpanCarriesCurrentRuleVersion haelt SPEC-088: jede geschriebene Zeile traegt die
// Fassung, unter der sie entstand, als Zahl ab 1. Eine Zeile ohne das Feld oder mit `0`
// liest jeder Leser als *Fassung nicht bekannt* — der Fall, den der Emitter nie
// erzeugen darf. Geprueft an der Zeile, die Build schreibt, nicht an der Konstante.
func TestSpanCarriesCurrentRuleVersion(t *testing.T) {
	if span.CurrentRuleVersion < 1 {
		t.Fatalf("CurrentRuleVersion %d: eine Fassung zaehlt ab 1, 0 heisst nicht bekannt", span.CurrentRuleVersion)
	}
	for name, payload := range map[string]string{
		"leere Payload": `{}`,
		"Bash":          `{"tool_name":"Bash","session_id":"s1","tool_input":{"command":"make gates"}}`,
		"Agent":         `{"tool_name":"Agent","session_id":"s1","tool_response":{"usage":{"input_tokens":1}}}`,
	} {
		p, err := span.Parse([]byte(payload))
		if err != nil {
			t.Fatalf("%s: Parse: %v", name, err)
		}
		b, err := json.Marshal(span.Build(p, t.TempDir(), time.Now()))
		if err != nil {
			t.Fatal(err)
		}
		want := `"rule_version":` + strconv.Itoa(span.CurrentRuleVersion) + `,`
		if !strings.Contains(string(b), want) {
			t.Fatalf("%s: die Zeile traegt nicht die laufende Fassung %s: %s", name, want, b)
		}
	}
}

// TestCurrentRuleVersionIsTheLastSpecFassung haelt die Konstante an die Fassungs-Tabelle
// der Spezifikation (SPEC-089): die Tabelle zaehlt lueckenlos ab 1, und ihre letzte
// Fassung ist die, die der Traeger schreibt. Wer die Konstante hochzaehlt, ohne die
// Fassung zu beschreiben, oder eine Fassung beschreibt, ohne sie zu schreiben, faellt hier.
// Ob ein Bedeutungswechsel ueberhaupt als solcher erkannt und hochgezaehlt wurde, misst
// dieser Test nicht.
func TestCurrentRuleVersionIsTheLastSpecFassung(t *testing.T) {
	roh, err := os.ReadFile(filepath.Join("..", "..", "spec", "spezifikation.md"))
	if err != nil {
		t.Fatalf("Spezifikation lesen: %v", err)
	}
	// Eine Zeile der Fassungs-Tabelle: Kennung, dann die Zelle `Fassung <N>`.
	fassungsZeile := regexp.MustCompile("^\\| `SPEC-[0-9]{3}` \\| Fassung ([0-9]+) \\|")
	var fassungen []int
	for _, zeile := range strings.Split(string(roh), "\n") {
		if m := fassungsZeile.FindStringSubmatch(zeile); m != nil {
			n, _ := strconv.Atoi(m[1])
			fassungen = append(fassungen, n)
		}
	}
	if len(fassungen) == 0 {
		t.Fatal("die Spezifikation fuehrt keine Fassungs-Tabelle (Zeilen `| `SPEC-NNN` | Fassung N |`)")
	}
	for i, n := range fassungen {
		if n != i+1 {
			t.Fatalf("die Fassungs-Tabelle zaehlt nicht lueckenlos ab 1: Zeile %d nennt Fassung %d", i+1, n)
		}
	}
	if letzte := fassungen[len(fassungen)-1]; letzte != span.CurrentRuleVersion {
		t.Fatalf("die letzte Fassung der Spezifikation ist %d, der Traeger schreibt %d", letzte, span.CurrentRuleVersion)
	}
}
