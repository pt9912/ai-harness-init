**Vorgang:** 2026-09-14-welle-13-trigger-audit

**Fund:** Das Feld *Geltungsbereich* von `CO-001` nennt **16**, seine *Letzte Prüfung* vom
2026-09-01 **20**, und derselbe Bestand liefert heute **30**:

```sh
git ls-files 'test/*.bats' | wc -l    # 30
```

**Kein Erwartungswert** — die Zahl wandert mit dem Bestand. Die drei Beträge sind nicht falsch
gewesen, sondern **gewandert**, und keiner trägt das Kommando neben sich, das ihn ausgibt. Der
Ausgang des Carveouts ist davon nicht berührt — sein Trigger fragt über den Bestand, und der ist
gewachsen; betroffen ist allein das Zahl-Feld, das seine Fundmenge nicht mehr nennt.
