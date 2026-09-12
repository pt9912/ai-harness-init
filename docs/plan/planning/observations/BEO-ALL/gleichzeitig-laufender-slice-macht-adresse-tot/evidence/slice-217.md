**Vorgang:** slice-217
**Fund:** Der Umsetzungs-Commit schrieb eine Marke in vier Zeilen von
[`d-check.mk`](../../../../../../../d-check.mk), die auf einen Abschnitt in
[`harness/README.md`](../../../../../../../harness/README.md) zeigte — richtig in dem Commit, der
sie schrieb, denn derselbe Commit legte den Abschnitt dort an. Sechs Commits später hatte
`slice-114` den Lifecycle von `open/` bis `in-progress/` durchlaufen und
[`harness/README.md`](../../../../../../../harness/README.md) auf die Ziel-Form gebracht, die
Sensor-Prosa nach `harness/sensors/` ausgelagert; von da an zeigte die Marke — die jeder
`make doc-tracked`- und `make doc-help`-Lauf ausgibt — auf einen Abschnitt, den die genannte Datei
nicht mehr führte. Beide Slices lagen zu diesem Zeitpunkt in `in-progress/`. Gefunden hat es erst
die **zweite** Review-Runde; der Lauf, der die Marke schrieb, hatte keinen Anlass, sie noch einmal
anzusehen, und der Lauf, der den Abschnitt auflöste, keinen, in einen fremden offenen Slice zu
sehen. Die Marke zeigt seither auf die zwei Sensor-Dateien selbst.

Gemessen an der Reihenfolge der Commits und am Ziel-Zustand:

```sh
git rev-list --count 497564d7..9a57f2b3                                                        # 6
git show 0dc740e8:d-check.mk | grep -c 'siehe harness/README.md Abschnitt zu doc-tracked'      # 4
git show 0dc740e8:harness/README.md | grep -c 'fuehrt fuer dieses Modul keinen eigenen Block'  # 0 (Exit 1)
```

Die Zahlen sind an feste Commit-Operanden gebunden und darum keine Erwartungswerte über den
lebenden Baum. Kein Lauf des Doku-Gates sprach davon: `make docs-check` war über dem toten Stand
grün.
