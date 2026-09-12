**Vorgang:** slice-223
**Fund:** Die Sprung-Inventur des Plans keilte auf den **abgehenden Tag** statt auf die
Eigenschaft, um die es geht — *eine Adresse in den vendored Baum*. Alle drei Erhebungs-Kommandos
filtern auf `v6\.5\.0`; ein Präfix-Filter auf `\.harness/baseline/v` hätte dieselbe Klasse
vollständig gesehen. Was dem Instrument entging, steht über dem Ergebnis-Stand da:

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' ':!docs/plan/adr' )
git grep -ohE '\.harness/baseline/v[0-9]+\.[0-9]+\.[0-9]+' -- "${PS[@]}" | sort | uniq -c
# 15 v3.5.2 · 39 v5.12.0 · 35 v5.18.0 · 6 v6.0.0 · 8 v6.5.0 · 150 v6.7.2
git grep -hE '\.harness/baseline/v(5\.18\.0|6\.0\.0|6\.5\.0)' -- "${PS[@]}" \
  | grep -cE 'git (show|grep|diff)'                                            # 7 von 45
```

**Keine Erwartungswerte** — beide Zahlen wandern mit dem Bestand. Lebende Artefakte tragen
Adressen in **fünf** abgelöste Bäume, und nur ein kleiner Teil der drei jüngsten steht in der
Tree-Operand-Form, die eine Adresse auf einen abgelösten Tag rechtfertigt. Die Fehlerrichtung ist
die der Klasse: Der Nachzug sieht vollständig aus, weil das Wortmuster leer ist, und die Menge, um
die es geht, ist größer als das Muster.
