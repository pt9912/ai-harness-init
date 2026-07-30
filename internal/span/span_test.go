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
// den Ablageort darunter — der ist eine Konstante.
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

// TestFailedStatusFromErrorShapes haelt fest: `error` traegt je
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
// ihre heutige Umsetzung: jede Payload hier traegt Felder, die
// ein GELISTETES Werkzeug preisgeben wuerde. Haengt die Erfassung wieder am
// Feld-Namen statt am Werkzeug-Namen, faellt dieser Test.
func TestUnknownToolStaysSilent(t *testing.T) {
	payloads := []string{
		`{"tool_name":"mcp__db__run","tool_input":{"command":"psql -c 'select 1'"}}`,
		`{"tool_name":"mcp__fs__put","tool_input":{"file_path":"/etc/shadow"}}`,
		`{"tool_name":"Task","tool_input":{"command":"deploy --prod","file_path":"/tmp/x"}}`,
		`{"tool_name":"","tool_input":{"command":"rm -rf /","file_path":"/tmp/y"}}`,
		`{"tool_input":{"command":"curl https://evil.example","file_path":"/tmp/z"}}`,
		// BashOutput sieht aus wie ein Kommando-Werkzeug, ist aber keins: seine
		// Eingabe ist eine Shell-Kennung. Es gehoert deshalb NICHT in die Tabelle: ein
		// Kommando-Eintrag dafuer waere eine Zusage, die strukturell nie eintreten kann.
		`{"tool_name":"BashOutput","tool_input":{"command":"rm -rf /","bash_id":"x"}}`,
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

// TestCommandProgramSkipsAssignments deckt zwei Faelle: eine Inline-Env-Zuweisung, die
// sonst verbatim als "program" landet, und argc, das sonst Felder statt Argumente
// zaehlt.
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

// TestReadToolGetsPathOnly haelt fest: ein Fingerabdruck auf
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

// TestSeqIsAssignedNotDerived haelt fest: waere die Nummer aus dem
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

// TestModeIsOwnerOnly deckt: der Modus steht vor dem ersten Byte, und ein
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

// TestSpansLandInStateDir haelt die Kopplung an den gitignorierten Ort fest.
// Die zweite Haelfte der Eigenschaft — dass .gitignore
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

// TestDurationAndResultSize misst die zwei Achsen, die am 2026-07-29 gefehlt haben:
// ohne Dauer war "liefen zwei Agenten gleichzeitig?" nicht entscheidbar, ohne
// Ergebnis-Groesse "hat ein einzelner Aufruf den Speicher gesprengt?". Beide stehen in
// der Payload — gemessen, nicht aus der Doku uebernommen.
func TestDurationAndResultSize(t *testing.T) {
	p, err := span.Parse([]byte(`{"tool_name":"Bash","duration_ms":1234,
	  "tool_response":"AWS_SECRET_ACCESS_KEY=abc123 und noch mehr Ausgabe"}`))
	if err != nil {
		t.Fatal(err)
	}
	s := span.Build(p, t.TempDir(), time.Now())
	if s.DurationMS == nil || *s.DurationMS != 1234 {
		t.Fatalf("duration_ms = %v, erwartet 1234", s.DurationMS)
	}
	if s.ResultBytes == nil || *s.ResultBytes <= 0 {
		t.Fatalf("result_bytes fehlt: %v", s.ResultBytes)
	}
	// Und der Kanarienvogel: aus dem Ergebnis erreicht bei `Bash` NUR die Laenge den
	// Span. Die frueher hier stehende unqualifizierte Fassung („vom Ergebnis darf NUR
	// die Laenge in den Span") ist seit slice-060 DoD (2) falsch — bei `Agent` erreichen
	// zusaetzlich die neun Werte der Positiv-Liste den Span (MR-018). Fuer JEDES
	// Werkzeug gilt die Laenge, darueber hinaus nur die Positiv-Liste bei `Agent`
	// (`make comment-claims` kann es nicht fangen,
	// es nimmt `_test.go` aus).
	b, err := json.Marshal(s)
	if err != nil {
		t.Fatal(err)
	}
	for _, forbidden := range []string{"abc123", "AWS_SECRET", "noch mehr Ausgabe"} {
		if strings.Contains(string(b), forbidden) {
			t.Fatalf("Ergebnis-Inhalt %q steht im Span: %s", forbidden, b)
		}
	}
}

// TestMissingDurationStaysAbsent: fehlt die Angabe in der Payload, wird sie nicht
// erfunden — ein `duration_ms: 0` waere eine Messung, die nie stattfand.
func TestMissingDurationStaysAbsent(t *testing.T) {
	p, err := span.Parse([]byte(`{"tool_name":"Bash"}`))
	if err != nil {
		t.Fatal(err)
	}
	b, err := json.Marshal(span.Build(p, t.TempDir(), time.Now()))
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(string(b), "duration_ms") || strings.Contains(string(b), "result_bytes") {
		t.Fatalf("nicht gemessene Groessen stehen im Span: %s", b)
	}
}

// TestSpanDirIsTraversable haelt die Trennung fest: die DATEIEN sind 0600 (der
// Inhalt ist schuetzenswert), das VERZEICHNIS ist betretbar. Mit 0700 scheiterte
// `make docs-check` an "permission denied" — und das fiel monatelang nicht auf, weil
// dort noch ein 0755-Verzeichnis der Vorgaenger-Fassung lag: der Gate war gruen wegen
// Altbestand, nicht wegen Korrektheit.
func TestSpanDirIsTraversable(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	fi, err := os.Stat(filepath.Join(root, span.Dir))
	if err != nil {
		t.Fatal(err)
	}
	if fi.Mode().Perm()&0o055 != 0o055 {
		t.Fatalf("Ablage-Verzeichnis ist nicht betretbar: %v — jedes Werkzeug, das den Baum laeuft, bricht daran", fi.Mode().Perm())
	}

	// Und der Fall, der real eintrat: ein BESTEHENDES Verzeichnis aus einer frueheren
	// Fassung mit 0700. MkdirAll fasst es nicht an — der Modus muss nachgezogen werden.
	// Gemessen wird deshalb auch der Altbestand, nicht nur der frisch angelegte Fall.
	zweite := newRoot(t)
	if err := os.MkdirAll(filepath.Join(zweite, span.Dir), 0o700); err != nil {
		t.Fatal(err)
	}
	emit(t, zweite, `{"tool_name":"Bash","session_id":"s1"}`)
	fi, err = os.Stat(filepath.Join(zweite, span.Dir))
	if err != nil {
		t.Fatal(err)
	}
	if fi.Mode().Perm()&0o055 != 0o055 {
		t.Fatalf("bestehendes 0700-Verzeichnis wurde nicht korrigiert: %v", fi.Mode().Perm())
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

// TestAgentRoleFromKnownTypes: die Rollen-Achse aus Modul 15 fuellt sich aus dem
// Agenten-Typ, wenn der eine Rolle NENNT — und bleibt sonst leer statt geraten. Heute
// ist sie durchweg leer (gemessen: alle Subagenten-Stroeme tragen `general-purpose`);
// genau das soll ein Auswerter SEHEN, statt es aus einer fehlenden Zeile zu schliessen.
func TestAgentRoleFromKnownTypes(t *testing.T) {
	cases := map[string]string{
		"reviewer": "reviewer", "verifier": "verifier", "planner": "planner",
		"architect": "architect", "implementer": "implementer", "validator": "validator",
		"general-purpose": "", "": "", "Explore": "", "reviewer-2": "",
	}
	for typ, want := range cases {
		got := span.Build(span.Payload{Tool: "Bash", AgentType: typ}, t.TempDir(), time.Now()).AgentRole
		if got != want {
			t.Fatalf("agent_type %q -> agent_role %q, erwartet %q", typ, got, want)
		}
	}
}

// TestStreamNamesStayDistinct: der Strom ist (Sitzung, Agent) — zwei verschiedene
// Paare duerfen nie denselben Strom und damit denselben Nummernkreis bekommen. Zwei
// Wege dorthin gibt es mehrere: ein `-` in der Sitzung, das wie der
// Trenner aussieht, und das Kuerzen langer Namen auf 120 Zeichen.
func TestStreamNamesStayDistinct(t *testing.T) {
	paare := []span.Payload{
		{Session: "a-b"},
		{Session: "a", Agent: "b"},
		{Session: strings.Repeat("x", 200) + "eins"},
		{Session: strings.Repeat("x", 200) + "zwei"},
	}
	seen := map[string]int{}
	for i, p := range paare {
		name := span.StreamName(p)
		if j, doppelt := seen[name]; doppelt {
			t.Fatalf("Paar %d und %d teilen den Strom %q", j, i, name)
		}
		seen[name] = i
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
// requirement.id kommt NUR aus dem Bezug-Block.
func TestCorrelationFromLifecycle(t *testing.T) {
	root := newRoot(t)
	dir := filepath.Join(root, "docs/plan/planning/in-progress")
	if err := os.MkdirAll(dir, 0o700); err != nil {
		t.Fatal(err)
	}
	slice := "**Bezug:** LH-QA-01 und LH-FA-02, ADR-0011 und ADR-0003.\n\n" +
		"Fliesstext nennt LH-XX-99 und ADR-9999 als Abgrenzung.\n"
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
	// adr.id ist die dritte ableitbare Korrelations-Achse aus Modul 15 Kernidee. Sie
	// fehlte zuerst ganz — weder erfasst noch als Abweichung erklaert, obwohl sie im
	// selben Block steht wie requirement.id.
	if strings.Join(s.Adr, ",") != "ADR-0003,ADR-0011" {
		t.Fatalf("adr = %v (nur der Bezug-Block zaehlt)", s.Adr)
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
	if !strings.Contains(string(b), `"slice":[]`) || !strings.Contains(string(b), `"requirement":[]`) ||
		!strings.Contains(string(b), `"adr":[]`) {
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

// TestLeftoverLockFileDoesNotBlock: mit flock gibt der Kernel die Sperre frei, sobald
// der haltende Prozess endet. Eine liegengebliebene Lock-DATEI ist damit harmlos —
// anders als das liegengebliebene Lock-VERZEICHNIS der Vorgaenger-Fassung, das den
// Strom stilllegte und deshalb gebrochen werden musste (was seinerseits nicht atomar
// war).
func TestLeftoverLockFileDoesNotBlock(t *testing.T) {
	root := newRoot(t)
	dir := filepath.Join(root, span.Dir)
	if err := os.MkdirAll(dir, 0o700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, ".s1.lock"), nil, 0o600); err != nil {
		t.Fatal(err)
	}
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	if got := readLines(t, root, "s1"); len(got) != 1 {
		t.Fatalf("liegengebliebene Lock-Datei hat den Strom stillgelegt: %+v", got)
	}
}

// TestLeftoverLockDirectoryDoesNotBlock: die Vorgaenger-Fassung sperrte mit `mkdir`,
// hinterliess also ein VERZEICHNIS an der Lock-Stelle. `OpenFile` scheitert daran mit
// EISDIR — ohne Behandlung waere der Strom ab dem Wechsel dauerhaft und lautlos tot,
// genau die Eigenschaft, die der flock-Kommentar ausschliesst.
func TestLeftoverLockDirectoryDoesNotBlock(t *testing.T) {
	root := newRoot(t)
	dir := filepath.Join(root, span.Dir)
	if err := os.MkdirAll(filepath.Join(dir, ".s1.lock"), 0o700); err != nil {
		t.Fatal(err)
	}
	emit(t, root, `{"tool_name":"Bash","session_id":"s1"}`)
	if got := readLines(t, root, "s1"); len(got) != 1 {
		t.Fatalf("liegengebliebenes Lock-VERZEICHNIS hat den Strom stillgelegt: %+v", got)
	}
}

// TestUnresolvableGitRefStillCarriesFields ist der Worktree-Fall: dort ist `.git` eine
// DATEI, die Ableitung schlaegt fehl — und MR-018 sagt fuer diesen Fall "leer und als
// leer erkennbar" zu. Mit `omitempty` verschwanden die Schluessel stattdessen ganz.
// Der Unterschied ist der zwischen "unbekannt" und "nicht
// vorhanden", und genau den soll ein Audit-Schema tragen.
func TestUnresolvableGitRefStillCarriesFields(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, ".git"), []byte("gitdir: /woanders\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	b, err := json.Marshal(span.Build(span.Payload{Tool: "Bash"}, root, time.Now()))
	if err != nil {
		t.Fatal(err)
	}
	for _, want := range []string{`"branch":""`, `"commit":""`} {
		if !strings.Contains(string(b), want) {
			t.Fatalf("%s fehlt — der Schluessel muss anwesend und leer sein: %s", want, b)
		}
	}
}

// TestNoCommandArgumentsReachSpan ist der Kanarienvogel fuer KOMMANDO-Werkzeuge,
// gemessen an der GESCHRIEBENEN ZEILE statt am Rueckgabewert einer Funktion. Die
// abgeloeste bats-Fassung hatte ihn, die erste Go-Fassung liess ihn ersatzlos entfallen.
// Geprueft wurden sonst nur Programm-Token, Write-Inhalte und
// unbekannte Werkzeuge — nie die Argumente eines BEKANNTEN Werkzeugs.
func TestNoCommandArgumentsReachSpan(t *testing.T) {
	root := newRoot(t)
	emit(t, root, `{"tool_name":"Bash","session_id":"s1",
	  "tool_input":{"command":"gh auth login --with-token AUTHORIZATION-TOKEN-XYZ /etc/shadow"}}`)
	b, err := os.ReadFile(filepath.Join(root, span.Dir, "s1.jsonl"))
	if err != nil {
		t.Fatal(err)
	}
	for _, forbidden := range []string{"AUTHORIZATION-TOKEN-XYZ", "--with-token", "/etc/shadow", "login"} {
		if strings.Contains(string(b), forbidden) {
			t.Fatalf("Argument %q steht in der Span-Zeile: %s", forbidden, b)
		}
	}
	if !strings.Contains(string(b), `"program":"gh"`) {
		t.Fatalf("das Programm-Token fehlt: %s", b)
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
	// Die Liste ist die PFLICHT-Spalte aus MR-018, vollstaendig. Sie war zuerst um
	// `branch`/`commit` kuerzer — genau die zwei, die im Code ein `omitempty` trugen
	// und in einem git-worktree lautlos verschwanden. Der Waechter mass damit die
	// heutige Implementierung statt der Zusage,
	// also exakt das Muster, vor dem sein eigener Kommentar warnt.
	for _, feld := range []string{
		`"seq":`, `"ts":`, `"event":`, `"tool":`, `"tool_use_id":`,
		`"session":`, `"agent":`, `"agent_type":`, `"agent_role":`, `"slice":`, `"requirement":`, `"adr":`,
		`"branch":`, `"commit":`, `"status":`,
	} {
		if !strings.Contains(string(b), feld) {
			t.Fatalf("Pflichtfeld %s fehlt in einem Span mit leeren Werten: %s", feld, b)
		}
	}
}
