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
	text := report.Schreibe(report.Bilanz{Sammelposten: 50, Gesamt: 200})
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
	text := report.Schreibe(report.Bilanz{MitZaehlern: 72, AgentLaeufe: 95})
	if !strings.Contains(text, "Abdeckung:") {
		t.Fatalf("Abdeckungs-Zeile fehlt:\n%s", text)
	}
	if !strings.Contains(text, "72 von 95") {
		t.Fatalf("Abdeckung ohne Bezugsmenge:\n%s", text)
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
