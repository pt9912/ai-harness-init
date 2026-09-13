# Nächste Rolle übernimmt vor dem Schluss der vorigen Runde

**Sub-Area:** `*` (gesamtes Repo)

Eine Review-Runde verdiktiert **blockierend**, der Implementer arbeitet nach — und die nächste Rolle
übernimmt, ohne dass eine Runde die Nacharbeit freigegeben hat. Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Sequenz für einen Slice setzt die Übergabe Implementer →
Verifier *„nach Review-Schluss"* an; **was eine Runde schließt, sagt keine Quelle**: weder, ob die
Freigabe eine eigene Runde verlangt, noch, ob die Behebungs-Zusage des Implementers genügt. Die
übernehmende Rolle prüft die Nacharbeit dann selbst mit — und ersetzt damit genau den zweiten Blick,
für den die Rollen-Trennung existiert.

Die Fehlerrichtung ist *die Runde ist geschlossen* statt *ihr Verdikt steht noch*. Die
Nachbarklasse
[`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
deckt den Fall nicht: Dort fehlt das Artefakt der Übergabe, hier liegen die Reports vor und es fehlt
die **Bedingung**, unter der sie als erledigt gelten.
