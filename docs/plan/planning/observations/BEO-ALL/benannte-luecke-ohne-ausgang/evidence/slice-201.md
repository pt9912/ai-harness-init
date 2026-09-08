**Vorgang:** slice-201
**Fund:** Der gewählte Ausgang *benannte Grenze* legt knapp sieben Kilobyte Grenz-Beschreibung in
genau die Datei, die diese Beobachtung misst — und die Beschreibung hat keinen Weg zurück:
[`harness/README.md`](../../../../../../../harness/README.md) wächst über den Vorgang von 44661
auf 51525 Byte. Beide Zahlen sind an Tree-Operanden gebunden und darum fest, keine
Erwartungswerte:

```sh
git show f5189bba^:harness/README.md | wc -c   # 44661
git show 602eb7c0:harness/README.md  | wc -c   # 51525
```

Ein Ausgang für die Beschreibung entsteht erst, wenn die Grenze selbst geschlossen ist; die
Adresse dafür ist
[slice-202](../../../../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md).
Bis dahin steht die Grenze zu Recht und kostet je Lauf, weil alle drei Anweisungssätze die Datei
in ihrem ersten Schritt lesen.
