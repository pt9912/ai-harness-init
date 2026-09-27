**Stand:** verkörpert

Zielort: [`.harness/skills/reviewer.md`](../../../../../../.harness/skills/reviewer.md) — die Zeile
*„Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil"*, mit dem Herkunfts-Anker
`seit slice-204-das-programm-feld-nennt-das-programm`
(`grep -c 'seit slice-204-das-programm-feld-nennt-das-programm' .harness/skills/reviewer.md`
→ 1, kein Erwartungswert). Der Anweisungssatz gehört der Rolle, die ihn ausführt: die Zeile schreibt
der Reviewer ([`ADR-0028`](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
den Ausgang setzt der Planner. Der Anker nennt den Slice, in dessen Closure die Klasse ihren dritten
Beleg trug; dessen Kennung löst über `done/` auf.

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: `make mutate` prüft die
Haltbarkeit gelisteter Fälle, nicht das Fehlen eines Falls für eine benannte, mehrteilige
Kommentar-Zusage, und `make comment-claims` prüft nur, ob ein genannter Sensor existiert, nicht, ob
er jede Hälfte der Zusage trifft. Träger ist der Review, der bei jeder mehrteiligen Zusage die
Mutations-Deckung je Teil hält, und der Lauf, der den Kommentar schreibt, nach
[`AGENTS.md`](../../../../../../AGENTS.md) §3.6. Die Zeile deckt Zusagen, die ein Diff anlegt oder
ändert, nicht den Bestand — die Namens-Maskierung in
`slice-archive-welle-schreibt-in-reports-nur-die-link-form` bleibt ein akzeptiertes Negativ, bis ein
künftiger Diff die Stelle anfasst.
