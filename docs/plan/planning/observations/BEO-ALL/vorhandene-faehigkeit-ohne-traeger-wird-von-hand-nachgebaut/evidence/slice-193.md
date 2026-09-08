**Vorgang:** slice-193
**Fund:** Der committet vendored Baum wurde beim Sprung auf `v6.5.0` von Hand aus dem `git`-Baum
des Kurs-Klons gelegt, während `internal/fetch.Baseline` den Weg *Asset laden → `sha256` prüfen →
zwei Bäume entpacken → `SHA256SUMS` schreiben* vollständig führt — die Funktion hatte damals genau
einen Aufrufer, den Init-Pfad für Zielrepos
(`git grep -n 'fetch\.Baseline(' -- cmd internal | grep -v _test`). Gefehlt hat nicht die
Fähigkeit, sondern ihr Einstieg für den eigenen Baum: `grep -nE '^(baseline|regelwerk)[a-z-]*:'
Makefile` nannte drei **prüfende** Ziele und kein herstellendes. Der Preis war ein Baum aus der
falschen Quelle plus ein Folge-Slice, der ihn nachzieht.

**Der Beleg trägt diesen Vorgang und nicht den Slice, der ihn eingetragen hat:** Der Eintrag
entsteht aus dem vierten Risiko von `slice-200`, das die Klasse ausdrücklich zur Entscheidung an
die Closure gibt; `slice-200` selbst hat den Weg gebaut und nicht von Hand genommen, ein Beleg dort
zählte eine Gelegenheit, die er nicht hatte.
