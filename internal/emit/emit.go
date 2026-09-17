// Package emit schreibt die Gate-Baselines in ein Zielrepo — das Doc-Gate (hier)
// und, konditional bei einem schichten-tragenden Layout, das Arch-Gate (archgate.go).
// Beide folgen demselben Muster: tool-autorierte Config + tool-generiertes
// `.mk`-Fragment aus `--print-mk`.
//
// Zwei Artefakte mit bewusst verschiedener Herkunft:
//   - .d-check.yml — vom Tool AUTORIERTE Config; welche Module aktiv sind, steht
//     in internal/emit/templates/d-check.yml selbst (DCheckConfig()).
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
	"os/exec"
	"strings"
)

// DefaultImage ist die per Default gepinnte d-check-Tag-Referenz (landet im
// emittierten DCHECK_IMAGE). DefaultDigest ist der zugehoerige Pin (LH-QA-02) — er
// treibt den docker-Lauf UND das emittierte DCHECK_DIGEST. Beide sind per Env
// (DCHECK_IMAGE/DCHECK_DIGEST) fuer bewussten Opt-in-Override ueberschreibbar; die
// Semantik (Digest sticht Tag) ist dieselbe wie im emittierten Fragment.
const (
	DefaultImage  = "ghcr.io/pt9912/d-check:v0.76.0"
	DefaultDigest = "sha256:f0b55fde2be414dda51ddeea5677d5ad1094eecb23a528cfef768cbd61945396"
)

//go:embed templates/d-check.yml
var dcheckConfig string

// adopterHeader ersetzt den d-check-eigenen Kopf-Kommentar im emittierten Fragment.
const adopterHeader = "# d-check.mk — Doku-Referenz-Gate via d-check. Emittiert von ai-harness-init,\n" +
	"# adaptiert aus `d-check --print-mk`: doc-check -> docs-check (das Befund-Gate,\n" +
	"# einziges als Gate behauptetes Target) und DCHECK_DIGEST auf den erzeugenden\n" +
	"# Image-Digest gepinnt (Reproduzierbarkeit). advisory doc-*-Targets verbatim.\n" +
	"# Einbinden: `include d-check.mk`; eigene .d-check.yml danebenlegen.\n"

// DCheckConfig liefert die eingebettete .d-check.yml-Vorlage; welche Module sie
// aktiviert, steht in internal/emit/templates/d-check.yml selbst.
func DCheckConfig() string { return dcheckConfig }

// DocGateMkPath ist der Zielpfad des Doc-Gate-Fragments. Es bindet das
// tool-generierte d-check.mk ein und haengt docs-check an GATE_CHECKS an;
// der Root-Aggregator faehrt es via make gates.
const DocGateMkPath = "harness/mk/doc-gate.mk"

// docGateMk ist der Inhalt des Doc-Gate-Fragments — verbatim (der Digest/Pin lebt in
// d-check.mk, nicht hier). `include d-check.mk` loest relativ zum Ziel-Root auf (make
// laeuft dort), nicht relativ zum Fragment-Verzeichnis harness/mk/.
//
// Es traegt auch den Vorlauf-Waechter der zwei history-lesenden Targets: die Vorbedingung
// `doc-immutable: history-range-guard` (und dieselbe fuer `doc-commits`) ergaenzt die
// Targets aus d-check.mk, ohne ihr Rezept anzuruehren — die Datei schreibt das Werkzeug
// bei jedem Bootstrap kanonisch neu, ein zweites Rezept hier waere beim naechsten Lauf weg.
// Die Vorbindung ist nur zulaessig, solange d-check.mk die zwei Targets fuehrt
// (requireVorbindungsTargets). Beide Targets stehen NICHT in GATE_CHECKS: ihre Range setzt
// der Aufrufer, ohne sie ist der Pruefbereich nicht hermetisch.
const docGateMk = `# harness/mk/doc-gate.mk — Doc-Gate-Fragment, emittiert von ai-harness-init.
# Bindet das tool-generierte d-check.mk ein (Befund-Gate docs-check) und haengt
# docs-check an GATE_CHECKS an; der Root-Aggregator faehrt es via make gates.
include d-check.mk

# VORLAUF-WAECHTER fuer die zwei history-lesenden Targets: ueber einer aufloesbaren,
# aber LEEREN Commit-Range melden doc-immutable und doc-commits am emittierten
# .d-check.yml "0 Befund(e)", Exit 0 — gruen ueber leerem Pruefbereich. Beide haengen
# darum an history-range-guard, der VOR dem Modul-Lauf mit einer Meldung abbricht; das
# Rezept der beiden Targets bleibt das aus d-check.mk, und die Emission prueft, dass
# diese Datei die zwei Targets fuehrt.
#
# FAIL-CLOSED, je Ziel: die Vorbindung setzt voraus, dass das eingebundene d-check.mk das
# Ziel MIT REZEPT fuehrt. Die Probe steht EINMAL (DOC_GATE_ZIEL) und wird je Ziel mit seinem
# Namen aufgerufen; nur der belegte Ausgang waehlt die Bindung, jeder andere — kein Treffer,
# eine Ziel-Zeile ohne Rezept, kein Probe-Werkzeug (awk) oder eine leere Ausgabe — faellt in
# den Abbruch mit Exit 2. Eine Vorbindung ueber einem Ziel ohne Rezept laesst make mit Exit 0
# enden und den Waechter allein laufen; dagegen steht diese Bedingung. Gelesen wird dieselbe
# Datei, die das include oben einbindet (awk, kein Bild, kein Netz).
#
# KEIN GATE: die Range setzt der Aufrufer, ohne sie ist der Pruefbereich nicht
# hermetisch (LH-QA-01) — das Ziel steht darum nicht in GATE_CHECKS.
.PHONY: history-range-guard

history-range-guard: ## Vorlauf-Waechter: RANGE muss aufloesbar UND nicht leer sein (STAGED=1 prueft den Index; den STAGED-Zweig fuehrt nur doc-immutable)
	@bash tools/harness/history-range-guard.sh "$(if $(STAGED),--staged,$(RANGE))"

# DOC_GATE_ZIEL <ziel> — die EINE Probe: "da", wenn d-check.mk das Ziel mit einer
# Rezept-Zeile fuehrt, "rezeptlos", wenn es die Ziel-Zeile ohne Rezept traegt. Kein Treffer,
# ein fehlendes Probe-Werkzeug und jede leere Ausgabe lassen den Vergleich scheitern.
# Die Zuweisung traegt override: die Kommandozeile setzt diese Variable nicht, ein Aufruf wie
#   make DOC_GATE_ZIEL=da <ziel>
# aendert die Entscheidung also nicht. Rekursiv zugewiesen (nicht :=), sonst expandiert $(1)
# schon hier.
override DOC_GATE_ZIEL = $(shell awk '/^$(1):/{f=1;next} f&&/^[[:space:]]*$$/{next} f{print (substr($$0,1,1)=="\t" ? "da" : "rezeptlos");exit}' d-check.mk 2>/dev/null)

ifeq ($(call DOC_GATE_ZIEL,doc-immutable),da)
doc-immutable: history-range-guard
else
doc-immutable:
	@echo "harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-immutable' nicht als Ziel mit Rezept (oder awk fehlt) — die Vorbindung des Vorlauf-Waechters haette dort kein Rezept (LH-QA-01)." >&2
	@exit 2
endif

ifeq ($(call DOC_GATE_ZIEL,doc-commits),da)
doc-commits: history-range-guard
else
doc-commits:
	@echo "harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-commits' nicht als Ziel mit Rezept (oder awk fehlt) — die Vorbindung des Vorlauf-Waechters haette dort kein Rezept (LH-QA-01)." >&2
	@exit 2
endif

GATE_CHECKS += docs-check
`

// DocGateMk liefert den Inhalt des Doc-Gate-Fragments (fuer Tests/Inspektion) — der
// netzlose Waechter auf die docs-check-Verdrahtung, weil DocGate selbst Docker braucht
// (--print-mk). Ohne ihn traege nur full-smoke die Zusage „docs-check haengt in gates".
func DocGateMk() string { return docGateMk }

// vorbindungsTargets sind die zwei history-lesenden Targets, an die das Doc-Gate-Fragment den
// Vorlauf-Waechter als Vorbedingung haengt (s. docGateMk). Die Bindung setzt voraus, dass das
// erzeugte d-check.mk sie fuehrt: eine Vorbindungs-Zeile ohne Rezept macht aus einem fehlenden
// Target einen STILLEN Erfolg — `make doc-immutable` meldet dann Exit 0 und faehrt allein den
// Waechter, wo es ohne die Zeile mit "Keine Regel" abbraeche (LH-QA-01, MR-017: fail-closed ist
// der Default fuer emittierte Pruefbereiche).
//
// Als Funktion (nicht als Paket-Variable), gochecknoglobals-konform.
func vorbindungsTargets() []string { return []string{"doc-immutable", "doc-commits"} }

// requireVorbindungsTargets prueft die Target-Zeile im erzeugten d-check.mk, nicht ein
// Vorkommen des Namens: `.PHONY: doc-immutable` allein traegt kein Rezept und liesse dieselbe
// stille Luecke offen.
func requireVorbindungsTargets(mk string) error {
	for _, ziel := range vorbindungsTargets() {
		if !strings.Contains(mk, "\n"+ziel+":") {
			return fmt.Errorf("--print-mk-Ausgabe fuehrt das Target %q nicht — die Vorbindung des Doc-Gate-Fragments haette dort kein Rezept (LH-QA-01)", ziel)
		}
	}
	return nil
}

// Options steuert den Doc-Gate-Emit.
type Options struct {
	Image  string // Tag-Referenz -> emittiertes DCHECK_IMAGE
	Digest string // sha256-Pin -> emittiertes DCHECK_DIGEST + docker-Lauf
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

// DocGate emittiert .d-check.yml + d-check.mk + doc-gate.mk nach targetDir. GEMISCHTE
// Idempotenz-Klasse (ADR-0007): `.d-check.yml` ist SKIP-IF-PRESENT (Adopter-
// Boden — er kann Module aktivieren), `d-check.mk` + `doc-gate.mk` sind KONVERGENT (tool-
// generiert, heilen Drift/Digest-Bump). Reihenfolge: erst die fallierbaren Schritte
// (docker --print-mk, Adaption), dann die Schreibvorgaenge — kein halb geschriebener Stand.
func DocGate(ctx context.Context, targetDir string, opts Options) error {
	raw, err := printMK(ctx, opts.RunRef())
	if err != nil {
		return err
	}
	mk, err := AdaptMK(raw, opts.Digest)
	if err != nil {
		return err
	}
	// .d-check.yml: skip-if-present (Adopter darf Module aktivieren, nie clobbern).
	if err := writeSkipIfPresent(targetDir, ".d-check.yml", []byte(dcheckConfig), 0o644); err != nil {
		return err
	}
	// d-check.mk + doc-gate.mk: konvergent (tool-generiert, kanonisch neu).
	if err := writeFileMode(targetDir, "d-check.mk", mk, 0o644); err != nil {
		return err
	}
	return writeFileMode(targetDir, DocGateMkPath, []byte(docGateMk), 0o644)
}

// AdaptMK wandelt rohe `d-check --print-mk`-Ausgabe in das Adopter-Fragment: der
// d-check-Kopf wird durch den ai-harness-init-Header ersetzt, das Befund-Gate
// doc-check -> docs-check umbenannt (advisory doc-*-Targets bleiben), DCHECK_DIGEST
// auf digest gepinnt und der doc-help-Grep auf docs?- erweitert (die MR-010-Handgriffe,
// hier mechanisch). Bricht ab, wenn sich das --print-mk-Format so aendert, dass ein
// Handgriff nicht greift, und wenn eines der zwei Targets fehlt, an die das Doc-Gate-
// Fragment den Vorlauf-Waechter haengt (requireVorbindungsTargets) — dann ist Tier-2
// (echter Lauf) die Instanz, die es faengt.
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
	// Die zwei Vorbindungs-Zeilen des Doc-Gate-Fragments setzen diese Targets voraus — ohne
	// die Pruefung waere ein fehlendes Rezept ein stiller Erfolg statt eines lauten Abbruchs.
	if err := requireVorbindungsTargets(body); err != nil {
		return nil, err
	}
	return []byte(adopterHeader + body), nil
}

// printMK ruft `docker run <ref> --print-mk` und liefert die rohe Ausgabe.
// --network none haertet den Lauf (--print-mk braucht kein Netz; der Image-Pull,
// falls noetig, laeuft ueber den Daemon, nicht das Container-Netz). Tool-neutral:
// d-check und a-check teilen dieselbe --print-mk-Konvention.
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
