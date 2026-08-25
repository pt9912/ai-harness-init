package main

import (
	"bytes"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// childEnv schaltet den Kind-Prozess frei. Die Klemme ist eine PROZESS-Eigenschaft
// (Exit-Code, stdout) und nur an einem echten Prozess messbar — ein Aufruf im
// Test-Prozess koennte sie nicht pruefen, weil os.Exit den Test selbst beendete.
const childEnv = "HARNESS_SUBCMD_CHILD"

// TestMain faengt das Kind ab, BEVOR das Test-Framework laeuft. Diese Stelle ist
// nicht Stil, sondern Schadensbegrenzung: stand die Abzweigung im Test-RUMPF, lief
// das Kind nach einem zurueckkehrenden main() in denselben Rumpf weiter und startete
// ein weiteres Kind — eine unbegrenzte Rekursion. Genau das trat ein, als Mutation
// 107 die Klemme entfernte: mit gueltiger Payload kehrte main() normal zurueck, und
// der Mutations-Lauf legte den Rechner lahm (vom Auftraggeber diagnostiziert).
// Hier kann das Kind den Rumpf konstruktiv nicht erreichen.
//
// Das Kind ruft main() und laeuft damit durch den REALEN Unterkommando-Zweig: seine
// Argumente sind die des Kind-Prozesses, nicht die des Test-Werkzeugs.
func TestMain(m *testing.M) {
	if os.Getenv(childEnv) == "1" {
		main()
		// Erreichbar NUR ohne Klemme. Der Schreiber endet sonst in clamp().
		os.Exit(0)
	}
	os.Exit(m.Run())
}

// runChild startet dieses Test-Binary als Kind, mit dem Unterkommando als Argument.
// Kein -test.run noetig: TestMain zweigt vor dem Framework ab, das Kind IST also der
// Traeger.
func runChild(t *testing.T, dir, sub, stdin string) (string, error) {
	t.Helper()
	cmd := exec.Command(os.Args[0], sub)
	cmd.Env = append(os.Environ(), childEnv+"=1")
	cmd.Dir = dir
	cmd.Stdin = strings.NewReader(stdin)
	var stdout bytes.Buffer
	cmd.Stdout = &stdout
	err := cmd.Run()
	return stdout.String(), err
}

func newRoot(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	if err := os.MkdirAll(filepath.Join(root, ".git"), 0o700); err != nil {
		t.Fatalf("Wurzel anlegen: %v", err)
	}
	return root
}

// TestClampSurvivesBrokenPayload misst die zwei nicht verhandelbaren Eigenschaften
// aus ADR-0011 Festlegung 6 an einem kaputten JSON: Exit 0 und leeres stdout. Ohne
// die Klemme endet derselbe Aufruf mit Exit 2 — dem Wert, mit dem ein Hook den
// Tool-Call BLOCKT. test/mutations/107-span-klemme-entfernt.sh nimmt sie weg,
// test/mutations/154-unterkommando-routing-vertauscht.sh haengt den Zweig um.
func TestClampSurvivesBrokenPayload(t *testing.T) {
	stdout, err := runChild(t, newRoot(t), "span-emit", "{ das ist kein json")
	if err != nil {
		t.Fatalf("Schreiber endete nicht mit 0: %v", err)
	}
	if stdout != "" {
		t.Fatalf("stdout ist der Entscheidungs-Kanal und muss leer bleiben: %q", stdout)
	}
}

// TestEmitWritesSpanFromHook fuehrt den Weg, den der Hook geht: Unterkommando
// `span-emit`, Payload auf stdin, Span im gitignorierten Zustands-Bereich.
func TestEmitWritesSpanFromHook(t *testing.T) {
	root := newRoot(t)
	payload := `{"hook_event_name":"PostToolUse","tool_name":"Bash","session_id":"s1",
	  "tool_use_id":"tu_1","tool_input":{"command":"make gates"}}`
	stdout, err := runChild(t, root, "span-emit", payload)
	if err != nil {
		t.Fatalf("Schreiber endete nicht mit 0: %v", err)
	}
	if stdout != "" {
		t.Fatalf("stdout nicht leer: %q", stdout)
	}
	b, err := os.ReadFile(filepath.Join(root, ".harness", "state", "spans", "s1.jsonl"))
	if err != nil {
		t.Fatalf("kein Span geschrieben: %v", err)
	}
	for _, want := range []string{`"tool":"Bash"`, `"program":"make"`, `"seq":1`, `"status":"ok"`} {
		if !strings.Contains(string(b), want) {
			t.Fatalf("%s fehlt im Span: %s", want, b)
		}
	}
}

// TestSubkommandoRouting_ReportSchreibtBilanz misst die ANDERE Haelfte des
// Einstiegspunkts als Prozess: `span-report` erreicht die Auswertung, nicht den Init
// und nicht den Schreiber. Ohne den Zweig liefe das Argument in den Init-Pfad, und
// die Bilanz erschiene nie.
func TestSubkommandoRouting_ReportSchreibtBilanz(t *testing.T) {
	root := newRoot(t)
	stdout, err := runChild(t, root, "span-report", "")
	if err != nil {
		t.Fatalf("Bericht endete nicht mit 0: %v", err)
	}
	if !strings.Contains(stdout, "Subagenten-Laeufe") {
		t.Fatalf("keine Bilanz auf stdout: %q", stdout)
	}
}
