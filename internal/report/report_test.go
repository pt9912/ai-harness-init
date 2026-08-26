package report_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/report"
)

// schreibeBestand legt einen Span-Bestand aus fertigen Zeilen an.
func schreibeBestand(t *testing.T, zeilen ...string) string {
	t.Helper()
	dir := t.TempDir()
	pfad := filepath.Join(dir, "sitzung-agent.jsonl")
	if err := os.WriteFile(pfad, []byte(strings.Join(zeilen, "\n")+"\n"), 0o600); err != nil {
		t.Fatalf("Bestand anlegen: %v", err)
	}
	return dir
}

// agentSpan baut eine Agent-Zeile mit Zaehlern.
func agentSpan(rolle string, in, out int64) string {
	r := ""
	if rolle != "" {
		r = `"spawned_role":"` + rolle + `",`
	}
	return `{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Agent","session":"s1",` +
		r + `"input_tokens":` + itoa(in) + `,"output_tokens":` + itoa(out) + `}`
}

// callSpan baut eine Nicht-Agent-Zeile, die dem Schluessel der Splitting-Regel zaehlt.
func callSpan(aufruferRolle string) string {
	return `{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Read","session":"s1",` +
		`"agent_role":"` + aufruferRolle + `"}`
}

func itoa(n int64) string {
	if n == 0 {
		return "0"
	}
	var b []byte
	for n > 0 {
		b = append([]byte{byte('0' + n%10)}, b...)
		n /= 10
	}
	return string(b)
}

func TestAggregiere_SummiertJeRolle(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("planner", 100, 50),
		agentSpan("planner", 10, 5),
		agentSpan("reviewer", 20, 10),
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if b.Gesamt != 195 {
		t.Fatalf("Gesamt = %d, erwartet 195", b.Gesamt)
	}
	if b.Rollen[0].Name != "planner" || b.Rollen[0].Summe() != 165 {
		t.Fatalf("groesste Rolle = %s/%d, erwartet planner/165", b.Rollen[0].Name, b.Rollen[0].Summe())
	}
}

// Der Sammelposten wird VERTEILT, nicht als eigene Zeile gefuehrt — den ungeteilten
// Sammelposten als Rolle zu drucken erfindet eine Kostenstelle, die es nicht gibt
// (spec/spezifikation.md §5, Pruefreihenfolge Punkt 3).
func TestAggregiere_SammelpostenWirdAnteiligVerteilt(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("planner", 100, 0),
		agentSpan("", 100, 0), // ohne Rolle -> Sammelposten
		callSpan("planner"), callSpan("planner"), callSpan("planner"),
		callSpan("reviewer"),
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if b.Sammelposten != 100 {
		t.Fatalf("Sammelposten = %d, erwartet 100", b.Sammelposten)
	}
	for _, r := range b.Rollen {
		if r.Name == "unbekannt" || r.Name == "" {
			t.Fatalf("Sammelposten als eigene Rolle gefuehrt: %+v", r)
		}
	}
	// 3 von 4 Tool-Calls sind planner -> 75 der 100 Sammelposten-Token.
	if got := rolle(t, b, "planner").Zugeteilt; got != 75 {
		t.Fatalf("planner zugeteilt = %d, erwartet 75", got)
	}
	if got := rolle(t, b, "reviewer").Zugeteilt; got != 25 {
		t.Fatalf("reviewer zugeteilt = %d, erwartet 25", got)
	}
}

// Rollenlose Calls bleiben aus dem Nenner der Splitting-Regel: sonst verteilte der
// Sammelposten teilweise auf sich selbst.
func TestAggregiere_RollenloseCallsNichtImNenner(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("", 100, 0),
		callSpan("planner"),
		`{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Read","session":"s1","agent_role":""}`,
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if got := rolle(t, b, "planner").Zugeteilt; got != 100 {
		t.Fatalf("planner zugeteilt = %d, erwartet 100 (der rollenlose Call zaehlt nicht mit)", got)
	}
}

// Ein Agent-Span OHNE Zaehler zaehlt in die Abdeckung, aber nicht in die Bilanz —
// genau diese Differenz ist die Aussage der Abdeckungszahl.
func TestAggregiere_AbdeckungZaehltLaeufeOhneZaehler(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("planner", 10, 0),
		`{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Agent","session":"s1"}`,
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if b.AgentLaeufe != 2 || b.MitZaehlern != 1 {
		t.Fatalf("Abdeckung = %d von %d, erwartet 1 von 2", b.MitZaehlern, b.AgentLaeufe)
	}
}

// ZAHN 1 (DoD (2)): der Nenner. Die Bilanz rechnet ueber Subagenten-Laeufe, nicht
// ueber den Lauf — der Haupt-Kontext traegt dauerhaft keine Zaehler (ADR-0012).
// Faellt die Angabe aus der Ausgabe, faellt dieser Test.
// Dauer-Sensor: test/mutations/140-report-nenner-entfernt.sh
func TestSchreibe_NennerStehtDrin(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{})
	if !strings.Contains(text, "Subagenten-Laeufe") || !strings.Contains(text, "nicht ueber den Lauf") {
		t.Fatalf("Nenner fehlt in der Ausgabe:\n%s", text)
	}
}

// ZAHN 2 (DoD (1)): der Sammelposten-Anteil. Ohne ihn ruht die Bilanz auf einer
// Regel, ohne dass der Leser es sieht.
// Dauer-Sensor: test/mutations/141-report-sammelposten-anteil-entfernt.sh
func TestSchreibe_SammelpostenAnteilStehtDrin(t *testing.T) {
	t.Parallel()
	// Verteilt: true — dieser Zahn gilt dem VERTEILTEN Fall. Den unverteilten
	// bewacht TestSchreibe_UnverteilterSammelpostenStehtAusserhalb, und er darf
	// gerade keinen Prozentsatz tragen.
	// MitZaehlern/Zeilen gesetzt, weil eine Bilanz nur ueber einem Bestand MIT
	// Verbrauchs-Zaehlern ausgewiesen wird — ohne sie meldete die Ausgabe zu Recht
	// ihre Leere, und dieser Zahn traefe den falschen Zweig.
	text := report.Schreibe(report.Bilanz{Sammelposten: 50, Gesamt: 200, Verteilt: true, MitZaehlern: 1, Zeilen: 4})
	if !strings.Contains(text, "Sammelposten:") {
		t.Fatalf("Sammelposten-Zeile fehlt:\n%s", text)
	}
	if !strings.Contains(text, "%") {
		t.Fatalf("Sammelposten-Anteil ohne Prozentsatz:\n%s", text)
	}
}

// ZAHN 3 (DoD (1)): die Abdeckungszahl, und zwar MIT ihrer Bezugsmenge — ein
// nackter Prozentsatz sagt nicht, worueber er rechnet.
// Dauer-Sensor: test/mutations/142-report-abdeckung-entfernt.sh
func TestSchreibe_AbdeckungStehtDrin(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{MitZaehlern: 72, AgentLaeufe: 95, Zeilen: 300})
	if !strings.Contains(text, "Abdeckung:") {
		t.Fatalf("Abdeckungs-Zeile fehlt:\n%s", text)
	}
	if !strings.Contains(text, "72 von 95") {
		t.Fatalf("Abdeckung ohne Bezugsmenge:\n%s", text)
	}
}

// ZAHN 4 (slice-099 DoD (1)): die Abdeckung steht ZUERST — in der ersten Zeile, nicht
// in einer Fussnote (LH-FA-10 §Leser: "Die Auswertung nennt ihre Abdeckung zuerst und
// meldet damit ihre eigene Leere"). Wer nach der ersten Zahl aufhoert zu lesen, hat
// dann die Aussage ueber den Nenner gesehen und nicht eine Zahl ohne ihn.
// Dauer-Sensor: test/mutations/173-leser-abdeckung-nicht-zuerst.sh
func TestSchreibe_AbdeckungStehtZuerst(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{MitZaehlern: 3, AgentLaeufe: 9, Zeilen: 40, Gesamt: 100,
		Rollen: []report.Rolle{{Name: "planner", Direkt: 100}}})
	erste, _, _ := strings.Cut(text, "\n")
	if !strings.HasPrefix(erste, "Abdeckung:") {
		t.Fatalf("die erste Zeile ist nicht die Abdeckung, sondern %q:\n%s", erste, text)
	}
}

// ZAHN 5 (slice-099 DoD (1)): ueber einem Bestand OHNE Verbrauchs-Zaehler wird KEINE
// Bilanz ausgewiesen. Eine Rollen-Zeile mit einer Null ist eine Rechnung, die nicht
// stattgefunden hat — genau die Gate-Luege als Kennzahl, die ADR-0022 Festlegung 8
// ausschliesst.
//
// Der Bestand ist NICHT leer (Zeilen > 0): das ist der Fall, in dem erfasst wurde und
// die Zaehler trotzdem fehlen. Den leeren Bestand misst der Zahn darunter.
// Dauer-Sensor: test/mutations/174-leser-bilanz-ohne-zaehler.sh
func TestSchreibe_OhneZaehlerKeineBilanz(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{
		AgentLaeufe: 4, MitZaehlern: 0, Zeilen: 40,
		Rollen: []report.Rolle{{Name: "planner", ToolCalls: 12}, {Name: "reviewer", ToolCalls: 3}},
	})
	for _, verboten := range []string{"planner", "reviewer", "Groesste Rolle", "Sammelposten:"} {
		if strings.Contains(text, verboten) {
			t.Errorf("ueber einem Bestand ohne Zaehler steht %q in der Ausgabe — das ist eine Bilanz:\n%s", verboten, text)
		}
	}
	if !strings.Contains(text, "Keine Bilanz:") {
		t.Errorf("die Ausgabe sagt nicht, dass sie keine Bilanz ausweist:\n%s", text)
	}
}

// ZAHN 6 (slice-099 DoD (1)): ein LEERER Bestand wird anders gemeldet als ein Bestand
// ohne Verbrauchs-Zaehler. Beide sehen beim Leser gleich aus, und genau das ist die
// Falle: ohne Zeile gibt es nichts, was Zaehler tragen koennte — die Leere kommt dann
// von einem Traeger, der nicht liegt, nicht von der Mechanik des Agenten-Werkzeugs.
// Wer beide gleich meldete, gaebe im zweiten Fall eine falsche Begruendung
// (ADR-0022 Festlegung 8: "und ihn von einem bloss leeren Bestand unterscheidet").
// Dauer-Sensor: test/mutations/175-leser-leere-ohne-unterscheidung.sh
func TestSchreibe_LeererBestandNenntSeineLeere(t *testing.T) {
	t.Parallel()
	leer := report.Schreibe(report.Bilanz{Zeilen: 0})
	ohneZaehler := report.Schreibe(report.Bilanz{Zeilen: 40, AgentLaeufe: 4})

	if !strings.Contains(leer, "Kein Bestand:") {
		t.Errorf("der leere Bestand meldet seine Leere nicht als solche:\n%s", leer)
	}
	if !strings.Contains(leer, "KEINE Aussage ueber die Verbrauchs-Zaehler") {
		t.Errorf("der leere Bestand grenzt sich nicht gegen den Zaehler-Fall ab:\n%s", leer)
	}
	if strings.Contains(leer, "Keine Bilanz:") {
		t.Errorf("der leere Bestand traegt die Meldung des zaehlerlosen Bestands — beide Leeren sind dieselbe geworden:\n%s", leer)
	}
	// Die Gegenprobe traegt zwei Bruchstellen, und jede bekommt ihre eigene Meldung:
	// der zaehlerlose Bestand darf sich weder wie ein leerer melden noch die Aussage
	// verlieren, dass er keine Bilanz ausweist. Eine gemeinsame Meldung waere in einem
	// der zwei Faelle die falsche Begruendung.
	if strings.Contains(ohneZaehler, "Kein Bestand:") {
		t.Errorf("der zaehlerlose Bestand meldet sich wie ein leerer:\n%s", ohneZaehler)
	}
	if !strings.Contains(ohneZaehler, "Keine Bilanz:") {
		t.Errorf("der zaehlerlose Bestand sagt nicht, dass er keine Bilanz ausweist — die Gegenprobe zum leeren Bestand misst dann nichts:\n%s", ohneZaehler)
	}
}

// Der Bestand zaehlt JEDE nicht-leere Zeile, auch die unlesbare: gemessen wird, ob
// ueberhaupt erfasst wurde. Ohne diese Lesart meldete ein Bestand aus lauter kaputten
// Zeilen "kein Bestand" — und der Leser gaebe einem fehlenden Traeger die Schuld an
// einem Schreibfehler.
func TestAggregiere_ZeilenZaehltAuchUnlesbare(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t, agentSpan("planner", 10, 5), "{kaputt", "")

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if b.Zeilen != 2 {
		t.Fatalf("Zeilen = %d, erwartet 2 (die Agent-Zeile und die kaputte, nicht die leere)", b.Zeilen)
	}
}

func rolle(t *testing.T, b report.Bilanz, name string) report.Rolle {
	t.Helper()
	for _, r := range b.Rollen {
		if r.Name == name {
			return r
		}
	}
	t.Fatalf("Rolle %q fehlt in %+v", name, b.Rollen)
	return report.Rolle{}
}

// Ein Spawn ist KEIN Tool-Call: `SubagentStart` traegt weder `tool_name` noch
// `tool_use_id` (spec/spezifikation.md §5) und darf den Schluessel der
// Splitting-Regel nicht verschieben.
// Dauer-Sensor: test/mutations/147-report-spawn-als-toolcall.sh
func TestAggregiere_SpawnSpanZaehltNichtAlsToolCall(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("", 100, 0),
		callSpan("planner"),
		// Ein Spawn-Span mit Rolle, aber ohne Werkzeug — er darf nicht zaehlen.
		`{"ts":"2026-08-08T10:00:00Z","event":"SubagentStart","tool":"","session":"s1","agent_role":"reviewer"}`,
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	for _, r := range b.Rollen {
		if r.Name == "reviewer" && r.ToolCalls != 0 {
			t.Fatalf("Spawn-Span als Tool-Call gezaehlt: reviewer hat %d", r.ToolCalls)
		}
	}
	if got := rolle(t, b, "planner").Zugeteilt; got != 100 {
		t.Fatalf("planner zugeteilt = %d, erwartet 100 (der Spawn zaehlt nicht mit)", got)
	}
}

// Ein Sammelposten, den keine Rolle aufnehmen kann, liegt AUSSERHALB der Summe —
// und die Ausgabe sagt das, statt eine Verteilung zu behaupten, die nicht
// stattgefunden hat.
// Dauer-Sensor: test/mutations/148-report-unverteilt-als-verteilt.sh
func TestSchreibe_UnverteilterSammelpostenStehtAusserhalb(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{Sammelposten: 150, Gesamt: 0, Verteilt: false, MitZaehlern: 1, Zeilen: 4})
	if strings.Contains(text, "anteilig nach Tool-Calls verteilt") {
		t.Fatalf("behauptet eine Verteilung, die nicht stattfand:\n%s", text)
	}
	if !strings.Contains(text, "NICHT verteilt") || !strings.Contains(text, "NICHT enthalten") {
		t.Fatalf("der unverteilte Sammelposten steht nicht als solcher da:\n%s", text)
	}
}

// Die Summe der Zuteilungen ist genau der Sammelposten: die Ganzzahl-Division
// laesst je Rolle bis zu ein Token liegen, und ein liegengebliebenes Token steht
// auf keiner Zeile, waehrend die Ausgabe es als verteilt nennt.
// Dauer-Sensor: test/mutations/149-report-ganzzahlrest-faellt-weg.sh
func TestAggregiere_GanzzahlRestGehtNichtVerloren(t *testing.T) {
	t.Parallel()
	// 10 Token auf drei Rollen mit 1/1/1 Tool-Calls: 10/3 = 3 je Rolle, Rest 1.
	dir := schreibeBestand(t,
		agentSpan("", 10, 0),
		callSpan("planner"), callSpan("reviewer"), callSpan("architect"),
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	var summe int64
	for _, r := range b.Rollen {
		summe += r.Zugeteilt
	}
	if summe != b.Sammelposten {
		t.Fatalf("Zuteilungen = %d, Sammelposten = %d — %d Token liegen auf keiner Zeile",
			summe, b.Sammelposten, b.Sammelposten-summe)
	}
	if b.Gesamt != b.Sammelposten {
		t.Fatalf("Gesamt = %d, erwartet %d", b.Gesamt, b.Sammelposten)
	}
}
