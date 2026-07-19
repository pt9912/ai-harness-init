// Package emit schreibt die Doc-Gate-Baseline in ein Zielrepo.
//
// Zwei Artefakte mit bewusst verschiedener Herkunft:
//   - .d-check.yml — vom Tool AUTORIERTE minimale Config (nur links/anchors;
//     ids/codepaths auskommentiert). Ihre Minimalitaet ist die LH-QA-01-Garantie
//     (kein Modul aktiv, das im frischen Repo brechen wuerde), darum eingebettet.
//   - d-check.mk   — zur BOOTSTRAP-Zeit erzeugt via `docker run <d-check> --print-mk`
//     (Docker ist die geforderte Bootstrap-Abhaengigkeit, LH-QA-03) und mechanisch
//     adaptiert (AdaptMK). So traegt das Tool kein driftendes Fragment, nur den Pin
//     + die Transform; das emittierte Fragment ist immer das aktuelle d-check-Target-Set
//     mit exakt dem Digest, der es erzeugt hat (LH-QA-02).
package emit

import (
	"bytes"
	"context"
	_ "embed" // fuer die //go:embed-Direktive (dcheckConfig)
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// DefaultImage ist die per Default gepinnte d-check-Tag-Referenz (landet im
// emittierten DCHECK_IMAGE). DefaultDigest ist der zugehoerige Pin (LH-QA-02) — er
// treibt den docker-Lauf UND das emittierte DCHECK_DIGEST. Beide sind per Env
// (DCHECK_IMAGE/DCHECK_DIGEST) fuer bewussten Opt-in-Override ueberschreibbar; die
// Semantik (Digest sticht Tag) ist dieselbe wie im emittierten Fragment.
const (
	DefaultImage  = "ghcr.io/pt9912/d-check:v0.51.1"
	DefaultDigest = "sha256:fede3d027b2ebc1dd8534460853e57b67cc7a9a182cad2e2138c8eebf7a2d03c"
)

//go:embed templates/d-check.yml
var dcheckConfig string

// adopterHeader ersetzt den d-check-eigenen Kopf-Kommentar im emittierten Fragment.
const adopterHeader = "# d-check.mk — Doku-Referenz-Gate via d-check. Emittiert von ai-harness-init,\n" +
	"# adaptiert aus `d-check --print-mk`: doc-check -> docs-check (das Befund-Gate,\n" +
	"# einziges als Gate behauptetes Target) und DCHECK_DIGEST auf den erzeugenden\n" +
	"# Image-Digest gepinnt (Reproduzierbarkeit). advisory doc-*-Targets verbatim.\n" +
	"# Einbinden: `include d-check.mk`; eigene .d-check.yml danebenlegen.\n"

// DCheckConfig liefert die eingebettete minimale .d-check.yml (links/anchors).
func DCheckConfig() string { return dcheckConfig }

// Options steuert den Doc-Gate-Emit.
type Options struct {
	Image  string // Tag-Referenz -> emittiertes DCHECK_IMAGE
	Digest string // sha256-Pin -> emittiertes DCHECK_DIGEST + docker-Lauf
	Force  bool   // vorhandene Zieldateien ueberschreiben
}

// RunRef ist die Referenz fuer den docker-Lauf: per Digest, wenn gesetzt (sticht
// den Tag), sonst die Tag-Referenz. Rein (kein Docker) und exportiert, damit die
// gepinnte repo@digest-Achse (LH-QA-02) einen Tier-1-Test hat.
func (o Options) RunRef() string {
	if o.Digest == "" {
		return o.Image
	}
	repo := o.Image
	if i := strings.LastIndex(repo, ":"); i > strings.LastIndex(repo, "/") {
		repo = repo[:i] // nur den Tag entfernen (Registry-Port bleibt) -> repo@digest
	}
	return repo + "@" + o.Digest
}

// DocGate emittiert .d-check.yml + d-check.mk nach targetDir. Reihenfolge: erst
// die Vorbedingungen und alle fallierbaren Schritte (Existenz-Pruefung ohne force,
// docker --print-mk, Adaption), dann die Schreibvorgaenge — so bleibt bei einem
// Fehler nichts halb geschrieben.
func DocGate(ctx context.Context, targetDir string, opts Options) error {
	targets := []string{".d-check.yml", "d-check.mk"}
	if !opts.Force {
		for _, name := range targets {
			switch _, err := os.Stat(filepath.Join(targetDir, name)); {
			case err == nil:
				return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", name)
			case !errors.Is(err, fs.ErrNotExist):
				return fmt.Errorf("%s pruefen: %w", name, err)
			}
		}
	}
	raw, err := printMK(ctx, opts.RunRef())
	if err != nil {
		return err
	}
	mk, err := AdaptMK(raw, opts.Digest)
	if err != nil {
		return err
	}
	content := map[string][]byte{".d-check.yml": []byte(dcheckConfig), "d-check.mk": mk}
	for _, name := range targets {
		if err := os.WriteFile(filepath.Join(targetDir, name), content[name], 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", name, err)
		}
	}
	return nil
}

// AdaptMK wandelt rohe `d-check --print-mk`-Ausgabe in das Adopter-Fragment: der
// d-check-Kopf wird durch den ai-harness-init-Header ersetzt, das Befund-Gate
// doc-check -> docs-check umbenannt (advisory doc-*-Targets bleiben), DCHECK_DIGEST
// auf digest gepinnt und der doc-help-Grep auf docs?- erweitert (die MR-010-Handgriffe,
// hier mechanisch). Bricht ab, wenn sich das --print-mk-Format so aendert, dass ein
// Handgriff nicht greift — dann ist Tier-2 (echter Lauf) die Instanz, die es faengt.
func AdaptMK(raw []byte, digest string) ([]byte, error) {
	const anchor = "DCHECK_IMAGE ?="
	s := string(raw)
	i := strings.Index(s, anchor)
	if i < 0 {
		return nil, fmt.Errorf("unerwartete --print-mk-ausgabe: %q nicht gefunden", anchor)
	}
	body := s[i:]
	// Rename NUR das Befund-Gate-Target doc-check, zeilen-verankert — ein kuenftiges
	// doc-check-* Target wuerde von einem substring-ReplaceAll still mit-umbenannt.
	body = strings.Replace(body, ".PHONY: doc-check\n", ".PHONY: docs-check\n", 1)
	body = strings.Replace(body, "\ndoc-check:", "\ndocs-check:", 1)
	// DCHECK_DIGEST pinnen (die leere --print-mk-Zeile fuellen).
	body = strings.Replace(body, "DCHECK_DIGEST ?=\n", "DCHECK_DIGEST ?= "+digest+"\n", 1)
	// doc-help-Grep auf docs?- weiten, damit das umbenannte docs-check gelistet wird.
	body = strings.Replace(body, "'^doc-[a-z-]+:", "'^docs?-[a-z-]+:", 1)
	// Jeder MR-010-Handgriff MUSS gegriffen haben — sonst hat sich das --print-mk-Format
	// geaendert; hart abbrechen statt ein halb-adaptiertes Fragment zu emittieren.
	switch {
	case !strings.Contains(body, "\ndocs-check:"):
		return nil, errors.New("rename doc-check -> docs-check schlug fehl (--print-mk-format geaendert?)")
	case !strings.Contains(body, "'^docs?-[a-z-]+:"):
		return nil, errors.New("weitung des doc-help-grep schlug fehl (--print-mk-format geaendert?)")
	case digest != "" && !strings.Contains(body, "DCHECK_DIGEST ?= "+digest):
		return nil, errors.New("pinnen von DCHECK_DIGEST fehlgeschlagen (--print-mk-format geaendert?)")
	}
	return []byte(adopterHeader + body), nil
}

// printMK ruft `docker run <ref> --print-mk` und liefert die rohe Ausgabe.
// --network none haertet den Lauf (--print-mk braucht kein Netz; der Image-Pull,
// falls noetig, laeuft ueber den Daemon, nicht das Container-Netz).
func printMK(ctx context.Context, ref string) ([]byte, error) {
	out, err := exec.CommandContext(ctx, "docker", "run", "--rm", "--network", "none", ref, "--print-mk").Output()
	if err != nil {
		return nil, fmt.Errorf("docker run %s --print-mk: %w", ref, execErr(err))
	}
	return out, nil
}

// execErr haengt den stderr eines fehlgeschlagenen Kommandos an die Fehlermeldung.
func execErr(err error) error {
	var ee *exec.ExitError
	if errors.As(err, &ee) && len(ee.Stderr) > 0 {
		return fmt.Errorf("%w (%s)", err, bytes.TrimSpace(ee.Stderr))
	}
	return err
}
