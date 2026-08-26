package emit

import (
	"github.com/pt9912/ai-harness-init/internal/span"
)

// FieldListPath ist der Zielort der Feldliste: der vom Doku-Gate des Ziels GEPRUEFTE
// Bereich (ADR-0022 Festlegung 7).
//
// NICHT unter .harness/** — die emittierte .d-check.yml nimmt jenen Baum aus, und eine
// Aussage an den Adopter gehoert dorthin, wo sein Doku-Gate sie liest. NICHT ins
// Technik-Stratum des Adopters (spec/spezifikation.md): das ist skip-if-present und
// gehoert ihm; eine Tabelle darin koennte ein Re-Lauf nie nachziehen und driftete mit der
// ersten Schema-Aenderung. Dass kein scan.ignore-Eintrag der emittierten .d-check.yml
// diesen Pfad trifft, misst TestFeldliste_LiegtImGeprueftenBereich; dass das Doku-Gate des
// Ziels ihn wirklich liest, belegt harness/tools/full-smoke.sh mit einem toten Verweis.
const FieldListPath = "harness/erfassung-feldliste.md"

// FieldList schreibt den Ausdruck des Traegers ueber sein eigenes Schema nach targetDir —
// KONVERGENT (ADR-0007 Idempotenz-Klasse, ADR-0022 Festlegung 4): tool-generiert, bei
// jedem Lauf kanonisch neu, heilt Drift und zieht eine Schema-Aenderung nach. Ein
// skip-if-present-Dokument bliebe nach der ersten Schema-Aenderung falsch stehen.
//
// VERBATIM: geschrieben wird, was span.FieldList liefert — kein Kopf, kein Stempel, keine
// Ersetzung. Dieselbe Konstruktion wie beim tool-generierten Doc-Gate-Fragment (MR-010).
// Damit ist die Drift zwischen erfasstem und dokumentiertem Feld KONSTRUKTIV
// ausgeschlossen statt per Regel verboten: beide kommen aus derselben Quelle.
//
// Der Fehler von span.FieldList wird DURCHGEREICHT, nicht geschluckt: er tritt genau dann
// auf, wenn Erfassung und Ausdruck auseinanderfallen, und ein Ziel mit einer Feldliste,
// die die Erfassung nicht mehr trifft, ist schlimmer als ein abgebrochener Bootstrap.
func FieldList(targetDir string) error {
	doc, err := span.FieldList()
	if err != nil {
		return err
	}
	return writeFileMode(targetDir, FieldListPath, []byte(doc), 0o644)
}
