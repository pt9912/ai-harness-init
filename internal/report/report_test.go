package report_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/report"
	"github.com/pt9912/ai-harness-init/internal/span"
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
// (spec/spezifikation.md §5, Zeile SPEC-046, Pruefreihenfolge Punkt 3).
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

// TestAggregiere_KennzeichnungIstKeineRolle haelt LH-FA-15 (Lesevorschrift): ein Call,
// dessen `agent_role` die Kennzeichnung *nicht bekannt* traegt, zaehlt wie ein Call mit
// leerem Rollenfeld — nicht im Nenner der Splitting-Regel, und keine Rolle
// *nicht bekannt* entsteht. Spans vor und nach der Umstellung landen damit im selben Posten.
func TestAggregiere_KennzeichnungIstKeineRolle(t *testing.T) {
	t.Parallel()
	dir := schreibeBestand(t,
		agentSpan("", 100, 0),
		callSpan("planner"),
		callSpan("nicht bekannt: agent_type"),
		callSpan(""),
		`{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Read","session":"s1",`+
			`"slice":"nicht bekannt: docs/plan/planning/in-progress","branch":"nicht bekannt: .git/HEAD"}`,
	)

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	for _, r := range b.Rollen {
		if span.IsNotKnown(r.Name) || r.Name == "" {
			t.Fatalf("die Kennzeichnung wurde als Rolle gelesen: %+v", b.Rollen)
		}
	}
	if got := rolle(t, b, "planner").Zugeteilt; got != 100 {
		t.Fatalf("planner zugeteilt = %d, erwartet 100 (der Call mit Kennzeichnung zaehlt nicht mit)", got)
	}
	if b.Fassungen[0] != 5 {
		t.Fatalf("lesbare Zeilen = %d, erwartet 5 — eine Zeile mit gekennzeichneter Liste bleibt lesbar", b.Fassungen[0])
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
	text := report.Schreibe(report.Bilanz{Sammelposten: 50, Gesamt: 200, Verteilt: true, AgentLaeufe: 1, MitZaehlern: 1, Zeilen: 4})
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
// in einer Fussnote (LH-FA-17 §Leser: "Die Auswertung nennt ihre Abdeckung zuerst und
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

// ZAHN (slice-071 DoD (1)): ein FEHLENDER Ablageort wird als solcher erkannt — nicht
// nur als "keine Zeile gelesen".
// Dauer-Sensor: test/mutations/491-report-ablageort-fehlt-nicht-erkannt.sh
func TestAggregiere_FehlenderAblageortWirdErkannt(t *testing.T) {
	t.Parallel()
	dir := filepath.Join(t.TempDir(), "existiert-nicht")

	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if !b.AblageortFehlt {
		t.Fatalf("AblageortFehlt = false, erwartet true fuer %q", dir)
	}
	if b.Zeilen != 0 {
		t.Fatalf("Zeilen = %d, erwartet 0", b.Zeilen)
	}
}

// Ein VORHANDENER, aber leerer Ablageort ist NICHT derselbe Fall wie ein fehlender —
// die Gegenprobe zum Zahn oben.
func TestAggregiere_VorhandenerLeererAblageortIstKeinFehlenderAblageort(t *testing.T) {
	t.Parallel()
	b, err := report.Aggregiere(t.TempDir())
	if err != nil {
		t.Fatalf("Aggregiere: %v", err)
	}
	if b.AblageortFehlt {
		t.Fatalf("AblageortFehlt = true fuer einen vorhandenen, leeren Ablageort")
	}
}

// ZAHN (slice-071 DoD (1)): ein FEHLENDER Ablageort meldet sich ANDERS als ein
// vorhandener, leerer — und keiner der beiden nennt eine Traeger-Ursache, die in
// diesem Zustand nicht zutreffen kann (das Programm laeuft schon, sonst gaebe es diese
// Zeile nicht; span-clean nimmt den Bestand, nicht das Programm).
// Dauer-Sensor: test/mutations/491-report-ablageort-fehlt-nicht-erkannt.sh,
// test/mutations/492-report-traeger-ursache-zurueckgeschrieben.sh
func TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer(t *testing.T) {
	t.Parallel()
	fehlt := report.Schreibe(report.Bilanz{Zeilen: 0, AblageortFehlt: true})
	leer := report.Schreibe(report.Bilanz{Zeilen: 0, AblageortFehlt: false})

	if !strings.Contains(fehlt, "existiert nicht") {
		t.Errorf("der fehlende Ablageort sagt nicht, dass er nicht existiert:\n%s", fehlt)
	}
	if strings.Contains(fehlt, "existiert, gelesen") {
		t.Errorf("der fehlende Ablageort traegt die Meldung des vorhandenen, leeren:\n%s", fehlt)
	}
	if !strings.Contains(leer, "existiert, gelesen") {
		t.Errorf("der vorhandene, leere Ablageort sagt nicht, dass er existiert:\n%s", leer)
	}
	if strings.Contains(leer, "existiert nicht") {
		t.Errorf("der vorhandene, leere Ablageort traegt die Meldung des fehlenden:\n%s", leer)
	}
	for _, text := range []string{fehlt, leer} {
		for _, verboten := range []string{"frischer Klon", "Aufraeum-Lauf"} {
			if strings.Contains(text, verboten) {
				t.Errorf("die Leere-Meldung nennt eine Traeger-Ursache, die hier nicht zutreffen kann (%q):\n%s", verboten, text)
			}
		}
	}
}

// ZAHN (slice-071 DoD (2)): Zeilen > 0 OHNE einen einzigen Agenten-Lauf ist eine eigene
// Lage — die Mechanik des Agenten-Werkzeugs traegt hier keine Schuld, weil kein
// Agenten-Aufruf lief, dessen Zaehler fehlen koennten. Der Grund-Satz zur Mechanik
// bleibt dort, wo er traegt: ueber einem Bestand MIT Agenten-Laeufen und ohne Zaehler.
// Dauer-Sensor: test/mutations/493-report-lage-ohne-agent-lauf-zusammengelegt.sh
func TestSchreibe_BestandOhneAgentLaufMeldetEigeneLage(t *testing.T) {
	t.Parallel()
	ohneAgent := report.Schreibe(report.Bilanz{Zeilen: 3, AgentLaeufe: 0})
	mitAgent := report.Schreibe(report.Bilanz{Zeilen: 3, AgentLaeufe: 2, MitZaehlern: 0})

	// Distinktes Fragment von grundDerZaehler statt "Mechanik des Agenten-Werkzeugs":
	// die neue Meldung NENNT diesen Ausdruck selbst, um ihn ausdruecklich zu
	// verneinen — ein Substring-Check darauf traefe faelschlich auf beide Texte.
	if strings.Contains(ohneAgent, "der Normalfall und kein Defekt") {
		t.Errorf("ohne Agenten-Lauf traegt die Meldung trotzdem den Mechanik-Grund-Satz:\n%s", ohneAgent)
	}
	if !strings.Contains(ohneAgent, "Keine Bilanz:") {
		t.Errorf("der Bestand ohne Agenten-Lauf sagt nicht, dass er keine Bilanz ausweist:\n%s", ohneAgent)
	}
	if !strings.Contains(mitAgent, "der Normalfall und kein Defekt") {
		t.Errorf("mit Agenten-Laeufen und ohne Zaehler fehlt der Mechanik-Grund-Satz:\n%s", mitAgent)
	}
}

// ZAHN (slice-071 DoD (3)): die Bestandszeile nennt, WAS sie zaehlt — die
// verschiedenen session-Werte der LESBAREN Zeilen — und greift dabei nicht ueber die
// gezaehlte Menge hinaus (keine zweite Zahl, keine Angabe ueber den ganzen Ablageort).
// Dauer-Sensor: test/mutations/494-report-bestandszeile-bezugsmenge-entfernt.sh
func TestSchreibe_BestandsZeileNenntIhreBezugsmenge(t *testing.T) {
	t.Parallel()
	text := report.Schreibe(report.Bilanz{
		Sitzungen: 3, Von: "2026-01-01T00:00:00Z", Bis: "2026-01-02T00:00:00Z",
		AgentLaeufe: 1, MitZaehlern: 1,
	})
	var zeile string
	for _, z := range strings.Split(text, "\n") {
		if strings.HasPrefix(z, "Bestand:") {
			zeile = z
			break
		}
	}
	if zeile == "" {
		t.Fatalf("keine Bestandszeile in der Ausgabe:\n%s", text)
	}
	if !strings.Contains(zeile, "session-Werte") {
		t.Errorf("die Bestandszeile nennt ihre Bezugsmenge nicht (session-Werte):\n%s", zeile)
	}
	if !strings.Contains(zeile, "lesbaren") {
		t.Errorf("die Bestandszeile grenzt sich nicht auf die lesbaren Zeilen ein:\n%s", zeile)
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
// `tool_use_id` (SPEC-052 in spec/spezifikation.md §5) und darf den Schluessel der
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
	text := report.Schreibe(report.Bilanz{Sammelposten: 150, Gesamt: 0, Verteilt: false, AgentLaeufe: 1, MitZaehlern: 1, Zeilen: 4})
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

// TestAggregiere_TrenntDieFassungen haelt SPEC-089 auf der Leser-Seite: jede lesbare Zeile
// zaehlt unter genau der Fassung, die sie traegt, und eine Zeile ohne `rule_version` unter
// *nicht bekannt* (Schluessel 0) — nie unter der laufenden Fassung des Lesers.
func TestAggregiere_TrenntDieFassungen(t *testing.T) {
	dir := schreibeBestand(t,
		`{"ts":"2026-10-08T10:00:00Z","tool":"Read","session":"s1","rule_version":4}`,
		`{"ts":"2026-10-08T10:00:01Z","tool":"Read","session":"s1","rule_version":4}`,
		`{"ts":"2026-10-08T10:00:02Z","tool":"Read","session":"s1","rule_version":99}`,
		`{"ts":"2026-10-07T10:00:00Z","tool":"Read","session":"s1"}`,
	)
	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatal(err)
	}
	want := map[int]int{4: 2, 99: 1, 0: 1}
	if len(b.Fassungen) != len(want) {
		t.Fatalf("Fassungen %v, erwartet %v", b.Fassungen, want)
	}
	for n, z := range want {
		if b.Fassungen[n] != z {
			t.Fatalf("Fassung %d: %d Zeile(n), erwartet %d (alle: %v)", n, b.Fassungen[n], z, b.Fassungen)
		}
	}
}

// TestAggregiere_FassungNullIstNichtBekannt haelt die Null-Haelfte von SPEC-089: eine Zeile
// mit `"rule_version":0` zaehlt wie eine ohne das Feld unter *Fassung nicht bekannt* — 0 ist
// der Nullwert des fehlenden Feldes, der Emitter schreibt ihn nie — und der Bericht nennt sie
// nicht als eigene Fassung 0.
func TestAggregiere_FassungNullIstNichtBekannt(t *testing.T) {
	dir := schreibeBestand(t,
		`{"ts":"2026-10-08T10:00:00Z","tool":"Read","session":"s1","rule_version":0}`,
		`{"ts":"2026-10-07T10:00:00Z","tool":"Read","session":"s1"}`,
	)
	b, err := report.Aggregiere(dir)
	if err != nil {
		t.Fatal(err)
	}
	aus := report.Schreibe(b)
	want := "Erfassungsregel: Fassung nicht bekannt: 2 Zeile(n)\n"
	if !strings.Contains(aus, want) {
		t.Fatalf("erwartet %q in:\n%s", want, aus)
	}
}

// TestSchreibe_NenntJedeFassungGetrennt haelt die Ausgabe von SPEC-089: der Bericht nennt
// jede Fassung mit ihrer Zeilenzahl, kennzeichnet eine Fassung, die der Leser nicht fuehrt,
// und fuehrt die Zeilen ohne Fassung als *nicht bekannt* auf — getrennt, nicht summiert.
func TestSchreibe_NenntJedeFassungGetrennt(t *testing.T) {
	aus := report.Schreibe(report.Bilanz{Zeilen: 4, Fassungen: map[int]int{4: 2, 99: 1, 0: 1}})
	want := "Erfassungsregel: Fassung 4: 2 Zeile(n) · Fassung 99 (dem Leser unbekannt): 1 Zeile(n) · Fassung nicht bekannt: 1 Zeile(n)\n"
	if !strings.Contains(aus, want) {
		t.Fatalf("die Fassungs-Zeile fehlt oder fasst zusammen, erwartet %q in:\n%s", want, aus)
	}
}

// TestSchreibe_OhneLesbareZeileKeineFassungsZeile haelt die Leer-Haelfte von SPEC-089: ein
// leerer Bestand und ein Bestand, dessen Zeilen alle unlesbar sind, tragen keine Fassung,
// und der Bericht schreibt dann keine Zeile `Erfassungsregel:` — auch keine leere.
func TestSchreibe_OhneLesbareZeileKeineFassungsZeile(t *testing.T) {
	for name, dir := range map[string]string{
		"leer":     t.TempDir(),
		"unlesbar": schreibeBestand(t, `kein json`, `{"ts":"2026-10-08T10:00:00Z","tool":"Read","rule_version":"vier"}`),
	} {
		b, err := report.Aggregiere(dir)
		if err != nil {
			t.Fatalf("%s: %v", name, err)
		}
		if aus := report.Schreibe(b); strings.Contains(aus, "Erfassungsregel:") {
			t.Fatalf("%s: Bestand ohne lesbare Zeile, erwartet keine Fassungs-Zeile in:\n%s", name, aus)
		}
	}
}

// TestSchreibe_FassungUnterEinsIstDemLeserUnbekannt haelt die untere Grenze der
// Kennzeichnung aus SPEC-089: eine Fassung kleiner als 1 fuehrt die Tabelle nicht, der
// Bericht nennt sie mit dem Zusatz `dem Leser unbekannt` und nicht als Fassung nicht bekannt.
func TestSchreibe_FassungUnterEinsIstDemLeserUnbekannt(t *testing.T) {
	aus := report.Schreibe(report.Bilanz{Zeilen: 1, Fassungen: map[int]int{-1: 1}})
	want := "Erfassungsregel: Fassung -1 (dem Leser unbekannt): 1 Zeile(n)\n"
	if !strings.Contains(aus, want) {
		t.Fatalf("erwartet %q in:\n%s", want, aus)
	}
}
