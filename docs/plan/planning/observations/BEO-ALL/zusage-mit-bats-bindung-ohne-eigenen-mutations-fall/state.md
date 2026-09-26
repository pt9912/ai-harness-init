**Stand:** verkörpert für die Klasse (Zielort [`AGENTS.md`](../../../../../../AGENTS.md) §3.6), geplant für die
Instanz `sync`. Schwelle erreicht
(`ls docs/plan/planning/observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/evidence/*.md | wc -l`
→ 4, gelesen 2026-09-26, keine Erwartung).

**Zwei Aussagen, zwei Träger.** Die **Instanz** `sync` ist `geplant`: Kennung
[`slice-sync-waechter-tragen-mutations-faelle`](../../../open/slice-sync-waechter-tragen-mutations-faelle.md)
(`open/`: Mutations-Fälle für die `sync`-eigenen Wächter und der Absatz *Grenze* in Schritt 7); der Slice legt die
Fälle an, die die `sync`-Zusagen unter `make mutate` stellen, und ist eine zulässige Instanz-Reparatur, kein Zwang
aus der Klasse. Die **Klasse** — jede
Zusage mit `bats`-Bindung und ohne Fall — ist verkörpert in [`AGENTS.md`](../../../../../../AGENTS.md) §3.6:
*„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*, und `make mutate` *„prüft die Haltbarkeit vorhandener
Zähne, nicht die Entstehung neuer"*. Zielort ist der Abschnitt; **kein** Herkunfts-Anker: §3.6 trägt an dieser Stelle
kein `seit slice-<Kennung>`
(`sed -n '/^### 3\.6/,/^### 3\.7/p' AGENTS.md | grep -c 'seit slice-'` → 0), und ein Anker daneben wäre erfunden;
der Zielort trägt seine eigene Kennung. Eine neue Regel *„jede Zusage bekommt einen Fall"* gibt es nicht: §3.6
verlangt das einmal rot gesehene Gegenbeispiel je Zusage, das ein `bats`-gebundenes erfüllt, und ein Fall je Zusage
wüchse mit dem Bestand in der Laufzeit des Sensors. Ob eine Zusage einen Fall **verdient**, ist eine Abwägung je
Zusage (Kritikalität, Kosten) und Urteil des Planners.

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: `make mutate` urteilt über seinen **eigenen**
Fall-Satz, und eine Zusage ohne Fall ist für ihn keiner. Träger ist das Review, das die Zusagen-Liste eines
gelisteten Wächters gegen dessen Fall-Satz hält; ein Befund *„Zusage ohne Fall"* ist INFO mit dem Hinweis auf die
Abwägung. Die Zähne des Teillauf-Filters (leer · doppelt · Filter wählt alle · Pfad-Zweig) stehen bewusst ohne Fall
und sind in diesem Sinn benannt unbewacht, kein Befund.
