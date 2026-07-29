package span_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// newRoot legt eine Repo-Wurzel im Temp-Bereich an. Die Tests setzen die WURZEL, nie
// den Ablageort darunter — der ist eine Konstante (Review-Befund MEDIUM-4).
func newRoot(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	if err := os.MkdirAll(filepath.Join(root, ".git"), 0o700); err != nil {
		t.Fatalf("Wurzel anlegen: %v", err)
	}
	return root
}

func emit(t *testing.T, root, payload string) {
	t.Helper()
	if err := span.Emit(root, []byte(payload), time.Now()); err != nil {
		t.Fatalf("Emit: %v", err)
	}
}

func readLines(t *testing.T, root, stream string) []span.Span {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(root, span.Dir, stream+".jsonl"))
	if err != nil {
		t.Fatalf("Strom lesen: %v", err)
	}
	var out []span.Span
	for _, line := range strings.Split(strings.TrimSpace(string(b)), "\n") {
		if line == "" {
			continue
		}
		var s span.Span
		if err := json.Unmarshal([]byte(line), &s); err != nil {
			t.Fatalf("Zeile ist kein JSON: %v (%q)", err, line)
		}
		out = append(out, s)
	}
	return out
}

// TestFailedStatusFromErrorShapes ist der Review-Befund MEDIUM-5: `error` traegt je
// nach Werkzeug einen String, ein Objekt oder null. Die Vorgaenger-Fassung erkannte
// nur den Top-Level-String und meldete "ok" fuer einen fehlgeschlagenen Aufruf.
func TestFailedStatusFromErrorShapes(t *testing.T) {
	cases := []struct {
		name    string
		payload string
		want    string
	}{
		{"kein error", `{"tool_name":"Bash"}`, "ok"},
		{"error null", `{"tool_name":"Bash","error":null}`, "ok"},
		{"error leerer String", `{"tool_name":"Bash","error":""}`, "ok"},
		{"error String", `{"tool_name":"Bash","error":"boom"}`, "error"},
		{"error Objekt", `{"tool_name":"Bash","error":{"message":"boom"}}`, "error"},
		{"error Array", `{"tool_name":"Bash","error":["boom"]}`, "error"},
		{"Fehlschlag-Ereignis ohne error-Feld",
			`{"tool_name":"Bash","hook_event_name":"PostToolUseFailure"}`, "error"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			p, err := span.Parse([]byte(tc.payload))
			if err != nil {
				t.Fatalf("Parse: %v", err)
			}
			got := span.Build(p, t.TempDir(), time.Now()).Status
			if got != tc.want {
				t.Fatalf("status = %q, erwartet %q", got, tc.want)
			}
		})
	}
}

// TestUnknownToolStaysSilent misst die EIGENSCHAFT des fail-closed Defaults, nicht
// ihre heutige Umsetzung (Review-Befund HIGH-2): jede Payload hier traegt Felder, die
// ein GELISTETES Werkzeug preisgeben wuerde. Haengt die Erfassung wieder am
// Feld-Namen statt am Werkzeug-Namen, faellt dieser Test.
func TestUnknownToolStaysSilent(t *testing.T) {
	payloads := []string{
		`{"tool_name":"mcp__db__run","tool_input":{"command":"psql -c 'select 1'"}}`,
		`{"tool_name":"mcp__fs__put","tool_input":{"file_path":"/etc/shadow"}}`,
		`{"tool_name":"Task","tool_input":{"command":"deploy --prod","file_path":"/tmp/x"}}`,
		`{"tool_name":"","tool_input":{"command":"rm -rf /","file_path":"/tmp/y"}}`,
		`{"tool_input":{"command":"curl https://evil.example","file_path":"/tmp/z"}}`,
	}
	for _, payload := range payloads {
		t.Run(payload, func(t *testing.T) {
			p, err := span.Parse([]byte(payload))
			if err != nil {
				t.Fatalf("Parse: %v", err)
			}
			s := span.Build(p, t.TempDir(), time.Now())
			if s.Path != "" || s.Program != "" || s.Argc != nil || s.Bytes != nil {
				t.Fatalf("unbekanntes Werkzeug gab Argumente preis: %+v", s)
			}
			if s.Status == "" {
				t.Fatal("Name und Status muessen erhalten bleiben")
			}
		})
	}
}

// TestCommandProgramSkipsAssignments deckt zwei Befunde: HIGH-7 (eine
// Inline-Env-Zuweisung landete verbatim als "program") und LOW-2 (argc zaehlte
// Felder statt Argumente).
func TestCommandProgramSkipsAssignments(t *testing.T) {
	cases := []struct {
		cmd      string
		program  string
		argc     int
		captured bool
	}{
		{"ls -l /tmp", "ls", 2, true},
		{"  ls -l", "ls", 1, true},
		{"GITHUB_TOKEN=ghp_SECRET_abc123 gh pr create", "gh", 2, true},
		{"A=1 B=2 make gates", "make", 1, true},
		{"GITHUB_TOKEN=ghp_SECRET_abc123", "", 0, false},
		{"FOO=bar BAZ=qux", "", 0, false},
		{"", "", 0, false},
	}
	for _, tc := range cases {
		t.Run(tc.cmd, func(t *testing.T) {
			p := span.Payload{Tool: "Bash", Input: span.ToolInput{Command: tc.cmd}}
			d := span.Derive(p)
			if d.Program != tc.program {
				t.Fatalf("program = %q, erwartet %q", d.Program, tc.program)
			}
			if d.HasArgc != tc.captured {
				t.Fatalf("HasArgc = %v, erwartet %v", d.HasArgc, tc.captured)
			}
			if tc.captured && d.Argc != tc.argc {
				t.Fatalf("argc = %d, erwartet %d", d.Argc, tc.argc)
			}
			if strings.Contains(d.Program, "SECRET") {
				t.Fatalf("Geheimnis im Span: %q", d.Program)
			}
		})
	}
}

// TestReadToolGetsPathOnly ist der Review-Befund MEDIUM-1: ein Fingerabdruck auf
// einem GELESENEN Pfad waere ein Bestaetigungs-Orakel ohne Incident-Frage.
func TestReadToolGetsPathOnly(t *testing.T) {
	root := newRoot(t)
	file := filepath.Join(root, "geheim.txt")
	if err := os.WriteFile(file, []byte("inhalt"), 0o600); err != nil {
		t.Fatal(err)
	}
	p := span.Payload{Tool: "Read", Input: span.ToolInput{FilePath: file}}
	s := span.Build(p, root, time.Now())
	if s.Path != file {
		t.Fatalf("path = %q, erwartet %q", s.Path, file)
	}
	if s.Bytes != nil || s.Sha256Prefix != "" {
		t.Fatalf("Lese-Werkzeug bekam einen Fingerabdruck: %+v", s)
	}
}

// TestWriteToolGetsFingerprintFromFilesystem: Laenge und Hash kommen aus dem
// DATEISYSTEM, nicht aus der Payload.
func TestWriteToolGetsFingerprintFromFilesystem(t *testing.T) {
	root := newRoot(t)
	file := filepath.Join(root, "ziel.txt")
	if err := os.WriteFile(file, []byte("abcdef"), 0o600); err != nil {
		t.Fatal(err)
	}
	p := span.Payload{Tool: "Write", Input: span.ToolInput{FilePath: file}}
	s := span.Build(p, root, time.Now())
	if s.Bytes == nil || *s.Bytes != 6 {
		t.Fatalf("bytes falsch: %+v", s.Bytes)
	}
	if len(s.Sha256Prefix) != 16 {
		t.Fatalf("sha256_16 = %q", s.Sha256Prefix)
	}
}

// TestNoPayloadContentReachesSpan ist der Kanarienvogel: eine Write-Payload traegt
// den vollen Datei-Inhalt. Aus ihr darf NUR der Pfad in den Span kommen.
func TestNoPayloadContentReachesSpan(t *testing.T) {
	root := newRoot(t)
	payload := `{"tool_name":"Write","session_id":"s1",
	  "tool_input":{"file_path":"/tmp/x.txt","content":"AWS_SECRET_ACCESS_KEY=abc123",
	  "old_string":"passwort=hunter2","new_string":"passwort=hunter3"}}`
	emit(t, root, payload)
	b, err := os.ReadFile(filepath.Join(root, span.Dir, "s1.jsonl"))
	if err != nil {
		t.Fatal(err)
	}
	for _, forbidden := range []string{"abc123", "hunter2", "hunter3", "AWS_SECRET"} {
		if strings.Contains(string(b), forbidden) {
			t.Fatalf("Payload-Inhalt %q steht im Span: %s", forbidden, b)
		}
	}
	if !strings.Contains(string(b), "/tmp/x.txt") {
		t.Fatalf("Pfad fehlt: %s", b)
	}
}

// TestSeqIsAssignedNotDerived ist der Review-Befund HIGH-3: waere die Nummer aus dem
// Bestand abgeleitet (`wc -l + 1`), waere eine Luecke konstruktiv unmoeglich — der
// Leser saehe Vollstaendigkeit, wo Spans fehlen.
func TestSeqIsAssignedNotDerived(t *testing.T) {
	root := newRoot(t)
	for range 3 {
		emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	}
	// Zeilen gehen verloren (Absturz, Aufraeumen, abgeschnittene Datei).
	if err := os.Truncate(filepath.Join(root, span.Dir, "s1.jsonl"), 0); err != nil {
		t.Fatal(err)
	}
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	got := readLines(t, root, "s1")
	if len(got) != 1 || got[0].Seq != 4 {
		t.Fatalf("seq = %+v, erwartet einen Eintrag mit seq 4 (Luecke sichtbar)", got)
	}
}

// TestConcurrentEmittersGetDistinctSeq: Nummernvergabe und Anhaengen sind unter
// DERSELBEN Sperre eine Einheit.
func TestConcurrentEmittersGetDistinctSeq(t *testing.T) {
	root := newRoot(t)
	const n = 8
	var wg sync.WaitGroup
	for range n {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if err := span.Emit(root, []byte(`{"tool_name":"Bash","session_id":"s1"}`), time.Now()); err != nil {
				t.Errorf("Emit: %v", err)
			}
		}()
	}
	wg.Wait()
	got := readLines(t, root, "s1")
	if len(got) != n {
		t.Fatalf("%d Zeilen, erwartet %d", len(got), n)
	}
	seen := map[int]bool{}
	for _, s := range got {
		if seen[s.Seq] {
			t.Fatalf("doppelte Folgenummer %d", s.Seq)
		}
		seen[s.Seq] = true
	}
}

// TestModeIsOwnerOnly deckt LOW-3: der Modus steht vor dem ersten Byte, und ein
// bestehender Strom mit zu weitem Modus wird korrigiert.
func TestModeIsOwnerOnly(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	file := filepath.Join(root, span.Dir, "s1.jsonl")
	fi, err := os.Stat(file)
	if err != nil {
		t.Fatal(err)
	}
	if fi.Mode().Perm() != 0o600 {
		t.Fatalf("Modus = %v, erwartet 0600", fi.Mode().Perm())
	}
	if err := os.Chmod(file, 0o644); err != nil {
		t.Fatal(err)
	}
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	fi, err = os.Stat(file)
	if err != nil {
		t.Fatal(err)
	}
	if fi.Mode().Perm() != 0o600 {
		t.Fatalf("zu weiter Modus wurde nicht korrigiert: %v", fi.Mode().Perm())
	}
}

// TestSpansLandInStateDir haelt die Kopplung an den gitignorierten Ort fest
// (Review-Befund MEDIUM-4). Die zweite Haelfte der Eigenschaft — dass .gitignore
// genau diesen Ort deckt — misst harness/tools/span-check.sh am realen Repo.
func TestSpansLandInStateDir(t *testing.T) {
	if span.Dir != ".harness/state/spans" {
		t.Fatalf("Ablageort = %q; er muss unter dem gitignorierten Zustands-Bereich liegen", span.Dir)
	}
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	if _, err := os.Stat(filepath.Join(root, ".harness", "state", "spans", "s1.jsonl")); err != nil {
		t.Fatalf("Span liegt nicht im Zustands-Bereich: %v", err)
	}
}

// TestStreamsAreSeparate: der Strom ist (Sitzung, Agent).
func TestStreamsAreSeparate(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1","agent_id":"a1"}`)
	for _, stream := range []string{"s1", "s1-a1"} {
		if got := readLines(t, root, stream); len(got) != 1 || got[0].Seq != 1 {
			t.Fatalf("Strom %s: %+v", stream, got)
		}
	}
}

// TestStreamNameCannotEscapeDirectory: eine Sitzungs-Kennung ist Fremd-Eingabe.
// Gemessen wird die EIGENSCHAFT — bleibt der reale Pfad im Ablageort? —, nicht die
// Zeichenmenge: Punkte sind ohne Pfad-Trenner harmlos.
func TestStreamNameCannotEscapeDirectory(t *testing.T) {
	const base = "/base"
	for _, session := range []string{"../../etc/passwd", "a/b", "..", "/abs", "~/x"} {
		name := span.StreamName(span.Payload{Session: session})
		full := filepath.Clean(filepath.Join(base, name+".jsonl"))
		if filepath.Dir(full) != base {
			t.Fatalf("Sitzung %q ergibt %q und verlaesst den Ablageort", session, full)
		}
	}
}

// TestCorrelationFromLifecycle: slice.id IST das Lifecycle-Verzeichnis (Modul 5),
// requirement.id kommt NUR aus dem Bezug-Block (Review-Befund MEDIUM-2).
func TestCorrelationFromLifecycle(t *testing.T) {
	root := newRoot(t)
	dir := filepath.Join(root, "docs/plan/planning/in-progress")
	if err := os.MkdirAll(dir, 0o700); err != nil {
		t.Fatal(err)
	}
	slice := "**Bezug:** LH-QA-01 und LH-FA-02.\n\nFliesstext nennt LH-XX-99 als Abgrenzung.\n"
	if err := os.WriteFile(filepath.Join(dir, "slice-042-beispiel.md"), []byte(slice), 0o600); err != nil {
		t.Fatal(err)
	}
	s := span.Build(span.Payload{Tool: "Bash"}, root, time.Now())
	if len(s.Slice) != 1 || s.Slice[0] != "slice-042-beispiel" {
		t.Fatalf("slice = %v", s.Slice)
	}
	if strings.Join(s.Requirement, ",") != "LH-FA-02,LH-QA-01" {
		t.Fatalf("requirement = %v (nur der Bezug-Block zaehlt)", s.Requirement)
	}
}

// TestCorrelationEmptyIsRecognisable: kein Slice in in-progress ergibt eine LEERE
// Liste, die als leer erkennbar ist — nicht ein geratener Wert und nicht `null`.
func TestCorrelationEmptyIsRecognisable(t *testing.T) {
	root := newRoot(t)
	b, err := json.Marshal(span.Build(span.Payload{Tool: "Bash"}, root, time.Now()))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(b), `"slice":[]`) || !strings.Contains(string(b), `"requirement":[]`) {
		t.Fatalf("leere Korrelation ist nicht als leer erkennbar: %s", b)
	}
}

// TestGitRefFromHead: Branch und Commit sind die Korrelations-Achse, ueber die eine
// Auswertung den PR nachschlaegt (die PR-Nummer selbst ist im Hook nicht erreichbar).
func TestGitRefFromHead(t *testing.T) {
	root := newRoot(t)
	git := filepath.Join(root, ".git")
	if err := os.MkdirAll(filepath.Join(git, "refs/heads"), 0o700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(git, "HEAD"), []byte("ref: refs/heads/welle-09\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	sha := "0123456789abcdef0123456789abcdef01234567"
	if err := os.WriteFile(filepath.Join(git, "refs/heads/welle-09"), []byte(sha+"\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	s := span.Build(span.Payload{Tool: "Bash"}, root, time.Now())
	if s.Branch != "welle-09" {
		t.Fatalf("branch = %q", s.Branch)
	}
	if s.Commit != sha[:12] {
		t.Fatalf("commit = %q", s.Commit)
	}
}

// TestStaleLockIsBroken: ein zwischen Mkdir und Remove getoeteter Prozess legte den
// Strom sonst DAUERHAFT still — unsichtbar, weil ohne beanspruchte Nummer keine
// Luecke entsteht.
func TestStaleLockIsBroken(t *testing.T) {
	root := newRoot(t)
	dir := filepath.Join(root, span.Dir)
	if err := os.MkdirAll(dir, 0o700); err != nil {
		t.Fatal(err)
	}
	lock := filepath.Join(dir, ".s1.lock")
	if err := os.Mkdir(lock, 0o700); err != nil {
		t.Fatal(err)
	}
	old := time.Now().Add(-10 * time.Minute)
	if err := os.Chtimes(lock, old, old); err != nil {
		t.Fatal(err)
	}
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	if got := readLines(t, root, "s1"); len(got) != 1 {
		t.Fatalf("liegengebliebenes Schloss hat den Strom stillgelegt: %+v", got)
	}
}

// TestNoRootNoSpan: ohne Repo-Wurzel raet der Emitter keinen Ablageort.
func TestNoRootNoSpan(t *testing.T) {
	if _, ok := span.FindRoot(t.TempDir()); ok {
		t.Fatal("FindRoot fand eine Wurzel, wo keine ist")
	}
}

// TestMandatoryFieldsAlwaysPresent haelt die PFLICHT-Spalte aus MR-018 fest: ein
// Pflichtfeld steht auch dann in der Zeile, wenn sein Wert leer ist. Ein
// `omitempty` an der falschen Stelle liesse es lautlos verschwinden, und der Leser
// saehe nicht das Fehlen, sondern gar nichts — die Zeile bliebe wohlgeformt.
func TestMandatoryFieldsAlwaysPresent(t *testing.T) {
	p, err := span.Parse([]byte(`{}`))
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	b, err := json.Marshal(span.Build(p, t.TempDir(), time.Now()))
	if err != nil {
		t.Fatal(err)
	}
	for _, feld := range []string{
		`"seq":`, `"ts":`, `"event":`, `"tool":`, `"tool_use_id":`,
		`"session":`, `"agent":`, `"slice":`, `"requirement":`, `"status":`,
	} {
		if !strings.Contains(string(b), feld) {
			t.Fatalf("Pflichtfeld %s fehlt in einem Span mit leeren Werten: %s", feld, b)
		}
	}
}
