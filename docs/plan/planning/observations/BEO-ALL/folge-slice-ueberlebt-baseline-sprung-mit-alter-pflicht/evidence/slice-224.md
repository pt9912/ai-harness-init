**Vorgang:** slice-224
**Fund:** Ein Folge-Slice, der **für** diesen Sprung geschnitten wurde, trug schon beim Schnitt
eine Prämisse, die der Sprung selbst widerlegt. Sein §1 schließt *„kein neuer `MR`-Eintrag"* aus,
begründet mit *„es gibt keine gewollte Abweichung"* — und die Ziel-Fassung verlangt an derselben
Stelle einen Eintrag, der keine Abweichung bucht, sondern eine **Deklaration**:

```sh
grep -n 'Welche Form gilt, deklariert das Repo' \
  .harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md   # 370
grep -c 'dichte Nummern' .harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md   # 0
```

**Keine Erwartungswerte** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Der Absatz, der bis `v6.0.0` dichte Nummern für Ein-Schreiber-Repos lizenzierte, ist
fort; die Kennungs-Form ist damit nicht mehr voreingestellt, sondern deklarationspflichtig.

Der fünfte Beleg verschiebt, wo die Klasse sitzt: Es genügt nicht, den Bestand offener Pläne gegen
den neuen Stand zu halten — auch ein Plan, der **im selben Zug** wie der Sprung entsteht, kann
eine Pflicht ausschließen, die der Sprung erst erzeugt. Die Prämisse eines Ausschlusses altert
so schnell wie der Stand, gegen den sie gemessen ist.
