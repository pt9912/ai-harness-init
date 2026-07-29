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
	"syscall"
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
	AgentRole      string   `json:"agent_role"`
	Slice          []string `json:"slice"`
	Requirement    []string `json:"requirement"`
	Adr            []string `json:"adr"`
	Branch         string   `json:"branch"`
	Commit         string   `json:"commit"`
	Status         string   `json:"status"`
	PermissionMode string   `json:"permission_mode,omitempty"`
	Transcript     string   `json:"transcript,omitempty"`
	Path           string   `json:"path,omitempty"`
	Bytes          *int64   `json:"bytes,omitempty"`
	Sha256Prefix   string   `json:"sha256_16,omitempty"`
	Program        string   `json:"program,omitempty"`
	Argc           *int     `json:"argc,omitempty"`
	DurationMS     *int64   `json:"duration_ms,omitempty"`
	ResultBytes    *int64   `json:"result_bytes,omitempty"`
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
	slices, reqs, adrs := correlation(root)
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
		AgentRole:      roleFromAgentType(p.AgentType),
		Slice:          slices,
		Requirement:    reqs,
		Adr:            adrs,
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
	// Dauer und Ergebnis-Groesse: die zwei Achsen, ohne die zwei Fragen dieses Tages
	// unbeantwortbar blieben — "lief es gleichzeitig?" und "hat ein einzelner Aufruf
	// den Speicher gesprengt?". Beide kommen aus der Payload, beide ohne Inhalt.
	if p.HasDuration {
		ms := p.DurationMS
		s.DurationMS = &ms
	}
	if p.HasResult {
		rb := p.ResultBytes
		s.ResultBytes = &rb
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

// roleFromAgentType fuellt die Rollen-Achse aus Modul 15, SOWEIT sie erreichbar ist.
// LEER HEISST UNBEKANNT, nicht "rollenlos": eine Rolle gibt es immer, wir kennen sie
// nur nicht. Die Lesevorschrift dazu steht in MR-018 — eine Auswertung, die die leeren
// Spans als eigene Kostenstelle aufsummiert, erfindet eine, die es nicht gibt.
//
// wird ein Subagent unter dem Namen seiner Harness-Rolle gestartet, IST der
// Agenten-Typ die Rolle. Jeder andere Wert — heute durchweg `general-purpose` — ergibt
// ein LEERES Feld.
//
// Warum ein Feld, das heute meist leer bleibt: dieselbe Begruendung wie bei
// `branch`/`commit`. Ein Pflichtfeld, dessen Ableitung scheitert, gehoert anwesend und
// leer in die Zeile, sonst kann ein Auswerter "unbekannt" nicht von "nicht vorhanden"
// unterscheiden. Die frueher hier fehlende Achse machte die Luecke nur in MR-018
// sichtbar — jetzt steht sie in JEDEM Span. Und sie fuellt sich ohne
// Erfassungs-Aenderung, sobald rollen-benannte Agenten-Typen existieren (slice-060).
// Bewacht von TestAgentRoleFromKnownTypes.
func roleFromAgentType(agentType string) string {
	switch agentType {
	case "planner", "architect", "implementer", "reviewer", "verifier", "validator":
		return agentType
	default:
		return ""
	}
}

// StreamName bildet den Strom (Sitzung, Agent) aus ADR-0011 Festlegung 3. Zwei Dinge
// sind hier keine Kosmetik: die Teile werden EINZELN reduziert (sonst faellt
// Sitzung "a-b" ohne Agent mit Sitzung "a" plus Agent "b" zusammen), und beim Kuerzen
// tritt ein Fingerabdruck des vollen Namens an die Stelle des Restes — sonst teilten
// sich zwei Laeufe, die sich erst jenseits der Grenze unterscheiden, einen Strom UND
// einen Nummernkreis (Review-Befund LOW-7). Eine Sitzungs-Kennung ist Fremd-Eingabe;
// `../..` darf keinen Pfad verlassen.
func StreamName(p Payload) string {
	name := sanitizePart(p.Session)
	if name == "" {
		name = "nosession"
	}
	if p.Agent != "" {
		name += "-" + sanitizePart(p.Agent)
	}
	if len(name) > maxStreamName {
		sum := sha256.Sum256([]byte(name))
		name = name[:maxStreamName-13] + "-" + hex.EncodeToString(sum[:])[:12]
	}
	return name
}

// sanitizePart laesst nur harmlose Zeichen durch — den Trenner `-` ausdruecklich
// NICHT, denn er trennt Sitzung von Agent.
func sanitizePart(s string) string {
	var b strings.Builder
	for _, r := range s {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9',
			r == '.', r == '_':
			b.WriteRune(r)
		default:
			b.WriteByte('_')
		}
	}
	return b.String()
}

// Append vergibt die Folgenummer und haengt die Zeile an — beides unter DERSELBEN
// Sperre, weil beides eine Einheit ist.
func Append(root, stream string, s Span) error {
	dir := filepath.Join(root, Dir)
	// 0755 fuer das VERZEICHNIS, 0600 fuer die DATEIEN — und die Trennung ist
	// gemessen, nicht gewaehlt: mit 0700 scheiterte `make docs-check` mit
	// "permission denied", sobald es das Verzeichnis betreten wollte (der Container
	// laeuft unter einer anderen Kennung). Aufgefallen ist es erst, als `make
	// span-clean` das 0755-Verzeichnis der Vorgaenger-Fassung wegraeumte — bis dahin
	// war der Gate GRUEN WEGEN ALTBESTAND, und auf einem frischen Checkout waere er
	// beim ersten Span rot geworden. Schuetzenswert ist der INHALT, und der steht in
	// den Dateien; die Verzeichnis-Rechte folgen dem umgebenden Zustands-Bereich
	// (.harness/state ist 775). Bewacht von TestSpanDirIsTraversable.
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	// MkdirAll setzt den Modus NUR beim Anlegen und unterliegt der umask: ein
	// 0700-Altbestand aus einer frueheren Fassung bliebe unbetretbar, und genau daran
	// scheiterte `make docs-check`. Fuer Dateien zieht appendLine denselben Fall nach;
	// fuers Verzeichnis fehlte es (Review Runde 3, F-3).
	if fi, statErr := os.Stat(dir); statErr == nil && fi.Mode().Perm()&0o055 != 0o055 {
		if chErr := os.Chmod(dir, 0o755); chErr != nil {
			return chErr
		}
	}
	lock, err := acquire(filepath.Join(dir, "."+stream+".lock"))
	if err != nil {
		return err
	}
	// Schliessen gibt die Sperre frei — und der Kernel tut dasselbe, wenn dieser
	// Prozess stirbt, ohne hierher zu kommen.
	defer func() { _ = lock.Close() }()

	// Die Nummer wird VERGEBEN, nicht aus dem Bestand abgeleitet. Der Unterschied ist
	// die ganze Zusage (Review-Befund HIGH-3): `wc -l + 1` waere immer dicht 1..N,
	// eine Luecke also konstruktiv unmoeglich — der Leser saehe Vollstaendigkeit, wo
	// Spans fehlen. Der Zaehler steht in einer eigenen Datei und wird VOR dem
	// Schreiben erhoeht: stirbt der Prozess danach, fehlt die Zeile und die Luecke
	// ist sichtbar (bewacht von TestSeqIsAssignedNotDerived).
	seqFile := filepath.Join(dir, stream+".seq")
	s.Seq = nextSeq(seqFile)
	if err := writeOwnerOnly(seqFile, []byte(strconv.Itoa(s.Seq)+"\n")); err != nil {
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

// acquire holt die Sperre. FLOCK und nicht mkdir: der Kernel gibt eine flock-Sperre
// frei, sobald der haltende Prozess endet — auch bei SIGKILL. Damit gibt es kein
// liegengebliebenes Schloss, das den Strom dauerhaft stilllegt, und damit auch kein
// Brechen eines solchen Schlosses. Die Vorgaenger-Fassung brach es nach 60 s, und
// genau dieses Brechen war nicht atomar: zwei Emitter konnten dasselbe veraltete
// Schloss sehen, der zweite Remove traf das FRISCHE Schloss des ersten, und beide
// vergaben dieselbe Nummer (Review-Befund MEDIUM-5). Eine Doppelvergabe erzeugt keine
// Luecke — der Leser saehe Vollstaendigkeit. Bewacht von
// TestConcurrentEmittersGetDistinctSeq und TestLeftoverLockFileDoesNotBlock.
//
// Nicht blockierend, sondern begrenzt wiederholend: wer die Sperre nicht bekommt,
// verliert seinen Span — nicht der Lauf seinen Fortgang (fail-open). Diese Aufgabe ist
// unsichtbar, weil nie eine Nummer beansprucht wurde; dieselbe benannte Grenze wie der
// Tod vor der Vergabe.
func acquire(path string) (*os.File, error) {
	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		// Ein VERZEICHNIS an dieser Stelle ist der Nachlass der Vorgaenger-Fassung, die
		// mit `mkdir` sperrte: `OpenFile` scheitert daran mit EISDIR, und der Strom
		// waere ab da dauerhaft und lautlos tot — genau die Eigenschaft, die dieser
		// Kommentar ausschliesst (Review-Befund Runde 2, MEDIUM-1). Einmal aufraeumen
		// und erneut versuchen; scheitert auch das, gilt fail-open.
		if fi, statErr := os.Stat(path); statErr == nil && fi.IsDir() {
			// Rmdir und NICHT os.Remove: letzteres unlinkt auch DATEIEN. Treffen zwei
			// Emitter dasselbe Altlast-Verzeichnis, koennte der zweite die frische,
			// bereits geflockte Lock-DATEI des ersten loeschen — zwei Inodes, dieselbe
			// Folgenummer. Das waere das Fehlerbild aus Runde-1-MEDIUM-5, in der
			// Reparatur von Runde-2-MEDIUM-1 wieder aufgemacht (Review Runde 3, F-2).
			// Rmdir scheitert an einer Datei und kann diesen Weg nicht gehen.
			if rmErr := syscall.Rmdir(path); rmErr != nil {
				return nil, err
			}
			f, err = os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o600)
		}
	}
	if err != nil {
		return nil, err
	}
	for range lockTries {
		if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB); err == nil {
			return f, nil
		}
		time.Sleep(lockWait)
	}
	_ = f.Close()
	return nil, errors.New("span: Sperre nicht erhalten")
}

// writeOwnerOnly schreibt und zieht den Modus nach. os.WriteFile setzt den Modus nur
// beim ANLEGEN; ein aus einer frueheren Fassung stammender Zaehler mit zu weitem Modus
// bliebe sonst dauerhaft zu weit (Verifier-Befund).
func writeOwnerOnly(file string, data []byte) error {
	if err := os.WriteFile(file, data, 0o600); err != nil {
		return err
	}
	if fi, err := os.Stat(file); err == nil && fi.Mode().Perm()&0o077 != 0 {
		return os.Chmod(file, 0o600)
	}
	return nil
}

// correlation leitet die drei ableitbaren Korrelations-Achsen aus Modul 15 ab:
// slice.id, requirement.id und adr.id. slice.id IST das Lifecycle-Verzeichnis
// (Modul 5) — kein Slice ergibt eine LEERE Liste, die als leer erkennbar bleibt statt
// geraten zu werden; mehrere ergeben alle. adr.id steht im selben Bezug-Block wie
// requirement.id und ist damit auf demselben Weg erreichbar; ihn wegzulassen und als
// Abweichung zu erklaeren waere gegen ADR-0011 Festlegung 1.4 gewesen ("Ableiten
// schlaegt deklarieren"). Die vierte Achse, agent.role, wird NICHT hier abgeleitet:
// sie haengt am LAUF, nicht am Repo-Zustand, und kommt aus dem Agenten-Typ
// (roleFromAgentType). Die frueher hier stehende Fassung nannte sie "nicht ableitbar"
// — das war schon im selben Commit ueberholt, in dem sie abgeleitet wurde
// (Review-Befund Runde 2, MEDIUM-3).
func correlation(root string) (slices, reqs, adrs []string) {
	slices, reqs, adrs = []string{}, []string{}, []string{}
	matches, err := filepath.Glob(filepath.Join(root, "docs/plan/planning/in-progress/slice-*.md"))
	if err != nil {
		return slices, reqs, adrs
	}
	sort.Strings(matches)
	seenReq, seenAdr := map[string]bool{}, map[string]bool{}
	for _, m := range matches {
		slices = append(slices, strings.TrimSuffix(filepath.Base(m), ".md"))
		r, a := references(m)
		for _, id := range r {
			if !seenReq[id] {
				seenReq[id] = true
				reqs = append(reqs, id)
			}
		}
		for _, id := range a {
			if !seenAdr[id] {
				seenAdr[id] = true
				adrs = append(adrs, id)
			}
		}
	}
	sort.Strings(reqs)
	sort.Strings(adrs)
	return slices, reqs, adrs
}

// references liest Anforderungs- und ADR-Kennungen NUR aus dem Bezug-Block, nicht aus
// der ganzen Datei: ein Slice erwaehnt im Fliesstext fremde Anforderungen
// (Praezedenzfaelle, Abgrenzungen), und die sind nicht sein Bezug (Review-Befund
// MEDIUM-2). Der Block reicht von der `**Bezug:**`-Zeile bis zur naechsten Leerzeile.
func references(file string) (reqs, adrs []string) {
	b, err := os.ReadFile(file)
	if err != nil {
		return nil, nil
	}
	reReq := regexp.MustCompile(`LH-[A-Z]{2}-[0-9]{2}`)
	reAdr := regexp.MustCompile(`ADR-[0-9]{4}`)
	inBlock := false
	for _, line := range strings.Split(string(b), "\n") {
		if strings.HasPrefix(line, "**Bezug:**") {
			inBlock = true
		} else if inBlock && strings.TrimSpace(line) == "" {
			break
		}
		if inBlock {
			reqs = append(reqs, reReq.FindAllString(line, -1)...)
			adrs = append(adrs, reAdr.FindAllString(line, -1)...)
		}
	}
	return reqs, adrs
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
