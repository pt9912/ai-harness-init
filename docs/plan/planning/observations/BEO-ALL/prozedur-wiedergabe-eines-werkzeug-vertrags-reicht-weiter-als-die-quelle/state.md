**Stand:** verkörpert

Zielort: [`.claude/commands/implement-slice.md`](../../../../../../.claude/commands/implement-slice.md) — Punkt 17 der
Pre-completion-Checkliste (Doku), der Satz *„Gibt Prozedur- oder Nutzer-Doku den Vertrag eines Werkzeugs wieder …,
zeigt jede Aussage auf die Quelle, die sie trägt … und geht nicht weiter als diese"*, mit dem Herkunfts-Anker
`seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`
(`grep -c 'seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap' .claude/commands/implement-slice.md` → 1).
Der Anweisungssatz gehört der Rolle, die ihn ausführt: die Zeile schreibt der Implementer
([`ADR-0028`](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); den Ausgang setzt der Planner.
Der Anker nennt den Slice, in dessen Closure die Klasse ihren dritten Beleg trug; dessen Kennung löst über `done/`
auf.

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: kein Test und kein Gate hält
`docs/user/releasing.md` gegen die Ausgabe des Skripts oder gegen die Zusage seiner ADR, und die Zeile trägt nur das
Lesen im Lauf des Implementers, bevor die Meldung „fertig" geht. Träger daneben ist der Review des Schritts und der
Verifier, der die Aussagen fährt. **Eskalation:** tritt die Klasse nach der Zeile erneut ein, ist die Trägerschaft
der Befund und nicht die Wiederholung; die nächste Stufe ist eine Hard Rule
([`AGENTS.md`](../../../../../../AGENTS.md) §3.8, Architect).
