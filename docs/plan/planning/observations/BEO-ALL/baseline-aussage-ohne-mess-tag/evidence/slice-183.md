**Vorgang:** slice-183
**Fund:** Der Erstentwurf von
[`ADR-0041`](../../../../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) stützte
seine tragende Aussage — *kein `Supersedes` auf [ADR-0033](../../../../../adr/0033-wellen-archivierung-als-unterkommando.md)* — auf den Satz *„die Baseline benennt den
Träger für den wellenlosen Fall selbst"*: eine Regelwerks-Aussage ohne Tag, ohne Datei, ohne
Abschnitt und ohne verbatim Zitat. Die Review-Runde 1 meldete fünf Fundorte
(`docs/reviews/2026-09-12-adr-0041-wellenloser-altbestand.md`, HIGH-1); das Kommando des Reports
zählt am Erstentwurf mehr:

```sh
git show 5969a86b:docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md \
  | grep -nE 'Ziel-Fassung|die Baseline' | grep -vc 'v6\.5\.0'   # 8
```

Die Datei friert nach [`AGENTS.md`](../../../../../../../AGENTS.md) §3.4 ab `Accepted` ein — ohne Tag
wäre danach weder nachvollziehbar noch als überholt erkennbar, gegen welchen vendored Stand die
Trigger-Frage entschieden wurde. Aufgelöst in `379def11`, das die Fundmenge maß statt die fünf
gemeldeten Zeilen zu ziehen.

**Nicht hier gezählt:** dass die genannte Quelle die Aussage auch inhaltlich nicht trägt, ist die
Nachbarklasse
[`zusammenfassung-staerker-als-ihre-quelle`](../../zusammenfassung-staerker-als-ihre-quelle/observation.md)
und hat im selben Vorgang ihren eigenen Beleg. Hier steht die **Form** der Berufung, dort ihre
**Substanz**.
