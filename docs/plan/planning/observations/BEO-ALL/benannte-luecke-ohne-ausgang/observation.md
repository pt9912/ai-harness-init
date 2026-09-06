# Benannte Lücke ohne Ausgang

**Sub-Area:** `*` (gesamtes Repo)

Eine benannte Lücke — was ein Sensor **nicht** deckt, wo eine Zusage endet, was eine Messung nicht
trägt — muss dastehen, damit die Zusage daneben nicht mehr behauptet, als sie hält
([`AGENTS.md`](../../../../../../AGENTS.md) §3.1 und §3.6). **Wohin sie wieder verschwindet, sagt
keine Quelle:** Es gibt keinen Zustand *ausgetragen*, keinen Ort, an den eine erledigte
Grenz-Beschreibung wandert, und kein Kriterium, das die noch tragende von der erledigten trennt.
Sie bleibt darum liegen, wo sie entstand — im meistgelesenen Dokument —, und Austragen sähe aus
wie Verstecken.

## Benannt, nicht gezählt

Aufgefallen in einer Koordinations-Sitzung, nicht in einem abgeschlossenen Vorgang. Gemessen an
[`harness/README.md`](../../../../../../harness/README.md), das alle drei Anweisungssätze unter
[`.claude/commands/`](../../../../../../.claude/commands/) in ihrem ersten Schritt lesen lassen —
die Kosten fallen damit **je Lauf** an, nicht einmalig:

```sh
grep -rln 'harness/README.md' .claude/commands/*.md | wc -l   # 3
ls .claude/commands/*.md | wc -l                              # 3
```

Der Umfang ist am eingefrorenen Stand `c43a759` erhoben; die Adressen sind Tree-Operanden, die
Zahlen darum **fest** und keine Erwartungswerte über den lebenden Baum:

```sh
R=c43a759
git show $R:harness/README.md | wc -c                                        # 39427 B  gesamte Datei
git show $R:harness/README.md | awk 'NR>=39 && NR<=93' | wc -c               # 36269 B  §Sensors (92 % der Datei)
git show $R:harness/README.md | awk 'NR>=39 && NR<=55' | wc -c               #  1979 B  die Gate-Tabelle selbst (5 % der Sektion)
git show $R:harness/README.md | awk 'NR>=81 && NR<=93' | wc -c               # 16210 B  allein `archive-welle` (41 % der Datei)
git show $R:harness/README.md \
  | awk 'NR==73||NR==75||NR==77||NR==79||(NR>=81&&NR<=93)' | wc -c           # 29545 B  Ziele, die sich selbst als Nicht-Gate führen (81 % der Sektion)
```

Die Zeilenwahl der letzten Zahl ist zur Hälfte ein Kriterium und zur Hälfte Hand: die fünf
Absätze, die sich selbst so bezeichnen, liefert
`git show $R:harness/README.md | awk 'NR>=56 && NR<=93 && /kein Gate|Nicht-Gate|in keiner der Tabellen/ {print NR}'`
(→ `73 75 77 79 81 89`); dazu genommen sind die Folge-Absätze des `archive-welle`-Blocks
(83–93), die dieselbe Beschreibung fortsetzen.

Der größte Block beschreibt dabei etwas, das hier nie gelaufen ist: `archive-welle` trägt 41 % der
Datei, und ihre Zeile 85 sagt selbst *„Auf eine Welle dieses Repos ist das Werkzeug noch nicht
anwendbar"* —
`git show $R:harness/README.md | awk 'NR==85' | grep -c 'noch nicht anwendbar'` → **1**.

Zwei Nachbarklassen sind enger und decken den Fall nicht.
[`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md)
misst die **Form** derselben Datei gegen die Pflichtgliederung — plausibel die Ursache, aber eine
eigene Frage: Wer die fehlende Sektion nachträgt und `## Sensors` auf seine Tabelle zurückführt,
hat damit noch keinen Weg, auf dem eine erledigte Grenz-Beschreibung wieder verschwindet.
[`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
misst Umfang an **Zeitdokumenten**, die niemand fortschreibt; hier trifft es ein lebendes Artefakt
im Pflicht-Lesepfad, und genau das macht den fehlenden Ausgang teuer.
