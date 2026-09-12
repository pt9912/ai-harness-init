# `make span-report` — Token-Bilanz je Rolle aus dem Span-Bestand

## Vertrag

Rechnet aus dem Span-Bestand eine Token-Bilanz je Rolle. Kein Gate, keine Prerequisite-Kette: ein
Bericht prüft nichts und färbt nichts rot — ein Gate darüber wäre eines über leerem Prüfbereich
([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er liest
den Bestand read-only und netzlos.

## Grenze — was das Grün nicht abdeckt

Die Ausgabe nennt ihren Nenner, den Sammelposten-Anteil und die Abdeckungszahl samt
Bezugsmenge. Ohne Span-Bestand ist der Nenner leer, und der Bericht sagt das statt eine Bilanz
über nichts zu behaupten.

## Bindung

Kein Gate-Versprechen — Bericht.
