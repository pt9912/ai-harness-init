package emit_test

import (
	"os"
	"path/filepath"
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
	if err := emit.Enforce(dir, false); err != nil {
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
		"harness/mk/enforce.mk",
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
	if err := emit.Enforce(dir, false); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, rel := range []string{
		"tools/harness/working-tree-hash.sh",
		"tools/harness/record-gates.sh",
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
	if err := emit.BlockedFragment(dir, "go", false); err != nil {
		t.Fatalf("BlockedFragment(go): %v", err)
	}
	frag := mustReadString(t, filepath.Join(dir, filepath.FromSlash("tools/harness/blocked/go")))
	if !strings.Contains(frag, "go gofmt golangci-lint staticcheck") {
		t.Errorf("blocked/go traegt die go-Toolchain nicht: %q", frag)
	}
	dir2 := t.TempDir()
	if err := emit.BlockedFragment(dir2, "", false); err != nil {
		t.Fatalf("BlockedFragment(sprachlos): %v", err)
	}
	if _, err := os.Stat(filepath.Join(dir2, filepath.FromSlash("tools/harness/blocked"))); !os.IsNotExist(err) {
		t.Errorf("BlockedFragment(sprachlos) legte ein blocked/-Fragment an: %v", err)
	}
}

// TestBlockedFragment_SkipIfPresent (slice-037, Mono-Repo-Kern): ein zweiter Drop
// derselben Sprache OHNE force clobbert das vorhandene blocked/<lang> NICHT und ist KEIN
// Fehler (mehrere Module gleicher Sprache teilen ein Fragment). Mit force wird ueberschrieben.
func TestBlockedFragment_SkipIfPresent(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash("tools/harness/blocked/go"))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(dst, []byte("adopter-eigenes blocked\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	// skip-if-present: kein Fehler, kein Clobber.
	if err := emit.BlockedFragment(dir, "go", false); err != nil {
		t.Fatalf("BlockedFragment skip-if-present soll kein Fehler sein: %v", err)
	}
	if got := mustReadString(t, dst); got != "adopter-eigenes blocked\n" {
		t.Errorf("blocked/go bei skip-if-present clobbert: %q", got)
	}
	// force ueberschreibt (Baseline-Bump).
	if err := emit.BlockedFragment(dir, "go", true); err != nil {
		t.Fatalf("BlockedFragment(force): %v", err)
	}
	if got := mustReadString(t, dst); !strings.Contains(got, "go gofmt golangci-lint") {
		t.Errorf("blocked/go mit --force nicht ueberschrieben: %q", got)
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

// TestEnforce_NoOverwriteWithoutForce + Modus-Mitzug bei --force (Befund slice-022a
// L2: os.WriteFile setzt Perm nur beim Anlegen).
func TestEnforce_NoOverwriteWithoutForce(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash("tools/harness/record-gates.sh"))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(dst, []byte("eigenes Skript"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := emit.Enforce(dir, false); err == nil {
		t.Fatal("vorhandene Datei ohne --force ueberschrieben")
	}
	if got := mustReadString(t, dst); got != "eigenes Skript" {
		t.Errorf("Inhalt bei Kollision veraendert: %q", got)
	}
	if err := emit.Enforce(dir, true); err != nil {
		t.Fatalf("Enforce mit force: %v", err)
	}
	info, err := os.Stat(dst)
	if err != nil {
		t.Fatalf("stat: %v", err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("nach --force Mode %v — richtiger Inhalt in nicht ausfuehrbarer Datei (L2)", info.Mode().Perm())
	}
}
