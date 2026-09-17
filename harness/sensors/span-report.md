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

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | die Bilanz steht auf stdout, mit den Größen aus §Grenze |
| 1 | `span-report: …` auf stderr: der Ablageort ist nicht auflösbar, oder der Bestand ist nicht lesbar |

Die Tabelle nennt den Exit des Unterkommandos; über `make span-report` meldet `make` einen Exit ungleich null
als `Fehler <n>` und endet selbst mit 2.

## Sperren

- `span-report: keine Repo-Wurzel ueber … — Ablageort als Argument nennen` — der Aufruf liegt
  außerhalb eines Repos und nennt keinen Ablageort; Exit 1, bevor ein Span gelesen ist → aus dem
  Repo aufrufen (`cmd/ai-harness-init/span_report.go`).
  Über `make span-report` tritt sie nicht auf: das Rezept ruft das Unterkommando in der
  Repo-Wurzel auf.

## Bindung

Kein Gate-Versprechen — Bericht.
