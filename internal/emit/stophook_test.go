package emit_test

import (
	"bytes"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// Fitness-Zeile 1 von ADR-0083: der ECHTE Stop-Hook und das ECHTE record-gates.sh,
// beide Fassungen (Dogfood und emittierte Vorlage), in einem tmp-Repo mit echtem git.
// Kein Nachbau: die drei Skripte werden unveraendert an ihren Ort im tmp-Repo kopiert.
// Das Test-Image traegt git (Dockerfile, Stage `test`); fehlt es, bricht der Test ab.

type stopHookFassung struct {
	name     string
	hook     string // Quelle des Hooks, relativ zu diesem Paket
	record   string // Quelle von record-gates.sh
	hash     string // Quelle von working-tree-hash.sh
	toolsDir string // Ort der zwei Werkzeuge im Repo
}

func stopHookFassungen() []stopHookFassung {
	return []stopHookFassung{
		{"dogfood", "../../.claude/hooks/stop-require-gates.sh", "../../harness/tools/record-gates.sh", "../../harness/tools/working-tree-hash.sh", "harness/tools"},
		{"ziel", "templates/enforce/stop-require-gates.sh", "templates/enforce/record-gates.sh", "templates/enforce/working-tree-hash.sh", "tools/harness"},
	}
}

type stopRepo struct {
	t   *testing.T
	dir string
	f   stopHookFassung
}

func stopEnv(extra ...string) []string {
	env := []string{}
	for _, e := range os.Environ() {
		if strings.HasPrefix(e, "STOP_GATE_STRENG=") {
			continue
		}
		env = append(env, e)
	}
	env = append(env, "GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1",
		"GIT_AUTHOR_NAME=t", "GIT_AUTHOR_EMAIL=t@example.invalid",
		"GIT_COMMITTER_NAME=t", "GIT_COMMITTER_EMAIL=t@example.invalid")
	return append(env, extra...)
}

func (r *stopRepo) git(args ...string) {
	r.t.Helper()
	cmd := exec.Command("git", append([]string{"-C", r.dir}, args...)...)
	cmd.Env = stopEnv()
	if out, err := cmd.CombinedOutput(); err != nil {
		r.t.Fatalf("git %s: %v: %s", strings.Join(args, " "), err, out)
	}
}

func (r *stopRepo) write(rel, inhalt string, mode os.FileMode) {
	r.t.Helper()
	p := filepath.Join(r.dir, rel)
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		r.t.Fatal(err)
	}
	if err := os.WriteFile(p, []byte(inhalt), mode); err != nil {
		r.t.Fatal(err)
	}
}

func (r *stopRepo) copy(src, rel string) {
	r.t.Helper()
	b, err := os.ReadFile(src)
	if err != nil {
		r.t.Fatal(err)
	}
	r.write(rel, string(b), 0o755)
}

// run faehrt bash <rel> im Repo und liefert stdout+stderr und den Exit-Code.
func (r *stopRepo) run(rel, stdin string, extraEnv ...string) (string, int) {
	r.t.Helper()
	var out bytes.Buffer
	cmd := exec.Command("bash", rel)
	cmd.Dir = r.dir
	cmd.Env = stopEnv(extraEnv...)
	cmd.Stdin = strings.NewReader(stdin)
	cmd.Stdout, cmd.Stderr = &out, &out
	err := cmd.Run()
	var ee *exec.ExitError
	switch {
	case err == nil:
		return out.String(), 0
	case errors.As(err, &ee):
		return out.String(), ee.ExitCode()
	default:
		r.t.Fatalf("bash %s: %v", rel, err)
		return "", -1
	}
}

func (r *stopRepo) record() (string, int) {
	return r.run(r.f.toolsDir+"/record-gates.sh", "")
}

func (r *stopRepo) mustRecord() {
	r.t.Helper()
	if out, rc := r.record(); rc != 0 {
		r.t.Fatalf("record-gates.sh Exit %d: %s", rc, out)
	}
}

func (r *stopRepo) hook(stdin string, extraEnv ...string) (string, int) {
	return r.run(".claude/hooks/stop-require-gates.sh", stdin, extraEnv...)
}

// newStopRepo legt das tmp-Repo an; mitCommit=false laesst es ohne einzigen Commit.
func newStopRepo(t *testing.T, f stopHookFassung, mitCommit bool) *stopRepo {
	t.Helper()
	r := &stopRepo{t: t, dir: t.TempDir(), f: f}
	r.git("init", "-q", "-b", "main")
	r.copy(f.hook, ".claude/hooks/stop-require-gates.sh")
	r.copy(f.record, f.toolsDir+"/record-gates.sh")
	r.copy(f.hash, f.toolsDir+"/working-tree-hash.sh")
	r.write(".harness/.gitignore", "state/\n", 0o644)
	r.write("inhalt.txt", "eins\n", 0o644)
	if mitCommit {
		r.git("add", "-A")
		r.git("commit", "-q", "-m", "basis")
	}
	return r
}

const (
	stopApprove = `"decision":"approve"`
	stopBlock   = `"decision": "block"`
)

func wantDecision(t *testing.T, out string, rc int, want string) {
	t.Helper()
	if rc != 0 || !strings.Contains(out, want) {
		t.Fatalf("Hook: erwartet Exit 0 mit %s, bekommen Exit %d:\n%s", want, rc, out)
	}
}

func TestStopHook_CommitBindung(t *testing.T) {
	for _, f := range stopHookFassungen() {
		t.Run(f.name, func(t *testing.T) {
			t.Run("ohne_neuen_HEAD_mit_ungedeckter_Aenderung_frei", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopApprove)
			})
			t.Run("neuer_HEAD_ohne_gruenen_Lauf_blockiert", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				r.git("commit", "-q", "-am", "neu")
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopBlock)
			})
			t.Run("neuer_HEAD_gedeckten_Inhalts_frei", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.write("inhalt.txt", "zwei\n", 0o644)
				r.mustRecord()
				r.git("commit", "-q", "-am", "neu")
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopApprove)
			})
			t.Run("streng_per_Datei_ohne_neuen_HEAD_blockiert", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.write(".harness/stop-gate-streng", "", 0o644)
				r.git("add", "-A")
				r.git("commit", "-q", "-m", "streng")
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopBlock)
			})
			t.Run("streng_per_Umgebung_1_ohne_neuen_HEAD_blockiert", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}", "STOP_GATE_STRENG=1")
				wantDecision(t, out, rc, stopBlock)
			})
			t.Run("Umgebung_true_wirkt_wie_Default", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}", "STOP_GATE_STRENG=true")
				wantDecision(t, out, rc, stopApprove)
			})
			t.Run("fehlender_HEAD_Stempel_bei_ungedeckter_Aenderung_blockiert", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				if err := os.Remove(filepath.Join(r.dir, ".harness/state/gates-passed.head")); err != nil {
					t.Fatal(err)
				}
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopBlock)
			})
			t.Run("Repo_ohne_Commit_Stempel_kein_commit_und_frei", func(t *testing.T) {
				r := newStopRepo(t, f, false)
				r.mustRecord()
				b, err := os.ReadFile(filepath.Join(r.dir, ".harness/state/gates-passed.head"))
				if err != nil || string(b) != "kein-commit\n" {
					t.Fatalf("HEAD-Stempel: erwartet \"kein-commit\\n\", bekommen %q (%v)", b, err)
				}
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}")
				wantDecision(t, out, rc, stopApprove)
			})
			t.Run("HEAD_auf_fehlenden_Ref_record_rot_ohne_Stempel_Hook_Exit_2", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.git("symbolic-ref", "HEAD", "refs/heads/gibt-es-nicht")
				if out, rc := r.record(); rc == 0 {
					t.Fatalf("record-gates.sh: erwartet rot, bekommen Exit 0:\n%s", out)
				}
				for _, s := range []string{"gates-passed.head", "gates-passed.diffsha"} {
					if _, err := os.Stat(filepath.Join(r.dir, ".harness/state", s)); err == nil {
						t.Fatalf("record-gates.sh rot, hat aber %s geschrieben", s)
					}
				}
				if out, rc := r.hook("{}"); rc != 2 {
					t.Fatalf("Hook: erwartet Exit 2, bekommen Exit %d:\n%s", rc, out)
				}
			})
			t.Run("unlesbarer_HEAD_Stempel_Exit_2", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				p := filepath.Join(r.dir, ".harness/state/gates-passed.head")
				if err := os.Remove(p); err != nil {
					t.Fatal(err)
				}
				// Ein Verzeichnis statt der Datei: unlesbar auch fuer root, unter dem der
				// Testlauf im Container laeuft (chmod 000 haelt root nicht auf).
				if err := os.Mkdir(p, 0o755); err != nil {
					t.Fatal(err)
				}
				if out, rc := r.hook("{}"); rc != 2 {
					t.Fatalf("Hook: erwartet Exit 2, bekommen Exit %d:\n%s", rc, out)
				}
			})
			t.Run("stop_hook_active_frei", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				r.git("commit", "-q", "-am", "neu")
				out, rc := r.hook(`{"stop_hook_active": true}`)
				wantDecision(t, out, rc, stopApprove)
			})
		})
	}
}
