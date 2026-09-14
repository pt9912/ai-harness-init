**Vorgang:** Review-Reports `docs/reviews/2026-09-14-adr-0048-konsistenzrunde.md` (MEDIUM-3, LOW-1)
und `docs/reviews/2026-09-14-adr-0048-konsistenzrunde-2.md` (MEDIUM-3, LOW-6) — der Vorgang ist das
Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden. Vier Funde, **eine** Gelegenheit.
**Fund:** Viermal gibt die Datei eine fremde Aussage stärker wieder, als die Quelle sie trägt.
Die Genealogie sprach
[ADR-0028](../../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und
[ADR-0024](../../../../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) je
eine Eigenschaft zu, die jene Entscheidungen so nicht setzen, und der eigenen dritten Achse die
Neuheit ab. Der Satz *„die sechs Closure-Schritte sind Planner-Arbeit"* komprimierte eine
Schritt-Tabelle, die vier Zeilen tiefer vom eigenen Kommando ausgegeben wird und für Schritt 1 den
Verifier führt. Und eine Zähler-Zahl berief sich auf
[`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
für eine Klasse, die jener Eintrag nach eigener Kopf-Marke ausdrücklich nicht erreicht.

**Die Fehlerrichtung ist stabil** — *die Quelle sagt mehr zu, als sie sagt* —, und der Ort macht
sie teuer: Drei der vier Stellen liegen in Abschnitten, die mit der Annahme einfrieren. Alle vier
sind vor dem Umschlag behoben.
