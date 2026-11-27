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
	keys     string // Quelle des je-Check-Satzerzeugers; leer, wenn die Fassung keinen traegt (Tier 1, ADR-0108)
}

func stopHookFassungen() []stopHookFassung {
	return []stopHookFassung{
		{"dogfood", "../../.claude/hooks/stop-require-gates.sh", "../../harness/tools/record-gates.sh", "../../harness/tools/working-tree-hash.sh", "harness/tools", "../../harness/tools/gates-keys.sh"},
		{"ziel", "templates/enforce/stop-require-gates.sh", "templates/enforce/record-gates.sh", "templates/enforce/working-tree-hash.sh", "tools/harness", ""},
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

// pinsMakefile ist das Fixture-Makefile der Dogfood-Fassung: der Satzerzeuger
// liest je Check die Pin-Zeilen und den Rezept-Block aus dem Makefile — es traegt
// alle Pin-Namen der Tafel-Mengen, damit je Check ein Key rechnet (leere Menge
// waere fail-closed, MR-017).
const pinsMakefile = `GO_VERSION ?= t
GOLANGCI_LINT_VERSION ?= t
TRAEGER_VERSION ?= t
SHELLCHECK_IMAGE ?= t
BATS_IMAGE ?= t
ACTIONLINT_IMAGE ?= t
HOST_OS ?= t
HOST_ARCH ?= t
HOST_BIN ?= t
BASELINE_TAG ?= t
BASELINE_ZIP_SHA256 ?= t
record-gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims register-ausgang mutate-greift host-bin span-check ## Checks + Nachweis
`

// newStopRepo legt das tmp-Repo an; mitCommit=false laesst es ohne einzigen Commit.
func newStopRepo(t *testing.T, f stopHookFassung, mitCommit bool) *stopRepo {
	t.Helper()
	r := &stopRepo{t: t, dir: t.TempDir(), f: f}
	r.git("init", "-q", "-b", "main")
	r.copy(f.hook, ".claude/hooks/stop-require-gates.sh")
	r.copy(f.record, f.toolsDir+"/record-gates.sh")
	r.copy(f.hash, f.toolsDir+"/working-tree-hash.sh")
	if f.keys != "" {
		r.copy(f.keys, f.toolsDir+"/gates-keys.sh")
		r.write("Makefile", pinsMakefile, 0o644)
	}
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

// fassungHaertet — die Tier-2-Fassung (Mischform, ADR-0108 Festlegung 5) haertet die
// Freigaben je Check: ein Zug, der je-Check-Keys driftet, blockt, wo die Tier-1-Fassung
// ueber der HEAD-Kante frei gab. Der benannte Preis des ADR-0108-Kontexts.
func fassungHaertet(f stopHookFassung) bool { return f.keys != "" }

func TestStopHook_CommitBindung(t *testing.T) {
	for _, f := range stopHookFassungen() {
		t.Run(f.name, func(t *testing.T) {
			t.Run("ohne_neuen_HEAD_driftender_Key_blockt_Tier1_frei", func(t *testing.T) {
				r := newStopRepo(t, f, true)
				r.mustRecord()
				r.write("inhalt.txt", "zwei\n", 0o644)
				out, rc := r.hook("{}")
				if fassungHaertet(f) {
					wantDecision(t, out, rc, stopBlock)
					if !strings.Contains(out, "per-check") {
						t.Fatalf("Mischform: erwartet Block am je-Check-Key, bekommen:\n%s", out)
					}
					return
				}
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
				if fassungHaertet(f) {
					// Der Streng-Schalter sagt nichts (true ist nicht 1); der Block
					// kommt allein aus der Mischform — der Grund benennt den Key.
					wantDecision(t, out, rc, stopBlock)
					if !strings.Contains(out, "per-check") {
						t.Fatalf("Mischform: der Block kommt vom je-Check-Key, nicht vom Streng-Schalter:\n%s", out)
					}
					return
				}
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
				if fassungHaertet(f) {
					// Mischform: der uncommittete Zug driftet den je-Check-Key auch
					// am ungeborenen Zweig — der ADR-0108-Preis, benannt im Kontext.
					wantDecision(t, out, rc, stopBlock)
					if !strings.Contains(out, "per-check") {
						t.Fatalf("Mischform: erwartet Block am je-Check-Key, bekommen:\n%s", out)
					}
					return
				}
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

			if fassungHaertet(f) {
				t.Run("Teildrift_gestempelte_Keys_geben_uncommitteten_Zug_frei", func(t *testing.T) {
					// Das Protokoll des Plans §5: der Fast-Pfad faehrt GENAU den
					// gedrifteten Check und stuempelt nur dessen Key; der Stop-Hook
					// liest die je-Check-Deckung als Alternative zur Hash-Kante.
					r := newStopRepo(t, f, true)
					r.mustRecord()
					r.write("inhalt.txt", "zwei\n", 0o644)
					// inhalt.txt liegt allein in der Bauch-Menge des Satzerzeugers;
					// genau der gedriftete Check stuempelt.
					if out, rc := r.run(f.toolsDir+"/gates-keys.sh", "stamp", "comment-claims"); rc != 0 {
						t.Fatalf("Satzerzeuger-Stempel: Exit %d:\n%s", rc, out)
					}
					out, rc := r.hook("{}")
					wantDecision(t, out, rc, stopApprove)
				})
				t.Run("Record_only_Zug_rotiert_keinen_Key_und_gibt_frei", func(t *testing.T) {
					// ADR-0103 Festlegung 2 über neuem HEAD lesbar (ADR-0108
					// Festlegung 5): der Record-only-Commit bewegt die zwei Gesamt-
					// Werte nicht und keinen je-Check-Key; der Hook gibt frei.
					r := newStopRepo(t, f, true)
					r.mustRecord()
					keysVor := map[string]string{}
					for _, s := range []string{"comment-claims", "docs-check", "lint"} {
						b, err := os.ReadFile(filepath.Join(r.dir, ".harness/state/gates-passed-"+s+".key"))
						if err != nil {
							t.Fatal(err)
						}
						keysVor[s] = string(b)
					}
					r.write(".harness/stamp/mutate/slice-x-befund-last.txt", "record-only\n", 0o644)
					r.git("add", "-A")
					r.git("commit", "-q", "-m", "record")
					out, rc := r.hook("{}")
					wantDecision(t, out, rc, stopApprove)
					for _, s := range []string{"comment-claims", "docs-check", "lint"} {
						b, err := os.ReadFile(filepath.Join(r.dir, ".harness/state/gates-passed-"+s+".key"))
						if err != nil {
							t.Fatal(err)
						}
						if string(b) != keysVor[s] {
							t.Fatalf("je-Check-Key %s rotierte mit dem Record-only-Zug: %q -> %q", s, keysVor[s], string(b))
						}
					}
				})
			}
		})
	}
}
