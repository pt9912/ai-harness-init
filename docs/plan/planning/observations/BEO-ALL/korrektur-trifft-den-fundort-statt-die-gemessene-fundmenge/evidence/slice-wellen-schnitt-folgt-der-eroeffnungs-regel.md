**Vorgang:** slice-wellen-schnitt-folgt-der-eroeffnungs-regel
**Fund:** Der Schnitt fixierte **drei** Träger — die drei, die
[`ADR-0046`](../../../../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen
namentlich nennt —, während der Ziel-Satz des Plans über **alle** lebenden Artefakte spricht
(*„Kein lebendes Artefakt dieses Repos lehrt mehr …"*, §1). Innerhalb jedes Trägers trug das
Gegenmittel: §1 maß die Fundmenge je Datei und fand im Anweisungssatz eine vierte Stelle, die die
ADR nicht führt. Über den **Ziel-Satz** wurde nicht gemessen — vier weitere lebende Fundstellen
standen die ganze Zeit da und stehen nach der Lieferung noch:

```sh
git grep -l 'aktuell\* oder \*geplant\*' \
  -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' | wc -l   # 4
```

**Kein Erwartungswert** — die Zahl wandert mit dem Bestand. Es sind `docs/plan/planning/README.md`
und die `Lifecycle:`-Kopfnoten der drei offenen Welle-Dateien. Gefunden hat sie der Review (F-5,
als Übergabe notiert) und nicht der schneidende Lauf; Ausgang ist der Folge-Slice
`slice-flache-welle-ist-eroeffnet-nicht-geplant`, der die Fundmenge misst, **bevor** er den Schnitt
fixiert.
