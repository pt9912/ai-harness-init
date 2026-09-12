**Vorgang:** slice-223
**Fund:** Der Baum-Tausch machte die Prämisse eines wartenden Plans falsch, und der mechanische
Adress-Nachzug verdeckte es: `slice-213` mass seine Ziel-Form als Diff zwischen vendored Baum und
Kurs-Klon und sagte daneben, die neue Fassung sei nicht adoptiert. Nach dem Tausch vergleicht
dasselbe Kommando eine Datei mit sich selbst — der Plan liest sich unverändert, und sein Diff ist
leer:

```sh
diff -q .harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md \
        /Development/KI/ai-harness-course/lab/templates/docs/reviews/review-report.template.md   # leer, EXIT 0
```

Der Plan war damit nicht nur anders formuliert, sondern **anders verpflichtet**: Die
Vorgriffs-Frage, die sein §1 ausschloss, sein §6 als Risiko führte und sein §4 als Start-Trigger
verdrahtete, hat keinen Gegenstand mehr — die Form ist adoptiert. Die Prämisse ist in der Closure
dieses Slice berichtigt, die abgelöste Seite steht jetzt als Tree-Operand.
[slice-214](../../../../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) ist gemessen
unberührt: Es führt keinen Baum-gegen-Klon-Vergleich, und seine Abhängigkeit ist die **Lieferung**
von `slice-213`, nicht dessen Prämisse.

Der vierte Beleg zeigt, wo die Klasse sitzt: nicht in der Größe des Sprungs, sondern darin, dass
kein Schritt den Bestand offener Pläne gegen den neuen Stand hält. Hier fand ihn eine vorab
benannte Risiko-Zeile, nicht ein Durchgang.
