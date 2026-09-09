**Vorgang:** slice-129
**Fund:** Die Message des Behebungs-Laufs führt `slice-129`, `AGENTS.md §3.10`, Setzung 1 von
[`MR-033`](../../../../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
und den Pfad des Runde-2-Reports, aber keine Kennung aus einem der zwei verlangten Muster:

```sh
git log -1 --format=%B <commit> | grep -oE 'LH-[A-Z]+-[0-9]+|ADR-[0-9]{4}'   # leer
```

Die vier übrigen Commits derselben Slice-Kette tragen je mindestens eine — die Form war dem Lauf
verfügbar und ist in dieser Kette der Normalfall. Unter der Lesart *die Änderung als ganze* ist die
Regel über die Kette erfüllt; unter der Lesart *jeder Commit* nicht, und welche gilt, sagt keine
Quelle.
