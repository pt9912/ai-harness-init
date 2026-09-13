**Vorgang:** slice-migration-hat-ein-instanz-register
**Fund:** Ein vorbereitendes Nachschlage-Dokument — kein Gate-Vertrag, keine ADR, kein
Hard-Rule-Text, keine emittierte Vorlage — bekam **vier** Review-Runden und **sechs**
Implementer-Commits:

```sh
ls docs/reviews/*slice-migration-hat-ein-instanz-register*.md | grep -vc verify   # 4
git log --format='%s' f0d58786^..369e6e99 | grep -cE '^Rolle Implement'           # 6
find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l             # 25
```

**Keine Erwartungswerte**
([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2; die Commit-Range ist ein fester Operand). Gegenstand war ein Register über **25**
Vorlagen, von denen **4** als offene Frage enden.

Die Funde blieben in jeder Runde echt und wurden kleinteiliger — Runde 1 meldete 1 HIGH / 6
MEDIUM, die Runden 2–4 je 0 HIGH und 5 / 3 / 5 MEDIUM. Die **Richtung** kippte dabei: Runde 4
befundete unter N-14/N-15/N-18, dass die Nacharbeiten der Runden 2 und 3 für mehrere Zeilen eine
**Zuordnung** erzwungen hatten, für die die Auflage des Slice-Plans die **offene Frage** vorsah —
N-18 nennt es *„Geweitetes Kriterium deckt eine ausdrücklich offen gehaltene Zeile mit"*. Ein
Kriterium, das eine Runde für hinreichend erklärt, besteht nicht: `0 HIGH` beendet sie nicht, weil
kein Artefakt dieses Repos es so setzt.
