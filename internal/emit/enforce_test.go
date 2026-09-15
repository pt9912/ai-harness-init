package emit_test

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"os"
	"path"
	"path/filepath"
	"reflect"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/gen"
)

// TestEnforce_EmitsAllMechanicFiles: die Durchsetzungsschicht (LH-FA-06) landet
// vollstaendig im Ziel — Gate-Nachweis (record-gates + working-tree-hash),
// Stop-Hook (stop-require-gates + settings.json), state/-Ignore UND Command-Guard
// (pretooluse-command-guard.sh + extract-command.awk, slice-032). EnforcePaths und
// der reale Emit koppeln denselben Bestand: der Pre-Flight (cmd Phase 3) sieht
// dieselbe Menge wie der Emit (Phase 4), sonst Teil-Bootstrap-Luecke.
func TestEnforce_EmitsAllMechanicFiles(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, rel := range emit.EnforcePaths() {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s nicht emittiert: %v", rel, err)
		}
	}
	// Die konkreten Zielpfade sind Vertrag (Stop-Hook + record-gates + Guard
	// referenzieren tools/harness/; der Stempel-Ignore muss .harness/.gitignore sein;
	// der Guard braucht den awk-Extraktor mit-emittiert, sonst laeuft er ins Leere).
	// blocked/<lang> gehoert seit slice-037 NICHT mehr hierher (skip-if-present, add-lang).
	want := []string{
		"tools/harness/working-tree-hash.sh",
		"tools/harness/record-gates.sh",
		".claude/hooks/stop-require-gates.sh",
		".claude/settings.json",
		".harness/.gitignore",
		".claude/hooks/pretooluse-command-guard.sh",
		"tools/harness/extract-command.awk",
		// Vorlauf-Waechter der zwei history-lesenden d-check-Targets: er liegt im
		// emittierten tools/harness/ (MR-005) und wird vom Doc-Gate-Fragment als
		// Vorbedingung vor doc-immutable/doc-commits gehaengt.
		"tools/harness/history-range-guard.sh",
		"harness/mk/enforce.mk",
		// Aufraeum- und Berichts-Fragment (slice-099): UNBEDINGT, also im
		// Kollisions-Pre-Flight — anders als Wrapper und Feldliste, die den Zweig des
		// Traegers teilen.
		"harness/mk/erfassung.mk",
	}
	got := strings.Join(emit.EnforcePaths(), "\n")
	for _, w := range want {
		if !strings.Contains(got, w) {
			t.Errorf("EnforcePaths fehlt %q — Ziel-Layout-Vertrag verletzt", w)
		}
	}
	// SPRACH-AGNOSTISCH (slice-037): EnforcePaths traegt KEIN blocked/<lang> — das ist
	// skip-if-present und wandert per add-lang, nicht ueber den Kollisions-Pre-Flight.
	if strings.Contains(got, "blocked/") {
		t.Errorf("EnforcePaths traegt ein blocked/-Fragment — das gehoert seit slice-037 zu add-lang (BlockedFragment):\n%s", got)
	}
	// Enforce selbst legt sprachlos KEIN blocked/ an.
	if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash("tools/harness/blocked"))); !os.IsNotExist(err) {
		t.Errorf("Enforce legte ein blocked/-Fragment an (soll sprach-agnostisch sein): %v", err)
	}
}

// TestEnforce_ScriptsExecutable: ein nicht ausfuehrbarer Hook/Tool-Nachweis waere
// eine leere Zusage — Claude ruft den Stop-Hook, make ruft record-gates.
func TestEnforce_ScriptsExecutable(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, rel := range []string{
		"tools/harness/working-tree-hash.sh",
		"tools/harness/record-gates.sh",
		"tools/harness/history-range-guard.sh",
		".claude/hooks/stop-require-gates.sh",
		".claude/hooks/pretooluse-command-guard.sh",
	} {
		info, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel)))
		if err != nil {
			t.Fatalf("%s: %v", rel, err)
		}
		if info.Mode().Perm()&0o111 == 0 {
			t.Errorf("%s Mode %v — nicht ausfuehrbar", rel, info.Mode().Perm())
		}
	}
}

// TestEnforce_SettingsWiresBothHooks: die emittierte settings.json verdrahtet BEIDE
// Hooks — den Stop-Hook (slice-031) UND den PreToolUse-Command-Guard (slice-032,
// Matcher Bash). Die slice-031-Grenze „Stop-only" ist mit slice-032 aufgehoben; der
// Guard-Verweis zeigt jetzt auf ein real mit-emittiertes Skript.
func TestEnforce_SettingsWiresBothHooks(t *testing.T) {
	settings := string(emit.EnforceFile(".claude/settings.json"))
	for _, want := range []string{
		`"Stop"`, "stop-require-gates.sh",
		"PreToolUse", `"matcher": "Bash"`, "pretooluse-command-guard.sh",
	} {
		if !strings.Contains(settings, want) {
			t.Errorf("settings.json verdrahtet %q nicht:\n%s", want, settings)
		}
	}
}

// TestEnforce_GuardBakedFloorAndUnion (slice-036, LH-FA-06/LH-QA-03): der emittierte Guard
// traegt den universellen Boden GEBACKEN (BLOCKED="apt ...") — kein @@BLOCKED_SET@@-
// Platzhalter mehr — und liest+vereinigt tools/harness/blocked/* (bash+cat). So blockt er
// sprachlos schon die Paketmanager (fail-safe, nie fail-open); die Sprach-Toolchain kommt
// als blocked/<lang>-Fragment. Rot-Gegenbeispiel: test/mutations entfernt den Boden -> rot.
func TestEnforce_GuardBakedFloorAndUnion(t *testing.T) {
	guard := string(emit.EnforceFile(".claude/hooks/pretooluse-command-guard.sh"))
	if strings.Contains(guard, "@@BLOCKED_SET@@") {
		t.Error("Guard traegt noch @@BLOCKED_SET@@ — der Boden ist seit slice-036 gebacken, nicht substituiert")
	}
	if !strings.Contains(guard, `BLOCKED="apt`) {
		t.Error(`Guard traegt den gebackenen Boden nicht (BLOCKED="apt ...") — fail-open-Risiko (ADR-0007 NEU-H1)`)
	}
	for _, floor := range []string{"pip", "npm", "cargo"} {
		if !strings.Contains(guard, floor) {
			t.Errorf("gebackener Boden unvollstaendig — %q fehlt", floor)
		}
	}
	for _, union := range []string{"blocked_dir=", "tools/harness/blocked", "cat "} {
		if !strings.Contains(guard, union) {
			t.Errorf("Guard liest die blocked/*-Union nicht (%q fehlt) — add-lang-Fragmente waeren wirkungslos (LH-QA-03)", union)
		}
	}
}

// TestBlockedFragment_Drops (slice-037): BlockedFragment mit gen-Profil schreibt
// tools/harness/blocked/<lang> mit der Sprach-Toolchain; eine Sprache OHNE Profil (leer)
// ist ein no-op (sprachlos greift der gebackene Guard-Boden allein).
func TestBlockedFragment_Drops(t *testing.T) {
	dir := t.TempDir()
	if err := emit.BlockedFragment(dir, "go"); err != nil {
		t.Fatalf("BlockedFragment(go): %v", err)
	}
	frag := mustReadString(t, filepath.Join(dir, filepath.FromSlash("tools/harness/blocked/go")))
	if !strings.Contains(frag, "go gofmt golangci-lint staticcheck") {
		t.Errorf("blocked/go traegt die go-Toolchain nicht: %q", frag)
	}
	dir2 := t.TempDir()
	if err := emit.BlockedFragment(dir2, ""); err != nil {
		t.Fatalf("BlockedFragment(sprachlos): %v", err)
	}
	if _, err := os.Stat(filepath.Join(dir2, filepath.FromSlash("tools/harness/blocked"))); !os.IsNotExist(err) {
		t.Errorf("BlockedFragment(sprachlos) legte ein blocked/-Fragment an: %v", err)
	}
}

// TestBlockedFragment_Convergent (slice-038, Review-I-1-Versoehnung): blocked/<sprache>
// ist KONVERGENT (ADR-0007 Z.100), nicht mehr skip-if-present wie slice-037. Ein zweiter
// Drop schreibt kanonisch neu (heilt Drift, byte-identisch) — auch im Mono-Repo idempotent,
// weil der Inhalt tool-fixiert ist. Rot-Gegenbeispiel: eine Mutation, die wieder skippt,
// laesst die Drift stehen (unten: die adopter-modifizierte Fassung ueberlebt faelschlich).
func TestBlockedFragment_Convergent(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash("tools/harness/blocked/go"))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(dst, []byte("adopter-modifiziert\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	// konvergent: kein Refuse, kanonisch neu (Drift geheilt).
	if err := emit.BlockedFragment(dir, "go"); err != nil {
		t.Fatalf("BlockedFragment (konvergent darf nicht fehlschlagen): %v", err)
	}
	if got := mustReadString(t, dst); !strings.Contains(got, "go gofmt golangci-lint") {
		t.Errorf("konvergenter Re-Lauf hat blocked/go NICHT kanonisch neu geschrieben (Drift nicht geheilt): %q", got)
	}
}

// TestBlockedFragment_CoversAllGenProfiles koppelt die blocked/<lang>-Fragmente an
// gen.SupportedLangs(): jedes Profil, das gen bootstrappen kann, MUSS ein nicht-leeres
// Sprach-BLOCKED-Fragment haben — sonst liefe im gebootstrappten Ziel die Host-Toolchain
// der Sprache ungehindert (stille Luecke). Ein unbekanntes lang liefert ein leeres Fragment.
func TestBlockedFragment_CoversAllGenProfiles(t *testing.T) {
	if emit.BlockedFragmentForLang("___unbekannt___") != "" {
		t.Error("unbekannte Sprache liefert ein nicht-leeres blocked-Fragment (soll leer sein)")
	}
	for _, lang := range gen.SupportedLangs() {
		if emit.BlockedFragmentForLang(lang) == "" {
			t.Errorf("gen-Profil %q hat kein blocked/<lang>-Fragment — Host-Toolchain liefe ungehindert (stille Luecke)", lang)
		}
	}
}

// TestEnforce_GuardBashAwkOnly (LH-QA-03): der emittierte Guard nutzt awk als
// JSON-Parser (nicht jq/node) und referenziert den Extraktor am emittierten
// tools/harness/-Pfad (MR-005). Ein reiner String-Grep auf „jq"/„node" waere
// bruechig — beide stehen im erklaerenden „KEIN node/jq"-Kommentar; die
// verbindliche Abhaengigkeits-Zusage belegt der behaviorale full-smoke-Lauf (Guard
// laeuft dort mit bash + awk). Hier die positiven Struktur-Anker.
func TestEnforce_GuardBashAwkOnly(t *testing.T) {
	guard := string(emit.EnforceFile(".claude/hooks/pretooluse-command-guard.sh"))
	if !strings.Contains(guard, "awk -f") {
		t.Error("Guard nutzt nicht `awk -f` — der bash+awk-Parser fehlt (LH-QA-03)")
	}
	if strings.Contains(guard, "harness/tools/extract-command.awk") {
		t.Error("Guard referenziert das lokale harness/tools/ statt des emittierten tools/harness/ (MR-005)")
	}
	if !strings.Contains(guard, "tools/harness/extract-command.awk") {
		t.Error("Guard referenziert den awk-Extraktor nicht am emittierten Pfad")
	}
}

// TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit (LH-QA-03): der emittierte
// Vorlauf-Waechter entscheidet ueber die Commit-Zahl der angeforderten Range — der Wert,
// an dem der Leerfall haengt — und ruft dazu `git`, kein Image.
//
// DIE ANKER SIND DIE AUFGERUFENEN FORMEN, NICHT IHRE STICHWORTE. Der Kopfkommentar des
// Skripts nennt dieselben Kommandos und dieselben Zweige, die es ausfuehrt: ein Anker auf
// ein Stichwort waere aus der Prosa erfuellbar und bliebe gruen, wenn die Ausfuehrung
// selbst wegfaellt. Geprueft wird darum die Aufrufform samt Argument
// (`git rev-list --count "$range"`), die Vergleichsform des `--staged`-Zweigs
// (`[ "$range" = "--staged" ]`) und der Wortlaut der Leerfall-Meldung, den der Code nur
// im Fehlerzweig ausgibt.
//
// DIE ABWESENHEIT WIRD HIER NICHT GEGREPT: „docker" steht im erklaerenden Kopfkommentar,
// und ein String-Grep darauf waere bruechig (dieselbe Grenze, die
// TestEnforce_GuardBashAwkOnly fuer „node/jq" benennt). Geprueft werden die positiven
// Struktur-Anker; dass der Modul-Lauf wirklich NICHT stattfindet, belegen der Lauf selbst
// (harness/tools/full-smoke.sh: der Abbruch nennt keine geprueften Dateien) und die
// Vorbedingungs-Bindung im Doc-Gate-Fragment.
func TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit(t *testing.T) {
	guard := string(emit.EnforceFile("tools/harness/history-range-guard.sh"))
	if guard == "" {
		t.Fatal("tools/harness/history-range-guard.sh nicht emittiert (EnforceFile leer)")
	}
	for _, want := range []string{
		`git rev-list --count "$range"`,
		`[ "$range" = "--staged" ]`,
		"set -euo pipefail",
	} {
		if !strings.Contains(guard, want) {
			t.Errorf("der Vorlauf-Waechter traegt %q nicht:\n%s", want, guard)
		}
	}
	// Der Leerfall ist der Fall, den er faengt — die Meldung ist Teil des Vertrags (ein
	// Abbruch ohne Grund waere von einem Tippfehler nicht zu unterscheiden).
	if !strings.Contains(guard, "ist aufloesbar, aber LEER (0 Commits)") {
		t.Errorf("der Waechter meldet den Leerfall nicht:\n%s", guard)
	}
	if strings.Contains(guard, "harness/tools/") {
		t.Errorf("der Waechter nennt das lokale harness/tools/ (MR-005, emittiertes Layout ist tools/harness/):\n%s", guard)
	}
}

// TestEnforce_ZielpfadeImEmittiertenLayout (MR-005): der Emit legt die Mechanik unter
// tools/harness/ ab, nie unter dem lokal adaptierten harness/tools/. Geprueft wird die
// GANZE emittierte Pfad-Menge, nicht der jeweils neue Eintrag: eine Pruefung je Eintrag
// greift erst, wenn jemand ihren Check nachzieht, und ein Skript am lokalen Layout faellt
// dann durch keine Stelle.
//
// GRENZE: geprueft ist der ZIELPFAD. Der INHALT eines Skripts darf das lokale Layout nennen
// (span-emit.sh nennt den Repo-Pfad, den es beschreibt) — eine Inhalts-Allgemeinpruefung
// waere darum keine Regel-Aussage.
func TestEnforce_ZielpfadeImEmittiertenLayout(t *testing.T) {
	for _, rel := range emit.EnforcePaths() {
		if strings.Contains(rel, "harness/tools/") {
			t.Errorf("emittierter Zielpfad %q liegt im lokalen harness/tools/ — emittiert ist tools/harness/ (MR-005)", rel)
		}
	}
}

// TestEnforce_EmitsGateFragment: das Enforce-Fragment harness/mk/enforce.mk (slice-034)
// traegt das record-gates-Rezept, das tools/harness/record-gates.sh ruft. Die
// Ordnungskante (record-gates: $(GATE_CHECKS)) lebt bewusst NICHT hier, sondern im
// Root-Aggregator — sie braucht GATE_CHECKS erst nach dem Glob-Include vollstaendig.
func TestEnforce_EmitsGateFragment(t *testing.T) {
	frag := string(emit.EnforceFile("harness/mk/enforce.mk"))
	if frag == "" {
		t.Fatal("harness/mk/enforce.mk nicht emittiert (EnforceFile leer)")
	}
	for _, want := range []string{".PHONY: record-gates", "record-gates:", "tools/harness/record-gates.sh"} {
		if !strings.Contains(frag, want) {
			t.Errorf("Enforce-Fragment enthaelt %q nicht:\n%s", want, frag)
		}
	}
	if strings.Contains(frag, "$(GATE_CHECKS)") {
		t.Errorf("Enforce-Fragment traegt die Ordnungskante $(GATE_CHECKS) — die gehoert in den Root-Aggregator (Glob-Reihenfolge):\n%s", frag)
	}
}

// TestEnforce_GitignoreIgnoresState: ohne den state/-Ignore zaehlte der
// record-gates-Stempel selbst in den working-tree-hash — der Stop-Hook blockte
// sich dann selbst (jeder Gate-Lauf aendert den Tree, den er stempelt).
func TestEnforce_GitignoreIgnoresState(t *testing.T) {
	gi := string(emit.EnforceFile(".harness/.gitignore"))
	if !strings.Contains(gi, "state/") {
		t.Errorf(".harness/.gitignore ignoriert state/ nicht: %q", gi)
	}
}

// TestEnforce_LangAgnostic: die Mechanik ist sprach-agnostisch (Messbefund
// slice-031) — reine git/sha256/Hook-Infrastruktur, kein --lang-Zweig. Der
// Stop-Hook + record-gates referenzieren das emittierte tools/harness/-Layout
// (MR-005: NICHT das lokale harness/tools/).
func TestEnforce_LangAgnostic(t *testing.T) {
	for _, rel := range []string{
		"tools/harness/record-gates.sh",
		".claude/hooks/stop-require-gates.sh",
	} {
		s := string(emit.EnforceFile(rel))
		if strings.Contains(s, "harness/tools/") {
			t.Errorf("%s referenziert das lokale harness/tools/ statt des emittierten tools/harness/ (MR-005)", rel)
		}
		if !strings.Contains(s, "tools/harness/working-tree-hash.sh") {
			t.Errorf("%s referenziert working-tree-hash nicht am emittierten Pfad", rel)
		}
	}
}

// TestEnforce_Convergent: die Durchsetzungs-Mechanik ist tool-eigene Infrastruktur
// (ADR-0007 konvergent) — ein Re-Lauf schreibt sie KANONISCH neu (heilt eine
// adopter-modifizierte Fassung), kein Refuse. Der Modus wird MITGEZOGEN: os.WriteFile
// setzt das Perm nur beim Anlegen, writeFileMode chmod't nach.
//
// GEMESSEN WIRD DIE GANZE MENGE: ADR-0007 bindet die Klasse an JEDE emittierte Datei.
// Je Pfad wird der kanonische Stand des ersten Laufs festgehalten, die Datei danach
// GELOESCHT und verstellt neu angelegt — Inhalt und Modus zugleich — und der zweite Lauf
// gegen den festgehaltenen Stand gehalten. Die drei Pfade des Commit-Kennungs-Waechters
// (.githooks/commit-msg, die Pruefung, das Aktivierungs-Fragment) liegen in dieser Menge
// und werden damit einzeln gegen ihre Klasse gehalten.
//
// Rot-Gegenbeispiel: test/mutations/49-enforce-konvergent.sh biegt den Schreiber der
// Schleife auf skip-if-present um; der zweite Lauf laesst die Drift dann stehen.
func TestEnforce_Convergent(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	kanonisch := map[string][]byte{}
	modus := map[string]os.FileMode{}
	for _, rel := range emit.EnforcePaths() {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		roh, err := os.ReadFile(p)
		if err != nil {
			t.Fatalf("%s lesen: %v", rel, err)
		}
		info, err := os.Stat(p)
		if err != nil {
			t.Fatalf("%s stat: %v", rel, err)
		}
		kanonisch[rel] = roh
		modus[rel] = info.Mode().Perm()
		// Verstellt wird per Loeschen + Neuanlegen: ueber eine vorhandene Datei
		// geschrieben bliebe ihr Modus stehen und die zweite Haelfte der Pruefung
		// waere still gruen.
		if err := os.Remove(p); err != nil {
			t.Fatalf("%s entfernen: %v", rel, err)
		}
		if err := os.WriteFile(p, []byte("adopter-modifiziert"), 0o600); err != nil {
			t.Fatalf("%s verstellen: %v", rel, err)
		}
	}
	if len(kanonisch) == 0 {
		t.Fatal("EnforcePaths ist leer — der Waechter misst dann nichts")
	}

	// konvergent: kein Refuse, kanonisch neu (Drift geheilt).
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce (konvergent darf nicht refusen): %v", err)
	}
	for _, rel := range emit.EnforcePaths() {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		got := mustReadString(t, p)
		if got != string(kanonisch[rel]) {
			t.Errorf("%s wurde nicht kanonisch neu geschrieben (konvergent verletzt): %d Bytes gegen %d des ersten Laufs",
				rel, len(got), len(kanonisch[rel]))
			continue
		}
		info, err := os.Stat(p)
		if err != nil {
			t.Fatalf("%s stat: %v", rel, err)
		}
		if info.Mode().Perm() != modus[rel] {
			t.Errorf("%s hat nach dem Re-Lauf Mode %v statt %v — der Modus wandert nicht mit (L2)",
				rel, info.Mode().Perm(), modus[rel])
		}
	}
}

// captureHookInventory liest den BESTAND unter .claude/hooks/ im gebootstrappten Ziel.
// Gemessen wird das Praefix samt Bestand, nicht ein geratener Dateiname: eine
// Stichprobe auf einen Namen, den der Emit nie schreibt, koennte unter keiner Mutation
// rot werden (AGENTS.md §3.6).
func captureHookInventory(t *testing.T, dir string) []string {
	t.Helper()
	entries, err := os.ReadDir(filepath.Join(dir, filepath.FromSlash(".claude/hooks")))
	if err != nil {
		t.Fatalf(".claude/hooks lesen: %v", err)
	}
	names := make([]string, 0, len(entries))
	for _, e := range entries {
		names = append(names, e.Name())
	}
	sort.Strings(names)
	return names
}

func sha256Of(t *testing.T, file string) string {
	t.Helper()
	data, err := os.ReadFile(file)
	if err != nil {
		t.Fatalf("%s lesen: %v", file, err)
	}
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:])
}

// TestEnforce_ErfassungLiegtMitDemTraeger (LH-FA-10, ADR-0022 Festlegung 1/4/5):
// laeuft die Traeger-Ablage durch, liegen im Ziel ALLE DREI — der Traeger im
// gitignorierten Zustands-Bereich, der Hook-Wrapper unter .claude/hooks/ und der
// Erfassungs-Block in .claude/settings.json.
//
// DIE BEDINGUNG STEHT IM WAECHTER, nicht in seinem Namen: der Zweig wird am notice-Kanal
// ABGELESEN, nicht unterstellt. Im Zweig aus Festlegung 5(a) fehlen die drei ZULAESSIG —
// dort misst TestEnforce_KeineErfassungOhneTraeger. Meldet notice hier etwas, ist die
// Umgebung nicht der Gelingens-Zweig, und der Test sagt das laut statt still zu ueberspringen.
//
// Rot-Gegenbeispiele: test/mutations/156 (Traeger nicht abgelegt) · 157 (Wrapper
// nicht emittiert) · 158 (Erfassungs-Block nie gesetzt).
func TestEnforce_ErfassungLiegtMitDemTraeger(t *testing.T) {
	dir := t.TempDir()
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	if notice.Len() != 0 {
		t.Fatalf("die Traeger-Ablage scheiterte in dieser Umgebung — der Gelingens-Zweig ist hier nicht messbar: %s", notice.String())
	}

	// (a) Der Traeger: seine Adresse ist der Ablageort, und er ist das LAUFENDE Bild —
	// nicht irgendeine Datei mit dem richtigen Namen (ADR-0022 Festlegung 1).
	image, err := os.Executable()
	if err != nil {
		t.Fatalf("os.Executable: %v", err)
	}
	carrier := filepath.Join(dir, filepath.FromSlash(emit.CarrierPath(image)))
	info, err := os.Stat(carrier)
	if err != nil {
		t.Fatalf("der Traeger liegt nicht am Ablageort %s: %v", emit.CarrierPath(image), err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("der Traeger liegt mit Mode %v — der Hook startet ihn je Tool-Call", info.Mode().Perm())
	}
	if got, want := sha256Of(t, carrier), sha256Of(t, image); got != want {
		t.Errorf("der abgelegte Traeger ist nicht das laufende Bild (sha256 %s statt %s)", got, want)
	}

	// (b) Der Wrapper: der VOLLE Bestand unter dem Praefix gegen die erwartete Liste.
	want := []string{"pretooluse-command-guard.sh", "span-emit.sh", "stop-require-gates.sh"}
	if got := captureHookInventory(t, dir); !reflect.DeepEqual(got, want) {
		t.Errorf(".claude/hooks/ traegt %v, erwartet %v", got, want)
	}

	// (c) Der Hook-Eintrag: eine INHALTS-Aussage ueber eine bestehende Datei — die drei
	// verdrahteten Ereignisse und der Ruf auf den Wrapper (spec/spezifikation.md §5).
	settings := mustReadString(t, filepath.Join(dir, filepath.FromSlash(".claude/settings.json")))
	if !json.Valid([]byte(settings)) {
		t.Fatalf("die emittierte settings.json ist kein gueltiges JSON:\n%s", settings)
	}
	for _, marker := range []string{
		`"PostToolUse"`, `"PostToolUseFailure"`, `"SubagentStart"`,
		`.claude/hooks/span-emit.sh`,
	} {
		if !strings.Contains(settings, marker) {
			t.Errorf("settings.json traegt den Erfassungs-Eintrag %q nicht:\n%s", marker, settings)
		}
	}
	// Der Erfassungs-Hook ruft den WRAPPER, nie den Traeger direkt: eine Konfiguration,
	// die direkt auf den gitignorierten Ablageort zeigte, waere ein Hook auf ein
	// fehlendes Programm, sobald ein frischer Klon ihn nicht mitbringt (LH-QA-01).
	if strings.Contains(settings, emit.CarrierPath(image)) {
		t.Errorf("settings.json zeigt direkt auf den Ablageort des Traegers statt auf den Wrapper:\n%s", settings)
	}
}

// TestEnforce_KeineErfassungOhneTraeger (LH-QA-01 woertlich, ADR-0022 Festlegung 5a):
// scheitert die Ablage des Traegers, wird WEDER Traeger NOCH Wrapper NOCH Hook-Eintrag
// geschrieben, der Bootstrap nennt den Grund und endet ERFOLGREICH — das Ziel ist ohne
// Erfassung vollstaendig.
//
// Das Scheitern wird HERGESTELLT, nicht abgewartet: der Ablageort wird durch eine Datei
// blockiert, wo ein Verzeichnis entstehen muesste. Ein Fehlerzweig, den kein Test
// erreicht, ist der unerprobte Pfad, an dem fail-open-Zusagen still brechen.
//
// Rot-Gegenbeispiel: test/mutations/155 hebt die Kopplung auf und schreibt den
// Hook-Eintrag unbedingt.
func TestEnforce_KeineErfassungOhneTraeger(t *testing.T) {
	dir := t.TempDir()
	blocker := filepath.Join(dir, filepath.FromSlash(".harness/state/bin"))
	if err := os.MkdirAll(filepath.Dir(blocker), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(blocker, []byte("kein Verzeichnis\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}

	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("der Bootstrap muss ohne Erfassung ERFOLGREICH enden, bekam: %v", err)
	}

	// Der Grund steht da — eine stille Degradierung waere dieselbe Klasse wie ein
	// halluzinierter Gate: das Ziel behauptete Erfassung, die niemand ablegte.
	if notice.Len() == 0 {
		t.Error("der Bootstrap nennt den Grund nicht — LH-FA-10 verlangt: begruendet nichts abgelegt")
	}

	// Kein Traeger.
	image, err := os.Executable()
	if err != nil {
		t.Fatalf("os.Executable: %v", err)
	}
	// Geprueft wird die ABWESENHEIT, nicht ein bestimmter Fehler: der blockierte
	// Ablageort liefert ENOTDIR, ein leeres Ziel ENOENT — beide heissen „da liegt
	// kein Traeger", und os.IsNotExist trifft nur den zweiten.
	if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(emit.CarrierPath(image)))); err == nil {
		t.Error("ohne gelungene Ablage liegt trotzdem ein Traeger am Ablageort")
	}

	// Kein Wrapper — wieder der VOLLE Bestand, nicht eine Stichprobe.
	want := []string{"pretooluse-command-guard.sh", "stop-require-gates.sh"}
	if got := captureHookInventory(t, dir); !reflect.DeepEqual(got, want) {
		t.Errorf(".claude/hooks/ traegt ohne Traeger %v, erwartet %v", got, want)
	}

	// Kein Hook-Eintrag — und die uebrige Durchsetzung steht unveraendert.
	settings := mustReadString(t, filepath.Join(dir, filepath.FromSlash(".claude/settings.json")))
	for _, verboten := range []string{"PostToolUse", "SubagentStart", "span-emit"} {
		if strings.Contains(settings, verboten) {
			t.Errorf("settings.json traegt ohne Traeger den Erfassungs-Eintrag %q — genau der Hook auf ein fehlendes Programm, den LH-QA-01 ausschliesst:\n%s", verboten, settings)
		}
	}
	for _, noetig := range []string{"stop-require-gates.sh", "pretooluse-command-guard.sh"} {
		if !strings.Contains(settings, noetig) {
			t.Errorf("ohne Traeger fehlt auch %q — der Ausfall der Erfassung darf die Durchsetzung nicht mitnehmen", noetig)
		}
	}
}

// TestEnforce_WrapperSuchtDenAblageort koppelt die zwei Haelften, die getrennt driften
// koennen: der Emitter LEGT den Traeger an einen Ort, der Wrapper SUCHT ihn dort. Ein
// Wrapper, der woanders sucht, schwiege dauerhaft — und schweigen ist genau seine
// erlaubte Betriebsart, der Ausfall bliebe also unsichtbar.
//
// Rot-Gegenbeispiel: test/mutations/159 nimmt der Ziel-Adresse die Windows-Endung.
func TestEnforce_WrapperSuchtDenAblageort(t *testing.T) {
	wrapper := string(emit.EnforceFile(".claude/hooks/span-emit.sh"))
	if wrapper != "" {
		t.Fatal("EnforceFile liefert den Wrapper — er gehoert nicht in enforceFiles(), sondern in die an den Traeger gekoppelte Menge")
	}
	dir := t.TempDir()
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	if notice.Len() != 0 {
		t.Fatalf("die Traeger-Ablage scheiterte in dieser Umgebung: %s", notice.String())
	}
	wrapper = mustReadString(t, filepath.Join(dir, filepath.FromSlash(".claude/hooks/span-emit.sh")))
	// BEIDE Namen, die CarrierPath erzeugen kann — der Wrapper laeuft auch dort, wo das
	// Bild `.exe` heisst (LH-QA-04).
	for _, image := range []string{"/pfad/ai-harness-init", "/pfad/ai-harness-init.exe"} {
		if rel := emit.CarrierPath(image); !strings.Contains(wrapper, path.Base(rel)) {
			t.Errorf("der Wrapper sucht %q nicht — der Emitter legt den Traeger genau dorthin:\n%s", path.Base(rel), wrapper)
		}
	}
	if !strings.Contains(wrapper, "/.harness/state/bin") {
		t.Errorf("der Wrapper sucht nicht im gitignorierten Zustands-Bereich:\n%s", wrapper)
	}
	// Das Unterkommando ist der Einstiegspunkt, den auch der Dogfood faehrt (ADR-0022
	// Festlegung 2); ein anderer Name liesse den Traeger ohne Span zurueckkehren.
	if !strings.Contains(wrapper, "span-emit") {
		t.Errorf("der Wrapper ruft den Traeger nicht mit `span-emit`:\n%s", wrapper)
	}
}

// TestCarrierPath_NimmtDieEndungMit: der Ziel-Name ist fest, die Endung des laufenden
// Bildes wandert mit. Ohne sie bekaeme ein Windows-Ziel eine Datei, die es nicht starten
// kann (LH-QA-04) — und der Plattform-Dateiname des Release-Assets darf umgekehrt NICHT
// mitwandern, sonst faende der Wrapper den Traeger nicht.
//
// Rot-Gegenbeispiel: test/mutations/159.
func TestCarrierPath_NimmtDieEndungMit(t *testing.T) {
	for _, fall := range []struct{ image, want string }{
		{"/tmp/ai-harness-init", ".harness/state/bin/ai-harness-init"},
		{"/tmp/ai-harness-init-linux-amd64", ".harness/state/bin/ai-harness-init"},
		{`C:\tools\ai-harness-init-windows-amd64.exe`, ".harness/state/bin/ai-harness-init.exe"},
		{"/tmp/ai-harness-init.EXE", ".harness/state/bin/ai-harness-init.EXE"},
	} {
		if got := emit.CarrierPath(fall.image); got != fall.want {
			t.Errorf("CarrierPath(%q) = %q, erwartet %q", fall.image, got, fall.want)
		}
	}
}
