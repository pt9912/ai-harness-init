package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestEnforce_EmitsAllMechanicFiles: die Durchsetzungs-Mechanik (LH-FA-06) landet
// vollstaendig im Ziel — Gate-Nachweis (record-gates + working-tree-hash),
// Stop-Hook (stop-require-gates + settings.json) und der state/-Ignore. EnforcePaths
// und der reale Emit koppeln denselben Bestand: der Pre-Flight (cmd Phase 3) sieht
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
	// Die konkreten Zielpfade sind Vertrag (Stop-Hook + record-gates referenzieren
	// tools/harness/; der Stempel-Ignore muss .harness/.gitignore sein).
	want := []string{
		"tools/harness/working-tree-hash.sh",
		"tools/harness/record-gates.sh",
		".claude/hooks/stop-require-gates.sh",
		".claude/settings.json",
		".harness/.gitignore",
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
	if err := emit.Enforce(dir, false); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	for _, rel := range []string{
		"tools/harness/working-tree-hash.sh",
		"tools/harness/record-gates.sh",
		".claude/hooks/stop-require-gates.sh",
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

// TestEnforce_SettingsStopOnly: die emittierte settings.json verdrahtet den
// Stop-Hook, aber NICHT den PreToolUse-Guard — der ist slice-032 (sein Skript wird
// noch nicht emittiert; ein settings.json-Verweis darauf liefe im Ziel ins Leere).
// Das ist die Slice-031-Grenze, als Test fixiert.
func TestEnforce_SettingsStopOnly(t *testing.T) {
	settings := string(emit.EnforceFile(".claude/settings.json"))
	if !strings.Contains(settings, "stop-require-gates.sh") {
		t.Error("settings.json verdrahtet den Stop-Hook nicht")
	}
	if !strings.Contains(settings, `"Stop"`) {
		t.Error("settings.json hat keinen Stop-Block")
	}
	if strings.Contains(settings, "PreToolUse") {
		t.Error("settings.json enthaelt PreToolUse — der Guard ist slice-032, nicht slice-031")
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
