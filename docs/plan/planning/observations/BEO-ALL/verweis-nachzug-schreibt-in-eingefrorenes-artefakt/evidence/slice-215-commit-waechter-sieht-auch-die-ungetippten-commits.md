**Vorgang:** slice-215-commit-waechter-sieht-auch-die-ungetippten-commits
**Fund:** Der Nachzug des Closure-Move hat in **zwei** eingefrorene Artefakte geschrieben — und die
von [`AGENTS.md`](../../../../../../../AGENTS.md) §3.11 Absatz 2 verlangte **Vorab-Messung** über
beide Adress-Formen ist dabei nicht über die zwei eingefrorenen Bäume gefahren.

```sh
git show --stat fe0f0cd6
# docs/plan/planning/done/slice-126-commit-message-traegt-eine-kennung.md          | 12 ++++++------
# docs/plan/planning/next/slice-kennungs-waechter-geht-ins-ziel.md                 |  8 ++++----
# docs/plan/planning/welle-emittierte-werkzeuge.md                                 |  2 +-
# docs/reviews/2026-09-15-slice-174-archivierung-emittieren-verify.md              |  2 +-
```

Die vierte Zeile ist der Verifikations-Report eines **fremden**, bereits geschlossenen Slice; die
erste ist die Closure-Notiz von `slice-126`, des Vorgängers desselben Gegenstands. Beide sind
Zeitdokumente; der Nachzug ist dort die von
[`ADR-0042`](../../../../../../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 2 **entschiedene** Antwort — kein Fehler des Werkzeugs und keine Panne.

**Was die Klasse hier trägt, ist die Reihenfolge, nicht der Nachzug.** Die Vorab-Messung dieses
Laufs ist über die Vorgangs-Frage gefahren (`git grep -n '<slice-kennung>' -- ':!.harness/baseline'
':!docs/reviews' ':!docs/plan/planning/done'`) und hat genau die vier **beweglichen** Fundorte
gefunden — die zwei eingefrorenen Bäume hat sie mit ihren beiden Ausschlüssen ausgeblendet, und
damit die zwei Ziele, die der Nachzug dann wirklich berührt hat. Dieselbe Abweichung steht schon
zweimal im Register (`slice-104`, `slice-124`). Dieser Beleg zählt den Vorgang für den Eintrag
**einmal** und nennt die Abweichung als seinen Fund: Der Nachzug schreibt, was er schreiben soll —
die Messung, die ihm vorausgehen sollte, fand an einer engeren Bezugsmenge statt, als die Regel
verlangt.
