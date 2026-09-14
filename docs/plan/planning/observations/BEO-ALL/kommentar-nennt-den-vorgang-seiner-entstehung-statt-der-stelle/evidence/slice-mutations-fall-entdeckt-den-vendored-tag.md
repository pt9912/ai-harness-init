**Vorgang:** slice-mutations-fall-entdeckt-den-vendored-tag
**Fund:** Zwei Review-Runden über demselben Diff fanden die Klasse in allen drei Ausprägungen, die
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.7 als *Falsch* aufführt. **Chronik statt Zustand:**
drei neue Kommentare beschrieben den abwesenden Vorzustand (*„nicht über der geflachten
Zeilen-Menge alter Fassung"*, *„… die dieses Repo an `failure_form` schon einmal beseitigt hat"*,
*„— vorher blieb hier nur die unadressierte Meldung"*). **Herkunft als Erzählung:** vier
Kommentare trugen einen DoD-Punkt und die Slice-Kennung als Anker — die Kennung
[`LH-QA-01`](../../../../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
löst auf, der DoD-Zeiger daneben nicht (*„…, DoD dieses Slice"*,
*„Deckt DoD 1 des Slice slice-…"*) — ein DoD-Punkt eines wandernden Plans ist keine der zulässigen
Anker-Formen, und der Zeiger löste nirgends auf. **Konjunktiv über die verworfene Alternative:**
die Korrektur der ersten Ausprägung tauschte Chronik gegen genau diesen Modus (*„wären dieselbe
Drift-Konstruktion"*), während drei unberührte Geschwister-Sätze derselben Aussage im Indikativ
stehen blieben — die Datei führte die Kopplungs-Aussage danach in zwei Fassungen. Alle Stellen
sind eingelöst; gezählt wird der Vorgang, nicht die Zahl der Stellen. Gefunden hat es je das
Review, kein Sensor: `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht,
worüber ein Kommentar spricht.
