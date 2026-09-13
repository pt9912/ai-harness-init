# Aktivierung entscheidet die als offen übergebene Frage

**Sub-Area:** `*` (gesamtes Repo)

Ein Vorgang erklärt eine Norm-Frage ausdrücklich für **nicht von ihm entschieden** und übergibt sie
an die zuständige Rolle — und sein eigener Liefergegenstand beantwortet sie im selben Commit
**faktisch**: Nach der Verdrahtung ist genau einer der offenen Antwortpfade noch gangbar, weil der
andere ab sofort ein Gate rot färbt. Die Rollen-Grenze ist der Form nach gewahrt (niemand schreibt
ein fremdes Artefakt) und der Sache nach überschritten; die empfangende Rolle entscheidet über einen
Zustand, den es schon nicht mehr gibt.

Die Fehlerrichtung ist *die Frage ist offen* statt *sie ist bereits beantwortet*. Zwei
Nachbarklassen decken den Fall nicht:
[`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
— dort fehlt das Trägerartefakt, hier existiert es und trägt die falsche Tatsachengrundlage;
[`fremdes-rollen-artefakt-im-implementations-kontext`](../fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
— dort wird ein fremdes Artefakt **geschrieben**, hier keines angefasst und seine Entscheidung
trotzdem vorweggenommen.

## Benannt, nicht gezählt

Die Frage, ob eine Gate-Aktivierung ihre Norm-Entscheidung abwarten muss, ist bewusst **nicht**
beantwortet worden: Eine Regel aus einem Einzelfall wäre eine Norm ohne Schwelle
([ADR-0046](../../../../../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
§Was diese Entscheidung nicht tut). Der Zähler ist die Route.
