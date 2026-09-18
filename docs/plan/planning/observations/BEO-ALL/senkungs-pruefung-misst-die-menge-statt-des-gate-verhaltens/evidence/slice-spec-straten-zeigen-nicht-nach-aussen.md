**Vorgang:** slice-spec-straten-zeigen-nicht-nach-aussen

**Fund:** Der Vorgang fügt einer Gate-Konfiguration eine Ausnahme hinzu (`matrix.exempt-paths`) und
beantwortet die Senkungs-Frage (AGENTS.md §3.5) in §1, Schärfung 3 zunächst über eine
**Mengen**-Aussage: Die drei Pfade seien „heute keiner Klasse zugeordnet", die Ausnahme nehme ihnen
also nichts. Diese Antwort kann richtig sein und beantwortet eine andere Frage als die gestellte —
sie vergleicht, **welche Namen** vorher und nachher klassifiziert sind, nicht, **welchen Zustand**
das Gate vorher zurückwies und nachher durchlässt.

**Auflösung — die Sonde, nicht die Menge.** Die Start-Frage (b) des Plans liegt als
Architect-Verdikt vor (`docs/reviews/2026-09-18-spec-straten-architect.md` §(b)) und ersetzt die
Mengen-Antwort durch eine Prüf-Form je Pfad: denselben konstruierten Zustand zweimal fahren, gegen
den heutigen und gegen den vorgeschlagenen Stand — **Senkung genau dann, wenn der heutige Stand
zurückweist und der vorgeschlagene durchlässt.** Über die drei Pfade angewandt kippt das Urteil für
einen: `docs/plan/planning/done/**` ist heute Quelle der Klasse `slice` und stünde heute unter der
Status-Prüfung — die weite Ausnahme wäre eine Senkung, und so ist sie **nicht** geliefert. Für den
ADR-Index und die Review-Reports bleibt es bei *keine Senkung*, jetzt am Verhalten begründet.

**Wirkung und Grenze.** Die gelieferte Ausnahme nimmt aus der **Status**-Prüfung, nicht aus den
Regeln; die Gegenprobe aus §1 misst das Verhalten, nicht die Liste: ein Link aus
`spec/architecture.md` auf den Index bleibt `matrix-forbidden`, obwohl der Index in `exempt-paths`
steht. Die Klasse ist damit in diesem Vorgang **nicht mehr über die Menge beantwortet** — benannt,
nicht geschlossen, weil kein Sensor die Frage stellt: Träger bleibt der Lauf, der eine
Senkungs-Frage aufwirft.
