**Vorgang:** slice-traeger-per-fetch-aus-dem-release
**Fund:** Der Zustand, den dieser Eintrag benennt, war der Ausgangspunkt des
Vorgangs und ist am realen Ziel gemessen: ein frischer Klon traegt keinen
Traeger (gitignorierter Zustaands-Bereich, ADR-0022 Festlegung 5(b)), und der
einzige Weg aus dem Zustand war der erneute Bootstrap-Lauf von aussen — das
Werkzeug kann den Traeger legen, aber fuer den Klon-Fall rief ihn kein Target
und kein Unterkommando. Der Vorgang hat dem Muster seinen Traeger gegeben:
`make traeger-fetch` (Fragment `harness/mk/traeger.mk`, kein Prerequisite,
nichts an `GATE_CHECKS` — ADR-0058 Festlegung 3) ist der Einstieg, und die
E2E-Stufe `traeger_fetch_im_ziel` in `harness/tools/full-smoke.sh` misst
Zustand und Weg am realen Ziel. Der Traeger ist damit mit einem Kommando
nachholbar statt durch den erneuten Bootstrap-Lauf — das Risiko ist gesenkt,
nicht auf null: der Lauf, der vor der Handarbeit im eigenen Code nachsieht,
bleibt der Traeger der Klasse.