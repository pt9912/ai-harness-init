**Vorgang:** slice-219
**Fund:** Zwei neu geschriebene Doc-Kommentare in
[`internal/archive/vorschau_test.go`](../../../../../../../internal/archive/vorschau_test.go)
trugen den Konjunktiv über die verworfene Alternative statt einer der fünf Klassen aus
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.7 — *„Ein Test, der stattdessen
archive.AltbestandSchluessel an beiden Enden verglichen haette, waere gegen eine Aenderung des
Werts blind"* und *„unter einer Welle-Kennung waere das 'mehrdeutiger-plan'"*. Beide sind wörtlich
die Form, die §3.7 als **Falsch** ausschreibt, und beide standen in derselben Datei, deren übrige
Kommentare den Indikativ halten.

Der Fund liegt in der Lücke, die der Eintrag führt, und zwar an ihrer breitesten Stelle:
`make comment-claims` nimmt `_test.go` **dauerhaft** aus seinem Prüfbereich
([`harness/README.md`](../../../../../../../harness/README.md) §Sensors, Punkt 3 der drei
Verengungen), und der Lauf meldete über dem unveränderten Stand `58 Datei(en) geprueft,
0 Befund(e)` — eine Vollständigkeits-Zeile, die über genau diese zwei Stellen nichts sagt.
Gefunden hat sie das Review, nicht ein Gate; umgestellt sind beide auf den Indikativ über den
Ist-Zustand.
