**Vorgang:** slice-225
**Fund:** Die Vorab-Messung nach [`AGENTS.md`](../../../../../../../AGENTS.md) §3.11 vor dem
Closure-Move fand **eine** Fundstelle, in der die zu ersetzende Adresse eine **Mess-Aussage über
die Vergangenheit** trägt — und sie liegt in einer Beleg-Datei dieses Registers, also in einem ab
Merge unveränderlichen Artefakt:

```sh
git grep -nE '^(#|\s*#|`).*in-progress/slice-225-gate-index-steht-einmal\.md' -- \
  'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/planning/observations/**/evidence/*.md'
```

Die Zeile ist die zitierte **Ausgabe** eines `git grep -c` und steht unter einem Pathspec, der
`done/` ausdrücklich ausnimmt. Nach der Ersetzung behauptet sie einen Treffer unter `done/`, den
dasselbe Kommando nie liefern kann — der Nachzug macht aus einer richtigen Ausgabe eine, die sich
selbst widerspricht, und zwar **still**: Der Pfad bleibt auflösbar, und `make docs-check` meldet
über beiden Ständen dasselbe.

Die zweite Fundstelle derselben Messung —
`docs/reviews/2026-09-12-slice-224-delta-nachweis-und-planungs-nachzug.md`, ein Code-Span, der den
Plan als Adresse nennt — trägt keine Zeitaussage und übersteht die Ersetzung Wort für Wort. Der
Unterschied zwischen beiden ist genau das Kriterium aus
[`ADR-0042`](../../../../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1:
Der Nachzug darf die **Adresse** ersetzen und nicht die **Aussage**. Jene Entscheidung lässt den
Fall nach Festlegung 4 ausdrücklich unrepariert und weist den Träger dem **Schreiber** der
Mess-Aussage zu — der schrieb sie vor einem Move, den es damals noch nicht gab.
