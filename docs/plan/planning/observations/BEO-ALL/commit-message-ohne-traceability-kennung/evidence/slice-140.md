**Vorgang:** slice-140
**Fund:** Drei Commits der Slice-Kette nennen weder eine `LH-*`- noch eine `ADR-*`-Kennung —
gemessen über den ganzen Bereich statt über die zwei, die der Review benannte:
`for c in $(git rev-list e184d996..f48bd37b); do git log -1 --format=%B $c | grep -qE 'LH-[A-Z]+-[0-9]+|ADR-[0-9]{4}' || git log -1 --format='%h %s' $c; done`
→ `e0e3832d`, `7377f9ba` und der werkzeug-erzeugte `ad7cde01`. Der dritte ist der interessante:
seine Message schreibt `make slice-mv`, nicht ein Lauf — die Regel trifft damit auch einen
Erzeuger, den keine Rolle beim Schreiben liest. Der Slice-Kopf trägt die Bezüge vollständig, die
Messages erben sie nicht, und nach einem Push ist der Verstoß nicht mehr behebbar, ohne Historie
zu schreiben.
