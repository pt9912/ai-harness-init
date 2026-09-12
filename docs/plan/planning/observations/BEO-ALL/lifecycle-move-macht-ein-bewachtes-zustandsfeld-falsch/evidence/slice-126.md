**Vorgang:** slice-126
**Fund:** Der Closure-Move nach `done/` macht den Ruhe-Marker der Roadmap falsch: `in-progress/`
trägt danach keinen `slice-*.md` mehr, und die Sektion *Offene Wellen* führte statt *Nichts in
Arbeit.* die Zeile, dass dieser Slice dort liege. Das Modul `planning` hält genau dieses Feld und
färbt `docs-check` mit `planning-drift` rot; `make slice-mv` zieht nach eigener Zusage Pfade nach,
keine Zustandssätze, und kein Anweisungssatz dieses Repos nennt den ausgleichenden Schritt. Im
selben Vorgang trat die Klasse ein zweites Mal auf, beim Move `next/` → `in-progress/` — ein Vorgang
zählt einmal.
