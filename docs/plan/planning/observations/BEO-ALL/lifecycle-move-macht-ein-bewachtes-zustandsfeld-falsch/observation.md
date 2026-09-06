# Lifecycle-Move macht ein bewachtes Zustandsfeld falsch

**Sub-Area:** `*` (gesamtes Repo)

Der vom Prozess vorgeschriebene `git mv` des Planning-Lifecycle macht ein **Zustandsfeld** in einem
anderen lebenden Artefakt falsch — den Ruhe-Marker der Roadmap, eine Zeiger-Liste, eine
Stand-Zelle —, und welcher Schritt es nachzieht, schreibt kein Artefakt vor, das der bewegende Lauf
liest. Trägt ein Sensor genau dieses Feld, färbt der Move den Lauf rot, der ihn ausführt; trägt es
keiner, steht das Feld still falsch. Beide Fälle sind dieselbe Lücke, nur einmal laut und einmal
leise.

Zwei Nachbarn führen dieselbe Ursache mit anderem Gegenstand und stehen bereits auf `verkörpert`:
[`verweise-brechen-beim-ortswechsel`](../verweise-brechen-beim-ortswechsel/observation.md) für die
**Verweise** auf die bewegte Datei und
[`vorgeschriebener-ortswechsel-macht-adresse-tot`](../vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
für die **Adresse** in einem eingefrorenen Artefakt. Der Träger der ersten,
`make slice-mv`, zieht nach eigener Zusage *Pfade nach, keine Zustandssätze* — die dritte Hälfte
hat damit keinen.
