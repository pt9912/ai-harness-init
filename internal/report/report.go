// Package report rechnet aus den geschriebenen Spans eine Token-Bilanz je Rolle.
//
// Der Gegenstand ist NUR der Bestand unter dem Ablageort — kein Transkript, keine
// Quelle ausserhalb des Repos. Der Ablageort ist der gitignorierte Zustands-Bereich
// ausserhalb des versionierten Baums (ADR-0011 Festlegung 3). Die Bilanz rechnet
// ueber SUBAGENTEN-Laeufe: der Haupt-Kontext traegt dauerhaft keine Zaehler, und
// das ist als permanente Abweichung entschieden (ADR-0012). Deshalb nennt jede
// Ausgabe dieses Pakets ihren Nenner — siehe Text.
package report

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// Rolle ist eine Zeile der Bilanz: was direkt gemessen wurde, was ihr aus dem
// Sammelposten zugeteilt wurde, und die Summe daraus.
type Rolle struct {
	Name      string
	Direkt    int64
	Zugeteilt int64
	ToolCalls int64
}

// Summe ist der Wert, der in der Bilanz steht.
func (r Rolle) Summe() int64 { return r.Direkt + r.Zugeteilt }

// Bilanz ist das vollstaendige Ergebnis. Die drei Angaben, die neben den
// Rollen-Zeilen stehen muessen, sind eigene Felder und keine Prosa: Sammelposten
// (worauf die Bilanz per Regel ruht), Abdeckung (wie viel des Bestands ueberhaupt
// Zaehler trug) und die Bestandsgrenzen (worueber gerechnet wurde).
type Bilanz struct {
	Rollen       []Rolle
	Gesamt       int64
	Sammelposten int64
	// Verteilt ist wahr, wenn die Splitting-Regel angewendet werden konnte — also
	// mindestens eine Rolle Tool-Calls traegt. Ist es falsch, liegt Sammelposten in
	// keiner Rollen-Zeile und damit ausserhalb von Gesamt.
	Verteilt    bool
	AgentLaeufe int
	MitZaehlern int
	Sitzungen   int
	Von         string
	Bis         string
	// Zeilen ist die Zahl der nicht-leeren Zeilen des Bestands — auch der nicht
	// lesbaren. Sie unterscheidet zwei Leeren, die sonst gleich aussehen: einen
	// Bestand OHNE ZEILE (es wurde nichts erfasst) von einem Bestand mit Zeilen und
	// ohne Verbrauchs-Zaehler. Nur die zweite Leere hat ihren Grund in der Mechanik
	// des Agenten-Werkzeugs; die erste kommt von einem Traeger, der nicht liegt.
	Zeilen int
}

// TraegtZaehler ist wahr, wenn mindestens ein Subagenten-Lauf des Bestands
// Verbrauchs-Zaehler trug — die Bedingung, unter der eine Bilanz eine Rechnung ist
// und keine Behauptung ueber leerem Grund.
func (b Bilanz) TraegtZaehler() bool { return b.MitZaehlern > 0 }

// SammelpostenAnteil ist der Anteil der Bilanz, der auf der Splitting-Regel ruht
// statt auf einer Messung.
func (b Bilanz) SammelpostenAnteil() float64 {
	if b.Gesamt == 0 {
		return 0
	}
	return float64(b.Sammelposten) / float64(b.Gesamt) * 100
}

// Aggregiere liest jede `*.jsonl` unter dir und rechnet die Bilanz.
//
// Gruppiert wird nach den FELDERN, nie nach dem Dateinamen — das verlangt
// spec/spezifikation.md §5 bindend, weil der Dateiname eine Ableitung ist und sich
// aendern darf. Eine kaputte Zeile beendet den Lauf nicht: der Bestand ist ein
// angehaengter Strom, und ein halb geschriebener Eintrag am Ende ist kein Grund,
// die ganze Rechnung zu verweigern.
func Aggregiere(dir string) (Bilanz, error) {
	dateien, err := filepath.Glob(filepath.Join(dir, "*.jsonl"))
	if err != nil {
		return Bilanz{}, err
	}
	sort.Strings(dateien)

	var (
		b         Bilanz
		direkt    = map[string]int64{}
		toolCalls = map[string]int64{}
		sitzungen = map[string]struct{}{}
	)

	for _, name := range dateien {
		roh, err := os.ReadFile(name)
		if err != nil {
			return Bilanz{}, err
		}
		for _, zeile := range strings.Split(string(roh), "\n") {
			if strings.TrimSpace(zeile) == "" {
				continue
			}
			// VOR dem Parsen gezaehlt: gemessen wird, ob ueberhaupt etwas erfasst
			// wurde. Eine unlesbare Zeile ist ein Bestand, kein fehlender Traeger.
			b.Zeilen++
			var s span.Span
			if json.Unmarshal([]byte(zeile), &s) != nil {
				continue
			}
			verarbeite(&b, s, direkt, toolCalls, sitzungen)
		}
	}

	b.Sitzungen = len(sitzungen)
	b.Rollen, b.Verteilt = verteile(direkt, toolCalls, b.Sammelposten)
	for _, r := range b.Rollen {
		b.Gesamt += r.Summe()
	}
	return b, nil
}

// verarbeite zieht aus einer Zeile alles, was die Bilanz braucht.
func verarbeite(b *Bilanz, s span.Span, direkt, toolCalls map[string]int64, sitzungen map[string]struct{}) {
	if s.Session != "" {
		sitzungen[s.Session] = struct{}{}
	}
	if s.TS != "" {
		if b.Von == "" || s.TS < b.Von {
			b.Von = s.TS
		}
		if s.TS > b.Bis {
			b.Bis = s.TS
		}
	}

	// Der Schluessel der Splitting-Regel: Tool-Calls je Rolle. Zwei Filter, und
	// beide tragen. Rollenlose Calls bleiben AUSSEN, sonst verteilte der
	// Sammelposten teilweise auf sich selbst. Und ein Span OHNE Werkzeug ist kein
	// Tool-Call: `SubagentStart` feuert je Spawn, traegt weder `tool_name` noch
	// `tool_use_id` (spec/spezifikation.md §5) und darf einen Schluessel, der
	// Tool-Calls zaehlt, nicht verschieben.
	// Bewacht von TestAggregiere_SpawnSpanZaehltNichtAlsToolCall.
	if s.AgentRole != "" && s.Tool != "" {
		toolCalls[s.AgentRole]++
	}

	if s.Tool != "Agent" {
		return
	}
	b.AgentLaeufe++
	if s.InputTokens == nil && s.OutputTokens == nil {
		return
	}
	b.MitZaehlern++

	var tokens int64
	if s.InputTokens != nil {
		tokens += *s.InputTokens
	}
	if s.OutputTokens != nil {
		tokens += *s.OutputTokens
	}

	// Leeres spawned_role heisst UNBEKANNT, nie "ohne Rolle" (Lesevorschrift in
	// spec/spezifikation.md §5). Der Lauf wandert deshalb in den Sammelposten und
	// wird verteilt, statt eine eigene Zeile zu bekommen.
	if s.SpawnedRole == "" {
		b.Sammelposten += tokens
		return
	}
	direkt[s.SpawnedRole] += tokens
}

// verteile wendet die Splitting-Regel an: der Sammelposten geht ANTEILIG NACH
// TOOL-CALLS auf die realen Rollen. Die Regel selbst steht als Festlegung in
// spec/spezifikation.md §5 — hier lebt nur ihre Umsetzung.
//
// Traegt keine Rolle Tool-Calls, bleibt der Sammelposten unverteilt; der zweite
// Rueckgabewert sagt, welcher der beiden Faelle vorliegt.
func verteile(direkt, toolCalls map[string]int64, sammelposten int64) ([]Rolle, bool) {
	namen := map[string]struct{}{}
	for n := range direkt {
		namen[n] = struct{}{}
	}
	for n := range toolCalls {
		namen[n] = struct{}{}
	}

	var summeCalls int64
	for n := range namen {
		summeCalls += toolCalls[n]
	}

	rollen := make([]Rolle, 0, len(namen))
	for n := range namen {
		r := Rolle{Name: n, Direkt: direkt[n], ToolCalls: toolCalls[n]}
		if summeCalls > 0 {
			r.Zugeteilt = sammelposten * toolCalls[n] / summeCalls
		}
		rollen = append(rollen, r)
	}

	// Der Rest der Ganzzahl-Division geht deterministisch weiter — absteigend nach
	// Tool-Calls, bei Gleichstand alphabetisch, je ein Token —, damit die Summe der
	// Zuteilungen genau der Sammelposten ist.
	// Bewacht von TestAggregiere_GanzzahlRestGehtNichtVerloren.
	if summeCalls > 0 {
		verteileRest(rollen, sammelposten)
	}

	sort.Slice(rollen, func(i, j int) bool {
		if rollen[i].Summe() != rollen[j].Summe() {
			return rollen[i].Summe() > rollen[j].Summe()
		}
		return rollen[i].Name < rollen[j].Name
	})
	return rollen, summeCalls > 0
}

// verteileRest gibt den Rundungsrest weiter, damit die Summe der Zuteilungen
// genau der Sammelposten ist.
func verteileRest(rollen []Rolle, sammelposten int64) {
	var zugeteilt int64
	for _, r := range rollen {
		zugeteilt += r.Zugeteilt
	}
	rest := sammelposten - zugeteilt
	if rest <= 0 {
		return
	}

	reihenfolge := make([]int, len(rollen))
	for i := range rollen {
		reihenfolge[i] = i
	}
	sort.Slice(reihenfolge, func(a, b int) bool {
		ra, rb := rollen[reihenfolge[a]], rollen[reihenfolge[b]]
		if ra.ToolCalls != rb.ToolCalls {
			return ra.ToolCalls > rb.ToolCalls
		}
		return ra.Name < rb.Name
	})

	for k := int64(0); k < rest; k++ {
		rollen[reihenfolge[int(k)%len(reihenfolge)]].Zugeteilt++
	}
}

// nennerZeile sagt, WORUEBER gerechnet wird: der Haupt-Kontext traegt dauerhaft keine
// Zaehler, jede Bilanz ist eine ueber Subagenten-Laeufe (ADR-0012).
const nennerZeile = "Token-Bilanz je Rolle — gerechnet ueber Subagenten-Laeufe, nicht ueber den Lauf.\n"

// summenZeile sagt, WAS summiert wird. `total_tokens` ist eine andere Groesse — dort
// laufen die Cache-Lesungen mit, ein eigener Gegenstand mit eigenen Regeln (Modul 15
// §Cache-Counter-Regeln).
const summenZeile = "Summiert: input_tokens + output_tokens (ohne Cache-Lesungen).\n"

// abdeckungsZeile nennt, wie viel des Bestands ueberhaupt Zaehler trug — MIT seiner
// Bezugsmenge und mit der Zahl der gelesenen Zeilen. Ein nackter Prozentsatz sagt nicht,
// worueber er rechnet.
func abdeckungsZeile(b Bilanz) string {
	return fmt.Sprintf("Abdeckung: %d von %d Agent-Laeufen trugen Verbrauchs-Zaehler; gelesen wurden %d Zeile(n).\n",
		b.MitZaehlern, b.AgentLaeufe, b.Zeilen)
}

// kopf liefert die drei Kopfzeilen — DIE ABDECKUNG ZUERST (LH-FA-10 §Leser: "Die
// Auswertung nennt ihre Abdeckung zuerst und meldet damit ihre eigene Leere").
// Die Reihenfolge ist der Vertrag, nicht Geschmack: wer die erste Zeile liest, weiss,
// worueber die folgenden sprechen. Eine Abdeckung am Ende erreicht den nicht, der nach
// der ersten Zahl aufhoert zu lesen.
// Bewacht von TestSchreibe_AbdeckungStehtZuerst.
func kopf(b Bilanz) string { return abdeckungsZeile(b) + nennerZeile + summenZeile }

// keineBilanz ist die Feststellung ueber einen Bestand ohne Verbrauchs-Zaehler.
const keineBilanz = "Keine Bilanz: der Bestand traegt keine Verbrauchs-Zaehler.\n"

// grundDerZaehler ist die GRENZE hinter dieser Leere (ADR-0021 Folgepflicht 6, ADR-0022
// Festlegung 8). Der Zustand allein liesse offen, ob er morgen anders ist; dieser Satz
// sagt, dass kein Lauf ihn aendert — er beschreibt einen FREMDEN Vertrag, nicht diesen
// Aufbau.
const grundDerZaehler = "Die Verbrauchs-Zaehler kommen aus der Mechanik des Agenten-Werkzeugs nicht: sie erreichen\n" +
	"eine Zeile nur, wenn das Werkzeug sie im Ergebnis eines Subagenten-Aufrufs mitliefert. Kein\n" +
	"Lauf dieses Repos fuehrt sie herbei — das ist keine Eigenschaft dieses Aufbaus, sondern der\n" +
	"Mechanik. Ein Bestand ohne Zaehler ist deshalb der Normalfall und kein Defekt.\n"

// leereDerZaehler meldet die Leere SAMT ihrem Grund. Die zwei Stuecke stehen getrennt,
// weil sie zwei Aussagen sind: die eine ueber diesen Bestand, die andere ueber die
// Mechanik.
//
// DER GRUND-SATZ HAT KEINEN GO-WAECHTER, und das ist eine Wahl: die Zusage ist, dass ein
// ADOPTER ihn in seinem Repo liest. Gemessen wird sie deshalb dort, wo dieser Weg endet —
// harness/tools/full-smoke.sh laesst den Leser im gebootstrappten Ziel ueber dessen
// eigenem Bestand laufen. Rot-Gegenbeispiel: test/mutations/176-leser-grund-satz-weg.sh.
func leereDerZaehler() string { return keineBilanz + grundDerZaehler }

// leereDesBestands meldet einen Bestand OHNE JEDE ZEILE — und sagt ausdruecklich, dass
// das keine Aussage ueber die Verbrauchs-Zaehler ist.
//
// DIE UNTERSCHEIDUNG IST DER PUNKT: ohne Zeile gibt es nichts, was Zaehler tragen
// koennte. Wer beide Leeren gleich meldete, gaebe der Mechanik des Agenten-Werkzeugs die
// Schuld an einer Leere, die von einem Traeger kommt, der nicht liegt — im zweiten Fall
// waere die Meldung schlicht falsch.
// Bewacht von TestSchreibe_LeererBestandNenntSeineLeere.
const leereDesBestands = "Kein Bestand: gelesen wurde keine Zeile.\n" +
	"Das ist KEINE Aussage ueber die Verbrauchs-Zaehler, sondern ueber die Erfassung: sie laeuft\n" +
	"ueber ein Programm im gitignorierten Zustands-Bereich — ein frischer Klon hat es nicht, und\n" +
	"ein Aufraeum-Lauf nimmt es weg. Liegt es, entsteht die erste Zeile beim naechsten\n" +
	"Werkzeug-Aufruf.\n"

// Schreibe gibt die Bilanz als Text aus — die ABDECKUNG ZUERST, danach die Lage.
//
// DREI LAGEN, DREI AUSGABEN, und die Unterscheidung ist selbst die Aussage:
//   - kein Bestand         -> es wurde nichts erfasst; ueber die Zaehler sagt das nichts,
//   - Bestand ohne Zaehler -> KEINE Bilanz, und der Grund steht dabei,
//   - Bestand mit Zaehlern -> die Bilanz.
//
// Drei Angaben tragen die Ausgabe unabhaengig von den Rollen-Zeilen, und jede sagt
// etwas anderes (ADR-0012: "Drei Groessen, drei Angaben"): die ABDECKUNG (wie viel des
// Bestands Zaehler trug) und der NENNER (worueber gerechnet wird) stehen im Kopf, der
// SAMMELPOSTEN-ANTEIL (worauf die Rechnung ruht) bei der Bilanz.
// Bewacht von TestSchreibe_NennerStehtDrin, TestSchreibe_SammelpostenAnteilStehtDrin
// und TestSchreibe_AbdeckungStehtDrin.
func Schreibe(b Bilanz) string {
	var sb strings.Builder

	sb.WriteString(kopf(b))

	if b.Sitzungen > 0 {
		fmt.Fprintf(&sb, "Bestand: %d Sitzung(en), %s bis %s\n", b.Sitzungen, b.Von, b.Bis)
	}
	sb.WriteString("\n")

	// Ohne Zaehler wird KEINE Bilanz ausgewiesen — keine Rollen-Zeile, keine groesste
	// Rolle, kein Sammelposten. Eine Zeile mit einer Null ueber leerem Grund ist eine
	// Rechnung, die nicht stattgefunden hat (LH-FA-10 §Leser).
	// Bewacht von TestSchreibe_OhneZaehlerKeineBilanz.
	switch {
	case b.Zeilen == 0:
		sb.WriteString(leereDesBestands)
		return sb.String()
	case !b.TraegtZaehler():
		sb.WriteString(leereDerZaehler())
		return sb.String()
	}

	if len(b.Rollen) == 0 || b.Gesamt == 0 {
		sb.WriteString("Keine Rolle traegt Token.\n")
	}
	for _, r := range b.Rollen {
		fmt.Fprintf(&sb, "  %-12s %12d  %5.1f %%\n", r.Name, r.Summe(), anteil(r.Summe(), b.Gesamt))
	}

	if len(b.Rollen) > 0 && b.Gesamt > 0 {
		groesste := b.Rollen[0]
		fmt.Fprintf(&sb, "\nGroesste Rolle: %s mit %d Token (%.1f %% der Summe)\n",
			groesste.Name, groesste.Summe(), anteil(groesste.Summe(), b.Gesamt))
	}

	// Drei Faelle: kein Sammelposten · verteilt, dann traegt er einen Anteil an der
	// Summe · unverteilt, dann liegt er ausserhalb der Summe und bekommt keinen
	// Prozentsatz.
	// Bewacht von TestSchreibe_UnverteilterSammelpostenStehtAusserhalb.
	switch {
	case b.Sammelposten == 0:
		sb.WriteString("Sammelposten: keiner — jeder zaehler-tragende Lauf trug eine Rolle.\n")
	case b.Verteilt:
		fmt.Fprintf(&sb, "Sammelposten: %d Token anteilig nach Tool-Calls verteilt (%.2f %% der Summe)\n",
			b.Sammelposten, b.SammelpostenAnteil())
	default:
		fmt.Fprintf(&sb, "Sammelposten: %d Token NICHT verteilt — keine Rolle traegt Tool-Calls. "+
			"Sie stehen in keiner Zeile oben und sind in der Summe NICHT enthalten.\n", b.Sammelposten)
	}

	return sb.String()
}

func anteil(teil, gesamt int64) float64 {
	if gesamt == 0 {
		return 0
	}
	return float64(teil) / float64(gesamt) * 100
}
