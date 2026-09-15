package emit_test

import (
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// commitMsgZiel faehrt einen echten Emit in ein frisches Verzeichnis und liefert
// dessen Wurzel. GELESEN wird von der Platte: die Zusage gilt den drei Dateien im
// Ziel, nicht dem Rueckgabewert einer Funktion.
func commitMsgZiel(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	return dir
}

// Rot-Gegenbeispiel: test/mutations/348-traeger-hook-faellt-aus-dem-emit.sh.
//
// TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf haelt fest, dass der
// Hook nicht auf ein Programm zeigt, das der Bootstrap nicht ablegt: beide Dateien
// liegen an ihren Zielorten, sind ausfuehrbar, und die im Hook genannte Adresse
// loest — gegen sein eigenes Verzeichnis aufgeloest — auf den Zielort der Pruefung
// auf.
//
// Warum das Ausfuehrrecht hier gemessen wird: git verwirft einen Hook ohne x-Bit
// STILL. Ein Traeger ohne es saehe wie einer aus und pruefte nichts (LH-QA-01).
//
// Warum das Aufloesen und nicht der Zeichenketten-Vergleich: die zwei Zielorte
// kommen aus zwei Konstanten, und die Zusage gilt ihrem Verhaeltnis zueinander. Ein
// Vergleich der Zeichenkette gegen sich selbst bliebe gruen, wenn beide auf einen
// Ort zeigten, an dem nichts liegt.
func TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf(t *testing.T) {
	dir := commitMsgZiel(t)

	for _, rel := range []string{emit.CommitMsgHookPath, emit.CommitMsgCheckPath} {
		pfad := filepath.Join(dir, filepath.FromSlash(rel))
		info, err := os.Stat(pfad)
		if err != nil {
			t.Fatalf("%s liegt nicht im Ziel: %v", rel, err)
		}
		if info.Mode().Perm()&0o111 == 0 {
			t.Errorf("%s ist nicht ausfuehrbar (%v) — git verwirft einen Hook ohne Ausfuehrungsrecht still",
				rel, info.Mode().Perm())
		}
	}

	hook := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.CommitMsgHookPath)))
	const aufruf = `bash "$here/`
	i := strings.Index(hook, aufruf)
	if i < 0 {
		t.Fatalf("%s ruft die Pruefung nicht ueber sein eigenes Verzeichnis auf — die zwei Dateien waeren damit nicht aneinander gebunden:\n%s",
			emit.CommitMsgHookPath, hook)
	}
	rest := hook[i+len(aufruf):]
	j := strings.Index(rest, `"`)
	if j < 0 {
		t.Fatalf("%s: der Aufruf der Pruefung ist nicht abgeschlossen:\n%s", emit.CommitMsgHookPath, hook)
	}
	hookDir := filepath.Join(dir, filepath.Dir(filepath.FromSlash(emit.CommitMsgHookPath)))
	aufgeloest := filepath.Clean(filepath.Join(hookDir, filepath.FromSlash(rest[:j])))
	if want := filepath.Join(dir, filepath.FromSlash(emit.CommitMsgCheckPath)); aufgeloest != want {
		t.Errorf("%s ruft %s auf; erwartet ist %s — der Hook zeigt auf einen Ort, an dem der Bootstrap nichts ablegt",
			emit.CommitMsgHookPath, aufgeloest, want)
	}

	// DAS LOKALE LAYOUT IST NICHT DAS EMITTIERTE (MR-005): nennt der Hook
	// harness/tools/, zeigt er in einem gebootstrappten Ziel ins Leere.
	if strings.Contains(hook, "harness/tools/") {
		t.Errorf("%s nennt das lokale harness/tools/ (MR-005, emittiertes Layout ist tools/harness/):\n%s",
			emit.CommitMsgHookPath, hook)
	}
}

// Rot-Gegenbeispiel: test/mutations/353-traeger-ohne-umgehungs-zeile.sh.
//
// TestCommitMsgTraeger_NenntSeineZweiGrenzen haelt den TEXT der zwei Grenzen fest,
// die zur Traegerschaft gehoeren: die Aktivierung reist nicht mit dem Klon, und
// `--no-verify` umgeht den Hook.
//
// WAS DIESER TEST NICHT MISST, und wo der Beleg dafuer liegt: dass die zwei Grenzen
// im gebootstrappten Ziel WIRKEN. Das ist ein realer Commit-Versuch und steht in
// harness/tools/full-smoke.sh (rote Message, gruene Message, Umgehung) — ein
// Zeichenketten-Fang kann ihn nicht ersetzen.
func TestCommitMsgTraeger_NenntSeineZweiGrenzen(t *testing.T) {
	dir := commitMsgZiel(t)
	hook := mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.CommitMsgHookPath)))

	for _, satz := range []string{"core.hooksPath", "reist nicht mit dem", "--no-verify", "make hooks-install"} {
		if !strings.Contains(hook, satz) {
			t.Errorf("%s nennt %q nicht — eine Grenze, die nicht neben der Zusage steht, ist keine:\n%s",
				emit.CommitMsgHookPath, satz, hook)
		}
	}
}

// Rot-Gegenbeispiel: test/mutations/349-aktivierung-haengt-an-gate-checks.sh.
//
// TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger haelt die zwei Adressen
// des Aktivierungs-Fragments fest: es definiert das Kommando, und es haengt an
// keiner Gate-Kante.
//
// Der Grund ist der der uebrigen Werkzeug-Fragmente: das Ziel SCHREIBT lokale
// Konfiguration. Ein Gate darueber faerbte rot, weil ein Klon seine Aktivierung noch
// nicht hat — dieselbe Verwechslung, gegen die die zwei Werkzeug-Fragmente des
// Ziels antreten.
func TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger(t *testing.T) {
	frag := mustReadString(t, filepath.Join(commitMsgZiel(t), filepath.FromSlash(emit.HooksInstallMkPath)))

	regeln, checks := regelnIn(frag)
	if _, da := regeln["hooks-install"]; !da {
		t.Errorf("%s definiert das Ziel %q nicht — ein Traeger ohne Aktivierung ist ungeprueft:\n%s",
			emit.HooksInstallMkPath, "hooks-install", frag)
	}
	if len(checks) != 0 {
		t.Errorf("%s haengt %v an GATE_CHECKS — es traegt ein Kommando, kein Gate", emit.HooksInstallMkPath, checks)
	}
	if huelle := gatesHuelle(t); huelle["hooks-install"] {
		t.Errorf("%q haengt in der gates-Kette des Ziels — die Aktivierung schreibt lokale Konfiguration: %v",
			"hooks-install", sortiert(huelle))
	}

	// Die Adresse des Traegers im Fragment und die Konstante muessen dieselbe sein:
	// das Fragment nennt sie ueber eine Variable, die Vorgabe ist der Zielort.
	if !strings.Contains(frag, filepath.Base(filepath.FromSlash(emit.CommitMsgHookPath))) {
		t.Errorf("%s nennt den Namen des Traegers nicht (%s) — das Ziel zeigt damit auf nichts:\n%s",
			emit.HooksInstallMkPath, filepath.Base(filepath.FromSlash(emit.CommitMsgHookPath)), frag)
	}
	if !strings.Contains(frag, "core.hooksPath") {
		t.Errorf("%s nennt nicht, was es setzt — der Aufruf waere eine Konfiguration ohne Gegenstand:\n%s",
			emit.HooksInstallMkPath, frag)
	}
}

// Rot-Gegenbeispiel: test/mutations/352-aktivierung-ohne-reichweiten-zeile.sh.
//
// TestHooksInstallFragment_TraegtDieReichweite steht fuer die Zusage aus der
// DoD-Reichweiten-Haelfte: was der Traeger NICHT erreicht, steht neben dem, was er
// erreicht. Gemessen wird der Text, nicht seine Wirkung — die zweite Haelfte der
// Traceability-Regel ist von keinem Commit-Waechter pruefbar, und genau das muss
// dastehen.
func TestHooksInstallFragment_TraegtDieReichweite(t *testing.T) {
	frag := mustReadString(t, filepath.Join(commitMsgZiel(t), filepath.FromSlash(emit.HooksInstallMkPath)))
	flach := strings.Join(strings.Fields(frag), " ")

	for _, satz := range []string{
		"nicht mechanisch pruefbar",
		"ANWESENHEIT einer Kennung, nicht ihre Wahrheit",
		"--no-verify",
		"weder Docker",
	} {
		if !strings.Contains(flach, satz) {
			t.Errorf("%s fuehrt %q nicht — die Reichweiten-Zusage ist damit weiter als der Traeger:\n%s",
				emit.HooksInstallMkPath, satz, frag)
		}
	}
}

// Rot-Gegenbeispiel: test/mutations/351-emittierte-config-fuehrt-eine-zweite-kennungs-menge.sh.
//
// TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge haelt die Zusage aus
// harness/README.md §Traceability fest: der Bootstrap legt neben der Pruefung keine
// zweite Fassung der Kennungs-Menge ab, und die Doku-Gate-Konfiguration des Ziels
// traegt keine. Kommt dort ein `commits:`-Block hinzu, ist die README-Zeile
// nachzuziehen — die Pruefung des Traegers liest ihn nicht, die zwei Fassungen
// liefen also auseinander, ohne dass eine Stelle es merkte.
func TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge(t *testing.T) {
	cfg := emit.DCheckConfig()
	if cfg == "" {
		t.Fatal("die eingebettete .d-check.yml ist leer — der Waechter misst dann nichts")
	}
	if strings.Contains(cfg, "\ncommits:") {
		t.Error("die emittierte .d-check.yml fuehrt einen commits:-Block — harness/README.md §Traceability sagt zu, dass die Kennungs-Menge allein in der Pruefung des Traegers steht")
	}
}

// Rot-Gegenbeispiel: test/mutations/350-anleitung-ohne-aktivierung-des-traegers.sh.
//
// TestCommitMsgAnweisung_NenntTraegerUndAktivierung haelt die Konvention fest, an
// der der Traeger haengt: der mitemittierte Anweisungssatz nennt ihn und den
// Schritt, der ihn aktiviert.
//
// Ohne diesen Satz ist der Traeger im Ziel unsichtbar: er liegt da, reist mit dem
// Klon und schweigt, bis jemand `core.hooksPath` setzt — und keine Zeile sagt, dass
// es ihn gibt.
func TestCommitMsgAnweisung_NenntTraegerUndAktivierung(t *testing.T) {
	anleitung := string(emit.CommandFile(".claude/commands/implement-slice.md"))
	if anleitung == "" {
		t.Fatal(".claude/commands/implement-slice.md nicht emittiert (CommandFile leer)")
	}
	for _, satz := range []string{emit.CommitMsgHookPath, "make hooks-install", "--no-verify"} {
		if !strings.Contains(anleitung, satz) {
			t.Errorf("der Anweisungssatz nennt %q nicht — der Traeger haengt damit an einer Konvention ohne Traeger:\n%s",
				satz, anleitung)
		}
	}
}
