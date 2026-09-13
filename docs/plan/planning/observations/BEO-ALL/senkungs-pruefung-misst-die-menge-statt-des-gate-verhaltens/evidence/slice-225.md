**Vorgang:** slice-225
**Fund:** Der Wechsel von `targets.authority` auf
[`harness/README.md`](../../../../../../../harness/README.md) wurde zweimal gegen §3.5 geprüft —
einmal beim Schnitt des Plans, einmal im umsetzenden Lauf — und beide Male mit derselben
Mengen-Differenz für unbedenklich gehalten:

```sh
comm -23 <(git show 99bfd1c5^:AGENTS.md | grep -oE '^\| `make [a-z0-9-]+`' | sed 's/^| `make //;s/`$//' | sort -u) \
         <(grep -oE '`make [a-z0-9-]+`' harness/README.md | sed 's/`make //;s/`$//' | sort -u)
# leer
```

Die Messung ist richtig und sagt, was sie sagt: **kein** Target verliert seine dokumentierte
Zeile. Der Plan zog daraus die Folgerung *„die Prüfung wird damit strenger, nicht schwächer — kein
§3.5-Fall"*, und die Folgerung spricht über etwas anderes als die Messung — über das
Annahme-Verhalten des Moduls.

Gefunden hat es der Review, und zwar mit einer **Sonde** statt mit einer Zahl: dasselbe
konstruierte Rezept (Nicht-Gate, nur Werkzeuge-Tabellenzeile, kein `exempt-targets`-Eintrag) über
beiden Ständen, über dem alten zurückgewiesen und über dem neuen durchgelassen. Eine zweite
Mengen-Messung hätte denselben leeren Rest geliefert; die Richtung, in der gesenkt wurde, kommt in
keiner der beiden Namenslisten vor.

Der Einzelfall ist entschieden und kompensiert
([`ADR-0045`](../../../../../adr/0045-authority-wechsel-senkt-eine-richtung.md), `Accepted`) — die
Klasse ist damit nicht geschlossen: Entschieden ist **diese** Senkung, nicht die Frage, woran ein
künftiger Lauf merkt, dass seine Messung über Mengen spricht und seine Folgerung über Verhalten.
