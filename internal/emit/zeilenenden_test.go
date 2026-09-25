package emit_test

import (
	"archive/zip"
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// zeilenendenZeile ist die eine Zeile, die jede emittierte .gitattributes traegt (ADR-0067
// Festlegung 2). Sie steht hier als eigene Zeichenkette, unabhaengig von der Emission: der
// Test haelt die Emission gegen diese Zeile.
const zeilenendenZeile = "* text=auto eol=lf"

// zeilenendenEmit legt die Ausgaenge des Werkzeugs ab, die ohne Docker und Netz entstehen:
// die Durchsetzungsschicht, die Wortlisten unter blocked/ beider Sprachen, das
// Verifikations-Skript samt Fragment und einen vendored Baum mit seiner Pruefsummen-Datei.
// Die Wurzel-Dateien (Makefile, d-check.mk, a-check.mk) legt der Test selbst daneben; die
// beiden .mk-Dateien erfuellen das Konsumenten-Kriterium und tragen die benannte Ausnahme der
// Wurzel.
func zeilenendenEmit(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, lang := range []string{"go", "cpp"} {
		if err := emit.BlockedFragment(dir, lang); err != nil {
			t.Fatalf("BlockedFragment(%s): %v", lang, err)
		}
	}
	if err := emit.BaselineVerify(dir); err != nil {
		t.Fatalf("BaselineVerify: %v", err)
	}
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	for _, name := range []string{"regelwerk/README.md", "templates/AGENTS.template.md"} {
		w, err := zw.Create(name)
		if err != nil {
			t.Fatalf("zip %s: %v", name, err)
		}
		if _, err := w.Write([]byte("inhalt\n")); err != nil {
			t.Fatalf("zip %s schreiben: %v", name, err)
		}
	}
	if err := zw.Close(); err != nil {
		t.Fatalf("zip schliessen: %v", err)
	}
	summe := sha256.Sum256(buf.Bytes())
	assetFetch := func(context.Context, string) (io.ReadCloser, error) {
		return io.NopCloser(bytes.NewReader(buf.Bytes())), nil
	}
	if err := fetch.Baseline(context.Background(), filepath.Join(dir, ".harness", "baseline"), "v0.0.0",
		hex.EncodeToString(summe[:]), assetFetch); err != nil {
		t.Fatalf("Baseline: %v", err)
	}
	for _, wurzel := range []string{"Makefile", "d-check.mk", "a-check.mk"} {
		if err := os.WriteFile(filepath.Join(dir, wurzel), []byte("all:\n\t@true\n"), 0o644); err != nil {
			t.Fatalf("%s schreiben: %v", wurzel, err)
		}
	}
	return dir
}

// zeilenendenKonsument sagt, ob eine emittierte Datei einen Konsumenten hat, an dessen Bytes
// er bricht: eine Shebang-Zeile, die Endung .sh/.awk/.mk, eine Wortliste unter blocked/, eine
// Datei unter .harness/ oder unter .githooks/ (ADR-0067 Festlegung 1). Die Menge der
// Verzeichnisse folgt daraus, sie steht nicht in diesem Test.
func zeilenendenKonsument(rel string, kopf []byte) bool {
	switch {
	case bytes.HasPrefix(kopf, []byte("#!")):
		return true
	case strings.HasSuffix(rel, ".sh"), strings.HasSuffix(rel, ".awk"), strings.HasSuffix(rel, ".mk"):
		return true
	case strings.Contains(rel, "/blocked/"):
		return true
	case strings.HasPrefix(rel, ".harness/"), strings.HasPrefix(rel, ".githooks/"):
		return true
	}
	return false
}

// zeilenendenTraegtDieZeile sagt, ob die .gitattributes am Pfad die Zeile als eigene Zeile
// traegt. Eine Zeile mit anderem Muster (ein Endungs-Glob) oder anderem Wert (eol=crlf) zaehlt
// nicht.
func zeilenendenTraegtDieZeile(t *testing.T, pfad string) bool {
	t.Helper()
	roh, err := os.ReadFile(pfad)
	if err != nil {
		return false
	}
	for _, zeile := range strings.Split(string(roh), "\n") {
		if strings.TrimSpace(zeile) == zeilenendenZeile {
			return true
		}
	}
	return false
}

// zeilenendenEolWert fragt git, welchen eol-Wert es jedem der Pfade im Baum unter dir zuweist:
// `git check-attr eol` wertet die .gitattributes des Arbeitsbaums so, wie ein Klon sie wertet —
// die Wirkung aller Zeilen in der Reihenfolge, in der git sie anwendet, nicht die Anwesenheit
// einer Zeile. Die Antwort ist "lf", "crlf", "unspecified" oder ein anderer Wert; fehlt einem
// Pfad die Antwort, bricht der Test ab. Das Test-Image traegt git (Dockerfile, Stage `test`);
// fehlt es, bricht der Test ab, statt zu bestehen.
func zeilenendenEolWert(t *testing.T, dir string, rels []string) map[string]string {
	t.Helper()
	git := func(stdin string, args ...string) string {
		var stdout, stderr bytes.Buffer
		cmd := exec.Command("git", append([]string{"-C", dir}, args...)...)
		cmd.Env = append(os.Environ(), "GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1")
		cmd.Stdin = strings.NewReader(stdin)
		cmd.Stdout, cmd.Stderr = &stdout, &stderr
		if err := cmd.Run(); err != nil {
			t.Fatalf("git %s: %v: %s", strings.Join(args, " "), err, stderr.String())
		}
		return stdout.String()
	}
	git("", "init", "-q")
	out := git(strings.Join(rels, "\x00")+"\x00", "check-attr", "-z", "--stdin", "eol")
	felder := strings.Split(strings.TrimSuffix(out, "\x00"), "\x00")
	if len(felder) != 3*len(rels) {
		t.Fatalf("git check-attr liefert %d Felder fuer %d Pfade (erwartet 3 je Pfad):\n%q", len(felder), len(rels), out)
	}
	wert := map[string]string{}
	for i := 0; i < len(felder); i += 3 {
		wert[felder[i]] = felder[i+2]
	}
	for _, rel := range rels {
		if _, ok := wert[rel]; !ok {
			t.Fatalf("git check-attr nennt keinen eol-Wert fuer %s:\n%q", rel, out)
		}
	}
	return wert
}

// Rot-Gegenbeispiele: test/mutations/446-zeilenenden-eintrag-entfaellt.sh (ein Verzeichnis
// verliert seine .gitattributes), test/mutations/447-zeilenenden-zeile-eol-crlf.sh (die Zeile
// legt CRLF fest), test/mutations/448-zeilenenden-zeile-endungs-glob.sh (die Zeile erfasst
// nur `*.sh`) und test/mutations/451-zeilenenden-spaetere-zeile-ueberstimmt.sh (eine spaetere
// Zeile setzt eol=crlf).
//
// TestZeilenenden_JederKonsumentLiegtUnterEinerZeile haelt die EIGENSCHAFT und nicht die
// Verzeichnis-Liste der Emission (ADR-0067 Festlegung 1, Fitness-Zeile 1): jede emittierte Datei
// mit Interpreter- oder Byte-Konsument unterhalb der Wurzel bekommt von git den Wert eol=lf. Die
// erwartete Menge kommt aus dem emittierten Baum und dem Kriterium, nicht aus der Liste, die die
// Emission liest; der Wert kommt von git und deckt damit jede Zeile jeder emittierten
// .gitattributes, nicht nur die eine Zeile der Vorlage.
//
// AUSNAHME, benannt: die Datei liegt in der Wurzel des Ziels (Makefile, d-check.mk, a-check.mk).
// Die Wurzel gehoert dem Adopter; die Ausnahme gilt nur dort — dieselbe Endung in einem
// Unterverzeichnis faellt unter das Kriterium.
//
// GRENZE: git wertet die Dateien des Arbeitsbaums im Test-Ziel; eine .gitattributes in der Wurzel
// des Adopters und core.autocrlf liegen ausserhalb des Test-Ziels (die Stufe `zeilenenden_im_klon`
// in harness/tools/full-smoke.sh fuehrt den Klon mit core.autocrlf=true).
//
// VORBEDINGUNG: jede der sechs Klassen von Konsumenten ist im emittierten Baum vertreten; eine
// Klasse ohne Vertreter misst nichts, und der Test bricht dann ab, statt ueber ihr zu bestehen.
func TestZeilenenden_JederKonsumentLiegtUnterEinerZeile(t *testing.T) {
	dir := zeilenendenEmit(t)
	vertreten := map[string]int{}
	var konsumenten []string
	err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		rel, err := filepath.Rel(dir, p)
		if err != nil {
			return err
		}
		rel = filepath.ToSlash(rel)
		if !strings.Contains(rel, "/") {
			return nil // die Wurzel des Ziels: benannte Ausnahme
		}
		f, err := os.Open(p)
		if err != nil {
			return err
		}
		defer func() { _ = f.Close() }()
		kopf := make([]byte, 2)
		n, _ := io.ReadFull(f, kopf)
		if !zeilenendenKonsument(rel, kopf[:n]) {
			return nil
		}
		konsumenten = append(konsumenten, rel)
		for _, klasse := range []string{"tools/harness/", "harness/mk/", ".claude/hooks/", ".githooks/", ".harness/baseline/", "/blocked/"} {
			if strings.Contains(rel, klasse) {
				vertreten[klasse]++
			}
		}
		return nil
	})
	if err != nil {
		t.Fatalf("emittierten Baum lesen: %v", err)
	}
	for _, klasse := range []string{"tools/harness/", "harness/mk/", ".claude/hooks/", ".githooks/", ".harness/baseline/", "/blocked/"} {
		if vertreten[klasse] == 0 {
			t.Fatalf("der emittierte Baum traegt keinen Konsumenten unter %s — die Richtung dieser Klasse misst nichts", klasse)
		}
	}
	wert := zeilenendenEolWert(t, dir, konsumenten)
	for _, rel := range konsumenten {
		if wert[rel] != "lf" {
			t.Errorf("%s hat einen Interpreter- oder Byte-Konsumenten, aber git weist ihr eol=%s zu (verlangt: lf) — die emittierten .gitattributes legen sie nicht mit %q auf LF fest, und im Klon mit core.autocrlf=true liegt die Datei dann mit CRLF", rel, wert[rel], zeilenendenZeile)
		}
	}
}

// Rot-Gegenbeispiele: test/mutations/449-zeilenenden-meldung-ohne-aussage.sh (die Meldung
// nennt nur noch den Pfad) und test/mutations/450-zeilenenden-klasse-wird-konvergent.sh (ein
// skip-if-present-Pfad wird konvergent — die liegende Datei verschwindet).
//
// TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet haelt die Klasse je Pfad (ADR-0067
// Festlegung 3 und 4). Die drei skip-if-present-Pfade behalten eine liegende Datei ohne
// `eol=lf` Byte fuer Byte, und die Meldung des Laufs nennt den Pfad UND die Aussage, was dann
// gilt — die Zeile fehlt, die Dateien des Verzeichnisses tragen im Klon mit core.autocrlf=true
// CRLF. Die zwei konvergenten Pfade kehren nach einer Verstellung auf die Fassung des Werkzeugs
// zurueck und melden nichts. Ein freier skip-if-present-Pfad wird geschrieben und schweigt.
//
// Die Klassen stehen hier als eigene Aufzaehlung, unabhaengig von PathClass: sie sind die
// Festlegung der ADR, und der Test haelt die Klasse je Pfad gegen diese Festlegung.
func TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet(t *testing.T) {
	skip := []string{"harness/mk/.gitattributes", ".claude/hooks/.gitattributes", ".githooks/.gitattributes"}
	konvergent := []string{".harness/.gitattributes", "tools/harness/.gitattributes"}
	const fremd = "# eigene Datei des Adopters\n* text=auto\n"

	// Ein FREIER Pfad wird geschrieben, ohne Meldung zu diesem Pfad.
	frei := t.TempDir()
	var freiNotice bytes.Buffer
	if err := emit.Enforce(frei, &freiNotice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, rel := range append(append([]string{}, skip...), konvergent...) {
		if !zeilenendenTraegtDieZeile(t, filepath.Join(frei, filepath.FromSlash(rel))) {
			t.Errorf("%s liegt nach dem Lauf in ein leeres Ziel nicht mit %q", rel, zeilenendenZeile)
		}
		if strings.Contains(freiNotice.String(), rel) {
			t.Errorf("der Lauf meldet den freien Pfad %s — die Meldung gilt nur einem belegten:\n%s", rel, freiNotice.String())
		}
	}

	// Ein BELEGTER Pfad: die drei skip-if-present-Dateien und die zwei konvergenten tragen fremden Inhalt.
	dir := t.TempDir()
	for _, rel := range append(append([]string{}, skip...), konvergent...) {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatalf("%s anlegen: %v", filepath.Dir(rel), err)
		}
		if err := os.WriteFile(p, []byte(fremd), 0o644); err != nil {
			t.Fatalf("%s belegen: %v", rel, err)
		}
	}
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("Enforce (kein Refuse erwartet): %v", err)
	}
	meldung := notice.String()
	for _, rel := range skip {
		if got := mustReadString(t, filepath.Join(dir, filepath.FromSlash(rel))); got != fremd {
			t.Errorf("%s wurde ueberschrieben (skip-if-present verletzt): %q", rel, got)
		}
		zeile := ""
		for _, z := range strings.Split(meldung, "\n") {
			if strings.Contains(z, rel) {
				zeile = z
			}
		}
		if zeile == "" {
			t.Errorf("die Meldung nennt den belegten Pfad %s nicht:\n%s", rel, meldung)
			continue
		}
		for _, aussage := range []string{zeilenendenZeile, "core.autocrlf=true", "CRLF", path.Dir(rel) + "/"} {
			if !strings.Contains(zeile, aussage) {
				t.Errorf("die Meldung zu %s nennt %q nicht — sie sagt dann nicht, was gilt:\n%s", rel, aussage, zeile)
			}
		}
	}
	for _, rel := range konvergent {
		if !zeilenendenTraegtDieZeile(t, filepath.Join(dir, filepath.FromSlash(rel))) {
			t.Errorf("%s wurde nicht kanonisch neu geschrieben (konvergent verletzt)", rel)
		}
		if strings.Contains(meldung, rel) {
			t.Errorf("der Lauf meldet den konvergenten Pfad %s — dort gibt es den Zustand \"liegt bereits\" nicht:\n%s", rel, meldung)
		}
	}
}
