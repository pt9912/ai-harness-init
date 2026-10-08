package span

import (
	"encoding/json"
	"strings"
)

// notKnownPrefix ist die Draht-Form der Kennzeichnung *nicht bekannt*: ein Pflichtfeld,
// dessen Wert die Quelle nicht liefert, traegt die Zeichenkette `nicht bekannt: <Quelle>`
// — nie `0`, nie `""`, nie `[]` und nie Abwesenheit (SPEC-087 in spec/spezifikation.md
// §5). `<Quelle>` ist der Payload-Schluessel oder die Datei, die den Wert nicht liefert.
const notKnownPrefix = "nicht bekannt: "

// SourceUsage liefert die zwei Cache-Zaehler (SPEC-024): das `usage`-Objekt der
// `tool_response` eines `Agent`-Aufrufs. Jeder Span ohne dieses Objekt traegt die
// Kennzeichnung.
const SourceUsage = "tool_response.usage"

// NotKnown bildet die Kennzeichnung fuer eine Quelle.
func NotKnown(source string) string { return notKnownPrefix + source }

// CacheCount ist ein Cache-Zaehler (SPEC-024): Pflicht, also in jeder Zeile. Mit Wert
// steht er als Zahl, ohne Wert als Kennzeichnung mit der Quelle SourceUsage. Die
// Kennzeichnung ist eine Zeichenkette und keine Zahl — ein Leser, der summiert, stoesst
// auf einen Typfehler statt auf eine `0`.
// Bewacht von TestCacheStatusIsMarkedNotKnown.
type CacheCount struct {
	N *int64
}

// MarshalJSON schreibt die Zahl oder die Kennzeichnung.
func (c CacheCount) MarshalJSON() ([]byte, error) {
	if c.N != nil {
		return json.Marshal(*c.N)
	}
	return json.Marshal(NotKnown(SourceUsage))
}

// UnmarshalJSON liest eine Zahl als Wert; die Kennzeichnung, `null` und jeder andere
// Wert lesen sich als *ohne Wert*. Eine Zeile mit unlesbarem Zaehler bleibt damit lesbar
// — der Zaehler kostet das Feld, nicht die Zeile.
func (c *CacheCount) UnmarshalJSON(b []byte) error {
	c.N = count(b)
	return nil
}

// SourceAgentType liefert die Rolle (SPEC-010): der Agenten-Typ der Payload. Nennt er
// keine der sechs Rollen — `general-purpose`, ein fremder Typ, der Haupt-Kontext ohne
// Typ —, traegt `agent_role` die Kennzeichnung mit dieser Quelle.
const SourceAgentType = "agent_type"

// SourceGitHead liefert Zweig und Stand (SPEC-014): `.git/HEAD` samt der Referenz, auf
// die er zeigt. Ist eines der zwei Felder daraus nicht ableitbar, traegt es die
// Kennzeichnung mit dieser Quelle.
const SourceGitHead = ".git/HEAD"

// IsNotKnown sagt, ob ein Wert die Kennzeichnung *nicht bekannt* traegt. Die Auswertung
// liest einen solchen Wert wie den leeren Wert des Bestands davor (SPEC-044).
func IsNotKnown(v string) bool { return strings.HasPrefix(v, notKnownPrefix) }

// IDList ist eine Korrelations-Liste (SPEC-011 bis SPEC-013). Mit leerer Quelle steht sie
// als Liste — `[]` heisst *keiner* —, mit Quelle als Kennzeichnung `nicht bekannt:
// <Quelle>` an derselben Stelle: die Liste ist dann unbekannt, nicht leer.
// Bewacht von TestCorrelationUnreadableSliceIsMarkedNotKnown.
type IDList struct {
	IDs     []string
	Unknown string
}

// MarshalJSON schreibt die Liste oder die Kennzeichnung; eine Liste ohne Eintrag steht als
// `[]`, nie als `null`.
func (l IDList) MarshalJSON() ([]byte, error) {
	if l.Unknown != "" {
		return json.Marshal(NotKnown(l.Unknown))
	}
	if l.IDs == nil {
		return []byte("[]"), nil
	}
	return json.Marshal(l.IDs)
}

// UnmarshalJSON liest eine Liste als Liste und eine Zeichenkette als Kennzeichnung; jeder
// andere Wert macht die Zeile unlesbar wie jedes falsch getypte Feld.
func (l *IDList) UnmarshalJSON(b []byte) error {
	var s string
	if json.Unmarshal(b, &s) == nil {
		*l = IDList{Unknown: strings.TrimPrefix(s, notKnownPrefix)}
		return nil
	}
	var ids []string
	if err := json.Unmarshal(b, &ids); err != nil {
		return err
	}
	*l = IDList{IDs: ids}
	return nil
}
