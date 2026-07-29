package span

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

// Dir ist der Ablageort — eine KONSTANTE, keine Konfiguration. Der Review-Befund
// MEDIUM-4 traf die Vorgaenger-Fassung, die ihn per Umgebungsvariable ueberschreibbar
// machte: ein Hook erbt die Umgebung des Agenten-Prozesses, und ein Span im
// GETRACKTEN Baum verschiebt den working-tree-hash bei jedem Tool-Call — der
// Stop-Hook blockierte sich selbst (MR-003). Tests setzen stattdessen die WURZEL
// (ein temporaeres Verzeichnis), nicht das Ziel darunter.
const Dir = ".harness/state/spans"

const (
	// maxHash begrenzt, was fingerabgedruckt wird. Ohne Grenze haengt der Emitter an
	// einer mehrere GB grossen Datei, und der Lauf, den er nur beobachten soll,
	// wartet auf ihn (ADR-0011 Festlegung 6: nie spuerbar verzoegern).
	maxHash = 64 << 20

	lockTries = 200
	lockWait  = 2 * time.Millisecond
	// lockStale bricht ein liegengebliebenes Schloss. Ohne diese Grenze legte ein
	// zwischen Mkdir und Remove getoeteter Prozess den Strom DAUERHAFT still — und
	// zwar unsichtbar, weil ohne beanspruchte Nummer keine Luecke entsteht. Die
	// Spanne ist um Groessenordnungen laenger als das Anhaengen einer Zeile.
	lockStale = 60 * time.Second

	maxStreamName = 120
)

// Span ist die geschriebene Zeile. Die Feldtabelle samt Incident-Fragen steht in
// harness/conventions.md MR-018 — sie ist die normative Fassung, dieses Struct ihre
// Umsetzung. Die Reihenfolge hier ist die Reihenfolge in der Datei.
type Span struct {
	Seq            int      `json:"seq"`
	TS             string   `json:"ts"`
	Event          string   `json:"event"`
	Tool           string   `json:"tool"`
	ToolUseID      string   `json:"tool_use_id"`
	Session        string   `json:"session"`
	Agent          string   `json:"agent"`
	AgentType      string   `json:"agent_type"`
	Slice          []string `json:"slice"`
	Requirement    []string `json:"requirement"`
	Branch         string   `json:"branch,omitempty"`
	Commit         string   `json:"commit,omitempty"`
	Status         string   `json:"status"`
	PermissionMode string   `json:"permission_mode,omitempty"`
	Transcript     string   `json:"transcript,omitempty"`
	Path           string   `json:"path,omitempty"`
	Bytes          *int64   `json:"bytes,omitempty"`
	Sha256Prefix   string   `json:"sha256_16,omitempty"`
	Program        string   `json:"program,omitempty"`
	Argc           *int     `json:"argc,omitempty"`
}

// Emit ist der ganze Weg: Payload lesen, Span bauen, an den Strom anhaengen.
func Emit(root string, payload []byte, now time.Time) error {
	p, err := Parse(payload)
	if err != nil {
		return err
	}
	return Append(root, StreamName(p), Build(p, root, now))
}

// Build leitet den Span ab. ABLEITEN SCHLAEGT DEKLARIEREN (ADR-0011 Festlegung 1.4):
// slice, requirement, branch und commit kommen aus dem Repo-Zustand, nicht aus einer
// gepflegten Datei, die veralten koennte.
func Build(p Payload, root string, now time.Time) Span {
	d := Derive(p)
	slices, reqs := correlation(root)
	branch, commit := gitRef(root)
	status := "ok"
	if p.Failed {
		status = "error"
	}
	s := Span{
		TS:             now.UTC().Format(time.RFC3339),
		Event:          p.Event,
		Tool:           p.Tool,
		ToolUseID:      p.ToolUseID,
		Session:        p.Session,
		Agent:          p.Agent,
		AgentType:      p.AgentType,
		Slice:          slices,
		Requirement:    reqs,
		Branch:         branch,
		Commit:         commit,
		Status:         status,
		PermissionMode: p.PermissionMode,
		Transcript:     p.Transcript,
		Path:           d.Path,
		Program:        d.Program,
	}
	if d.HasArgc {
		argc := d.Argc
		s.Argc = &argc
	}
	// Fingerabdruck NUR fuer Schreib-Werkzeuge (Review-Befund MEDIUM-1): auf einem
	// gelesenen Pfad waere er ein Bestaetigungs-Orakel ohne Incident-Frage. Er kommt
	// aus dem DATEISYSTEM, nie aus der Payload — so passiert kein Byte fremden
	// Inhalts diesen Emitter (bewacht von TestNoPayloadContentReachesSpan).
	if toolClass(p.Tool) == classFileWrite {
		fingerprint(&s, d.Path)
	}
	return s
}

func fingerprint(s *Span, path string) {
	if path == "" {
		return
	}
	fi, err := os.Stat(path)
	if err != nil || !fi.Mode().IsRegular() {
		return
	}
	size := fi.Size()
	s.Bytes = &size
	if size > maxHash {
		return
	}
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer func() { _ = f.Close() }()
	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return
	}
	s.Sha256Prefix = hex.EncodeToString(h.Sum(nil))[:16]
}

// StreamName bildet den Strom (Sitzung, Agent) aus ADR-0011 Festlegung 3. Der Name
// wird auf harmlose Zeichen reduziert: eine Sitzungs-Kennung ist Fremd-Eingabe, und
// `../..` darf keinen Pfad verlassen.
func StreamName(p Payload) string {
	name := p.Session
	if name == "" {
		name = "nosession"
	}
	if p.Agent != "" {
		name += "-" + p.Agent
	}
	var b strings.Builder
	for _, r := range name {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9',
			r == '.', r == '_', r == '-':
			b.WriteRune(r)
		default:
			b.WriteByte('_')
		}
	}
	out := b.String()
	if len(out) > maxStreamName {
		out = out[:maxStreamName]
	}
	return out
}

// Append vergibt die Folgenummer und haengt die Zeile an — beides unter DERSELBEN
// Sperre, weil beides eine Einheit ist.
func Append(root, stream string, s Span) error {
	dir := filepath.Join(root, Dir)
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return err
	}
	lock := filepath.Join(dir, "."+stream+".lock")
	if err := acquire(lock, time.Now()); err != nil {
		return err
	}
	defer func() { _ = os.Remove(lock) }()

	// Die Nummer wird VERGEBEN, nicht aus dem Bestand abgeleitet. Der Unterschied ist
	// die ganze Zusage (Review-Befund HIGH-3): `wc -l + 1` waere immer dicht 1..N,
	// eine Luecke also konstruktiv unmoeglich — der Leser saehe Vollstaendigkeit, wo
	// Spans fehlen. Der Zaehler steht in einer eigenen Datei und wird VOR dem
	// Schreiben erhoeht: stirbt der Prozess danach, fehlt die Zeile und die Luecke
	// ist sichtbar (bewacht von TestSeqIsAssignedNotDerived).
	seqFile := filepath.Join(dir, stream+".seq")
	s.Seq = nextSeq(seqFile)
	if err := os.WriteFile(seqFile, []byte(strconv.Itoa(s.Seq)+"\n"), 0o600); err != nil {
		return err
	}

	line, err := json.Marshal(s)
	if err != nil {
		return err
	}
	return appendLine(filepath.Join(dir, stream+".jsonl"), append(line, '\n'))
}

func nextSeq(seqFile string) int {
	b, err := os.ReadFile(seqFile)
	if err != nil {
		return 1
	}
	n, err := strconv.Atoi(strings.TrimSpace(string(b)))
	if err != nil || n < 0 {
		return 1
	}
	return n + 1
}

// appendLine schreibt die Zeile in EINEM Stueck. Der Modus steht VOR dem ersten Byte:
// O_CREATE mit 0600 legt die Datei gleich richtig an, statt sie erst offen zu
// schaffen und den Modus nachzuziehen (das liesse ein Fenster mit umask-Rechten
// offen). Ein bestehender Strom mit zu weitem Modus wird korrigiert — Review-Befund
// LOW-3, bewacht von TestModeIsOwnerOnly.
func appendLine(file string, line []byte) error {
	f, err := os.OpenFile(file, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o600)
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()
	if fi, err := f.Stat(); err == nil && fi.Mode().Perm()&0o077 != 0 {
		if err := f.Chmod(0o600); err != nil {
			return err
		}
	}
	_, err = f.Write(line)
	return err
}

// acquire holt die Sperre. `mkdir` ist die portable atomare Operation; ohne sie
// vergeben nebenlaeufige Emitter dieselbe Nummer und ihre Zeilen verschraenken sich
// (im Review gemessen: 6 doppelte seq, 8 kaputte Zeilen bei 25 Parallelen).
// Bewacht von TestConcurrentEmittersGetDistinctSeq.
func acquire(lock string, now time.Time) error {
	for range lockTries {
		if err := os.Mkdir(lock, 0o700); err == nil {
			return nil
		}
		if fi, err := os.Stat(lock); err == nil && now.Sub(fi.ModTime()) > lockStale {
			_ = os.Remove(lock)
			continue
		}
		time.Sleep(lockWait)
	}
	// Fail-open: wer die Sperre nicht bekommt, verliert seinen Span — nicht der Lauf
	// seinen Fortgang. Diese Aufgabe ist unsichtbar (es wurde nie eine Nummer
	// beansprucht) — dieselbe benannte Grenze wie der Tod vor der Vergabe.
	return errors.New("span: Sperre nicht erhalten")
}

// correlation leitet slice.id und requirement.id ab. slice.id IST das
// Lifecycle-Verzeichnis (Modul 5) — kein Slice ergibt eine LEERE Liste, die als leer
// erkennbar bleibt statt geraten zu werden; mehrere ergeben alle.
func correlation(root string) (slices, reqs []string) {
	slices, reqs = []string{}, []string{}
	matches, err := filepath.Glob(filepath.Join(root, "docs/plan/planning/in-progress/slice-*.md"))
	if err != nil {
		return slices, reqs
	}
	sort.Strings(matches)
	seen := map[string]bool{}
	for _, m := range matches {
		slices = append(slices, strings.TrimSuffix(filepath.Base(m), ".md"))
		for _, id := range requirements(m) {
			if !seen[id] {
				seen[id] = true
				reqs = append(reqs, id)
			}
		}
	}
	sort.Strings(reqs)
	return slices, reqs
}

// requirements liest die Anforderungs-Kennungen NUR aus dem Bezug-Block, nicht aus
// der ganzen Datei: ein Slice erwaehnt im Fliesstext fremde Anforderungen
// (Praezedenzfaelle, Abgrenzungen), und die sind nicht sein Bezug (Review-Befund
// MEDIUM-2). Der Block reicht von der `**Bezug:**`-Zeile bis zur naechsten Leerzeile.
func requirements(file string) []string {
	b, err := os.ReadFile(file)
	if err != nil {
		return nil
	}
	re := regexp.MustCompile(`LH-[A-Z]{2}-[0-9]{2}`)
	var out []string
	inBlock := false
	for _, line := range strings.Split(string(b), "\n") {
		if strings.HasPrefix(line, "**Bezug:**") {
			inBlock = true
		} else if inBlock && strings.TrimSpace(line) == "" {
			break
		}
		if inBlock {
			out = append(out, re.FindAllString(line, -1)...)
		}
	}
	return out
}

// gitRef leitet Branch und Commit aus .git ab — die Korrelations-Achse, nach der
// Modul 15 mit "Slice/PR/Agent-Rolle" fragt. Die PR-NUMMER selbst ist im Hook nicht
// erreichbar (sie lebt bei der Forge, der Emitter geht nicht ins Netz); Branch und
// Commit sind der Anker, ueber den eine Auswertung sie nachschlaegt. Ein `.git` als
// DATEI (Worktree/Submodul) wird nicht aufgeloest — dann bleiben beide Felder leer,
// als leer erkennbar.
func gitRef(root string) (branch, commit string) {
	gitDir := filepath.Join(root, ".git")
	fi, err := os.Stat(gitDir)
	if err != nil || !fi.IsDir() {
		return "", ""
	}
	head, err := os.ReadFile(filepath.Join(gitDir, "HEAD"))
	if err != nil {
		return "", ""
	}
	ref := strings.TrimSpace(string(head))
	if !strings.HasPrefix(ref, "ref: ") {
		return "", shortSha(ref)
	}
	name := strings.TrimSpace(strings.TrimPrefix(ref, "ref: "))
	branch = strings.TrimPrefix(name, "refs/heads/")
	return branch, shortSha(resolveRef(gitDir, name))
}

func resolveRef(gitDir, name string) string {
	if b, err := os.ReadFile(filepath.Join(gitDir, filepath.FromSlash(name))); err == nil {
		return strings.TrimSpace(string(b))
	}
	packed, err := os.ReadFile(filepath.Join(gitDir, "packed-refs"))
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(packed), "\n") {
		fields := strings.Fields(line)
		if len(fields) == 2 && fields[1] == name {
			return fields[0]
		}
	}
	return ""
}

func shortSha(sha string) string {
	sha = strings.TrimSpace(sha)
	if len(sha) < 12 {
		return ""
	}
	for _, r := range sha[:12] {
		if !strings.ContainsRune("0123456789abcdefABCDEF", r) {
			return ""
		}
	}
	return sha[:12]
}

// FindRoot sucht die Repo-Wurzel aufwaerts vom Arbeitsverzeichnis. Ohne Wurzel gibt
// es keinen Span — der Emitter schreibt NIE an einen geratenen Ort.
func FindRoot(start string) (string, bool) {
	dir := start
	for {
		if _, err := os.Stat(filepath.Join(dir, ".git")); err == nil {
			return dir, true
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", false
		}
		dir = parent
	}
}
