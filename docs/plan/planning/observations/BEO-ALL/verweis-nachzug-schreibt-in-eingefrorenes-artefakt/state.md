**Stand:** verkörpert

Zielort:
[`ADR-0042`](../../../../../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) —
der Verweis-Nachzug ersetzt im Zeitdokument die Adresse und in der `Accepted`-ADR nichts;
Festlegung 2 trägt das Kriterium, Festlegung 5 die Sperre des ersten Archiv-Moves. Den Ausschluss
führen seit `slice-221` beide Träger (`make slice-mv` und `archive-welle`). Für den Baum
`docs/reviews/` schneidet
[`ADR-0070`](../../../../../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1 die Reichweite: der Nachzug schreibt dort nur die Adresse in Link-Form, die drei
übrigen Bäume behalten ihn in jeder Form; beide Träger führen diese Form-Regel:
`slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` und
`slice-archive-welle-schreibt-in-reports-nur-die-link-form` liegen in `done/`
(`ls docs/plan/planning/done | grep -c -e slice-lifecycle-move-schreibt-in-reports-nur-die-link-form -e slice-archive-welle-schreibt-in-reports-nur-die-link-form`
→ 2). Ein zweiter
Herkunfts-Anker steht nicht: Was aus einer ADR folgt, trägt bereits eine ID (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker, Geltungsbereich).

**Grenze der Verkörperung, benannt.** Entschieden ist das Kriterium *ändert sich die Aussage?* und
nicht eine Aufzählung von Bäumen: `docs/plan/adr/**` ist aus beiden Nachzug-Trägern ausgenommen,
`docs/reviews/**` und `docs/plan/planning/done/**` bleiben darin — `done/**` in jeder Form,
`docs/reviews/**` in der Link-Form. Drei Gegenformen, in denen die Adresse die Aussage trägt, bleiben nach
Festlegung 4 unrepariert; für sie besteht an beiden Enden kein Wächter, und Träger bleibt der
Lauf, der den Move plant.
