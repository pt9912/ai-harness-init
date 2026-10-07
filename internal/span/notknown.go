package span

import "encoding/json"

// notKnownPrefix ist die Draht-Form der Kennzeichnung *nicht bekannt*: ein Pflicht-Zaehler,
// dessen Wert die Quelle nicht liefert, traegt die Zeichenkette `nicht bekannt: <Quelle>`
// — nie `0` und nie Abwesenheit (SPEC-087 in spec/spezifikation.md §5). `<Quelle>` ist
// der Payload-Schluessel, der den Wert nicht liefert.
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
