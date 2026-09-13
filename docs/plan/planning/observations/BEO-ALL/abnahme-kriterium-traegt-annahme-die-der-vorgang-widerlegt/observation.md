# Abnahme-Kriterium trägt eine Annahme, die der Vorgang widerlegt

**Sub-Area:** `*` (gesamtes Repo)

Ein DoD-Punkt schreibt eine **ungemessene Annahme** als Tatsache fest, und die Messung, die derselbe
Vorgang als ersten Schritt fährt, widerlegt sie. Der Punkt ist danach **wie geschrieben** nicht wahr
abhakbar: Das gelieferte Artefakt erfüllt ihn, indem es ihm widerspricht. Korrigieren darf ihn
weder der Implementer noch der Reviewer — die ausführende Rolle schreibt ihr eigenes
Abnahmekriterium nicht um ([`AGENTS.md`](../../../../../../AGENTS.md) §3.10) —, und so übersteht er
jede Runde, bis die Closure ihn anfasst.

Zwei Nachbarklassen teilen die Ursache — ein Abnahmemaßstab, der nicht über die Lieferung urteilt —
und decken den Fall nicht:
[`abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht`](../abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht/observation.md)
hat die umgekehrte Fehlerrichtung, dort ist das Kriterium **wahr** und sagt nichts;
[`mess-zusage-trifft-das-eigene-zitat`](../mess-zusage-trifft-das-eigene-zitat/observation.md) teilt
die Fehlerrichtung *im Moment des Abhakens unerfüllbar*, aber aus einer Eigenschaft der
Bezugsmenge — hier ist die Bezugsmenge in Ordnung und die **Tatsachenbehauptung** falsch.

## Benannt, nicht gezählt

Der Plan, an dem die Klasse zuerst auffiel, hatte die Annahme in §6 als solche ausgewiesen
(*„angenommen sind die drei d-check-Ergebnisse"*) und ihr Kippen mit einer Rückführung verknüpft.
Das hat den Fall nicht verhindert: Die Rückführung misst **Größe** — Liefer-Punkte, Schichten,
Prüfbarkeit in einer Sitzung —, und eine gekippte Annahme bewegt keine der drei. Ein Risiko, das
seine eigene Folge falsch adressiert, ist kein Gegenmittel.
