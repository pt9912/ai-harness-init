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
	if err := emit.Enforce(dir, "go", false); err != nil {
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
}

// TestEnforce_ScriptsExecutable: ein nicht ausfuehrbarer Hook/Tool-Nachweis waere
// eine leere Zusage — Claude ruft den Stop-Hook, make ruft record-gates.
func TestEnforce_ScriptsExecutable(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, "go", false); err != nil {
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

// TestEnforce_GuardBlockedSetPerLang: der emittierte Guard traegt fuer --lang go die
// go-Toolchain PLUS die universellen Paketmanager, und der @@BLOCKED_SET@@-Platzhalter
// ist ersetzt (ein zurueckbleibender Platzhalter waere ein zahnloser Guard). Gelesen
// aus der WIRKLICH geschriebenen Datei (Substitution passiert beim Emit, nicht im
// Embed).
func TestEnforce_GuardBlockedSetPerLang(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, "go", false); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	guard := mustReadString(t, filepath.Join(dir, filepath.FromSlash(".claude/hooks/pretooluse-command-guard.sh")))
	if strings.Contains(guard, "@@BLOCKED_SET@@") {
		t.Error("Guard traegt noch den @@BLOCKED_SET@@-Platzhalter — Substitution fehlte (zahnlos)")
	}
	for _, tool := range []string{"go", "gofmt", "golangci-lint", "staticcheck", "pip", "npm", "cargo"} {
		if !strings.Contains(guard, tool) {
			t.Errorf("emittierter Guard (--lang go) blockt %q nicht — BLOCKED-Set unvollstaendig", tool)
		}
	}
}

// TestBlockedSet_CoversAllGenProfiles koppelt das BLOCKED-Set an gen.SupportedLangs():
// jedes Profil, das gen bootstrappen kann, MUSS eine Sprach-Toolchain im Guard haben —
// sonst liefe im gebootstrappten Ziel die Host-Toolchain der Sprache ungehindert
// (stille Luecke). Ein unbekanntes lang liefert nur die universelle Menge.
func TestBlockedSet_CoversAllGenProfiles(t *testing.T) {
	universalOnly := emit.BlockedSetForLang("___unbekannt___")
	for _, lang := range gen.SupportedLangs() {
		if emit.BlockedSetForLang(lang) == universalOnly {
			t.Errorf("gen-Profil %q hat kein Sprach-BLOCKED-Set — Host-Toolchain liefe ungehindert (stille Luecke)", lang)
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
	if err := emit.Enforce(dir, "go", false); err == nil {
		t.Fatal("vorhandene Datei ohne --force ueberschrieben")
	}
	if got := mustReadString(t, dst); got != "eigenes Skript" {
		t.Errorf("Inhalt bei Kollision veraendert: %q", got)
	}
	if err := emit.Enforce(dir, "go", true); err != nil {
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
