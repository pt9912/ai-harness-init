**Vorgang:** 2026-09-14-welle-13-verify

**Fund:** Zwei Zahlen des Abnahmekriteriums der Welle tragen kein Kommando neben sich und treffen
ihren Gegenstand nicht mehr. §3 der Welle nennt **zwölf** `docs?-*`-Ziele und **sechs** Slices; die
Verifikation zählt am selben Baum **dreizehn** Ziele und **sieben** Träger:

```sh
grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk                       # 13
grep -lE '^\*\*Welle:\*\*.*welle-13' docs/plan/planning/done/*.md | wc -l   # 7
```

**Keine Erwartungswerte** — beide Zahlen wandern mit dem Baum. Die Fehlerrichtung ist die der
Klasse: Die Zahl hat von Anfang an unter der Fundmenge gelegen (das dreizehnte Ziel und der siebte
Träger sind später dazugekommen), und kein Satz neben ihr nennt das Kommando, das sie ausgibt.
Aufgelöst hat der Closure-Lauf der Welle sie: §3 nennt jetzt dreizehn, §4 führt den siebten Träger
(`slice-217`) mit seiner Kennung.
