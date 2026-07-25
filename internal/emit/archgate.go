package emit

import (
	"context"
	"fmt"
	"strings"
)

// Arch-Gate-Emission (slice-046, LH-FA-07, ADR-0009). Dasselbe Muster wie das
// Doc-Gate: die Schicht-Config ist tool-autoriert (sie muss zum generierten Skelett
// passen), das `.mk`-Fragment entsteht zur Bootstrap-Zeit aus `a-check --print-mk`
// und wird mechanisch adaptiert. KONDITIONAL: der Aufrufer emittiert nur, wenn das
// Modul ein schichten-tragendes Layout traegt (gen.ArchGateConfig) — ueber einem
// flachen Skelett gaebe es keinen Pruefbereich (LH-QA-01).

// DefaultArchImage ist die per Default gepinnte a-check-Tag-Referenz, DefaultArchDigest
// der zugehoerige Pin (LH-QA-02). Beide sind per Env (A_CHECK_IMAGE/A_CHECK_DIGEST)
// bewusst ueberschreibbar; die Semantik (Digest sticht Tag) ist dieselbe wie beim
// Doc-Gate. Der Digest ist gegen die Registry verifiziert (v0.15.0, slice-046 Schritt 0).
const (
	DefaultArchImage  = "ghcr.io/pt9912/a-check:v0.15.0"
	DefaultArchDigest = "sha256:6425c93a9a4359ef28c4da231a2d1db6f421fdaa8f96877ac89d201827c42d09"
)

// ArchConfigName ist der Dateiname der Schicht-Config IM MODUL (bei <pfad>="." also
// im Ziel-Root). ArchMkPath ist der Zielpfad des tool-generierten Fragments — es liegt
// wie d-check.mk im Ziel-Root, weil die Fragmente von dort per `include` aufgeloest werden.
const (
	ArchConfigName = ".a-check.yml"
	ArchMkPath     = "a-check.mk"
)

// archAdopterHeader ersetzt den a-check-eigenen Kopf-Kommentar im emittierten Fragment.
const archAdopterHeader = "# a-check.mk — Architektur-Gate via a-check. Emittiert von ai-harness-init,\n" +
	"# adaptiert aus `a-check --print-mk`: A_CHECK_IMAGE auf den Digest gepinnt, der das\n" +
	"# Fragment ERZEUGT hat (der vom Tool gedruckte Pin kann nachhinken — Reproduzierbarkeit).\n" +
	"# Eingebunden vom Arch-Gate-Fragment unter harness/mk/; die .a-check.yml liegt im Modul.\n"

// ArchGateMkPath ist der Zielpfad des Arch-Gate-Fragments eines Moduls — modul-scoped
// wie das Code-Gate-Fragment (slice-037), damit zwei hexSlice-Module in einem Mono-Repo
// koexistieren, statt sich eine Root-Config zu teilen.
func ArchGateMkPath(modul string) string { return "harness/mk/arch-" + modul + ".mk" }

// ArchGateMk liefert den Inhalt des Arch-Gate-Fragments fuer Modul modul am Pfad path.
// Am Root (path ".") haengt es das Tool-eigene Target `a-check` an GATE_CHECKS
// (byte-nah an der kanonischen Nutzung); im Unterverzeichnis definiert es das
// modul-scoped `a-check-<modul>`, das NUR das Modul-Verzeichnis mountet — sonst liefe
// a-check mit der Modul-Config ueber dem ganzen Repo (die Globs traefen nichts bzw. das
// Falsche). Der ifndef-Waechter macht `include a-check.mk` include-once: ohne ihn
// wuerde ein zweites hexSlice-Modul dieselben Targets ein zweites Mal definieren
// (`overriding recipe`).
func ArchGateMk(modul, path string) string {
	head := "# " + ArchGateMkPath(modul) + " — Arch-Gate-Fragment (Modul " + modul + "), emittiert von\n" +
		"# ai-harness-init (slice-046). Bindet das tool-generierte a-check.mk ein und haengt das\n" +
		"# Architektur-Gate an GATE_CHECKS; der Root-Aggregator faehrt es via make gates.\n" +
		"ifndef A_CHECK_IMAGE\n" +
		"include " + ArchMkPath + "\n" +
		"endif\n"
	if path == "." {
		return head + "GATE_CHECKS += a-check\n"
	}
	target := "a-check-" + modul
	return head +
		"\n.PHONY: " + target + "\n" +
		target + ": ## Architektur-Gate Modul " + modul + " (a-check, netzlos, read-only)\n" +
		"\tdocker run --rm --network none -v \"$(CURDIR)/" + path + "\":/src:ro $(A_CHECK_IMAGE) /src\n" +
		"GATE_CHECKS += " + target + "\n"
}

// PrintMK ist die Quelle des tool-generierten Gate-Fragments: `docker run <ref> --print-mk`.
// Als Typ injizierbar, damit der Emit-Pfad OHNE Docker unit-testbar bleibt (der add-lang-
// Pfad hat, anders als der Bootstrap, netzlose Erfolgs-Faelle) — dieselbe Linie wie die
// injizierte Baseline-Quelle in cmd.
type PrintMK func(ctx context.Context, ref string) ([]byte, error)

// DockerPrintMK ist die reale PrintMK-Implementierung (Docker-only, ADR-0003).
func DockerPrintMK(ctx context.Context, ref string) ([]byte, error) { return printMK(ctx, ref) }

// ArchGate emittiert das Architektur-Gate eines Moduls nach targetDir: die Schicht-Config
// <path>/.a-check.yml (SKIP-IF-PRESENT — der Adopter passt seine Schichten an, sobald er
// example/greet durch eigene Areas ersetzt), das tool-generierte a-check.mk und das
// Arch-Gate-Fragment (beide KONVERGENT — tool-generiert, heilen Drift/Digest-Bump;
// Idempotenz-Klassen nach ADR-0007/slice-038). Reihenfolge wie bei DocGate: erst die
// fallierbaren Schritte (docker --print-mk, Adaption), dann die Schreibvorgaenge.
func ArchGate(ctx context.Context, targetDir, path, modul, config string, opts Options, printFragment PrintMK) error {
	raw, err := printFragment(ctx, opts.RunRef())
	if err != nil {
		return err
	}
	mk, err := AdaptArchMK(raw, opts.RunRef())
	if err != nil {
		return err
	}
	cfgRel := ArchConfigName
	if path != "." {
		cfgRel = path + "/" + ArchConfigName
	}
	if err := writeSkipIfPresent(targetDir, cfgRel, []byte(config), 0o644); err != nil {
		return err
	}
	if err := writeFileMode(targetDir, ArchMkPath, mk, 0o644); err != nil {
		return err
	}
	return writeFileMode(targetDir, ArchGateMkPath(modul), []byte(ArchGateMk(modul, path)), 0o644)
}

// AdaptArchMK wandelt rohe `a-check --print-mk`-Ausgabe in das Adopter-Fragment: der
// a-check-eigene Kopf wird ersetzt und A_CHECK_IMAGE auf ref gepinnt — die Referenz, mit
// der das Fragment ERZEUGT wurde. Das ist kein Ritual: a-check druckt einen im Binary
// gebackenen Pin, der dem laufenden Image nachhinken kann (gemessen bei v0.15.0). Wer ihn
// uebernaehme, emittierte eine stille Unwahrheit (LH-QA-02). Bricht ab, wenn der Anker
// fehlt oder der Pin nicht greift — statt ein halb adaptiertes Fragment zu emittieren.
func AdaptArchMK(raw []byte, ref string) ([]byte, error) {
	const anchor = "A_CHECK_IMAGE ?="
	s := string(raw)
	i := strings.Index(s, anchor)
	if i < 0 {
		return nil, fmt.Errorf("unerwartete --print-mk-ausgabe: %q nicht gefunden", anchor)
	}
	body := s[i:]
	nl := strings.Index(body, "\n")
	if nl < 0 {
		return nil, fmt.Errorf("unerwartete --print-mk-ausgabe: %q ohne Zeilenende", anchor)
	}
	body = anchor + " " + ref + body[nl:]
	if !strings.Contains(body, anchor+" "+ref+"\n") {
		return nil, fmt.Errorf("pinnen von A_CHECK_IMAGE auf %s fehlgeschlagen (--print-mk-format geaendert?)", ref)
	}
	return []byte(archAdopterHeader + body), nil
}
