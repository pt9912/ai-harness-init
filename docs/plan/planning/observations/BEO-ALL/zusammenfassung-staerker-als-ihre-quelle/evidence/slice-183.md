**Vorgang:** slice-183
**Fund:** Der Slice-Plan legte die ausführende Rolle auf eine Prämisse über eine fremde,
eingefrorene Quelle fest, die diese Quelle nicht trägt: *„[`ADR-0033`](../../../../../adr/0033-wellen-archivierung-als-unterkommando.md) hat zwei
Re-Evaluierungs-Trigger, und einer davon ist gefeuert"*. Gemessen:

```sh
awk '/^## Re-Evaluierungs-Trigger/{f=1;next} /^## /{f=0} f' \
  docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md | grep -c '^- \*\*Wenn'   # 5
```

Fünf Trigger, keiner gefeuert. Die Prämisse stand an **drei** Stellen des Plans — Bezug-Kopf, §1
und **DoD 2** — und machte damit ein Abnahmekriterium gegen den angenommenen ADR-Text wörtlich
unerfüllbar; gezogen hat sie die Plan-Korrektur `06d64897` nach dem Konflikt-Pfad-Verdikt *„ADR
gilt, Slice-Plan hat falsch behauptet"*
(Baseline-Regelwerk `v6.5.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz).

Dieselbe Fehlerrichtung ein zweites Mal, in derselben Runde-2 gefunden: Die Contra-Zelle der
Option E in
[`ADR-0041`](../../../../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
behauptete eine Kosten-**Obermenge** über B (*„dieselbe Betriebsart-Arbeit wie B und darüber
hinaus"*), während ihre eigene Folgepflicht 1 im selben Dokument vier aufzuhebende Ausgänge nennt,
von denen E genau einen berührt. Ein Vorgang zählt einmal
(Baseline-Regelwerk `v6.5.0`, `modul-06-roadmap.md` §Das Beobachtungs-Register) — beide Funde
stehen in diesem einen Beleg.

Die **Form**-Hälfte des ersten Funds — die Berufung auf die Baseline ohne Tag, Datei, Abschnitt und
verbatim Zitat — zählt die Nachbarklasse
[`baseline-aussage-ohne-mess-tag`](../../baseline-aussage-ohne-mess-tag/observation.md) und nicht
dieser Eintrag.
