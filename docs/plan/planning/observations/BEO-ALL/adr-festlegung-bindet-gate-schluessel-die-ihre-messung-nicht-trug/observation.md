# ADR-Festlegung bindet Gate-Schlüssel, die ihre Messung nicht trug

**Sub-Area:** `*` (gesamtes Repo)

Eine Layout-Festlegung einer ADR (Pfade, Schreibweisen) hängt an Globs oder Regeln eines Fremd-Gates und nennt als
Messung nur einen Teil davon: Die Festlegung maß die Auflösung der Import-Symbole, nicht jede Regel, die an denselben
Pfaden hängt. Die Lücke tritt erst im Vorgang auf, der sie baut — dort widerlegt die Messung des Reviewers die
Festlegung, und der Slice ist in Teilen neu zu bauen. Nachbar:
[`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
hat die Annahme im DoD-Punkt des Plans, hier steht sie in der Messung der ADR.
