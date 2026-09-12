**Vorgang:** slice-223
**Fund:** Sechs Mess-Zitate in zwei Adaptions-Einträgen nennen den Stand, gegen den sie gemessen
sind — und ihr Kommando gibt seit dem Baum-Tausch nicht mehr aus, was neben ihm steht. Der Tag ist
also nicht das Problem, die Kopplung ist es:

```sh
grep -rn 'Adopter' .harness/baseline/v6.5.0/regelwerk/ | wc -l                                   # 0, EXIT 0
git grep -c 'Adopter' e488119c^ -- '.harness/baseline/v6.5.0/regelwerk/' \
  | awk -F: '{s+=$NF} END{print s}'                                                              # 7
```

[`MR-054`](../../../../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) führt **7** neben dem ersten Kommando, und das Fork-Verdikt des Eintrags ruht auf dieser
Zahl; [`MR-055`](../../../../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) zitiert dieselbe Messung und sagt daneben *„leer (Exit 1)"*, während die Zeile heute
mit EXIT 2 endet. In der Sache sind beide Aussagen unverändert richtig und über den Tree-Operand
vollständig wiederherstellbar — falsch ist allein die Kopplung, die
[`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt.
[`MR-040`](../../../../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
hält für genau diesen Fall den Tree-Operand als Ausgang 2 bereit und benennt seinen Träger als den
Durchgang beim Sprung; der Durchgang hat ihn nicht gefunden, und der Plan zitiert den Eintrag
nicht.

Zwei Nachbarklassen decken den Fall nicht:
[`baseline-aussage-ohne-mess-tag`](../../baseline-aussage-ohne-mess-tag/observation.md) setzt eine
Aussage **ohne** Mess-Tag voraus — hier steht er ausdrücklich da;
[`zahl-neben-nie-gefahrenem-kommando`](../../zahl-neben-nie-gefahrenem-kommando/observation.md)
setzt ein Kommando voraus, das nie lief — dieses lief und gab damals aus, was danebensteht.
