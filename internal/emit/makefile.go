package emit

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

// MakefilePath ist der Zielpfad der Root-Makefile (der Aggregator). Sprach-agnostisch:
// der Init-Emitter schreibt sie IMMER — auch ohne --lang —, damit ein sprachloser
// Bootstrap ein `make gates` hat (doc-only: docs-check + baseline-verify + record-gates).
// slice-035 relocatete den Aggregator aus dem gen-Skelett (slice-034 Option A) hierher:
// der Aggregator ist sprach-agnostisch und gehoert in die Init-Phase, nicht ins Skelett.
const MakefilePath = "Makefile"

// aggregatorMakefile — die sprach-agnostische Root-Makefile: ein duenner Aggregator, der
// die Gate-Fragmente (harness/mk/*.mk) per Glob einbindet. KEIN Sprach-Pin (die GO_VERSION
// lebt im Code-Gate-Fragment harness/mk/<lang>.mk, das gen bei --lang emittiert). Die
// Recipe-Zeile ist TAB-eingerueckt (Makefile-Pflicht).
const aggregatorMakefile = `# Makefile — generiert von ai-harness-init (Aggregator). Die Gate-Belange leben als
# Fragmente unter harness/mk/*.mk; jedes haengt seine Checks an GATE_CHECKS. Der
# Gate-Nachweis (record-gates) laeuft strikt ZULETZT via Ordnungskante auf GATE_CHECKS
# — waehrend make -j die Checks parallelisiert; .NOTPARALLEL ist bewusst NICHT gewaehlt
# (das serialisierte das ganze Makefile). Sprach-agnostisch: ohne --lang matchen nur
# baseline/doc-gate/enforce, mit --lang zusaetzlich das Code-Gate-Fragment.
GATE_CHECKS :=

.PHONY: gates help

# Gate-Fragmente je Belang (baseline/doc-gate/enforce + Sprach-Code-Gates) einbinden.
# Alphabetisch (baseline < doc-gate < enforce < <lang>); die Ordnungskante unten steht
# NACH dem Include und sieht GATE_CHECKS damit vollstaendig.
include harness/mk/*.mk

help: ## Diese Hilfe
	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*##"}{printf "  %-14s %s\n",$$1,$$2}'

# gates haengt allein an record-gates; record-gates haengt an ALLEN akkumulierten
# Checks — der Nachweis laeuft strikt nach den Checks (Ordnungskante), waehrend make
# -j die Checks parallel faehrt. Das record-gates-Rezept liefert harness/mk/enforce.mk.
gates: record-gates ## Alle Gates (Checks parallel, Nachweis zuletzt)
record-gates: $(GATE_CHECKS)
`

// Makefile emittiert die Aggregator-Root-Makefile nach targetDir (Init-Phase,
// sprach-agnostisch — immer, auch ohne --lang). Ohne force wird eine vorhandene Datei
// nicht ueberschrieben (LH-FA-01 Boundary; der Phase-3-Pre-Flight prueft das bereits,
// hier als Verteidigung).
func Makefile(targetDir string, force bool) error {
	dst := filepath.Join(targetDir, MakefilePath)
	if !force {
		switch _, err := os.Stat(dst); {
		case err == nil:
			return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", MakefilePath)
		case !errors.Is(err, fs.ErrNotExist):
			return fmt.Errorf("%s pruefen: %w", MakefilePath, err)
		}
	}
	if err := os.WriteFile(dst, []byte(aggregatorMakefile), 0o644); err != nil {
		return fmt.Errorf("%s schreiben: %w", MakefilePath, err)
	}
	return nil
}

// AggregatorMakefile liefert den Aggregator-Inhalt (fuer Tests/Inspektion) — der
// netzlose Waechter auf die Ordnungskante, relocatet aus gen (slice-035).
func AggregatorMakefile() string { return aggregatorMakefile }
