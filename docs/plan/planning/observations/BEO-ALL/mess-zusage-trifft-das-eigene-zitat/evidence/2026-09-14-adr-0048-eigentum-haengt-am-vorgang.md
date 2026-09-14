**Vorgang:** Review-Report `docs/reviews/2026-09-14-adr-0048-konsistenzrunde.md`, HIGH-1 — der
Vorgang ist das Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden.
**Fund:** Die Messung, die §Kontext trägt, zählt Stellen, an denen *Welle-Plan* und *Planner* in
einem Satz zusammentreffen — und die Datei, die die Messung abdruckt, ist selbst voll davon. Das
abgedruckte Kommando lieferte an dem Stand, an dem die Datei lebt, **8** statt **3**; fünf Treffer
waren ihre eigenen Zeilen, einer davon innerhalb einer Festlegung.

**Zwei Verschärfungen gegenüber den bisherigen Belegen.** Der Zusatz *„kein Erwartungswert"* deckt
den Fall nicht — er deckt Drift **nach** dem Schreiben, hier bewegt der schreibende Vorgang die
Zahl selbst. Und ein Re-Evaluierungs-Trigger derselben Datei machte seine Beobachtbarkeit an genau
diesem Kommando fest: Er war im Moment des Einfrierens von der eigenen Festlegung erfüllt.

Behoben, solange die Datei `Proposed` war — durch eine Pathspec-Verengung, die den Gegenstand
ausnimmt, und durch einen Trigger, der nicht mehr an einer Ordnungszahl hängt. Die benannte Klasse
führt
[`MR-058`](../../../../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen);
ihr Geltungsbereich nimmt `docs/plan/adr/` aus — sie benennt den Fall, sie bindet ihn nicht.
