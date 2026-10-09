**Vorgang:** slice-ziel-traegt-keine-kennung-dieses-repos
**Fund:** Fall 641 nannte einen Test und behauptete eine Gegenprobe; die Mutation schreibt `ADR-0009` in ein Go-Literal, das auch der Literal-Wächter liest, und färbt damit zwei Tests (Review LOW-2, behoben: der Kopf nennt beide).
