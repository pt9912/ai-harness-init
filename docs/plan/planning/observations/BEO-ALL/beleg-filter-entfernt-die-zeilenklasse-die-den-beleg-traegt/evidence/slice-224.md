**Vorgang:** slice-224
**Fund:** Das Beleg-Kommando des Delta-Nachweises war für zwei Zeilenklassen blind, und fünf
Zellen der 42-Posten-Tabelle stützten sich darauf. `grep -E '^[+-][^+-]'` sollte die
Diff-Kopfzeilen wegnehmen und nimmt jede Markdown-Listenzeile mit — ihr zweites Zeichen ist wieder
`-`; der nachgeschaltete `grep -vE '^[+-]\|'` sollte umformatierte Tabellen wegnehmen und nimmt
jede Tabellenzeile mit, auch jede neue. Beides trifft genau die zwei Formen, in denen ein
Regelwerks-Modul seine Pflichten führt.

Der Ersatz misst dieselbe Frage ohne Filter — whitespace- und spaltenbreiten-normalisierter
Volltext-Vergleich beider Stände:

```sh
cd /Development/KI/ai-harness-course
for f in grundlagen-begriffe modul-08-agentenrollen modul-16-produktiver-betrieb \
         modul-02-harness-bootstrap grundlagen-referenz-richtung; do
  printf '%-32s %s\n' "$f" \
    "$(diff <(git show v6.0.0:lab/regelwerk/$f.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
            <(git show v6.7.2:lab/regelwerk/$f.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
       | grep -cE '^[<>]')"
done
# 3 · 4 · 2 · 6 · 14
```

**Keine Erwartungswerte** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wandern mit dem Klon-Stand. Die ersten drei Zellen sagten *keine
Inhaltsänderung* bzw. *ausschließlich Tabellen-Reformatierung*, wo drei neue Glossar-Zeilen, zwei
Tabellenzellen und eine Listenzeile stehen; die Nacharbeit hat sie berichtigt. Die letzten zwei
waren mit dem reparierten Verfahren **nicht** neu gefahren — dort fand es zwei weitere Fälle, und
bei `modul-02-harness-bootstrap.md` fällt der Beleg: die Zelle deckt einen von drei Hunks. Die
Antworten selbst halten in allen fünf Fällen; falsch war jedes Mal allein der Beleg.

Die Klasse sitzt nicht in der Sorgfalt, sondern im Werkzeug: Ein Filter, der Rauschen wegnimmt,
entscheidet über die Zeilenklasse, nicht über den Inhalt — und Markdown trägt seine Norm in genau
den zwei Klassen, die dieser Filter wegnimmt.
